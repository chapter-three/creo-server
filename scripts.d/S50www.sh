#@todo: Run apache2/httpd graceful
#@todo: Add HTTP Authorization

config_settings() {
  #$1 is the connection type (mysql or mysqli), $2 is the new DB username, $3 is the new DB password, $4 is the new DB name and $5 is the path to settings.php
  set_message "Modifying settings.php for sandboxed project $PROJECT"
  sed -i "s|^\\\$db_url = .*|\$db_url = '$1:\\/\\/$2:$3@localhost\\/$4';|" $5
}

copy_if_missing() {
  #copy $1 to $2 if $2 doesn't exist
  if [ ! -f $2 ]; then
    cp $1 $2
  fi
}

case "$COMMAND" in
  create)
    set_message "Setting up $PROJECT in Apache"

    if [ -d $WWW_DIR/$TEMPLATE/sites/all/files ] && [ ! -d $WWW_DIR/$PROJECT/sites/all/files ] ; then
      cp -r $WWW_DIR/$TEMPLATE/sites/all/files $WWW_DIR/$PROJECT/sites/all/files
    else
      mkdir -p $WWW_DIR/$PROJECT/sites/all/files
    fi

    chown -R $WWW_USER:$WWW_GROUP $WWW_DIR/$PROJECT
    chmod -R g+w $WWW_DIR/$PROJECT

    # set up apache
    sed "s/$TEMPLATE/$PROJECT/" $APACHE_DIR/sites-available/$TEMPLATE > $APACHE_DIR/sites-available/$PROJECT
    a2ensite $PROJECT
    $APACHE_SERVICE_PATH reload
  ;;

  backup)
    set_message "Backing up WWW"
    mkdir -p $BACKUP_DIR/$PROJECT
    ( cd $WWW_DIR ; tar czf $BACKUP_DIR/$PROJECT/$PROJECT.www.tar.gz ./$PROJECT )
    ( cd $APACHE_DIR/sites-available ; tar czf $BACKUP_DIR/$PROJECT/$PROJECT.apache-sa.tar.gz $PROJECT )
    if [ -e $APACHE_DIR/htpasswds/$PROJECT.auth ]; then
      ( cd $APACHE_DIR/htpasswds ; tar czf $BACKUP_DIR/$PROJECT/$PROJECT.htpasswds.tar.gz $PROJECT.auth )
    fi
  ;;

  restore)
    set_message "Restoring WWW"

    # get files in place
    mkdir -p $WWW_DIR/$PROJECT
    ( cd $WWW_DIR ; tar xzf $BACKUP_DIR/$PROJECT/$PROJECT.www.tar.gz )
    chown -R $WWW_USER:$WWW_GROUP $WWW_DIR/$PROJECT
    chmod -R g+w $WWW_DIR/$PROJECT

    # set up apache
    ( cd $APACHE_DIR/sites-available ; tar xzf $BACKUP_DIR/$PROJECT/$PROJECT.apache-sa.tar.gz )

    a2ensite $PROJECT
    $APACHE_SERVICE_PATH reload
  ;;

  delete)
    set_message "Removing WWW"
    rm -rf $WWW_DIR/$PROJECT
    rm $APACHE_DIR/sites-enabled/$PROJECT
    rm $APACHE_DIR/sites-available/$PROJECT
    $APACHE_SERVICE_PATH reload
  ;;

  local_all | local_files | export)
    set_message "Getting file directories"
    if [ -d $WWW_DIR/$PROJECT/files ] ; then
      cp -r $WWW_DIR/$PROJECT/files $HOME/${PROJECT}-${COMMAND}/$PROJECT
    fi

    if [ -d $WWW_DIR/$PROJECT/sites/all/files ] ; then
      mkdir -p $HOME/${PROJECT}-${COMMAND}/$PROJECT/sites/all
      cp -r $WWW_DIR/$PROJECT/sites/all/files $HOME/${PROJECT}-${COMMAND}/$PROJECT/sites/all
    fi
  ;;

  copy_private_db)
    config_settings mysqli $DEFAULT_DB_UN $DEFAULT_DB_PW ${PROJECT}_${USER} $HOME/public_html/$PROJECT/sites/$PROJECT.$DOMAIN.~$USER/settings.php
  ;;

  create_private_db)
    config_settings mysql 'username' 'password' 'databasename' $HOME/public_html/$PROJECT/sites/$PROJECT.$DOMAIN.~$USER/settings.php
    chmod -R 775 $HOME/public_html/$PROJECT/sites/$PROJECT.$DOMAIN.~$USER
    chown -R $USER:www-data $HOME/public_html/$PROJECT/sites/$PROJECT.$DOMAIN.~$USER
  ;;

  delete_private_db)
    config_settings mysqli $DEFAULT_DB_UN $DEFAULT_DB_PW $PROJECT $HOME/public_html/$PROJECT/sites/$PROJECT.$DOMAIN.~$USER/settings.php
  ;;
esac
