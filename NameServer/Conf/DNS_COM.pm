package Cpanel::NameServer::Conf::DNS_COM;

# cpanel - Cpanel/NameServer/Conf/BIND_COM.pm   Copyright(c) 2010 Comwired, Inc.
#                                                           All rights Reserved.
#                                                                 http://dns.com

use Storable                        ();
use IO::Handle                      ();
use Cpanel::PwCache                 ();
use Cpanel::SafeFile                ();
use Cpanel::NameServer::Utils::BIND ();
use Cpanel::CommentKiller           ();
use Cpanel::Logger                  ();
use strict;
use bytes;

my $logger = Cpanel::Logger->new();

our $VERSION = '0.1';

my $datastore_version = '0.1';

our $debug = 1;