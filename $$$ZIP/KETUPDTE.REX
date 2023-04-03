rexx_KETUPDTE: /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "01.04"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 Dataset: KETUPDTE.REX
 Author:  KTomiak
 Contact: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
 Syntax:  KETUPDTE {iebupdte_stream_filename}
 Purpose: Read an input file with IEBUPDTE control cards and
          split members into separate files.

=======================================================================

 History of Modifications
 ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  01.04 Standardizing Rexx_Initialize routine
  20070713 KTomiak  01.03 Converted to Open Object REXX, converted to
                          Ken's Universe style, added design features
                          from KETRECV, and output statistics to the
                          RPT file.
  19971223 KTomiak  01.02 Correctly get length of member.
  19971219 KTomiak  01.01 Prefix current drive and previous dir If ..\.
  19970827 KTomiak  01.00 Original code for IBM PC DOS 7.1 REXX.

=======================================================================

STANDARD GLOBAL DISCLAIMER
The author explicitly disavows any claim whatsoever about the
correctness or functionality of this program, and disclaims liability
for anything and everything bad that might happen in connection with,
before, during, or after using it.  I have tried to make it work right,
and I am personally pretty confident that it does, but everybody makes
mistakes, so if you use it, you do so at your own risk.

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

  Parse Arg all_my_arguments
  Numeric Digits 12

