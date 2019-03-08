# dotfiler

I manage dotfiles with support for multiple profiles with differing configurations based
on the specific environment.

## Overview

Dotfiler works by symlinking all files and directions in **profiles** within the current
work directory to the users home.

One or more profiles can be installed on a specific computer to provide
the desired dotfiles for it's purpose (work, home, public, etc.).

# Usage

To setup your own dotfiler manage dotfiles, fork this repo to your account, then
clone down your fork of the repo (you can clone into Dropbox or Google Drive to sync
across multiple systems) and run the following to link the dotfiles for both
the public and private profiles on this instance.

```
bash dotfiler install public private
```

This will symlink all the files in the given profile directories into your home directory
prepending a ".".

For example the above would create the following:

```
lrwxrwxrwx 1 brett brett   28 Mar  8 09:03 .bashrc -> /brett/dotfiler/profiles/public/bashrc
lrwxrwxrwx 1 brett brett   40 Mar  8 09:03 .profilerc_private -> /brett/dotfiler/profiles/private/profilerc_private
lrwxrwxrwx 1 brett brett   38 Mar  8 09:03 .profilerc_public -> /brett/dotfiler/profiles/public/profilerc_public
```

You can then make changes to files in the **public** or **private** profiles, or
add additional profiles as necessary.  If you use different files in different
environments you can create a profile for each with the appropriate dotfiles.

Since the files are symlinked from home, If you keep the files in a shared
drive, changes to files on one instance will automatically be reflected on all
instances with that profile installed.

The default **.bashrc** will load anything in file prepended with **profilerc** to
allow for doing any specific setup for the a profile. See
[profiles](https://github.com/weavenet/dotfiler/tree/master/profiles)
for exmaples of profiles with different variables initialized.

## Development

### Pre-reqs

* Docker

### Test

```
make test
```
