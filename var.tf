variable "vpc-cidr" {
  type        = string
  default     = "11.0.0.0/16"
  description = "vpc cidr block"
}


variable "public-subnet-1-cidr" {
  type        = string
  default     = "11.0.1.0/24"
  description = "public subet1 cidr block"
}


#variable "public-subnet-2-cidr" {
#  type        = string
#  default     = "10.0.0.0/16"
#  description = "public subet2 cidr block"
#}

variable "private-subnet-1-cidr" {
  type        = string
  default     = "11.0.2.0/24"
  description = "private subnet 1 cidr block"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resource tagging"
  default = {
  }
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create in VPC"
}

variable "instance_type" {
  type        = string
  description = "Type for EC2 Instance"
}
