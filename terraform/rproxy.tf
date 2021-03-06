resource "aws_instance" "rproxy" {
  ami = "${data.aws_ami.ubuntu-xenial.id}"
  instance_type = "t2.micro"
  disable_api_termination = true
  subnet_id = "${aws_subnet.main_public.id}"
  associate_public_ip_address = true

  lifecycle = {
    ignore_changes = [
      "ami",
      "user_data"
    ]
  }

  vpc_security_group_ids = [
    "${aws_security_group.rproxy.id}",
    "${aws_security_group.ssh_via_bastion.id}"
  ]

  user_data = "${data.template_file.user_data.rendered}"

  tags {
    Name = "rproxy-001"
  }
}

resource "aws_route53_record" "rproxy_internal" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name = "rproxy"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.rproxy.private_ip}"]
}

resource "aws_security_group" "rproxy" {
  name = "rproxy"
  description = "Security group for rproxy instance"

  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [
      "${aws_security_group.elb_rproxy.id}"
    ]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rproxy"
  }
}
