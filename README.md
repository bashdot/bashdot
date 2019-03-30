[![CircleCI](https://circleci.com/gh/bashdot/bashdot/tree/master.svg?style=svg)](https://circleci.com/gh/bashdot/bashdot/tree/master)

# Summary

I am **bashdot**, a minimalist dotfile management framework with support for 
multiple profiles and templates.

I am a [single script](https://github.com/bashdot/bashdot/blob/master/bashdot), written
**entirely in bash**, which requires **no additional dependencies**.

The authors of bashdot focus on transparency in the code, providing
clear log output and heavily [testing](https://circleci.com/gh/bashdot/bashdot/tree/master)
the script using [bats](https://github.com/sstephenson/bats).

## Overview

Bashdot works by symlinking all files and directions in a given profile
directory, within the current directory where bashdot is run, to files
in the users home.

One or more profiles can be installed on a specific computer to provide
the desired dotfiles for it's purpose (work, home, etc.), operating
system (Linux, MacOS, Solaris, etc.) and version (Debian, RedHat, etc.).

Using a combinations of profiles, you can remove conditional logic from your bash
scripts. For example, create a Linux profile for Linux specific commands or
aliases, or an operations profile for those specific to the operations
organization. Only install what you need on a given system.

Bashdot supports templates for replacing values in files during installation.

## Quick Start

1. Install Bashdot

    MacOS Homebrew

    ```sh
    brew tap bashdot/tap
    brew install bashdot
    ```

    Manual Installation

    ```sh
    curl -s https://raw.githubusercontent.com/bashdot/bashdot/4.1.0/bashdot > bashdot
    sudo mv bashdot /usr/local/bin
    sudo chmod a+x /usr/local/bin/bashdot
    ```

1. Clone the **bashdot_profiles** starter repo

    ```sh
    git clone https://github.com/bashdot/bashdot_profiles
    ```

1. Change into the bashdot_profiles directory and run the below command to setup the
**default** and **home** profiles on this instance.

    ```sh
    cd bashdot_profiles
    bashdot install default home
    ```

1. Update the directory with your dotfiles, check it into source or store it in a cloud drive.

## Templates

If you have values which need to be set in a file when bashdot is run, you can create a template.

1. Append **.template** to any files which should be rendered.  Template files will have
all variables replaced with the current environment variables when bashdot is run.

1. The rendered files names will have **.template** replaced with **.rendered** and be created
in the same directory.

1. For example:

    If you have the file **profiles/home/env.template** with the below contents:

    ```sh
    export SECRET_KEY=$ENV_SECRET_KEY
    ```

    You can run the following to set the value **ENV_SECRET_KEY** when installing the home profile:

    ```sh
    env ENV_SECRET_KEY=test1234 bashdot install home
    ```

    This will result in the following rendered file as **profiles/home/env.rendered** and symlinkd to **~/.env**

    ```sh
    env SECRET_KEY=test1234
    ```

1. These files will then be symlinked into your home directory like any other bashdot managed file.

1. Rendered files **will be removed** when you uninstall their respective bashdot profile.

1. Be sure to include **\*\*/\*.rendered** in **.gitignore** if you will be checking your dotfiles
into a Git repo.

## Managing Multiple Profiles

Bashdot works by symlinking files within the given profile directory into your home directory.

For example, if you run:

```sh
bashdot install default work
```

Bashdot will symlink all the files in the default and work into your home directory
while prepending a period (prepending a period prevents all files from being hidden in
the source directory).

When run in the [starter repo](https://github.com/bashdot/bashdot_profiles), the above command
would create the following symlinks:

```sh
lrwxrwxrwx 1 brett brett   28 Mar  8 09:03 .bashrc -> /brett/bashdot/profiles/default/bashrc
lrwxrwxrwx 1 brett brett   40 Mar  8 09:03 .profilerc_work -> /brett/bashdot/profiles/work/profilerc_work
```

You can then make changes to files in the **default** or **work** profiles, or
add additional profiles as necessary. Re-run bashdot install to link any newly
created files or directories.

Since the files are symlinked into your home directory, if you keep the bashdot directory
on a shared drive, changes to files on one instance will automatically be reflected on all
instances with that profile installed.

## Frequently Asked Questions

**Q:** What if I have secrets or other private information to install in my dotfile?

**A:** Never check in sensitive information in your dotfiles. To remove sensitive information,
either a) pull that information from an external system b) encrypt it and read the decryption
key from a location not in your dotfiles or c) leverage templates (described above). See
[here](https://gist.github.com/bashdot/f3af28350f07176674a5474b2d891102) for examples.

**Q:** How can I share my bashdot profiles?

**A:** Bashdot only manages dotfiles installation, not their distribution. To share your
bashdot profile, make it available via source control or a file share.

For example to install the public profiles from a Git repo:

```sh
git clone https://github.com/bashdot/bashdot_public_profile
bashdot install bashdot_public_profile
```

**Q:** Does bashdot work with zsh, fish or other shells?

**A:** Yes. Bashdot works by using standard unix commands and symlinks. It should work 
with any shell on a system that has bash installed.

**Q:** If bashdot supports other shells, why is it called bashdot?

**A:** It is a 100% self contained bash script with no dependencies.

## Bashdot Development

### Test

Only requirement to run tests is [docker](https://docs.docker.com/install/). Once installed run:

```sh
make test
```

### Shell

To shell into a container to test bashdot without affecting your local environment run:

```
make shell
```

### Debug

To increase logging, set the **BASHDOT_LOG_LEVEL** environment variable to **debug**.

```
export BASHDOT_LOG_LEVEL=debug
```
