package	Cpanel::DnsDotComManager;

use strict;
#use warnings; 
use Data::Dumper;
use Cpanel::LoadFile      ();
use Cpanel::FileUtils     ();


use JSON::PP;
use URI::Escape;
use LWP 5.64;
#use LWP::Protocol::http ();



my $browser = LWP::UserAgent->new;

our $VERSION = '0.1';

my $cmd = '';

sub dns_query{    
    my $tokenfile = '/var/local/dnsdotcom/' . $Cpanel::user . '-dns-dot-com-token';
    my $AUTH_TOKEN = uri_escape(Cpanel::LoadFile::loadfile($tokenfile));
    
    my $hostname    = 'sandbox.comwired.com';
    
    $cmd               = $_[0];

    my $opt_field1       = uri_escape($_[1]);
    my $opt_field1_value = uri_escape($_[2]);
    my $opt_field2       = uri_escape($_[3]);
    my $opt_field2_value = uri_escape($_[4]);
    my $opt_field3       = uri_escape($_[5]);
    my $opt_field3_value = uri_escape($_[6]);
    my $opt_field4       = uri_escape($_[7]);
    my $opt_field4_value = uri_escape($_[8]);
    my $opt_field5       = uri_escape($_[9]);
    my $opt_field5_value = uri_escape($_[10]);
    my $opt_field6       = uri_escape($_[11]);
    my $opt_field6_value = uri_escape($_[12]);
    my $opt_field7       = uri_escape($_[13]);
    my $opt_field7_value = uri_escape($_[14]);
    my $opt_field8       = uri_escape($_[15]);
    my $opt_field8_value = uri_escape($_[16]);
    my $opt_field9       = uri_escape($_[17]);
    my $opt_field9_value = uri_escape($_[18]);
    my $opt_field10       = uri_escape($_[19]);
    my $opt_field10_value = uri_escape($_[20]);
    my $opt_field11       = uri_escape($_[21]);
    my $opt_field11_value = uri_escape($_[22]);
    my $opt_field12       = uri_escape($_[23]);
    my $opt_field12_value = uri_escape($_[24]);
    
    my $opt1              = '';
    my $opt2              = '';
    my $opt3              = '';
    my $opt4              = '';
    my $opt5              = '';
    my $opt6              = '';
    my $opt7              = '';
    my $opt8              = '';
    my $opt9              = '';
    my $opt10             = '';
    my $opt11             = '';
    my $opt12             = '';
    
    if ($opt_field1_value){
        $opt1 = "&$opt_field1=$opt_field1_value";
    }
    if ($opt_field2_value){
        $opt2 = "&$opt_field2=$opt_field2_value";
    }
    if ($opt_field3_value){
        $opt3 = "&$opt_field3=$opt_field3_value";
    }
    if ($opt_field4_value){
        $opt4 = "&$opt_field4=$opt_field4_value";
    }
    if ($opt_field5_value){
        $opt5 = "&$opt_field5=$opt_field5_value";
    }
    if ($opt_field6_value){
        $opt6 = "&$opt_field6=$opt_field6_value";
    }
    if ($opt_field7_value){
        $opt7 = "&$opt_field7=$opt_field7_value";
    }
    if ($opt_field8_value){
        $opt8 = "&$opt_field8=$opt_field8_value";
    }
    if ($opt_field9_value){
        $opt9 = "&$opt_field9=$opt_field9_value";
    }
    if ($opt_field10_value){
        $opt10 = "&$opt_field10=$opt_field10_value";
    }
    if ($opt_field11_value){
        $opt11 = "&$opt_field11=$opt_field11_value";
    }
    if ($opt_field12_value){
        
        $opt12 = "&$opt_field12=$opt_field12_value";
    }

    
    my $url = "http://$hostname/api/$cmd/?AUTH_TOKEN=$AUTH_TOKEN$opt1$opt2$opt3$opt4$opt5$opt6$opt7$opt8$opt9$opt10$opt11$opt12";
    my $response = $browser->get( $url );
    my $json = new JSON::PP;
    my $domain_data = $json->decode($response->content);
    return $domain_data;
}

