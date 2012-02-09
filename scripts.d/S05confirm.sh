
case "$COMMAND" in
  create)
    echo -n "Create project $PROJECT from template $TEMPLATE"
  ;;

  external)
    echo -n "Import project $PROJECT from git repo: $IMPORT_REPO"
  ;;

  backup)
    echo -n "Backup project $PROJECT"
  ;;

  restore)
    echo -n "Restore project $PROJECT from backup"
  ;;

  delete)
    set_message "Warning: No backup is made. Be sure to backup the project first." warning
    echo -n "Delete project $PROJECT"
  ;;

  create_solr)
    echo -n "Create solr instance for project $PROJECT"
  ;;

  delete_solr)
    echo -n "Delete solr instance for project $PROJECT"
  ;;

  local_all)
    echo -n "Dump a copy of the svn files, non-svn files and database(s) of project $PROJECT"
  ;;

  local_files)
    echo -n "Dump a copy of the non-svn files of project $PROJECT"
  ;;

  local_db)
    echo -n "Dump a copy of the database of project $PROJECT"
  ;;

  local_private_db)
    echo -n "Dump a copy of the private sandbox database of project $PROJECT"
  ;;

  export)
    echo -n "Export project $PROJECT"
  ;;

  sandbox)
    echo -n "Create sandbox of project $PROJECT for user $USER"
  ;;

  copy_private_db)
    echo -n "Create private sandbox database ${PROJECT}_${USER} for user $USER from project $PROJECT"
  ;;

  create_private_db)
    echo -n "Create new (blank) private sandbox database ${PROJECT}_${USER} for user $USER for project $PROJECT"
  ;;

  update_private_db)
    echo -n "Update private sandbox database ${PROJECT}_${USER} for user $USER from project $PROJECT"
  ;;

  delete_private_db)
    echo -n "Delete private sandbox database ${PROJECT}_${USER} for user $USER for project $PROJECT"
  ;;
esac

read -p " (y/n)? " ANSWER
if [ ${ANSWER} != "y" ]; then
  exit 1
fi
