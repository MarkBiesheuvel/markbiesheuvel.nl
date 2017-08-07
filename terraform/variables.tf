variable "url" {
  type = "string"
}

variable "aliases" {
  type = "list"
}

variable "domains" {
  type = "list"
}

variable "mx_records" {
  type    = "list"
  default = []
}

variable "keybase_verification" {
  type    = "map"
  default = {}
}

variable "google_verification" {
  type    = "map"
  default = {}
}
