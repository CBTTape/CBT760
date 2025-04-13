#!/usr/bin/perl

  use strict ;
  @my::args = @ARGV ;

#
#* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
#  IDENTIFICATION DIVISION:
#  ========================
#
  $program::identifier = "updt2htm.pl" ;
  $program::version    = "01.00.02 --- 2007-07-29" ;
  $program::author     = "Kenneth E. Tomiak" ;
  $author::email       = "CBT_Ken\@KTomiak.biz" ;
#
#======================================================================
#
# Syntax:  perl updt2htm.pl
# Purpose: Convert an IEBUPDTE stream into html web pages.
#
# History of Modifications
# ------------------------
# When     Who      What you did
# -------- -------- ---------------------------------------------------
# 20070729 KTomiak  01.00.02 Use HTML off current sub-directory by
#                            stripping off leading sub-directories
#                            on IEBUPDTE stream file name.
# 20070728 KTomiak  01.00.01 Converted to FILE760 format.
# 20070110 KTomiak  01.00.00 Original code.
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
  $iebupdte::file = "$my::args[0]" ;

#
#        OUTPUT
#        ------
  $html::path = "HTML$winnix::slash" ;

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
# ./ ADD NAME=A$TITLE  0100-077-077-1205-00004-00004-00000-KTOMIAK

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
updt2htm_pl: {
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
  print "Input: $iebupdte::file.\n" ;
  $five::spaces = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" ;
  $iebupdte::open = 0 ;
  $cond::code = open(iebupdte_stream,"$iebupdte::file") ;
  if ($cond::code == 0) {
    print "Ooops... Check that name: $iebupdte::file.\n" ;
    return 12 ;
  }
  (@dir::levels) = split(/\\/,$iebupdte::file) ;
  $just::filename = $dir::levels[$#dir::levels] ;
  $iebupdte::open = 1 ;
  print "Output sub-directory: $html::path.\n" ;
  print "Just::filename($just::filename).\n" ;
  return 0 ;
}

#======================================================================
# Do the main processing here.
#======================================================================
sub perl_Process: {
  $cond::code = 0 ;
  $record::counter = 0 ;
#----------------------------------------------------------------------
# First pass, see what we have.
#----------------------------------------------------------------------
  while (<iebupdte_stream>) {
    chomp ;
    ++$record::counter ;
    if (m/.\/ ADD/i) {               # is it ./ ADD ?
      ($ieb::cc, $ieb::op, $ieb::eq, @ieb::stats) = split(/ /,$_) ;
      ($ieb::jk, $ieb::nm, $ieb::jk) = split(/=/,$ieb::eq) ;
      ($ieb::ix, $ieb::sq, $ieb::jk) = split(/\$/,$ieb::nm) ;
      if ($ieb::nm ne "") {
        $group::name{$ieb::nm} .= "$ieb::nm:" ;
      }
    }
  }
  close(iebupdte_stream) ;
  print "Records read = $record::counter.\n" ;

#----------------------------------------------------------------------
# Create the main page.
#----------------------------------------------------------------------
  $file::outlog = "${html::path}$just::filename.html" ;
  $cond::code = open(SYSUT2,">$file::outlog") ;
  if ($cond::code == 0) {
    print "${file::outlog}\t" ;
    print "Can't open it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
  &html_header() ;
  $html::line = "<ul>\n" ;
  &HTML() ;
  foreach $record::key (sort keys (%group::name)) {
    $html::line = "<li><a href=\"${record::key}.html\">" ;
    $html::line .= "${record::key}</a></li>\n" ;
    &HTML() ;
  }
  $html::line = "</ul>\n" ;
  &HTML() ;
  &html_footer() ;
  $cond::code = close SYSUT2 ;
  if ($cond::code eq 0) {
    print "${file::outlog}\t" ;
    print "Can't close it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
  foreach $record::key (sort keys (%group::name)) {
    &write_group_page() ;
  }

#----------------------------------------------------------------------
# Second pass, create one web page per member.
#----------------------------------------------------------------------
  $cond::code = open(iebupdte_stream,"$iebupdte::file") ;
  $cond::code = 0 ;
  $record::counter = 0 ;
  $file::open = "no" ;
  while (<iebupdte_stream>) {
    if (m/.\/ ADD/i) {
      if ($file::open eq "yes") {
        &close_sysut2() ;
      }
      ($ieb::cc, $ieb::op, $ieb::eq, @ieb::stats) = split(/ /,$_) ;
      ($ieb::jk, $ieb::nm, $ieb::jk) = split(/=/,$ieb::eq) ;
      ($ieb::ix, $ieb::sq, $ieb::jk) = split(/\$/,$ieb::nm) ;
      $file::outlog = "${html::path}${ieb::nm}.html" ;
      $record::key = $ieb::ix ;
      &open_sysut2() ;
    }
    $html::line = $_ ;
    &HTML() ;
  }
  close(iebupdte_stream) ;
  if ($file::open eq "yes") {
    &close_sysut2() ;
  }
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
# Handle requests for timestamp activities
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

#======================================================================
# Open the output file for the current file.
#======================================================================
sub open_sysut2: {
  $cond::code = open(SYSUT2,">$file::outlog") ;
  if ($cond::code eq 0) {
    print "${file::outlog}\t" ;
    print "Can't open it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
  &html_header() ;
  $file::open = "yes" ;
  $html::line = "<pre>\n" ;
  &HTML() ;
}

#======================================================================
# Close the output file for the current file.
#======================================================================
sub close_sysut2: {
  $html::line = "</pre>\n" ;
  &HTML() ;
  &html_footer_groups() ;
  &html_footer() ;
  $cond::code = close SYSUT2 ;
  if ($cond::code eq 0) {
    print "${file::outlog}\t" ;
    print "Can't open it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
  $file::open = "no" ;
}

#======================================================================
# Set the output file for the current group and write it out.
#======================================================================
sub write_group_page: {
  $file::outlog = "${html::path}${record::key}.html" ;
  $cond::code = open(SYSUT2,">$file::outlog") ;
  if ($cond::code eq 0) {
    print "${file::outlog}\t" ;
    print "Can't open it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
  &html_header() ;
  (@seq::nbr) = split(/:/,$group::name{$record::key}) ;
  $html::line = "<h2><a href=\"${record::key}\">$record::key</a></h2>\n" ;
  &HTML() ;
  if ($#seq::nbr > 0) {
    $html::line = "<ul>\n" ;
    &HTML() ;
    for ($x::x = 0; $x::x <= $#seq::nbr; $x::x++) {
      $html::line = "<li><a href=\"${record::key}\$$seq::nbr[$x::x].html\">" ;
      $html::line .= "${record::key}\$$seq::nbr[$x::x]</a></li>\n" ;
      &HTML() ;
    }
    $html::line = "</ul>\n" ;
    &HTML() ;
  }
  $html::line = "<h2>Categories</h2>\n" ;
  &HTML() ;
  foreach $record::key (sort keys (%group::name)) {
    $html::line = "<a href=\"${record::key}.html\">" ;
    $html::line .= "${record::key}</a>$five::spaces\n" ;
    &HTML() ;
  }
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  $html::line = "<a href=\"$just::filename.html\">" ;
  $html::line .= "INDEX</a>$five::spaces\n" ;
  &HTML() ;
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  $html::line = "<a href=\"../index.html\">" ;
  $html::line .= "Up one level</a>$five::spaces\n" ;
  &HTML() ;
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  &html_footer() ;
  $cond::code = close SYSUT2 ;
  if ($cond::code eq 0) {
    print "${file::outlog}\t" ;
    print "Can't close it.\n" ;
    $cond::code = 16 ;
    return $cond::code ;
  } else {
    $cond::code = 0 ;
  }
}

#======================================================================
# Write a group footer page.
#======================================================================
sub html_footer_groups: {
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  (@seq::nbr) = split(/:/,$group::name{$record::key}) ;
  $html::line = "<h2>$record::key</h2>\n" ;
  &HTML() ;
  for ($x::x = 0; $x::x <= $#seq::nbr; ++$x::x) {
    $html::line = "<a href=\"${record::key}\$$seq::nbr[$x::x].html\">" ;
    $html::line .= "${record::key}\$$seq::nbr[$x::x]</a>$five::spaces\n" ;
    &HTML() ;
  }
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  $html::line = "<h2>Categories</h2>\n" ;
  &HTML() ;
  foreach $record::key (sort keys (%group::name)) {
    $html::line = "<a href=\"${record::key}.html\">" ;
    $html::line .= "${record::key}</a>$five::spaces\n" ;
    &HTML() ;
  }
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  $html::line = "<a href=\"$just::filename.html\">" ;
  $html::line .= "INDEX</a>$five::spaces\n" ;
  &HTML() ;
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
  $html::line = "<a href=\"../index.html\">" ;
  $html::line .= "Up one level</a>$five::spaces\n" ;
  &HTML() ;
  $html::line = "<hr noshade size=\"4\" color=\"#66CCCC\">\n" ;
  &HTML() ;
}

#======================================================================
# Write a line.
#======================================================================
sub HTML: {
  print SYSUT2 ("$html::line") ;
  return  ;
}

#======================================================================
# Write a standard header block.
#======================================================================
sub html_header: {
  $time::block = &fmt_timestamp("Local") ;
  my $timestamp = "${fmt_timestamp::myyear}${fmt_timestamp::mymm}${fmt_timestamp::mydd}" ;
  $timestamp .= " ${fmt_timestamp::myhr}:${fmt_timestamp::mymn}:${fmt_timestamp::mysc}" ;
    print SYSUT2 <<ENDOFMSG ;
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 3.0//EN">
<!--                                                                 -->
<!-- Version       | TimeStamp         | Description of change       -->
<!-- ------------- | ----------------- | --------------------------- -->
<!-- 1.0.0 KTomiak | $timestamp | Original version            -->
<!--                                                                 -->

<html>
 <!---
 Author: Kenneth E Tomiak
 $main::program_id Copyright (c) 0$fmt_timestamp::myyear by Kenneth E Tomiak
 --->

<head>
 <title>
 $just::filename - $record::key Examples
 </title>

 <!--META_START-->

 <meta HTTP-EQUIV="Content-Type" content="text/html ; charset=iso8859-1">
 <meta name="ROBOTS" content="INDEX, FOLLOW">
 <meta name="abstract" content="Web pages for files in $just::filename">
 <meta name="Keywords" content="$just::filename">
 <meta name="owner" content="Author of $just::filename">
 <meta name="author" content="$0">
 <meta name="modified" content="${fmt_timestamp::myyear}${fmt_timestamp::mymm}${fmt_timestamp::mydd}">
 <meta name="review" content="${fmt_timestamp::myyear}1231">
 <meta name="security" content="public">
 <meta name="ms.locale" content="EN-US">
 <meta name="Generator" content="Kenneth Tomiak's perl program $0">

 <!--META_END-->

</head>
<BODY BGCOLOR="#FFFFFF" LINK="#000066" ALINK="#000088">

 <A NAME="pgtop"></A>

 <center>
 <h1>
 <a href=\"../$just::filename.html\">$just::filename</a> - $record::key Examples
 </h1>
 </center>

<hr noshade size=\"4\" color=\"#66CCCC\">

ENDOFMSG
}

#======================================================================
# Write a standard footer block.
#======================================================================
sub html_footer: {
  print SYSUT2 <<ENDOFMSG ;

<hr noshade size=\"4\" color=\"#CCCC66\">

<A NAME="pgbottom"></A>
<hr noshade size=\"4\">
<SCRIPT LANGUAGE="JavaScript">
<!--
document.write("<b>" + location.href + "</b>")
// -->
</SCRIPT>

<hr noshade size=\"4\">
<b> $main::program_id Copyright:</b> &copy; 0$fmt_timestamp::myyear by Kenneth E Tomiak
<br>
<SCRIPT LANGUAGE="JavaScript">
<!--
var d = new Date(document.lastModified)
document.write("<b>Last modified:</b> " + d)
// -->
</SCRIPT>
<hr noshade size=\"4\">

</body>
</html>
ENDOFMSG
}

#======================================================================
# This is the end of the code.
#======================================================================
__END__

