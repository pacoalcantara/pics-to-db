#!/usr/bin/perl
# Usage: $ perl exif.pl
#---------------------- Description ---------------
# Function: Imports data from files and inserts them to a MySQL Database 
#   In detail: 
#   1. Scans directories in server or disk (eg. E:\) for images (.jpeg and .gif) 
#   3. If JPEG: EXIF data and MD5 will be extracted
#   4. After being scanned and entered into the DB, a switch can be used to delete
#	   or leave originals.
#   
# ---------------------- Enviroment ---------------
#
# -ODBC connector can be used but standard MySQL connection is also supported
# -ODBC name for MySQL connection: odbcimagesys
#
# The following modules are used：

use strict;
use warnings;
use utf8;
use Image::ExifTool;
use Digest::MD5;
use DBI;
use Data::Dumper;

my $exifTool = Image::ExifTool->new;

# DELETE SWITCH - Turn the delete feature ON/OFF 
my $delete_switch_on = 0; # 0 = OFF / 1 = ON

# ---------- ODBC Connection   -----------

my $dbusername = 'db_username';
my $dbpassword = 'db_password';
my $dbname = 'imagesys';
my $driver = 'odbcimagesys';
my $debug = 0; # DBI tracing 0 = OFF / 1 = ON
my $dbh;
eval {
	$dbh = DBI->connect("dbi:ODBC:$driver","$dbusername","$dbpassword") ||  die "Can't connect to mysql $driver database: $DBI::errstr\n";
};
#--  (end)

#-- MySQL connection if no ODBC
#
#my $dbusername = 'db_username';
#my $dbpassword = 'db_password';
#my $dbname = 'imagesys';
#my $debug = 1; # DBI tracing 0 = OFF / 1 = ON
#my $dbh;
#eval {
#  $dbh = DBI->connect("dbi:mysql:$dbname","$dbusername","$dbpassword") ||  die "Can't connect to mysql database: $DBI::errstr\n";
#};
#--  (end)

# DBI tracing
if ($debug == 1)
{
unlink 'dbitrace.log' if -e 'dbitrace.log';
DBI->trace(2, 'dbitrace.log');
}
die $@ if $@;
# -- (end tracing)

my $insert_sth = $dbh->prepare("INSERT INTO images (filename, `uid`, `outputdata`, image_gif`, `exif_width`, `exif_height`, `exif_filesize`, `exif_update`, `exif_model`, `exif_rotation`, `exif_iso`, `file_update`, `exif_taken`, `exif_maker`, `exif_exposure`, `exif_fstop`, `exif_bias`, `exif_wb`, `exif_dist`, `exif_flash`, `exif_md5`, `image_data`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");


