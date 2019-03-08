#!/usr/bin/env bats

@test "help" {
  run dotfiler
  [ "$output" == "Usage: dotfiler [dir|install|list|uninstall] OPTIONS" ]
  [ $status = 1 ]

  run dotfiler install
  [ "$output" == "Usage: dotfiler install PROFILE1 PROFILE2 ... PROFILEN" ]
  [ $status = 1 ]
}

@test "not installed" {
  result0=`dotfiler list`
  [ "$result0" == "No dotfiles installed by dotfiler." ]
  result1=`dotfiler dir`
  [ "$result1" == "No dotfiles installed by dotfiler." ]
}

@test "errors" {
  cd /tmp
  run dotfiler install public
  [ "$output" == "Directory profiles does not exist in '/tmp'." ]
  [ $status = 1 ]

  mkdir profiles
  run dotfiler install public
  [ "$output" == "Profile 'public' directory does not exist." ]
  [ $status = 1 ]

  run dotfiler uninstall
  [ "$output" == "No '.dotfiler' file in ~." ]
  [ $status = 1 ]
}

@test "install" {
  result0=`cd /root && dotfiler install public private | tail -1`
  result1=`dotfiler list | head -1`
  result2=`dotfiler list | tail -1`
  result3=`dotfiler list | wc -l`
  result4=`dotfiler dir`
  [ "$result0" == "Completed installation of all profiles succesfully." ]
  [ "$result1" == "private" ]
  [ "$result2" == "public" ]
  [ "$result3" -eq 2 ]
  [ "$result4" == "/root" ]
}

@test "already installed" {
  cd /tmp ; mkdir -p profiles/public
  run dotfiler install public
  [ "$output" == "Profiles already installed from '/root'." ]
  [ $status = 1 ]
}

@test "profiles" {
  result1=`. ~/.bashrc > /dev/null ; echo -e $PRIVATE_VAR`
  result2=`. ~/.bashrc > /dev/null ; echo -e $PUBLIC_VAR`
  [ "$result1" == "abc" ]
  [ "$result2" == "123" ]
}

@test "uninstall" {
  result0=`cd /root && dotfiler uninstall | tail -1`
  echo $result0
  result1=`dotfiler list`
  result2=`dotfiler dir`
  [ "$result0" == "Completed uninstallation succesfully." ]
  [ "$result1" == "No dotfiles installed by dotfiler." ]
  [ "$result2" == "No dotfiles installed by dotfiler." ]
}
