#!/usr/bin/env bats

teardown() {
  /bin/rm -rf ~/.bashrc ~/.profilerc* ~/.dotfiler profiles/another
}

@test "general help" {
  run dotfiler
  [ "$output" == "Usage: dotfiler [dir|install|list|uninstall] OPTIONS" ]
  [ $status = 1 ]
}

@test "install help" {
  run dotfiler install
  [ "$output" == "Usage: dotfiler install PROFILE1 PROFILE2 ... PROFILEN" ]
  [ $status = 1 ]
}

@test "error profiles does not exist" {
  cd /tmp
  run dotfiler install public
  [ "$output" == "Directory profiles does not exist in '/tmp'." ]
  [ $status = 1 ]
}

@test "error profile does not exist" {
  mkdir profiles
  run dotfiler install public
  [ "$output" == "Profile 'public' directory does not exist." ]
  [ $status = 1 ]
}

@test "error no dotfiler profiles installed" {
  run dotfiler uninstall
  [ "$output" == "No '.dotfiler' file in ~." ]
  [ $status = 1 ]
}

@test "error file already exists on install" {
  touch ~/.bashrc
  mkdir -p profiles/public
  touch profiles/public/bashrc
  run dotfiler install public
  [ "${lines[2]}" == "File '.bashrc' already exists, exiting." ]
  [ $status = 1 ]
}

@test "error already installed" {
  cd /root
  dotfiler install public
  cd /tmp
  mkdir -p profiles/public
  run dotfiler install public
  [ $status = 1 ]
}

@test "error file already installed from another profile" {
  cd /root
  dotfiler install public

  mkdir -p profiles/another
  touch profiles/another/bashrc
  run dotfiler install another
  [ $status = 1 ]
}

@test "install" {
  cd /root
  run dotfiler install public private
  [ "${lines[11]}" == "Completed installation of all profiles succesfully." ]
  [ $status = 0 ]
}

@test "validate ignored files not symlinked" {
  cd /root
  dotfiler install public

  run test -e /root/.bashrc
  [ $status = 0 ]

  run test -e /root/.profilerc_public
  [ $status = 0 ]

  run test -e /root/.README.md
  [ $status != 0 ]
}

@test "re-install" {
  cd /root
  dotfiler install public private
  run dotfiler install public private
  [ $status = 0 ]
}

@test "ls" {
  cd /root
  dotfiler install public private
  run dotfiler list
  [ "${lines[0]}" == "private" ]
  [ "${lines[1]}" == "public" ]
  [ $status = 0 ]
}

@test "dir" {
  cd /root
  dotfiler install public private
  run dotfiler dir
  [ "${lines[0]}" == "/root" ]
  [ $status = 0 ]
}

@test "ls no dotfiles installed" {
  run dotfiler list
  [ "$output" == "No dotfiles installed by dotfiler." ]
  [ $status = 0 ]
}

@test "dir no dotfiles installed" {
  run dotfiler dir
  [ "$output" == "No dotfiles installed by dotfiler." ]
  [ $status = 0 ]
}

@test "profiles" {
  cd /root
  dotfiler install public private
  . ~/.bashrc
  [ "$PRIVATE_VAR" == "abc" ]
  [ "$PUBLIC_VAR" == "123" ]
}

@test "uninstall" {
  cd /root
  dotfiler install public private

  run dotfiler dir
  [ "$output" == "/root" ]
  [ $status = 0 ]

  run dotfiler uninstall
  [ $status = 0 ]

  run dotfiler list
  [ "$output" == "No dotfiles installed by dotfiler." ]
  [ $status = 0 ]

  run dotfiler dir
  [ "$output" == "No dotfiles installed by dotfiler." ]
  [ $status = 0 ]
}
