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

variable "node_type" {
  type      = string
  default = "2"
}
variable "cores" {
  type      = string
  default = "2"
} 

variable "disk_size" {
  type      = string
  default = "20G"
} 

variable "disk_format" {
  type      = string
  default = "raw"
}
variable "disk_type" {
  type      = string
  default = "scsi"
} 

variable "storage_pool" {
  type      = string
  default = "local"
} 

variable "memory" {
  type      = string
  default = "4G"
} 

variable "node" {
  type      = string
  default = "pve1"
}

variable "vm_id" {
  type      = string
  default = "1000"
}
# Resource Definition for the VM Template
source "proxmox-iso" "ubuntu-server-jammy" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.node}"#"pve1"
    vm_id = "${var.vm_id}"#"199"
    vm_name = "ubuntu-server-jammy"
    template_name = "tmpl-ubuntu-22.4"
    template_description = "Ubuntu Server jammy Image"

    # VM OS Settings
    # (Option 1) Local ISO File
    # iso_file = "local:iso/ubuntu-22.04-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    # iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"
    # iso_checksum = "84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
    iso_file = "local:iso/ubuntu-22.04.4-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true

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
        bridge = "vmbr0"
        firewall = true
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.storage_pool}"# "local-lvm"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    # http_bind_address = "0.0.0.0"
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username  = "${var.ssh_username}"
    ssh_password  = "${var.ssh_password}"
   # ssh_private_key_file = "~/.ssh/air-mobile"
    # (Option 1) Add your Password here
    # ssh_password = "your-password"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    # ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy"
    sources = ["proxmox-iso.ubuntu-server-jammy"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ 
          "sudo systemd-analyze dump | grep qemu",
          "sudo systemctl start qemu-guest-agent",
          "sudo systemctl enable qemu-guest-agent"
         ]
    }

}