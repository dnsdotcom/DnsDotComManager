#!/usr/bin/perl
# cpanel - whostmgr/docroot/cgi/addon_dns_com.cgi
#                                                 Copyright(c) 2010 Comwired, Inc.
#                                                           All rights Reserved.
#                                                                 http://dns.com
#WHMADDON:dns_com:DNS.com Integration
#ACLS:list-accts

use lib '/usr/local/cpanel/';

use Socket;
use Cpanel::Form            ();
use Whostmgr::HTMLInterface ();
use Whostmgr::ACLS          ();

use Cpanel::NameServer::Conf::DNS_COM          ();
use Cpanel::NameServer::Utils::DNS_COM         ();

my %FORM = Cpanel::Form::parseform();

printPage();

#################################################
#
#################################################
sub printPage {
    print "Content-Type: text/html\n\n";
    print <<"EOM";
    something something
    EOM
}