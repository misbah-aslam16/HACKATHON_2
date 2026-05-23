# Terraform Configuration for Google Cloud Run Deployment
# Deploy Todo App to Google Cloud Run with Infrastructure as Code

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # Uncomment to use remote state
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "todo-app"
  # }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  
  service            = each.value
  disable_on_destroy = false
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "todo_app" {
  location      = var.gcp_region
  repository_id = var.artifact_registry_repo
  description   = "Docker repository for Todo App"
  format        = "DOCKER"
  
  depends_on = [google_project_service.required_apis]
}

# Service Account for Cloud Run
resource "google_service_account" "cloud_run" {
  account_id   = "todo-app-cloud-run"
  display_name = "Todo App Cloud Run Service Account"
}

# IAM Role for Cloud Run to access Artifact Registry
resource "google_project_iam_member" "cloud_run_artifact_registry" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Backend Cloud Run Service
resource "google_cloud_run_service" "backend" {
  name     = var.backend_service_name
  location = var.gcp_region
  
  template {
    spec {
      service_account_name = google_service_account.cloud_run.email
      
      containers {
        image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.artifact_registry_repo}/backend:latest"
        
        ports {
          container_port = 8080
        }
        
        resources {
          limits = {
            memory = var.backend_memory
            cpu    = var.backend_cpu
          }
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "PYTHONDONTWRITEBYTECODE"
          value = "1"
        }
        
        env {
          name  = "PYTHONUNBUFFERED"
          value = "1"
        }
        
        env {
          name  = "DATABASE_URL"
          value = var.database_url
        }
        
        env {
          name  = "DATABASE_URL_UNPOOLED"
          value = var.database_url_unpooled
        }
        
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 20
          timeout_seconds       = 10
          period_seconds        = 30
          failure_threshold     = 3
        }
      }
      
      timeout_seconds       = 3600
      max_instances         = var.max_instances
      service_account_name  = google_service_account.cloud_run.email
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = var.max_instances
        "autoscaling.knative.dev/minScale" = "0"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  depends_on = [google_project_service.required_apis]
}

# Backend Cloud Run IAM - Allow unauthenticated access
resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = google_cloud_run_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Frontend Cloud Run Service
resource "google_cloud_run_service" "frontend" {
  name     = var.frontend_service_name
  location = var.gcp_region
  
  template {
    spec {
      service_account_name = google_service_account.cloud_run.email
      
      containers {
        image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.artifact_registry_repo}/frontend:latest"
        
        ports {
          container_port = 3000
        }
        
        resources {
          limits = {
            memory = var.frontend_memory
            cpu    = var.frontend_cpu
          }
        }
        
        env {
          name  = "PORT"
          value = "3000"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        
        env {
          name  = "NEXT_TELEMETRY_DISABLED"
          value = "1"
        }
        
        env {
          name  = "NEXT_PUBLIC_BACKEND_URL"
          value = google_cloud_run_service.backend.status[0].url
        }
        
        env {
          name  = "DATABASE_URL"
          value = var.database_url
        }
        
        env {
          name  = "DATABASE_URL_UNPOOLED"
          value = var.database_url_unpooled
        }
        
        env {
          name  = "AUTH_SECRET"
          value = var.auth_secret
        }
        
        env {
          name  = "BETTER_AUTH_SECRET"
          value = var.better_auth_secret
        }
        
        liveness_probe {
          http_get {
            path = "/"
            port = 3000
          }
          initial_delay_seconds = 30
          timeout_seconds       = 10
          period_seconds        = 30
          failure_threshold     = 3
        }
      }
      
      timeout_seconds       = 3600
      max_instances         = var.max_instances
      service_account_name  = google_service_account.cloud_run.email
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = var.max_instances
        "autoscaling.knative.dev/minScale" = "0"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_service.backend
  ]
}

# Frontend Cloud Run IAM - Allow unauthenticated access
resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Outputs
output "backend_url" {
  description = "Backend Cloud Run service URL"
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_url" {
  description = "Frontend Cloud Run service URL"
  value       = google_cloud_run_service.frontend.status[0].url
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.todo_app.repository_id}"
}
