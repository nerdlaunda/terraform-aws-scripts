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
  type    = string
  default = "./key.pub"
}
variable "aws-shared-creds" {
  type    = string
  default = "~/.aws/credentials"
}

variable "ami" {
  type = map(any)
  default = {
    "us-east-1"      = "ami-087c17d1fe0178315"
    "us-east-2"      = "ami-0b59bfac6be064b78"
    "us-west-1"      = "ami-0bdb828fd58c52235"
    "us-west-2"      = "ami-a0cfeed8"
    "ap-northeast-1" = "ami-0a4eaf6c4454eda75"
    "ap-south-1"     = "ami-0912f71e06545ad88"
    "ap-southeast-1" = "ami-08569b978cc4dfa10"
    "ap-southeast-2" = "ami-09b42976632b27e9b"
  }
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}