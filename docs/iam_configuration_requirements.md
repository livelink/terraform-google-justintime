## IAM Configuration Requirements


In order to make jit-access work from this module you will need to configure the access your users have.
As discussed here [jit-access-readme.md](faq.md) I decided when making this module I would draw
a hard line between user roles and the roles assigned to the service accounts necessary to get the application capable of performing its duties. 
Every assigned role in this module is assigned to a service account created in this module. 

That leaves 2 types of assignment left for users to implement in more suitable places in their terraform.
- User access though the IAP
- The roles that a user can request 'just in time' (ya know the whole reason for the app)


```terraform

resource "google_iap_web_backend_service_iam_member" "iap_http_access" {
  for_each = var.iap_access_principle
  project             = local.deployment_project
  web_backend_service = ""
  role                = "roles/iap.httpsResourceAccessor"
  member              = each.value
}
```