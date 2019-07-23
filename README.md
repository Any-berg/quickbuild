## Introduction

QuickBuild supports external authentication mainly through [Active Directory and LDAP](https://wiki.pmease.com/display/qb90/Authenticate+with+Active+Directory+and+LDAP); Jira and TeamForge are available as options, yet there isn't any documentation for either.

![protect](img/protect.png)

[OpenID Connect](https://openid.net/connect/) (OIDC) authentication becomes possible when QuickBuild runs behind a [Reverse Proxy](https://wiki.pmease.com/display/qb90/Running+Behind+Apache) that operates as a [Relying Party](https://github.com/zmartzone/mod_auth_openidc) protecting some part of the backend content. The need to preserve [Anonymous Access](https://wiki.pmease.com/display/qb90/Enable+Anonymous+Access+and+Self+Registering) and [Internal Authentication](https://wiki.pmease.com/display/qb90/Authenticate+with+Active+Directory+and+LDAP) places heavy restrictions on what can actually be protected.

## Why Self-Register?

This implementation sacrifices the [Self-Registering](https://wiki.pmease.com/display/qb90/Enable+Anonymous+Access+and+Self+Registering) functionality to repurpose it as a protected authentication/callback URL, and to gain its UI links. Related requests are diverted to the chosen OIDC provider, and corresponding callbacks return with an authentication header that determines the user's `Login Name` for [Single Sign-On](https://wiki.pmease.com/display/qb90/Single+sign-on+Support).

![unauthorize](img/unauthorize.png)

The reverse proxy needs to ensure that all requests coming to it are stripped of this authentication header. The authentication/callback URL (repurposed from registration) is already protected from tampering, but possible authentication headers need to be removed from all unprotected URLs as well.

## Never Trust Localhost!

QuickBuild has to trust the authentication header from some specified IP address. Surprisingly, `localhost` cannot be trusted because of its potential for [Privilege Escalation](https://en.wikipedia.org/wiki/Privilege_escalation): already authenticated users can find out who the administrators are and thereby know their `Login Name`s - and they don't even need `RESTful API Accessible`, `Script Allowed` or inherently dangerous permissions like `EDIT_SETTINGS`, `CREATE_SCRIPT` and `RUN_BUILD`, to authorize their RESTful API calls from shell commands executed locally as the QuickBuild process user, via QuickBuild scripts that any user can insert even without any permissions.

![trust](img/trust.png)

Containerizing the reverse proxy gives it a distinct IP that can be trusted, and even a possible [Binding Address](https://wiki.pmease.com/display/qb90/Listen+to+specified+IP+address) for QuickBuild; that would force all requests, including RESTful API calls from the `server` build node, to pass through the proxy. This wouldn't give any additional security, since localhost authentication headers are already not trusted.

## Login Name Changes

[My Setting](https://wiki.pmease.com/display/qb90/Manage+User+Profile) normally allows users to change their `Login Name`. This causes problems for any external authenticator. Using [Single Sign-On](https://wiki.pmease.com/display/qb90/Single+sign-on+Support) has forced the reverse proxy to disable it as a security risk: it could have been used to secretly initialize the accounts of still unregistered colleagues with preset passwords. If someone's `Login Name` still needs to be changed, administrators can do that from [User Management](https://wiki.pmease.com/display/qb90/User+and+Group+Management).

