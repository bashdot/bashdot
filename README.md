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

Bashdot works by symlinking files and directions, in a given profile, into the
users home directory.

One or more profiles can be installed on a specific instance to provide
the desired dotfiles for it's purpose (work, home, etc.), operating
system (Linux, MacOS, Solaris, etc.) and version (Debian, RedHat, etc.).

Bashdot supports templates for replacing values in files during installation.

## Install

MacOS Homebrew

```sh
brew tap bashdot/tap
brew install bashdot
```

Manual Installation

```sh
curl -s https://raw.githubusercontent.com/bashdot/bashdot/master/bashdot > bashdot
sudo mv bashdot /usr/local/bin
sudo chmod a+x /usr/local/bin/bashdot
```

## Quick Start

1. Create your initial profile directory, in this example, default. Add any files you would
like symlinked into your home directory when this profile is installed:

    ```sh
    mkdir default
    echo 'set -o vi' > default/env
    ```

1. Install the profile.

    ```sh
    bashdot install default
    ```
    Note, when you run install, bashdot **prepends a dot**, in front of the filename, to the linked file.

    In the above, **default/env** will now be linked to **~/.env**.

1. Continue adding your dotfiles to the default profile.

   ```sh
   mv ~/.bashrc default/bashrc
   ```

1. You can safely re-run ```bashdot install default``` to link newly added files. Store this directory in
a cloud drive or source control. Repeat for additional profiles.

## Templates

If you have values which need to be set in a file when bashdot is run, you can create a template.

1. Append **.template** to any files which should be rendered.

1. When installed, template files will have all variables replaced with the current
environment variables set when bashdot is run.

1. The rendered files will be created in the same directory, and have **.template** replaced
with **.rendered**.

1. For example:

    If you have the file **default/env.template** with the below contents:

    ```sh
    export SECRET_KEY=$ENV_SECRET_KEY
    ```

    You can run the following to set the value **ENV_SECRET_KEY** when installing the home profile:

    ```sh
    env ENV_SECRET_KEY=test1234 bashdot install default
    ```

    This will result in the rendered file **default/env.rendered** being created and symlinkd to **~/.env** with the below contents..

    ```sh
    export SECRET_KEY=test1234
    ```

1. Rendered files **will be removed** when you uninstall their respective bashdot profile.

1. Be sure to include **\*\*/\*.rendered** in **.gitignore** if you will be checking your dotfiles
into a Git repo.

## Managing Multiple Profiles

Bashdot works by symlinking files within the given profile directory into your home directory.

For example, if you run:

```sh
bashdot install default work
```

Bashdot will symlink all the files in default and work into your home directory.

Profiles installed on the same system must not contain overlapping files.

## Frequently Asked Questions

**Q:** How do I set secrets or private information in my dotfiles?

**A:** Never store secrets in your dotfiles. To remove sensitive information, create
a bashdot [template](https://github.com/bashdot/bashdot#templates) and
replace sensitive information with variables. This will prompt for the sensitive information to be
provided when you run bashdot install.

**Q:** How do I manage directories with bashdot, when only some of the contents, of that
directory, should be in source control? For example **.config** or **.ssh**?

**A:** Bashdot does not provide any functionality past symlinking into the top level of
home directory. To manage the contents of any directories symlinked by bashdot, we recommend
you add the directory and then ignore the appropriate files from your source
control (For example with [**.gitignore**](https://git-scm.com/docs/gitignore)).

**Q:** How can I share my bashdot profiles?

**A:** Bashdot only manages dotfiles installation, not their distribution. To share your
bashdot profile, make it available via source control, shared file system or cloud drive.

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
