# Bitbucket Pipelines Agent Docker image for Docksal CI

A thin agent used to provision Docksal powered sandboxes on a remote Docker host.

This image(s) is part of the [Docksal](http://docksal.io) image library.


## Docksal CI Sandboxes

For any Docksal powered project enabling Bitbucket Pipelines and dropping [this](bitbucket-pipelines.yml) file 
into the project repo will enable per-branch sandbox provisioning.
URLs to sandbox environments can be found in the build logs and can also published to a desired Slack channel.


## Image variants and versions

### Stable

- `docksal/bitbucket-pipelines-agent` - basic (bash, curl, git)
- `docksal/bitbucket-pipelines-agent:php` - basic + php stack tools (composer, drush, drupal console, wp-cli, etc)
- `docksal/bitbucket-pipelines-agent:1.0` - basic, specific version
- `docksal/bitbucket-pipelines-agent:1.0-php` - php, specific version

### Development

- `docksal/bitbucket-pipelines-agent:edge`
- `docksal/bitbucket-pipelines-agent:edge-php`


## Configuration

The following required variables should be configured at the Bitbucket organization level (this way all
project repos will have access to them). 

`DOCKSAL_HOST` or `DOCKSAL_HOST_IP`

The address of the remote Docksal host, which will be hosting sandboxes. Configure one of the other.  
If using `DOCKSAL_HOST`, make sure the domain is configured as a wildcard DNS entry.  
If using `DOCKSAL_HOST_IP`, the agent will use `xip.io` for dynamic wildcard domain names for sandboxes. 

`DOCKSAL_HOST_SSH_KEY`

A base64 encoded private SSH key used to access the remote Docksal host.  
See [Access remote hosts via SSH](https://confluence.atlassian.com/bitbucket/access-remote-hosts-via-ssh-847452940.html) 
tutorial for details.

`CI_SSH_KEY`

A secondary SSH key (base64 encoded as well), which can be used for deployments and other remote operations run directly 
on the agent.  
E.g. cloning/pushing a repo, running commands over SSH on a remote deployment environment.

Other features and integrations are usually configured at the Bitbucket repo level. See below.


## Basic HTTP Auth

Protect sandboxes from public access using Basic HTTP authentication.

### Configuration

Set the following environment variables at the repo level:

- `HTTP_USER`
- `HTTP_PASS`


## Slack integration

This integrations allows the agent to post messages to a given Slack channel.  
It can be used for notification purposes when a build is started, completed, failed, etc.

### Configuration

`SLACK_WEBHOOK_URL`

The Incoming Webhook integration URL from Slack, 
e.g. `SLACK_WEBHOOK_URL https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXxxXXXXxxXXXXxxXXXXxxXX`

`SLACK_CHANNEL`

A public or private channel in Slack, e.g. `SLACK_CHANNEL #project-name-bots`

### Usage

`slack 'message' ['#channel'] ['webhook_url']`

Channel and webhook url can be passed via environment variables. See above. 

### Limitations

Incoming Webhook integration won't work for private channels, which the owner of the integration does not belong to.
