# variable "vpc_cidr" {
#     type = string
#     default = "172.20.0.0/16"  
# }

# variable "subnet_cidr" {
#   type = string
#   default = "172.20.18.0/24"
# }

variable "project-name" {
  type    = string
  default = "webserver-deployment"
}

variable "cidr" {
  type = map(string)
  default = {
    "vpc"    = "172.20.0.0/16"
    "subnet" = "172.20.18.0/24"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "pub-key-path" {
    type = string
    default = "./key.pub"
}
variable "aws-shared-creds" {
  type = string
  default = "~/.aws/credentials"
}

variable "ami" {
  type = map
  default = {
  "us-east-1" = "ami-087c17d1fe0178315"
  }
}

variable "instance-type" {
    type = string
    default = "t2.micro"
}