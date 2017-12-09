variable "image"{}
variable "my_scaleway_type" {}
variable "ssh_port" {}
variable "ssh_user" {}
variable "count" {
  type    = "string"
  default = "1"
}
variable "docker_cluster_script" {}
variable "docker_role" {}
variable "scaleway_token" {}
variable "scaleway_region" {
    type    = "string"
}
variable "ufw_pause" {
  type    = "string"
  default = "2"
}

variable "reboot_delay" {
    type = "string"
    default = "150"
}
variable "dependencies" {
    type = "list"
    default = [""]
}

variable "manager_ip_to_join" {
  type = "string"
  default = ""
}
resource "scaleway_server" "node" {
  count = "${var.count}"
  name = "swarm-${var.docker_role}-${count.index + 1}"
  image = "${var.image}"
  type = "${var.my_scaleway_type}"
  dynamic_ip_required = "true"
  security_group="${scaleway_security_group.internal.id}"

  provisioner "local-exec" {
    command = "echo ${var.dependencies[0]}"
  }

  provisioner "remote-exec" {
      inline = [
        "mkdir -p /etc/systemd/system/docker.d",
        "mkdir -p /etc/docker",
        "mkdir -p /opt/ansible",
        "echo ${var.dependencies[0]}"
      ]
  }

  provisioner "file" {
    source = "${path.module}/scripts/daemon.json"
    destination = "/etc/docker/daemon.json"
  }
  provisioner "file" {
    source = "${path.module}/scripts/server.yml"
    destination = "/etc/docker/server.yml"
  }
  provisioner "file" {
    source = "${path.module}/scripts/init_manager.sh"
    destination = "/etc/docker/init_manager.sh"
  }
  provisioner "file" {
    source = "${path.module}/scripts/join_manager.sh"
    destination = "/etc/docker/join_manager.sh"
  }
  provisioner "file" {
    source = "${path.module}/scripts/join_worker.sh"
    destination = "/etc/docker/join_worker.sh"
  }
  provisioner "local-exec" {
    command = "touch ${path.root}/tokens/${var.docker_role}_token.txt"
  }

  provisioner "local-exec" {
    command = "touch debug.txt && mkdir -p tokens && touch tokens/${var.docker_role}_token.txt && echo \"name: swarm-${var.docker_role}-${count.index + 1} timestamp:${timestamp()} token: ${file("${path.root}/tokens/${var.docker_role}_token.txt")}\">>debug.txt"
  }
  provisioner "file" {
    source = "${path.root}/tokens/${var.docker_role}_token.txt"
    destination = "/etc/docker/${var.docker_role}_token.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"token -+-$(cat /etc/docker/${var.docker_role}_token.txt)-+-\"",
      "sudo chmod 777 -R /etc/docker",
      "systemctl daemon-reload",
      "systemctl restart docker"
       ]
  }



  #install ansible
  provisioner "remote-exec" {
      inline = [
        "mkdir -p /etc/docker/roles"]
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
    source = "${path.root}/node.yml"
    destination = "/etc/docker/node.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -e \"node_path=/etc/docker/node.yml\" -e \"ufw_pause=${var.ufw_pause}\" -e \"ssh_port=${var.ssh_port}\"  -e \"ssh_permit_tunnel=false\"  -e \"ssh_user=${var.ssh_user}\"  /etc/docker/server.yml",
      "echo ${var.docker_cluster_script} ${var.docker_role == "first_manager"? scaleway_server.node.0.private_ip:var.manager_ip_to_join} ${file("${path.root}/tokens/${var.docker_role}_token.txt")}",
      "eval ${var.docker_cluster_script} ${var.docker_role == "first_manager"? scaleway_server.node.0.private_ip:var.manager_ip_to_join} ${file("${path.root}/tokens/${var.docker_role}_token.txt")}"

    ]
  }
  #hard reboot to complete network security rules
  provisioner "local-exec" {
    command = "curl -H 'X-Auth-Token: ${var.scaleway_token}' -H 'Content-Type: application/json' -X POST -d '{\"action\":\"reboot\"}' https://cp-${var.scaleway_region}.scaleway.com/servers/${self.id}/action"
  }

  #remove old host key
  provisioner "local-exec" {
    command="ssh-keygen -f \"$${HOME}/.ssh/known_hosts\" -R [${scaleway_server.node.0.private_ip}]:${var.ssh_port}"
  }


}

output "first_node_private_ip" {
  value = "${scaleway_server.node.0.private_ip}"
}

output "first_node_public_ip" {
  value = "${scaleway_server.node.0.public_ip}"
}


output "first_node_id" {
  value = "${scaleway_server.node.0.id}"
}
