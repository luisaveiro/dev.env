<p align="center">
    <a href="http://github.com/luisaveiro/dev.env">
        <img 
            src="./images/organizing-projects.svg" 
            alt="organizing projects" 
            width="50%">
    </a>
</p>

<h4 align="center">
    Kick start your development environment while making a cup of coffee.
</h4>

<p align="center">
    <a href="#about">About</a> •
    <a href="#disclaimer">Disclaimer</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#download">Download</a> •
    <a href="#how-to-use">How To Use</a> •
    <a href="#executing-commands">Executing Commands</a> •
    <a href="#faq">FAQ</a>
</p>
<p align="center">
    <a href="#useful-tips">Useful Tips</a> •
    <a href="#changelog">Changelog</a> •
    <a href="#roadmap">Roadmap</a> •
    <a href="#contributing">Contributing</a> •
    <a href="#security-vulnerabilities">Security Vulnerabilities</a> •
    <a href="#credits">Credits</a> •
    <a href="#license">License</a>
</p>

## About

There are many things developers will need to get familiar with when joining a 
new development team. Developers are sometimes thrown in at the deep end when 
joining a new organization, expected to teach themselves any parts of the 
codebase and architecture they don't know. Developers are also required to set 
up their local environments quickly and start coding as soon as they can.

