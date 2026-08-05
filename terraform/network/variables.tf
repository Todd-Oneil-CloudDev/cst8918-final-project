variable "group_number" {
  type        = string
  description = "CST8918 group number from Brightspace, e.g. '01'. Used in every resource name."
  default     = "01"
}

variable "location" {
  type        = string
  description = "Azure region for the state storage account"
  default     = "canadacentral"
}

variable "rg" {
  type        = string
  description = "network resource group"
  default     = "cst8918-final-project-group"
}

variable "subnet_map" {
  type = map(string)
  default = {
    prod  = "10.0.0.0/16"
    test  = "10.1.0.0/16"
    dev   = "10.2.0.0/16"
    admin = "10.3.0.0/16"
  }
}