package	Cpanel::DnsDotComManager;

use strict;
#use warnings; 
use Data::Dumper;
#use Cpanel::Logger       ();
#use Cpanel::AdminBin     ();

use JSON::PP;
use URI::Escape;
use LWP;


my $browser = LWP::UserAgent->new;

our $VERSION = '0.1';

sub DNS_COM_init {
    return 1;
    }

my $cmd = '';

sub dns_query{
    ##########
    # Later login and server info will be stored in the DB.
    ###
    my $username    = 'me@millerhooks.com';
    my $password    = 'rYB2qkGbex';
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
    
    my $opt1             = '';
    my $opt2             = '';
    my $opt3             = '';
    my $opt4             = '';
    my $opt5             = '';
    
    if ($opt_field1_value){
        $opt1 = "&$opt_field1=$opt_field1_value";
    }
    if ($opt_field2_value){
        $opt2 = "&$opt_field2=$opt_field2_value";
    }
    if ($opt_field3_value){
        $opt2 = "&$opt_field3=$opt_field3_value";
    }
    if ($opt_field4_value){
        $opt2 = "&$opt_field4=$opt_field4_value";
    }
    if ($opt_field5_value){
        $opt2 = "&$opt_field5=$opt_field5_value";
    }
    
    my $url = "http://$hostname/api/$cmd/?email=$username&password=$password$opt1$opt2$opt3$opt4$opt5";
    
    my $json = new JSON::PP;
    my $response = $browser->get( $url );
    die "Couldn't get $url" unless defined $response;
    
    my $domain_data = $json->decode($response->content);
    return $domain_data;
}

##############################
# Retrieval Functions
#############################################

sub api2_getDomains{
    # Optional Search Term
    $cmd = 'getDomains';
    my $search_term  = $_[0];
    my $domain_data = dns_query($cmd, 'search_term', $search_term);
    my $meta        = ();
    my @domain_array = ();
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        print "$meta->{error}\n";
        return $meta;
    }else{
        foreach my $domain(@{$domain_data->{data}}){
            push(@domain_array, {'name' => $domain->{name}});    
        }
        
    }
        return @domain_array;
}

sub api2_getDomainGroups {
    ################
    # Optional Search Term
    ########
    $cmd = 'getDomainGroups';
    my $search_term  = $_[0];
    my $domain_group_data = dns_query($cmd, 'search_term', $search_term);
    my @domain_group_array = ();
    my $meta        = ();
    
    if ($domain_group_data->{meta}->{success} == 0){
        $meta->{success} = $domain_group_data->{meta}->{success};
        print "FAIL QUERY\n";
        return $meta;
    }else{
        foreach my $domain_group(@{$domain_group_data->{data}}){
            push(@domain_group_array, {'name' => $domain_group->{name}});  
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
        print $meta->{error};
        return $meta;
    }else{
        foreach my $domain(@{$domain_data->{data}}){
             push(@domain_array, {'name' => $domain->{name}});
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
        print "FAIL QUERY\n";
        return $meta;
    }else{
        foreach my $country_group(@{$country_group_data->{data}}){
            push(@country_group_array, {'name' => $country_group->{name}});
        }
        return @country_group_array;
    }
}

sub getCountriesInCountryGroup {
    ######
    # Requires countryGroup Name
    ##
    $cmd = 'getCountriesInCountryGroup';
    
    my %OPTS = @_;
    my $country_group_name  = $OPTS{'coutry_group_name'};   
    
    my $country_data = dns_query($cmd, 'countryGroup', $country_group_name);
    my %country_hash = ();
    my $meta        = ();
    
    if ($country_data->{meta}->{success} == 0){
        $meta->{error}   = $country_data->{meta}->{error};
        $meta->{success} = $country_data->{meta}->{success};
        print $meta->{error};
        return $meta;
    }else{
        my $name = $country_data->{meta}->{name};
        foreach my $country(@{$country_data->{data}}){
            $country_hash{$name}->{iso_code}              = $country->{iso_code};
            $country_hash{$name}->{name}                  = $country->{name};
            
            print "COUNTRIES IN COUNTRY GROUP: $country_hash{$name}->{name} \n";
        }
        return %country_hash;
    }
}

##########################
# Creation Functions
##########

sub createDomainGroup {
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
            
        print "CREATED DOMAIN GROUP: $group_name \n";        
        return $meta;
    }else{
        print "FAIL";
    }
}

sub createDomain {
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
    my %OPTS = @_;
    my $domain_mode = $OPTS{'domain_mode'};
    die "ERROR: Please enter a domain mode!" unless defined $domain_mode;
    my $domain_name = $OPTS{'domain_name'};
    die "ERROR: Please enter a domain name!" unless defined $domain_name;
    
    my $domain_group  = $_[2];
    my $domain_td     = $_[3];
    
    my $domain_data  = dns_query($cmd, 'mode', $domain_mode, 'domain', $domain_name, 'group', $domain_group, 'trafficDestination', $domain_td);
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        $meta->{trafficDestination_id} = $domain_data->{meta}->{trafficDestination_id};
        
            
        print "CREATED DOMAIN: $domain_name \n";        
        return $meta;
    }else{
        print "FAIL";
    }
}

sub deleteDomain {
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
    
    my $domain_group  = $_[2];
    
    my $domain_data  = dns_query($cmd, 'mode', $domain_mode, 'domain', $domain_name, 'group', $domain_group);
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 1){
        $meta->{id}                    = $domain_data->{meta}->{id};
        $meta->{success}               = $domain_data->{meta}->{success};
        
            
        print "DELETED DOMAIN: $domain_name \n";        
        return $meta;
    }else{
        print "FAIL";
    }
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
        }
    );
    return \%{ $API2{ $_[0] } };
}

###
#command line execution
###
if ($ARGV[0]){
    if ($ARGV[0] eq '-h'){
        print "example: DNS_COM.pm getDomains arg\nSee API docs.\n";
    }
    elsif ($ARGV[0] eq 'getDomains'){
        api2_getDomains($ARGV[1]);   
    }elsif($ARGV[0] eq 'getDomainGroups'){
        api2_getDomainGroups($ARGV[1]);
    }elsif($ARGV[0] eq 'getDomainsInGroup'){
        api2_getDomainsInGroup($ARGV[1]);
    }
}else{
    print "Please enter a comand. -h for help\n";
}

1;