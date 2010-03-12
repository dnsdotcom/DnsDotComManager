#!/usr/bin/perl
#WHMADDON:dnsdotcom:DNS.com Reseller Admin

###############################################################################
#  DNS.com Reseller Admin
###############################################################################
# Load general use case perl modules
use lib '/usr/local/cpanel';
use Cpanel::cPanelFunctions ();
use Cpanel::Form            ();
use Cpanel::Config          ();
use Whostmgr::HTMLInterface ();
use Cpanel::DnsDotComManager ();

use Whostmgr::ACLS          ();
###############################################################################
print "Content-type: text/html\r\n\r\n";
# Check user has root permissions
Whostmgr::ACLS::init_acls();
if ( !Whostmgr::ACLS::hasroot() ) {
# User is not root, tell them where to go
print "You need to be root.\n";

exit();
}

# Parse input parameters from GET and POST into $FORM{} for later use
my %FORM     = Cpanel::Form::parseform();

# Print a WHM Header
Whostmgr::HTMLInterface::defheader( "DNS.com Reseller Admin",'/cgi/dnsicon.jpg', '/cgi/addon_dnsdotcom.cgi' );

# Print General Output
my @domains = Cpanel::DnsDotComManager::api2_getDomains();
my %domain_query = '';
my $domain_name = '';
my $user_total = 0;

print "<table width='600' border=1><tr><th>Domains</th><th>Bytes Total</th></tr>";

foreach (@domains){
    $domain_name = $_->{name}; 
    $domain_query = Cpanel::DnsDotComManager::dns_query('getHits', 'domain', $domain_name);
    my $domain_total = $domain_query->{meta}->{bytes_total};
    if (!$domain_total){
        $domain_total = 0;
    }
    print "<tr><td>$domain_query->{meta}->{domain}</td>";
    print "<td>$domain_total</td></tr>";
    $user_total = $user_total+$domain_total;
    
}
if (!$user_total){
    $user_total = 0;   
}
print "<tr><td>TOTAL:</td><td> $user_total </td></tr>";

print "</table>";

1;