#!/bin/bash

case "$COMMAND" in
  create)
    echo "Create $PROJECT from template $TEMPLATE?"
  ;;

  backup)
    echo "Backup project $PROJECT?"
  ;;

  restore)
    echo "Restore project $PROJECT from backup?"
  ;;

  external)
    echo "Create project $PROJECT from external svn?"
  ;;

  delete)
    echo "Delete project $PROJECT?"
    echo_color $YELLOW"Warning: - no backup is made in this action - make sure to backup the project first if you need a backup."
  ;;

  create_solr)
    echo "Create solr instance for project $PROJECT?"
  ;;

  delete_solr)
    echo "Delete solr instance for project $PROJECT?"
  ;;

  local_all)
    echo "Dump a copy of the svn files, non-svn files and database(s) of project $PROJECT?"
  ;;

  local_files)
    echo "Dump a copy of the non-svn files of project $PROJECT?"
  ;;

  local_db)
    echo "Dump a copy of the database of project $PROJECT?"
  ;;

  local_private_db)
    echo "Dump a copy of the private sandbox database of project $PROJECT?"
  ;;

  export)
    echo "Export project $PROJECT?"
  ;;

  sandbox)
    echo "Create sandbox of project $PROJECT for user $USER?"
  ;;

  copy_private_db)
    echo "Create private sandbox database ${PROJECT}_${USER} for user $USER from project $PROJECT?"
  ;;

  create_private_db)
    echo "Create new (blank) private sandbox database ${PROJECT}_${USER} for user $USER for project $PROJECT?"
  ;;

  update_private_db)
    echo "Update private sandbox database ${PROJECT}_${USER} for user $USER from project $PROJECT?"
  ;;

  delete_private_db)
    echo "Delete private sandbox database ${PROJECT}_${USER} for user $USER for project $PROJECT?"
  ;;
esac

echo -n "(y/n):"

read ANSWER
echo ""
if [ ${ANSWER} != "y" ]; then
  echo "Cancelling $COMMAND....."
  exit 1
fi
