#!/usr/bin/perl

  use strict ;

#
#* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
#  IDENTIFICATION DIVISION:
#  ========================
#
  $program::identifier = "\$\$\$index.pl" ;
  $program::version    = "01.00.00 --- 2007-07-28" ;
  $program::author     = "Kenneth E. Tomiak" ;
  $author::email       = "CBT_Ken\@KTomiak.biz" ;
#
#======================================================================
#
# Syntax:  perl $$$index.pl
# Purpose: Show what the files in this sub-directory do.
#
# History of Modifications
# ------------------------
# When     Who      What you did
# -------- -------- ---------------------------------------------------
# 20070728 KTomiak  01.00.00 Original code.
#
#======================================================================
#
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
#
#----------------------------------------------------------------------
#
#  OWNERSHIP:
#  ==========
#  This program is the property of Kenneth E Tomiak.
#  It may be freely used without the consent of Kenneth E Tomiak.
#  It may not be modified in any form.
#  No payment for distribution shall be received by anyone.
#
  $program::copyright = "\tCopyright (c) 02007 - Kenneth E Tomiak : All rights reserved." ;
#
#----------------------------------------------------------------------
#
#
#======================================================================
#
#  ENVIRONMENT DIVISION:
#  =====================
#    CONFIGURATION SECTION
#    ---------------------
  $source::computer = "Perl for Windows" ;
  $object::computer = "$^O" ;
#
#    INPUT-OUTPUT SECTION
#    --------------------
#      FILE-CONTROL
#      ------------
  if (uc($object::computer) eq "MSWIN32") {
    $winnix::slash = "\\" ;
    $windrive::c = "c:" ;
    $windrive::d = "d:" ;
  } elsif (uc($object::computer) eq "LINUX") {
    $winnix::slash = "/" ;
    $windrive::c = "" ;
    $windrive::d = "" ;
  } else {
    print "I don't run on $object::computer!\n" ;
    exit 12 ;
  }
#
#        INPUT
#        -----

#
#        OUTPUT
#        ------

#  print output will be displayed on the local terminal.

#
#        I-O
#        ---
#
#      EXTEND MODULES SEARCH PATH
#      --------------------------
#
  if ($object::computer eq "Linux") {
    use lib "/home/ktomiak/PERL" ;
  } elsif ($object::computer eq "MSWin32") {
    use lib "d:\\home\\ktomiak\\PERL" ;
  }

#
#======================================================================
#
#  DATA DIVISION:
#  ==============
#    FILE SECTION
#    ------------
#
#        INPUT
#        -----
#

#
#        OUTPUT
#        ------
#

#
#        I-O
#        ---
#

#
#        SORT
#        ----
#

#
#    WORKING-STORAGE SECTION
#    -----------------------
#      DECLARE MODULES TO BE USED
#      --------------------------

  use Time::Local ;

#
#      DECLARE GLOBAL VARIABLES
#      ------------------------

#
#======================================================================
#
#  PROCEDURE DIVISION:
#  ===================
#    MAIN SECTION
#    ------------
#======================================================================
# This is the program, it calls three subroutines.
#======================================================================
index_pl: {
  $cond::code = &perl_Initialize();
  if ($cond::code == 0) { $cond::code = &perl_Process() } ;
  &perl_Termination();
  exit $cond::code;
}

