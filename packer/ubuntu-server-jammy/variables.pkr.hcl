# Variable Definitions
variable "sudo_password" {
  type =  string
  default = "mypassword"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "proxmox_api_url" {
    type = string
    default = "http://localhost:8006/api2/json"
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "ssh_username" {
  type      = string
  default = "air"
}

variable "ssh_password" {
  type      = string
  default = "password"
}

variable "cores" {
  type      = string
  default = "2"
} 

  # Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "ssh_username" {
  type      = string
  default = "air"
}

variable "ssh_password" {
  type      = string
  default = "password"
}

# disk_size = "20G"
# format = "raw"
# storage_pool = "local-lvm"
# cores = "2"
# memory = "8192"
