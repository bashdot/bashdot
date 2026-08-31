#!/usr/bin/env bats

setup() {
  /bin/rm -rf ~/.bashrc ~/.profile ~/.profilerc* ~/.bashdot another ~/.test ~/.env \
    ~/.cmd ~/.special ~/.braced ~/.prefix \
    /home/circleci/rendered/env.rendered \
    /home/circleci/secure/*.rendered \
    /tmp/bashdot-pwned-cmd /tmp/bashdot-pwned-bt /tmp/bashdot-pwned-eof /tmp/bashdot-pwned-val \
    /tmp/bashdot-empty /tmp/invalid,name /tmp/default /tmp/another \
    /tmp/profile_with_invalid1 /tmp/profile_with_invalid2 /tmp/profile_with_invalid3 \
    /home/circleci/.dotfiles
}

@test "general help" {
  run bashdot
  [ "$output" == "Usage: bashdot [dir|install|links|profiles|uninstall|version] OPTIONS" ]
  [ $status = 1 ]
}

@test "install help" {
  run bashdot install
  [ "$output" == "Usage: bashdot install PROFILE1 PROFILE2 ... PROFILEN" ]
  [ $status = 1 ]
}

@test "uninstall help" {
  run bashdot uninstall
  [ "$output" == "Usage: bashdot uninstall PROFILE_DIRECTORY PROFILE" ]
  [ $status = 1 ]
}

@test "error invalid profile name" {
  run bashdot install test,test
  echo $output | grep "Invalid profile name 'test,test'. Profiles must be alpha numeric with only dashes or underscores."
  [ $status = 1 ]
}

@test "error profile does not exist" {
  mkdir -p /tmp/bashdot-empty
  cd /tmp/bashdot-empty
  run bashdot install default
  echo $output | grep "Profile 'default' directory does not exist."
  [ $status = 1 ]
}

@test "error uninstall when no bashdot profiles installed" {
  run bashdot uninstall /home/circleci test
  echo $output | grep "Config file '$HOME/.bashdot' not found."
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 1 ]
}

@test "error uninstall profiles does not exist" {
  cd /home/circleci
  bashdot install default
  run bashdot uninstall /home/circleci test
  echo $output | grep "Profile 'test' not installed from '/home/circleci'."
  [ $status = 1 ]
}

@test "error uninstall directory does not exist" {
  cd /home/circleci
  bashdot install default
  run bashdot uninstall /boom default
  echo $output | grep "Profile 'default' not installed from '/boom'."
  [ $status = 1 ]
}

@test "error file already exists on install" {
  touch ~/.bashrc
  mkdir -p default
  touch default/bashrc
  run bashdot install default
  echo $output | grep "File '/home/circleci/.bashrc' already exists, exiting."
  [ $status = 1 ]
}

@test "error file already in another profile" {
  cd /home/circleci
  bashdot install default

  mkdir -p another
  touch another/bashrc
  run bashdot install another
  [ $status = 1 ]
}

@test "error installing template without variables set" {
  cd /home/circleci
  unset APP_SECRET_KEY
  run bashdot install rendered
  echo $output | grep "Variable 'APP_SECRET_KEY' is unset in template '/home/circleci/rendered/env.template'."
  [ $status = 1 ]

  run test -e /home/circleci/.env
  [ $status = 1 ]

  run test -e /home/circleci/rendered/env.rendered
  [ $status = 1 ]
}

@test "error file already exists on template install" {
  touch ~/.env
  cd /home/circleci
  run env APP_SECRET_KEY=test1234 bashdot install rendered
  echo $output | grep "File '/home/circleci/.env' already exists, exiting."
  [ $status = 1 ]
}

@test "error installing from invalid current working directory" {
  mkdir /tmp/invalid,name
  cp -r /home/circleci/default /tmp/invalid,name
  cd /tmp/invalid,name
  run bashdot install default
  [ $status = 1 ]

  echo $output | grep "Current working directory '/tmp/invalid,name' has an invalid character. The directory you are in when you install a profile must have alpha numeric characters, with only dashes, dots or underscores."
}

@test "error if profiles directories files contain invalid characters" {
  cd /tmp
  mkdir -p profile_with_invalid1/invalid\ name
  mkdir -p profile_with_invalid2/invalid\\name
  mkdir -p profile_with_invalid3/invalid:name

  run bashdot install profile_with_invalid1
  echo $output |grep "Files in '/tmp/profile_with_invalid1' contain invalid characters."
  [ $status = 1 ]

  run bashdot install profile_with_invalid2
  echo $output |grep "Files in '/tmp/profile_with_invalid2' contain invalid characters."
  [ $status = 1 ]

  run bashdot install profile_with_invalid3
  echo $output |grep "Files in '/tmp/profile_with_invalid3' contain invalid characters."
  [ $status = 1 ]
}

@test "install" {
  cd /home/circleci
  run bashdot install default work
  echo $output | grep "Completed installation of all profiles successfully."
  [ $status = 0 ]
}

@test "install from directory with leading ." {
  cd /home/circleci
  mkdir .dotfiles
  cp -r default .dotfiles
  cp -r work .dotfiles
  cd .dotfiles
  run bashdot install default work
  echo $output | grep "Completed installation of all profiles successfully."
  [ $status = 0 ]
}

@test "installing rendered template file" {
  cd /home/circleci
  run env APP_SECRET_KEY=test1234 bashdot install rendered
  echo $output | grep "Completed installation of all profiles successfully."
  cat /home/circleci/.env | grep 'export APP_SECRET_KEY=test1234'

  run sum /home/circleci/.env
  echo $output | grep '58480'
}

@test "template command substitution and backticks are not executed" {
  cd /home/circleci
  run env SAFE_VAR=ok FOO=one FOOBAR=two BRACED_SECRET=braced123 SPECIAL_VAL=plain \
    bashdot install secure
  echo $output | grep "Completed installation of all profiles successfully."
  [ $status = 0 ]

  run test -e /tmp/bashdot-pwned-cmd
  [ $status = 1 ]

  run test -e /tmp/bashdot-pwned-bt
  [ $status = 1 ]

  grep -F 'payload=$(touch /tmp/bashdot-pwned-cmd)' /home/circleci/.cmd
  grep -F 'ticks=`touch /tmp/bashdot-pwned-bt`' /home/circleci/.cmd
  grep -F 'arith=$((1+2))' /home/circleci/.cmd
  grep -F 'safe=ok' /home/circleci/.cmd
}

@test "template braced variables are substituted" {
  cd /home/circleci
  run env SAFE_VAR=ok FOO=one FOOBAR=two BRACED_SECRET=braced123 SPECIAL_VAL=plain \
    bashdot install secure
  [ $status = 0 ]
  grep -F 'export KEY=braced123' /home/circleci/.braced
}

@test "template prefix variables do not clobber longer names" {
  cd /home/circleci
  run env SAFE_VAR=ok FOO=one FOOBAR=two BRACED_SECRET=braced123 SPECIAL_VAL=plain \
    bashdot install secure
  [ $status = 0 ]
  [ "$(cat /home/circleci/.prefix)" = $'FOO=one\nFOOBAR=two' ]
}

@test "template values are not re-expanded or executed" {
  cd /home/circleci
  export SAFE_VAR=ok
  export FOO=one
  export FOOBAR=two
  export BRACED_SECRET=braced123
  export SPECIAL_VAL=$'line1\nEOF\n$(touch /tmp/bashdot-pwned-eof)\n`touch /tmp/bashdot-pwned-val`\n$HOME'
  run bashdot install secure
  [ $status = 0 ]

  run test -e /tmp/bashdot-pwned-eof
  [ $status = 1 ]

  run test -e /tmp/bashdot-pwned-val
  [ $status = 1 ]

  grep -F '$(touch /tmp/bashdot-pwned-eof)' /home/circleci/.special
  grep -F '`touch /tmp/bashdot-pwned-val`' /home/circleci/.special
  grep -F '$HOME' /home/circleci/.special
  grep -F 'after=ok' /home/circleci/.special
}

@test "install suceeds when profile already installed from another directory" {
  cd /home/circleci
  bashdot install default

  cd /tmp
  mkdir -p default
  touch default/test
  run bashdot install default
  [ $status = 0 ]
}

@test "install bashdot profiles from another directory" {
  cd /home/circleci
  bashdot install default work

  cd /tmp
  mkdir another
  touch another/test

  run bashdot install another
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci default" ]
  [ "${lines[1]}" == "/home/circleci work" ]
  [ "${lines[2]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/home/circleci" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot links
  echo "$output"
  [ "${lines[0]}" == "~/.bashrc -> /home/circleci/default/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /home/circleci/work/profilerc_work" ]
  [ "${lines[2]}" == "~/.test -> /tmp/another/test" ]
  [ $status = 0 ]
}

@test "install multiple profiles in directories with the same leading prefix" {
  cd /home/circleci
  bashdot install default work
  cd /home/circleci/another_test
  bashdot install home

  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci/another_test home" ]
  [ "${lines[1]}" == "/home/circleci default" ]
  [ "${lines[2]}" == "/home/circleci work" ]

  bashdot uninstall /home/circleci work
  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci/another_test home" ]
  [ "${lines[1]}" == "/home/circleci default" ]
}

@test "validate ignored files not symlinked" {
  cd /home/circleci
  bashdot install default work home

  run test -e /home/circleci/.bashrc
  [ $status = 0 ]

  run test -e /home/circleci/.profilerc_work
  [ $status = 0 ]

  run test -e /home/circleci/.profilerc_home
  [ $status = 0 ]

  run test -e /home/circleci/.README.md
  [ $status != 0 ]

  run test -e /home/circleci/.CHANGELOG.txt
  [ $status != 0 ]
}

@test "re-install" {
  cd /home/circleci
  bashdot install default work
  run bashdot install default work
  [ $status = 0 ]
}

@test "list profiles" {
  cd /home/circleci
  bashdot install default work
  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci default" ]
  [ "${lines[1]}" == "/home/circleci work" ]
  [ $status = 0 ]
}

@test "list profiles with only rendered template in home directory" {
  cd /home/circleci
  run env APP_SECRET_KEY=test1234 bashdot install rendered
  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci rendered" ]
  [ $status = 0 ]
}

@test "links" {
  cd /home/circleci
  bashdot install default work
  run bashdot links
  [ "${lines[0]}" == "~/.bashrc -> /home/circleci/default/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /home/circleci/work/profilerc_work" ]
  [ $status = 0 ]
}

@test "dir" {
  cd /home/circleci
  bashdot install default work
  run bashdot dir
  [ "${lines[0]}" == "/home/circleci" ]
  [ $status = 0 ]
}

@test "profiles when no dotfiles installed" {
  run bashdot profiles
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]
}

@test "dir no dotfiles installed" {
  run bashdot dir
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]
}

@test "version" {
  version=$(grep ^VERSION /usr/bin/bashdot |cut -d\= -f2)
  run bashdot version
  [ "$output" == "$version" ]
  [ $status = 0 ]
}

@test "profilerc is sourced" {
  cd /home/circleci
  bashdot install default work
  . ~/.bashrc
  [ "$HOME_VAR" == "" ]
  [ "$WORK_VAR" == "123" ]

  bashdot install home
  . ~/.bashrc
  [ "$HOME_VAR" == "abc" ]
}

@test "uninstall" {
  cd /home/circleci
  bashdot install default work

  run bashdot dir
  [ "$output" == "/home/circleci" ]
  [ $status = 0 ]

  run bashdot uninstall /home/circleci default
  [ $status = 0 ]

  run bashdot uninstall /home/circleci work
  [ $status = 0 ]

  run bashdot profiles
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]

  run bashdot dir
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]
}

@test "uninstall multiple directories" {
  cd /home/circleci
  bashdot install default work

  cd /tmp
  mkdir -p another
  touch another/test
  bashdot install another

  run bashdot dir
  [ "${lines[0]}" == "/home/circleci" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /home/circleci work
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci default" ]
  [ "${lines[1]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/home/circleci" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /tmp another
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/home/circleci default" ]
  [ "${lines[1]}" == "" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/home/circleci" ]
  [ $status = 0 ]

  run bashdot uninstall /home/circleci default
  [ $status = 0 ]

  run bashdot profiles
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]

  run bashdot dir
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]

  run test -f ~/.bashdot
  [ $status = 1 ]
}

@test "uninstall rendered file" {
  run test -f /home/circleci/.env
  [ $status = 1 ]

  run test -f /home/circleci/rendered/env.rendered
  [ $status = 1 ]

  cd /home/circleci
  env APP_SECRET_KEY=test1234 bashdot install rendered

  run test -f /home/circleci/.env
  [ $status = 0 ]

  run test -f /home/circleci/rendered/env.rendered
  [ $status = 0 ]

  bashdot uninstall /home/circleci rendered

  run test -f /home/circleci/.env
  [ $status = 1 ]

  run test -f /home/circleci/rendered/env.rendered
  [ $status = 1 ]
}
