package	Cpanel::DnsDotComManager;

#use strict;
#use warnings; 
use Data::Dumper;
use Cpanel::LoadFile      ();
use Cpanel::FileUtils     ();
use YAML::Syck;


use JSON::PP;
use URI::Escape;
use LWP 5.64;

my $browser = LWP::UserAgent->new;
$YAML::Syck::ImplicitTyping = 1;

our $VERSION = '0.7';

#get reseller token to figure out if it's a reseller install
our $resellertokenfile = Cpanel::LoadFile::loadfile('/var/local/dnsdotcom/reseller-dns-dot-com-token');

if ($resellertokenfile) {
    our $is_reseller = 1;    
}

sub dns_query{
    my $tokenfile = '';
    my $AUTH_TOKEN = '';
    
    if ($resellertokenfile) {
        $AUTH_TOKEN = uri_escape($resellertokenfile);

        my $resellercodefile = Cpanel::LoadFile::loadfile('/var/local/dnsdotcom/reseller-code');
        if ($resellercodefile){
            my $resellercode = "&resellerCode=$resellerCode=$resellercodefile";
        }
    }elsif(!$resellertokenfile){
        $tokenfile = '/var/local/dnsdotcom/' . $Cpanel::user . '-dns-dot-com-token';
        $AUTH_TOKEN = uri_escape(Cpanel::LoadFile::loadfile($tokenfile));
    }

    my $hostname    = 'sandbox.comwired.com';
    
    my $cmd               = $_[0];

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
    #print "<br><br> $url <br><br>";
    my $json = new JSON::PP;
    my $domain_data = $json->decode($response->content);
    return $domain_data;
}

##
# API2 Functions
####

#This checks to see if the user is in the reseller userDB if not it adds them
sub api2_checkUser {
    if ($is_reseller){
        my $user_data_file = my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
        my $user_data = Cpanel::LoadFile::loadfile($user_data_file);
        if (!$user_data){
            my %initial_data = ();
            %initial_data = ('groups'=> 'groups',
                             'domains'=> 'domains',
                             'geogroups'=> 'geogroups',
                            );
                
            my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
            Cpanel::FileUtils::writefile($user_data_file, Dump(\%initial_data));
        }else{
         
            my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
            my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
            my @user_data = Load($user_data_import);
            my @domains = ();
            for $aref ( @user_data[0]->{domains} ) {
                push(@domains, @$aref);
            }
           
        }
    }
}


sub api2_listCountries{
    my $yaml = Cpanel::LoadFile::loadfile('/var/local/dnsdotcom/yaml/countries/00-COUNTRIES-LIST.yaml');
    my @data = Load($yaml);
    return $data[0];
}

sub api2_listRegions{
    my %OPTS = @_;
    my $country = $OPTS{'country'};

    my $yaml = Cpanel::LoadFile::loadfile("/var/local/dnsdotcom/yaml/countries/$country.yaml");
    my @data = Load($yaml);
    
    return $data[0];
}

