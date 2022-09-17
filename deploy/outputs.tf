#output "instance_id" {
#  description = "ID of the EC2 instance"
#  value       = aws_instance.app_server.id
#}
#
output "url_stage_api" {
  description = "URL api rest"
  value       = "${aws_api_gateway_stage.example.invoke_url}/dragons"
}
