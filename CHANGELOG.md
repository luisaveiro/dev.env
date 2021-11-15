# Changelog
All notable changes to `luisaveiro/dev.env` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.4.0] - 2021-11-15
### Added
- `env:list` command to list of available setup files.

### Fixed
- `env:config` command from failing due to setup directory does not exist.

## [v0.3.2] - 2021-11-11
### Added
- free-for.dev to Useful Tips section.
- ShellCheck for Visual Studio Code
- ShellCheck Directive for variables in the printf format ([ShellCheck SC2059](https://github.com/koalaman/shellcheck/wiki/SC2059)).

### Fixed
- Problematic code for eval negates the benefit of arrays ([ShellCheck SC2294](https://github.com/koalaman/shellcheck/wiki/SC2294)).

## [v0.3.1] - 2021-06-01
### Added
- Awesome Compose & Raycast to Useful Tips section.

### Fixed
- Problematic code in the case of readonly ([ShellCheck SC2155](https://github.com/koalaman/shellcheck/wiki/SC2155)).

## [v0.3.0] - 2021-04-15
### Added
- Configuration functions for `repos` package.
### Changed
- `self-update` command git output to a throwaway variable.
- `git::fetch` function output to standard output and error.
- `repos:config` command accepts git repository as a remote configuration.

### Fixed
- Incorrect variable name for git remote config in `env::remote_configuration`.

## [v0.2.1] - 2021-04-15
### Added
- `git::fetch` function to `git` package.

### Fixed
- `self-update` command.

## [v0.2.0] - 2021-04-15
### Added
- Linux as supported OS.
- `file_extension` filesystem function.
- `symlink` filesystem function.
- `git::is_gist` function to `git` package to detect if git repository is GitHub Gist repository.
- Configuration functions for `env` package.

### Changed
- `is_file_remote` function uses own regex instead of `git::protocol` function.
- `env:config` command accepts git repository as a remote configuration.
- `env:config` command provides symbolic link to local configuration.

## [v0.1.1] - 2021-04-11
### Changed
- `env:setup` command accepts multiple arguments to support running multiple setup files.

## [v0.1.0] - 2021-04-10
### Added
- Initial project setup.
- Repositories YAML template file.
- Documentation for community profile.
