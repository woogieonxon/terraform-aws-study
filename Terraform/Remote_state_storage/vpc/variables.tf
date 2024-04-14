variable "webserver_port" {
  description = "Webserver's HTTP port"
  type = number
  default = 80
}

variable "my_ip" {
  description = "My public IP"
  type = string
  default = "218.38.20.159/32"
}

variable "alb_security_group_name" {
  description = "The name of the ALB's security group"
  type = string
  default = "webserver-alb-sg"
}

variable "alb_name" {
  description = "The name of the ALB"
  type = string
  default = "webserver-alb"
}