sub api2_changeAuthToken{
    my @meta = (); 
    my %OPTS = @_;
    my $AUTH_TOKEN  = $OPTS{'AUTH_TOKEN'};

    $AUTH_TOKEN =~ s/&gt;/>/g;
    $AUTH_TOKEN =~ s/&lt;/</g;
    my $tokenfile = "/var/local/dnsdotcom/" . $Cpanel::user . "-dns-dot-com-token";
    Cpanel::FileUtils::writefile( $tokenfile, $AUTH_TOKEN );
    return $meta->{message} = "Authorization Token Updated";
}


sub api2_countDomains{
    $cmd = 'getDomains';
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'}; 
    
    my $domain_data = dns_query($cmd, 'search_term', $search_term);
    my $meta        = ();
    my @domain_array = ();
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        return $meta;
    }else{
        my $count = 0;
        foreach my $domain(@{$domain_data->{data}}){
            $count = $count+1;
        }
        push(@domain_array, {'count' => $count,});
    }
    return @domain_array;
}

sub api2_getDomains{
    # Optional Search Term
    $cmd = 'getDomains';
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'}; 
    
    my $domain_data = dns_query($cmd, 'search_term', $search_term);
    my $meta        = ();
    my @domain_array = ();
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        return $meta;
    }else{

        foreach my $domain(@{$domain_data->{data}}){
            $count = $count+1;
            push(@domain_array, {'name'                 => $domain->{name},
                                 'mode'                 => $domain->{mode},
                                 'group'                => $domain->{group},
                                 'date_last_modified'   => $domain->{date_last_modified},
                                 'date_created'         => $domain->{date_created},
                                 });    
        }
    }
        return @domain_array;
}

sub api2_getHostnamesForDomain{
    $cmd = 'getHostnamesForDomain';
    my %OPTS = @_;
    my $domain_name = $OPTS{'domain_name'}; 
    
    my $hosts_data = dns_query($cmd, 'domain', $domain_name);
    my $meta        = ();
    my @hosts_array = ();
    if ($hosts_data->{meta}->{success} == 0){
        $meta->{error}   = $hosts_data->{meta}->{error};
        $meta->{success} = $hosts_data->{meta}->{success};
        print "$meta->{error}\n";
        return $meta;
    }else{
        foreach my $host(@{$hosts_data->{data}}){
            if(!$host->{name}){
                $host->{name} = ' ';
            }
            push(@hosts_array, {'name'                  => $host->{name},
                                'date_created'          => $host->{date_created},
                                'date_last_modified'    => $host->{date_last_modified},});    
        }
        
    }
        return @hosts_array;
}


sub api2_getHostnamesForGroup{
    $cmd = 'getHostnamesForGroup';
    my %OPTS = @_;
    my $group_name = $OPTS{'group_name'}; 
    
    my $hosts_data = dns_query($cmd, 'group', $group_name);
    my $meta        = ();
    my @hosts_array = ();
    if ($hosts_data->{meta}->{success} == 0){
        $meta->{error}   = $hosts_data->{meta}->{error};
        $meta->{success} = $hosts_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $host(@{$hosts_data->{data}}){
            if(!$host->{name}){
                $host->{name} = ' ';
            }
            push(@hosts_array, {'name'                  => $host->{name},
                                'date_created'          => $host->{date_created},
                                'date_last_modified'    => $host->{date_last_modified},
                            });    
        }
        
    }
        return @hosts_array;
}

sub api2_getRRSetForHostname{
    $cmd = 'getRRSetForHostname';
    my %OPTS = @_;
    my $host_name = $OPTS{'host_name'};
    my $domain_name = $OPTS{'domain_name'};
    my $group_name = $OPTS{'group_name'};
    
    my $hosts_data = dns_query($cmd, 'host', $host_name, 'domain', $domain_name, 'group', $group_name);
    my $meta        = ();
    my @hosts_array = ();
    if ($hosts_data->{meta}->{success} == 0){
        $meta->{error}   = $hosts_data->{meta}->{error};
        $meta->{success} = $hosts_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $host(@{$hosts_data->{data}}){
            push(@hosts_array, {'city'                  => $host->{city},
                                'date_last_modified'    => $host->{date_last_modified},
                                'country'               => $host->{country},
                                'region'                => $host->{region},
                                'priority'              => $host->{priority},
                                'answer'                => $host->{answer},
                                'date_created'          => $host->{date_created},
                                'type'                  => $host->{type},
                                'id'                    => $host->{id},
                                'ttl'                   => $host->{ttl},
                                'is_wildcard'           => $host->{is_wildcard},
                                });    
        }
        
    }
        return @hosts_array;
}

