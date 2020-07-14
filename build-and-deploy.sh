set -eu -o pipefail

PROJECT_ID=$1

gcloud --project ${PROJECT_ID} app deploy -q --stop-previous-version --promote app.yaml