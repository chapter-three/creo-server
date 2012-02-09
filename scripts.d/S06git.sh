
case "$COMMAND" in
  #nothing for create_solr, delete_solr, external, local_files, local_db, local_private_db, copy_private_db, create_private_db, update_private_db or delete_private_db
  create)
    set_message "Creating GIT repository"
    (
      cd $GITOLITE_ADMIN_REPO_DIR
      set_message "Copy gitolite $TEMPLATE conf to $PROJECT project conf"
      cp conf/repos/$TEMPLATE.conf conf/repos/$PROJECT.conf

      # Change the repo name in the file from $TEMPLATE to $PROJECT
      sed -i "s/$TEMPLATE/$PROJECT/" conf/repos/$PROJECT.conf

      # Add the new file to the repo
      git add conf/repos/$PROJECT.conf
      git commit -m "$SCRIPTNAME - Add $PROJECT.conf"

      # Store the new file in the gitolite-admin repo
      git push
      #Automatically add new host to known_hosts:
      #ssh-keyscan localhost -t rsa >> ~/.ssh/known_hosts
    )
    (
      # Change to WWW_DIR
      cd $WWW_DIR
      set_message "Cloning $TEMPLATE template into $WWW_DIR/$PROJECT"
      git clone $GITOLITE_REPO_ACCESS:$TEMPLATE $PROJECT
      set_message "Changing origin to $PROJECT repo"
    )
    (
      # Change the origin to be the new PROJECT repo
      cd $WWW_DIR/$PROJECT
      git remote rename origin $TEMPLATE
      git remote add origin $GITOLITE_REPO_ACCESS:$PROJECT
      git push origin master
      git config --local branch.master.remote origin

      # Change file ownership to the correct user/group
      chown -R $WWW_USER:$WWW_GROUP $WWW_DIR/$PROJECT
    )

    #echo "Creating $WWW_DIR/$PROJECT/sites/$PROJECT.$DOMAIN"
    #mv $TMP_DIR/$PROJECT/sites/$TEMPLATE.$DOMAIN $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN

    #sed -i "s/$TEMPLATE/$PROJECT/" $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN/settings.php
    #cd $TMP_DIR/$PROJECT/sites/; ln -sf $PROJECT.$DOMAIN default
  ;;

  backup)
    set_message "Backing up GIT"
    mkdir -p $BACKUP_DIR/$PROJECT
    tar cf $BACKUP_DIR/$PROJECT/$PROJECT.svn.tar.gz $GITOLITE_REPO_DIR/$PROJECT.git
  ;;

  restore)
    set_message "Restoring GIT"
    mkdir -p $GITOLITE_REPO_DIR/$PROJECT.git
    tar xf $BACKUP_DIR/$PROJECT/$PROJECT.svn.tar.gz -C $GITOLITE_REPO_DIR/$PROJECT.git
    #@todo Add back to gitolite, if needed.
  ;;

  delete)
    set_message "Removing GIT repository"
    (
      cd $GITOLITE_ADMIN_REPO_DIR
      git rm conf/repos/$PROJECT.conf
      git commit -m "$SCRIPTNAME - Delete $PROJECT.conf"
      # Store the change in the gitolite-admin repo
      git push
    )
    rm -rf $GITOLITE_REPO_DIR/$PROJECT.git

  ;;

#  local_all)
#    echo "Getting an export of the trunk for local dev"
#    mkdir -p $HOME/${PROJECT}-${COMMAND}
#    svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/${PROJECT}-${COMMAND}/$PROJECT
#  ;;


  sandbox)
    set_message "Creating a $PROJECT sandbox for $USER"

    if [ -d $HOME/public_html/$PROJECT ] ; then
      set_message "Sandbox already exists at $HOME/public_html/$PROJECT" error
      exit 1
    fi

    git clone $GITOLITE_REPO_ACCESS:$PROJECT $HOME/public_html/$PROJECT
  ;;
esac
