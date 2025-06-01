/*
locals{
  server_name=""
  server_prefix="stack"
}

resource "aws_key_pair" "test-instance-kp" {
  key_name   = "test_instances_kp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "Test-Instance" {
  for_each                  = toset(data.aws_availability_zones.available.names)
  ami                       = var.ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.test-instance-sg.id]
  #subnet_id                 = var.subnets[0]
  availability_zone         = each.key
  user_data                 = data.template_file.bootstrap.rendered
  key_name                  = aws_key_pair.test-instance-kp.key_name

  root_block_device {
    volume_type             = "gp2"
    volume_size             = 20
    delete_on_termination   = true
    encrypted               = false
  }

  tags                      = {
    Name                      =  local.server_name != "" ? "${local.server_name}_${each.key}" : "${local.server_prefix}_${element(split("-", each.key),2)}"
    #Name                      = local.server_name != "" ? "${local.server_name}" : "${local.server_prefix}"
    #Name                      =    "${local.server_name!=""? local.server_name : "TestInstance_${each.key}"}" 
                              #Above is a condtional statment stating that if value of local.server_name is not empty("") (as contained in number 1 of this line of codes), then print the value of local.server_name
                              #Else if local.server_name is empty it should pick the value of TestInstance_${each.key} e.g server_name=TestInstance_${each.key}

    OwnerEmail                = "ayodeleoluwole112@gmail.com"
    StackTeam                 = "stackcloud9"
    Schedule                  = "A"
    Backup                    = "Yes"
  }

  }
*/

