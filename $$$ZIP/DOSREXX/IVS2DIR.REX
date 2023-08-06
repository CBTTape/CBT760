rexx_IVS2DIR:  /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "02.01"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

=======================================================================

  Dataset: REXX(IVS2DIR)
  Author:  KTomiak
  Contact: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
  Syntax:  IVS2DIR (filename) (DEBUG=#)
           filename - [drive:][path\]filename
           ".xmi" and beyond will get stripped off.
           DEBUG=# - # is 0 - 5 to contorl level of debugging output.
  Purpose: Read the INMCOPY version of an internal IEBCOPY unload
           format or your own IEBCOPY unload downloaded to a PC.

  History of Modifications
  ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  02.01 Standardizing Rexx_Initialize routine
  20070709 KTomiak  02.00 This is the second half of KETRECV in case
                          you have a PDS in internal IEBCOPY unload
                          format as produced by XMI2INM.
                          Might even work if you properly downloaded
                          a backup of a PDS as
                          RECFM=VS,BLKSIZE=32740,LRECL=32736.
  20011004 KTomiak  01.00 Original code that worked.

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

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Call the other routines.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Main_IVS2DIR:
  return_code = rexx_Initialize()
  If (return_code = 0) Then,
    Do
      return_code = rexx_Process()
    End
  return_code = rexx_Termination()
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we open any files and intialize any
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
      return return_code
    End

  help_rc = check_for_help()
  If (help_rc > 0) Then Return help_rc

  Parse Var all_my_arguments xmit_file_in " " .,
    =1 . "DEBUG" debug_state .
  If (DataType(debug_state) >< "NUM") Then debug_state = 0
  Parse Var xmit_file_in xmit_file_orig .

  xmit_file_orig =  xmit_file_orig
  file_size = Chars(xmit_file_orig)
  If (file_size = 0) Then Return 12
  rpt = xmit_file_orig "size("file_size")"
  If (debug_state > 1) then,
    write_rc = LineOut(xmit_file_rpt,rpt)
  rpt_open = 1

  back_wards = Reverse(xmit_file_in)
  Parse Var back_wards in_file_xmit "\" path_drive
  just_file_name = Reverse(in_file_xmit)
  drive_path = Reverse(path_drive)
  xmit_file_rpt = xmit_file_in".$$$.rpt"

  "erase" xmit_file_in".$$$.*"
  dos_cmd_rc = rc
  If (dos_cmd_rc >< 0) Then,
    Do
      rpt = "erase" xmit_file_in".$$$.*",
        "will show file not found if no files existed",
        "RC("dos_cmd_rc")."
      Say rpt
      write_rc = LineOut(xmit_file_rpt,rpt)
    End

  rpt = source_uc_exec_name Copies(" ",20) Date() Time()
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "DEBUG state("debug_state")"
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "Drive:Path="drive_path
  If (debug_state > 3) then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = just_file_name "has" file_size "character(s)."
  write_rc = LineOut(xmit_file_rpt,rpt)
  Say rpt

  Call rexx_build_arrays
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we loop through our input.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Process:
  rpt = " "
  write_rc = LineOut(xmit_file_rpt,rpt)

  "rmdir" xmit_file_xmi".$$$ /S"
  "mkdir" xmit_file_xmi".$$$"
  iebcopy_counter = 0
  this_idx = 1
  this_size = Chars(xmit_file_orig)
  dir_entries = "Y"
  ttr_alias. = ""
  ttr_char. = ""
  ttr_name. = ""
  mbrblk. = ""
  maxmbrs = 0
  Do While this_idx < this_size
    rdw_len = 4
    this_rdw = CharIn(xmit_file_orig,this_idx,rdw_len)
    this_idx = this_idx + rdw_len
    rdw_len = c2d(Left(this_rdw,2)) - 8
    rpt = "IEBCOPY rdw("rdw_len")"
    If (debug_state > 1) then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    iebcopy_counter = iebcopy_counter + 1
    data_line = CharIn(xmit_file_orig,this_idx,rdw_len)
    rpt = "IEBCOPY txt("data_line")"
    If (debug_state > 2) then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    this_idx = this_idx + rdw_len
    Call iebcopy_extract
  End
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  convert dsorg to displayable meaning
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
x2c_dsorg: Procedure
  Parse Arg hex_dsorg
  Select
    When hex_dsorg = "0008" Then real_dsorg = "VSAM"
    When hex_dsorg = "0200" Then real_dsorg = "PO"
    When hex_dsorg = "4000" Then real_dsorg = "PS"
    When hex_dsorg = "0000" Then real_dsorg = "U"        /* Obsolete */
    When hex_dsorg = "2000" Then real_dsorg = "DA"       /* Obsolete */
    When hex_dsorg = "8000" Then real_dsorg = "ISAM"     /* Obsolete */
    Otherwise,
      Do
        real_dsorg = "NONE"
      End
  End
  Return real_dsorg

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  convert record format to displayable meaning
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
x2c_recfm: Procedure
  Parse Arg hex_recfm
  real_recfm = ""
  If (BitAnd(hex_recfm,"0001") = "0001") Then,
    real_recfm = real_recfm"SVBS"
  If (BitAnd(Right(hex_recfm,2),"02") = "02") Then,
    real_recfm = real_recfm"+noRDW"
  If (BitAnd(hex_recfm,"C000") = "C000") Then,
    real_recfm = real_recfm"U"
  If (BitAnd(hex_recfm,"4000") = "4000") Then,
    real_recfm = real_recfm"V"
  If (BitAnd(hex_recfm,"8000") = "8000") Then,
    real_recfm = real_recfm"F"
  If (BitAnd(hex_recfm,"1000") = "1000") Then,
    real_recfm = real_recfm"B"
  If (BitAnd(hex_recfm,"2000") = "2000") Then,
    real_recfm = real_recfm"T"
  If (BitAnd(hex_recfm,"0800") = "0800") Then,
    real_recfm = real_recfm"S"
  If (BitAnd(hex_recfm,"0200") = "0200") Then,
    real_recfm = real_recfm"M"
  If (BitAnd(hex_recfm,"0400") = "0400") Then,
    real_recfm = real_recfm"A"
  Return real_recfm

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  convert type of data set to displayable meaning
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
convert_type: Procedure
  Parse Arg dstype
  Select
    When (dstype = "80") Then real_dstype = "Data Library"
    When (dstype = "40") Then real_dstype = "Program Library"
    When (dstype = "00") Then real_dstype = "No Library"
    Otherwise
      real_dstype = "Uknown"
  End
  Return real_dstype

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  convert date to displayable meaning
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
convert_date: Procedure
  Parse Arg pdate
  pdate_yr = SubStr(pdate,1,4)
  pdate_mm = SubStr(pdate,5,2)
  pdate_dy = SubStr(pdate,7,2)
  pdate_hr = SubStr(pdate,9,2)
  pdate_mn = SubStr(pdate,11,2)
  pdate_sc = SubStr(pdate,13,2)
  ddate = pdate_yr'-'pdate_mm'-'pdate_dy,
    pdate_hr":"pdate_mn":"pdate_sc
  Return ddate

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we close files and finish up.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Termination:
  If (rpt_open = 1) Then,
    Do
      rpt = " "
      write_rc = LineOut(xmit_file_rpt,rpt)
      rpt = source_uc_exec_name "completed."
      write_rc = LineOut(xmit_file_rpt,rpt)
      rpt = " "
      write_rc = LineOut(xmit_file_rpt,rpt)
      write_rc = LineOut(xmit_file_rpt)
    End
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we close files and finish up.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
finish_last_file:
  "Rename" xmit_ebcdic_nbr xmit_file_orig".ebcdic"
  dos_cmd_rc = rc
  If (dos_cmd_rc >< 0) Then,
    Do
      rpt = "Rename" xmit_ebcdic_nbr,
        "to" xmit_file_orig".ebcdic" "RC("dos_cmd_rc")."
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  temp_key = "2_"inmr03_counter"_1"
  If (txtunit_INMUTILN.temp_key = "IEBCOPY") Then,
    Do
      rpt = "Call IEBCOPY to unload"
      write_rc = LineOut(xmit_file_rpt,rpt)
      Call iebcopy_unload
    End
  Return 0

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
  Convert EBCDIC value to PC ASCII value
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
e2a: Procedure Expose xlat_e2a
  Return translate(arg(1),xlat_e2a)

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Convert PC ASCII value to EBCDIC value
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
a2e: Procedure Expose xlat_a2e
  Return translate(arg(1),xlat_a2e)

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we build stem variables for character translations
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_build_arrays:

  xlat_e2a = ''   /*  0 1 2 3 4 5 6 7 8 9 A B C D E F  */
  xlat_e2a = xlat_e2a'000102039C09867F978D8E0B0C0D0E0F'x  /* 00 - 0F */
  xlat_e2a = xlat_e2a'101112139D8508871819928F1C1D1E1F'x  /* 10 - 1F */
  xlat_e2a = xlat_e2a'80818283840A171B88898A8B8C050607'x  /* 20 - 2F */
  xlat_e2a = xlat_e2a'909116939495960498999A9B14159E1A'x  /* 30 - 3F */
  xlat_e2a = xlat_e2a'20A0E2E4E0E1E3E5EFF1A22E3C282B7C'x  /* 40 - 4F */
  xlat_e2a = xlat_e2a'26E9EAEBE8EDEEEFECDF21242A293B5E'x  /* 50 - 5F */
  xlat_e2a = xlat_e2a'2D2FC2C4C0C1C3C5C7D1A62C255F3E3F'x  /* 60 - 6F */
  xlat_e2a = xlat_e2a'F8C9CACBC8CDCECFCC603A2340273D22'x  /* 70 - 7F */
  xlat_e2a = xlat_e2a'D8616263646566676869ABBBF0FDFEB1'x  /* 80 - 8F */
  xlat_e2a = xlat_e2a'B06A6B6C6D6E6F707172AABAE6B8C6A4'x  /* 90 - 9F */
  xlat_e2a = xlat_e2a'B57E737475767778797AA1BFD05BDEAE'x  /* A0 - AF */
  xlat_e2a = xlat_e2a'ACA3A5B7A9A7B6BCBDBEDDA8AF5DB4D7'x  /* B0 - BF */
  xlat_e2a = xlat_e2a'7B414243444546474849ADF4F6F2F3F5'x  /* C0 - CF */
  xlat_e2a = xlat_e2a'7D4A4B4C4D4E4F505152B9FBFCF9FAFF'x  /* D0 - DF */
  xlat_e2a = xlat_e2a'5CF7535455565758595AB2D4D6D2D3D5'x  /* E0 - EF */
  xlat_e2a = xlat_e2a'30313233343536373839B3DBDCD9DA9F'x  /* F0 - FF */

  xlat_a2e = ''   /*  0 1 2 3 4 5 6 7 8 9 A B C D E F  */
  xlat_a2e = xlat_a2e'00010203372D2E2F1605250B0C0D0E0F'x  /* 00 - 0F */
  xlat_a2e = xlat_a2e'101112133C3D322618193F271C1D1E1F'x  /* 10 - 1F */
  xlat_a2e = xlat_a2e'405A7F7B5B6C507D4D5D5C4E6B604B61'x  /* 20 - 2F */
  xlat_a2e = xlat_a2e'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F'x  /* 30 - 3F */
  xlat_a2e = xlat_a2e'7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6'x  /* 40 - 4F */
  xlat_a2e = xlat_a2e'D7D8D9E2E3E4E5E6E7E8E9ADE0BD5F6D'x  /* 50 - 5F */
  xlat_a2e = xlat_a2e'79818283848586878889919293949596'x  /* 60 - 6F */
  xlat_a2e = xlat_a2e'979899A2A3A4A5A6A7A8A9C04FD0A107'x  /* 70 - 7F */
  xlat_a2e = xlat_a2e'202122232415061728292A2B2C090A1B'x  /* 80 - 8F */
  xlat_a2e = xlat_a2e'30311A333435360838393A3B04143EFF'x  /* 90 - 9F */
  xlat_a2e = xlat_a2e'41AA4AB19FB26AB5BBB49A8AB0CAAFBC'x  /* A0 - AF */
  xlat_a2e = xlat_a2e'908FEAFABEA0B6B39DDA9B8BB7B8B9AB'x  /* B0 - BF */
  xlat_a2e = xlat_a2e'6465626663679E687471727378757677'x  /* C0 - CF */
  xlat_a2e = xlat_a2e'AC69EDEEEBEFECBF80FDFEFBFCBAAE59'x  /* D0 - DF */
  xlat_a2e = xlat_a2e'4445424643479C485451525358555657'x  /* E0 - EF */
  xlat_a2e = xlat_a2e'8C49CDCECBCFCCE170DDDEDBDC8D8EDF'x  /* F0 - FF */
  txtunit_INMDDNAM. = ""
  txtunit_INMDSNAM. = ""
  txtunit_INMMEMBR. = ""
  txtunit_INMSECND. = ""
  txtunit_INMDIR.    = ""
  txtunit_INMEXPDT. = ""
  txtunit_INMTERM.   = ""
  txtunit_INMBLKSZ. = ""
  txtunit_INMDSORG. = ""
  txtunit_INMLRECL. = ""
  txtunit_INMRECFM. = ""
  txtunit_INMTNODE. = ""
  txtunit_INMTUID.   = ""
  txtunit_INMFNODE. = ""
  txtunit_INMFUID.   = ""
  txtunit_INMLREF.   = ""
  txtunit_INMLCHG.   = ""
  txtunit_INMCREAT. = ""
  txtunit_INMFVERS. = ""
  txtunit_INMFTIME. = ""
  txtunit_INMTTIME. = ""
  txtunit_INMFACK.   = ""
  txtunit_INMERRCD. = ""
  txtunit_INMUTILN. = ""
  txtunit_INMUSERP. = ""
  txtunit_INMRECCT. = ""
  txtunit_INMSIZE.   = ""
  txtunit_INMFFM.    = ""
  txtunit_INMNUMF.   = ""
  txtunit_INMTYPE.   = ""

  dasd_model. = ""
  dasd_model.01.200   = "2311 no-alt"
  dasd_model.01.203   = "2311"
  dasd_model.02.0     = "2301"
  dasd_model.04.0     = "2302"
  dasd_model.04.1440  = "9345-1"
  dasd_model.04.2156  = "9345-2"
  dasd_model.03.0     = "2303"
  dasd_model.05.0     = "2321"
  dasd_model.06.48    = "2305-1 no-alt"
  dasd_model.06.54    = "2305-1"
  dasd_model.07.96    = "2305-2 no-alt"
  dasd_model.07.108   = "2305-2"
  dasd_model.08.200   = "2314 no-alt"
  dasd_model.08.203   = "2314"
  dasd_model.09.404   = "3330-1 no-alt"
  dasd_model.09.411   = "3330-1"
  dasd_model.0A.808   = "3330-11 no-alt"
  dasd_model.0A.815   = "3330-11"
  dasd_model.0B.348   = "3340-35 no-alt"
  dasd_model.0B.360   = "3340-35"
  dasd_model.0B.696   = "3340-70 no-alt"
  dasd_model.0B.708   = "3340-70"
  dasd_model.0C.555   = "3350 no-alt"
  dasd_model.0C.560   = "3350"
  dasd_model.0D.959   = "3375 no-alt"
  dasd_model.0D.960   = "3375"
  dasd_model.0E.885   = "3380-A/B/D/J no-alt"
  dasd_model.0E.886   = "3380-A/B/D/J"
  dasd_model.0E.1770  = "3380-E no-alt"
  dasd_model.0E.1772  = "3380-E"
  dasd_model.0E.2655  = "3380-K no-alt"
  dasd_model.0E.2658  = "3380-K"
  dasd_model.0E.3339  = "EMC3380-K no-alt"
  dasd_model.0E.3342  = "EMC3380-K"
  dasd_model.0E.3993  = "EMC3380-KK no-alt"
  dasd_model.0E.3996  = "EMC3380-KK"
  dasd_model.0F.1113  = "3390-1 no-alt"
  dasd_model.0F.1114  = "3390-1"
  dasd_model.0F.2226  = "3390-2 no-alt"
  dasd_model.0F.2227  = "3390-2"
  dasd_model.0F.3339  = "3390-3 no-alt"
  dasd_model.0F.3340  = "3390-3"
  dasd_model.0F.10017 = "3390-9 no-alt"
  dasd_model.0F.10020 = "3390-9"
  dasd_model.0F.32760 = "3390-27 no-alt"
  dasd_model.0F.32763 = "3390-27"
  dasd_model.0F.65520 = "3390-54 no-alt"
  dasd_model.0F.65523 = "3390-54"
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Convert dasdtype to displayable meaning
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
convert_dasdtype:
  Parse Arg bin_dasdtype dec_devcapacity
  hex_dasdtype = c2x(bin_dasdtype)
  d_dasdtype = Value("dasd_model."hex_dasdtype"."dec_devcapacity)
  Return d_dasdtype

/*dasd_model.{dasdtype}.{max_cyl} = model_type                 */

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Read IEBCOPY unload dataset back into stem data_line.#
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
iebcopy_unload:
  rpt = " "
  write_rc = LineOut(xmit_file_rpt,rpt)
  xmit_file_orig =  xmit_file_orig".ebcdic"
  file_size = Chars(xmit_file_orig)
  rpt = xmit_file_orig "size("file_size")"
  If (debug_state > 1) Then,
    write_rc = LineOut(xmit_file_rpt,rpt)

  "rmdir" xmit_file_xmi".$$$ /S"
  "mkdir" xmit_file_xmi".$$$"
  iebcopy_counter = 0
  this_idx = 1
  this_size = Chars(xmit_file_orig)
  dir_entries = "Y"
  ttr_alias. = ""
  ttr_char. = ""
  ttr_name. = ""
  mbrblk. = ""
  maxmbrs = 0
  Do While this_idx < this_size
    rdw_len = 4
    this_rdw = CharIn(xmit_file_orig,this_idx,rdw_len)
    this_idx = this_idx + rdw_len
    rdw_len = c2d(Left(this_rdw,2)) - 8
    rpt = "IEBCOPY rdw("rdw_len")"
    If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    iebcopy_counter = iebcopy_counter + 1
    data_line = CharIn(xmit_file_orig,this_idx,rdw_len)
    rpt = "IEBCOPY txt("data_line")"
    If (debug_state > 2) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    this_idx = this_idx + rdw_len
    Call iebcopy_extract
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Process the step data_line and extract members.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
iebcopy_extract:
  Select
    When (iebcopy_counter = 1) Then Call decode_attributes
    When (iebcopy_counter = 2) Then Call decode_record2
    When (dir_entries = "Y")   Then Call decode_dir_batch
    Otherwise,
      Call must_be_member_char
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the dataset attributes
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
decode_attributes:
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"RECORD1   ")
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"==========")
  Parse Var data_line        /* loadlib    panels   */ ,
                             /* pds        pdse     */ ,
    pds_pdse        +4       /* 00CA6D0F   01CA6D0F */ ,
    dsorg           +2       /* 0200       0200     */ ,
    blksize         +2       /* 7FF8       6D10     */ ,
    lrecl           +2       /* 0000       0050     */ ,
    recfm           +2       /* C000       9000     */ ,
    .               +2       /* 0080       0000     */ ,
    minblksize      +2       /* 0C30       0C30     */ ,
    .               +2       /* 3030       0008     */ ,
    devtype         +1       /* 20         20       */ ,
    dasdtype        +1       /* 0F         00       */ ,
    .               +2       /* 0000       0000     */ ,
    maxblksize      +2       /* 7FF8       7FF8     */ ,
    devcapacity     +2       /* 0D0B       0100     */ ,
    cylcapacity     +2       /* 000F       0100     */ ,
    trkcapacity     +2       /* E5A2       FFFF     */ ,
    .               +2       /* 0000       0000     */ ,
    .               +2       /* 2252       0000     */ ,
    .               +2       /* 0000       0000     */ ,
    .               +2       /* 00B4       0000     */ ,
    .               +1       /* 80         00       */ ,
    used_blksize    +2       /* 7FF8       0000     */ ,
    .               +1       /* 50         00       */ ,
    .               +2       /* 0000       0000     */ ,
    .               +2       /* 0F00       0000     */ ,
    .               +4       /* 03135632   00000000 */ ,
    .               +2       /* 0000       0000     */ ,
    warn_me
  If (warn_me >< "") Then,
    Do
      rpt = "Attributes longer than I described ("warn_me")"
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  hex_pds_pdse = c2x(pds_pdse)
  dev_trk_cyl = c2d(cylcapacity)
  Select
    When (hex_pds_pdse = "00CA6D0F") Then display_pds_pdse = "PDS"
    When (hex_pds_pdse = "01CA6D0F") Then display_pds_pdse = "PDSE"
    Otherwise
      display_pds_pdse = "UNK"
  End
  rpt = "DSNTYPE="display_pds_pdse
  write_rc = LineOut(xmit_file_rpt,rpt)
  dsorg   = x2c_dsorg(c2x(dsorg))
  blksize = c2d(blksize)
  lrecl = c2d(lrecl)
  recfm   = x2c_recfm(c2x(recfm))
  minblksize = c2d(minblksize)
  maxblksize = c2d(maxblksize)
  devcapacity = c2d(devcapacity)
  cylcapacity = c2d(cylcapacity)
  trkcapacity = c2d(trkcapacity)
  dasdname = convert_dasdtype(dasdtype devcapacity)
  dcb = "DCB=(DSORG="dsorg",RECFM="recfm
  dcb = dcb",BLKSIZE="blksize",LRECL="lrecl")"
  write_rc = LineOut(xmit_file_rpt,dcb)
  rpt = dasdname "BLKSIZE" minblksize"-"maxblksize,
    trkcapacity "bytes/track" cylcapacity "trks/cyl"
  write_rc = LineOut(xmit_file_rpt,rpt)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the dataset adjustments.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
