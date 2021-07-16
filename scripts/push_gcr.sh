function push_gcr {
#push_gcr [project] [image] [tag]
#push_gcr "" "nim-plus" "latest"
GCP_PROJECT=${1:-$(gcloud config get-value project)}
IMAGE=${2:-"nim-plus"}
TAG=${2:-"latest"}
# authorize docker to push custom images
echo "authorize docker to push to Google Container Registry"
gcloud auth configure-docker
docker tag $IMAGE gcr.io/$GCP_PROJECT/$IMAGE:$TAG
docker push gcr.io/$GCP_PROJECT/$IMAGE:$TAG
#echo "delete container"
#DIGEST=$(gcloud container images list-tags gcr.io/${GCP_PROJECT}/${IMAGE} --format json | jq -r .[].digest)
# gcloud container images describe gcr.io/${GCP_PROJECT}/${IMAGE}@${DIGEST} --format json | jq -r .image_summary.fully_qualified_digest
#gcloud container images delete gcr.io/${GCP_PROJECT}/${IMAGE}@${DIGEST} --force-delete-tags
}