sub api2_getDomainGroups {
    ################
    # Optional Search Term
    ########
    $cmd = 'getDomainGroups';
    
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'}; 
    my $domain_group_data = dns_query($cmd, 'search_term', $search_term);
    my @domain_group_array = ();
    my $meta        = ();
    
    if ($domain_group_data->{meta}->{success} == 0){
        $meta->{success} = $domain_group_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $domain_group(@{$domain_group_data->{data}}){
            push(@domain_group_array, {'name'           => $domain_group->{name},
                                       'date_created'   => $domain_group->{date_created},
                                       });  
        }
        return @domain_group_array;
    }
}

sub api2_getDomainsInGroup {
    ######
    # Requires Group Name
    ##
    $cmd = 'getDomainsInGroup';
    
    my %OPTS = @_;
    my $group_name  = $OPTS{'group_name'};   
    
    my $domain_data = dns_query($cmd, 'group', $group_name);
    my @domain_array = ();
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $domain(@{$domain_data->{data}}){
             push(@domain_array, {'name'                 => $domain->{name},
                                 'mode'                 => $domain->{mode},
                                 'group'                => $domain->{group},
                                 'date_last_modified'   => $domain->{date_last_modified},
                                 'date_created'         => $domain->{date_created},
                                 }); 
        }
        return @domain_array;
    }
}

sub api2_getCountryGroups {
    ################
    # Optional Search Term
    ########
    
    $cmd = 'getCountryGroups';
    my $search_term  = $_[0];
    my $country_group_data = dns_query($cmd, 'search_term', $search_term);
    my @country_group_array = ();
    my $meta        = ();
    
    if ($country_group_data->{meta}->{success} == 0){
        $meta->{success} = $country_group_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $country_group(@{$country_group_data->{data}}){
            push(@country_group_array, {'name' => $country_group->{name}});
        }
        return @country_group_array;
    }
}

sub api2_getCountriesInCountryGroup {
    ######
    # Requires countryGroup Name
    ##
    $cmd = 'getCountriesInCountryGroup';
    
    my %OPTS = @_;
    my $country_group_name  = $OPTS{'coutry_group_name'};   
    
    my $country_data = dns_query($cmd, 'countryGroup', $country_group_name);
    my @country_array = ();
    my $meta        = ();
    
    if ($country_data->{meta}->{success} == 0){
        $meta->{error}   = $country_data->{meta}->{error};
        $meta->{success} = $country_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $country(@{$country_data->{data}}){
            push(@country_array, {'name' => $country->{name}});  
        }
        return @country_array;
    }
}


sub api2_createDomainGroup {
    ######
    # Requires Group Name
    ##
    
    $cmd = 'createDomainGroup';
    my %OPTS = @_;
    my $group_name  = $OPTS{'group_name'};
    die "ERROR: Please enter a group name!" unless defined $group_name;
    
    my $group_data  = dns_query($cmd, 'name', $group_name);
    my $meta        = ();
    
    if ($group_data->{meta}->{success} == 1){
        $meta->{id}                    = $group_data->{meta}->{id};
        $meta->{success}               = $group_data->{meta}->{success};
            
        print "<b>CREATED DOMAIN GROUP</b>: $group_name";        
        return $meta;
    }else{
        print $group_data->{meta}->{error};
    }
}

sub api2_createDomain {
    #################
    # Required Fields:
    #       mode - string value of operational mode
    #       domain - string value of domain name
    # Optional Fields:
    #       group - string value of the group name to add domain to
    #       trafficDestination -Only used when 'mode' is 'custom' & must be an existing trafficDestination (ref. getTrafficDestinations)
    #
    # IMPORTANT: must be pass variables in order.
    #####
    
    $cmd = 'createDomain';
    
    my @domain_array = ();
    my %OPTS = @_;
    my $domain_mode = $OPTS{'domain_mode'};
    my $domain_name = $OPTS{'domain_name'};
    
    my $domain_group  = $OPTS{'domain_group'};
    my $domain_td     = $OPTS{'domain_td'};
    
    
    
    my $domain_data  = dns_query($cmd, 'mode', $domain_mode, 'domain', $domain_name, 'group', $domain_group, 'trafficDestination', $domain_td);
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        $meta->{trafficDestination_id} = $domain_data->{meta}->{trafficDestination_id};
        
        push(@domain_array, {'message'   => "<b>CREATED DOMAIN:</b> $domain_name </br>"});        
    }else{
        push(@domain_array, {'message'   => $domain_data->{meta}->{error}}); 
    }
    return @domain_array;
}

