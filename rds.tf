

#This tells your datavase which subnet it should stay. it is used incase you need when youre restoring your rds to an entirely different vpc and subnet
resource "aws_db_subnet_group" "db_subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "DB Subnet Group"
  }
}



resource "aws_db_instance" "restored_instance" {
  identifier              = "my-restored-db-instance"
  snapshot_identifier     = data.aws_db_snapshot.latest_db_snapshot.id
  instance_class          = "db.t4g.micro"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.RDS-sg.id]
  skip_final_snapshot     = true # Set to true to avoid creating an extra snapshot on destroy
  publicly_accessible     = false
}
