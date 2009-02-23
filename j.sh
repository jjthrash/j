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

choose_dir() {
  for dir in `cat ~/.j | grep_all $* | sort -nr | uniq | cut -d" " -f2`
  do
    if [ -d $dir ]
    then
      RET=$dir
      return 0
    fi
  done
  return 1
}

j_complete() {
  COMPREPLY=()
  if choose_dir ${COMP_WORDS[COMP_CWORD]}
  then
    COMPREPLY=($RET)
    return 0
  else
    return 1
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
  elif [ "$1" = "-h" ]
  then
    echo "usage: cd [-s] [-l] [dir]"
    echo "  -s   -- show selected directory, but don't actually change directories"
    echo "  -l   -- show directory history"
  elif [ "$1" = "-s" ]
  then
    shift
    if choose_dir $*
    then
      echo $RET
    else
      echo no directory found matching: $*
    fi
  else
    if choose_dir $*
    then
      builtin cd $RET
      inc
    else
      echo no directory found matching: $*
    fi
  fi
}

shopt -s progcomp
complete -F j_complete cd
