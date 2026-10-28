output "api_gateway_url" {
  description = "Public URL for login and book CRUD requests."
  value       = render_web_service.gateway.url
}

output "eureka_dashboard_url" {
  description = "Public Eureka dashboard URL; restrict access before production use."
  value       = render_web_service.eureka.url
}

output "postgres_internal_connection_string" {
  description = "Sensitive internal PostgreSQL connection string. Do not share publicly."
  value       = render_postgres.library.connection_info.internal_connection_string
  sensitive   = true
}
