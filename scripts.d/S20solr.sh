
case "$COMMAND" in
  create_solr)
    set_message "Creating solr instance..."
    cp -ar $SOLR_DATA_DIR/$TEMPLATE $SOLR_DATA_DIR/$PROJECT
    cp -a TOMCAT_LOCALHOST_DIR/${TEMPLATE}.xml TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    sed -i "s/$TEMPLATE/$PROJECT/" TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    cp -ar $TOMCAT_WEBAPP_DIR/$TEMPLATE $TOMCAT_WEBAPP_DIR/$PROJECT
    set_message "Restarting Tomcat..."
    $TOMCAT_SERVICE_PATH restart
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT enable apachesolr apachesolr_search search
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_port 8180
    #drush -l http://$PROJECT.$DOMAIN -r $WWW_DIR/$PROJECT vset --yes apachesolr_path /inceptum
    set_message "Please go to http://$PROJECT.$DOMAIN:8180/$PROJECT/admin/ and verify the new context is working."
  ;;

  delete_solr)
    set_message "Removing solr instance..."
    rm -r $SOLR_DATA_DIR/$PROJECT
    rm $TOMCAT_LOCALHOST_DIR/$PROJECT.xml
    rm -r TOMCAT_WEBAPP_DIR/$PROJECT
    # @todo: Make sure files were deleted before the restart is done.
    set_message "Restarting Tomcat..."
    $TOMCAT_SERVICE_PATH restart
  ;;
esac
