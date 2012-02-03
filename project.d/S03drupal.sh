#!/bin/bash

# this pieces takes care of getting the drupal codebase and creating the /tmp

COMMAND=$1
PROJECT=$2
TEMPLATE=$3
DATESTAMP=$4
SVN=$5

. /usr/local/scripts/common.sh
. /usr/local/scripts/shflags

set +e

case "$COMMAND" in
    # nothing for backup, restore, create_solr, delete_solr, external, local_all, local_files, local_db, local_private_db, export, sandbox, copy_private_db, create_private_db, update_private_db, or delete_private_db
    create) 
	echo "Installing drupal from $TEMPLATE...."
        # CODE UP /TMP
	svn export -q file://$SVN_DIR/$TEMPLATE/trunk $TMP_DIR/$PROJECT
	
	mkdir -p $TMP_DIR/$PROJECT/sites/all/modules/custom
	mkdir -p $TMP_DIR/$PROJECT/sites/all/themes
	;;
    
    delete) 
	echo "Removing $TMP_DIR/$PROJECT....."
	rm -rf $TMP_DIR/$PROJECT
	;;
    
esac
