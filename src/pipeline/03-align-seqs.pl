#!/usr/bin/perl

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Perl script to preform multiple sequence alignment of a fasta file using MUSCLE.

use strict;
use warnings;
use JSON qw( decode_json );

print("Aligning sequences...\n");

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
my $DATA_DIR         = $decoded_json->{"DataDirectory"};
my $DATA_DIR_INTERIM = $DATA_DIR . "/interim";
my $DATA_DIR_RAW     = $DATA_DIR . "/raw";
my $MUSCLE_BINARY    = $decoded_json->{"MuscleBinaryPath"};
my $MARKER           = $decoded_json->{"Marker"};

my $input_file;
my $output_file;

`mkdir -p $DATA_DIR_RAW`;
`mkdir -p $DATA_DIR_INTERIM`;

print("| Done\n");

# --------------------------------------------------------------
# Filtering, Remove sequeneces that arent the target
# --------------------------------------------------------------
print("| Filtering sequences...\n");
$input_file  = $DATA_DIR_RAW . "/bold_" . $TAXON . "_". $MARKER . "_seq.fasta";
$output_file = $DATA_DIR_INTERIM . "/bold_" . $TAXON . "_". $MARKER . "_seq_filtered.fasta";

# Remove all sequences that are not for the target marker(s). Modified from Assignment 4
save_fasta_hash( $output_file, read_filter_fasta_file( $input_file, $MARKER ) );

print("| Done\n");

# --------------------------------------------------------------
# MSA
# --------------------------------------------------------------
print("| Running MUSCLE...\n");

$input_file  = $output_file;
$output_file = $DATA_DIR_INTERIM . "/bold_" . $TAXON . "_". $MARKER . "_seq.aln";
system("muscle -in $input_file -out $output_file");

print("| Done\n");
print("Done\n");

# --------------------------------------------------------------
# Helper functions
# --------------------------------------------------------------

# Removes trailing and leading whitespace
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s }

# Removes all newline from string
sub strip { my $s = shift; $s =~ s/\n//g; $s =~ s/\r//g; return $s; }

# reads and filters a FASTA file and stores all (header,sequence) pairs in the hash above.
# Filters for a keyword within the sequence
# Takes two arguments:
#    the fasta file to reach from
#    the marker to filter by
sub read_filter_fasta_file {
    my ( $fasta_file, $marker ) = @_;

    my $current_header       = "";
    my %hash_header2sequence = ();

    # open the file for reading and stop if you encounter an error
    open( my $fin, "<$fasta_file" )
      || die("ERROR: Can't open file $fasta_file!\n");

    # read the file one line at a time. Each line is contained in the
    #  special Perl variable $_
    while (<$fin>) {
        my $line = $_;                  # store each line in the variable $line
        chomp($line);                   # remove end of line character
        if ( $line eq "" ) { next; }    # skip empty lines

        if ( $line =~ /^>.+/ ) {

            # Skip if it doesnt match pattern
            if ( index( $line, $marker ) == -1 ) {
                $current_header = "";
                next;
            }

            $hash_header2sequence{$line} = "";
            $current_header = $line;
        }
        else {
            if ( $current_header ne "" ) {
                $hash_header2sequence{$current_header} .= $line;
            }
        }

    }

    close($fin);

    return %hash_header2sequence;
}

# print the content of the hash to check if the script works properly.
# Takes two arguments:
#  The fasta hash with the value being the sequence and the key the header
#  The file output path to save it to
sub save_fasta_hash {

    my $fasta_file = shift;
    my %fasta_hash = @_;

    print "$fasta_file";

    open( my $fin, ">", $fasta_file )
      || die("ERROR: Can't open file $fasta_file!\n");

    foreach my $header ( keys %fasta_hash ) {
        print $fin "$header\n";
        print $fin "$fasta_hash{$header}\n";
    }

    close($fin);
}
