# variable "agent_secret" {
#   description = "Jenkins agent secret"
#   type = string
# }

variable "app_name" {
  default = "jenkins"
}

variable "env_name" {
  default = "dev"
}

variable "base_domain_url" {
  default = "pedscommons.org"
}