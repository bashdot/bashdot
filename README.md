[![CircleCI](https://circleci.com/gh/weavenet/dotfiler/tree/master.svg?style=svg)](https://circleci.com/gh/weavenet/dotfiler/tree/master)

# Summary

I am **dotfiler**.

I am a dotfile management framework with support for multiple profiles, providing different configurations for different environments.

I am written **100% in bash** and heavily [tested](https://circleci.com/gh/weavenet/dotfiler/tree/master).

## Overview

Dotfiler works by symlinking all files and directions in **profiles** within the current
work directory to the users home.

One or more profiles can be installed on a specific computer to provide
the desired dotfiles for it's purpose (work, home, shared, public, etc.).

## Quick Start

To setup your own dotfiler managed dotfiles:

* Fork this repo to your account
* Clone down your fork of the repo (you can clone into Dropbox or Google Drive to sync
across multiple systems) 
* Run the following to setup the dotfiles for the **public** profiles on this instance.

```
bash dotfiler install public
```

## Managing Multiple Profiles

Dotfiler works by symlinking files within the given profile directory into your home directory.

For example, if you run:

```
bash dotfiler install public private
```

Dotfiler will symlink all the files in the public and private directories within profiles
into your home directory while prepending a "period".

The above command would create the following symlinks:

```
lrwxrwxrwx 1 brett brett   28 Mar  8 09:03 .bashrc -> /brett/dotfiler/profiles/public/bashrc
lrwxrwxrwx 1 brett brett   40 Mar  8 09:03 .profilerc_private -> /brett/dotfiler/profiles/private/profilerc_private
lrwxrwxrwx 1 brett brett   38 Mar  8 09:03 .profilerc_public -> /brett/dotfiler/profiles/public/profilerc_public
```

You can then make changes to files in the **public** or **private** profiles, or
add additional profiles as necessary.  If you use different files in different
environments you can create a profile for each environment with the appropriate dotfiles.

Since the files are symlinked from home, If you keep the files in a shared
drive, changes to files on one instance will automatically be reflected on all
instances with that profile installed.

The default **.bashrc** will load anything in file prepended with **profilerc** to
allow for doing any specific setup for the a profile. See
[profiles](https://github.com/weavenet/dotfiler/tree/master/profiles)
for exmaples of profiles with different variables initialized.

## Dotfiler Development

### Pre-reqs

* Docker

### Test

```
make test
```
