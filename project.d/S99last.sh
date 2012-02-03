#!/bin/bash

COMMAND=$1
PROJECT=$2
TEMPLATE=$3
DATESTAMP=$4
SVN=$5

. /usr/local/scripts/common.sh
. /usr/local/scripts/shflags

set +e

case "$COMMAND" in 

    create)
	echo -n "Project $PROJECT created"
	echo " "
	/usr/local/scripts/project create_solr $PROJECT
	;;
    
    backup)
	echo -n "Project $PROJECT backed up."
	echo " "
	/usr/local/scripts/project delete $PROJECT 
	;;

    restore)
	echo -n "Project $PROJECT restored from backup."
	echo " "
	/usr/local/scripts/project create_solr $PROJECT
	;;
    
    external)
	echo "Project $PROJECT created from external source $SVN."
	echo "Empty database $PROJECT created - please import data to populate"
	;;
    
    delete)
	echo -n "Project $PROJECT deleted."
	echo " "
	/usr/local/scripts/project delete_solr $PROJECT 
	;;
    
    create_solr)
	echo "Sorl instance created for project $PROJECT."
	;;
	
    delete_solr)
	echo "Solr instance delete for project $PROJECT."
	;;
    
    local_all | local_files | local_db | local_private_db | export)
	echo "Packaging $COMMAND files..."
	cp -r /usr/local/scripts/local_scripts/update* $HOME/${PROJECT}-${COMMAND}/
	cd $HOME ; zip -r ${PROJECT}-${COMMAND}-${DATESTAMP}.zip $PROJECT-${COMMAND}
	rm -rf $HOME/${PROJECT}-${COMMAND}
	echo "$COMMAND copy of $PROJECT saved to $HOME/${PROJECT}-${COMMAND}-${DATESTAMP}.zip"
	;;
    
    sandbox)
	echo "Sandbox of project $PROJECT created for user $USER."
        echo "Files are in $HOME/public_html/$PROJECT"
        echo "Website is at http://$PROJECT.$DOMAIN/~$USER/$PROJECT"
	;;

    copy_private_db)
	echo "Private sandbox database ${PROJECT}_${USER} created for user $USER from project $PROJECT."
	;;
    
    create_private_db)
	echo "New (blank) private sandbox database ${PROJECT}_${USER} created for user $USER for project $PROJECT."
	echo "The new database name is ${PROJECT}_${USER} - install.php will ask you for this."
	;;

    update_private_db)
	echo "Private sandbox database ${PROJECT}_${USER} updated."
	;;

    delete_private_db)
	echo "Private sandbox database ${PROJECT}_${USER} deleted."
	;;

esac
