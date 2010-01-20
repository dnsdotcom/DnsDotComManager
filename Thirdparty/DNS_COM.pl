#!/usr/bin/perl -w
package	Cpanel::Thirdparty::DNS_COM;

use strict;
use warnings; 
use Data::Dumper;

use LWP::Simple;
use JSON;

my $cmd	= '';

sub dns_query{
    $cmd            = $_[0];
    my $username    = 'me@millerhooks.com';
    my $password    = 'sucka1411';
    my $hostname    = 'sandbox.comwired.com';
    my $query	    = "http://$hostname/api/$cmd/?email=$username&password=$password";
    
    my $json = new JSON;
    my $content = get $query;
    my $domain_data = $json->allow_nonref->utf8->relaxed->decode($content);
    die "Couldn't get $query" unless defined $content;
    return $domain_data;
}

sub getDomains{
    $cmd = 'getDomains';
    my $domain_data = dns_query($cmd);
    my %domain_hash = ();
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 0){
        $meta->{error}   = $domain_data->{meta}->{error};
        $meta->{success} = $domain_data->{meta}->{success};
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
    $cmd = 'getDomainGroups';
    my $domain_data = dns_query($cmd);
    my %domain_hash = ();
    my $meta        = ();
    
    if ($domain_data->{meta}->{success} == 0){
        $meta->{success} = $domain_data->{meta}->{success};
        print "FAIL QUERY\n";
        return $meta;
    }else{
        my $i = 0;
        foreach my $domain(@{$domain_data->{data}}){
            $domain_hash{$i}->{id}                    = $domain->{id};
            $domain_hash{$i}->{name}                  = $domain->{name};
            $domain_hash{$i}->{date_created}          = $domain->{date_created};
            $domain_hash{$i}->{num_domains}           = $domain->{num_domains};
            
            print "DOMAIN GROUP: $domain_hash{$i}->{name} \n";
            $i++;
        }
        return %domain_hash;
    }
}

sub getDomainsInGroup {
    $cmd = 'getDomainsInGroup';
    my $domain_data = dns_query($cmd);
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

###
#command line execution
###

if ($ARGV[0] eq 'getDomains'){
    getDomains();   
}
elsif($ARGV[0] eq 'getDomainGroups'){
    getDomainGroups();
}
elsif($ARGV[0] eq 'getDomainsInGroup'){
    getDomainsInGroup();
}