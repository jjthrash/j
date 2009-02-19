#!/bin/bash

inc() {
  perl -pi -e '
    ($n, $d) = split /\s/;
    $_ = ($n+1) . " $d\n" if $d eq "'`pwd`'";
  ' ~/.j
}

add_or_inc() {
  if grep -wq `pwd` ~/.j
  then
    inc
  else
    echo 1 `pwd` >> ~/.j
  fi
}

grep_all() {
  if [ "$*" == "" ]
  then
    cat -
  else
    pattern=$1
    shift
    egrep "$pattern" - | grep_all ${*}
  fi
}

j() {
  touch ~/.j

  if [ "$*" = "" ]
  then
    builtin cd
  elif [ -d $1 -o "$1" = "-" ]
  then
    builtin cd $1
    add_or_inc
  elif [ "$1" = "-l" ]
  then
    sort -nr ~/.j
  else
    for dir in `cat ~/.j | grep_all $* | sort -nr | uniq | cut -d" " -f2`
    do
      if [ -d $dir ]
      then
        builtin cd $dir
        inc
        return
      fi
    done
    echo no directory found matching: $*
  fi
}
