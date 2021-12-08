#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to add conservation status of each species to a the sample info file

use strict;
use warnings;
use JSON qw( decode_json );

print("Annotating sample data\n");

# --------------------------------------------------------------
# Helper functions
# --------------------------------------------------------------

# Removes trailing and leading whitespace
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s }

# Removes all newline from string
sub strip { my $s = shift; $s =~ s/\n//g; $s =~ s/\r//g; return $s; }

# --------------------------------------------------------------
# Parse input json config
# --------------------------------------------------------------

print("| Parsing config...\n");

# Read json file to string
my $json_text = do {
    open( my $json_fh, "<:encoding(UTF-8)", $ARGV[0] )
      or die("| ERROR: Can't open config JSON: \$filename\": $!\n");
    local $/;
    <$json_fh>;
};

my $decoded_json = decode_json($json_text)
  or die("| ERROR: Can't decode config JSON: \$filename\": $!\n");

# --------------------------------------------------------------
# Script parameters
# --------------------------------------------------------------
my $TAXON                   = $decoded_json->{"Taxon"};
my $DATA_DIR                = $decoded_json->{"DataDirectory"};
my $DATA_DIR_INTERIM        = $DATA_DIR . "/interim";
my $DATA_DIR_RAW            = $DATA_DIR . "/raw";
my $MARKER       = $decoded_json->{"Marker"};
my $FISH_IUCN_FINDER_BINARY = $decoded_json->{"FishIucnFinderBinaryPath"};
my $DELIM                   = "\t";

`mkdir -p $DATA_DIR_RAW`;
`mkdir -p $DATA_DIR_INTERIM`;

print("| Done\n");

# --------------------------------------------------------------
# Add conservation status to the information *.tsv obtained from
#    BOLD using fish_iucn_finder
# --------------------------------------------------------------
print("| Appending IUCN data to sample (tsv)...\n");

my $input_file  = $DATA_DIR_RAW . "/bold_" . $TAXON . "_". $MARKER . "_info.tsv";
my $output_file = $DATA_DIR_INTERIM . "/bold_" . $TAXON . "_". $MARKER . "_info_iucn.tsv";

# Display progress
my $row_total   = strip( trim(`wc -l < $input_file`) );
my $row_current = 0;

# Iterate througgh the TSV, query fish base of the species, and append as new row
open( my $input_data, '<', $input_file )
  or die "Could not open '$input_file' $!\n";
open( my $output_data, '>', $output_file )
  or die "Could not open '$output_file' $!\n";

# Store each result in a hash in order to SKIP multiple identical species being queried.
my %species_genus_iucn = ();

while ( my $line = <$input_data> ) {
    $row_current = $row_current + 1;
    chomp $line;

    my @fields = split $DELIM, $line;

    if ( $row_current == 1 ) {
        my $line_output = $line . $DELIM . "iucn";
        say $output_data strip($line_output);
    }
    else {
        # Find the genus species
        my $genus_species = trim( $fields[21] );

        # Check against hash for duplicate
        if ( exists $species_genus_iucn{$genus_species} ) {
            print(
"$row_current/$row_total | Skipping duplicate species...: $genus_species\n"
            );
        }
        else {
            print(
                "$row_current/$row_total | Finding IUCN for: $genus_species\n");

            my $iucn = `$FISH_IUCN_FINDER_BINARY $genus_species`;

            # Save to hash table
            if ( $iucn ne "" ) { $species_genus_iucn{$genus_species} = $iucn; }
        }

        my $line_output =
          trim( $line . $DELIM . $species_genus_iucn{$genus_species} );
        say $output_data strip($line_output);
    }
}

print("| Done\n");

close $input_file;
close $output_file;

print("Done\n");
