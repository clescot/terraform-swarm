
resource "scaleway_security_group" "bastion" {
  name = "bastion_network"
  description = "security group to configure access to bastion"
}


#If you are planning on creating an overlay network with encryption (--opt encrypted),
#you will also need to ensure protocol 50 (ESP) is open.
resource "scaleway_security_group_rule" "bastion_in_accept_ssh" {
  security_group = "${scaleway_security_group.bastion.id}"
  action = "accept"
  direction = "inbound"
  protocol = "TCP"
  # ip_range = "10.0.0.0/8"
  ip_range = "0.0.0.0/0"
  port = "${var.ssh_port}"
}

# resource "scaleway_security_group_rule" "cluster_internal_in_accept_from_cluster" {
#   security_group = "${scaleway_security_group.internal.id}"
#   action = "accept"
#   direction = "inbound"
#   protocol = "TCP"
#   # ip_range = "10.0.0.0/8"
#   ip_range = "10.0.0.0/8"
#   port = "${var.ssh_port}"
# }

resource "scaleway_security_group_rule" "bastion_in_drop_udp" {
  security_group = "${scaleway_security_group.bastion.id}"
  action = "drop"
  direction = "inbound"
  protocol = "UDP"
  ip_range = "0.0.0.0/0"
}

resource "scaleway_security_group_rule" "bastion_in_drop_icmp" {
  security_group = "${scaleway_security_group.bastion.id}"
  action = "drop"
  direction = "inbound"
  protocol = "ICMP"
  ip_range = "0.0.0.0/0"
}
