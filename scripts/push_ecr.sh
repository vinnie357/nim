function push_ecr {
#push_ecr [local-image] [tag]
#push_ecr nim-plus latest
LOCALIMAGE="${1:-"nim-plus"}"
ECR=$(terraform output -state=${HOME}/workspace/terraform/fargate/ecr/terraform.tfstate  --json | jq -r ".[\"$LOCALIMAGE-url\"].value" )
REGISTRY=$(echo $ECR | cut -d "/" -f1 )
REPOSITORY=$(echo $ECR | cut -d "/" -f2)
IMAGEUID=$(echo $REPOSITORY | cut -d "-" -f3)
IMAGE=$( echo $REPOSITORY | tr -d "'-'${IMAGEUID}" | sed 's/.$//')
TAG=${2:-"latest"}
# authorize docker to push custom images
REGION=$(echo $REGISTRY | cut -d "." -f4)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
echo "pushing $REGISTRY/$REPOSITORY:$TAG"
read -p "Press enter to continue"
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
