#!/bin/bash
#
### SSH Connection Mapper
#
# This Script is desing to generate csv files that help you map
# ssh connections for all users on a given host. The resulting
# outbound.csv shows accepted known hosts and thus outbound ssh
# connections from the host the script is run on, while inbound.csv
# shows the ID field of ssh keys that can connect to the host.

usage() { echo "Usage: $0 [-v verbose] [-H Print Headers] [-o Output Directory(required)]" 1>&2; exit 1; }
HOSTNAME=`hostname`
OUTDIR="/tmp"
while getopts "vHo:" OPTION; do
  case "$OPTION" in
    v) VERBOSE=1      ;;
    H) header         ;;
    o) OUTDIR=$OPTARG ;;
    *) usage          ;;
    esac
done
# clean the previous runs, comment out if using above headers
> $OUTDIR/$HOSTNAME.outbound.csv
> $OUTDIR/$HOSTNAME.inbound.csv
> $OUTDIR/$HOSTNAME.homemap.csv
header() {
  echo "On Host,User,Connects To" >  $OUTDIR/$HOSTNAME.outbound.csv
  echo "On Host,User,Accepts From" > $OUTDIR/$HOSTNAME.inbound.csv
  echo "User,Home Directory" >       $OUTDIR/$HOSTNAME,homemap.csv
}

# $i points to lines in /etc/passwd bellow
while read i
do
  user=`echo $i | awk -F":" '{print $1}'`
  home=`echo $i | awk -F":" '{print $6}'`
  echo "$user,$home" >> $OUTDIR/$HOSTNAME.homemap.csv
  # Verify the file exists to prevent errors
  if [ -a "$home/.ssh/known_hosts" ]
  then
    while read o
    do
      host=`echo $o | grep -v "^#" | awk '{print $1}' | sed 's/,/+/g'`
      # Prevents empty or header lines from being output
      if [ -n "$host" ]
      then
        echo "$HOSTNAME,$user,$host" >> $OUTDIR/$HOSTNAME.outbound.csv
      fi
    done < $home/.ssh/known_hosts
  fi
  # Verify the file exists to prevent errors
  if [ -a "$home/.ssh/authorized_keys" ]
  then
    while read in
    do
      host=`echo $in | grep -v "^#" | awk '{print $NF}'`
      # Prevents empty or header lines from being output
      if [ -n "$host" ]
      then
        echo "$HOSTNAME,$user,$host" >> $OUTDIR/$HOSTNAME.inbound.csv
      fi
    done < $home/.ssh/authorized_keys
  fi
done < /etc/passwd
