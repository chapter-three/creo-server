#!/bin/bash
# Creo Server Project Manager
# Created by eosrei, based on C3 project script by populist, joshk, and jskulski.

# Stop on any errors
set -e

# Store the starting directory
STARTDIR=$PWD

# Make a script name for use in logs
SCRIPTNAME='creo'

FLAGS_HELP="Usage: creo command project [-t template] [-i repository]

Project commands (root required):
create:                    create a project bare or from a template
import:                    import a project from a GIT repo
backup:                    backup a project (archive) - NOT FUNCTIONAL
restore:                   restore a project backup (unarchive) - NOT FUNCTIONAL
delete:                    delete project
create_solr:               create Solr instance for a project
delete_solr:               delete Solr instance for a project

Project commands (root not required):
local_files:               dumps a copy of the project files - NOT FUNCTIONAL
local_db:                  dumps a copy of the project db - NOT FUNCTIONAL
local_private_db:          dumps a copy of the project private sandbox db - NOT FUNCTIONAL

Sandbox commands (root not required)
sandbox:                   creates a project sandbox
create_private_db:         creates a new (blank) private sandbox database - NOT FUNCTIONAL
update_private_db:         updates a private sandbox database from the project database - NOT FUNCTIONAL
delete_private_db:         deletes a private sandbox database - NOT FUNCTIONAL
"

# Get the script's current working directory: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# Consider moving creo.conf to /etc: http://mywiki.wooledge.org/BashFAQ/028
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Include color echo functions (echo_color, set_message)
source $SCRIPTDIR/include/colors

echo -e "Creo Project Manager v0.5 for Linux/Apache/MySQL/PHP/Solr/Drupal/Drush/Gitolite projects\n"

# Check if creo.conf exists
if [ ! -e $SCRIPTDIR/creo-server.conf ]; then
  set_message "Configuration cannot be found. Copy creo-server.conf.sample to creo-server.conf and adjust the values." error
  exit 1
fi

# Include creo.conf
source $SCRIPTDIR/creo-server.conf
source $SCRIPTDIR/include/confcheck.sh

# Allow errors for shflags
set +e
# Include shflags to parse flags
source $SCRIPTDIR/include/shflags

# Set shflags
DEFINE_string template '' "Use specified template instead of the default" t
DEFINE_string import '' "Import the specified repository, any git protocol/path is allowed" i

# Parse the command-line
FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Stop on any errors again. shflags can exit incorrectly with error: http://code.google.com/p/shflags/issues/detail?id=9
set -e

# Make arguments and flags into useful variables
COMMAND=$1
PROJECT=$2
TEMPLATE=${FLAGS_template}
IMPORT_REPO=${FLAGS_import}
DATESTAMP=`date +%Y%m%d%H%M%S`

# Check for at least two arguments
if ! [ $# -ge 2 ]; then
  flags_help
  exit 1
fi

# Check for valid commands
if [[ $1 != 'create' && \
      $1 != 'import' && \
      $1 != 'backup' && \
      $1 != 'restore' && \
      $1 != 'delete' && \
      $1 != 'create_solr' && \
      $1 != 'delete_solr' && \
      $1 != 'local_files' && \
      $1 != 'local_db' && \
      $1 != 'local_private_db' && \
      $1 != 'sandbox' && \
      $1 != 'copy_private_db' && \
      $1 != 'create_private_db' && \
      $1 != 'update_private_db' && \
      $1 != 'delete_private_db' ]] ; then
  flags_help
  exit 1
fi

# If a command requires sudo, make sure we're root.
if [[ ( $1 = 'create' || \
        $1 = 'import' || \
        $1 = 'backup' || \
        $1 = 'restore' || \
        $1 = 'delete' || \
        $1 = 'external' ) \
        && $USER != "root" ]] ; then
  set_message "The $1 command requires root. Use sudo." error
  exit 1
fi

# Run all script commands in $SCRIPTDIR/scripts.d
for script in $( ls $SCRIPTDIR/scripts.d/S* ) ; do
  source $script
done