YouTuber Frying Pan has a [humorous video](https://youtu.be/YZ5tOe7y9x4) on 
Software Engineer interns' first day and what they can expect.

***DEV.env*** is a lightweight command-line interface that provides 
developer-friendly commands to automate parts of the setup process that 
developers are expected to perform. This includes local development 
environments, projects (git-based repositories) and rapid prototyping 
(docker-based).

<p align="center">
    <a href="http://github.com/luisaveiro/dev.env">
        <img src="./images/dev-env-cli.svg" alt="DEV.env CLI" width="75%">
    </a>
</p>

## Disclaimer

**Please note:** ***DEV.env*** was developed to help onboard developers in new 
teams that have multiple projects with a complex setup process.

It should not be used to manage projects on any 
<ins>**testing/production**</ins> environments or setting up those 
environments. Please only run ***DEV.env*** in your local environment.

## Getting Started

You will need to make sure your system meets the following prerequisites:

- Git >= 2.0.0

***DEV.env*** is a CLI tool that utilizes [Git](https://git-scm.com/) to clone 
your repositories. So, before using the CLI commands, make sure you have Git 
installed on your system, set up SSH credentials and have access to the 
repositories you are cloning in advance.

***DEV.env*** prototyping feature utilizes [Docker Awesome Compose GitHub Repo](https://github.com/docker/awesome-compose)
to provide prototyping samples. You will need to have Docker and Docker Compose 
installed on your system to use the Awesome Docker Compose samples.

## Download

You can clone the latest version of ***DEV.env repository*** for macOS and Linux.

```bash
# Clone this repository.
$ git clone git@github.com:luisaveiro/dev.env.git --branch main --single-branch
```

## How To Use

By default, ***DEV.env*** commands are invoked by using the 
`path/dev.env/bin/dev` script.

```bash
# Setup development environment.
$ bash path/dev.env/bin/dev env:setup
```

#### <ins>Configuring A Bash Alias</ins>

Instead of you repeatedly typing `bash path/dev.env/bin/dev` to execute 
***DEV.env*** commands, you can configure a Bash alias in `~/.bashrc` or 
`~/.zshrc` that allows you to execute the commands more easily:

```bash
alias dev='bash path/dev.env/bin/dev'
```

Once the Bash alias has been configured, you may execute ***DEV.env*** commands 
by simply typing `dev`. The remainder of this readme's examples will assume 
that you have configured this alias:

```bash
# Setup development environment.
$ dev env:setup
```

## Executing Commands

The `dev` script provides convenient CLI commands for automating the set up of 
your development environment, as well as cloning and setting up your project 
repositories. The following commands are available for you to manage your 
environment and repositories.

| #  	| Commands          	| Description                                            	|
|----	|-------------------	|--------------------------------------------------------	|
| 1  	| dev help          	| List of all available commands.                        	|
| 2  	| dev self-update   	| Update DEV.env to the latest version.                  	|
| 3  	| dev env:config    	| Add development environment setup file to DEV.env.     	|
| 4  	| dev env:list      	| List available development environment setup files     	|
| 5  	| dev env:setup     	| Setup development environment.                         	|
| 6  	| prototype:new     	| Start a new prototype using Docker Compose samples.    	|
| 7  	| prototype:samples 	| List Docker Compose samples                            	|
| 8  	| dev repos:config  	| Add repositories YAML file to DEV.env.                 	|
| 9  	| dev repos:publish 	| Publish repositories YAML file to a project directory. 	|
| 10 	| dev repos:setup   	| Setup Git Repositories from repositories YAML file.    	|
| 11 	| dev repos:status  	| List all Git Repositories and setup status.            	|

Below I have provided more information on each ***DEV.env*** CLI command.

#### 1. <ins>List of all available commands</ins>

To view a list of all available commands you can use, you may use the `help` 
command:

```bash
$ dev help
```

#### 2. <ins>Update DEV.env to the latest version</ins>

To ensure you have the latest version of ***DEV.env***, you can use the 
`self-update` command:

```bash
$ dev self-update
```

#### 3. <ins>Add development environment setup file to DEV.env</ins>

***DEV.env*** does not include any development environment setup files since 
each developer has their personal preference and each development team has 
different requirements to ensure all team members' environments are similar to 
ensure code consistency and ease of collaboration.

Instead, this tool offers the option to store multiple shell-based development 
environment setup files by using the `env:config` command. You can provide a 
local or remote-based setup file (supports Git repositories and 
[GitHub Gist](https://gist.github.com/)). 

However remote-based setup files are preferred over local setup files for 
several reasons not only for individual developers but also for development 
teams. 

By having remote-based setup files, you can guarantee development environment 
configurations are consistent between your team members. Plus you can transfer 
to another computer and replicate your configuration without the need to 
manually transferring various setup files.

###### Use local setup files

When using local setup files, you only need to provide the full path of the 
setup file when using the `env:config` command.

```bash
$ dev env:config path/development-setup.sh
```

By default, ***DEV.env*** will create a symbolic link to your setup file. If 
you prefer to not have a symbolic link, you can provide the `--no-symlink` 
option to the `env:config` command.

```bash
$ dev env:config path/development-setup.sh --no-symlink
```

If you wish to have ***DEV.env*** rename your setup file, you can provide the 
`name` option to the `env:config` command.

```bash
$ dev env:config path/development-setup.sh --name=macos
```

###### Use remote-based setup files

When retrieving remote-based setup files, you will need to provide the Git 
repository url when using the `env:config` command.

```bash
$ dev env:config git@<git-url>.git
```

[GitHub Gist](https://gist.github.com/) repositories use a random hash as the 
Git repositories name. Which can be difficult to remember. You can provide an 
additional `--directory` option to the `env:config` command, ***DEV.env*** will
save you GitHub Gist files or Git repositories in the named directory.

```bash
$ dev env:config git@<git-url>.git --directory=localhost
```

You can provide an additional `--only` option to the `env:config` 
command, This will allow ***DEV.env*** to only store the desired configuration 
files.

```bash
# Only keep macos setup file
$ dev env:config git@<git-url>.git --only=macos

# Provide multiple files by comma separated list
$ dev env:config git@<git-url>.git --only=macos,vscode
```

#### 4. <ins>List available development environment setup files</ins>

***DEV.env*** offers a `env:list` command to show a list of available 
development environment files in a table view that have been configured using 
***DEV.env*** `env:config` command.

```bash
$ dev env:list
```

#### 5. <ins>Setup development environment</ins>

Once you have added your development environment setup files to ***DEV.env***. 
You can use the `env:setup` command to run the various setup files to configure 
your development environment.

The `env:setup` command requires the setup file name as an argument.

```bash
# Individual setup file
$ dev env:setup macos

# Multiple setup files
$ dev env:setup macos vscode
```

#### 6. <ins>Start a new prototype using Docker Compose samples</ins>

***DEV.env*** prototyping feature utilizes [Docker Awesome Compose GitHub Repo](https://github.com/docker/awesome-compose)
to provide prototyping samples. The `prototype:new` command provides two 
methods to set up prototype project: selecting a prototype sample from the 
list or providing a Docker Compose sample name.

```bash
$ dev prototype:new

# Setup the angular Docker Compose sample
$ dev prototype angular
```

If you don't provide a Docker Compose sample name as an argument for 
`prototype:new` command, ***DEV.env*** will provide you a list of available 
Docker Compose samples.

The `prototype:new` command will copy all the files for your selected Docker 
Compose sample into the current directory of your terminal.

#### 7. <ins>List Docker Compose samples</ins>

The `prototype:samples` command is similar to the `prototype:new` command. However,
this command won't copy Docker Compose sample files. This command can be considered
as a "read-only" command.

Both commands will automatically fetch the latest commits from [Docker Awesome Compose GitHub Repo](https://github.com/docker/awesome-compose)
to ensure you always have the latest changes and Docker Compose samples.

#### 8. <ins>Add repositories YAML file to DEV.env</ins>

***DEV.env*** allows you to add your pre-existing YAML repositories 
configuration files. Similar to the `env:config` command, you can provide a 
local or remote-based repositories configuration file (supports Git 
repositories and [GitHub Gist](https://gist.github.com/)).

###### Use local repositories configuration files

When using local YAML repositories configuration files, you only need to provide 
the full path of the repositories configuration file when using the 
`repos:config` command.

```bash
$ dev repos:config path/personal.yml
```

If you wish to have ***DEV.env*** rename your YAML repositories configuration 
file, you can provide the `name` option to the `repos:config` command.

```bash
$ dev repos:config path/repos.yml --name=personal
```

###### Use remote-based repositories configuration files

When retrieving remote-based YAML repositories configuration files, you will 
need to provide the Git repository url when using the `repos:config` command.

```bash
$ dev repos:config git@<git-url>.git
```

By default ***DEV.env*** will store all YAML files in the template directory. 
You can provide an additional `--only` option to the `repos:config` 
command, This will allow ***DEV.env*** to only store the desired YAML 
repositories configuration files.

```bash
# Only keep personal YAML repositories configuration file
$ dev repos:config git@<git-url>.git --only=personal

# Provide multiple files by comma separated list
$ dev repos:config git@<git-url>.git --only=personal,company
```

#### 9. <ins>Publish DEV.env repositories configuration templates</ins>

Before ***DEV.env*** can set up your repositories, you will need to publish a 
YAML repositories configuration file to your projects root directory. You can 
use the `repos:publish` command to copy the YAML repositories configuration 
file to your project root directory.

```bash
# Change directory
$ cd projects

# Publish configuration
$ dev repos:publish
```

Once you have published your YAML repositories configuration file, your project 
directory structure is presented as follows:

```
.
+-- projects
|   +-- repositories.yml
```

###### Use template repositories configuration file

If you don't have pre-existing repositories configuration file, ***DEV.env*** 
includes a template `repositories-template.yml` which you can use.

```bash
$ dev repos:publish
```

###### Use your own repositories configuration files

The `repos:publish` command also accepts a repositories configuration name as 
an argument and copy the repositories configuration file to your project root 
directory.

```bash
$ dev repos:publish personal
```

#### 10. <ins>Setup git repositories</ins>

Once you have published your YAML repository configuration file. You will need 
to provide the following information.

| Field          	| Mandatory 	| Description                                             	|
|----------------	|-----------	|---------------------------------------------------------	|
| repo name      	| Required  	| Your repo name.                                         	|
| gitUrl         	| Required  	| SSH or HTTPS url for you repo.                          	|
| branch         	| Optional  	| The branch you want to clone.                           	|
| localDirectory 	| Optional  	| Which directory would you want DEV.env clone your repo? 	|
| setupCommand   	| Optional  	| Your repo setup command.                                	|

###### Example of repositories.yml

The repositories YAML config can store multiple repositories in one config.

```yml
---
# List of repositories that DEV.env will setup.
enabled-repositories:
  - repository-one
  - repository-two
---
# Description
repository-one:
  gitUrl: git@github.com:username/repository-one.git
  branch: main
  localDirectory:
  setupCommand:
---
# Description
repository-two:
  gitUrl: git@github.com:username/repository-two.git
  branch: main
  localDirectory:
  setupCommand:

```

Once you have configured your git repositories in your repositories 
configuration file. You can run the `repos:setup` command in your projects 
root directory to allow ***DEV.env*** to automatically set up your repositories.

The `repos:setup` command provides two methods to set up repositories: setup 
all enabled repositories or set up an individual repository.

###### Enabled repositories

In your repositories YAML configuration file, you will have a collection node 
called `enabled-repositories`.

```yml
---
# List of repositories that DEV.env will setup.
enabled-repositories:
  - repository-one
  - repository-two
---

```

You can list the repositories in the enabled repositories collection node you 
want ***DEV.env*** to automatically set up. If the repository already exists 
in your local environment, ***DEV.env*** will skip the repository setup process.

Once you have run the `repos:setup` command, your projects root directory will 
be structured as follows:

```
.
+-- projects
|   +-- repository-one
|   +-- repository-two
|   +-- repositories.yml
```

###### Individual repository

The `repos:setup` command also accepts a repositories name as an argument.

```bash
$ dev repos:setup repository-name
```

#### 11. <ins>Check git repositories setup status</ins>

Although you are not required to use ***DEV.env*** to manage your development 
environment, ***DEV.env*** does offer a `repos:status` command to show a list 
in a table view of the setup status for each repository. Which is based on your 
repositories configuration file

```bash
$ dev repos:status
```

## FAQ

**Q:** Why shell-based development environment setup files?  
**A:** The configuration options and customization is limitless when you use 
CLI. You can install packages, download files, open URLs and orchestrate your 
setup progress to be interactive or completely a background process. 
shell-based setup files enable you to set up your development environment to 
your exact requirements.

**Q:** Can I used ***DEV.env*** to setup repositories from different 
organizations or profiles?  
**A:** Absolutely, you can create subdirectories for each organization or 
profile and publish your repositories YAML configuration files in each 
respective directory.

```bash
# Change directory
$ cd development

# Create your directories
$ mkdir organization-one organization-two personal

# Publish your configuration in each directory
$ for d in ./*/ ; do (cd "$d" && dev repos:publish "$(basename "$d")"); done

# Setup each organization/profile repositories
$ for d in ./*/ ; do (cd "$d" && dev repos:setup); done
```

Your organizations/profile directories will be structured as follows:

```
.
+-- organization-one
|   +-- repository-one
|   +-- repository-two
|   +-- repositories.yml
+-- organization-two
|   +-- repository-one
|   +-- repository-two
|   +-- repository-three
|   +-- repositories.yml
+-- personal
|   +-- website
|   +-- repositories.yml
```

**Q:** Are you able to share your development environment setup files?  
**A:** I plan to provide setup templates which will provide developers a 
starting point. Each developer has their personal preference and I want 
***DEV.env*** to be a lightweight tool without having collection of 
unnecessary setup files.

## Useful Tips

The objective of this project is to provide an ecosystem of tools to improve 
the onboarding experience for developers. Below are a few tools my development 
team and I use and recommend.

[Fig](https://withfig.com/) is a CLI tool that adds VSCode-style autocomplete 
to your existing Terminal. You can build autocomplete functionality for any CLI 
with javascript, not bash. You can share it with your team, or contribute to 
Fig open source specs for tools like `git`, `aws`, `kubectl`.

[Raycast](https://raycast.com/) lets you control your tools with a few 
keystrokes. It's designed to keep you focused. Provides built-in extensions to 
connect with common tools like `Asana`, `GitHub`, `Jira`, `Linear`, `Zoom`. 
Write scripts in your favorite programming language to connect to web APIs or 
control other tools.

[Swimm](https://swimm.io/) keeps development smooth with smart docs that are 
always synced with your code. Never let onboarding, outdated documents, or 
project switching slow you down. Swimm allows you to create walkthroughs or 
hands-on tasks to demonstrate patterns and logic. Create tailored onboarding 
plans per team or specific new hire.

[VS Code](https://code.visualstudio.com/) makes it easier to automate and 
configure VS Code, it is possible to list, install, and uninstall extensions 
from the command line. This is a great feature if you want to use ***DEV.env*** 
to include your VS Code set up part of your development environment set up. You 
can learn more about command-line extension management in 
[VS Code user guide](https://code.visualstudio.com/docs/editor/extension-gallery#_command-line-extension-management).

[Awesome Compose](https://github.com/docker/awesome-compose) is curated list of 
Docker Compose samples that provide a starting point for how to integrate 
different services using a Compose file and to manage their deployment with 
Docker Compose.

**Please note:** The following Awesome Compose samples are intended for use in 
local development environments such as project setups, tinkering with software 
stacks, etc. These samples must not be deployed in production environments.

[Localhost SonarQube](https://github.com/luisaveiro/localhost-sonarqube) offers 
a light-weight command-line interface for interacting with 
[SonarQube](https://www.sonarqube.org/) *Community Edition* and analyse your 
source code with SonarScanner (*CLI*) in a Docker environment. 

[free-for.dev](https://free-for.dev) A list of SaaS, PaaS and IaaS offerings 
that have free tiers of interest to devops and infradev.

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information what has changed recently.

## Roadmap

Please see the [Public Roadmap](https://github.com/luisaveiro/dev.env/projects/1)
where you can learn about what features we're working on, what stage they're 
in, and when we expect to bring them to you.

## Contributing

I encourage you to contribute to ***DEV.env***! Contributions are what make the 
open source community such an amazing place to be learn, inspire, and create. 
Any contributions you make are **greatly appreciated**.

Please check out the [contributing to DEV.env guide](.github/CONTRIBUTING.md) 
for guidelines about how to proceed.

## Security Vulnerabilities

Trying to report a possible security vulnerability in ***DEV.env***? Please 
check out our [security policy](.github/SECURITY.md) for guidelines about how 
to proceed.

## Credits

The illustration used in the project is from 
[unDraw (created by Katerina Limpitsouni)](https://undraw.co/). All product 
names, logos, brands, trademarks and registered trademarks are property of 
their respective owners.

This software uses the following open source packages:

- [ANSI Code Generator](https://github.com/fidian/ansi)
- [bash-yaml](https://github.com/jasperes/bash-yaml)

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.

---

<p align="center">
  <a href="http://github.com/luisaveiro" target="_blank">GitHub</a> •
  <a href="https://uk.linkedin.com/in/luisaveiro" target="_blank">LinkedIn</a> •
  <a href="https://twitter.com/luisdeaveiro" target="_blank">Twitter</a>
</p>
