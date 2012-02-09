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

  sandbox)
    set_message "Creating symbolic link to files"
    if [ -d $WWW_DIR/$PROJECT/sites/all/files ] ; then
      ln -s $WWW_DIR/$PROJECT/sites/all/files $HOME/public_html/$PROJECT/sites/all/files
    fi

    if [ -d $WWW_DIR/$PROJECT/files ] ; then
      ln -s $WWW_DIR/$PROJECT/files $HOME/public_html/$PROJECT/files
    fi

    if [ -d $WWW_DIR/$PROJECT/files ] ; then
      ln -s $WWW_DIR/$PROJECT/files $HOME/public_html/$PROJECT/files
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
