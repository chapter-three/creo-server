Creo Project - Server

DESCRIPTION
-----------
Manages Drupal 6/7 projects made with Linux, Apache, MySQL, PHP, Solr, Trac, Drush

REQUIRED SOFTWARE
-----------------
1. Apache 2.x (Tested with 2.2.16)
2. MySQL 5.x (Tested with 5.1.49-3)
3. PHP 5.x (Tested with 5.3.3-7)
4. Drush 4.x (Tested with 4.5)
5. Tomcat 6.x (Tested with 6.0.35-1)
6. Solr 1.4.x or 3.5.x (Tested with 1.4.1)
7. Trac 0.x (Tested with 0.12)

NOTES
-----
This script was designed/tested on Debian 6 Squeeze, and also tested on Ubuntu 10.04 Lucid Lynx.
It may be updated in the future to work with RHEL and CentOS.

INSTALLATION
------------
1. Install Apache, MySQL, PHP and Tomcat using the package manager, apt-get or aptitude.
2. Download and install Drush in a globally accessible location. (Often in /usr or /usr/local)
3. Download and setup Solr
4. Download and setup Trac
5. Create Apache, Solr, and Trac template filess
6. Copy creo.conf.sample to creo.conf and adjust the values to match your server
7. Go!

