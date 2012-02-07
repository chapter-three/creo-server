
case "$COMMAND" in
  #nothing for create_solr, delete_solr, external, local_files, local_db, local_private_db, copy_private_db, create_private_db, update_private_db or delete_private_db
  create)
    set_message "Creating GIT repository..."
    cd $GITOLITE_ADMIN_REPO_DIR

    set_message "Copy gitolite $TEMPLATE conf to $PROJECT project conf"
    cp conf/repos/$TEMPLATE.conf $conf/repos/$PROJECT.conf

    # Change the repo name in the file from $TEMPLATE to $PROJECT
    sed -i "s/$TEMPLATE/$PROJECT/" conf/repos/$PROJECT.conf

    # Add the new file to the repo
    git add $PROJECT.conf
    git commit -m "Add $PROJECT.conf"

    set_message "Store the new file in the gitolite-admin repo"
    git push

    # Change to WWW_DIR
    cd $WWW_DIR
    set_message "Cloning $TEMPLATE template into $WWW_DIR/$PROJECT"
    git clone $GITOLITE_REPO_ACCESS:$TEMPLATE $PROJECT
    set_message "Changing origin to $PROJECT repo"
    # Change the origin to be the new PROJECT repo
    git remote rename origin $TEMPLATE
    git remote add origin $GITOLITE_REPO_ACCESS:$PROJECT
    git push origin master
    git config --local branch.master.remote origin

    # Change file ownership to the correct user/group
    chmod -R $WWW_USER:$WWW_GROUP $WWW_DIR/$PROJECT

    #echo "Creating $WWW_DIR/$PROJECT/sites/$PROJECT.$DOMAIN..."
    #mv $TMP_DIR/$PROJECT/sites/$TEMPLATE.$DOMAIN $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN

    #sed -i "s/$TEMPLATE/$PROJECT/" $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN/settings.php
    #cd $TMP_DIR/$PROJECT/sites/; ln -sf $PROJECT.$DOMAIN default

  ;;

  backup)
    echo "Rolling up SVN....."
    mkdir -p $BACKUP_DIR/$PROJECT
    svnadmin dump -q $SVN_DIR/$PROJECT | gzip - > $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz
  ;;

  restore)
    echo "Rolling down SVN....."
    mkdir -p $SVN_DIR/$PROJECT
    svnadmin create $SVN_DIR/$PROJECT --fs-type fsfs
    gunzip -c $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz | svnadmin load -q $SVN_DIR/$PROJECT
    set_svn_permissions $PROJECT
  ;;

  delete)
    echo "Removing SVN....."
    rm -rf $SVN_DIR/$PROJECT
  ;;

  external)
    echo "Checking out a copy from $EXTERNAL..."
    svn checkout $SVN $WWW_DIR/$PROJECT
  ;;

  local_all)
    echo "Getting an export of the trunk for local dev..."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/${PROJECT}-${COMMAND}/$PROJECT
  ;;

  export)
    echo "Getting an export of the trunk..."
    mkdir -p $HOME/${PROJECT}-${COMMAND}
    REPOSITORY=`svn info $WWW_DIR/$PROJECT | grep 'URL' | sed 's/URL: //'`
    svn export $REPOSITORY $HOME/${PROJECT}-${COMMAND}/www
  ;;

  sandbox)
    echo "Creating a $PROJECT sandbox for $USER...."

    if [ -d $HOME/public_html/$PROJECT ] ; then
      echo "Sandbox already exists at $HOME/public_html/$PROJECT"
      exit 1
    fi

    svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/public_html/$PROJECT
  ;;
esac
