variable "scaleway_token" {}
variable "scaleway_region" {}
variable "bastion_ssh_port" {}
variable "bastion_image" {}
variable "bastion_server_type" {}
variable "cluster_server_type"{}
variable "ssh_port" {}
variable "ssh_user" {}
variable "reboot_delay" {
  type = "string"
  default = "150"
}
variable "manager_private_ip" {
  type = "string"
}

resource "scaleway_server" "node" {
  count = 1
  name = "bastion-${count.index + 1}"
  image = "${var.bastion_image}"
  type = "${var.bastion_server_type}"
  dynamic_ip_required = "true"
  security_group="${scaleway_security_group.bastion.id}"
  #install ansible
 provisioner "remote-exec" {
      inline = [
        "mkdir -p /etc/docker/roles",
        "mkdir -p /opt/ansible"]
  }

 provisioner "file" {
    source = "~/.ssh/id_rsa.pub"
    destination = "/opt/ansible/id_rsa.pub"
  }

 provisioner "file" {
    source = "roles/"
    destination = "/etc/docker/roles"
  }


 provisioner "file" {
     source = "bastion/scripts/bastion.yml"
     destination = "/etc/docker/bastion.yml"
 }
 provisioner "file" {
     source = "bastion/scripts/keyscan.sh"
     destination = "/etc/docker/keyscan.sh"
 }
 provisioner "file" {
     source = "bastion/scripts/tokens.sh"
     destination = "/etc/docker/tokens.sh"
 }

 provisioner "file" {
    source = "${path.root}/node.yml"
    destination = "/etc/docker/node.yml"
 }


 provisioner "remote-exec" {
    inline = [
      "sudo chmod -R 777 /etc/docker",
      "ansible-playbook -e \"node_path=/etc/docker/node.yml\" -e \"ssh_port=${var.ssh_port}\"  -e \"ssh_permit_tunnel=true\"  -e \"ssh_user=${var.ssh_user}\"  /etc/docker/bastion.yml"
    ]
 }


  #remove old host key
  provisioner "local-exec" {
    command="ssh-keygen -f \"$${HOME}/.ssh/known_hosts\" -R [${self.public_ip}]:${var.ssh_port}"
  }

  #add new host key with private ip
  # provisioner "remote-exec" {
  #   inline=["${path.module}/scripts/keyscan.sh ${var.manager_private_ip} ${var.ssh_port}>> $${HOME}/.ssh/known_hosts"]
  # }

  #add new host key with public ip
  provisioner "local-exec" {
    command="${path.module}/scripts/keyscan.sh ${self.public_ip} ${var.ssh_port}>> $${HOME}/.ssh/known_hosts"
  }

  provisioner "local-exec" {
     command = "${path.module}/scripts/tokens.sh ${var.manager_private_ip} ${var.ssh_user} ${var.ssh_port} ${self.public_ip} worker"
  }
  provisioner "local-exec" {
     command = "${path.module}/scripts/tokens.sh ${var.manager_private_ip} ${var.ssh_user} ${var.ssh_port} ${self.public_ip} manager"
  }

  #hard reboot to complete network security rules
  provisioner "local-exec" {
    command = "curl -H 'X-Auth-Token: ${var.scaleway_token}' -H 'Content-Type: application/json' -X POST -d '{\"action\":\"reboot\"}' https://cp-${var.scaleway_region}.scaleway.com/servers/${self.id}/action"
  }


}


output "private_ip" {
  value = "${scaleway_server.node.0.private_ip}"
}

output "public_ip" {
  value = "${scaleway_server.node.0.public_ip}"
}
