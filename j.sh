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
  if [ "$*" = "" ]
  then
    cat -
  else
    pattern=$1
    shift
    egrep "$pattern" - | grep_all ${*}
  fi
}

choose_dirs() {
  RET=""
  for dir in `cat ~/.j | grep_all $* | sort -nr | uniq | cut -d" " -f2`
  do
    if [ -d $dir ]
    then
      RET="$RET$dir "
    fi
  done
  if [ "$RET" = "" ]
  then
    return 1
  else
    return 0
  fi
}

choose_dir() {
  if choose_dirs $*
  then
    for dir in $RET
    do
      RET=$dir
      return 0
    done
    return 1
  else
    return 1
  fi
}

j_complete() {
  if [ "${COMP_WORDS[COMP_CWORD]}" = "" ]
  then
    return 1
  else
    COMPREPLY=()
    if choose_dirs ${COMP_WORDS[COMP_CWORD]}
    then
      for dir in $RET
      do
        COMPREPLY=(${COMPREPLY} $dir)
      done
      return 0
    else
      return 1
    fi
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
complete -F j_complete -o dirnames cd
alias cd=j
