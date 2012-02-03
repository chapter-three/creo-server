
delete_sandbox_tables() {
  #$1 is the DB
  TABLES=`echo "SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '$1' AND table_name LIKE '%sandbox%'" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW`
  for TABLE in $TABLES; do
    if [ ! $TABLE = "table_name" ]; then
      echo "Dropping Table $TABLE"
      echo "DROP TABLE IF EXISTS $TABLE" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW $1
    fi
  done
}

backup_db() {
  #$1 is the DB name and $2 is the location to save the file
  #tests first to see if DB exists - mysqldump spits out an error if it doesn't
  DBS=`mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW -Bse 'show databases'| egrep -v 'information_schema|mysql'`
  for db in $DBS; do
    if [ "$db" = "$1" ]; then
      echo "Existing DB $1 found, backing up to $2"
      #clear caches and dump all but user cache tables:
      drush -r /var/www/${1} cc all
      mysqldump -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW $1 -r $2
    fi
  done
}

create_db() {
  #$1 is the DB name
  echo "DROP DATABASE IF EXISTS $1" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
  echo "CREATE DATABASE IF NOT EXISTS $1" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
  echo "GRANT ALL ON $1.* TO '$DEFAULT_DB_UN'@'localhost'; FLUSH PRIVILEGES;" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
}

copy_db() {
  #copies DB $1 to $2
  mysqldump -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW $1 -r $TMP_DIR/$1.sql
  echo "CREATE DATABASE IF NOT EXISTS $2" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
  mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW -D$2 < $TMP_DIR/$1.sql
  rm $TMP_DIR/$1.sql
}

drop_db() {
  #$1 is DB name
  echo "DROP DATABASE IF EXISTS $1" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
  echo "USE mysql ; DELETE FROM db WHERE Db='$1'; FLUSH PRIVILEGES;" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW
}

copy_table() {
  #$1 is the project and $2 is the table name
  if [ `echo "SELECT * FROM information_schema.tables WHERE table_schema = '$1' AND table_name = '$2'" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW` ]; then
    echo "CREATE TABLE IF NOT EXISTS ${USER}_sandbox_${2} LIKE $2" | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW $1
  fi
}

case "$COMMAND" in
  # nothing for create_solr, delete_solr, external, or local_private_files
  create)
    backup_db $PROJECT $HOME/${PROJECT}_${DATESTAMP}.sql
    echo "Creating DB....."
    create_db $PROJECT
    copy_db $TEMPLATE $PROJECT
  ;;

  backup)
    echo "Rolling up DB....."
    mkdir -p $BACKUP_DIR/$PROJECT
    copy_db $PROJECT scratch
    delete_sandbox_tables scratch
    backup_db scratch $BACKUP_DIR/$PROJECT/$PROJECT.sql
    gzip $BACKUP_DIR/$PROJECT/$PROJECT.sql
    drop_db scratch
  ;;

  restore)
    backup_db $PROJECT $HOME/${PROJECT}_${DATESTAMP}.sql
    echo "Rolling down DB....."
    create_db $PROJECT
    gunzip -c $BACKUP_DIR/$PROJECT/$PROJECT.sql.gz | mysql -u $DEFAULT_DB_UN -p$DEFAULT_DB_PW $PROJECT
  ;;

  local_all)
    echo "Exporting DB...."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    copy_db $PROJECT scratch
    delete_sandbox_tables scratch
    backup_db scratch $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${DATESTAMP}.sql
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${USER}_${DATESTAMP}.sql
    drop_db scratch
  ;;

  local_files)
    mkdir -p $HOME/${PROJECT}-${COMMAND}
  ;;

  local_db | export)
    echo "Exporting DB...."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    copy_db $PROJECT scratch
    delete_sandbox_tables scratch
    backup_db scratch $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${DATESTAMP}.sql
    drop_db scratch
  ;;

  local_private_db)
    echo "Exporting DB...."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}-${COMMAND}/${PROJECT}_${USER}_${DATESTAMP}.sql
  ;;

  delete)
    echo "Deleting DB....."
    drop_db $PROJECT
  ;;

  sandbox)
    copy_table $PROJECT 'cache'
    copy_table $PROJECT 'cache_menu'
    copy_table $PROJECT 'cache_admin_menu'
  ;;

  copy_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    echo "Copying to sandbox DB....."
    create_db ${PROJECT}_${USER}
    copy_db $PROJECT ${PROJECT}_${USER}
  ;;

  create_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    echo "Creating sandbox DB....."
    create_db ${PROJECT}_${USER}
  ;;

  update_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    echo "Updating sandbox DB....."
    create_db ${PROJECT}_${USER}
    copy_db $PROJECT ${PROJECT}_${USER}
  ;;

  delete_private_db)
    backup_db ${PROJECT}_${USER} $HOME/${PROJECT}_${USER}_${DATESTAMP}.sql
    echo "Deleting sandbox DB....."
    drop_db ${PROJECT}_${USER}
  ;;

esac
