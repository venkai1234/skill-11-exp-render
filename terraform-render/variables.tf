variable "repo_url" {
  description = "HTTPS URL of the GitHub repository containing the skill-11-exp project root."
  type        = string
}

variable "git_branch" {
  description = "Git branch to deploy."
  type        = string
  default     = "main"
}

variable "region" {
  description = "Render region. Keep all services and the database in the same region."
  type        = string
  default     = "singapore"
  validation {
    condition     = contains(["frankfurt", "ohio", "oregon", "singapore", "virginia"], var.region)
    error_message = "Choose a supported Render region: frankfurt, ohio, oregon, singapore, or virginia."
  }
}

variable "web_plan" {
  description = "Render web-service plan. Starter is paid; check Render pricing before applying."
  type        = string
  default     = "starter"
}

variable "postgres_plan" {
  description = "Render PostgreSQL plan. Free databases expire after 30 days; change to a paid plan for persistence."
  type        = string
  default     = "free"
}

variable "jwt_secret" {
  description = "Strong random secret shared by auth and book services. Supply via TF_VAR_jwt_secret, never commit it."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must contain at least 32 characters."
  }
}