sub api2_listCities{
    my %OPTS = @_;
    my $country = $OPTS{'country'};
    my $region = $OPTS{'region'};

    my $yaml = Cpanel::LoadFile::loadfile("/var/local/dnsdotcom/yaml/countries/$country/$region.yaml");
    my @data = Load($yaml);
    
    return $data[0];
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

our $cmd = '';

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
    my $meta        = ();
    our @domain_array = ();
    
    if ($is_reseller){
        my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
        my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
        my @user_data = Load($user_data_import);
        my @domains = ();
        for $aref ( @user_data[0]->{domains} ) {
                push(@domains, @$aref);
        }
        
        if (@user_data[0]->{domains}){
            foreach (@domains) {

                if ($_ ne 'domains'){
                    my $domain = dns_query($cmd, 'search_term', $_);
                    push(@domain_array, {'name'                 => $domain->{data}[0]->{name},
                                         'mode'                 => $domain->{data}[0]->{mode},
                                         'group'                => $domain->{data}[0]->{group},
                                         'date_last_modified'   => $domain->{data}[0]->{date_last_modified},
                                         'date_created'         => $domain->{data}[0]->{date_created},
                                         });
                }
            }
            return @domain_array;
        }
    }else{
        my $domain_data = dns_query($cmd, 'search_term', $search_term);
    
    
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
        }
        return @domain_array;
    }
    
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
        return $meta;
    }else{
        foreach my $host(@{$hosts_data->{data}}){
            if(!$host->{name}){
                $host->{name} = '(root)';
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
                $host->{name} = '(root)';
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
    if ($host_name =~ /(root)/){
        $host_name = ' ';
    }
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
                                'geoGroup'              => $host->{geoGroup},
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
    my @domain_group_array = ();
    my $meta        = ();
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'};
    
    if ($is_reseller){
        my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
        my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
        my @user_data = Load($user_data_import);
        my @groups = ();
        for $aref ( @user_data[0]->{groups} ) {
                push(@groups, @$aref);
        }
        
        if (@user_data[0]->{groups}){
            foreach (@groups) {
                if ($_ ne 'groups'){
                    my $domain_group = dns_query($cmd, 'search_term', $_);
                    push(@domain_group_array, {'name'       => $domain_group->{data}[0]->{name},
                                           'date_created'   => $domain_group->{data}[0]->{date_created},
                                           }); 
                }
            }
            return @domain_group_array;
        }
    }else{
        my $domain_group_data = dns_query($cmd, 'search_term', $search_term);
        
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
    
    my $group_data  = dns_query($cmd, 'name', $group_name);
    my $meta        = ();
    my @group_array = ();
    
    if ($group_data->{meta}->{success} == 1){
        $meta->{id}                    = $group_data->{meta}->{id};
        $meta->{success}               = $group_data->{meta}->{success};
        
        if ($is_reseller){
            my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
            my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
            my @user_data = Load($user_data_import);
            
            my @groups      = ();
            my @domains     = ();
            my @geogroups   = ();
            
            for $aref ( @user_data[0]->{domains} ) {
                push(@domains, @$aref);
            }
            
            for $aref ( @user_data[0]->{groups} ) {
                push(@groups, @$aref);
            }
            
            for $aref ( @user_data[0]->{geogroups} ) {
                push(@geogroups, @$aref);
            }
                
            push(@groups, $group_name);
            
            my %user_data = ();
            %user_data = ('groups'=> [@groups],
                         'domains'=> [@domains],
                         'geogroups'=> [@geogroups],
            );
            
            Cpanel::FileUtils::writefile($user_data_file, Dump(\%user_data));
        }
            
        push(@group_array, {'message'   => $group_name});    
    }else{
        push(@group_array, {'message'   => $group_data->{meta}->{error}}); 
    }
    return @group_array;
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
        
        if ($is_reseller){
            my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
            my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
            my @user_data = Load($user_data_import);
            
            my @groups      = ();
            my @domains     = ();
            my @geogroups   = ();
            
            for $aref ( @user_data[0]->{domains} ) {
                push(@domains, @$aref);
            }
            
            for $aref ( @user_data[0]->{groups} ) {
                push(@groups, @$aref);
            }
            
            for $aref ( @user_data[0]->{geogroups} ) {
                push(@geogroups, @$aref);
            }
                
            push(@domains, $domain_name);
            
            my %user_data = ();
            %user_data = ('groups'=> [@groups],
                         'domains'=> [@domains],
                         'geogroups'=> [@geogroups],
            );
            
            Cpanel::FileUtils::writefile($user_data_file, Dump(\%user_data));
        }
        
        push(@domain_array, {'message'   => $domain_name});        
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
    my @host_array = ();
    
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
        
        push(@host_array, {'message'   => $host});    
    }else{
        push(@host_array, {'message'   => $host_data->{meta}->{error}}); 
    }
    return @host_array;
    
}

sub api2_createRRData {
    $cmd = 'createRRData';
    
    my @rr_array = ();
    my %OPTS = @_;
    # identifier vars
    my $domain  = $OPTS{'domain'};
    my $group   = $OPTS{'group'};
    
    #required vars
    my $host_name   = $OPTS{'host'};
    my $type        = $OPTS{'type'};
    my $rdata       = $OPTS{'rdata'};
    
    #optional vars
    my $geoGroup        = $OPTS{'geoGroup'};
    my $country_Iso2    = $OPTS{'country_Iso2'};
    my $region          = $OPTS{'region'};
    my $city            = $OPTS{'city'};
    my $priority        = $OPTS{'priority'};
    my $is_wildcard     = $OPTS{'is_wildcard'};
    my $ttl             = $OPTS{'ttl'};
    
    my $domain_group    = $OPTS{'domain_group'};
    
    if ($host_name =~ /(root)/){
        $host_name = ' ';
    }
    
    my $rr_data  = dns_query($cmd,
                                 'domain',          $domain,
                                 'group',           $group,
                                 'host',            $host_name,
                                 'type',            $type,
                                 'rdata',           $rdata,
                                 'geoGroup',        $geoGroup,
                                 'country_Iso2',    $country_Iso2,
                                 'region',          $region,
                                 'city',            $city,
                                 'priority',        $priority,
                                 'is_wildcard',     $is_wildcard,
                                 'ttl',             $ttl,
                                );
    my $meta        = ();
    
    if ($host_data->{meta}->{success} == 1){
        $meta->{id}                    = $rr_data->{meta}->{id};
        $meta->{success}               = $rr_data->{meta}->{success};
        
        if ($host_name =~ ' '){
            $host_name = '(root)';
        }
        
        push(@rr_array, {'message'   => "$host_name: $type : $rdata"});    
    }else{
        push(@rr_array, {'message'   => $rr_data->{meta}->{error}}); 
    }
    return @rr_array;
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
    my $domain_name = $OPTS{'domain_name'};
    my @domain_array = ();

    
    my $domain_group  = $OPTS{'domain_group'};
    
    my $domain_data  = dns_query($cmd, 'mode', $domain_mode, 'domain', $domain_name, 'group', $domain_group, 'confirm', 1);
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        
            
        push(@domain_array, {'message'   => $domain_name});    
    }else{
        push(@domain_array, {'message'   => $domain_data->{meta}->{error}}); 
    }
    return @domain_array;
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
    my @group_array = ();
    die "ERROR: Please enter a domain name!" unless defined $group_name;

    
    my $group_data  = dns_query($cmd, 'group', $group_name, 'confirm', 1);
    my $meta        = ();
    
    if ($group_data->{meta}->{success} == 1){
        $meta->{id}                    = $group_data->{meta}->{id};
        $meta->{success}               = $group_data->{meta}->{success};
        
            
        push(@group_array, {'message'   => $group_name});    
    }else{
        push(@group_array, {'message'   => $group_data->{meta}->{error}}); 
    }
    return @group_array;
    
}

sub api2_deleteHostname {
    
    my %OPTS = @_;
    my $group = $OPTS{'group'};
    my $domain = $OPTS{'domain'};
    my $host = $OPTS{'host'};
    my @host_array = ();
    if ($host =~ /(root)/){
        $host = ' ';
    }
    
    my $host_data  = dns_query('removeHostname', 'host', $host, 'group', $group, 'domain', $domain, 'confirm', 1);
    
    my $meta        = ();
    
    if ($host_data->{meta}->{success} == 1){
        $meta->{id}                    = $host_data->{meta}->{id};
        $meta->{success}               = $host_data->{meta}->{success};
        
        if ($host =~ / /){
            $host = '(root)';
        }
        push(@host_array, {'message'   => $host});    
    }else{
        push(@host_array, {'message'   => $host_data->{meta}->{error}}); 
    }
    return @host_array;
    
}

sub api2_removeRR {
    
    my %OPTS = @_;
    my $id = $OPTS{'id'};
    
    my $rr_data  = dns_query('removeRR', 'rr_id', $id, 'confirm', 1);

    my $meta        = ();
    my @rr_array    = ();
    
    if ($host_data->{meta}->{success} == 1){
        $meta->{id}                    = $host_data->{meta}->{id};
        $meta->{success}               = $host_data->{meta}->{success};
        
        push(@rr_array, {'message'   => 'success'});    
    }else{
        push(@rr_array, {'message'   => $host_data->{meta}->{error}}); 
    }
    return @rr_array;
    
}


sub api2_getGeoGroups {
    # Optional Search Term
    $cmd = 'getGeoGroups';
    my %OPTS = @_;
    my $search_term  = $OPTS{'search_term'};
    my $meta        = ();
    my @geogroup_array = ();
    
    if ($is_reseller){
        my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
        my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
        my @user_data = Load($user_data_import);
        my @geogroups = ();
        for $aref ( @user_data[0]->{geogroups} ) {
                push(@geogroups, @$aref);
        }
        
        if (@user_data[0]->{geogroups}){
            foreach (@geogroups) {
                if ($_ ne 'geogroups'){
                    my $geogroup = dns_query($cmd, 'search_term', $_);
                    push(@geogroup_array, { 'name'      => $geogroup->{data}[0]->{name},
                                            'editable'  => $geogroup->{data}[0]->{editable},
                                            'id'        => $geogroup->{data}[0]->{id},
                                        });
                }
            }
            return @geogroup_array;
        }
    }else{
    
        my $geogroup_data = dns_query($cmd, 'search_term', $search_term);

        if ($geogroup_data->{meta}->{success} == 0){
            $meta->{error}   = $geogroup_data->{meta}->{error};
            $meta->{success} = $geogroup_data->{meta}->{success};
            return $meta;
        }else{
    
            foreach my $geogroup(@{$geogroup_data->{data}}){
                if ($geogroup->{editable} == 'True'){
                    push(@geogroup_array, {'name'   => $geogroup->{name},
                                        'editable'  => $geogroup->{editable},
                                        'id'        => $geogroup->{id},
                                        });
                }
            }
        }
        return @geogroup_array;
    }
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
        
        if ($is_reseller){
            my $user_data_file = '/var/local/dnsdotcom/yaml/user/' . $Cpanel::user . '.yaml';
            my $user_data_import = Cpanel::LoadFile::loadfile($user_data_file);
            my @user_data = Load($user_data_import);
            
            my @groups      = ();
            my @domains     = ();
            my @geogroups   = ();
            
            for $aref ( @user_data[0]->{domains} ) {
                push(@domains, @$aref);
            }
            
            for $aref ( @user_data[0]->{groups} ) {
                push(@groups, @$aref);
            }
            
            for $aref ( @user_data[0]->{geogroups} ) {
                push(@geogroups, @$aref);
            }
                
            push(@geogroups, $geogroup_name);
            
            my %user_data = ();
            %user_data = ('groups'=> [@groups],
                         'domains'=> [@domains],
                         'geogroups'=> [@geogroups],
            );
            
            Cpanel::FileUtils::writefile($user_data_file, Dump(\%user_data));
        }
        
        push(@geogroup_array, {'message'   => $geogroup_name});    
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
    my $country     = $OPTS{'country'};
    my $region      = $OPTS{'region'};
    my $city        = $OPTS{'city'};
    
    my $yaml = Cpanel::LoadFile::loadfile('/var/local/dnsdotcom/yaml/00-COUNTRIES-LIST.yaml');
    my @countrydata = Load($yaml);
    
    foreach my $country_entry(@{$countrydata[0]}){
        if ($country_entry->{name} =~ $country){
            my $iso2_code = $country_entry->{iso_code};
            #print $iso2_code;
        }
    }
    
    
    my $geogroup_data  = dns_query($cmd, 'name', $name, 'iso2_code', $iso2_code, 'region', $region, 'city', $city);
    my $meta        = ();
    
    push(@geogroup_array, {'message'  => $geogroup_data->{meta}->{message},
                             'id'       => $geogroup_data->{meta}->{id}});        
    return @geogroup_array;
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
        
            
        push(@geogroup_array, {'message'   => $name});    
    }else{
        push(@geogroup_array, {'message'   => $geogroup_data->{meta}->{error}}); 
    }
    return @geogroup_array;
}

