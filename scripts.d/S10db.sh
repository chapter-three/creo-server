#@todo Determine a method to import databases


backup_db() {
  #$1 is the DB name and $2 is the location to save the file
  #tests first to see if DB exists - mysqldump spits out an error if it doesn't
  DBS=`mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -Bse 'show databases'| egrep -v 'information_schema|mysql'`
  for db in $DBS; do
    if [ "$db" = "$1" ]; then
      echo "Existing DB $1 found, backing up to $2"
      #clear caches and dump all but user cache tables:
      # @todo: drush can only be run on working drupal installs. Test first
      #drush -r /var/www/${1} cc all
      mysqldump -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $1 -r $2
    fi
  done
}

create_db() {
  #$1 is the DB name
  echo "DROP DATABASE IF EXISTS \`$1\`" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
  echo "CREATE DATABASE IF NOT EXISTS \`$1\`" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
  echo "GRANT ALL ON \`$1\`.* TO '$MYSQL_USERNAME'@'localhost'; FLUSH PRIVILEGES;" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
}

copy_db() {
  #copies DB $1 to $2
  mysqldump -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $1 -r $TMP_DIR/$1.sql
  echo "CREATE DATABASE IF NOT EXISTS \`$2\`" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
  mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -D$2 < $TMP_DIR/$1.sql
  rm $TMP_DIR/$1.sql
}

drop_db() {
  #$1 is DB name
  echo "DROP DATABASE IF EXISTS \`$1\`" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
  echo "USE mysql ; DELETE FROM db WHERE Db='$1'; FLUSH PRIVILEGES;" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD
}

copy_table() {
  #$1 is the project and $2 is the table name
  if [ `echo "SELECT * FROM information_schema.tables WHERE table_schema = '$1' AND table_name = '$2'" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD` ]; then
    echo "CREATE TABLE IF NOT EXISTS ${USER}_sandbox_${2} LIKE $2" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $1
  fi
}

case "$COMMAND" in
  # nothing for create_solr, delete_solr, external, or local_private_files
  create)
    backup_db $PROJECT $HOME/${PROJECT}_${DATESTAMP}.sql
    set_message "Creating DB"
    create_db $PROJECT
    copy_db $TEMPLATE $PROJECT
  ;;

  import)
    # Attempt to clone the repo
    (
      cd $TMP_DIR
      rm -rf import-repo
      # This will fail the script if it fails
      git clone $IMPORT_REPO import-repo
    )

    backup_db $PROJECT $HOME/${PROJECT}_${DATESTAMP}.sql
    set_message "Creating DB"
    create_db $PROJECT

    set_message "Empty database $PROJECT created"

  ;;

  backup)
    set_message "Rolling up DB"
    mkdir -p $BACKUP_DIR/$PROJECT
    copy_db $PROJECT scratch
    backup_db scratch $BACKUP_DIR/$PROJECT/$PROJECT.sql
    gzip $BACKUP_DIR/$PROJECT/$PROJECT.sql
    drop_db scratch
  ;;

  restore)
    backup_db $PROJECT $HOME/${PROJECT}_${DATESTAMP}.sql
    set_message "Rolling down DB"
    create_db $PROJECT
    gunzip -c $BACKUP_DIR/$PROJECT/$PROJECT.sql.gz | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $PROJECT
  ;;

  local_all)
    set_message "Exporting DB."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    copy_db $PROJECT scratch
    backup_db scratch $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${DATESTAMP}.sql
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${USER}_${DATESTAMP}.sql
    drop_db scratch
  ;;

  local_files)
    mkdir -p $HOME/${PROJECT}-${COMMAND}
  ;;

  local_db | export)
    set_message "Exporting DB."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    copy_db $PROJECT scratch
    backup_db scratch $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${DATESTAMP}.sql
    drop_db scratch
  ;;

  local_private_db)
    set_message "Exporting DB."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${USER}_${DATESTAMP}.sql
  ;;

  delete)
    set_message "Deleting DB"
    drop_db $PROJECT
  ;;

  sandbox)
  ;;

  copy_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    set_message "Copying to sandbox DB"
    create_db ${PROJECT}_${USER}
    copy_db $PROJECT ${PROJECT}_${USER}
  ;;

  create_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    set_message "Creating sandbox DB"
    create_db ${PROJECT}_${USER}
  ;;

  update_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    set_message "Updating sandbox DB"
    create_db ${PROJECT}_${USER}
    copy_db $PROJECT ${PROJECT}_${USER}
  ;;

  delete_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    set_message "Deleting sandbox DB"
    drop_db ${PROJECT}_${USER}
  ;;

esac
