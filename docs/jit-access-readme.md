### How does a user use jit-access?
- Access the web applications front page. 
- Enters the project id where they want the escalated role.
- Selects which role they need from the available list.
- Chooses the ttl for the requested access.
- inputs reason or ticket id.
- Magic! 


### How does jit-access work?

Depending on the scope of your deployment, the application is assigned either _Project_, _Folder_ or _Organisation_ `Security Admin` Role. <br>
Using this it searches through bindings the users constraints for either `has({}.jitAccessConstraint)` `has({}.multiPartyApprovalConstraint)` <br>
Matches are given to the user as escalation options. <br>
The selected roles are assigned with a `JIT access activation` Condition which works like a normal Expiring access duration Condition. 


### How do I configure what jit roles I assign a user?
You can configure what roles are eligible for escalation just like you would any other iam role with a condition.<br>
```terraform
#This is a iam binding for an automatic approval
resource "google_project_iam_member" "no_approval_required" {

  role    = "role/container.admin"
  member  = "user@company.com"
  project = var.project
  condition {
    title      = "Eligible for JIT access - automatic"
    expression = "has({}.jitAccessConstraint)"
  }
}
```
```terraform
#This is a iam binding that requires an approval
resource "google_project_iam_member" "approval_required" {

  role    = "role/container.admin"
  member  = "user@company.com"
  project = var.project
  condition {
    title      = "Eligible for JIT access - approval"
    expression = "has({}.multiPartyApprovalConstraint)"
  }
}
```

Many organisations will have IAM configured for Users in a single place. Providing the option to include
some here would encourage some configuration to move to this module.<br> 
Making it less intuitive and needlessly more complicated. Especially as the Roles in jit will be Break Glass and likely far more permissive.<br>
Keeping these tucked away is not cool! <br>

![Just_In_Time_Deployment.drawio.png](Just_In_Time_Deployment.drawio.png)


If you are looking for a module that can help implement User Role bindings try <br>
https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest/submodules/projects_iam