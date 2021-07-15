function gcloud_auth {
# example:
#gcloud_auth "projectid"
PROJECT_ID=$1
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud auth application-default login
}
