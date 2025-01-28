#!/bin/env bash

# set -e at the beginning of the script to cause the shell to exit if any command exits with a non-zero status.
set -e

# set -u to treat unset variables as an error and immediately exit.
# This would reduce the need for manual checks for the presence of environment variables.
set -u

# set -o pipefail to cause the script to fail if any of the commands piped together fail.
set -o pipefail

# Check if psql is installed
if ! command -v psql &> /dev/null; then
  echo "psql could not be found. Please install it and try again."
  exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
  echo "curl could not be found. Please install it and try again."
  exit 1
fi

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI could not be found. Please install it and try again."
  exit 1
fi

echo "Configuring AWS credentials..."
# authenticate to aws
aws configure set aws_access_key_id $AWS_ACCESS_KEY && aws configure set aws_secret_access_key $AWS_SECRET_KEY && aws configure set region $AWS_REGION

# Get the latest file from S3
echo "Fetching latest file from S3: s3://${S3_BUCKET_NAME}/${SEED_FOLDER}"
latest_file=$(aws s3 ls "s3://${S3_BUCKET_NAME}/${SEED_FOLDER}" | sort -k1,2 | tail -n 1 | awk '{print $4}')

if [[ -z "${latest_file}" ]]; then
  echo "No files found in S3 path: s3://${S3_BUCKET_NAME}/${SEED_FOLDER}"
  exit 1
fi

# Download the latest file from S3
echo "Downloading file: ${latest_file}"
aws s3 cp "s3://${S3_BUCKET_NAME}/${SEED_FOLDER}/${latest_file}" seed.sql

# Check if seed.sql exists in the current directory
if [[ ! -f "seed.sql" ]]; then
  echo "The seed.sql file could not be found in the current directory."
  exit 1
fi

echo "Database seeding started."
echo "Using restore method: ${RESTORE_METHOD}"

# Seed the database
if [[ "${RESTORE_METHOD}" == "pg_restore" ]]; then
  echo "Running pg_restore..."
  pg_restore -d "$DATABASE_URL" seed.sql
elif [[ "${RESTORE_METHOD}" == "psql" ]]; then
  echo "Running psql..."
  psql "$DATABASE_URL" < seed.sql
else
  echo "Invalid restore method. Please set the RESTORE_METHOD environment variable to either 'pg_restore' or 'psql'."
  exit 1
fi

echo "Database seeding completed successfully."
echo "Cleaning up temporary files..."
rm -f seed.sql
echo "Done!"
