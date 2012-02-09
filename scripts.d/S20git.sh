#@todo: during create, make DB settings changes work with Pantheon, and imported sites.

create_repo() {
  set_message "Creating GIT repository"
  (
    set_message "Copy gitolite $TEMPLATE conf to $PROJECT project conf"
    cd $GITOLITE_ADMIN_REPO_DIR
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
}

case "$COMMAND" in
  create)
    create_repo

    (
      set_message "Cloning $TEMPLATE template into $WWW_DIR/$PROJECT"
      cd $WWW_DIR
      git clone $GITOLITE_REPO_ACCESS:$TEMPLATE $PROJECT
    )

    (
      set_message "Changing origin to $PROJECT repo"
      cd $WWW_DIR/$PROJECT

      # Change the origin to be the new PROJECT repo
      git remote rename origin $TEMPLATE
      git remote add origin $GITOLITE_REPO_ACCESS:$PROJECT
      git push origin master
      git config --local branch.master.remote origin

    )
  ;;

  import)
    create_repo

    set_message "Importing $IMPORT_REPO into $PROJECT repository."

    (
      cd $TMP_DIR/import-repo
      # @todo: check if origin remote exists
      #git remote rm origin
      git remote add origin GITOLITE_REPO_ACCESS:$PROJECT
      # @todo: check if branch master exists
      git push origin master
    )

    (
      set_message "Cloning $PROJECT repository into $WWW_DIR/$PROJECT"
      cd $WWW_DIR
      git clone $GITOLITE_REPO_ACCESS:$PROJECT $PROJECT
    )

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
    set_message "Creating $PROJECT sandbox for $USER"

    # If public_html doesn't exist, create it.
    if [ ! -d $HOME/public_html ] ; then
      mkdir $HOME/public_html
    fi

    git clone $GITOLITE_REPO_ACCESS:$PROJECT $HOME/public_html/$PROJECT
  ;;
esac