decode_record2:
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"RECORD2   ")
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"==========")
  If (display_pds_pdse = "PDS") Then,
    Do                                            /* loadlib.ieb */
      Parse Var data_line,
        control_word    +4       /* 01000000 */ ,
        reserved_1      +4       /* FF000000 */ ,
        reserved_2      +4       /* 8F0AD000 */ ,
        reserved_3      +4       /* 0479D0C8 */ ,
        reserved_4      +4       /* 58F537A0 */ ,
        reserved_5      +2       /* 0000     */ ,
        cc_beg          +2       /* 0976     */ ,
        hh_beg          +2       /*     000A */ ,
        cc_end          +2       /* 097A     */ ,
        hh_end          +2       /*     0009 */ ,
        cc_hh_ctr       +2       /* 003C     */ ,
        reserved_8      +4       /* 00000000 */ ,
        reserved_9      +4       /* 00000000 */ ,
        reserved_10     +4       /* 00000000 */ ,
        reserved_11     +4       /* 00000000 */ ,
        reserved_12     +4       /* 00000000 */ ,
        reserved_13     +4       /* 00000000 */ ,
        reserved_14     +4       /* 00000000 */ ,
        reserved_15     +4       /* 00000000 */ ,
        reserved_16     +210     /* -00-     */
    End
  If (display_pds_pdse = "PDSE") Then,
    Do                                          /* panels.xmi */
      Parse Var data_line,
        control_word    +4       /* 03000000 */ ,
        reserved_1      +4       /* FF000000 */ ,
        reserved_2      +4       /* 8F000000 */ ,
        reserved_3      +4       /* 04000000 */ ,
        reserved_4      +4       /* 0008C170 */ ,
        cc_beg          +2       /* 0000     */ ,
        hh_beg          +2       /*     0000 */ ,
        cc_hh_ctr       +4       /* 0000007E */ ,
        reserved_7      +4       /* 00FF7F00 */ ,
        reserved_8      +4       /* 0008C170 */ ,
        reserved_9      +4       /* 0000007F */ ,
        reserved_10     +4       /* 000000FD */ ,
        reserved_11     +4       /* 00FF7F00 */ ,
        reserved_12     +4       /* 0008C170 */ ,
        reserved_13     +4       /* 000000FE */ ,
        reserved_14     +4       /* 000000FF */ ,
        reserved_15     +4       /* FF020000 */ ,
        reserved_16     +210     /* -00-     */
    End

  hex_cc_beg = c2x(cc_beg)
  hex_hh_beg = c2x(hh_beg)
  dec_cc_beg = c2d(cc_beg)
  dec_hh_beg = c2d(hh_beg)
  rpt = "BEG("hex_cc_beg""hex_hh_beg")."
  If (debug_state > 1) Then,
    write_rc = LineOut(xmit_file_rpt,rpt)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================

