case "$COMMAND" in
  create)
    set_message "Project $PROJECT created"
    set_message " "
    #../project create_solr $PROJECT
  ;;

  backup)
    set_message -n "Project $PROJECT backed up."
    set_message " "
    ../project delete $PROJECT
  ;;

  restore)
    set_message -n "Project $PROJECT restored from backup."
    set_message " "
    ../project create_solr $PROJECT
  ;;

  external)
    set_message "Project $PROJECT created from external source $SVN."
    set_message "Empty database $PROJECT created - please import data to populate"
  ;;

  delete)
    set_message -n "Project $PROJECT deleted."
    set_message " "
    ../project delete_solr $PROJECT
  ;;

  create_solr)
    set_message "Sorl instance created for project $PROJECT."
  ;;

  delete_solr)
    set_message "Solr instance delete for project $PROJECT."
  ;;

  local_all | local_files | local_db | local_private_db | export)
    set_message "Packaging $COMMAND files..."
    cp -r ../local_scripts/update* $HOME/${PROJECT}-${COMMAND}/
    cd $HOME ; zip -r ${PROJECT}-${COMMAND}-${DATESTAMP}.zip $PROJECT-${COMMAND}
    rm -rf $HOME/${PROJECT}-${COMMAND}
    set_message "$COMMAND copy of $PROJECT saved to $HOME/${PROJECT}-${COMMAND}-${DATESTAMP}.zip"
  ;;

  sandbox)
    set_message "Sandbox of project $PROJECT created for user $USER."
    set_message "Files are in $HOME/public_html/$PROJECT"
    set_message "Website is at http://$PROJECT.$DOMAIN/~$USER/$PROJECT"
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
