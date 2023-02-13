# rbac_migrate

## What problem does this solve

You may have built a new Puppet server and want to copy over your RBAC roles from your old Puppet server.

## How does it solve it

1. It accesses the Puppet RBAC API of your old PE server to read the RBAC configuration and it stores the config in a file.
2. It then reads the file and posts the config to the new PE server via the RBAC API.

API documentation https://www.puppet.com/docs/pe/latest/rbac-api.html 

## What do you need

1. You need ruby but as your on a PE server it's already there.
2. A name for the data file you're going to store the data in.
3. An API token, you can generate one by following this document. https://www.puppet.com/docs/pe/latest/rbac_token_auth_intro.html


## Example

### get

This is an example of getting the config off a server.

```
/opt/puppetlabs/installer/bin/ruby rbac_migrate.rb
Enter the API token:
############################
Enter the hostname (e.g. localhost):
localhost
Enter target/source file (.json):
rbac_config.json
Are we getting the RBAC config or pushing it? [get|push]
get
```

### push

This is an example of sending the config up to a server.

```
/opt/puppetlabs/installer/bin/ruby rbac_migrate.rb
Enter the API token:
############################
Enter the hostname (e.g. localhost):
localhost
Enter target/source file (.json):
rbac_config.json
Are we getting the RBAC config or pushing it? [get|push]
push