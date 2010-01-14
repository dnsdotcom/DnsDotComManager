package Cpanel::NameServer::Utils::DNS_COM;

# cpanel - Cpanel/NameServer/Utils/BIND_COM.pm   Copyright(c) 2010 Comwired, Inc.
#                                                           All rights Reserved.
#                                                                 http://dns.com

use strict;
use Cpanel::Sys::OS           ();
use Cpanel::Sys::Find         ();
use Cpanel::Path              ();
use Cpanel::Logger            ();
use Cpanel::FileUtils::Link         ();
use Cpanel::FileUtils::Move         ();
use Cpanel::FileUtils::Copy         ();
use Cpanel::SafeDir::MK       ();
use Cpanel::SafeRun::Errors   ();
use Cpanel::SafetyBits::Chown ();
use RcsRecord                 ();
use Cpanel::SafeFile          ();

our $VERSION = '0.1';
my $logger = Cpanel::Logger->new();

