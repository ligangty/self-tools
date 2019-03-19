#!/bin/bash
##
# This script is used to process pnc maven build log into a csv file that contains all
# downloaded artifacts with following format:
# GAV   File   Size    Download_Speed
#
# It can help to analyze which part of the downloading is slow
#
# P.S: all other maven build logs can also be used as source file for this script
##

FILE=$1
ACTION=$2
DIR=$(realpath $(dirname $0));
TMPDIR=/tmp;
if [ "$ACTION" == "" ]; then
   ACTION="download"
fi

TMP_FILE=$TMPDIR/pnc-maven-origin.tmp;
TMP_PROCESS=$TMPDIR/pnc-maven-processed.tmp;
FINAL_PROCESS=$DIR/pnc-$ACTION-artifacts.csv;

if [[ "$FILE" == ""  ||  ! -f $FILE ]]; then
   echo "$FILE is not a file";
   echo "Usage: $0 file-to-process [download|upload]";
   exit 1;
fi


if [ -f TMP_FILE ]; then
  rm -f $TMP_FILE;
fi

if [ -f TMP_PROCESS ]; then
  rm -f $TMP_PROCESS;
fi


if [ "$ACTION" == "download" ]; then
  grep 'Downloaded from' $1 > $TMP_FILE;
else
  grep 'Uploaded to' $1 > $TMP_FILE;
fi

sed -i 's;\[INFO\];;g' $TMP_FILE;
if [ "$ACTION" == "download" ]; then
  sed -i 's;\(Downloaded from indy-mvn: http://[^/]*/api/folo/track/[^/]*\)/\(.*\);/\2;g' $TMP_FILE;
else
  sed -i 's;\(Uploaded to indy-mvn: http://[^/]*/api/folo/track/[^/]*\)/\(.*\);/\2;g' $TMP_FILE;
fi
#sed -i 's;(\(.*\));\1;g' $TMP_FILE;
sed -i 's;\([0-9]\+\) ;\1;1' $TMP_FILE;
sed -i 's; at ; ;g' $TMP_FILE;

while IFS='' read -r line || [[ -n "$line" ]]; do
    by_comma=(${line// / });
    by_slash=(${by_comma[0]//\// });
    length=${#by_slash[@]};
    forLimit=$((length-2));
    result="";
    for i in $(seq 0 $forLimit); do
      result="$result/${by_slash[i]}";
    done

    result="$result/${by_slash[length-1]}";
    echo $result >> $TMP_PROCESS;
done < $TMP_FILE

if [ -f $FINAL_PROCESS ]; then
  rm -f $FINAL_PROCESS;
fi

sort -t, -k1,1 -k2,2r $TMP_PROCESS > $FINAL_PROCESS;
#sed -i '1s/^/Repo+GAV,File,Size,Down_speed,Unit\n/' $FINAL_PROCESS;
rm -f $TMP_PROCESS $TMP_FILE;

echo "Processed anaylized file generated at $FINAL_PROCESS";