#======================================================================
# Initialize any variables used in the program and get started.
#======================================================================
sub perl_Initialize: {
  @daytable::longname = ("Sunday","Monday","Tuesday","Wednesday",
                    "Thursday","Friday","Saturday");

  @monthtable::shortname = ("Jan","Feb","Mar","Apr",
             "May","Jun","Jul","Aug","Sep",
             "Oct","Nov","Dec");

  @monthtable::longname = ("January","February","March","April",
                      "May","June","July","August","September",
                      "October","November","December");

  $my::time = "GMT";
  $gmt::timestamp = &fmt_timestamp($my::time);
  $my::time = "Local";
  $local::timestamp = &fmt_timestamp($my::time);

  $pgm::blanks = sprintf("%79c"," ") ;

  $main::program_id = &get_program_id() ;
  print "\n\n\t" . &double_wide($main::program_id) ;
  print "\n\n\tProgram: $program::identifier\n\tVersion $program::version\n\tWritten by $program::author.\n\t$program::copyright\n" ;
  print "\tInvoked from $0\n" ;
  print "\tRunning perl $] under $object::computer as process $$\n\n" ;
  print "GMT: $gmt::timestamp\n" ;
  print "LCL: $gmt::timestamp\n" ;
  $sgd::rc = &standard_global_disclaimer() ;
  return 0 ;
}

#======================================================================
# Do the main processing here.
#======================================================================
sub perl_Process: {
  print "\n" ;
  print "MEMBER      Purpose of member\n" ;
  print "----------- ------------------------------------------------\n" ;
  print "\$\$\$INDEX.PL Show what this collection contains\n" ;
  print "UPDT2HTM.PL Convert IEBUPDTE stream into html pages\n" ;
  print "\n" ;
  return $cond::code ;
}

#======================================================================
# Do any post-processing here.
#======================================================================
sub perl_Termination: {
  if ($cond::code > 0) {
    print "RC>0, so beware, rc=$cond::code.\n" ;
  }
  return ;
}

#======================================================================
# Handle requests for timestamp activities.
#======================================================================
sub fmt_timestamp: {
  $fmt_timestamp::mytime = @_[0] ;
  $fmt_timestamp::ta = 0 ;
  if ($fmt_timestamp::mytime eq "GMT") {
    ($fmt_timestamp::time_seconds, $fmt_timestamp::time_minutes, $fmt_timestamp::time_hours,
       $fmt_timestamp::date_day_of_month, $fmt_timestamp::date_month, $fmt_timestamp::date_year_relative_to_1900,
       $fmt_timestamp::dayofweek, $fmt_timestamp::indexdayofyear, $fmt_timestamp::gmtdaylightsavingstimezone)
         = gmtime();
    $fmt_timestamp::ta = $fmt_timestamp::mytime . ' ' . gmtime();
  } elsif ($fmt_timestamp::mytime eq "Local") {
    ($fmt_timestamp::time_seconds, $fmt_timestamp::time_minutes, $fmt_timestamp::time_hours,
       $fmt_timestamp::date_day_of_month, $fmt_timestamp::date_month, $fmt_timestamp::date_year_relative_to_1900,
       $fmt_timestamp::dayofweek, $fmt_timestamp::indexdayofyear, $fmt_timestamp::localdaylightsavingstimezone)
         = localtime();
    $fmt_timestamp::ta = $fmt_timestamp::mytime . ' ' . localtime();
  } elsif ($fmt_timestamp::mytime eq "Binary") {
    $fmt_timestamp::now::time = timelocal(1,1,1,$fmt_timestamp::date_day_of_month-1,$fmt_timestamp::date_month,$fmt_timestamp::date_year_relative_to_1900+1900) ;
    $fmt_timestamp::mytime = (60 * 60 * 24 * 6) + $fmt_timestamp::now::time ;
    ($fmt_timestamp::time_seconds, $fmt_timestamp::time_minutes, $fmt_timestamp::time_hours,
       $fmt_timestamp::date_day_of_month, $fmt_timestamp::date_month, $fmt_timestamp::date_year_relative_to_1900,
       $fmt_timestamp::dayofweek, $fmt_timestamp::indexdayofyear, $fmt_timestamp::binarydaylightsavingstimezone)
         = localtime($fmt_timestamp::mytime);
    $fmt_timestamp::ta = $fmt_timestamp::mytime . ' ' . localtime();
  } else {
    ($fmt_timestamp::time_seconds, $fmt_timestamp::time_minutes, $fmt_timestamp::time_hours,
       $fmt_timestamp::date_day_of_month, $fmt_timestamp::date_month, $fmt_timestamp::date_year_relative_to_1900,
       $fmt_timestamp::dayofweek, $fmt_timestamp::indexdayofyear, $fmt_timestamp::mytimedaylightsavingstimezone)
         = localtime($fmt_timestamp::mytime);
    $fmt_timestamp::ta = $fmt_timestamp::mytime . ' ' . localtime($fmt_timestamp::mytime);
  }
  $fmt_timestamp::date_year = $fmt_timestamp::date_year_relative_to_1900 + 1900 ;
  $fmt_timestamp::mymon = $Initialize_Storage::shortmonthnames[$fmt_timestamp::date_month] ;
  $fmt_timestamp::myyear = sprintf("%04d", $fmt_timestamp::date_year + 0) ;
  $fmt_timestamp::myyr = sprintf("%02d", $fmt_timestamp::date_year % 100) ;
  $fmt_timestamp::mymm = sprintf("%02d", $fmt_timestamp::date_month + 1) ;
  $fmt_timestamp::mydd = sprintf("%02d", $fmt_timestamp::date_day_of_month + 0) ;
  $fmt_timestamp::myhr = sprintf("%02d", $fmt_timestamp::time_hours + 0) ;
  if (($fmt_timestamp::myhr > -1) && ($fmt_timestamp::myhr < 12)) {
    $fmt_timestamp::am_or_pm = "AM" ;
  } else {
    $fmt_timestamp::am_or_pm = "PM" ;
  }
  $fmt_timestamp::mymn = sprintf("%02d", $fmt_timestamp::time_minutes + 0) ;
  $fmt_timestamp::mysc = sprintf("%02d", $fmt_timestamp::time_seconds + 0) ;
  $fmt_timestamp::mydow = $Initialize_Storage::longdaynames[$fmt_timestamp::dayofweek] ;
  $fmt_timestamp::mydoy = sprintf("%03d", $fmt_timestamp::indexdayofyear + 1) ;

  $fmt_timestamp::dayofyear = $fmt_timestamp::indexdayofyear + 1;

  $fmt_timestamp::thisyear = $fmt_timestamp::date_year_relative_to_1900 + 1900;
  $fmt_timestamp::thismonth = $Initialize_Storage::longmonthnames[$fmt_timestamp::date_month];
  $fmt_timestamp::thisday = $Initialize_Storage::longdaynames[$fmt_timestamp::dayofweek];

  $fmt_timestamp::thisweek = sprintf("%02d",($fmt_timestamp::mydoy + $fmt_timestamp::jan1dayofweek - 1) / 7) ;

 return $fmt_timestamp::ta;
}

