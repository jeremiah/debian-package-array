#!/usr/bin/perl

# Name:                       pkgs-parse.pl
# Purpose:                    Parse a debian packages file turning 
#                             packages into entries in a YAML file.

# Currently I am just using the @ARGV array because I am too lazy to
# add getopts. I will add getopt eventually. The first arg is the file 
# you want to search - the second optional arg is the name of the package
# you want the versions for

use warnings;
use strict;
use Perl6::Slurp;

# pull into an array discrete package entries
my @pkgs = slurp $ARGV[0], {irs => qr/\n\n/xms};

# merge packages into an array
my @lines = map { split /\n/ } grep /Package:/, @pkgs;

# We only want certain elements
my @selected  = map { $_ } grep /Package:|Version:|Filename:/, @lines;

my %h;
my @pkgsary;
my ($fil, $ver, $deb);

#  We need to re-arrange the data into an array of lines.
#  This needs to be auto-vivified somehow
foreach my $packet (@selected) {
  if ($packet =~ s/Package: (.*)/$1/) {
    #%h = (  split /^(*.): (.*)$/, $packet;
    $fil = $packet .= " ";
  }
  elsif ($packet =~ s/Version: (.*)/$1/) {
    $ver = $packet .= " ";
  }
  elsif ($packet =~ s/Filename: (.*)/$1/) {
    $deb = $packet;
    push @pkgsary, $fil .= $ver .= $deb .= "\n";
    # This should get pushed to disk and archived 
  }
}

sub list_version {
  use YAML;
  my @new;
  my %versions;
  my $pac = shift;
  my $search = $pac ? $pac : " ";
  my @found = map { $_ } grep /$search/, @pkgsary;
  if ($search !~ / /) { # If there is no search term defined
    print "Search for $search:";
  }                     # iterate over the whole file
  foreach my $line (@found) {
    my ($package, $version, $file) =  split / /, $line;
    $versions{$package} = [ ] unless exists $versions{$package};
    push @{ $versions{$package} }, $version.="=$file";
  }
#  print map { $_->[0] } each %versions;
  while (my ($key, $val) = each(%versions)) {
    print "\nPackage $key has version(s)\n", map { join '   ', split /=/ } @$val;
  }
}
list_version($ARGV[1]);

1;