Each batch is 276 bytes long.
+------------+------+------+------+------+------+------+--------+
+ Control    |Block |Last  |Entry |Entry |Entry |Entry | filler +
+ bytes      |length|Member|Length|  1   |...   |  n   | to 276 +
+ (10)       |(2)   |(8)   |(2)   |(var) |(var) |      | bytes  +
+------------+------+------+------+------+------+------+--------+

Each entry has the form:
+--------+-------+----+-----------------------------------+
+ Member |TTR    |Flag|                                   +
+ Name   |       |#hwd|  User Data TTRN's (halfwords)     +
+ (8)    |(2)    |(1) |                                   +
+--------+-------+----+-----------------------------------+
When Bit 0 of the flag is '1', '80'x, the member is an alias.
Bits 3-7 contain the number of user data half-words.

=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the IEBCOPY unload format directory blocks
  PDS:  Must find 'FFFFFFFFFFFFFF'x to know where the end is.
  PDSE: Knows by reaching control-byte = x'88', works like PDS, too.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
decode_dir_batch:
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"RECORD3   ")
  If (debug_state > 0) Then,
  write_rc = LineOut(xmit_file_rpt,"==========")
  data_line_len = length(data_line)
  total_batches = (data_line_len - 4) / 276
  rpt = "Number("total_batches") in data_line("data_line_len")."
  If (debug_state > 0) Then,
  wrc=Lineout(xmit_file_rpt,rpt)
  rpt = "I think there are" total_batches "directory batches in use."
  If (debug_state > 1) Then,
  wrc=Lineout(xmit_file_rpt,rpt)
  Do While data_line >< ""
    Parse Var data_line dir_ent +276 data_line
    Call decode_dir_batch_ent
  End
  Return

