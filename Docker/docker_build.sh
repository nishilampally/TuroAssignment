#!/bin/bash

echo "Logging into Docker Hub"

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Build docker image 
docker build -t $DOCKER_IMAGEREPO:$DOCKER_TAG -f $DOCKER_FILE_PATH .

# Push docker image to docker hub
docker push $DOCKER_IMAGEREPO:$DOCKER_TAG

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image build was successfull with DOCKER_TAG: $DOCKER_TAG"
else
    echo "Failed to build Docker image"
fi