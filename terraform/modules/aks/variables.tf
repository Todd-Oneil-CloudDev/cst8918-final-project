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
    condition     = length(var.name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "node_name" {
  type        = string
  description = "node name supplied by the calling environment"
  validation {
    condition     = length(var.name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "region" {
  type        = string
  description = "region supplied by the calling environment"
  validation {
    condition     = length(var.region) > 0
    error_message = "resource_group_name must not be empty"
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