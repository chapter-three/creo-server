# @todo: Make sure files were deleted before the restart.
# @todo: Determine Tomcat's port

case "$COMMAND" in
  create_solr)
    set_message "Creating Solr instance"
    cp -ar $SOLR_DATA_DIR/$SOLR_TEMPLATE $SOLR_DATA_DIR/$PROJECT
    cp -a $TOMCAT_LOCALHOST_DIR/$SOLR_TEMPLATE.xml $TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    sed -i "s/$SOLR_TEMPLATE/$PROJECT/" $TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    cp -ar $TOMCAT_WEBAPP_DIR/$SOLR_TEMPLATE $TOMCAT_WEBAPP_DIR/$PROJECT
    set_message "Restarting Tomcat"
    $TOMCAT_SERVICE_PATH restart
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT enable apachesolr apachesolr_search search
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_port $TOMCAT_PORT
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_path /inceptum

    set_message "Go to: http://$PROJECT.$DOMAIN:$TOMCAT_PORT/$PROJECT/admin/ to verify the new context." warning
  ;;

  delete_solr)
    set_message "Removing Solr instance"
    rm -r $SOLR_DATA_DIR/$PROJECT
    rm $TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    rm -r $TOMCAT_WEBAPP_DIR/$PROJECT

    set_message "Restarting Tomcat"
    $TOMCAT_SERVICE_PATH restart
  ;;
esac
