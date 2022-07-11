#vpc_cidr_block = "172.16.0.0/16"

#enable_dns_hostnames = true

tags = {
  owner   = "Kaustubh"
  purpose = "terraform_job"
  enddate = "09/07/2022"
}

instance_count = "2"

instance_type = "t2.micro"