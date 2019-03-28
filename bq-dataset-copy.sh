#!/bin/sh

# Copy BigQuery tables to a new region.
#
# Manual setup:
# 0. Create destination dataset and temporary buckets
# 1. Export table schema (bq show --schema --format=prettyjson projectid:datasetid.tableid >> schema-file.json)
# 
# Run this script:
# 2. Export US BQ to US GCS
# 3. Copy US GCS to EU GCS
# 4. Load EU GCS to EU BQ using table schema

export SOURCE_DATASET="projectid1:eudataset1"
export DEST_DATASET="projectid1:usdataset1"
export SOURCE_BUCKET="projectid1-bucket-in-eu"
export DEST_BUCKET="projectid1-bucket-in-us"
export SCHEMA_FILE="schema-file.json"
export NUMBER_OF_TABLES=2

for f in `bq ls -n $NUMBER_OF_TABLES $SOURCE_DATASET |grep TABLE | awk '{print $1}'`
do
  export EXPORT_CMD="bq --location=us extract --destination_format NEWLINE_DELIMITED_JSON $SOURCE_DATASET.$f gs://$SOURCE_BUCKET/$f "
  export COPY_CMD="gsutil cp -p gs://$SOURCE_BUCKET/$f gs://$DEST_BUCKET/$f "
  export LOAD_CMD="bq --location=eu load --source_format=NEWLINE_DELIMITED_JSON $DEST_DATASET.$f gs://$DEST_BUCKET/$f $SCHEMA_FILE"

  echo `$EXPORT_CMD`
  echo `$COPY_CMD`
  echo `$LOAD_CMD`

  echo "---> Successfully copied $f from $SOURCE_DATASET to $DEST_DATASET"
done
