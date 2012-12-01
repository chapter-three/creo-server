
case "$COMMAND" in
  backup)
    #Backup site using archive
    #Method to list all files: ls -1 -d /var/www/projects/*
    #Method to show last git update : git log -1 --format=%cd --date=iso
    mkdir -p $BACKUP_DIR/$PROJECT
    NOW=$(date +"%m-%d-%Y")
    drush archive-backup -r $WWW_DIR/$PROJECT --generator "Creo Project Manager"  --destination=$BACKUP_DIR/$PROJECT/$PROJECT-$NOW.tar.gz  --overwrite
  ;;

  create | import)
    #Add project to global drush aliases
  ;;

  restore)
    #Add project to global drush aliases
  ;;

  delete)
    #Remove project from global drush aliases
  ;;

  sandbox)
    #Add sandbox to user's drush aliases
  ;;

esac
