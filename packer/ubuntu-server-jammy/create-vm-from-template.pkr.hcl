# Ubuntu Server jammy
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type    = string
  default = "http://localhost:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_username" {
  type    = string
  default = "air"
}

variable "ssh_password" {
  type    = string
  default = "password"
}

variable "node_type" {
  type    = string
  default = "2"
}
variable "cores" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_format" {
  type    = string
  default = "raw"
}
variable "disk_type" {
  type    = string
  default = "scsi"
}

variable "storage_pool" {
  type    = string
  default = "local"
}

variable "memory" {
  type    = string
  default = "4G"
}

variable "node" {
  type    = string
  default = "pve1"
}

variable "vm_name" {
  type    = string
  default = "1000"
}

variable "clone_vm_id" {
  type    = string
  default = "1000"
}

variable "vm_id" {
  type      = string
  default = "1000"
}
source "proxmox-clone" "vm" {

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true
  # VM General Settings
  node                 = "${var.node}"  #"pve1"
  vm_id                = "${var.vm_id}" #"199"
  vm_name              = "ubuntu-server-jammy"
  template_name        = "tmpl-ubuntu-22.4"
  template_description = "Ubuntu Server jammy Image"
  #   proxmox_url      = var.proxmox_url
  #   username         = var.proxmox_username
  #   password         = var.proxmox_password
  #   node             = var.proxmox_node
  #   vm_template      = var.proxmox_template
  #   storage_pool     = var.proxmox_storage_pool
  #   vm_id            = "100"
  #   vm_name          = "packer-clone-vm"
  #   disk_size        = "10G"
  full_clone  = true
  clone_vm_id = "${var.clone_vm_id}"

# PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    # http_bind_address = "0.0.0.0"
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username  = "${var.ssh_username}"
    ssh_password  = "${var.ssh_password}"
    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "${var.disk_size}"# "20G"
        format = "${var.disk_format}"#"raw"
        storage_pool = "${var.storage_pool}"#"local-lvm"
       # storage_pool_type = "lvm"
        type = "${var.disk_type}"# "scsi"
    }

    # VM CPU Settings
    cores = "${var.cores}"# "2"
    
    # VM Memory Settings
    memory = "${var.memory}"# "8192"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "sandbox"
        firewall = true
    } 
  #   ipconfigs = [
  #     {
  #       model     = "virtio"
  #       bridge    = "sandbox"
  #       ipconfig0 = "dhcp"
  #     }
  #   ]
}

build {
  sources = ["source.proxmox-clone.vm"]

  provisioner "shell" {
    inline = ["echo 'Provisioning...'", "sleep 30"]
  }
}
