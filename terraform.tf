provider "scaleway" {
  organization = "${var.scaleway_organization}"
  token = "${var.scaleway_token}"
  region = "${var.scaleway_region}"
}


provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

#bastion part
module "bastion" {
  source="./bastion"
  scaleway_token="${var.scaleway_token}"
  scaleway_region="${var.scaleway_region}"
  bastion_ssh_port = "${var.ssh_port}"
  bastion_image = "${var.ubuntu_x86_64_image}"
  bastion_server_type = "${var.scaleway_type}"
  cluster_server_type = "node"
  ssh_user="${var.ssh_user}"
  ssh_port="${var.ssh_port}"
  manager_private_ip="${module.first_docker_manager.first_node_private_ip}"
}

#Add a record to the domain for the bastion public ip
resource "cloudflare_record" "bastion" {
  domain = "${var.cloudflare_domain}"
  name = "b"
  value = "${module.bastion.public_ip}"
  type = "A"
  ttl = 3600
}


#initialize docker swarm mode cluster with managers
module "first_docker_manager" {
  source = "./server"
  scaleway_token="${var.scaleway_token}"
  scaleway_region="${var.scaleway_region}"
  image="${var.ubuntu_x86_64_image}"
  my_scaleway_type="${var.scaleway_type}"
  ssh_user="${var.ssh_user}"
  ssh_port="${var.ssh_port}"
  count=1
  docker_role="first_manager"
  docker_cluster_script="/etc/docker/init_manager.sh"
}


resource "scaleway_ip" "external_ip" {
  server = "${module.first_docker_manager.first_node_id}"
}


#Add a record to the domain
resource "cloudflare_record" "star" {
  domain = "${var.cloudflare_domain}"
  name = "*"
  value = "${scaleway_ip.external_ip.ip}"
  type = "A"
  ttl = 3600
}



# Add a record to the domain for the first manager private ip
resource "cloudflare_record" "first_manager" {
  domain = "${var.cloudflare_domain}"
  name = "m"
  value = "${module.first_docker_manager.first_node_private_ip}"
  type = "A"
  ttl = 3600
}




#other managers for docker swarm mode cluster
module "other_docker_managers" {
  source = "./server"
  scaleway_token="${var.scaleway_token}"
  scaleway_region="${var.scaleway_region}"
  image="${var.ubuntu_x86_64_image}"
  my_scaleway_type="${var.scaleway_type}"
  ssh_user="${var.ssh_user}"
  ssh_port="${var.ssh_port}"
  count=0
  docker_role="manager"
  docker_cluster_script="/etc/docker/join_manager.sh"
  dependencies = ["${module.bastion.public_ip}"]
  manager_ip_to_join="${module.first_docker_manager.first_node_private_ip}"
}


#other workers for docker swarm mode cluster
module "docker_workers" {
  source = "./server"
  scaleway_token="${var.scaleway_token}"
  scaleway_region="${var.scaleway_region}"
  image="${var.ubuntu_x86_64_image}"
  my_scaleway_type="${var.scaleway_type}"
  ssh_user="${var.ssh_user}"
  ssh_port="${var.ssh_port}"
  count=0
  docker_role="worker"
  docker_cluster_script="/etc/docker/join_worker.sh"
  dependencies = ["${module.bastion.public_ip}"]
  manager_ip_to_join="${module.first_docker_manager.first_node_private_ip}"
}