decode_dir_batch_ent:
  Parse Var dir_ent,
    control_byte    +1       /* 08 | 88  */ ,
    .               +3       /* 000000   */ ,
    .               +4       /* 00000000 */ ,
    .               +2       /* 0008     */ ,
    ent_len         +2       /* 0100     */ ,
    last_mbr_in_blk +8       /*          */ ,
    blk_len         +2       /*          */ ,
    dir_blk
  If (control_byte = '88'x) Then,
    Do
      dir_entries = "N"
      Return
    End
  ent_len = c2d(ent_len)
  last_mbr_in_blk = Space(e2a(last_mbr_in_blk))
  blk_len = c2d(blk_len)
  dir_len = Length(dir_blk)
  rpt = "ent("ent_len") mbr("last_mbr_in_blk")",
    "blk("blk_len") dir("dir_len")"
  rpt = "Decode dir until" last_mbr_in_blk "is reached."
  blk_idx = 1
  Do While blk_idx < dir_len
    mbr_name = Space(SubStr(dir_blk,blk_idx,8))
    If (mbr_name = 'FFFFFFFFFFFFFFFF'x) Then,
      Do
        dir_entries = "N"
        Return
      End
    mbr_name = Space(e2a(mbr_name))
    maxmbrs = maxmbrs + 1
    blk_idx = blk_idx + 8
    ttr = SubStr(dir_blk,blk_idx,3)
    dec_ttr_cc = c2d(substr(ttr,1,1))
    dec_ttr_hh = c2d(substr(ttr,2,1))
    hex_ttr_rr = c2x(substr(ttr,3,1))
    dec_ttr_cc = dec_ttr_cc + dec_cc_beg
    dec_ttr_hh = dec_ttr_hh + dec_hh_beg
    if (dec_ttr_hh > dev_trk_cyl) Then,
      do
        how_many = dec_ttr_hh % dev_trk_cyl
        dec_ttr_cc = dec_ttr_cc + how_many
        dec_ttr_hh = dec_ttr_hh - (how_many * dev_trk_cyl)
      end
    hex_ttr_cc = Right("0000"c2x(d2c(dec_ttr_cc)),4)
    hex_ttr_hh = Right("0000"c2x(d2c(dec_ttr_hh)),4)
    ttr = hex_ttr_cc
    ttr = ttr""hex_ttr_hh
    ttr = ttr""hex_ttr_rr
    blk_idx = blk_idx + 3
    info_byte = SubStr(dir_blk,blk_idx,1)
    blk_idx = blk_idx + 1
    len = c2d(bitand(info_byte,'1F'x)) * 2
    If (bitand(info_byte,'80'x) = '80'x) Then,
      Do
        ttr_alias.ttr = ttr_alias.ttr""mbr_name" "
        mbr_type = "Alias :"
      End
    Else,
      Do
        ttr_name.ttr = mbr_name
        mbr_type = "Member:"
      End
    If (len > 0) Then,
      Do
        user_char = SubStr(dir_blk,blk_idx,len)
        blk_idx = blk_idx + len
        rpt = Right("     "maxmbrs,5)
        rpt = rpt mbr_type Left(mbr_name,8) ttr e2a(user_char)
        write_rc = LineOut(xmit_file_rpt,rpt)
        ttr_char.ttr = user_char
        mbr_char.mbr_name = user_char
      End
    Else,
      Do
        rpt = Right("     "maxmbrs,5)
        rpt = rpt mbr_type Left(mbr_name,8) ttr "NO STATS"
        write_rc = LineOut(xmit_file_rpt,rpt)
        ttr_char.ttr = "NO STATS"
      End
    If (mbr_name = last_mbr_in_blk) Then,
      Do
        Return
      End
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the member data
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
must_be_member_char:
  rpt = display_pds_pdse "DATA"
  rpt = Copies("=",Length(rpt))
  Parse Var data_line,
    data_code       +1,
    .               +3,
    mbr_ttr         +5,
    segment_len     +3,
    data_char
  If (c2x(e2a(data_code)) >< "00") Then Return
  hex_ttr = c2x(mbr_ttr)
  rpt = display_pds_pdse "mbr_ttr("hex_ttr")"
  segment_len = c2d(segment_len)
  If (segment_len = 0) Then Return
  Parse Var data_char data_char +(segment_len) more_data
  this_member = ttr_name.hex_ttr
  this_byte_out = 1
  If (this_member = "") Then,
    Do
      hex_ttr = last_ttr
      this_byte_out = last_byte_out
      this_member = ttr_name.hex_ttr
    End
  user_char = ttr_char.hex_ttr
  mbr_type = "Member:"
  If (recfm = "U") Then,
    Do
      Call stats_loadlib
    End
  Else,
    Do
      Call stats_ispf
    End
  Call check_aliases
  xmit_mbr_ascii = xmit_file_xmi".$$$\"this_member".ascii"
  xmit_mbr_ebcdic = xmit_file_xmi".$$$\"this_member".ebcdic"
  Select
    When (recfm = "FB") Then,
      Do While data_char >< ""
        Parse Var data_char,
          write_char +(lrecl),
          data_char
        e2a_char = e2a(write_char)
        write_rc = LineOut(xmit_mbr_ascii,e2a_char)
        write_rc = CharOut(xmit_mbr_ebcdic,write_char)
        If (debug_state > 2) Then,
        write_rc = LineOut(xmit_file_rpt,"FB:LL("lrecl")")
      End
    When (recfm = "VB") Then,
      Do
        Parse Var data_char buffer_len +4 buffer_data
        Do While buffer_data >< ""
          Parse Var buffer_data buffer_seg +4 buffer_data
          this_buffer_len = c2d(left(buffer_seg,2)) - 4
          Parse Var buffer_data this_data +(this_buffer_len),
            buffer_data
          write_rc = LineOut(xmit_mbr_ascii,e2a(this_data))
          write_rc = CharOut(xmit_mbr_ebcdic,this_data)
        End
      End
    When (recfm = "U") Then,
      Do
        If (debug_state > 2) Then,
        write_rc = LineOut(xmit_file_rpt,"U: SL("segment_len")")
        write_rc = CharOut(xmit_mbr_ascii,e2a(data_char),this_byte_out)
        write_rc = LineOut(xmit_mbr_ebcdic,data_char)
        this_byte_out = this_byte_out + segment_len
        write_rc = CharOut(xmit_mbr_ascii,'0D0A'x,this_byte_out)
        this_byte_out = this_byte_out + 2
        last_byte_out = this_byte_out
        last_ttr = hex_ttr
        If (more_data >< "") Then,
          Do
            data_line = more_data
            Call must_be_member_char
          End
      End
    Otherwise
      Say "Unknown recfm("recfm") at this time."
  End
  write_rc = LineOut(xmit_mbr_ascii)
  write_rc = LineOut(xmit_mbr_ebcdic)
  last_ttr = hex_ttr
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Map aliases to true name
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
check_aliases:
  is_alias = "NO"
  If (ttr_alias.hex_ttr = "") Then Return
  mbr_type = "  ALIAS:"
  Do wx = 1 to Words(ttr_alias.hex_ttr)
    alias_of = Word(ttr_alias.hex_ttr,wx)
    If (alias_created.alias_of >< "") Then Leave
    rpt = "ALIAS :" alias_of " on " this_member"."
    write_rc = LineOut(xmit_file_rpt,rpt)
    xmit_mbr_alias = xmit_file_xmi".$$$\"alias_of".$$$"
    write_rc = LineOut(xmit_mbr_alias,rpt)
    write_rc = LineOut(xmit_mbr_alias)
    alias_created.alias_of = this_member
    is_alias = "YES"
    user_char = mbr_char.alias_of
    If (recfm = "U") Then,
      Do
        Call stats_loadlib
      End
    Else,
      Do
        Call stats_ispf
      End
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the ISPF based statistics
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
stats_ispf:
  If (hex_ttr = last_ttr) Then Return
  If (user_char = "NO STATS") Then,
    Do
      rpt = "No STATS:    " Left(this_member,8),
        hex_ttr
      write_rc = LineOut(xmit_file_rpt,rpt)
      Return
    End
  midblk = 1
  mbr_vv = Right("00"c2d(SubStr(user_char,midblk,1)),2)
  midblk = midblk + 1
  mbr_mm = Right("00"c2d(SubStr(user_char,midblk,1)),2)
  midblk = midblk + 1
  mbr_xx = c2x(SubStr(user_char,midblk,1))
  midblk = midblk + 1
  mbr_sc = c2x(SubStr(user_char,midblk,1))
  midblk = midblk + 1
  mbr_credt = doy2g(c2x(SubStr(user_char,midblk,4)))
  midblk = midblk + 4
  mbr_chgdt = doy2g(c2x(SubStr(user_char,midblk,4)))
  midblk = midblk + 4
  mbr_hr = c2x(SubStr(user_char,midblk,1))
  midblk = midblk + 1
  mbr_mn = c2x(SubStr(user_char,midblk,1))
  midblk = midblk + 1
  mbr_curln = c2d(SubStr(user_char,midblk,2))
  midblk = midblk + 2
  mbr_initl = c2d(SubStr(user_char,midblk,2))
  midblk = midblk + 2
  mbr_modln = c2d(SubStr(user_char,midblk,2))
  midblk = midblk + 2
  mbr_userid = e2a(SubStr(user_char,midblk,8))
  midblk = midblk + 8
  mbr_notused = e2a(SubStr(user_char,midblk,2))
  midblk = midblk + 2
  rpt = "STATS:       " Left(this_member,8),
    hex_ttr,
    mbr_credt mbr_chgdt,
    mbr_hr":"mbr_mn":"mbr_sc,
    Right("     "mbr_initl,5) Right("     "mbr_curln,5),
    Right("     "mbr_modln,5),
    mbr_vv'.'mbr_mm mbr_userid
  write_rc = LineOut(xmit_file_rpt,rpt)
  return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Decode the loadlib statistics using macro(IHAPDS)
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
stats_loadlib:
  If (hex_ttr = last_ttr) Then Return
  rpt = mbr_type Left(this_member,8) hex_ttr
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  /* START-OF-BASIC-SECTION                                          */
  pds2ttrt                 = c2x(SubStr(user_char,1,3))
  rpt = rpt "TTRT("pds2ttrt")"
  pds2zero                 = c2x(SubStr(user_char,4,1))
  pds2ttrn                 = c2x(SubStr(user_char,5,3))
  rpt = rpt "TTRN("pds2ttrn")"
  pds2nl                   = c2d(SubStr(user_char,8,1))
  rpt = rpt "NL("pds2nl")"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  pds2atr1                 =     SubStr(user_char,9,1)
  rpt = rpt "ATR1("c2x(pds2atr1)")"
    pds2rent             = BitAnd(pds2atr1,'80'x)
    If (pds2rent = '80'x) Then rpt = rpt "80=RENT"
    pds2reus             = BitAnd(pds2atr1,'40'x)
    If (pds2reus = '40'x) Then rpt = rpt "40=REUS"
    pds2ovly             = BitAnd(pds2atr1,'20'x)
    If (pds2ovly = '20'x) Then rpt = rpt "20=OVERLAY"
    pds2test             = BitAnd(pds2atr1,'10'x)
    If (pds2test = '10'x) Then rpt = rpt "10=TEST"
    pds2load             = BitAnd(pds2atr1,'08'x)
    If (pds2load = '08'x) Then rpt = rpt "08=ONLY LOADABLE"
    pds2sctr             = BitAnd(pds2atr1,'04'x)
    If (pds2sctr = '04'x) Then rpt = rpt "04=SCATTER LOAD"
    pds2exec             = BitAnd(pds2atr1,'02'x)
    If (pds2exec = '02'x) Then rpt = rpt "02=EXECUTABLE"
    pds21blk             = BitAnd(pds2atr1,'01'x)
    If (pds21blk = '01'x) Then rpt = rpt "01=1st TEXT BLOCK"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  pds2atr2                 =     SubStr(user_char,10,1)
  rpt = rpt "ATR2("c2x(pds2atr2)")"
    pds2flvl             = BitAnd(pds2atr2,'80'x)
    If (pds2flvl = '80'x) Then rpt = rpt "80=NO E LINKAGE EDITOR"
    pds2org0             = BitAnd(pds2atr2,'40'x)
    If (pds2org0 = '40'x) Then rpt = rpt "40=ORIGIN ZERO"
    pds2ep0              = BitAnd(pds2atr2,'20'x)
    If (pds2ep0  = '20'x) Then rpt = rpt "20=ENTPT ZERO"
    pds2nrld             = BitAnd(pds2atr2,'10'x)
    If (pds2nrld = '10'x) Then rpt = rpt "10=NO RLD"
    pds2nrep             = BitAnd(pds2atr2,'08'x)
    If (pds2nrep = '08'x) Then rpt = rpt "08=NOT REPROCESSABLE"
    pds2tstn             = BitAnd(pds2atr2,'04'x)
    If (pds2tstn = '04'x) Then rpt = rpt "04=TESTRAN SYMBOL CARDS"
    pds2lef              = BitAnd(pds2atr2,'02'x)
    If (pds2lef  = '02'x) Then rpt = rpt "02=Linkage Editor F"
    pds2refr             = BitAnd(pds2atr2,'01'x)
    If (pds2refr = '01'x) Then rpt = rpt "01=REFRESHABLE"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  pds2stor                 = c2x(SubStr(user_char,11,3))
  rpt = rpt "STOR("pds2stor")"
  pds2ftbl                 = c2x(SubStr(user_char,14,2))
  rpt = rpt "1ST BLK LEN("pds2ftbl")"
  pds2epa                  = c2x(SubStr(user_char,16,3))
  rpt = rpt "ENTPT("pds2epa")"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  pds2ftb1                 =     SubStr(user_char,19,1)
  rpt = rpt "FTB1("c2x(pds2ftb1)")"
    pdsaosle             = BitAnd(pds2ftb1,'80'x)
    If (pdsaosle = '80'x) Then rpt = rpt "80=AOS Linkage Editor"
    pds2big              = BitAnd(pds2ftb1,'40'x)
    If (pds2big  = '40'x) Then rpt = rpt "40=LPO SECTION Exists"
    pds2paga             = BitAnd(pds2ftb1,'20'x)
    If (pds2paga = '20'x) Then rpt = rpt "20=PAGE Alignment"
    pds2ssi              = BitAnd(pds2ftb1,'10'x)
    If (pds2ssi  = '10'x) Then rpt = rpt "10=SSI SECTION Exists"
    pdsapflg             = BitAnd(pds2ftb1,'08'x)
    If (pdsapflg = '08'x) Then rpt = rpt "08=APF SECTION Exists"
    pds2pgmo             = BitAnd(pds2ftb1,'04'x)
    If (pds2pgmo = '04'x) Then rpt = rpt "04=PDS2FTB3 VALID"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
  pds2ftb2                 =     SubStr(user_char,20,1)
  rpt = rpt "FTB2("c2x(pds2ftb2)")"
    pds2altp             = BitAnd(pds2ftb2,'80'x)
    If (pds2altp = '80'x) Then rpt = rpt "80=Binder Primary Name"
    pdslrmod             = BitAnd(pds2ftb2,'10'x)
    If (pdslrmod = '10'x) Then rpt = rpt "RMODE(ANY)"
    Else                       rpt = rpt "RMODE(24)"
    pdsaamod             = BitAnd(pds2ftb2,'0C'x)
    rpt = rpt c2x(pdsaamod)"=ALIAS Address AMODE("
    If (pdsaamod = '01'x) Then rpt = rpt"64"
    If (pdsaamod = '08'x) Then rpt = rpt"31"
    If (pdsaamod = '00'x) Then rpt = rpt"24"
    If (pdsaamod = '0C'x) Then rpt = rpt"ANY"
    rpt = rpt")"
      /*
*                             B'00' = AMODE 24
*                             B'10' = AMODE 31
*                             B'11' = AMODE ANY
*                             B'01' = AMODE 64
*/
    pdsmamod             = BitAnd(pds2ftb2,'03'x)
    rpt = rpt c2x(pdsmamod)"=Member ENTPT AMODE("
    If (pdsmamod = '03'x) Then rpt = rpt"ANY"
    If (pdsmamod = '02'x) Then rpt = rpt"31"
    If (pdsmamod = '01'x) Then rpt = rpt"64"
    If (pdsmamod = '00'x) Then rpt = rpt"24"
    rpt = rpt")"
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = "    "
      /*
*                             B'00' = AMODE 24
*                             B'10' = AMODE 31
*                             B'11' = AMODE ANY
*                             B'01' = AMODE 64
*/
  If (pds2pgmo = '04'x) Then,
    Do
      rpt = rpt "PGO flag #3"
      pds2ftb3             =     SubStr(user_char,21,1)
        pds2nmig         = BitAnd(pds2ftb3,'80'x)
        If (pds2mnig = '80'x) Then rpt = rpt "PGO >< LMOD"
        pds2prim         = BitAnd(pds2ftb3,'40'x)
        If (pds2prim = '40'x) Then rpt = rpt "FETCHOPT PRIME"
        pds2pack         = BitAnd(pds2ftb3,'20'x)
        If (pds2pack = '20'x) Then rpt = rpt "FETCHOPT PACK"
    End
  Else,
    Do
      pds2rlds             = c2d(SubStr(user_char,21,1))
      rpt = rpt "#RLD("pds2rlds")"
    End
  If (debug_state > 1) Then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  user_opt_loc = 22
  /* END-OF-BASIC-SECTION                                            */
  /* START-OF-SCATTER-LOAD-SECTION OPTIONAL                          */
  If (pds2sctr = '01'x) Then,
    Do
      rpt = "    SCATTER LOAD"
      pds2slsz             = c2d(SubStr(user_char,user_opt_loc,2))
      rpt = rpt "List size("pds2slsz")"
      user_opt_loc = user_opl_loc + 2
      pds2ttsz             = c2d(SubStr(user_char,user_opt_loc,2))
      rpt = rpt "XLAT size("pds2ttsz")"
      user_opt_loc = user_opl_loc + 2
      pds2esdt             =     SubStr(user_char,user_opt_loc,2)
      rpt = rpt "1st Block ESDID("pds2esdt")"
      user_opt_loc = user_opl_loc + 2
      pds2esdc              =    SubStr(user_char,user_opt_loc,2)
      rpt = rpt "ENTPT Scatter ESDID("pds2esdt")"
      user_opt_loc = user_opl_loc + 2
      If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Else,
    Do
      pds2slsz = 0
      pds2ttsz = "0000"
      pds2esdt = "  "
      pds2esdc = "  "
    End
  /* END-OF-SCATTER-LOAD-SECTION                                     */
  /* START-OF-ALIAS-SECTION                                          */
  If (is_alias = "YES") Then,
    Do
      rpt = "     Alias SECTION"
      pds2epm              = c2x(SubStr(user_char,user_opt_loc,3))
      rpt = rpt "Member ENTPT("pds2epm")"
      user_opt_loc = user_opt_loc + 3
      pds2mnm              =    SubStr(user_char,user_opt_loc,8)
      rpt = rpt "Member name("e2a(pds2mnm)")"
      user_opt_loc = user_opt_loc + 8
      If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Else,
    Do
      pds2epm = "000000"
      pds2mnm = "        "
    End
  /* END-OF-ALIAS-SECTION                                            */
  /* START-OF-SSI-SECTION                                            */
  If (pds2ssi = '10'x) Then,
    Do
      rpt = "     SSI: loc("user_opt_loc")"
      user_opt = user_opt_loc // 2
      If (user_opt > 0) Then,
        Do
          user_opt_loc = user_opt_loc +user_opt
          rpt = rpt "HWBDY("user_opt_loc")"
        End
      pdschlvl             = c2x(SubStr(user_char,user_opt_loc,1))
      rpt = rpt "Change level("pdschlvl")"
      user_opt_loc = user_opt_loc + 1
      pdsssifb             =     SubStr(user_char,user_opt_loc,1)
      rpt = rpt "SSI FLAG("c2x(pdsssifb)")="
      user_opt_loc = user_opt_loc + 1
        pdsforce         = BitAnd(pdsssifb,'40'x)
        If (pdsforce = '40'x) Then rpt = rpt"FORCE/"
        pdsusrch         = BitAnd(pdsssifb,'20'x)
        If (pdsusrch = '20'x) Then rpt = rpt"USER CHANGE/"
        pdsemfix         = BitAnd(pdsssifb,'10'x)
        If (pdsusrch = '10'x) Then rpt = rpt"IBM Emergency/"
        pdsdepch         = BitAnd(pdsssifb,'08'x)
        If (pdsusrch = '08'x) Then rpt = rpt"DEPENDENCY/"
        pdssysgn         = BitAnd(pdsssifb,'03'x)
          pdsnosgn       = BitAnd(pdssysgn,'00'x)
          If (pdssysgn = '00'x) Then rpt = rpt "NO SYSGEN"
          pdsptsgn       = BitAnd(pdssysgn,'04'x)
          If (pdsptsgn = '04'x) Then rpt = rpt "PARTIAL SYSGEN"
          pdscmsgn       = BitAnd(pdssysgn,'02'x)
          If (pdscmsgn = '02'x) Then rpt = rpt "COMPLETE SYSGEN"
          pdsibmmb         = BitAnd(pdsssifb,'01'x)
          If (pdsibmmb = '01'x) Then rpt = rpt "IBM SUPPLIED MEMBER"
      user_opt_loc = user_opt_loc - 1
      pdsmbrsn           = c2x(SubStr(user_char,user_opt_loc,4))
      rpt = rpt "SN("pdsmbrsn")"
      user_opt_loc = user_opt_loc + 4
      If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Else,
    Do
      pdschlvl = '00'x
      pdsssifb = '00'x
        pdsforce         = BitAnd(pdsssifb,'40'x)
        pdsusrch         = BitAnd(pdsssifb,'20'x)
        pdsemfix         = BitAnd(pdsssifb,'10'x)
        pdsdepch         = BitAnd(pdsssifb,'08'x)
        pdssysgn         = BitAnd(pdsssifb,'03'x)
          pdsnosgn       = BitAnd(pdssysgn,'00'x)
          pdsptsgn       = BitAnd(pdssysgn,'10'x)
          pdscmsgn       = BitAnd(pdssysgn,'01'x)
        pdsibmmb         = BitAnd(pdsssifb,'01'x)
      pdsmbrsn = "  "
    End
  /* END-OF-SSI-SECTION                                              */
  /* START-OF-APF-SECTION                                            */
  If (pdsapflg = '08'x) Then,
    Do
      rpt = "     APF:"
      pdsapfct             = c2x(SubStr(user_char,user_opt_loc,1))
      rpt = rpt "Len("pdsapfct")"
      user_opt_loc = user_opt_loc + 1
      pdsapfac             = c2x(SubStr(user_char,user_opt_loc,1))
      rpt = rpt "AC("pdsapfac")"
      user_opt_loc = user_opt_loc + 1
      If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
  rpt = rpt "AC("pdsapfac")"
    End
  Else,
    Do
      pdsapfct = 0
      pdsapfac = " "
    End
  /* END-OF-APF-SECTION                                              */
  /* START-OF-LPO-SECTION                                            */
  If (pds2big = '40'x) Then,
    Do
      rpt = "     LPO:"
      pds2lpol         = c2d(SubStr(user_char,user_opt_loc,1))
      rpt = rpt "Len("pds2lpol")"
      user_opt_loc = user_opt_loc + 1
      pds2vstr         = c2x(SubStr(user_char,user_opt_loc,4))
      rpt = rpt "Virtual Storage("pds2vstr")"
      user_opt_loc = user_opt_loc + 4
      pds2mepa         = c2x(SubStr(user_char,user_opt_loc,4))
      rpt = rpt "Main EPA offset("pds2mepa")"
      user_opt_loc = user_opt_loc + 4
      pds2aepa         = c2x(SubStr(user_char,user_opt_loc,4))
      rpt = rpt "Alias EPA offset("pds2aepa")"
      user_opt_loc = user_opt_loc + 4
      If (debug_state > 1) Then,
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Else,
    Do
      pds2lpol = 0
      pds2vstr = 0
      pds2mepa = "00000000"
      pds2aepa = "00000000"
    End
  /* END-OF-LPO-SECTION                                              */
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
  back_wards = Reverse(source_uc_exec_name)
  Parse Var back_wards ucname "\" path_drive
  ucname = Reverse(ucname)
  Parse Var ucname ucname "." extension
  dashname = Left(ucname""Copies("-",12),12)
  Say "Syntax:"
  Say ">>--"dashname"+file_name+-+---------+----<<"
  Say "                            +-DEBUG=#-+"
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
  Say "I first wrote a REXX form of RECEIVE for the PC"
  Say "under IBM PC DOS 7.1 REXX. It processed the transmit file"
  Say "and unloaded PDS members. I broke KETRECV into two parts,"
  Say "an INMCOPY extractor and an IEBCOPY unload extractor, after"
  Say "the discussion of downloading an IEBCOPY unload format"
  Say "dataset finally settled on how it can be downloaded to a PC"
  Say "and then uploaded again. Since I was already handling the"
  Say "IEBCOPY Internal Variaable Spanned format dataset, I thought"
  Say "why not break the code out. One day I need to test this on"
  Say "a real dataset and not the embedded in a transmit file copy."
  Say ""
  Say "I produce both an ASCII and EBCDIC version of members. This"
  Say "allows me to extract a PDS member that may be the output of"
  Say "a transmit command and then RECEIVE it."
  Say ""
  Say '"Kenneth Tomiak"<CBT_Ken@KTomiak.biz>'
  Say ""
  Say Copies("-",79)
  Say ""
  Say "Press [ENTER] to continue"
  Say ""
  Pull any_key_lol

  Say "                                                               "
  Say "//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  Say "//* First create the unloaded dataset.                         "
  Say "//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  Say "//BACKUP  EXEC PGM=IEBCOPY                                     "
  Say "//SYSPRINT DD  SYSOUT=*                                        "
  Say "//SYSUT1   DD  DISP=(SHR),DSN=&SYSUID..PDS.CNTL                "
  Say "//SYSUT2   DD  DISP=(NEW,CATLG),DSN=&SYSUID..PDSCNTL.BACKUP,   "
  Say "//             UNIT=SYSALLDA,SPACE=(TRK,(20,100),RLSE)         "
  Say "//* =>Default  DCB=(DSORG=PS,RECFM=VB,BLKSIZE=32740,LRECL=32736)"
  Say "//SYSUT3   DD  DISP=(NEW,DELETE),DSN=&&TEMP1,                  "
  Say "//             UNIT=SYSALLDA,                                  "
  Say "//             SPACE=(80,(60,45))                              "
  Say "//SYSIN    DD  *                                               "
  Say "CPYLABEL COPY INDD=SYSUT1,OUTDD=SYSUT2                         "
  Say "/*                                                             "
  Say "//*                                                            "
  Say "//                                                             "
  Say ""
  Say "Press [ENTER] to continue"
  Say ""
  Pull any_key_lol
  Say "                                                               "
  Say ":rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  Say ":rem Then use FTP on your PC to download it.                   "
  Say ":rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  Say "ftp server.site.tld                                            "
  Say "your_userid                                                    "
  Say "your_password                                                  "
  Say "bin                                                            "
  Say "quote stru r                                                   "
  Say "get PDSCNTL.BACKUP                                             "
  Say "quit                                                           "
  Say ""
  Say "Press [ENTER] to continue"
  Say ""
  Pull any_key_lol
  Say "                                                               "
  Say "@echo Now run oorexx" ucname parse_all_my_arguments
  Say "                                                               "

  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
__DATA__
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

