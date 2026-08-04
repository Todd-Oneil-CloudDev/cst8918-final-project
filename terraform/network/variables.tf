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