sub api2_getTrafficRules{
    $cmd = 'getTrafficRules';
    my %OPTS = @_;
    my $domain = $OPTS{'domain'};
    my $group = $OPTS{'group'}; 
    
    my $tr_data = dns_query($cmd, 'domain', $domain, 'group', $group);
    my $meta        = ();
    my @tr_array    = ();
    
    if ($tr_data->{meta}->{success} == 0){
        $meta->{error}   = $tr_data->{meta}->{error};
        $meta->{success} = $tr_data->{meta}->{success};
        return $meta;
    }else{
        foreach my $tr(@{$tr_data->{data}}){
            push(@tr_array, {   'id'                    => $tr->{id},
                                'geoGroup'              => $tr->{geoGroup},
                                'countryGroup'          => $tr->{countryGroup},
                                'trafficDestination'    => $tr->{trafficDestination},
                                'date_created'          => $tr->{date_created},
                                'date_last_modified'    => $tr->{date_last_modified},
                            });    
        }
        
    }
        return @tr_array;
}

sub api2_createTrafficRule{
    $cmd = 'createTrafficRule';
    my %OPTS = @_;
    my $group               = $OPTS{'group'};
    my $domain              = $OPTS{'domain'};
    my $geoGroup            = $OPTS{'geoGroup'};
    my $trafficDestination  = $OPTS{'trafficDestination'};
    
    my $tr_data  = dns_query($cmd, 'group', $group, 'domain', $domain, 'geoGroup', $geoGroup, 'trafficDestination', $trafficDestination);
    my $meta        = ();
    my $tr_array    = ();
    
    if ($tr_data->{meta}->{success} == 1){
        $meta->{id}                    = $tr_data->{meta}->{id};
        $meta->{success}               = $tr_data->{meta}->{success};
            
        push(@tr_array, {'message'   => 'Success'});    
    }else{
        push(@tr_array, {'message'   => $tr_data->{meta}->{error}}); 
    }
    return @tr_array;
}

