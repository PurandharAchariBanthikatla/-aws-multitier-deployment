output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public (web) subnet"
  value       = aws_subnet.public.id
}

output "private_app_subnet_id" {
  description = "ID of the private app subnet"
  value       = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  description = "ID of the first private db subnet"
  value       = aws_subnet.private_db.id
}

output "private_db_subnet_id_2" {
  description = "ID of the second private db subnet"
  value       = aws_subnet.private_db_2.id
}
