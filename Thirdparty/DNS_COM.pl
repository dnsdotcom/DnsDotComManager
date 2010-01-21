#!/usr/bin/perl -w
##########################################
#DNS.com's Perl API Wrapper#
#
#created by: Miller Hooks 1-20-2010 miller@comwired.com
###########################
package	Cpanel::Thirdparty::DNS_COM;

use strict;
use warnings; 
use Data::Dumper;

use URI::Escape;
use LWP::Simple;
use JSON;

my $cmd	      = '';

sub dns_query{
    ##########
    # Later login and server info will be stored in the DB.
    ###
    my $username    = 'me@millerhooks.com';
    my $password    = 'sucka1411';
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
    
    my $query = "http://$hostname/api/$cmd/?email=$username&password=$password$opt1$opt2$opt3$opt4$opt5";
    
    my $json = new JSON;
    my $content = get $query;
    die "Couldn't get $query" unless defined $content;
    
    my $domain_data = $json->allow_nonref->utf8->relaxed->decode($content);
    
    return $domain_data;
}


##############################
# Retrieval Functions
#############################################

sub getDomains{
    ################
    # Optional Search Term
    ########
    $cmd = 'getDomains';
    my $search_term  = $_[0];
    my $domain_data = dns_query($cmd, 'search_term', $search_term);
    my %domain_hash = ();
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        print "$meta->{error}\n";
        return $meta;
    }else{
        my $i = 0;
        foreach my $domain(@{$domain_data->{data}}){
            $domain_hash{$i}->{id}                    = $domain->{id};
            $domain_hash{$i}->{name}                  = $domain->{name};
            $domain_hash{$i}->{mode}                  = $domain->{mode};
            $domain_hash{$i}->{date_created}          = $domain->{date_created};
            $domain_hash{$i}->{date_last_modified}    = $domain->{date_last_modified};
            $domain_hash{$i}->{num_hosts}             = $domain->{num_hosts};
            
            print "DOMAIN: $domain_hash{$i}->{name} \n";
            $i++;
        }
        return %domain_hash;
    }
}

sub getDomainGroups {
    ################
    # Optional Search Term
    ########
    $cmd = 'getDomainGroups';
    my $search_term  = $_[0];
    my $domain_group_data = dns_query($cmd, 'search_term', $search_term);
    my %domain_group_hash = ();
    my $meta        = ();
    
    if ($domain_group_data->{meta}->{success} == 0){
        $meta->{success} = $domain_group_data->{meta}->{success};
        print "FAIL QUERY\n";
        return $meta;
    }else{
        my $i = 0;
        foreach my $domain_group(@{$domain_group_data->{data}}){
            $domain_group_hash{$i}->{id}                    = $domain_group->{id};
            $domain_group_hash{$i}->{name}                  = $domain_group->{name};
            $domain_group_hash{$i}->{date_created}          = $domain_group->{date_created};
            $domain_group_hash{$i}->{num_domains}           = $domain_group->{num_domains};
            
            print "DOMAIN GROUP: $domain_group_hash{$i}->{name} \n";
            $i++;
        }
        return %domain_group_hash;
    }
}

sub getDomainsInGroup {
    ######
    # Requires Group Name
    ##
    
    $cmd = 'getDomainsInGroup';
    
    my $group_name  = $_[0];
    my $domain_data = dns_query($cmd, 'group', $group_name);
    my %domain_hash = ();
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
        print $meta->{error};
        return $meta;
    }else{
        my $i = 0;
        foreach my $domain(@{$domain_data->{data}}){
            $domain_hash{$i}->{id}                    = $domain->{id};
            $domain_hash{$i}->{name}                  = $domain->{name};
            $domain_hash{$i}->{date_created}          = $domain->{date_created};
            $domain_hash{$i}->{date_last_modified}    = $domain->{date_last_modified};
            
            print "DOMAINS IN GROUP: $domain_hash{$i}->{name} \n";
            $i++;
        }
        return %domain_hash;
    }
}

sub getCountryGroups {
    ################
    # Optional Search Term
    ########
    
    $cmd = 'getCountryGroups';
    my $search_term  = $_[0];
    my $country_group_data = dns_query($cmd, 'search_term', $search_term);
    my %country_group_hash = ();
    my $meta        = ();
    
    if ($country_group_data->{meta}->{success} == 0){
        $meta->{success} = $country_group_data->{meta}->{success};
        print "FAIL QUERY\n";
        return $meta;
    }else{
        my $i = 0;
        foreach my $country_group(@{$country_group_data->{data}}){
            $country_group_hash{$i}->{id}                    = $country_group->{id};
            $country_group_hash{$i}->{editable}              = $country_group->{editable};
            $country_group_hash{$i}->{name}                  = $country_group->{name};
            
            print "COUNTRY GROUPS: $country_group_hash{$i}->{name} \n";
            $i++;
        }
        return %country_group_hash;
    }
}

sub getCountriesInCountryGroup {
    ######
    # Requires countryGroup Name
    ##
    $cmd = 'getCountriesInCountryGroup';
    
    my $country_group_name  = $_[0];
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
    
    my $group_name  = $_[0];
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
    
    my $domain_mode  = $_[0];
    die "ERROR: Please enter a domain mode!" unless defined $domain_mode;
    my $domain_name  = $_[1];
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
    
    my $domain_mode  = $_[0];
    die "ERROR: Please enter a domain mode!" unless defined $domain_mode;
    my $domain_name  = $_[1];
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
#command line execution
###

if ($ARGV[0] eq 'getDomains'){
    getDomains($ARGV[1]);   
}
elsif($ARGV[0] eq 'getDomainGroups'){
    getDomainGroups($ARGV[1]);
}
elsif($ARGV[0] eq 'getDomainsInGroup'){
    getDomainsInGroup($ARGV[1]);
}
elsif($ARGV[0] eq 'getCountryGroups'){
    getCountryGroups($ARGV[1]);
}
elsif($ARGV[0] eq 'getCountriesInCountryGroup'){
    getCountriesInCountryGroup($ARGV[1]);
}

elsif($ARGV[0] eq 'createDomainGroup'){
    createDomainGroup($ARGV[1]);
}
elsif($ARGV[0] eq 'createDomain'){
    createDomain($ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4]);
}
elsif($ARGV[0] eq 'deleteDomain'){
    deleteDomain($ARGV[1],$ARGV[2],$ARGV[3]);
}

