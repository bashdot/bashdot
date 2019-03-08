#!/usr/bin/env bats

teardown() {
  /bin/rm -rf ~/.bashrc ~/.profilerc* ~/.bashdot profiles/another
}

@test "general help" {
  run bashdot
  [ "$output" == "Usage: bashdot [dir|install|list|uninstall] OPTIONS" ]
  [ $status = 1 ]
}

@test "install help" {
  run bashdot install
  [ "$output" == "Usage: bashdot install PROFILE1 PROFILE2 ... PROFILEN" ]
  [ $status = 1 ]
}

@test "error profiles does not exist" {
  cd /tmp
  run bashdot install public
  [ "$output" == "Directory profiles does not exist in '/tmp'." ]
  [ $status = 1 ]
}

@test "error profile does not exist" {
  mkdir profiles
  run bashdot install public
  [ "$output" == "Profile 'public' directory does not exist." ]
  [ $status = 1 ]
}

@test "error no bashdot profiles installed" {
  run bashdot uninstall
  [ "$output" == "No '.bashdot' file in ~." ]
  [ $status = 1 ]
}

@test "error file already exists on install" {
  touch ~/.bashrc
  mkdir -p profiles/public
  touch profiles/public/bashrc
  run bashdot install public
  [ "${lines[2]}" == "File '.bashrc' already exists, exiting." ]
  [ $status = 1 ]
}

@test "error already installed" {
  cd /root
  bashdot install public
  cd /tmp
  mkdir -p profiles/public
  run bashdot install public
  [ $status = 1 ]
}

@test "error file already installed from another profile" {
  cd /root
  bashdot install public

  mkdir -p profiles/another
  touch profiles/another/bashrc
  run bashdot install another
  [ $status = 1 ]
}

@test "install" {
  cd /root
  run bashdot install public private
  [ "${lines[11]}" == "Completed installation of all profiles succesfully." ]
  [ $status = 0 ]
}

@test "validate ignored files not symlinked" {
  cd /root
  bashdot install public

  run test -e /root/.bashrc
  [ $status = 0 ]

  run test -e /root/.profilerc_public
  [ $status = 0 ]

  run test -e /root/.README.md
  [ $status != 0 ]
}

@test "re-install" {
  cd /root
  bashdot install public private
  run bashdot install public private
  [ $status = 0 ]
}

@test "ls" {
  cd /root
  bashdot install public private
  run bashdot list
  [ "${lines[0]}" == "private" ]
  [ "${lines[1]}" == "public" ]
  [ $status = 0 ]
}

@test "dir" {
  cd /root
  bashdot install public private
  run bashdot dir
  [ "${lines[0]}" == "/root" ]
  [ $status = 0 ]
}

@test "ls no dotfiles installed" {
  run bashdot list
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}

@test "dir no dotfiles installed" {
  run bashdot dir
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}

@test "profiles" {
  cd /root
  bashdot install public private
  . ~/.bashrc
  [ "$PRIVATE_VAR" == "abc" ]
  [ "$PUBLIC_VAR" == "123" ]
}

@test "uninstall" {
  cd /root
  bashdot install public private

  run bashdot dir
  [ "$output" == "/root" ]
  [ $status = 0 ]

  run bashdot uninstall
  [ $status = 0 ]

  run bashdot list
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]

  run bashdot dir
  [ "$output" == "No dotfiles installed by bashdot." ]
  [ $status = 0 ]
}
