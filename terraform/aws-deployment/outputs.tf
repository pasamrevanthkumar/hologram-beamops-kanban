output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.beamops.id
}

output "public_ip" {
  description = "Public IPv4 address"
  value       = aws_instance.beamops.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.beamops.public_dns
}

output "availability_zone" {
  description = "Instance availability zone"
  value       = aws_instance.beamops.availability_zone
}
