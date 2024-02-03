variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "image_name" {
  description = "Image used to for Deployment"
  type        = string
}

variable "container_name" {
  description = "Name of the Container"
  type        = string
}

variable "replicas" {
  description = "Number of Replicas"
  type        = number
}

variable "http_container_port" {
  description = "Port number to expose container"
  type        = number
}

variable "https_container_port" {
  description = "Port number to expose container"
  type        = number
}

variable "label_name" {
  description = "Value of the Label"
  type        = string
}

variable "tag" {
  description = "Tag of docker image"
  type        = string
}

variable "namespace" {
  description = "Namespace in the cluster"
  type        = string
}