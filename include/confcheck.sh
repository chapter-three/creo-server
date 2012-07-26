# Checks for valid settings in the creo.conf file.
# @todo: Complete configuration tests
# @todo: Check location of Linux/Apache/MySQL/PHP/Solr/Trac/Drupal/Drush

# TMP_DIR: Directory to store temporary files/repos

# PROJECT_TEMPLATE_FILES: Stores template files for creating new projects
if [ ! -d $PROJECT_TEMPLATE_FILES ] ; then
  set_message "Project template files directory cannot be found: $PROJECT_TEMPLATE_FILES" error
  exit 1
fi

# APACHE_DIR: The Apache configuration directory (Note: This script is Debian/Ubuntu specific)
if [ ! -d $APACHE_DIR ] ; then
  set_message "Apache HTTP Server cannot be found: $APACHE_DIR" error
  exit 1
fi

# WWW_DIR: The directory to store the web accessible clones of projects
if [ ! -d $WWW_DIR ] ; then
  set_message "The WWW project directory cannot be found: $WWW_DIR" error
  exit 1
fi

# WWW_USER & WWW_GROUP: The user and group owning all files/directories in $WWW_DIR.
if ! grep -q $WWW_USER /etc/passwd; then
  set_message "WWW_USER: '$WWW_USER' does not exist" error
  exit 1
fi

if ! grep -q $WWW_GROUP /etc/group; then
  set_message "WWW_GROUP: '$WWW_GROUP' does not exist" error
  exit 1
fi

# BACKUP_DIR: Directory to store/restore backups to/from

# DOMAIN: The root domain name to use for each project. Will be used in the form: project.DOMAIN.

# MYSQL_USERNAME & MYSQL_PASSWORD: MySQL username and password

# DRUSH_PATH: Full path to run drush
if [ ! -e $DRUSH_PATH ] ; then
  set_message "Drush executable cannot be found: $DRUSH_PATH" error
  exit 1
fi

# GITOLITE_REPO_ACCESS: The user@host access string for use with Gitolite

# GITOLITE_ADMIN_REPO_DIR: Directory for the gitolite-admin repo

# SOLR_DATA_DIR: The data directory for Solr instancesl; will contain bin, conf, and data directories
if [ ! -d $SOLR_DATA_DIR ] ; then
  set_message "The Solr data directory cannot be found: $SOLR_DATA_DIR" error
  exit 1
fi

# TOMCAT_WEBAPP_DIR: The Tomcat web app directory; contains solr.war, and instance admin files
if [ ! -d $TOMCAT_WEBAPP_DIR ] ; then
  set_message "The Tomcat web app directory cannot be found: $TOMCAT_WEBAPP_DIR" error
  exit 1
fi

# TOMCAT_LOCALHOST_DIR: The Tomcat HTTP root directory; contains solr.xml, and instance xml files
if [ ! -d $TOMCAT_LOCALHOST_DIR ] ; then
  set_message "The Tomcat HTTP root directory cannot be found: $TOMCAT_LOCALHOST_DIR" error
  exit 1
fi

# TOMCAT_SERVICE_PATH: Path to the tomcat6 script, must accept restart command
if [ ! -e $TOMCAT_SERVICE_PATH ] ; then
  set_message "Tomcat6 executable cannot be found: $TOMCAT_SERVICE_PATH" error
  exit 1
fi

# TOMCAT_PORT: Port Tomcat is running on

# SOLR_TEMPLATE: The template for new Solr instances, exists if README.mkd is followed
if [ ! -d $SOLR_DATA_DIR/$SOLR_TEMPLATE ] ; then
  set_message "The Solr template data directory cannot be found: $SOLR_DATA_DIR/$SOLR_TEMPLATE" error
  exit 1
fi
if [ ! -e $TOMCAT_LOCALHOST_DIR/$SOLR_TEMPLATE.xml ] ; then
  set_message "The Solr template XML cannot be found: $TOMCAT_LOCALHOST_DIR/$SOLR_TEMPLATE.xml" error
  exit 1
fi
if [ ! -d $TOMCAT_WEBAPP_DIR/$SOLR_TEMPLATE ] ; then
  set_message "The Solr template WebApp cannot be found: $TOMCAT_WEBAPP_DIR/$SOLR_TEMPLATE" error
  exit 1
fi
