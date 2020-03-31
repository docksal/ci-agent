# CI agent Docker image for Docksal Sandboxes

A thin agent used to provision Docksal Sandboxes on a remote Docker host.  

Supported CI providers:

- Bitbucket Pipelines (with build status integration)
- CircleCI (with build status integration)
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

Build status updates (and sandbox URLs) can be posted to Github and Bitbucket via respective build status APIs.  
URLs to sandbox environments can also be published to a Slack channel.  


## Image variants and versions

### Stable

- `base` - basic (bash, curl, git, etc.), latest version
- `php`, `latest` - basic + php stack tools (composer, drush, drupal console, wp-cli, etc.), latest version
- `1.2-base` - basic, a specific stable version
- `1.2-php` - php, a specific stable version

### Development

- `edge-base` - base, latest development version
- `edge-php`, php, latest development version


## Global Configuration

### Required

The following required variables are usually configured at the organization level. This way, all project repos will 
have access to them. They can as well be configured at the repo level.

`DOCKSAL_HOST` or `DOCKSAL_HOST_IP`

The address of the remote Docksal host, which is hosting sandboxes. Configure one or the other.  
If using `DOCKSAL_HOST`, make sure the domain is configured as a wildcard DNS entry.  
If using `DOCKSAL_HOST_IP`, the agent will use `nip.io` for dynamic wildcard domain names for sandboxes. 

`DOCKSAL_HOST_SSH_KEY`

A base64 encoded private SSH key, used to access the remote Docksal host.

Note: on macOS `cat /path/to/<private_key_file> | base64` can be used to create a base64 encoded string from a private SSH key, while on Linux and in WSL on Windows 10 `cat /path/to/<private_key_file> | base64 -w 0` should be used to avoid output wrapping of the `base64` command).

### Optional

`BUILD_ENVIRONMENT`

Used to set the environment built against. Defaults to `local`.

`CI_SSH_KEY`

A base64 encoded private SSH key, used by default for all hosts (set as `Host *` in `~/.ssh/config`).
This key will be used to clone/push to git, run commands over SSH on a remote deployment environment, etc.

`DOCKSAL_HOST_SSH_PORT`

The variable can be set if sandbox ssh service is running on a non-standard port (22)

`DOCKSAL_DOMAIN`

Can be used to set the base URL for sandbox builds (defaults to `DOCKSAL_HOST` if not set), individually from `DOCKSAL_HOST`.  
This is useful when working with CDNs/ELBs/WAFs/etc (when `DOCKSAL_DOMAIN` is different from the `DOCKSAL_HOST`).

`DOCKSAL_HOST_USER`

The user's name that should have access to the remote Docksal host. Defaults to `build-agent`.

`REMOTE_BUILD_BASE`

The default directory location on the remote server where the repositories should be cloned down to and built. 
Defaults to `/home/build-agent/builds`

`REMOTE_CODEBASE_METHOD`

Pick between `rsync` (default) and `git` for the codebase initialization method on the sandbox server.

The codebase is initialized on the sandbox server by the `sandbox-init` (or `build-init`) command.

`git` - code is checkout on the sandbox server via git. Server must have access to checkout from the repo. 
Any build settings and necessary code manipulations must happen on the sandbox server using `build-exec` commands.

`rsync` - code is rsync-ed to the sandbox server from the build agent. You can perform necessary code adjustments in the 
build agent after running `build-env` and before running `sandbox-init` (or `build-init`), which pushes the code to the 
sandbox server.

`REMOTE_BUILD_DIR_CLEANUP`

Whether or not the remote build directory is reset during the build. Only supported with `REMOTE_CODEBASE_METHOD=git`.

Defaults to `1` which wipes the remote build directory and produces a "clean build".    
Set to `0` to produce "dirty builds", when file changes in the remote codebase should be preserved.

Note: Switching `REMOTE_CODEBASE_METHOD` mode will result in a clean build. 

`SANDBOX_PERMANENT`

Set `SANDBOX_PERMANENT=true` to have a permanent sandbox provisioned.

