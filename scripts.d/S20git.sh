#@todo: during create, make DB settings changes work with Pantheon, and imported sites.

create_repo() {
  set_message "Creating GIT repository"
  (
    set_message "Copy gitolite $TEMPLATE conf to $PROJECT project conf"
    cd $GITOLITE_ADMIN_REPO_DIR
    #Make directory if it doesn't exist
    mkdir -p $GITOLITE_ADMIN_REPO_DIR/conf/repos/
    cp $PROJECT_TEMPLATE_FILES/gitolite-repo.conf conf/repos/$PROJECT.conf

    # Change the repo name in the file from PROJECT to $PROJECT
    sed -i "s/PROJECT/$PROJECT/" conf/repos/$PROJECT.conf

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
      git push origin master --tags
      git config --local branch.master.remote origin
    )
  ;;

  import)
    create_repo

    set_message "Importing $IMPORT_REPO into $PROJECT repository."
    (
      cd $TMP_DIR/import-repo
      git remote rename origin source
      git remote add origin $GITOLITE_REPO_ACCESS:$PROJECT
      #Get current branch
      BRANCH=`git branch | grep "*" | sed 's/\* //'`
      # If branch isn't master, post a warning.
      if [ ! $BRANCH = "master" ]; then
        set_message "Non-standard branch selected: $BRANCH" 'warning'
        set_message "Additional configuration is required." 'warning'
      fi
      # Push selected branch to origin, normally master
      git push origin $BRANCH --tags
      #@todo Add a master branch? Something needs to be done to handle Pantheon project imports
    )

    set_message "Cloning $PROJECT repository into $WWW_DIR/$PROJECT"
    su - git -c "git clone $GITOLITE_REPO_DIR/$PROJECT.git $WWW_DIR/$PROJECT"
    # Note the post-receive hooks will update the $WWW_DIR/$PROJECT

  ;;

  backup)
    set_message "Backing up GIT"
    mkdir -p $BACKUP_DIR/$PROJECT
    tar cf $BACKUP_DIR/$PROJECT/$PROJECT.git.tar.gz $GITOLITE_REPO_DIR/$PROJECT.git
  ;;

  restore)
    set_message "Restoring GIT"
    mkdir -p $GITOLITE_REPO_DIR/$PROJECT.git
    tar xf $BACKUP_DIR/$PROJECT/$PROJECT.git.tar.gz -C $GITOLITE_REPO_DIR/$PROJECT.git
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

  sandbox)
    set_message "Creating $PROJECT sandbox for $USER"

    # If public_html doesn't exist, create it.
    if [ ! -d $HOME/public_html ] ; then
      mkdir $HOME/public_html
    fi

    # @todo: check if branch master exists, use different available branch if required
    git clone $GITOLITE_REPO_ACCESS:$PROJECT $HOME/public_html/$PROJECT
  ;;
esac
