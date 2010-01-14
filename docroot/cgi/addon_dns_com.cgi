#!/usr/bin/perl
# cpanel - whostmgr/docroot/cgi/addon_dns_com.cgi
#                                                 Copyright(c) 2010 Comwired, Inc.
#                                                           All rights Reserved.
#                                                                 http://dns.com

BEGIN { unshift @INC, '/usr/local/cpanel'; }

use Socket;
use Cpanel::Form            ();
use Cpanel::Hostname        ();
use Cpanel::AcctUtils       ();
use Cpanel::Accounting      ();
use Cpanel::Ips             ();
use Whostmgr::HTMLInterface ();
use Whostmgr::ACLS          ();
use Whostmgr::Version       ();
use Cpanel::AccessIds       ();

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