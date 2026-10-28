SKILL-11-EXP: RENDER + TERRAFORM (FREE-TIER EXPERIMENT)

ARCHITECTURE
- API Gateway, Auth Service, and Book Service are separate Free web services.
- Eureka is deliberately not deployed: Render Free web services cannot receive private-network traffic, and the original Eureka setup advertised container IPs.
- The gateway calls the auth/book services by their public HTTPS URLs.
- Render Free PostgreSQL is used for the Book Service.

The three application Dockerfiles use a smaller JVM heap setting to improve the chance of running on Render Free 256 MB instances. This is still not a guarantee: Spring Boot startup may be slow or exceed free memory.

IMPORTANT FREE-TIER LIMITATIONS
- Render Free web services sleep after 15 minutes without inbound traffic and may take about a minute to wake up.
- Free web services cannot receive private-network traffic. This configuration uses public HTTPS calls instead.
- Free PostgreSQL expires 30 days after creation and has limited storage. Export your data before expiration.
- Your workspace may still require payment verification. If Render returns a payment-information-required error even for Free plans, stop; Terraform cannot bypass an account-level billing requirement. Do not add payment information unless you choose to.
- This is for learning/testing, not production. Public auth/book service URLs should be secured before real use.

REPOSITORY LAYOUT
The root of the GitHub repository should contain compose.yaml, the three service folders, library-eureka-server (unused here), and terraform-render.

SETUP
1. Set your Render API key in PowerShell (never commit it):
   $env:RENDER_API_KEY = "YOUR_RENDER_API_KEY"
2. Set the Render Owner ID if the provider asks for it:
   $env:RENDER_OWNER_ID = "YOUR_RENDER_OWNER_ID"
3. Set a strong unique JWT secret for this terminal session:
   $bytes = New-Object byte[] 48
   $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
   $rng.GetBytes($bytes)
   $env:TF_VAR_jwt_secret = [Convert]::ToBase64String($bytes)
   $rng.Dispose()
4. Commit/push these updated application.properties and terraform-render files to the GitHub repository's main branch.
5. In this folder, run:
   terraform init -upgrade
   terraform fmt
   terraform validate
   terraform state list
6. Review existing state before proceeding. The previous paid-plan apply may have created some resources. Do not blindly destroy them.
7. If no resources exist in Terraform state, plan with:
   terraform plan -var="repo_url=https://github.com/venkai1234/skill-11-exp-render.git" -out="render-free.tfplan"
8. Confirm plan proposes only 4 resources (Postgres + auth + book + gateway), all web services plan="free". This configuration uses the Render free Postgres plan, which expires after 30 days. Then apply:
   terraform apply "render-free.tfplan"
9. If resources from the old configuration are already in state, stop and inspect/reconcile the plan first. Do not apply until Terraform shows no unexpected destroys or replacements.
10. Get gateway URL:
   $GATEWAY = terraform output -raw api_gateway_url
   curl.exe -i "$GATEWAY/actuator/health"
   curl.exe -i -X POST "$GATEWAY/api/auth/login" -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}'

After login returns a JWT token, test books:
   $TOKEN = "PASTE_TOKEN_HERE"
   curl.exe -i -X GET "$GATEWAY/api/books" -H "Authorization: Bearer $TOKEN"

If requests fail, check Render deploy/runtime logs. Free services can take time to wake up. Do not paste secrets into chat.

CLEANUP
Use terraform destroy only after reviewing the destroy plan carefully. It deletes Terraform-managed services and may delete the database and its data.
