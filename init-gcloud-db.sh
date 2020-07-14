#!/usr/bin/env bash
set -eu -o pipefail

ENV_DEV=dev
ENV_PROD=prod

DEV_PROJECT_ID=cmi-mitre-dev
PROD_PROJECT_ID=cmi-mitre-prod
GCP_ZONE=us-central1-a


assign_project_id() {
  if [[ "$1" == "$ENV_DEV" ]]; then
    echo $DEV_PROJECT_ID
  elif [[ "$1" == "$ENV_PROD" ]]; then
    read -p "Will use production! Press enter to continue... " ignored
    echo $PROD_PROJECT_ID
  else
    echo "Invalid env: $1"
    exit 1
  fi
}


NAME=$(basename "$0")
if (( $# != 1 )); then
  echo "Usage: $NAME <$ENV_DEV | $ENV_PROD>"
  exit 1
fi

PROJECT_ID=$(assign_project_id "$1")
echo "Using GCP project: $PROJECT_ID"

echo ''
echo 'Initializing postgresql cloud sql instance...'
read -p 'Enter name for new sql instance: ' instance_id
read -s -p "Password to set for 'postgres' user: " password
echo ''

echo ''
set -x
gcloud --project=$PROJECT_ID sql instances create "$instance_id" \
  --root-password="$password" \
  --database-version=POSTGRES_11 \
  --require-ssl \
  --zone=$GCP_ZONE \
  --tier=db-f1-micro \
  --activation-policy=always \
  --maintenance-release-channel=production \
  --maintenance-window-day=SAT \
  --maintenance-window-hour=04
set +x

echo ''
echo 'Creating user role...'
read -p 'Enter username: ' username
read -s -p 'Enter password: ' password
echo ''
gcloud --project=$PROJECT_ID sql users create "$username" --instance="$instance_id" --password="$password"

echo ''
echo 'Creating database...'
read -p 'Enter database name: ' db_name
gcloud --project=$PROJECT_ID sql databases create "$db_name" --instance="$instance_id" --charset=UTF8

echo ''
echo 'Done!'
