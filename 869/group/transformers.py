import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin

# TODO: These don't work as transformers. The parameters are evaluated in a
# conditional, which pandas doesn't like. Need to fix this.


class AvgPrevLoanDurationTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, prevloans_df=None):
        self.prevloans_df = prevloans_df
        self.avg_duration_by_customer = None

    def fit(self, X, y=None):
        prevloans = self.prevloans_df.copy()
        prev_creation = pd.to_datetime(prevloans["creationdate"], errors="coerce")
        prev_closed = pd.to_datetime(prevloans["closeddate"], errors="coerce")
        duration_mask = prev_creation.notna() & prev_closed.notna()
        prevloans = prevloans[duration_mask].copy()
        prevloans["duration_days"] = (
            prev_closed[duration_mask] - prev_creation[duration_mask]
        ).dt.days
        self.avg_duration_by_customer = prevloans.groupby("customerid")[
            "duration_days"
        ].mean()
        return self

    def transform(self, X):
        X = X.copy()
        X["avg_prevloan_duration"] = (
            X["customerid"].map(self.avg_duration_by_customer).fillna(0)
        )
        return X


class DemographicsJoinTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, demographics_df=None):
        self.demographics_df = demographics_df

    def fit(self, X, y=None):
        # Remove duplicates based on 'customerid'
        self.demographics_clean = self.demographics_df.drop_duplicates(
            subset="customerid", keep="first"
        )
        return self

    def transform(self, X):
        # Left join on 'customerid'
        return X.merge(self.demographics_clean, on="customerid", how="left")
