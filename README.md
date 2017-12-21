# CI agent Docker image for Docksal Sandboxes

A thin agent used to provision Docksal Sandboxes on a remote Docker host.  

Supported CI providers:

- Bitbucket Pipelines
- CircleCI
- GitLab

This image(s) is part of the [Docksal](http://docksal.io) image library.


## Docksal Sandboxes

Docksal Sandboxes are continuous integration environments powered by Docksal.  
They can be provisioned for any git branch and are feature-wise identical to project's local Docksal environment.

Use cases:

- automated testing (full stack)
- manual testing
- enhanced pull request review experience
- demos

URLs to sandbox environments can be found in the build logs and can also be published to a Slack channel.


## Image variants and versions

### Stable

- `docksal/bitbucket-pipelines-agent` - basic (bash, curl, git, etc.), latest version
- `docksal/bitbucket-pipelines-agent:php` - basic + php stack tools (composer, drush, drupal console, wp-cli, etc.), latest version
- `docksal/bitbucket-pipelines-agent:1.0` - basic, specific stable version
- `docksal/bitbucket-pipelines-agent:1.0-php` - php, specific stable version

### Development

- `docksal/bitbucket-pipelines-agent:edge` - base, latest development version
- `docksal/bitbucket-pipelines-agent:edge-php`, php, latest development version


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

### Bitbucket Pipelines

Copy the example [bitbucket-pipelines.yml](examples/bitbucket-pipelines/bitbucket-pipelines.yml) file into the project 
repo and adjust as necessary.

### CircleCI

Copy the example [config.yml](examples/.circleci/config.yml) file into the project repo and adjust as necessary.


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

```bash
slack 'message' ['#channel'] ['webhook_url']
```

Channel and webhook url can be passed via environment variables. See above. 

### Limitations

Incoming Webhook integration won't work for private channels, which the owner of the integration does not belong to.


## Build artifact storage

Build artifacts can be stored in an AWS S3 bucket.  

### Configuration

Set the following environment variables at the organization or repo level:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ARTIFACTS_BUCKET_NAME`
- `ARTIFACTS_BASE_URL` (optional)
- `BITBUCKET_API_AUTH` (optional)

### Usage

To upload artifacts to the configured S3 bucket use the `build-acp` command.

```bash
build-acp /source/path/
```

There is no file browsing capability available for private S3 buckets.  
An `index.html` file is used as the directory index, however it has to be created/generated manually.  
When uploading a prepared artifacts folder with the `index.html` file in it, add a trailing slash to the source path to
upload the contents of the source folder vs the folder itself.

You can upload additional folders/files by running the command multiple times.

The optional `destination` argument can be used to define a subdirectory at the destination in the bucket.  

```bash
build-acp /source/path/ destination/path
```

### Advanced usage

**Base URL**

The base URL is derived from `ARTIFACTS_BUCKET_NAME` as follows (assuming AWS S3 `us-east-1` region by default):

```
https://${ARTIFACTS_BUCKET_NAME}.s3.amazonaws.com
```

It can be overridden via the optional `ARTIFACTS_BASE_URL` configuration variable at the organization/repo level:

```
ARTIFACTS_BASE_URL = https://artifacts.example.com
```

**Upload path**

The upload path is unique for each commit and is derived as follows: 

```bash
${REPO_NAME_SAFE}/${BRANCH_NAME_SAFE}-${GIT_COMMIT_HASH}
```

In certain cases you may want to store build artifacts per branch instead of per commit.  
To do this, override the `ARTIFACTS_BUCKET_PATH` variable before calling the `build-acp` command: 

```bash
export ARTIFACTS_BUCKET_PATH="${REPO_NAME_SAFE}/${BRANCH_NAME_SAFE}"
build-acp my-artifacts/
```

**Posting build artifact URLs to Bitbucket**

If the `BITBUCKET_API_AUTH` is set, the URL to the artifacts will be posted back to Bitbucket via 
[Bitbucket Build Status API](https://blog.bitbucket.org/2015/11/18/introducing-the-build-status-api-for-bitbucket-cloud/).

See [this article](https://confluence.atlassian.com/bitbucket/publish-and-link-your-build-artifacts-872137736.html) for 
information on how to get `BITBUCKET_API_AUTH` (steps 1 and 2 only).

### Security

If a bucket does not exist, it will be created automatically (with no public access). Existing bucket access permissions 
are not automatically adjusted. It's up to you whether you want to keep them open or not.

When artifacts are uploaded, the destination artifact folder in the bucket is set to be publicly accessible. 
Anyone with the direct link will be able to access the artifacts, but will not be able to browse the list of all 
available artifact folders in the bucket (so long as the bucket itself is set to be private). 

The URL by default includes a git commit hash, which serves as an authentication token (the URL is impossible to guess). 
This provides a simple yet efficient level of security for artifacts.

To add an additional level of security follow [this guide](https://medium.com/@lmakarov/serverless-password-protecting-a-static-website-in-an-aws-s3-bucket-bfaaa01b8666) 
to set up username/password access to S3 via CloudFront and Lambda@Edge.
