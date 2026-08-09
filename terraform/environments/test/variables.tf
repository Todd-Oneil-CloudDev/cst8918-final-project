# ********************** ACR *************************
variable "acr_sku" {
  type        = string
  description = "sku supplied by the calling environment, defaults to Standard"
  default     = "Standard"
}

variable "acr_name" {
  type        = string
  description = "name supplied by the calling environment"
  validation {
    condition     = length(var.acr_name) > 0
    error_message = "resource_group_name must not be empty"
  }
}


# ********************** AKS *************************
variable "aks_name" {
  type        = string
  description = "name supplied by the calling environment"
  validation {
    condition     = length(var.aks_name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "node_name" {
  type        = string
  description = "node name supplied by the calling environment"
  validation {
    condition     = length(var.node_name) > 0
    error_message = "resource_group_name must not be empty"
  }
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
  description = "version supplied by the calling environment, defaults to 1.33"
  default     = "1.35"
}

variable "aks_dns_prefix" {
  type = string
  description = "dns supplied by the calling environment"
}

variable "aks_service_cidr" {
  type        = string
  description = "cidr for the internal kubernetes network supplied by the calling environment"
}

variable "aks_service_dns_ip" {
  type        = string
  description = "dns ip for the internal kubernetes network supplied by the calling environment"
}

# ********************** REDIS *************************
variable "redis_name" {
  type        = string
  description = "name supplied by the calling environment"
  validation {
    condition     = length(var.redis_name) > 0
    error_message = "resource_group_name must not be empty"
  }
}

variable "redis_sku" {
  type        = string
  description = "sku supplied by the calling environment, defaults to Standard"
  default     = "Standard"
}