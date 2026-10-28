SKILL-11-EXP: RENDER + TERRAFORM DEPLOYMENT

IMPORTANT
- This configuration uses paid Render web services (default plan: starter) because this Eureka-based multi-service architecture needs services that can receive private-network traffic.
- The PostgreSQL plan defaults to free, which expires after 30 days. For persistent data, select a paid database plan before applying.
- Check Render pricing and your workspace's available plans before `terraform apply`.
- Do not commit API keys, JWT secrets, terraform.tfvars, or Terraform state.

PROJECT EXPECTED AT REPOSITORY ROOT
  compose.yaml
  library-api-gateway/Dockerfile
  library-auth-service/Dockerfile
  library-book-service/Dockerfile
  library-eureka-server/Dockerfile
  terraform-render/...

SETUP ON WINDOWS
1. Install Terraform: https://developer.hashicorp.com/terraform/install
2. Install Git: https://git-scm.com/download/win
3. Create a Render API key in the Render dashboard/account settings. Do not paste it into files.
4. In PowerShell, set the API key for this terminal session:
   $env:RENDER_API_KEY = "PASTE_YOUR_RENDER_API_KEY_HERE"
5. Clone your GitHub repository and open its root folder. The repository URL must be HTTPS and the repository must be accessible to Render.
6. Open PowerShell in the `terraform-render` directory.
7. Set a strong JWT secret for this terminal session (use a password manager or a secure random generator):
   $env:TF_VAR_jwt_secret = "REPLACE_WITH_A_UNIQUE_RANDOM_SECRET_AT_LEAST_32_CHARACTERS"
8. Initialize Terraform:
   terraform init
   Expected: Terraform has been successfully initialized!
9. Validate syntax:
   terraform validate
   Expected: Success! The configuration is valid.
10. Review the plan (replace the URL with your actual repository URL):
   terraform plan -var='repo_url=https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git' -out=render.tfplan
11. Carefully review the resources and cost. If anything is unexpected, do not apply.
12. Create resources:
   terraform apply render.tfplan
13. Display gateway URL:
   terraform output -raw api_gateway_url

RECOMMENDED REPOSITORY LAYOUT
Put the contents of this archive's `skill-11-exp` directory at the root of the GitHub repository. Keep `terraform-render` as a subfolder. The Terraform repo_url must point to that repository.

TESTING
PowerShell:
$GATEWAY = terraform output -raw api_gateway_url
curl.exe -i "$GATEWAY/actuator/health"
curl.exe -i -X POST "$GATEWAY/api/auth/login" -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}'

Copy the token from the login JSON response, then:
$TOKEN = "PASTE_TOKEN_HERE"
curl.exe -i -X GET "$GATEWAY/api/books" -H "Authorization: Bearer $TOKEN"

If login returns 200 but book requests fail, check the Render logs for the gateway, Eureka, auth, book services, and database. Ensure Eureka shows AUTH-SERVICE and BOOK-SERVICE instances UP. Never use the local Docker Compose hostname `postgres` in Render; Terraform sets the Render database address.

CLEANUP
To delete the Terraform-managed Render resources:
terraform destroy -var='repo_url=https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git'
Review the destroy plan carefully. This can delete your database and its data.
