provider "aws" {
  region     = "${var.aws_region}"
  shared_credentials_file = "${var.aws_credentials_file}"
}

data "template_file" "userdata" {
  template = "${file("userdata.template")}"

  vars {
    rancher_registration_command  = "${var.rancher_registration_command}"
    docker_version    = "1.12.6"
    ssh_pub_key       = "${var.ssh_public_key}"
  }
}

resource "aws_launch_configuration" "autospot-asg-rancheros" {
  image_id      = "ami-7bba5a03"
  instance_type = "t2.micro"
  key_name      = "william"
  security_groups = ["sg-48efe630"]
  user_data     = "${data.template_file.userdata.rendered}"
}


resource "aws_autoscaling_group" "autospot-asg" {
  lifecycle { create_before_destroy = true }
  depends_on = ["aws_launch_configuration.autospot-asg-rancheros"]
  availability_zones        = ["us-west-2a"]
  name                      = "autospot-${aws_launch_configuration.autospot-asg-rancheros.name}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.autospot-asg-rancheros.name}"
  vpc_zone_identifier       = "${var.vpc_subnets}"

  tag {
  key                 = "Name"
  value               = "autospot-nodes-${aws_launch_configuration.autospot-asg-rancheros.name}"
  propagate_at_launch = true
  }
}
