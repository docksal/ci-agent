# Bitbucket Pipelines Agent Docker image for Docksal CI

A thin agent used to provision Docksal powered sandboxes on a remote Docker host.

This image(s) is part of the [Docksal](http://docksal.io) image library.

## Docksal CI Sandboxes

For any Docksal powered project enabling Bitbucket Pipelines and dropping this file into the project repo will enable per-branch sandbox provisioning.
URLs to sandbox environments can be found in the build logs and can also published to a desired Slack channel.


## Slack notifications

## Usage

`slack 'message' ['#channel'] ['webhook_url']`

Channel and webhook url can be passed via environment variables. See below.

## Configuration

### Global Pipelines variables

The agent expects the following required variables to be defined.

`DOCKER_HOST` or `DOCKER_HOST_IP`

The address of the remote Docker host, which will be hosting sandboxes. Configure one of the other.  
If using `DOCKER_HOST`, make sure the domain is configured as a wildcard DNS entry.  
If using `DOCKER_HOST_IP`, the agent will use `xip.io` for dynamic wildcard domain names for sandboxes. 

`DOCKER_HOST_SSH_KEY`

A base64 encoded private SSH key used to access the remote Docker host.  
See [Access remote hosts via SSH](https://confluence.atlassian.com/bitbucket/access-remote-hosts-via-ssh-847452940.html) 
tutorial for details.

`CI_SSH_KEY`

A second SSH keys (base64 encoded as well), which can be used for deployments and other remote operations run directly on the agent.  
E.g. cloning/pushing a repo, running commands over SSH on a remote deployment environment.

### Project level Pipelines variables 

The following environment variables can be configured in the project's Pipelines settings:

`SLACK_WEBHOOK_URL`

The Incoming Webhook integration URL from Slack, e.g. `SLACK_WEBHOOK_URL https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXxxXXXXxxXXXXxxXXXXxxXX`

`SLACK_CHANNEL`

A public or private channel in Slack, e.g. `SLACK_CHANNEL #project-name-bots`

### Limitations

Incoming Webhook integration won't work for the private channels, which the owner of the integration does not belong to.
