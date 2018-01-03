#!/bin/sh

# used to deploy indy from a archive on local, and keep all configuration 
# and storage not changed

INDY_SRC=/tmp/$1
OLD_INDY_LOC=$HOME/deploy/indy

wait_process()
{
  processId=$1
  if [ "a$processId" == "a" ]; then
    return -1
  fi

  while ps -p $processId 
  do
    sleep 1s
  done
   
  return 1
}

if [ "x$1" == "x" ]; then
  echo "usage: $0 indy-launcher.tar.gz";
  exit 0;
fi

if [ ! -f $1 ]; then
  echo "$1 is not a regular file!";
  exit 0;
fi


if [[ $1 == *.gz ]]; then
  mkdir $INDY_SRC 
  echo "extracting package to $INDY_SRC";
  tar -zxvf $1 -C $INDY_SRC;
elif [[ $1 == *.zip ]]; then
  mkdir $INDY_SRC 
  echo "extracting package to $INDY_SRC";
  unzip $1 -d $INDY_SRC;
else
  echo "$1 is not a regular indy launcher package!";
  exit 0;
fi

# stop old indy
processId=`ps -ef | grep -v grep | grep indy | grep java | awk '{print $2}'`
if [ $processId > 0 ]; then
  echo "stopping old indy instance"
  kill $processId
  wait_process $processId 
fi

# backup old indy
#DATE=`date +%Y-%m-%d`
#tar -zcvf ~/deploy/backup/indy-backup-$DATE.tar.gz $OLD_INDY_LOC/*


# replace indy with new archives
echo "replacing lib"
rm -rf $OLD_INDY_LOC/lib
cp -r $INDY_SRC/indy/lib $OLD_INDY_LOC/

echo "replacing bin"
rm -rf  $OLD_INDY_LOC/bin/indy.sh $OLD_INDY_LOC/bin/boot.properties $OLD_INDY_LOC/bin/init
cp -r $INDY_SRC/indy/bin/* $OLD_INDY_LOC/bin/

echo "replacing doc"
rm -rf $OLD_INDY_LOC/usr/share/doc
cp -r $INDY_SRC/indy/usr/share/doc $OLD_INDY_LOC/usr/share/

echo "replacing uis"
rm -rf $OLC_INDY_LOC/var/lib/indy/ui
cp -r $INDY_SRC/indy/var/lib/indy/ui $OLD_INDY_LOC/var/lib/indy/

# start indy
echo "starting new indy instance"
nohup $OLD_INDY_LOC/bin/indy.sh >> $OLD_INDY_LOC/var/log/indy/indy.log 2>&1 &
sleep 5s

# remove temp extracted files
echo "remove temp extracted files"
rm -rf $INDY_SRC
