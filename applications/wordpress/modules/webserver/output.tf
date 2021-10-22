output "sg_rds"{
    value= aws_security_group.allow_http_out
}

output "security_group_id"{
    description = "SG to be used for reaching Internet/RDS"
    value = aws_security_group.allow_http_out.id
}