sub api2_removeTrafficRule{
    $cmd = 'removeTrafficRule';
    
    my %OPTS = @_;
    my $id = $OPTS{'id'};
    my @tr_array = ();
    my $meta        = ();
    my $tr_data  = dns_query($cmd, 'id', $id, 'confirm', 1);
    
    
    if ($tr_data->{meta}->{success} == 1){
        $meta->{id}                    = $tr_data->{meta}->{id};
        $meta->{success}               = $tr_data->{meta}->{success};
        
            
        push(@tr_array, {'message'   => $name});    
    }else{
        push(@tr_array, {'message'   => $tr_data->{meta}->{error}}); 
    }
    return @tr_array;


}

#sub api2_getTrafficDestinations{
#
#}



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
        'removeRR' => {
            'func' => 'api2_removeRR',
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
        'getTrafficRules' => {
            'func' => 'api2_getTrafficRules',
            'engine' => 'hasharray',
        },
        'createTrafficRule' => {
            'func' => 'api2_createTrafficRule',
            'engine' => 'hasharray',
        },
        'removeTrafficRule' => {
            'func' => 'api2_removeTrafficRule',
            'engine' => 'hasharray',
        },
        'listCountries' => {
            'func' => 'api2_listCountries',
            'engine' => 'hasharray',
        },
        'listRegions' => {
            'func' => 'api2_listRegions',
            'engine' => 'hasharray',
        },
        'listCities' => {
            'func' => 'api2_listCities',
            'engine' => 'hasharray',
        },
        'checkUser' => {
            'func' => 'api2_checkUser',
            'engine' => 'hasharray',
        },
        
    );
    return \%{ $API2{ $_[0] } };
}

1;