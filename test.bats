#!/usr/bin/env bats

setup() {
  /bin/rm -rf ~/.bashrc ~/.profile ~/.profilerc* ~/.bashdot another ~/.test ~/.env /root/rendered/env.rendered
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
  run bashdot install default
  echo $output | grep "Profile 'default' directory does not exist."
  [ $status = 1 ]
}

@test "error uninstall when no bashdot profiles installed" {
  run bashdot uninstall /root test
  echo $output | grep "Config file '$HOME/.bashdot' not found."
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 1 ]
}

@test "error uninstall profiles does not exist" {
  cd /root
  bashdot install default
  run bashdot uninstall /root test
  echo $output | grep "Profile 'test' not installed from '/root'."
  [ $status = 1 ]
}

@test "error uninstall directory does not exist" {
  cd /root
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
  echo $output | grep "File '/root/.bashrc' already exists, exiting."
  [ $status = 1 ]
}

@test "error file already in another profile" {
  cd /root
  bashdot install default

  mkdir -p another
  touch another/bashrc
  run bashdot install another
  [ $status = 1 ]
}

@test "error installing template without variables set" {
  cd /root
  unset APP_SECRET_KEY
  run bashdot install rendered
  [ $status = 1 ]

  run test -e /root/.env
  [ $status = 1 ]
}

@test "error installing from invalid current working directory" {
  mkdir /tmp/invalid,name
  cp -r /root/default /tmp/invalid,name
  cd /tmp/invalid,name
  run bashdot install default
  [ $status = 1 ]

  echo $output | grep "Current working directory '/tmp/invalid,name' has an invalid character. The directory you are in when you install a profile must have alpha numberic characters, with only dashes, dots or underscores."
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
  cd /root
  run bashdot install default work
  echo $output | grep "Completed installation of all profiles succesfully."
  [ $status = 0 ]
}

@test "install from directory with leading ." {
  cd /root
  mkdir .dotfiles
  cp -r default .dotfiles
  cp -r work .dotfiles
  cd .dotfiles
  run bashdot install default work
  echo $output | grep "Completed installation of all profiles succesfully."
  [ $status = 0 ]
}

@test "installing rendered template file" {
  cd /root
  run env APP_SECRET_KEY=test1234 bashdot install rendered
  echo $output | grep "Completed installation of all profiles succesfully."
  cat /root/.env | grep 'export APP_SECRET_KEY=test1234'

  run sum /root/.env
  echo $output | grep '58480'
}

@test "install suceeds when profile already installed from another directory" {
  cd /root
  bashdot install default

  cd /tmp
  mkdir -p default
  touch default/test
  run bashdot install default
  [ $status = 0 ]
}

@test "install bashdot profiles from another directory" {
  cd /root
  bashdot install default work

  cd /tmp
  mkdir another
  touch another/test

  run bashdot install another
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "/root work" ]
  [ "${lines[2]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot links
  echo "$output"
  [ "${lines[0]}" == "~/.bashrc -> /root/default/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /root/work/profilerc_work" ]
  [ "${lines[2]}" == "~/.test -> /tmp/another/test" ]
  [ $status = 0 ]
}

@test "install multiple profiles in directories with the same leading prefix" {
  cd /root
  bashdot install default work
  cd /root/another_test
  bashdot install home

  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "/root work" ]
  [ "${lines[2]}" == "/root/another_test home" ]

  bashdot uninstall /root work
  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "/root/another_test home" ]
}

@test "validate ignored files not symlinked" {
  cd /root
  bashdot install default work home

  run test -e /root/.bashrc
  [ $status = 0 ]

  run test -e /root/.profilerc_work
  [ $status = 0 ]

  run test -e /root/.profilerc_home
  [ $status = 0 ]

  run test -e /root/.README.md
  [ $status != 0 ]

  run test -e /root/.CHANGELOG.txt
  [ $status != 0 ]
}

@test "re-install" {
  cd /root
  bashdot install default work
  run bashdot install default work
  [ $status = 0 ]
}

@test "list profiles" {
  cd /root
  bashdot install default work
  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "/root work" ]
  [ $status = 0 ]
}

@test "list profiles with only rendered template in home directory" {
  cd /root
  run env APP_SECRET_KEY=test1234 bashdot install rendered
  run bashdot profiles
  [ "${lines[0]}" == "/root rendered" ]
  [ $status = 0 ]
}

@test "links" {
  cd /root
  bashdot install default work
  run bashdot links
  [ "${lines[0]}" == "~/.bashrc -> /root/default/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /root/work/profilerc_work" ]
  [ $status = 0 ]
}

@test "dir" {
  cd /root
  bashdot install default work
  run bashdot dir
  [ "${lines[0]}" == "/root" ]
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
  run bashdot version
  [ "$output" == "4.1.3" ]
  [ $status = 0 ]
}

@test "profilerc is sourced" {
  cd /root
  bashdot install default work
  . ~/.bashrc
  [ "$HOME_VAR" == "" ]
  [ "$WORK_VAR" == "123" ]

  bashdot install home
  . ~/.bashrc
  [ "$HOME_VAR" == "abc" ]
}

@test "uninstall" {
  cd /root
  bashdot install default work

  run bashdot dir
  [ "$output" == "/root" ]
  [ $status = 0 ]

  run bashdot uninstall /root default
  [ $status = 0 ]

  run bashdot uninstall /root work
  [ $status = 0 ]

  run bashdot profiles
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]

  run bashdot dir
  echo $output | grep "No dotfiles installed by bashdot."
  [ $status = 0 ]
}

@test "uninstall multiple directories" {
  cd /root
  bashdot install default work

  cd /tmp
  mkdir -p another
  touch another/test
  bashdot install another

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /root work
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /tmp another
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/root default" ]
  [ "${lines[1]}" == "" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ $status = 0 ]

  run bashdot uninstall /root default
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
  run test -f /root/.env
  [ $status = 1 ]

  run test -f /root/rendered/env.rendered
  [ $status = 1 ]

  cd /root
  env APP_SECRET_KEY=test1234 bashdot install rendered

  run test -f /root/.env
  [ $status = 0 ]

  run test -f /root/rendered/env.rendered
  [ $status = 0 ]

  bashdot uninstall /root rendered

  run test -f /root/.env
  [ $status = 1 ]

  run test -f /root/rendered/env.rendered
  [ $status = 1 ]
}
