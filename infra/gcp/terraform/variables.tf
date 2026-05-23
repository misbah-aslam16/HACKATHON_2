# Terraform Variables for Cloud Run Deployment

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "todo-app"
}

variable "backend_service_name" {
  description = "Backend Cloud Run service name"
  type        = string
  default     = "todo-backend"
}

variable "frontend_service_name" {
  description = "Frontend Cloud Run service name"
  type        = string
  default     = "todo-frontend"
}

variable "backend_memory" {
  description = "Backend service memory allocation"
  type        = string
  default     = "512Mi"
}

variable "backend_cpu" {
  description = "Backend service CPU allocation"
  type        = string
  default     = "1"
}

variable "frontend_memory" {
  description = "Frontend service memory allocation"
  type        = string
  default     = "512Mi"
}

variable "frontend_cpu" {
  description = "Frontend service CPU allocation"
  type        = string
  default     = "1"
}

variable "max_instances" {
  description = "Maximum number of instances for auto-scaling"
  type        = number
  default     = 10
}

variable "database_url" {
  description = "Neon database pooled connection string"
  type        = string
  sensitive   = true
}

variable "database_url_unpooled" {
  description = "Neon database unpooled connection string"
  type        = string
  sensitive   = true
}

variable "auth_secret" {
  description = "Authentication secret"
  type        = string
  sensitive   = true
}

variable "better_auth_secret" {
  description = "Better Auth secret"
  type        = string
  sensitive   = true
}
