locals {
  # Render's internal connection string is postgres://user:password@host/database.
  # Extract host/database for JDBC; credentials are passed separately.
  pg_parts = regex("^postgres(ql)?://([^:]+):([^@]+)@([^/]+)/([^?]+)", render_postgres.library.connection_info.internal_connection_string)
  eureka_url = "${trimsuffix(render_web_service.eureka.url, "/")}/eureka/"
}

resource "render_postgres" "library" {
  name          = "skill-11-library-db"
  plan          = var.postgres_plan
  region        = var.region
  version       = "16"
  database_name = "librarydb"
  database_user = "libraryuser"
}

resource "render_web_service" "eureka" {
  name   = "skill-11-library-eureka"
  plan   = var.web_plan
  region = var.region
  health_check_path = "/actuator/health"
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.git_branch
      context         = "./library-eureka-server"
      dockerfile_path = "./library-eureka-server/Dockerfile"
      auto_deploy     = true
    }
  }
  env_vars = {
    SERVER_PORT = { value = "10000" }
  }
}

resource "render_web_service" "auth" {
  name   = "skill-11-library-auth"
  plan   = var.web_plan
  region = var.region
  health_check_path = "/actuator/health"
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.git_branch
      context         = "./library-auth-service"
      dockerfile_path = "./library-auth-service/Dockerfile"
      auto_deploy     = true
    }
  }
  env_vars = {
    SERVER_PORT = { value = "10000" }
    EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = { value = local.eureka_url }
    JWT_SECRET = { value = var.jwt_secret }
  }
  depends_on = [render_web_service.eureka]
}

resource "render_web_service" "book1" {
  name   = "skill-11-library-book-1"
  plan   = var.web_plan
  region = var.region
  health_check_path = "/actuator/health"
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.git_branch
      context         = "./library-book-service"
      dockerfile_path = "./library-book-service/Dockerfile"
      auto_deploy     = true
    }
  }
  env_vars = {
    SERVER_PORT = { value = "10000" }
    EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = { value = local.eureka_url }
    EUREKA_INSTANCE_INSTANCE_ID = { value = "book-service-render-1" }
    SPRING_DATASOURCE_URL = { value = "jdbc:postgresql://${local.pg_parts[3]}/${local.pg_parts[4]}" }
    SPRING_DATASOURCE_USERNAME = { value = "libraryuser" }
    SPRING_DATASOURCE_PASSWORD = { value = render_postgres.library.connection_info.password }
    JWT_SECRET = { value = var.jwt_secret }
  }
  depends_on = [render_postgres.library, render_web_service.eureka]
}

resource "render_web_service" "book2" {
  name   = "skill-11-library-book-2"
  plan   = var.web_plan
  region = var.region
  health_check_path = "/actuator/health"
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.git_branch
      context         = "./library-book-service"
      dockerfile_path = "./library-book-service/Dockerfile"
      auto_deploy     = true
    }
  }
  env_vars = {
    SERVER_PORT = { value = "10000" }
    EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = { value = local.eureka_url }
    EUREKA_INSTANCE_INSTANCE_ID = { value = "book-service-render-2" }
    SPRING_DATASOURCE_URL = { value = "jdbc:postgresql://${local.pg_parts[3]}/${local.pg_parts[4]}" }
    SPRING_DATASOURCE_USERNAME = { value = "libraryuser" }
    SPRING_DATASOURCE_PASSWORD = { value = render_postgres.library.connection_info.password }
    JWT_SECRET = { value = var.jwt_secret }
  }
  depends_on = [render_postgres.library, render_web_service.eureka]
}

resource "render_web_service" "gateway" {
  name   = "skill-11-library-gateway"
  plan   = var.web_plan
  region = var.region
  health_check_path = "/actuator/health"
  runtime_source = {
    docker = {
      repo_url        = var.repo_url
      branch          = var.git_branch
      context         = "./library-api-gateway"
      dockerfile_path = "./library-api-gateway/Dockerfile"
      auto_deploy     = true
    }
  }
  env_vars = {
    SERVER_PORT = { value = "10000" }
    EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = { value = local.eureka_url }
  }
  depends_on = [render_web_service.auth, render_web_service.book1, render_web_service.book2]
}
