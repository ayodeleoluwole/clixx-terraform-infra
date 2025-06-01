# Create the EFS File System
resource "aws_efs_file_system" "efs" {
  creation_token   = "my-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  tags = {
    Name        = "MyEFS"
    OwnerEmail  = "ayodeleoluwole112@gmail.com"
    StackTeam   = "stackcloud9"
    Schedule    = "A"
    Backup      = "Yes"
  }
}

# Create Mount Targets for the EFS in each available subnets
resource "aws_efs_mount_target" "mount" {
  count           = length(aws_subnet.private)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.EFS-sg.id]
}