sub api2_createHostname {
    #################
    # Identifier Fields:
    #       domain - string value of domain name
    #       group - string value of group name
    # Required Fields:
    #       host - string value of the group name to add to the domain if mode is group.
    # Optional Fields:
    #       is_urlforward - setup bit if you want to hostname as url forward
    #       default - set address for all undefined traffic to go to
    #####

    $cmd = 'createHostname';
    my %OPTS = @_;
    my $domain          = $OPTS{'domain'};
    my $group           = $OPTS{'group'};
    my $host            = $OPTS{'host'};
    my $is_urlforward   = $OPTS{'is_urlforward'};
    my $default         = $OPTS{'default'};

    my $host_data  = dns_query($cmd, 'group', $group, 'domain', $domain, 'host', $host, 'is_urlforward', $is_urlforward, 'default', $default);
    my $meta        = ();
    
    if ($host_data->{meta}->{success} == 1){
        $meta->{id}                    = $host_data->{meta}->{id};
        $meta->{success}               = $host_data->{meta}->{success};
        
        #print "$host : $domain$group <br>";
    }else{
        print $host_data->{meta}->{error};
    }
    
}

sub api2_createRRData {
    $cmd = 'createRRData';
    my %OPTS = @_;
    # identifier vars
    my $domain  = $OPTS{'domain'};
    my $group   = $OPTS{'group'};
    
    #required vars
    my $host    = $OPTS{'host'};
    my $type    = $OPTS{'type'};
    my $rdata   = $OPTS{'rdata'};
    
    #optional vars
    my $countryGroup    = $OPTS{'countryGroup'};
    my $country_Iso2    = $OPTS{'country_Iso2'};
    my $region          = $OPTS{'region'};
    my $city            = $OPTS{'city'};
    my $priority        = $OPTS{'priority'};
    my $is_wildcard     = $OPTS{'is_wildcard'};
    my $ttl             = $OPTS{'ttl'};
    
    my $domain_group  = $OPTS{'domain_group'};
    
    my $domain_data  = dns_query($cmd,
                                 'domain',          $domain,
                                 'group',           $group,
                                 'host',            $host,
                                 'type',            $type,
                                 'rdata',           $rdata,
                                 'countryGroup',    $countryGroup,
                                 'country_Iso2',    $country_Iso2,
                                 'region',          $region,
                                 'city',            $city,
                                 'priority',        $priority,
                                 'is_wildcard',     $is_wildcard,
                                 'ttl',             $ttl,
                                );
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        
        print "<b>CREATED HOST:</b> $host </br>";        
        #return $meta;
    }else{
        print $domain_data->{meta}->{error};
    }
}



sub api2_deleteDomain {
    #################
    # Required Fields:
    #       mode - string value of operational mode
    #       domain - string value of domain name
    # Optional Fields:
    #       group - string value of the group name to add to the domain if mode is group.
    #
    # IMPORTANT: must be pass variables in order.
    #####
    
    $cmd = 'deleteDomain';
    
    my %OPTS = @_;
    my $domain_mode = $OPTS{'domain_mode'};
    die "ERROR: Please enter a domain mode!" unless defined $domain_mode;
    my $domain_name = $OPTS{'domain_name'};
    die "ERROR: Please enter a domain name!" unless defined $domain_name;
    
    my $domain_group  = $OPTS{'domain_group'};
    
    my $domain_data  = dns_query($cmd, 'mode', $domain_mode, 'domain', $domain_name, 'group', $domain_group, 'confirm', 1);
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        
            
        print "<b>DELETED DOMAIN:</b> $domain_name <br>";
    }else{
        print $domain_data->{meta}->{error};
    }
}

