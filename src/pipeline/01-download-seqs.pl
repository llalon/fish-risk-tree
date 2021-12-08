#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to download sequence data of the COI gene in fasta format for species of fish.
# Data is obtained from BoldSystems https://boldsystems.org

use strict;
use warnings;
use JSON qw( decode_json );

print("Downloading data sets...\n");

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
my $DATA_DIR     = $decoded_json->{"DataDirectory"};
my $DATA_DIR_RAW = $DATA_DIR . "/raw";
my $TAXON        = $decoded_json->{"Taxon"};
my $MARKER       = $decoded_json->{"Marker"};
my $API_BASE_URL = "http://v3.boldsystems.org/index.php/API_Public/";
my $output_file;

`mkdir -p $DATA_DIR_RAW`;

print("| Done\n");

# --------------------------------------------------------------
# Download sequence data (FASTA)
# --------------------------------------------------------------
print("| Downloading sequence data (fasta)...\n");
$output_file = $DATA_DIR_RAW . "/bold_" . $TAXON . "_". $MARKER . "_seq.fasta";
system(
"wget -O $output_file \"http://v3.boldsystems.org/index.php/API_Public/sequence?taxon=$TAXON\&marker=$MARKER\""
);
print("| Done\n");

# --------------------------------------------------------------
# Download specimen data (TSV)
# --------------------------------------------------------------
print("| Downloading sample information data (tsv)...\n");
$output_file = $DATA_DIR_RAW . "/bold_" . $TAXON . "_". $MARKER . "_info.tsv";
system(
"wget -O $output_file \"http://www.boldsystems.org/index.php/API_Public/specimen?taxon=$TAXON\&format=tsv\&marker=$MARKER\""
);
print("| Done\n");

print("Done\n");
