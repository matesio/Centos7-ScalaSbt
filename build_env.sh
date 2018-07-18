#!/bin/bash


#Author 
#****Hammad Ahmad****#
#****email:-hammad.ahmad@abcdata.org****#

function print_stack() {

  local i

  local stack_size=${#FUNCNAME[@]}

  log "Stack trace (most recent call first):"

  # to avoid noise we start with 1, to skip the current function

  for (( i=1; i<$stack_size ; i++ )); do

    local func="${FUNCNAME[$i]}"

    [[ -z "$func" ]] && func='MAIN'

    local line="${BASH_LINENO[(( i - 1 ))]}"

    local src="${BASH_SOURCE[$i]}"

    [[ -z "$src" ]] && src='UNKNOWN'



    log "  $i: File '$src', line $line, function '$func'"

  done

}
function log() {
  echo "[$(basename $0)-$(date '+%H:%M:%S')] $@"

}


function tryexec () {
  "$@"
  local retval=$?
  [[ $retval -eq 0 ]] && return 0

  log 'A command has failed:'
  log "  $@"
  log "Value returned: ${retval}"
  print_stack
  exit $retval
}
rootcheck () {
    if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@" 
        log "please run as root"
        exit $?
    fi
}


function buildScalaEnvironment {

	tryexec yum update -y
	log $(tryexec java -version)
	log "Downloading scala rpm package........."
	tryexec wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm
	log "installing sacla .........."
	tryexec yum install scala-2.11.8.rpm -y
	log "successfully installed.........".$(scala -version)
	log "adding sbt repos to /etc/yum.repos.d"
	tryexec curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo
	log "installing sbt"
	tryexec yum install sbt -y


	}


function createProject(){
	read -n1 -p "Create a sample scala project? [y,n]" doit 
	case $doit in  
  	  y|Y)  log "creating sample project ......" && sbt new sbt/scala-seed.g8 ;; 
  	  n|N) log "setup Complete" ;; 
      *) echo dont know ;; 
	esac

}


log "Please be sure you are root."

rootcheck
buildScalaEnvironment
createProject