sub api2_removeDomainGroup {
    #################
    # Required Fields:
    #       group - string value of operational mode
    #       confirm - string value of domain name
    # Optional Fields:
    #       group - string value of the group name to add to the domain if mode is group.
    #
    # 
    #####
    
    $cmd = 'removeDomainGroup';
    
    my %OPTS = @_;
    my $group_name = $OPTS{'group_name'};
    die "ERROR: Please enter a domain name!" unless defined $group_name;

    
    my $group_data  = dns_query($cmd, 'group', $group_name, 'confirm', 1);
    my $meta        = ();
    
    if ($group_data->{meta}->{success} == 1){
        $meta->{id}                    = $group_data->{meta}->{id};
        $meta->{success}               = $group_data->{meta}->{success};
        
            
        print "<b>DELETED DOMAIN GROUP:</b> $group_name <br>";
    }else{
        print $group_data->{meta}->{error};
    }
    
}

sub api2_deleteHostname {
    
    my %OPTS = @_;
    my $group = $OPTS{'group'};
    my $domain = $OPTS{'domain'};
    my $host = $OPTS{'host'};
    
    #if ($domain){
    #    my $host  = dns_query('getHostnamesForDomain', 'domain', $domain, 'confirm', 1);
    #}elsif($group){
    #    my $host  = dns_query('getHostnamesForGroup', 'group', $group, 'confirm', 1);
    #}
        
    my $host_data  = dns_query('removeHostname', 'host', $host, 'group', $group, 'domain', $domain, 'confirm', 1);
    die "ERROR: Failed to remove Host!" unless defined $host_data;
    
    #my $rr_data  = dns_query('removeRR', 'rr_id', $host->{data}->{id}, 'confirm', 1);
    #die "ERROR: Failed to remove RR data!" unless defined $rr_data;
    
    my $meta        = ();
    
    if ($host_data->{meta}->{success} == 1){
        $meta->{id}                    = $host_data->{meta}->{id};
        $meta->{success}               = $host_data->{meta}->{success};
        
            
        print "<b>DELETED HOST:</b> $host : $group$domain <br>";
    }else{
        print $host_data->{meta}->{error};
    }
    
}


sub api2_getGeoGroups {
    # Optional Search Term
    $cmd = 'getGeoGroups';
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'}; 
    
    my $geogroup_data = dns_query($cmd, 'search_term', $search_term);
    my $meta        = ();
    my @geogroup_array = ();
    if ($geogroup_data->{meta}->{success} == 0){
        $meta->{error}   = $geogroup_data->{meta}->{error};
        $meta->{success} = $geogroup_data->{meta}->{success};
        return $meta;
    }else{

        foreach my $geogroup(@{$geogroup_data->{data}}){
            push(@geogroup_array, {'name'   => $geogroup->{name},
                                'editable'  => $geogroup->{editable},
                                'id'        => $geogroup->{id},
                                 });    
        }
    }
    return @geogroup_array;
}

sub api2_createGeoGroup {    
    $cmd = 'createGeoGroup';
    my @geogroup_array = ();
    my $meta        = ();
    
    my %OPTS = @_;
    my $geogroup_name = $OPTS{'geogroup_name'};

    my $geogroup_data  = dns_query($cmd, 'name', $geogroup_name);
    
    if ($geogroup_data->{meta}->{success} == 1){
        $meta->{id}                    = $geogroup_data->{meta}->{id};
        $meta->{success}               = $geogroup_data->{meta}->{success};
        
        push(@geogroup_array, {'message'   => "<b>CREATED DOMAIN:</b> $domain_name </br>"});    
    }else{
        push(@geogroup_array, {'message'   => $geogroup_data->{meta}->{error}}); 
    }
    return @geogroup_array;
}

sub api2_getGeoGroupDetails {
# Optional Search Term
    $cmd = 'getGeoGroupDetails';
    my %OPTS = @_;
    my $geogroup_name = $OPTS{'geogroup_name'}; 
    
    my $geogroup_data = dns_query($cmd, 'name', $geogroup_name);
    my $meta        = ();
    my @geogroup_array = ();
    if ($geogroup_data->{meta}->{success} == 0){
        $meta->{error}   = $geogroup_data->{meta}->{error};
        $meta->{success} = $geogroup_data->{meta}->{success};
        return $meta;
    }else{

        foreach my $geogroup(@{$geogroup_data->{data}}){
            push(@geogroup_array, {'name'       => $geogroup->{name},
                                'editable'      => $geogroup->{editable},
                                'date_created'  => $geogroup->{date_created},
                                'id'            => $geogroup->{id},
                                 });    
        }
    }
    return @geogroup_array;
}
sub api2_appendToGeoGroup {
    $cmd = 'appendToGeoGroup';
    
    my @geogroup_array = ();
    my %OPTS = @_;
    my $name        = $OPTS{'geogroup_name'};
    my $iso2_code   = $OPTS{'iso2_code'};
    my $region      = $OPTS{'region'};
    my $city        = $OPTS{'city'};
    
    my $geogroup_data  = dns_query($cmd, 'name', $name, 'iso2_code', $iso2_code, 'region', $region, 'city', $city);
    my $meta        = ();
    
    push(@geogroup_array, {'message'  => $geogroup_data->{meta}->{message},
                             'id'       => $geogroup_data->{meta}->{id}});        
    return @dgeogroup_array;
}

