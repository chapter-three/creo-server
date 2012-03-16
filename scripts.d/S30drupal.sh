case "$COMMAND" in
  create)

    (
      set_message "Editing sites/default/settings.php to use correct database"
      cd $WWW_DIR/$PROJECT
      # Add sites/default/settings.php to the .git/info/exclude (like .gitignore, but only this clone)
      echo "sites/default/settings.php" >> .git/info/exclude

      sed -i "s/$TEMPLATE/$PROJECT/" sites/default/settings.php
    )
  ;;

  import)
    set_message "Please edit the sites/default/settings.php to use the $PROJECT database." warning
  ;;

  sandbox)
    set_message "Creating symbolic link to files"
    if [ -d $WWW_DIR/$PROJECT/sites/all/files ] ; then
      FILES_DIR=sites/all/files
    elif [ -d $WWW_DIR/$PROJECT/files ] ; then
      FILES_DIR=files
    elif [ -d $WWW_DIR/$PROJECT/sites/default/files ] ; then
      FILES_DIR=sites/default/files
    fi
    if [ -n $FILES_DIR ] ; then
      #@todo: rmdir, make sure directory is empty
      if [ -d $HOME/public_html/$PROJECT/$FILES_DIR ] ; then
        rmdir $HOME/public_html/$PROJECT/$FILES_DIR
      fi
      ln -s $WWW_DIR/$PROJECT/$FILES_DIR $HOME/public_html/$PROJECT/$FILES_DIR
      set_message "Drupal files found at $WWW_DIR/$PROJECT/$FILES_DIR"
    else
      # Complain if a files directory wasn't found.
      set_message "A files directory could not be found." warning
    fi

    # If sites/default/settings.php is not in the clone
    if [ ! -a $HOME/public_html/$PROJECT/sites/default/settings.php ] ; then
      # Is it in $WWW_DIR?
      if [ -a $WWW_DIR/$PROJECT/sites/default/settings.php ] ; then
        # Copy it to the clone
        cp -a $WWW_DIR/$PROJECT/sites/default/settings.php $HOME/public_html/$PROJECT/sites/default/settings.php
      else
        # Complain.
        # @todo: In the future, recreate it.
        set_message "sites/default/settings.php could not be located." warning
      fi
    fi

    (
      set_message "Editing sites/default/settings.php to use correct database"
      cd $HOME/public_html/$PROJECT
      # Add sites/default/settings.php to the .git/info/exclude (like .gitignore, but only this clone)
      echo "sites/default/settings.php" >> .git/info/exclude

      # @todo: Must completely rewrite the DB connection strings
      sed -i "s/$TEMPLATE/$PROJECT/" sites/default/settings.php

      # Add .htaccess to the .git/info/exclude
      echo "sites/default/settings.php" >> .git/info/exclude

      # RewriteBase is required due to the rewrites to project.user.dev.domain.com
      echo "RewriteBase /" >> .htaccess
    )


  ;;


esac
