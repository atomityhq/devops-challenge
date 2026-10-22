output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the internet-reachable subnet."
  # Depend on the association so nothing launches into the subnet before
  # it is actually routable.
  value      = aws_route_table_association.public.subnet_id
  depends_on = [aws_route.internet]
}
