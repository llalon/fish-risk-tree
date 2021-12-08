#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to build a phylogentic tree from a muscle alignment (FASTA).

use strict;
use warnings;
use Cwd;
use Sys::CPU;
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
my $RAXML_BINARY     = $decoded_json->{"RaxmlBinaryPath"};
my $SEED             = $decoded_json->{"Seed"};
my $NUM_BOOTSTRAPS   = trim( $decoded_json->{"NumBootstraps"} );
my $THREADS          = trim( $decoded_json->{"Threads"} );

# Find CPU threads automatically
if ( $THREADS eq "0" == 1 ) { $THREADS = Sys::CPU::cpu_count(); }

# Convert NumBootstraps to integer
eval { $NUM_BOOTSTRAPS = int($NUM_BOOTSTRAPS); 1; }
  or do { $NUM_BOOTSTRAPS = 0; };

`mkdir -p $DATA_DIR_INTERIM`;

print("| Done\n");

# --------------------------------------------------------------
# ML tree building
# --------------------------------------------------------------
my $input_file = $DATA_DIR_INTERIM . "/bold_" . $TAXON . "_". $MARKER . "_seq.aln";
my $id         = "bold_" . $TAXON . "_". $MARKER . "_tree";

# RAXML Only accepts absoulte path.
my $output_path = Cwd::abs_path($DATA_DIR_INTERIM);

if ( $NUM_BOOTSTRAPS >= 1 ) {
    print("| Running model with bootstrapping...\n");
    system(
"$RAXML_BINARY -s $input_file -m GTRGAMMA -p $SEED -w $output_path -T $THREADS -x $SEED -# $NUM_BOOTSTRAPS -n $id"
    );
}
else {
    print("| Running model...\n");
    system(
"$RAXML_BINARY -s $input_file -m GTRGAMMA -p $SEED -w $output_path -T $THREADS -n $id"
    );
}

print("| Done\n");
print("Done\n");
