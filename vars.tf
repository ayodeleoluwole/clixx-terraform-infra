variable "AWS_ACCESS_KEY" {} 
 
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "us-east-2"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "test_instances_kp.pub"
}


variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0a37b9296fbe95a93"  #This is Amazon linux 2 ami
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}



variable "instance_type" {
  default="t3.micro"
}



variable "ami" {
  default="ami-0b671272c81662a99"
}
