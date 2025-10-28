#!/usr/bin/env fish

if test (count $argv) -gt 1
    echo "Usage: fetch_and_save_trump_tweets.fish [starting_page_number]" >&2
    exit 1
end

if test (count $argv) -eq 1
    set -g PAGE_NUMBER $argv[1]
else
    echo "No starting page number provided, defaulting to 1" >&2
    set -g PAGE_NUMBER 1
end

set -l CSV_FILE "tweets.csv"

# Write CSV header if file does not exist
if not test -e $CSV_FILE
    echo "page_number,browse_flag,date,document_id,image_url,media_type,sequence,speaker,speaker_id,subject,text,type,word_count,deleted_flag,account_url,handle,id,platform,post_url,social_author,social_favorite_count,social_repost_count,social_visibility,search_id,score" > $CSV_FILE
end

while true
    set -l url "https://rollcall.com/wp-json/factbase/v1/twitter?platform=all&sort=date&sort_order=desc&page=$PAGE_NUMBER&format=json"
    set -l response (http get $url)

    # Check for error in response
    set -l error (echo $response | jq '.error')
    if test "$error" = "true"
        echo "[$(date)] Error fetching tweets: $response" >&2
        return
    end

    # Parse data array
    set -l data (echo $response | jq -c '.data[]?')
    if test -z "$data"
        echo "[$(date)] No data found" >&2
        return
    end

    for entry in $data
        set -l browse_flag (echo $entry | jq -r '.browse_flag')
        set -l date (echo $entry | jq -r '.date')
        set -l document_id (echo $entry | jq -r '.document_id')
        set -l image_url (echo $entry | jq -r '.image_url')
        set -l media_type (echo $entry | jq -r '.media_type')
        set -l sequence (echo $entry | jq -r '.sequence')
        set -l speaker (echo $entry | jq -r '.speaker')
        set -l speaker_id (echo $entry | jq -r '.speaker_id')
        set -l subject (echo $entry | jq -r '.subject')
        set -l text (echo $entry | jq -r '.text' | string replace --all '"' '""')
        set -l type (echo $entry | jq -r '.type')
        set -l word_count (echo $entry | jq -r '.word_count')
        set -l deleted_flag (echo $entry | jq -r '.deleted_flag')
        set -l account_url (echo $entry | jq -r '.account_url')
        set -l handle (echo $entry | jq -r '.handle')
        set -l id (echo $entry | jq -r '.id')
        set -l platform (echo $entry | jq -r '.platform')
        set -l post_url (echo $entry | jq -r '.post_url')
        set -l social_author (echo $entry | jq -r '.social.author')
        set -l social_favorite_count (echo $entry | jq -r '.social.favorite_count')
        set -l social_repost_count (echo $entry | jq -r '.social.repost_count')
        set -l social_visibility (echo $entry | jq -r '.social.visibility')
        set -l search_id (echo $entry | jq -r '.search_id')
        set -l score (echo $entry | jq -r '.score')

        set -l year (string split -m1 '-' $date)[1]
        if test (math $year) -lt 2017
            echo "[$(date)] Reached tweet before 2017-01-01, stopping." >&2
            return
        end

        # Write CSV row (quote text fields)
        printf '%s,%s,"%s",%s,"%s","%s",%s,"%s","%s","%s","%s","%s",%s,%s,"%s","%s","%s","%s","%s","%s",%s,%s,"%s","%s","%s"\n' \
            $PAGE_NUMBER $browse_flag $date $document_id $image_url $media_type $sequence $speaker $speaker_id $subject $text $type $word_count $deleted_flag $account_url $handle $id $platform $post_url $social_author $social_favorite_count $social_repost_count $social_visibility $search_id $score >> $CSV_FILE
    end
    echo "[$(date)] Completed page $PAGE_NUMBER" >&2

    set PAGE_NUMBER (math $PAGE_NUMBER + 1)
    echo "[$(date)] Moving to page $PAGE_NUMBER" >&2
end
