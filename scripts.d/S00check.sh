# Error check command options

case "$COMMAND" in
  create)
    if [ ! -d $WWW_DIR/$TEMPLATE ] ; then
      set_message "Template $TEMPLATE does not exist in $WWW_DIR" error
      exit 1
    fi
    if [ -d $WWW_DIR/$PROJECT ] ; then
      set_message "Project $PROJECT already exists in $WWW_DIR" error
      exit 1
    fi
    if [ -d $GITOLITE_REPO_DIR/$PROJECT.git ] ; then
      set_message "Git $PROJECT repo already exists." error
      exit 1
    fi
  ;;
esac