sub api2_removeGeoGroup {
    $cmd = 'removeGeoGroup';
    
    my %OPTS = @_;
    my $name = $OPTS{'geogroup_name'};
    my @geogroup_array = ();
    my $meta        = ();
    my $geogroup_data  = dns_query($cmd, 'name', $name, 'confirm', 1);
    
    
    if ($geogroup_data->{meta}->{success} == 1){
        $meta->{id}                    = $geogroup_data->{meta}->{id};
        $meta->{success}               = $geogroup_data->{meta}->{success};
        
            
        push(@geogroup_array, {'message'   => uri_escape("<b>CREATED GEO GROUP:</b> $name </br>")});    
    }else{
        push(@geogroup_array, {'message'   => $geogroup_data->{meta}->{error}}); 
    }
    return @geogroup_array;
}
###
#Api2 call names
##
sub api2 {
    my %API2 = (
        'getDomains' => {
            'func' => 'api2_getDomains',
            'engine' => 'hasharray',
        },
        'countDomains' => {
            'func' => 'api2_countDomains',
            'engine' => 'hasharray',
        },
        'getDomainGroups' => {
            'func' => 'api2_getDomainGroups',
            'engine' => 'hasharray',
        },
        'getDomainsInGroup' => {
            'func' => 'api2_getDomainsInGroup',
            'engine' => 'hasharray',
        },
        'getCountryGroups' => {
            'func' => 'api2_getCountryGroups',
            'engine' => 'hasharray',
        },
        'getCountriesInCountryGroup' => {
            'func' => 'api2_getCountriesInCountryGroup',
            'engine' => 'hasharray'
        },
        'createDomainGroup' => {
            'func' => 'api2_createDomainGroup',
            'engine' => 'hasharray'
        },
        'createDomain' => {
            'func' => 'api2_createDomain',
            'engine' => 'hasharray'
        },
        'deleteDomain' => {
            'func' => 'api2_deleteDomain',
            'engine' => 'hasharray'
        },
        'removeDomainGroup' => {
            'func' => 'api2_removeDomainGroup',
            'engine' => 'hasharray'
        },
        'getHostnamesForDomain' => {
            'func' => 'api2_getHostnamesForDomain',
            'engine' => 'hasharray'
        },
        'getHostnamesForGroup' => {
            'func' => 'api2_getHostnamesForGroup',
            'engine' => 'hasharray'
        },
        'createHostname' => {
            'func' => 'api2_createHostname',
            'engine' => 'hasharray'
        },
        'getRRSetForHostname' => {
            'func' => 'api2_getRRSetForHostname',
            'engine' => 'hasharray'
        },
        'createRRData' => {
            'func' => 'api2_createRRData',
            'engine' => 'hasharray'
        },
        'deleteHostname' => {
            'func' => 'api2_deleteHostname',
            'engine' => 'hasharray',
        },
        'changeAuthToken' => {
            'func' => 'api2_changeAuthToken',
            'engine' => 'hasharray',
        },
        'getGeoGroups' => {
            'func' => 'api2_getGeoGroups',
            'engine' => 'hasharray',
        },
        'createGeoGroup' => {
            'func' => 'api2_createGeoGroup',
            'engine' => 'hasharray',
        },
        'getGeoGroupDetails' => {
            'func' => 'api2_getGeoGroupDetails',
            'engine' => 'hasharray',
        },
        'appendToGeoGroup' => {
            'func' => 'api2_appendToGeoGroup',
            'engine' => 'hasharray',
        },
        'removeGeoGroup' => {
            'func' => 'api2_removeGeoGroup',
            'engine' => 'hasharray',
        },
        
    );
    return \%{ $API2{ $_[0] } };
}

1;