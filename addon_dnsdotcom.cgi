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
use File::Basename;

use YAML::Syck;
$YAML::Syck::ImplicitTyping = 1;

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

# create a list of all *.html files in
# the current directory

my @users = ();
#get user domain files
opendir(DIR, '/var/local/dnsdotcom/yaml/user/');
@files = grep(/\.yaml$/,readdir(DIR));
closedir(DIR);

# print all the filenames in our array
foreach $file (@files) {    
    ($base,$path,$type) = fileparse($file,
                                    '\.yaml');
    push(@users, $base);
}

my @domain_array = ();

foreach (@users){
    my $user_total = 0;
    
    print "<h1>Bandwidth Usage for $_</h1><table width='600' border=1><tr><th>Domains</th><th>Bytes Total</th></tr>";
    my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $_ . '.yaml';
    my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
    my @user_data = Load($user_data_import);
    
    my @domains = ();
    for $aref ( @user_data[0]->{domains} ) {
            push(@domains, @$aref);
    }
     
    if (@user_data[0]->{domains}){
        foreach (@domains) {
                $domain = Cpanel::DnsDotComManager::dns_query('getDomains', 'search_term', $_);
                push(@domain_array, {'name'                 => $domain->{data}[0]->{name},
                                     'mode'                 => $domain->{data}[0]->{mode},
                                     'group'                => $domain->{data}[0]->{group},
                                     'date_last_modified'   => $domain->{data}[0]->{date_last_modified},
                                     'date_created'         => $domain->{data}[0]->{date_created},
                                    });
                $domain_hits = Cpanel::DnsDotComManager::dns_query('getHits', 'domain', $_);
                my $domain_total = $domain_hits->{data}->{bytes_total};
                if (!$domain_total){
                    $domain_total = 0;
                }
                $user_total = $user_total+$domain_total;
                if (!$user_total){
                    $user_total = 0;   
                }
                print "<tr><td>$_</td>";
                print "<td>$domain_total</td></tr>";
        }
        #return @domain_array;
    
        print "<tr><td>TOTAL:</td><td> $user_total </td></tr>";

        print "</table>";
        
    }   
}


1;