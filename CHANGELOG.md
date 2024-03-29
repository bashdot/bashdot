# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [4.1.7] - 2023-01-18
### Changed
- Shellcheck fixes (Thanks @vincentqb)

## [4.1.6] - 2022-08-22
### Changed
- Refactor test to run as non root
- Update build image and fixed ci
- Typos / comments (Thanks @vincentqb)

## [4.1.5] - 2021-11-22
### Changed
- Address shellcheck SC2196 and SC2181

## [4.1.4] - 2021-03-20
### Changed
- Applied shellcheck fixable 

## [4.1.3] - 2019-06-15
### Changed
- Bug fix adding quotes to some variables 

## [4.1.2] - 2019-04-10
### Changed
- Bug fix when removing rendered templates

## [4.1.1] - 2019-04-09
### Changed
- Support dotfiles directories with . (~/.dotfiles)

## [4.1.0] - 2019-03-30
### Changed
- Updated ignore files
- Error if varialbles are not set in rendered template

## [4.0.1] - 2019-03-28
### Changed
- Add ignored files

## [4.0.0] - 2019-03-28
### Changed
- Removed requirement for profiles directory

## [3.0.0] - 2019-03-26
### Added
- Template support

## [2.1.0] - 2019-03-25
### Changed
- Check for valid profile name
- Switch to log output
- Bug fix installing multiple profiles with similiar path prefixes

## [2.0.0] - 2019-03-09
### Changed
- Renamed shared profile to default
- Renamed ls to profiles
- Added links
- Refactored to support profiles from multiple directories
- Uninstall required directory and profile to uninstall

## [1.0.0] - 2019-03-09
### Added
- Initial Release
