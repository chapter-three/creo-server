#!/bin/bash

COMMAND=$1
PROJECT=$2
TEMPLATE=template6
DATESTAMP=$4
SVN=$5

. /usr/local/scripts/common.sh
. /usr/local/scripts/shflags

set +e

case "$COMMAND" in 
    #nothing for create, backup, restore, delete, external, local_all, local_files, local_db, local_private_db, export, sandbox, copy_priivate_db, create_private_db, update_private_db and delete_private_db
    create_solr) 
	echo "Creating solr instance..."
	cp -ar /var/solr/$TEMPLATE /var/solr/$PROJECT
	cp -a /etc/tomcat6/Catalina/localhost/${TEMPLATE}.xml /etc/tomcat6/Catalina/localhost/$PROJECT.xml
	sed -i "s/$TEMPLATE/$PROJECT/" /etc/tomcat6/Catalina/localhost/$PROJECT.xml
	cp -ar /var/lib/tomcat6/webapps/$TEMPLATE /var/lib/tomcat6/webapps/$PROJECT
	echo "Restarting Tomcat..."
	/etc/init.d/tomcat6 restart
	drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT enable apachesolr apachesolr_search search
	drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_port 8180
	drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_path /inceptum
	echo "Please go to http://$PROJECT.$DOMAIN:8180/$PROJECT/admin/ and verify the new context is working."
	;;
    
    delete_solr)
	echo "Removing solr instance..."
	rm -r /var/solr/$PROJECT
	rm /etc/tomcat6/Catalina/localhost/$PROJECT.xml
	rm -r /var/lib/tomcat6/webapps/$PROJECT
	echo "Restarting Tomcat..."
	/etc/init.d/tomcat6 restart
	;;
    
esac
