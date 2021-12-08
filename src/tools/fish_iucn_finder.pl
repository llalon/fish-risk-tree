#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to obtain IUCN conservation status of a given fish species.
# Obtains data from the public database fishbase https://www.fishbase.de.
# This script was created because the public API for fishbase was offline at the time of this writing.

# Usage: fish_iucn_finder.pl <genus> <species>

use strict;
use warnings;

# For HTTP requests
use LWP::Simple;

# --------------------------------------------------------------
# Constants/settings of the script
# --------------------------------------------------------------
my $NA_STRING    = "NA";
my $FISHBASE_URL = "https://www.fishbase.de/";

# --------------------------------------------------------------
# Function prints a help message to instruct users how to use it
# --------------------------------------------------------------
sub help() {
    my $num_args = $#ARGV + 1;

    # quits unless the correct number of arguments (2) is provided
    if ( $num_args != 2 ) {
        print STDERR
"fish_iucn_finder: A tool for obtaining IUCN conservation status from a given fish species.\n";
        print STDERR "\n\tUsage: $0  <genus> <species>\n\n";
        print STDERR "\tExample: $0 danio rerio\n\n";
        exit();
    }
}

# --------------------------------------------------------------
# Determines the IUCN conservation status of a given fish species.
# Obtains data from the public database FishBase
#
# Requires:
#       (string) The fish species to query. Must be formatted as `genus species`
# Returns:
#       (string) The conservation status of the given fish species
# --------------------------------------------------------------
sub get_iucn_status_of_species {
    my $genus   = $_[0];
    my $species = $_[1];

    # Don't waste time querying if genus/species is invalid
    if ( length($genus) <= 1 || length($species) <= 1 ) {
        return $NA_STRING;
    }

    # Formulate the URL. Fishbase.de uses the same format for each fish page.
    my $request_url =
      $FISHBASE_URL . "summary/" . $genus . "-" . $species . ".html";

    # Return the entire page as HTML
    my $response = get($request_url);

    # where to look in the html for the value we want
    my $html_match_start = 'https://www.iucnredlist.org';
    my $html_match_end   = '<';

    # Extract the value between the html tags
    $response =~ /$html_match_start(.*?)$html_match_end/;
    my ($result) = $1 =~ />\s*(.+)$/;

    # Validate the output by checking if the length is too big or too small
    if ( length($result) <= 5 || length($result) >= 25 ) {
        print STDERR "ERROR: Couldn't parse response\n";
        return $NA_STRING;
    }
    return $result;
}

# --------------------------------------------------------------
# Main entry point
# --------------------------------------------------------------
unless (caller) {
    help();
    print STDOUT ( get_iucn_status_of_species( $ARGV[0], $ARGV[1] ) );
}
