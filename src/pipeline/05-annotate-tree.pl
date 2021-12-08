#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to build a phylogentic tree from a muscle alignment (FASTA).

use strict;
use warnings;
use JSON qw( decode_json );

print("Building phylogenetic tree...\n");

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
my $TAXON            = $decoded_json->{"Taxon"};
my $MARKER       = $decoded_json->{"Marker"};
my $DATA_DIR         = $decoded_json->{"DataDirectory"};
my $DATA_DIR_INTERIM = $DATA_DIR . "/interim";
my $DATA_DIR_PROCESSED = $DATA_DIR . "/processed";
my $DELIM                   = "\t";
my $NA_STRING = "NA";

`mkdir -p $DATA_DIR_INTERIM`;
`mkdir -p $DATA_DIR_PROCESSED`;

print("| Done\n");

# --------------------------------------------------------------
# Adding IUCN to the tree file using the Hampshire eXtend format.
# --------------------------------------------------------------
my $input_file = $DATA_DIR_INTERIM . "/RAxML_bestTree.bold_" . $TAXON . "_". $MARKER . "_tree";
my $output_file = $DATA_DIR_PROCESSED . "/bold_" . $TAXON . "_". $MARKER . "_tree_annotated.nhx";

my $info_file = $DATA_DIR_INTERIM . "/bold_" . $TAXON . "_". $MARKER . "_info_iucn.tsv";

# Read both info file and tree file
open( my $input_data, '<', $input_file )
  or die "| ERROR: Could not open '$input_file' $!\n";

open( my $info_data, '<', $info_file )
  or die "| ERROR: Could not open '$info_file' $!\n";

# Save the entire tree to memory as a string
my $input_file_content = do { local $/; <$input_data> };

# Make sure its on only 1 line.
$input_file_content = strip(trim( $input_file_content));

# Step 1. Shorten IDs from ID|Specues to just IDs
$input_file_content =~ s/\|[^:]*:/:/g;

# Step 2. Search for each ID and add the required annotation data to it.
# Iterate through each id in the annotation file. Slower than searching the other way but easier
my $row_current = 0;
while ( my $line = <$info_data> ) {
    $row_current = $row_current + 1;
    chomp $line;

    # Split row into array
    my @fields = split $DELIM, $line;

    if ( $row_current != 1 ) {
        # Find the genus species
        my $genus_species = trim( $fields[21] );
        my $genus = trim( $fields[19] );
        my $iucn_long = $fields[68];

        # Set empty values to NA
        if (!(defined $genus and length $genus)) {
          $genus = $NA_STRING;
        }

        if (!(defined $genus_species and length $genus_species)) {
          $genus_species = $NA_STRING;
        }


        # Convert IUCN from long form to short form. i.e. Least concerned (LC) => LC.
        # Not evalulated is the same as NA so it works fine.
        my $iucn = $NA_STRING;
        if (defined $iucn_long and length $iucn_long){
          my($iucn_short) = $iucn_long =~ /\((\w+)\)/;
          $iucn = $iucn_short;
        }

        # Make IUCN NA if its empty.
        if (!(defined $iucn and length $iucn)) {
          $iucn = $NA_STRING;
        }

        $iucn = strip(trim($iucn));

        # get the ID (as in the tsv not the tree)
        my $info_id = trim( $fields[0] );
        my $tree_id_match = $info_id . ":";

        # Find the string between the tree_id_match and either ',' or ')'. i.e. "ID-0001:0.0032783728," => ID-0001:0.0032783728
        # And replace it with its annotated string. i.e "ID-0001:0.0032783728," => ID-0001:0.0032783728 => ID-0001:0.0032783728[ANNOTATION]
        my $string = $input_file_content;
        my $substring = "";
        
        $string =~ /$tree_id_match(.*?)[\,\)]/;
        ($substring) = $1;

        # ID not found in tree. Skip.
        if (!(defined $substring and length $substring)) {
          next;
        }

        # Create annotation string
        my $annotation = "[\&\&NHX:IUCN=$iucn]";
        my $replacement = $tree_id_match . $substring . "[\&\&NHX:IUCN=$iucn]";
        my $string_to_replace = $tree_id_match . $substring;

        # Find the replacement string within the tree and replace it with its annotated version
        print "| Adding annotation: $string_to_replace" . " => " . $replacement . "\n";

        # Do the replacement
        $input_file_content =~ s/$string_to_replace/$replacement/;
    }
}

close $input_data;
close $info_data;

# Write annotated tree to output file.
open( my $output_data, '>', $output_file )
  or die "| ERROR: Could not open '$output_file' $!\n";

print $output_data $input_file_content;
close $output_data;

print("| Done\n");
print("Done\n");
