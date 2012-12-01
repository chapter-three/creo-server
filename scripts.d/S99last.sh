case "$COMMAND" in
  create)
    set_message "Project $PROJECT created"
    $0 create_solr $PROJECT
  ;;

  import)
    set_message "Project $PROJECT created from git repository: $IMPORT_REPO."
    set_message "Empty database $PROJECT created - please import data to populate." warning
  ;;

  backup)
    set_message "Project $PROJECT backed up."
    #$0 delete $PROJECT
  ;;

  restore)
    set_message 1"Project $PROJECT restored from backup."
    $0 create_solr $PROJECT
  ;;

  delete)
    set_message "Project $PROJECT deleted."

    # If solr instance exists for project, delete it.
    if [ -d $SOLR_DATA_DIR/$PROJECT ] ; then
      echo y | $0 delete_solr $PROJECT
    fi
  ;;

  create_solr)
    set_message "Solr instance created for project $PROJECT."
  ;;

  delete_solr)
    set_message "Solr instance delete for project $PROJECT."
  ;;

  local_all | local_files | local_db | local_private_db | export)
    set_message "Packaging $COMMAND files..."
    cd $HOME ; tar zcf ${PROJECT}-${COMMAND}-${DATESTAMP}.tar.gz $PROJECT-${COMMAND}
    rm -rf $HOME/${PROJECT}-${COMMAND}
    set_message "$COMMAND copy of $PROJECT saved to $HOME/${PROJECT}-${COMMAND}-${DATESTAMP}.tar.gz"
  ;;

  sandbox)
    set_message "Sandbox of project $PROJECT created for user $USER."
    set_message "Files are in $HOME/public_html/$PROJECT"
    set_message "Website is at http://$PROJECT.$USER.dev.$DOMAIN/"
  ;;

  copy_private_db)
    set_message "Private sandbox database ${PROJECT}_${USER} created for user $USER from project $PROJECT."
  ;;

  create_private_db)
    set_message "New (blank) private sandbox database ${PROJECT}_${USER} created for user $USER for project $PROJECT."
    set_message "The new database name is ${PROJECT}_${USER} - install.php will ask you for this."
  ;;

  update_private_db)
    set_message "Private sandbox database ${PROJECT}_${USER} updated."
  ;;

  delete_private_db)
    set_message "Private sandbox database ${PROJECT}_${USER} deleted."
  ;;

esac
