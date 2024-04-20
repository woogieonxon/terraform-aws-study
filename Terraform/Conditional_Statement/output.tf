output "instance_ids" {
  value = aws_instance.ec2_is_type[*].id
}

output "instance_types" {
  value = aws_instance.ec2_is_type[*].instance_type
}