Permanent sandboxes are exempt from scheduled garbage collection on the sandbox server. They would still hibernate after
the configured period of inactivity, but won't be removed from the server after becoming dangling.
See https://github.com/docksal/service-vhost-proxy#advanced-proxy-configuration for more information. 

This variable is usually set at the branch level in the build settings to designate a specific (one or multiple) 
branch environments as permanent.

`SANDBOX_DOMAIN`

Sets a custom domain for a sandbox. Takes precedence over the automatic (branch name based) domain generation.

This can be used for sandbox environments which need a custom (nice) domain name.

`GITHUB_TOKEN` and `BITBUCKET_TOKEN`

Used for access to post sandbox URLs via build status API as well as comments on pull requests.  

For Github, the token can be generated from the [user's account](https://github.com/settings/tokens).  
Set access to "repo" (http://take.ms/nMqcW).

For Bitbucket, the token can be generated from the user's settings. Instructions on creating an [app password](https://confluence.atlassian.com/bitbucket/app-passwords-828781300.html).  
Set access to "Repositories: Write", "Pull requests: Write" (http://take.ms/98BG5).  
When storing the app password it is in the format: `USER:PASSWORD`.

`GIT_USER_EMAIL`

The user's email to perform Git operations as. Defaults to `ci@docksal.io`

`GIT_USER_NAME`

The user's name to perform Git operations as. Defaults to `Docksal CI`

`DOCKSAL_HOST_TUNNEL`

If not empty, `localhost:2374` in the agent is mapped to `docker.sock` on the remote `DOCKSAL_HOST` via a secure SSH tunnel.  
The agent can then run `docker` commands against the remote `DOCKSAL_HOST`.


Other features and integrations are usually configured at the repo level. See below.


## Project configuration

### Bitbucket Pipelines

Here's the most basic configuration for Bitbucket Pipelines. Save it into `bitbucket-pipelines.yml` in your project repo.

```yaml
image: docksal/ci-agent:base

pipelines:
  default:
    - step:
        script:
          - source build-env && sandbox-init
```

For a more advanced example see [bitbucket-pipelines.yml](examples/bitbucket-pipelines/bitbucket-pipelines.yml).

### CircleCI

Here's the most basic configuration for CircleCI. Save it into `.circleci/config.yml` in your project repo.

```yaml
version: 2

jobs:
  build:
    working_directory: /home/agent/build
    docker:
      - image: docksal/ci-agent:base
    steps:
      - run:
          name: Configure agent environment
          command: echo 'source build-env' >> $BASH_ENV
      - checkout
      - run:
          name: Build sandbox
          command: sandbox-init
```

For a more advanced example see [config.yml](examples/.circleci/config.yml).

### GitLab

Here's the most basic configuration for GitLab. Save it into `.gitlab-ci.yml` in your project repo.

```yaml
stages:
  - sandbox

sandbox-launch:
  stage: sandbox
  image: docksal/ci-agent:base
  script:
    - export SANDBOX_DOMAIN=$CI_ENVIRONMENT_SLUG--$CI_PROJECT_NAME.$DOCKSAL_HOST
    - source build-env
    - sandbox-init
  environment:
    name: $CI_COMMIT_REF_NAME
    url: https://$CI_ENVIRONMENT_SLUG--$CI_PROJECT_NAME.$DOCKSAL_HOST
```

For a more advanced example see [.gitlab-ci.yml](examples/gitlab/.gitlab-ci.yml).


## Build commands

For a complete list of built-in commands see [base/bin](base/bin).

- `build-env` - configures build settings on the agent. Usage: `source build-env` (or `DEBUG=1 source build-env`)
- `build-init`- initializes the sandbox codebase and settings on the sandbox server. Usage: `build-init`
- `build-exec` - executes a shell command within the build directory on the sandbox server. Usage: `build-init pwd`
- `build-notify` - see "Build status notifications" docs below
- `sandbox-init` - a convenient shortcut to provision a basic sandbox. See [sandbox-init](base/bin/sandbox-init) 


## Build environment variables

The following variables are derived from the respective Bitbucket Pipelines, Circle CI, and GitLab CI build variables. 

- `GIT_REPO_OWNER` - git repo machine owner/slug name
- `GIT_REPO_NAME` - git repo machine name
- `GIT_REPO_URL` - git repo URL
- `GIT_BRANCH_NAME` - git branch name
- `GIT_COMMIT_HASH` - git commit hash
- `GIT_PR_NUMBER` - git pull request / merge request number
- `GIT_REPO_SERVICE` - `github`, `bitbucket` or `gitlab` (makes sense mostly for CircleCI)
- `BUILD_ID` - The unique identifier for a build
- `BUILD_DIR` - The full path where the repository is cloned and where the job is run in the agent container

`REMOTE_BUILD_DIR`

The directory location on the remote server where current build will happen. Defaults to:

```
${REMOTE_BUILD_BASE}/${REPO_NAME_SAFE}-${BRANCH_NAME_SAFE}
```


## Feature: Basic HTTP Auth

Protect sandboxes from public access using Basic HTTP authentication.

### Configuration

Set the following environment variables at the repo level:

- `HTTP_USER`
- `HTTP_PASS`


## Feature: Build status notifications

This integration allows the agent to post build status updates and sandbox URL via Github/Bitbucket build status API.  
For CircleCI, it is also possible to enable posting the sandbox URL as a comment in pull requests. 

### Configuration

`GITHUB_TOKEN` or `BITBUCKET_TOKEN` must be configured respectively (either globally or at the repo level). 

### Usage

`build-notify <pending|success|failure>`

Place the triggers right before and right after `fin init` call in your build script, e.g.,

```bash
build-notify pending 
ssh docker-host "cd $REMOTE_BUILD_DIR && fin init" || ( build-notify failure && exit 1 )
build-notify success
```

To enable posting sandbox URLs in comments on pull requests, do `export PR_COMMENT=1` prior to calling `build-notify`


## Feature: Slack notifications

This integrations allows the agent to post messages to a given Slack channel.  
It can be used for notification purposes when a build is started, completed, failed, etc.

### Configuration

`SLACK_WEBHOOK_URL`

The Incoming Webhook integration URL from Slack, 
e.g., `SLACK_WEBHOOK_URL https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXxxXXXXxxXXXXxxXXXXxxXX`

`SLACK_CHANNEL`

A public or private channel in Slack, e.g., `SLACK_CHANNEL #project-name-bots`

`SLACK_USER`

The username the message should post to Slack as. Defaults to `Docksal CI`

`SLACK_ICON`

The icon the message should use to accompany the message: Defaults to `:desktop_computer:`

### Usage

```bash
slack 'message' ['#channel'] ['webhook_url'] ['slack_user'] ['slack_icon']
```

Channel and webhook url can be passed via environment variables. See above. 

### Limitations

Incoming Webhook integration won't work for private channels, which the owner of the integration does not belong to.


## Feature: Build artifact storage

Build artifacts can be stored in an AWS S3 bucket.  

### Configuration

Set the following environment variables at the organization or repo level:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ARTIFACTS_BUCKET_NAME`
- `ARTIFACTS_BASE_URL` (optional)
- `GITHUB_TOKEN` (optional)
- `BITBUCKET_TOKEN` (optional)

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

If `BITBUCKET_TOKEN` is set, the URL to the artifacts will be posted back to Bitbucket via 
[Bitbucket Build Status API](https://blog.bitbucket.org/2015/11/18/introducing-the-build-status-api-for-bitbucket-cloud/).

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


## Feature: Non-volatile environments

By combining the following configuration options you can get low overhead non-volatile environments.

```
SANDBOX_DOMAIN=<nice-domain>
SANDBOX_PERMANENT=true
REMOTE_CODEBASE_METHOD=git
REMOTE_BUILD_DIR_CLEANUP=0
``` 

Such environments can be used for non-critical production-ish workloads, whenever an on-demand delayed start 
(5-10s delay) is not a concern.

## Feature: Secrets in environment variables

It is best security practice not to store secrets such as API keys in a code repository. Many CI systems already have the ability to set such environment variables during the build process. Any environment variables set at build time whose name starts with `SECRET_` will be forwarded as-is to the built environment.