# ================== retrieve records from E:\
foreach my $i (1 .. 10) {
	#adjust internal/external storage folder name as needed
    my $server_name = sprintf('folder%03d', $i);
    print $server_name . "\n";
    ## lookup subdirectory 　
    ## format: E:\[server name]\path\to\photos\
    my $dir = "E:/$server_name/path/to/photos/";

    opendir(my $dfh, $dir) or warn "Can't read folder $dir: $!\n" and next;
    # search within dated folders
    my @daydir = grep { -d "$dir/$_" and $_ !~ /^\.+$/ } readdir($dfh); # [yymmdd_hh]
    closedir($dfh);
    foreach my $daydir (@daydir) {
        opendir($dfh, "$dir/$daydir");
        my @nnndir = grep { -d "$dir/$daydir/$_" and $_ !~ /^\.+$/ } readdir($dfh); # [nnn]
        closedir($dfh);
        foreach my $nnndir (@nnndir) {
            ## Search for .txt files 
            opendir($dfh, "$dir/$daydir/$nnndir");
            my @allfiles = grep { -f "$dir/$daydir/$nnndir/$_" } readdir($dfh);
            close($dfh);
            my @imgfiles = grep { /\.jpe?g$/i } @allfiles;
            foreach my $imgfile (@imgfiles) {
                print "img as $imgfile\n";
                my ($uid) = split(/\-/, $imgfile, 2);
                
                # Checker to determine when to delete all originals in E:\
                #
                # append to list of items to delete later on
                my @files_to_remove;
                
                my $ok_to_remove = 1; 
                my $md5_hex;
                
                ##  Search for jpeg files and if found, process them
                my ($jpeg_file) = grep { /.jpe?g$/i } @allfiles;
                my $image_data;
                my ( $exif_width, $exif_height, $exif_filesize, $exif_model, $exif_update, $exif_rotation, 
                     $exif_iso, $file_update, $exif_taken, $exif_maker, $exif_exposure, $exif_fstop, $exif_bias,
                     $exif_wb, $exif_dist, $exif_flash );
                if (defined $jpeg_file) {
                    if ( open(my $fh, '<', "$dir/$daydir/$nnndir/$jpeg_file") ) {
                        binmode($fh);    
                        $image_data = do {
                            local $/;
                            <$fh>;
                        };
                        close($fh);
                        # Extract MD5 from JPEGs
                        $md5_hex = Digest::MD5->new->add($image_data)->hexdigest;
                        print "jpeg md5 hex as $md5_hex\n";
                        if ( $delete_switch_on ) {
                            push @files_to_remove, $jpeg_file;
                            $ok_to_remove |= 2;
                        }

                        # Extract selected EXIF data from JPEGs
                        my $info = $exifTool->ImageInfo("$dir/$daydir/$nnndir/$jpeg_file");
                        if ($info->{Error}) {
                            print "Error getting EXIF info: $info->{Error}\n";
                        } 
                        else {
                            $exif_width    = $info->{ImageWidth};
                            $exif_height   = $info->{ImageHeight};
                            $exif_filesize = $info->{FileSize};
                            $exif_model    = $info->{Model};
                            $exif_update   = $info->{FileModifyDate};
                            $exif_rotation = $info->{Orientation};
                            $exif_iso      = $info->{ISO};
                            $file_update   = $info->{ModifyDate};
                            $exif_taken    = $info->{CreateDate};
                            $exif_maker    = $info->{Make};
                            $exif_exposure = $info->{ShutterSpeed};
                            $exif_fstop    = $info->{Aperture};
                            $exif_bias     = $info->{ExposureCompensation};
                            $exif_wb       = $info->{WhiteBalance};
                            $exif_dist     = $info->{SubjectDistanceRange};
                            $exif_flash    = $info->{Flash};
                            # For debugging
#                            print Dumper(\$info);
                        }
                    }
                    else {
                        warn "Can't open $jpeg_file: $!\n";
                    }
                }
                ################
                

                ## Or search for .gif files
                my ($gif_file) = grep { /$filename_wo_postfix\.gif$/i } @allfiles;
                my $gift_blob;
                if (defined $gif_file) {
                    if ( open(my $fh, '<', "$dir/$daydir/$nnndir/$gif_file") ) {
                        $gift_blob = do {
                            local $/;
                            <$fh>;
                        };
                        close($fh);
                        if ( $delete_switch_on ) {
                            push @files_to_remove, $gif_file;
                            $ok_to_remove |= 2;
                        }
                    }
                    else {
                        warn "Can't open $gif_file: $!\n";
                    }
               }
                
                                   
                $insert_sth->execute( $uid, $gift_blob, $exif_width, $exif_height, $exif_filesize, $exif_update, $exif_model, $exif_rotation, $exif_iso, $file_update, $exif_taken, $exif_maker, $exif_exposure, $exif_fstop, $exif_bias, $exif_wb, $exif_dist, $exif_flash, $md5_hex, $image_data ) or warn $dbh->errstr . "\n";
                                        
                map { unlink("$dir/$daydir/$nnndir/$_") } @files_to_remove if ( $ok_to_remove == 7 );
            }
        }
    }
}

1;
