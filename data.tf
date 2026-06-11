
data "template_file" "bootstrap" {
    template = file(format("%s/scripts/clixx_bootstrap.tpl", path.module))

    vars = {
        MOUNT_POINT    = "/var/www/html"
        FILE_SYSTEM_ID = aws_efs_file_system.efs.id
        REGION         = var.AWS_REGION
        RDSHost        = local.clixx_creds.RDSHost
        DBName         = local.clixx_creds.DBName
        DBUser         = local.clixx_creds.DBUser
        DBPassword     = local.clixx_creds.DBPassword        
        
    }
}


#Data source for secrets
data "aws_secretsmanager_secret_version" "clixx-credentials"{
    #fill in the name you gave to your secrets
    secret_id = "clixx-credentials"
}

# Data source for database snapshot recovery
data "aws_db_snapshot" "latest_db_snapshot" {
    db_snapshot_identifier = "clixx-retaildb" # Replace with your db identifier or use filtering
    most_recent = true
}



# Declare the data source for availablity zone
data "aws_availability_zones" "available" {
  state = "available"
}


locals{
  server_name=""
  server_prefix="stack"
  clixx_creds = jsondecode(
    data.aws_secretsmanager_secret_version.clixx-credentials.secret_string
  )
}