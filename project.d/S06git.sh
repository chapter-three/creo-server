#!/bin/bash

COMMAND=$1
PROJECT=$2
TEMPLATE=$3
DATESTAMP=$4
SVN=$5
GIT=$6

. ../common.sh
. ../shflags

# if git is enabled (not the default)
if [ $GIT = 0 ]; then
  exit 0
fi

set +e


case "$COMMAND" in
#nothing for create_solr, delete_solr, external, local_files, local_db, local_private_db, copy_private_db, create_private_db, update_private_db or delete_private_db
create)
  #Create gitolite repo
  #Checkout $PROJECT
  #Change origin to new repo
  #Push project to new repo
  echo "Creating GIT repository....."

  svnadmin create $SVN_DIR/$PROJECT --fs-type fsfs
  svn mkdir -q -m "Creating subversion structure" file://$SVN_DIR/$PROJECT/trunk file://$SVN_DIR/$PROJECT/branches file://$SVN_DIR/$PROJECT/tags
  echo "Creating $WWW_DIR/$PROJECT/sites/$PROJECT.$DOMAIN dir..."
  mv $TMP_DIR/$PROJECT/sites/$TEMPLATE.$DOMAIN $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN
  sed -i "s/$TEMPLATE/$PROJECT/" $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN/settings.php
  sed -i "s/mysql:/mysqli:/" $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN/settings.php
  cd $TMP_DIR/$PROJECT/sites/; ln -sf $PROJECT.$DOMAIN default
  svn import -q -m "Initial import of $PROJECT from $TEMPLATE" $TMP_DIR/$PROJECT file://$SVN_DIR/$PROJECT/trunk
  rm -rf  $TMP_DIR/$PROJECT

  # get the globabl svn hooks
  rm -rf /var/svn/$PROJECT/hooks
  ln -s /usr/local/scripts/svn_hooks /var/svn/$PROJECT/hooks

  set_svn_permissions $PROJECT

  svn co -q file://$SVN_DIR/$PROJECT/trunk $WWW_DIR/$PROJECT
  ;;

backup)
  echo "Rolling up SVN....."
  mkdir -p $BACKUP_DIR/$PROJECT
  svnadmin dump -q $SVN_DIR/$PROJECT | gzip - > $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz
  ;;

restore)
  echo "Rolling down SVN....."
  mkdir -p $SVN_DIR/$PROJECT
  svnadmin create $SVN_DIR/$PROJECT --fs-type fsfs
  gunzip -c $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz | svnadmin load -q $SVN_DIR/$PROJECT
  set_svn_permissions $PROJECT
  ;;

delete)
  echo "Removing SVN....."
  rm -rf $SVN_DIR/$PROJECT
  ;;

external)
  echo "Checking out a copy from $EXTERNAL..."
  svn checkout $SVN $WWW_DIR/$PROJECT
  ;;

local_all)
  echo "Getting an export of the trunk for local dev..."
  mkdir -p $HOME/${PROJECT}-${COMMAND}
  svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/${PROJECT}-${COMMAND}/$PROJECT
  ;;

export)
  echo "Getting an export of the trunk..."
  mkdir -p $HOME/${PROJECT}-${COMMAND}
  REPOSITORY=`svn info $WWW_DIR/$PROJECT | grep 'URL' | sed 's/URL: //'`
  svn export $REPOSITORY $HOME/${PROJECT}-${COMMAND}/www
  ;;

sandbox)
  echo "Creating a $PROJECT sandbox for $USER...."

  if [ -d $HOME/public_html/$PROJECT ] ; then
      echo "Sandbox already exists at $HOME/public_html/$PROJECT"
      exit 1
  fi

  svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/public_html/$PROJECT
  ;;
esac