rexx_Main_KETUPDTE:
  return_code = rexx_Initialize()
  If (return_code = 0) Then,
    Do
      return_code = rexx_Process()
    End
  return_code = rexx_Termination()
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 In this routine we open any files and initialize any
 constants we might need.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Initialize:
  Parse VERSION,
    version_rexx_name,
    version_rexx_version,
    version_rexx_date
  Parse SOURCE,
    source_host_env,
    source_call_type,
    source_uc_exec_name,
    source_hostdd,
    source_hostdsn,
    source_nf_exec_name,
    source_initial_cmd_env,
    source_asid_name,
    source_char8_user_token,
    source_hostother
  return_code = 0
  Address_Environment = Address()
  Select
    When (version_rexx_name = "REXX-ooRexx_3.1(MT)") Then,
      REXX_ENVIR = "PC/ooREXX"
    When ((version_rexx_name = "REXXSAA") & ,
          (source_initial_cmd_env = "DOS")) Then,
      REXX_ENVIR = "PC/IBM_PC_DOS"
    When ((version_rexx_name = "REXXSAA") & ,
          (source_initial_cmd_env = "OS2")) Then,
      REXX_ENVIR = "PC/IBM_OS/2"
    When ((version_rexx_name = "REXX370") & ,
          (source_initial_cmd_env = "CMS")) Then,
      REXX_ENVIR = "VM/CMS"
    When ((source_asid_name = "MVS") & ,
          (source_initial_cmd_env = "MVS")) Then,
      REXX_ENVIR = "MVS/Batch"
    When ((version_rexx_name = "REXX370") & ,
          (source_initial_cmd_env = "TSO")) Then,
      REXX_ENVIR = "MVS/TSO"
    When ((version_rexx_name = "REXX370") & ,
          (source_initial_cmd_env = "ISPF")) Then,
      REXX_ENVIR = "MVS/TSO/ISPF"
    When ((version_rexx_name = "REXX/2") & ,
          (source_initial_cmd_env = "WINDOWS")) Then,
      REXX_ENVIR = "PC/SPFPC"
    When (Address_Environment = "COMMAND") Then,      /* PC/DOS 7.0 */
      REXX_ENVIR = "PC/DOS7.0"
    When (Address_Environment = "SYSTEM") Then,       /* Regina Rexx */
      REXX_ENVIR = "PC/REGINA"
    Otherwise
      REXX_ENVIR = "UNKNOWN"
  End
  say ""
  say Copies("=",55)
  say left("=" source_uc_exec_name dir2updt_version,53) "="
  say left("=" "executing under" source_host_env,53) "="
  say left("=" "as a" source_call_type,53) "="
  say left("=  on" date() "at" time()".",53) "="
  say Copies("=",55)
  say ""
  rpt_open = 0
  Say "all_my_arguments("all_my_arguments")"
  Say ""
  If (REXX_ENVIR >< "PC/ooREXX") Then,
    Do
      return_code = 24
      Say Copies("!",79)
      Say "Sorry, this only runs on a PC under Open Object REXX!"
      Say Copies("!",79)
      Return return_code
    End
  help_rc = check_for_help()
  If (help_rc > 0) Then Return help_rc
  Parse Var all_my_arguments ieb_in " " .,
    =1 . "DEBUG" debug_state .
  If (DataType(debug_state) >< "NUM") Then debug_state = 0

  file_size = Chars(ieb_in)
  If (file_size > 0) Then,
    Do
      ieb_in_txt = ieb_in
    End
  Else,
    Do
      Say "Let me try adding .txt for you."
      Parse Var ieb_in ieb_in_txt "." .
      ieb_in_txt = ieb_in_txt".txt"
      file_size = Chars(ieb_in_txt)
      If (file_size = 0) Then,
        Do
          Say "Let me try adding .text for you."
          Parse Var ieb_in ieb_in_txt "." .
          ieb_in_txt = ieb_in_txt".text"
          file_size = Chars(ieb_in_txt)
          If (file_size = 0) Then,
            Do
              Say ieb_in "appears to be empty",
                "or nonexistent, file size("file_size")."
              return_code = 16
              Return return_code
            End
        End
    End

  back_wards = Reverse(ieb_in)
  Parse Var back_wards in_file_txt "\" path_drive
  just_file_name = Reverse(in_file_txt)
  drive_path = Reverse(path_drive)
  txt_file_rpt = ieb_in".$$$.rpt"
  rpt_open = 1

  "erase" ieb_in_txt".$$$.*"
  dos_cmd_rc = rc
  If (dos_cmd_rc >< 0) Then,
    Do
      rpt = "erase" ieb_in_txt".$$$.*",
        "will show file not found if no files existed",
        "RC("dos_cmd_rc")."
      Say rpt
      write_rc = LineOut(txt_file_rpt,rpt)
    End

  rpt = source_uc_exec_name Copies(" ",20) Date() Time()
  write_rc = LineOut(txt_file_rpt,rpt)
  rpt = "DEBUG state("debug_state")"
  write_rc = LineOut(txt_file_rpt,rpt)
  rpt = just_file_name "has" file_size "character(s)."
  write_rc = LineOut(txt_file_rpt,rpt)
  Say rpt

  "rmdir" just_file_name".$$$ /S"
  "mkdir" just_file_name".$$$"
  rpt = ,
    "MEMBER  ",
    "VV",
    "MM",
    "ISIZE",
    "CSIZE",
    "MSIZE",
    "CREATED   ",
    "MODDATE   ",
    "MTIME",
    "USERID"
  write_rc = LineOut(txt_file_rpt,rpt)
  rpt = ,
    Copies("-",8),
    Copies("-",2),
    Copies("-",2),
    Copies("-",5),
    Copies("-",5),
    Copies("-",5),
    Copies("-",10),
    Copies("-",10),
    Copies("-",5),
    Copies("-",7)
  write_rc = LineOut(txt_file_rpt,rpt)
  Return return_code

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 In this routine we Do our processing.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Process:
  endup_found = 0
  member_open = 0
  Do while LINES(ieb_in)
    line_in=LineIn(ieb_in)
    Select
      When (left(line_in,2) = "./") Then,
        Do
          Call parse_control_card
        End
      Otherwise
        myrc = LineOut(member_name,line_in)
        return_code = RC
        If (return_code >< 0) Then,
          Do
            Say "LineOut failed for" member_name", RC("return_code")."
            Return return_code
          End
    End
  End
  Return return_code

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 In this routine we close files and finish up.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Termination:
  If (member_open = 1) Then,
    Do
      Call close_member
    End
  line_in = LineOut(ieb_in)
  If (endup_found = 0) Then,
    Do
      Say "Poorly coded IEBUPDTE stream, ./ ENDUP is missing."
    End
  say ""
  say Copies("=",55)
  say left("= DONE.",53) "="
  say Copies("=",55)
  say ""
  Return return_code

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Parse the control card and any ISPF statistics.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_control_card:
  If (member_open = 1) Then,
    Do
      Call close_member
    End
  Parse Var line_in,
    dot_slash,
    verb,
    operands,
    stats
  ispf_stats = 0
  Select
    When (verb = "ENDUP") Then,
      Do
        Call close_member
        endup_found = 1
      End
    When (verb = "ALIAS") Then,
      Do
        Call parse_operands
        Say "No support for ALIAS entries at this time."
        rpt = member_name "ALIAS"
        write_rc = LineOut(txt_file_rpt,rpt)
      End
    When (verb = "CHANGE") Then,
      Do
        Call parse_operands
        Say "No support for CHANGE control cards, use IEBUPDTE."
        rpt = member_name "./ CHANGE NOT SUPPORTED"
        write_rc = LineOut(txt_file_rpt,rpt)
        member_name = member_name".CHG"
      End
    Otherwise
      Call parse_operands
      Call parse_stats
      Call open_member
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Parse operands to get just the member name.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_operands:
  Parse Var operands,
    . "NAME=" member_name "," .
  Parse Var member_name member_name " " .
  mbrname = space(member_name)
  member_name = just_file_name".$$$\"mbrname
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Parse stats and figure out if there are any, and if so, which.
./ ADD NAME=A$TITLE  0100-07007-07007-1205-00004-00004-00000-KTOMIAK
./N3 ADD NAME=BIORYTHM 33 2002/08/15 08:34
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_stats:
  stats = Space(stats)
  If (Length(stats) < 8) Then,
    Do
      rpt = member_name "NO STATS"
      write_rc = LineOut(txt_file_rpt,rpt)
      Return
    End
  Select
    When (Pos("-",stats) > 0) Then,
      Do
        ispf_stats = 1
        Parse Var stats,
          vv_mm "-",
          cre_jdate "-",
          mod_jdate "-",
          mod_time "-",
          initl "-",
          curl "-",
          modl "-" ,
          z4muser "-",
          .
        Parse Var vv_mm zlvers +2 zlmod +2 .
        Parse Var cre_jdate yy +2 ddd +3 .
        If (yy < 65) Then cc = "01"
        Else cc = "00"
        z4cdate = doy2g(cc""yy""ddd"F")
        Parse Var mod_jdate yy +2 ddd +3 .
        If (yy < 65) Then cc = "01"
        Else cc = "00"
        z4mdate = doy2g(cc""yy""ddd"F")
        Parse Var mod_time mbr_hr +2 mbr_mn +2 .
        z4mtime = mbr_hr":"mbr_mn
      End
    When (Pos("/",stats) > 0) Then,
      Do
        ispf_stats = 2
        Parse Var stats,
          initl,
          z4mdate,
          z4mtime,
          vv_dot_mm,
          z4muser,
          .
        Parse Var vv_dot_mm zlvers +2 . +1 zlmod .
        If (DataType(zlvers) >< "NUM") Then,
          Do
            zlvers = "01"
            zlmod  = "00"
            z4muser = Left(source_uc_exec_name,7)
          End
        If (DataType(zlmod) >< "NUM") Then,
          Do
            zlmod  = "00"
          End
        If (z4muser = "") Then,
          Do
            z4muser = Left(source_uc_exec_name,7)
          End
        z4cdate = z4mdate
        curl = initl
        modl = 0
        initl = 1
      End
    Otherwise
      Say "Unknown format, ignoring ("Length(stats)")=",
        "="stats"=."
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Convert day-of-year to Gregorian date
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
doy2g: Procedure
  Arg ccyyddds
  Parse Var ccyyddds,
    century +2,
    year    +2,
    days    +3,
    sign    +1
  yy = 1900 + (century * 100) + year
  ddd = days + 0
  If (yy // 4 = 0) Then,
     dom = 31 29 31 30 31 30 31 31 30 31 30 31 999
   Else,
     dom = 31 28 31 30 31 30 31 31 30 31 30 31 999
  If (yy // 400 = 0)  Then,
     dom = 31 28 31 30 31 30 31 31 30 31 30 31 999
  Do i = 1 by 1 until ddd < 0
     ddd = ddd - word(dom,i)
  End
  Return Right(i,2,0)"/"Right(ddd+word(dom,i),2,0)"/"yy

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Open the member.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
open_member:
  member_open = 1
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Close the member and update the ISPF statistics.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
close_member:
  write_rc = LineOut(member_name)
  If (ispf_stats > 0) Then,
    Do
      Call update_ispf_stats
    End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Set the statistics per the control card.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
update_ispf_stats:
  rpt = ,
    Left(mbrname,8),
    Right(" "zlvers,2),
    Right(" "zlmod,2),
    Right(" "initl,5),
    Right(" "curl,5),
    Right(" "modl,5),
    Right(" "z4cdate,10),
    Right(" "z4mdate,10),
    Right(" "z4mtime,5),
    z4muser
  write_rc = LineOut(txt_file_rpt,rpt)
  ispf_stats = 0
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Either a question mark or some switch form of HELP, gets syntax.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
check_for_help:
  Push all_my_arguments
  Pull all_uc_arguments
  If (all_my_arguments= "") Then,
    Do
      Call show_simple_syntax
      Call show_some_history
      Return 4
    End
  If (Pos("?",all_my_arguments) > 0) Then,
    Do
      Call show_simple_syntax
      Return 4
    End
  If (Pos("/HELP",all_uc_arguments) > 0) Then,
    Do
      Call show_simple_syntax
      Return 4
    End
  If (Pos("-HELP",all_uc_arguments) > 0) Then,
    Do
      Call show_simple_syntax
      Return 4
    End
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Either a question mark or some switch form of HELP, gets syntax.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
show_simple_syntax:
  Say ""
  Say "You want to know how to use" source_uc_exec_name"?"
  Say "So would I."
  Say ""
  Say "Syntax:"
  Say ">>--KETUPDTE---file_name--+---------+----<<"
  Say "                          +-DEBUG=#-+"
  Say "         #=Level of debugging information written to .RPT."
  Say ""
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 No parameters were passed.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
show_some_history:
  Say Copies("-",79)
  Say "History:"
  Say "I first wrote a REXX form of IEBUPDTE for the PC"
  Say "under IBM PC DOS 7.1 REXX. It handled things okay, and still"
  Say "would. However, after tackling KETRECV, I decided to retrofit"
  Say "some of the design features from there, into here. I had also"
  Say "whipped together a version to run on z/OS and set the ISPF"
  Say "statistics from information on the ./ control card. While I"
  Say "could fudge the date and time on the system, I decided to"
  Say "write the statistics into a .RPT file instead."
  Say ""
  Say '"Kenneth Tomiak"<CBT_Ken@KTomiak.biz>'
  Say ""
  Say Copies("-",79)
  Say ""
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
__DATA__
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

