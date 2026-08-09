variable "resource_group_name" {
  type        = string
  description = "resource group supplied by the calling environment"
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "name" {
  type        = string
  description = "resource name supplied by the calling environment"
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