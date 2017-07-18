output "frontend_eip" {
        value = "${join(", ", aws_instance.frontend.*.public_ip)}"
}

output "backend_eip" {
        value = "${join(", ", aws_instance.backend.*.public_ip)}"
}

output "database_eip" {
        value = "${join(", ", aws_instance.database.*.public_ip)}"
}
