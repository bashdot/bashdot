#!/usr/bin/env bats

teardown() {
  /bin/rm -rf ~/.bashrc ~/.profilerc* ~/.dotfiler
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
  [ "$output" == "Profiles already installed from '/root'." ]
  [ $status = 1 ]
}

@test "install" {
  cd /root
  run dotfiler install public private
  [ "${lines[11]}" == "Completed installation of all profiles succesfully." ]
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
  result1=`. ~/.bashrc > /dev/null ; echo -e $PRIVATE_VAR`
  result2=`. ~/.bashrc > /dev/null ; echo -e $PUBLIC_VAR`

  [ "$result1" == "abc" ]
  [ "$result2" == "123" ]
}

@test "uninstall" {
  cd /root
  dotfiler install public private
  result0=`cd /root && dotfiler uninstall | tail -1`
  echo $result0
  result1=`dotfiler list`
  result2=`dotfiler dir`
  [ "$result0" == "Completed uninstallation succesfully." ]
  [ "$result1" == "No dotfiles installed by dotfiler." ]
  [ "$result2" == "No dotfiles installed by dotfiler." ]
}
