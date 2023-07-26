## Just In Time Terraform Module

_[Just In Time](https://cloudnativenow.com/features/just-in-time-permissions-in-microservices-based-applications/)_ permissions are a concept drawn from the _[Principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)_<br>
A Google Cloud Community group has created [jit-access](https://github.com/GoogleCloudPlatform/jit-access),
an application that gives users the ability to request additional permissions from a configured list of roles.<br>

### How does jit-access work?

Depending on the scope of your deployment, the application is assigned either _Project_, _Folder_ or _Organisation_ `Security Admin` Role. <br>
Using this it searches through bindings the users constraints for either `has({}.jitAccessConstraint)` `has({}.multiPartyApprovalConstraint)` ([multi party not supported with this module](faq.md#why-didnt-you-include-multi-party-approval)) <br>
Matches are given to the user as escalation options. <br>
The selected roles are assigned with a `JIT access activation` Condition which works like a normal Expiring access duration Condition.



### How to use the module

This module creates a Cloud Run instance of jit-access by automating the build steps set out in this [documentation](https://cloud.google.com/architecture/manage-just-in-time-privileged-access-to-project#cloud-run).
There are a few steps you will need to do in preperation before deployment.

1. Download and checkout the latest version of the jit-access application.
```   
    git clone https://github.com/GoogleCloudPlatform/jit-access.git
    cd jit-access/sources
    git checkout latest
```
2. Build and push the container into your chosen artifact registry. This must be public or in stored in Google Cloud. see [faq - Why cant I use a private registry that not google cloud](docs/faq.md#why-cant-i-use-a-private-registry-thats-not-google-cloud)
```
    docker build -t [artifact registery]/jitaccess:latest .
    docker push [artifact registery]/jitaccess:latest
```

3. Now you just need to run the module! Be sure to read the thoughts behind the below options though!

4. You can now add conditions to users Role assignments that will prompt in the application see [faq - How do i configure what jit roles I assign a user](docs/faq.md#how-do-i-configure-what-jit-roles-i-assign-a-user)

5. Use the application see [faq - How does a user use jit-access](docs/faq.md#how-does-a-user-use-jit-access)
#### Scope
jit-access allows you to set the scope of the application in the [hierarchy](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy). <br>
With the `scope_type` variable you are able to decide this for yourself. <br>
> **Warning:** <br>
> Placing an application and a service account at the organisation/folder scope <br>
> provides the permissive role [Security Admin](https://cloud.google.com/iam/docs/understanding-roles#iam.securityAdmin) across your organisation. This should **only** be done knowingly.

Make sure to input the correct acting variable that matches your desired scope
`acting_project`, `acting_folder` or `acting_organization` 

I chose `acting` as a key word to differentiate it from `deployment` <br>
in case you choose to deploy the app in `project-id-1` but wanted it configured with project scope to set permissions for `project-id-2`


#### Allow Unauthenticated Invocations
Cloud Run allows you to open invocations up to the internet.
Although you will be behind the IAP this setting should be still be off for sensitive applications such as this. <br>
I have given you access to change this `allow_unauthenticated_invocations`


#### Identity Aware Proxy Access Principle
There is no default set for this value because who you provide access to the application is a question that should be answered with defaults.
That being said, there will be an answer many will consider the one that makes the most sense `domain:example.com`. <br>
With this all users authenticating with your domain will have access to the application to see if they have any assigned roles.

The less, the better of course so this can be replaced with any supported [principle identifier](https://cloud.google.com/iam/docs/principal-identifiers)

### Things you can't do with this module.

- You can not remove all resources with a `terragrunt destroy` command see [faq - why can't I delete the IAP brand?](docs/faq.md#why-cant-i-delete-the-iap-brand) for more
- I have not included a way to configure User aim roles in this module see [faq - why didnt you include the ability to configure the users from this module](docs/faq.md#why-didnt-you-include-the-ability-to-configure-the-users-from-this-module) for more.
- I have not included multi party approval in this module see [faq - why didnt you include multi party approval](docs/faq.md#why-didnt-you-include-multi-party-approval) for more.
- Use a private container that is not stored in Google Cloud see [faq - Why cant I use a private registry that not google cloud](docs/faq.md#why-cant-i-use-a-private-registry-thats-not-google-cloud)

-------- 
For more information on jit-access see [faq](docs/faq.md)