# TuroAssignment

This code is solving the problem in various phases to setup a simple web application deployment serving static files using Docker, Terraform and Kubernetes.Below code addresses specific part of the process invloving building the docker image, update the terraform code with latest tag and creating PR in Git which is CI process and once the code is merged to main branch it triggers a CD pipeline in Azure Devops which deploys and expose the application in kubernetes. 

*******************************************************************************************

# Tools involved in the entire flow

 1. Docker
 2. Bash Scripting
 3. GIT
 4. Terraform
 5. Kubernetes
 6. Azure DevOps


## **Phase 1: Creating Docker File**

```
FROM nginx:latest
RUN apt-get -y update
RUN apt-get -y install curl
COPY index.html /usr/share/nginx/html/index.html
COPY page1.html /usr/share/nginx/html/page1.html

```

## **Phase 2: Creating Bash scrip to build and publish image to Docker Hub**

```
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

```
## **Phase 3: Update tag in terraform and Push code to Git and create PR**

```
git config --global user.email "***"
git config --global user.name "***"
BRANCH_NAME=$(Build.SourceBranchName)
git checkout feature-build-$(Build.BuildId)
git pull --rebase
sed -i "s/^tag\s*=.*/tag = \"$(Build.BuildId)\"/" terraform.tfvars
git add .
git commit -m "Update Docker image tag to $(Build.BuildId)"
git push -u origin $BRANCH_NAME
curl -X POST \
-H "Authorization: token $(GITHUB_TOKEN)" \
-H "Content-Type: application/json" \
-d '{
"title": "Updated Docker tag",
"head": $(Build.SourceBranchName),
"base": "main",
"body": "Updated Docker tag to $(Build.BuildId)"
}' "https://api.github.com/repos/nishilampally/turoassignment/pulls"

```
## Phase 4: Deploy Web application in Kubernetes using Terraform

```
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
  backend "local" {}
}

provider "kubernetes" {
}

resource "random_integer" "number" {
  min = 1
  max = 10
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "${var.deployment_name}-${random_integer.number.result}"
    labels = {
      app = var.label_name
    }
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.label_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.label_name
        }
      }

      spec {
        container {
          image = "${var.image_name}:${var.tag}"
          name  = var.container_name
          port {
            container_port = var.http_container_port
          }

          port {
            container_port = var.https_container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "${var.service_name}-${random_integer.number.result}"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.label_name
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

```
## Terraform commands used to deploy application

```
terraform init  # To initiaize and download required plugins and source code from repository
terraform plan   # Shows the blueprint of the plan it is going to execute
terraform apply  # Creates the resource in the actual infrastructure

```

## Phase 5: Verify resources in Kubernetes cluster
 1. Check deployment exists by running 
   
    kubectl get deployments
```
    $ kubectl get deployments
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    simple-web-app   2/2     2            2           31s

   ```
2. Check desired number of pods are running or not as replicas specified in deployment config

   kubectl get pods
```
    $ kubectl get pods
    NAME                              READY   STATUS    RESTARTS   AGE
    simple-web-app-66c64c5ffd-ll5jt   1/1     Running   0          13h
    simple-web-app-66c64c5ffd-wdblz   1/1     Running   0          13h
```

3. Verify Service which is used to expose application is created or not

   kubectl get services
```
   $ kubectl.exe get services
    NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
    web-app-service   LoadBalancer   172.20.202.131   a9c3f425ca71e4e43b569670325358ac-591723510.us-east-1.elb.amazonaws.com   80:32095/TCP   5s

```

4. Copy External IP from the output 

    Open browser and hit http://a9c3f425ca71e4e43b569670325358ac-591723510.us-east-1.elb.amazonaws.com to see the content passed in index.html

## License
-------

For Assignement use only.

## Author Information

[Nishil Ampally](mailto:nishilampally25@gmail.com)
