#!/usr/bin/env bats

setup() {
  /bin/rm -rf ~/.bashrc ~/.profile ~/.profilerc* ~/.bashdot profiles/another ~/.test
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

@test "error profiles does not exist" {
  cd /tmp
  run bashdot install shared
  [ "$output" == "Directory profiles does not exist in '/tmp'." ]
  [ $status = 1 ]
}

@test "error profile does not exist" {
  mkdir profiles
  run bashdot install shared
  [ "$output" == "Profile 'shared' directory does not exist." ]
  [ $status = 1 ]
}

@test "error no bashdot profiles installed" {
  run bashdot uninstall /root test
  [ "$output" == "No '.bashdot' file in ~." ]
  [ $status = 1 ]
}

@test "error file already exists on install" {
  touch ~/.bashrc
  mkdir -p profiles/shared
  touch profiles/shared/bashrc
  run bashdot install shared
  [ "${lines[2]}" == "File '.bashrc' already exists, exiting." ]
  [ $status = 1 ]
}

@test "error file already in another profile" {
  cd /root
  bashdot install shared

  mkdir -p profiles/another
  touch profiles/another/bashrc
  run bashdot install another
  [ $status = 1 ]
}

@test "install" {
  cd /root
  run bashdot install shared work
  [ "${lines[12]}" == "Completed installation of all profiles succesfully." ]
  [ $status = 0 ]
}

@test "install suceeds when profile already installed from another directory" {
  cd /root
  bashdot install shared

  cd /tmp
  mkdir -p profiles/shared
  touch profiles/shared/test
  run bashdot install shared
  [ $status = 0 ]
}

@test "install bashdot profiles from another directory" {
  cd /root
  bashdot install shared work

  cd /tmp
  mkdir -p profiles/another
  touch profiles/another/test

  run bashdot install another
  [ $status = 0 ]

  run bashdot profiles
  echo "BOOM: $output"
  [ "${lines[0]}" == "/root shared" ]
  [ "${lines[1]}" == "/root work" ]
  [ "${lines[2]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot links
  echo "$output"
  [ "${lines[0]}" == "~/.bashrc -> /root/profiles/shared/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /root/profiles/work/profilerc_work" ]
  [ "${lines[2]}" == "~/.test -> /tmp/profiles/another/test" ]
  [ $status = 0 ]
}

@test "validate ignored files not symlinked" {
  cd /root
  bashdot install shared work home

  run test -e /root/.bashrc
  [ $status = 0 ]

  run test -e /root/.profilerc_work
  [ $status = 0 ]

  run test -e /root/.profilerc_home
  [ $status = 0 ]

  run test -e /root/.README.md
  [ $status != 0 ]
}

@test "re-install" {
  cd /root
  bashdot install shared work
  run bashdot install shared work
  [ $status = 0 ]
}

@test "profiles" {
  cd /root
  bashdot install shared work
  run bashdot profiles
  [ "${lines[0]}" == "/root shared" ]
  [ "${lines[1]}" == "/root work" ]
  [ $status = 0 ]
}

@test "links" {
  cd /root
  bashdot install shared work
  run bashdot links
  [ "${lines[0]}" == "~/.bashrc -> /root/profiles/shared/bashrc" ]
  [ "${lines[1]}" == "~/.profilerc_work -> /root/profiles/work/profilerc_work" ]
  [ $status = 0 ]
}

@test "dir" {
  cd /root
  bashdot install shared work
  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ $status = 0 ]
}

@test "profiles when no dotfiles installed" {
  run bashdot profiles
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}

@test "dir no dotfiles installed" {
  run bashdot dir
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}

@test "version" {
  run bashdot version
  [ "$output" == "2.0.0" ]
  [ $status = 0 ]
}

@test "profilerc is sourced" {
  cd /root
  bashdot install shared work
  . ~/.bashrc
  [ "$HOME_VAR" == "" ]
  [ "$WORK_VAR" == "123" ]

  bashdot install home
  . ~/.bashrc
  [ "$HOME_VAR" == "abc" ]
}

@test "uninstall" {
  cd /root
  bashdot install shared work

  run bashdot dir
  [ "$output" == "/root" ]
  [ $status = 0 ]

  run bashdot uninstall /root shared
  [ $status = 0 ]

  run bashdot uninstall /root work
  [ $status = 0 ]

  run bashdot profiles
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]

  run bashdot dir
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}

@test "uninstall multiple directories" {
  cd /root
  bashdot install shared work

  cd /tmp
  mkdir -p profiles/another
  touch profiles/another/test
  bashdot install another

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /root work
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/root shared" ]
  [ "${lines[1]}" == "/tmp another" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ "${lines[1]}" == "/tmp" ]
  [ $status = 0 ]

  run bashdot uninstall /tmp another
  [ $status = 0 ]

  run bashdot profiles
  [ "${lines[0]}" == "/root shared" ]
  [ "${lines[1]}" == "" ]
  [ $status = 0 ]

  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ $status = 0 ]

  run bashdot uninstall /root shared
  [ $status = 0 ]

  run bashdot profiles
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]

  run bashdot dir
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]

  run test -f ~/.bashdot
  [ $status = 1 ]
}
