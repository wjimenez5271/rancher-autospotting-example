variable "aws_credentials_file" {}
variable "aws_region" {}
variable "ssh_public_key"  {}
variable "security_groups"  {
  type = "list"
}
variable "vpc_subnets" {
  type = "list"
}
