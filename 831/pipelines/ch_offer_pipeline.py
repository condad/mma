"""
Pipeline module for CH_Offer_0_V.csv data processing.
Loads and transforms offer data using scikit-learn pipeline.
"""

import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer
from pathlib import Path

# No-op transformation pipeline
pipeline = Pipeline([
    ('identity', FunctionTransformer(lambda x: x, validate=False))
])


def load_data(data_path="../data/CH_Offer_0_V.csv"):
    """Load offer data from CSV file."""
    file_path = Path(__file__).parent / data_path
    df = pd.read_csv(file_path)
    return df


def transform_data():
    """Load and transform offer data."""
    # Load data
    raw_data = load_data()
    print(f"Loaded offer data with shape: {raw_data.shape}")
    print(f"Columns: {list(raw_data.columns)}")

    # Use no-op pipeline (identity transformation)
    transformed_array = pipeline.fit_transform(raw_data)
    
    # Create transformed DataFrame
    transformed_data = pd.DataFrame(transformed_array, 
                                    columns=raw_data.columns)

    print(f"Transformed data shape: {transformed_data.shape}")

    return transformed_data, pipeline


# Execute transformation and store as module-level variables
transformed_data, transformation_pipeline = transform_data()
raw_data = load_data()

# Export variables for import in notebooks
__all__ = ['transformed_data', 'transformation_pipeline', 'raw_data']