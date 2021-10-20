output "subnet_private_ids" {
  value = [for k,v in aws_subnet.private: v.id]
}

output "subnet_public_ids" {
  value = [for k,v in aws_subnet.public: v.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}