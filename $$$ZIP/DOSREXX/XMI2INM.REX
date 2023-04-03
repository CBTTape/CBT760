rexx_XMI2INM:  /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "01.02"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

=======================================================================

  Dataset: REXX(XMI2INM)
  Author:  KTomiak
  Contact: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
  Syntax:  XMI2INM (filename) (DEBUG=#)
           filename - [drive:][path\]filename
           ".xmi" and beyond will get stripped off.
           DEBUG=# - # is 0 - 5 to control level of debugging output.
  Purpose: Read the output of a TRANSMIT command and extract the
           INMCOPY version of the original dataset. This could be
           the original sequential dataset or an internal IEBCOPY
           unload format.

  History of Modifications
  ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  01.02 Standardizing Rexx_Initialize routine
  20070709 KTomiak  01.01 This is the first half of KETRECV.rex in case
                          all you want to do is get the INMCOPY of
                          a dataset.
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
rexx_Main_XMI2INM:
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

  file_size = Chars(xmit_file_in)
  If (file_size > 0) Then,
    Do
      xmit_file_xmi = xmit_file_in
    End
  Else,
    Do
      Say "Let me try adding .xmi for you."
      Parse Var xmit_file_in xmit_file_xmi "." .
      xmit_file_xmi = xmit_file_xmi".xmi"
      file_size = Chars(xmit_file_xmi)
      If (file_size = 0) Then,
        Do
          Say "Let me try adding .xmit for you."
          Parse Var xmit_file_in xmit_file_xmi "." .
          xmit_file_xmi = xmit_file_xmi".xmit"
          file_size = Chars(xmit_file_xmi)
          If (file_size = 0) Then,
            Do
              Say xmit_file_in "appears to be empty",
                "or nonexistent, file size("file_size")."
              return_code = 16
              Return return_code
            End
        End
    End

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
  rpt_open = 1

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
  crfile_number = 0
  cr_last_number = 0
  control_counter. = 0
  inm_idx = 1
  not_sure = 0
  alias_created. = ""
  output_progress = 0
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we loop through our input.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Process:
  char_idx = 1
  segment_counter = 0
  buffer_data_ebcdic = ""
  rpt = "Processing" xmit_file_xmi"."
  say rpt
  If (debug_state > 0) then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  Do Forever
    If (char_idx > file_size) Then Leave
    segment_counter = segment_counter + 1
    segment_len = c2d(CharIn(xmit_file_xmi,char_idx,1)) - 2
    char_idx = char_idx + 1
    segment_desc_flag = CharIn(xmit_file_xmi,char_idx,1)
    char_idx = char_idx + 1
    If (debug_state > 3) then,
      Do
        rpt = ">>segctr("segment_counter")",
          "LOC("char_idx")",
          "len("segment_len")",
          "segment_type("c2x(segment_desc_flag)")"
        write_rc = LineOut(xmit_file_rpt,rpt)
      End
    If (segment_len < 1) Then,
      Do
        rpt = "CharIn is about to fail, seglen<1 LOC("char_idx")."
        write_rc = LineOut(xmit_file_rpt,rpt)
        Iterate
      End
    segment_char = CharIn(xmit_file_xmi,char_idx,segment_len)
    Select
      When (BitAnd(segment_desc_flag,'E0'x) = 'E0'x) Then,
        Do
          buffer_data_ebcdic = segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
          Call process_control_record
        End
      When (BitAnd(segment_desc_flag,'C0'x) = 'C0'x) Then,
        Do
          buffer_data_ebcdic = segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
          Call process_char_record
        End
      When (BitAnd(segment_desc_flag,'A0'x) = 'A0'x) Then,
        Do
          buffer_data_ebcdic = segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
        End
      When (BitAnd(segment_desc_flag,'80'x) = '80'x) Then,
        Do
          buffer_data_ebcdic = segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
        End
      When (BitAnd(segment_desc_flag,'60'x) = '60'x) Then,
        Do
          buffer_data_ebcdic = buffer_data_ebcdic""segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
          Call process_control_record
        End
      When (BitAnd(segment_desc_flag,'40'x) = '40'x) Then,
        Do
          buffer_data_ebcdic = buffer_data_ebcdic""segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
          Call process_char_record
        End
      When (BitAnd(segment_desc_flag,'20'x) = '20'x) Then,
        Do
          buffer_data_ebcdic = buffer_data_ebcdic""segment_char
          buffer_data_ascii = e2a(buffer_data_ebcdic)
        End
      When (BitAnd(segment_desc_flag,'10'x) = '10'x) Then,
        Do
          Say "This is record number of next record. Huh?"
        End
      When (BitAnd(segment_desc_flag,'0F'x) = '0F'x) Then,
        Do
          Say "This is reserved. Whole lot of help that is to me."
        End
      Otherwise
        buffer_data_ebcdic = buffer_data_ebcdic""segment_char
        buffer_data_ascii = e2a(buffer_data_ebcdic)
    End
    char_idx = char_idx + segment_len
  End
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Process INMR* records.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
process_control_record:
  If (output_progress > 0) Then Call finish_last_file
  control_type = SubStr(buffer_data_ascii,1,6)
  next_byte = 7
  control_counter.control_type = control_counter.control_type + 1
  rpt = "Entire" control_type "Len("Length(buffer_data_ebcdic)")."
  write_rc = LineOut(xmit_file_rpt,rpt)
  If (debug_state > 3) then,
    Do
      rpt = "EBCDIC("buffer_data_ebcdic")"
      write_rc = LineOut(xmit_file_rpt,rpt)
      rpt = "ASCII ("e2a(buffer_data_ebcdic)")"
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Select
    When (control_type = "INMR01") Then,
      Do
        control_key = "1_"crfile_number"_"control_counter.control_type
        rpt = "     CR # =" crfile_number control_counter.control_type,
          "control_key("control_key")"
        If (debug_state > 0) then,
        write_rc = LineOut(xmit_file_rpt,rpt)
        Call parse_subtypes
      End
    When (control_type = "INMR02") Then,
      Do
        crfile_number = c2d(SubStr(buffer_data_ebcdic,next_byte,4))
        If (crfile_number >< cr_last_number) Then,
          Do
            control_counter.control_type = 1
          End
        control_key = "2_"crfile_number"_"control_counter.control_type
        cr_last_number = crfile_number
        rpt = "     CR # =" crfile_number control_counter.control_type,
          "control_key("control_key")"
        If (debug_state > 1) then,
        write_rc = LineOut(xmit_file_rpt,rpt)
        max_r02.crfile_number = control_counter.control_type
        next_byte = next_byte + 4
        Call parse_subtypes
      End
    When (control_type = "INMR03") Then,
      Do
        inmr03_counter = control_counter.control_type
        this_r02 = max_r02.inmr03_counter
        control_key = "3_"inmr03_counter"_"this_r02
        rpt = " 03  CR # =" this_r02 control_counter.control_type,
          "control_key("control_key") Begin"
        If (debug_state > 1) then,
        write_rc = LineOut(xmit_file_rpt,rpt)

        xmit_ascii_nbr = xmit_file_in".$$$."this_r02"ascii"
        xmit_ebcdic_nbr = xmit_file_in".$$$."this_r02"ebcdic"

        Call parse_subtypes

        output_progress = 1
        inm_idx = 1
        temp_key = "2_"inmr03_counter"_"this_r02
      End
    When (control_type = "INMR04") Then,
      Do
        rpt = "     CR # =" crfile_number control_counter.control_type,
          "control_key("control_key")"
        If (debug_state > 1) then,
        write_rc = LineOut(xmit_file_rpt,rpt)
        Call parse_subtypes
      End
    When (control_type = "INMR06") Then,
      Do
        rpt = " E-O-F"
        write_rc = LineOut(xmit_file_rpt,rpt)
        segment_len = file_size
      End
    When (control_type = "INMR07") Then,
      Do
        rpt = "     CR # =" crfile_number control_counter.control_type,
          "control_key("control_key")"
        If (debug_state > 1) then,
        write_rc = LineOut(xmit_file_rpt,rpt)
        Call parse_subtypes
      End
    Otherwise
      Say "Unknown control record type" control_type"."
      rpt = "     CR # =" crfile_number control_counter.control_type
      write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Process member data record.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
process_char_record:
  rpt = "  data  # =" temp_key,
    "RECFM("txtunit_INMRECFM.temp_key")"
  If (debug_state > 2) then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  If (debug_state > 3) then,
    Do
      rpt = "EBDIC("buffer_data_ebcdic")"
      write_rc = LineOut(xmit_file_rpt,rpt)
      rpt = "ASCII "buffer_data_ascii")"
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  Select
    When (pos("+noRDWVS",txtunit_INMRECFM.temp_key) > 0) Then,
      Do
        Call vs_add_rdw
      End
    When (pos("VB",txtunit_INMRECFM.temp_key) > 0) Then,
      Do
        Call vb_add_bdw_rdw
      End
    When (pos("SVBS",txtunit_INMRECFM.temp_key) > 0) Then,
      Do
        Call vb_add_bdw_rdw
      End
    When (pos("FB",txtunit_INMRECFM.temp_key) > 0) Then,
      Do
        write_rc = LineOut(xmit_ebcdic_nbr,buffer_data_ebcdic)
        write_rc = LineOut(xmit_ascii_nbr,buffer_data_ascii)
      End
    Otherwise
      write_rc = CharOut(xmit_ebcdic_nbr,buffer_data_ebcdic,inm_idx)
      write_rc = CharOut(xmit_ascii_nbr,buffer_data_ascii,inm_idx)
  End
  inm_idx = inm_idx + Length(buffer_data_ascii)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Add record descriptor word
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
vs_add_rdw:
  bdw_char_len = Length(buffer_data_ebcdic)
  bdw_char_len = d2c(bdw_char_len + 4)
  bdw_blk = Right('0000'x""bdw_char_len,2)'0000'x
  buffer_data_out = bdw_blk""buffer_data_ebcdic
  write_rc = CharOut(xmit_ebcdic_nbr,buffer_data_out,inm_idx)
  buffer_data_out = e2a(rdw_blk)""buffer_data_ascii
  write_rc = CharOut(xmit_ascii_nbr,buffer_data_out,inm_idx)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Add block descriptor word and record descriptor word
  On a PC I am okay with doing one record per block.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
vb_add_bdw_rdw:
  sdw_char_len = Length(buffer_data_ebcdic)
  rdw_char_len = d2c(sdw_char_len + 4)
  rdw_blk = Right('0000'x""rdw_char_len,2)'0000'x
  bdw_char_len = d2c(sdw_char_len + 8)
  bdw_blk = Right('0000'x""bdw_char_len,2)'0000'x
  write_rc = LineOut(xmit_ebcdic_nbr,buffer_data_ebcdic)
  bdw_blk = Right('0000'x""bdw_char_len,2)'0000'x
  write_rc = LineOut(xmit_ascii_nbr,buffer_data_ascii)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Add block descriptor word and record descriptor word
  On a PC I am okay with doing one entire record per block.
  Otherwise I have to segment records to fit in a smaller block.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
vs_add_bdw_rdw:
  Call vb_add_bdw_rdw
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  control records are made up of text units:
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_subtypes:
  Do While next_byte < Length(buffer_data_ebcdic)
    txtunit_key = c2x(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_qty = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    Select
      When txtunit_key = '0001' Then Call parse_INMDDNAM
      When txtunit_key = '0002' Then Call parse_INMDSNAM
      When txtunit_key = '0003' Then Call parse_INMMEMBR
      When txtunit_key = '000B' Then Call parse_INMSECND
      When txtunit_key = '000C' Then Call parse_INMDIR
      When txtunit_key = '0022' Then Call parse_INMEXPDT
      When txtunit_key = '0028' Then Call parse_INMTERM
      When txtunit_key = '0030' Then Call parse_INMBLKSZ
      When txtunit_key = '003C' Then Call parse_INMDSORG
      When txtunit_key = '0042' Then Call parse_INMLRECL
      When txtunit_key = '0049' Then Call parse_INMRECFM
      When txtunit_key = '1001' Then Call parse_INMTNODE
      When txtunit_key = '1002' Then Call parse_INMTUID
      When txtunit_key = '1011' Then Call parse_INMFNODE
      When txtunit_key = '1012' Then Call parse_INMFUID
      When txtunit_key = '1020' Then Call parse_INMLREF
      When txtunit_key = '1021' Then Call parse_INMLCHG
      When txtunit_key = '1022' Then Call parse_INMCREAT
      When txtunit_key = '1023' Then Call parse_INMFVERS
      When txtunit_key = '1024' Then Call parse_INMFTIME
      When txtunit_key = '1025' Then Call parse_INMTTIME
      When txtunit_key = '1026' Then Call parse_INMFACK
      When txtunit_key = '1027' Then Call parse_INMERRCD
      When txtunit_key = '1028' Then Call parse_INMUTILN
      When txtunit_key = '1029' Then Call parse_INMUSERP
      When txtunit_key = '102A' Then Call parse_INMRECCT
      When txtunit_key = '102C' Then Call parse_INMSIZE
      When txtunit_key = '102D' Then Call parse_INMFFM
      When txtunit_key = '102F' Then Call parse_INMNUMF
      When txtunit_key = '8012' Then Call parse_INMTYPE
      Otherwise,
        Do
          Say "Trouble" txtunit_key "SG("segment_counter")"
          Say SubStr(buffer_data_ascii,next_byte,20)
          exit 16
        End
    End
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  DDNAME
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMDDNAM:
  rpt = "     0001 INMDDNAM:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMDDNAM.control_key = ,
      txtunit_INMDDNAM.control_key""txtunit_char" "
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Dataset name
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMDSNAM:
  rpt = "     0002 INMDSNAM:"
  full_dsname = ""
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    next_byte = next_byte + txtunit_len
    full_dsname = full_dsname""txtunit_char"."
  End
  full_dsname = strip(full_dsname,"B",".")
    txtunit_INMDSNAM.control_key = ,
      txtunit_INMDSNAM.control_key""full_dsname" "
  rpt = rpt full_dsname
  write_rc = LineOut(xmit_file_rpt,rpt)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Select member names
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMMEMBR:
  rpt = "     0002 INMMEMBR:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMMEMBR.control_key = ,
      txtunit_INMMEMBR.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Secondary space
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMSECND:
  rpt = "     000B INMSECND:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMSECND.control_key = ,
      txtunit_INMSECND.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Number of directory blocks for PDS
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMDIR:
  rpt = "     000C INMDIR:  "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMDIR.control_key = ,
      txtunit_INMDIR.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Expiration date
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMEXPDT:
  rpt = "     0022 INMEXPDT:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMEXPDT.control_key = ,
      txtunit_INMEXPDT.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  ?
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMTERM:
  rpt = "     0028 INMTERM: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_INMTERM.control_key = ,
      txtunit_INMTERM.control_key"Y"
    rpt = "            ZERO?  "txtunit_len
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Block size
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMBLKSZ:
  rpt = "     0030 INMBLKSZ:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMBLKSZ.control_key = ,
      txtunit_INMBLKSZ.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Dataset organization
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMDSORG:
  rpt = "     003C INMDSORG:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2x(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    next_byte = next_byte + txtunit_len
    dsorg   = x2c_dsorg(txtunit_char)
    txtunit_INMDSORG.control_key = ,
      txtunit_INMDSORG.control_key""dsorg
    rpt = rpt txtunit_char dsorg
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

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
  logical record length
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMLRECL:
  rpt = "     0042 INMLRECL:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMLRECL.control_key = ,
      txtunit_INMLRECL.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  record format
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMRECFM:
  rpt = "     0049 INMRECFM:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2x(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    next_byte = next_byte + txtunit_len
    recfm = x2c_recfm(txtunit_char)
    txtunit_INMRECFM.control_key = ,
      txtunit_INMRECFM.control_key""recfm
    rpt = rpt txtunit_char recfm
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

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
  to node
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMTNODE:
  rpt = "     1001 INMTNODE:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMTNODE.control_key = ,
      txtunit_INMTNODE.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  to userid
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMTUID:
  rpt = "     1002 INMTUID: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMTUID.control_key = ,
      txtunit_INMTUID.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  from node
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFNODE:
  rpt = "     1011 INMFNODE:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMFNODE.control_key = ,
      txtunit_INMFNODE.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  from userid
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFUID:
  rpt = "     1012 INMFUID: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMFUID.control_key = ,
      txtunit_INMFUID.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  last reference date
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMLREF:
  rpt = "     1020 INMLREF: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    next_byte = next_byte + txtunit_len
    formatted_date = convert_date(txtunit_char)
    txtunit_INMLREF.control_key = ,
      txtunit_INMLREF.control_key""formatted_date
    rpt = rpt txtunit_char formatted_date
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  last change date
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMLCHG:
  rpt = "     1021 INMLCHG: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    next_byte = next_byte + txtunit_len
    formatted_date = convert_date(txtunit_char)
    txtunit_INMLCHG.control_key = ,
      txtunit_INMLCHG.control_key""formatted_date
    rpt = rpt txtunit_char formatted_date
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  creation date
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMCREAT:
  rpt = "     1022 INMCREAT:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMCREAT.control_key = ,
      txtunit_INMCREAT.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  version
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFVERS:
  rpt = "     1023 INMFVERS:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMFVERS.control_key = ,
      txtunit_INMFVERS.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  modified time
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFTIME:
  rpt = "     1024 INMFTIME:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    next_byte = next_byte + txtunit_len
    formatted_date = convert_date(txtunit_char)
    txtunit_INMFTIME.control_key = ,
      txtunit_INMFTIME.control_key""formatted_date
    rpt = rpt txtunit_char formatted_date
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  transmit time
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMTTIME:
  rpt = "     1025 INMTTIME:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    next_byte = next_byte + txtunit_len
    formatted_date = convert_date(txtunit_char)
    txtunit_INMTTIME.control_key = ,
      txtunit_INMTTIME.control_key""formatted_date
    rpt = rpt txtunit_char formatted_date
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  acknowledgement
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFACK:
  rpt = "     1026 INMFACK: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMFACK.control_key = ,
      txtunit_INMFACK.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  error return code
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMERRCD:
  rpt = "     1027 INMERRCD:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMERRCD.control_key = ,
      txtunit_INMERRCD.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  utility program name
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMUTILN:
  rpt = "     1028 INMUTILN:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMUTILN.control_key = ,
      txtunit_INMUTILN.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  user parameters passed to exits
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMUSERP:
  rpt = "     1029 INMUSERP:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMUSERP.control_key = ,
      txtunit_INMUSERP.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  record count
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMRECCT:
  rpt = "     102A INMRECCT:"
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMRECCT.control_key = ,
      txtunit_INMRECCT.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  file size
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMSIZE:
  rpt = "     102C INMSIZE: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    txtunit_INMSIZE.control_key = ,
      txtunit_INMSIZE.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  cms file mode
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMFFM:
  rpt = "     102D INMFFM:  "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = SubStr(buffer_data_ascii,next_byte,txtunit_len)
    txtunit_INMFFM.control_key = ,
      txtunit_INMFFM.control_key""txtunit_char
    next_byte = next_byte + txtunit_len
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  number of files
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMNUMF:
  rpt = "     102F INMNUMF: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2d(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    next_byte = next_byte + txtunit_len
    txtunit_INMNUMF.control_key = ,
      txtunit_INMNUMF.control_key""txtunit_char
    rpt = rpt txtunit_char
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  type of data set
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
parse_INMTYPE:
  rpt = "     8012 INMTYPE: "
  Do txx = 1 to txtunit_qty
    txtunit_len = c2d(SubStr(buffer_data_ebcdic,next_byte,2))
    next_byte = next_byte + 2
    txtunit_char = c2x(SubStr(buffer_data_ebcdic,next_byte,txtunit_len))
    next_byte = next_byte + txtunit_len
    dstype = convert_type(txtunit_char)
    txtunit_INMTYPE.control_key = ,
      txtunit_INMTYPE.control_key""dstype
    rpt = rpt txtunit_char dstype
    write_rc = LineOut(xmit_file_rpt,rpt)
  End
  Return

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
  If (file_size = 0) Then Return 12
  rpt = " 03 CR # = temp_key("temp_key") Finish"
  If (debug_state > 1) then,
  write_rc = LineOut(xmit_file_rpt,rpt)
  write_rc = LineOut(xmit_ebcdic_nbr)
  write_rc = LineOut(xmit_ascii_nbr)
  output_progress = 0
  Select
    When (txtunit_INMDSNAM.temp_key >< "") Then,
      Do
        xmit_file_orig = Strip(txtunit_INMDSNAM.temp_key,"B"," ")
      End
    When (this_r02 = 1) Then,
      Do
        xmit_file_orig = xmit_file_in".$$$.MSG"
      End
    When (txtunit_INMUTILN.temp_key = "IEBCOPY") Then,
      Do
        xmit_file_orig = xmit_file_in".$$$.IEBCOPY"
      End
    When (txtunit_INMUTILN.temp_key = "INMCOPY") Then,
      Do
        xmit_file_orig = xmit_file_in".$$$.INMCOPY"
      End
    Otherwise
      not_sure = not_sure + 1
      xmit_file_orig = xmit_file_in".$$$."not_sure
      rpt = "Not sure what needs to be done with this," ,
        xmit_file_orig"."
      write_rc = LineOut(xmit_file_rpt,rpt)
  End
  "Rename" xmit_ascii_nbr xmit_file_orig".ascii"
  dos_cmd_rc = rc
  If (dos_cmd_rc >< 0) Then,
    Do
      rpt = "Rename" xmit_ascii_nbr,
        "to" xmit_file_orig".ascii" "RC("dos_cmd_rc")."
      write_rc = LineOut(xmit_file_rpt,rpt)
    End
  If (Right(xmit_file_orig,3) = "MSG") Then,
    "notepad" xmit_file_orig".ascii"
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
  ucname = Left(ucname""Copies("-",12),12)
  Say "Syntax:"
  Say ">>--"ucname"+file_name+-+---------+----<<"
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
  Say "under IBM PC DOS 7.1 REXX. It handled sequential and PDS"
  Say "non-LOADLIB TRANSMIT output for several years. It failed one"
  Say "day and I just left it smoldering. Fast forward to 2007 and"
  Say "the flames started flickering. Resurrected, corrected, and"
  Say "improved," source_uc_exec_name "overcomes the limitations"
  Say "and annoyances of XMITMGR and RECV390. Introducing new"
  Say "limitations and annoyances. Feel free to let me know what"
  Say "bothers you about" source_uc_exec_name", not already listed"
  Say "in the Wish List."
  Say ""
  Say "I produce both an ASCII and EBCDIC version of members. This"
  Say "allows me to extract a PDS member that may be the output of"
  Say "a transmit command and then RECEIVE it."
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

