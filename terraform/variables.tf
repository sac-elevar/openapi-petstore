variable "region" {
  description = "AWS region"
  type = string
  default = "ap-southeast-1"
}

variable "aws_access_key_id" {
  description = "AWS ACCESS_KEY_ID"
  type = string
  default = ""
}

variable "aws_secret_access_key" {
  description = "AWS SECRET_ACCESS_KEY"
  type = string
  default = ""
}