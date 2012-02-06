
case "$COMMAND" in
  #nothing for backup, create_solr, delete_solr, local_all, local_files, local_db, local_private_db, export, sandbox, copy_private_db, create_private_db, update_private_db, and delete_private_db
  create)
    ln -s /usr/local/scripts/selfdrush.sh /usr/local/bin/drush_$PROJECT
  ;;

  restore)
    ln -s /usr/local/scripts/selfdrush.sh /usr/local/bin/drush_$PROJECT
  ;;

  external)
    ln -s /usr/local/scripts/selfdrush.sh /usr/local/bin/drush_$PROJECT
  ;;

  delete)
    rm /usr/local/bin/drush_$PROJECT
  ;;

esac
