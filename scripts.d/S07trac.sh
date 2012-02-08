
case "$COMMAND" in
  #nothing for create_solr, delete_solr, external, local_all, local_files, local_db, local_private_db, export, sandbox, copy_private_db, create_private_db, update_private_db or delete_private_db
  create)
    echo "Creating Trac...."
    cp -ra /var/trac/$TEMPLATE /var/trac/$PROJECT
    sed -i '/file =/ d' $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/origin.dir/ c\origin.dir = $GITOLITE_REPO_DIR/$PROJECT.git" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/repository_dir/ c\repository_dir = $GITOLITE_REPO_DIR/$PROJECT.git" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/base_url = / c\base_url = $PROJECT.$DOMAIN/trac" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/descr =/ c\descr = $PROJECT is a project built from $TEMPLATE" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/name =/ c\name = $PROJECT" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/alt =/ c\alt = $PROJECT" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/url =/ c\url = $PROJECT.$DOMAIN" $TRAC_DIR/$PROJECT/conf/trac.ini
    sed -i "/link =/ c\link = https://$PROJECT.$DOMAIN/trac/var/" $TRAC_DIR/$PROJECT/conf/trac.ini
    #This bug was driving me crazy http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=634826
    trac-admin /var/trac/$PROJECT repository resync '*'
  ;;

  backup)
    echo "Rolling up Trac...."
    mkdir -p $BACKUP_DIR/$PROJECT
    ( cd $TRAC_DIR ; tar czf $BACKUP_DIR/$PROJECT/$PROJECT.trac.tar.gz ./$PROJECT ) && exit 0
  ;;

  restore)
    echo "Rolling down Trac...."
    mkdir -p $TRAC_DIR/$PROJECT
    ( cd $TRAC_DIR ; tar xzf $BACKUP_DIR/$PROJECT/$PROJECT.trac.tar.gz ) && exit 0
  ;;

  delete)
    echo "Removing Trac...."
    rm -rf $TRAC_DIR/$PROJECT
  ;;
esac