#======================================================================
# Convert a string to have a space between every character.
#======================================================================
sub double_wide: {
  my @args = @_ ;
  my $args = '' ;
  my $val = '' ;
  my $byte = '' ;
  foreach $args (@args) {
    my @values = split(//,"$args") ;
    foreach $byte (@values) {
      $val .= "$byte " ;
    }
  }
  return $val ;
}

#======================================================================
# Take program location and return just the filename.extension.
#======================================================================
sub get_program_id: {
  $program::location = $0 ;
  @file::drive_path_file_ext = split/\\/,$program::location ;
  return $file::drive_path_file_ext[$#file::drive_path_file_ext] ;
}

#======================================================================
# Display the standard global disclaimer.
#======================================================================
sub standard_global_disclaimer: {
  print "\n" ;
  print "STANDARD GLOBAL DISCLAIMER\n" ;
  print "==========================\n" ;
  print "The author explicitly disavows any claim whatsoever about\n" ;
  print "the correctness or functionality of this program, and\n" ;
  print "disclaims liability for anything and everything bad that\n" ;
  print "might happen in connection with, before, during, or after\n" ;
  print "using it. I have tried to make it work right, and I am\n" ;
  print "personally pretty confident that it does, but everybody\n" ;
  print "makes mistakes, so if you use it, you do so at your own\n" ;
  print "risk.\n" ;
  print "\n" ;
}

__END__

