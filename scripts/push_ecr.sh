function push_ecr {
#push_ecr [local-image] [tag]
#push_ecr nim-plus latest
LOCALIMAGE="${1:-"nim-plus"}"
LIST=$(terraform output -state=${HOME}/workspace/terraform/fargate/ecr/terraform.tfstate  --json | jq .[\"repo-list\"].value)
ECR=$(echo $LIST | jq -r .[\"$LOCALIMAGE\"])
REGISTRY=$(echo $ECR | cut -d "/" -f1 )
REPOSITORY=$(echo $ECR | cut -d "/" -f2)
IMAGEUID=$(echo $REPOSITORY | rev |  cut -d "-" -f1 | rev)
IMAGE=$( echo $REPOSITORY | sed s/"-$IMAGEUID"//)
TAG=${2:-"latest"}
# authorize docker to push custom images
REGION=$(echo $REGISTRY | cut -d "." -f4)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
echo "pushing $REGISTRY/$REPOSITORY:$TAG"
read -p "Press enter to continue"
echo "docker $IMAGE $REGISTRY/$REPOSITORY:$TAG"
docker tag $IMAGE $REGISTRY/$REPOSITORY:$TAG
docker push $REGISTRY/$REPOSITORY:$TAG
#echo "delete container"
#https://docs.aws.amazon.com/AmazonECR/latest/userguide/delete_image.html
# aws ecr list-images \
#      --repository-name $REGISTRY

# aws ecr batch-delete-image \
#      --repository-name my-repo \
#      --image-ids imageTag=tag1 imageTag=tag2

# aws ecr batch-delete-image \
#      --repository-name my-repo \
#      --image-ids imageDigest=sha256:4f70ef7a4d29e8c0c302b13e25962d8f7a0bd304EXAMPLE imageDigest=sha256:f5t0e245ssffc302b13e25962d8f7a0bd304EXAMPLE

}
