output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "instance_id" {
  description = "EC2 web server instance identifier."
  value       = aws_instance.web.id
}

output "web_url" {
  description = "Public HTTP URL of the EC2 demo server."
  value       = "http://${aws_instance.web.public_ip}"
}

output "artifact_bucket" {
  description = "Versioned and encrypted S3 artifact bucket."
  value       = aws_s3_bucket.artifacts.bucket
}
