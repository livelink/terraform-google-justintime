## Just In Time Terraform Module

_[Just In Time](https://cloudnativenow.com/features/just-in-time-permissions-in-microservices-based-applications/)_ permissions are a concept drawn from the _[Principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)_<br>
A Google Cloud Community group has created [jit-access](https://github.com/GoogleCloudPlatform/jit-access),
an application that gives users the ability to request additional permissions from a configured list of roles.<br>

This is a terraform module covering most configurable options jit-access provides. 

>**Info:** 
> The only configuration I chose not to include is the iam bindings set for users. 
> I have included examples and explanation in the [jit-access-readme.md](docs/jit-access-readme.md) file. 


## How to use the module

### Scope
jit-access allows you to set the scope of the application in the [hierarchy](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy). <br>
With the `scope_type` variable you are able to decide this for yourself. <br>
> **Warning:** <br>
> Placing an application and a service account at the organisation/folder scope <br>
> provides the permissive role [Security Admin](https://cloud.google.com/iam/docs/understanding-roles#iam.securityAdmin) across your organisation. This should **only** be done knowingly.

Make sure to input the correct acting variable that matches your desired scope
`acting_project`, `acting_folder` or `acting_organization` 

I chose `acting` as a key word to differentiate it from `deployment` <br>
in case you choose to deploy the app in `project-id-1` but wanted it configured with project scope to set permissions for `project-id-2`

### Multi Party Approval
multi party approval is a feature of jit-access that allows you to permit a role but require someone who has that role assigned 
to approve the request before it is assigned. <br>
This feature can be turned on with the `enable_multi_party_approval` variable. <br>
It will require creating a workspace user account, instructions on how to do this in Google Workspaces is [here](https://github.com/GoogleCloudPlatform/jit-access/wiki/Configure-Multi-Party-Approval#obtain-smtp-credentials)<br>


### Allow Unauthenticated Invocations
Cloud Run allows you to open invocations up to the internet.
Although you will be behind the IAP this setting should be still be off. <br>
I have given you access to change this `allow_unauthenticated_invocations`

-------- 
For more information on jit-access see [jit-access-readme.md](docs/jit-access-readme.md)