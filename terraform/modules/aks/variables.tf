variable "resource_group_name" {
  type        = string
  description = "resource group supplied by the calling environment"
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "aks_name" {
  type        = string
  description = "name supplied by the calling environment"
  validation {
    condition     = length(var.aks_name) > 0
    error_message = "aks_name must not be empty"
  }
}

variable "node_name" {
  type        = string
  description = "node name supplied by the calling environment"
  validation {
    condition     = length(var.node_name) > 0
    error_message = "node_name must not be empty"
  }
}

variable "region" {
  type        = string
  description = "region supplied by the calling environment"
  validation {
    condition     = length(var.region) > 0
    error_message = "region must not be empty"
  }
}

variable "sku" {
  type        = string
  description = "sku supplied by the calling environment, defaults to Standard"
  default     = "Standard"
}

variable "min" {
  type        = number
  description = "min number of nodes supplied by the calling environment, defaults to 1"
  default     = 1
}

variable "max" {
  type        = number
  description = "max number of nodes supplied by the calling environment, defaults to 1"
  default     = 1
}

variable "aks_version" {
  type        = string
  description = "version supplied by the calling environment, defaults to 1.32"
  default     = "1.32"
}

variable "subnet_id" {
  type        = string
  description = "subnet supplied by the calling environment"
  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "subnet_idmust not be empty"
  }
}

variable "dns_prefix" {
  type        = string
  description = "version supplied by the calling environment, defaults to 1.32"
  default     = "1.35"
  validation {
    condition     = length(var.dns_prefix) > 0
    error_message = "dns_prefix must not be empty"
  }
}

variable "service_cidr" {
  type        = string
  description = "cidr for the internal kubernetes network supplied by the calling environment"
}

variable "service_dns_ip" {
  type        = string
  description = "dns ip for the internal kubernetes network supplied by the calling environment"
}