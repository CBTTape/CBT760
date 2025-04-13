rexx_EBC2ASC:  /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "01.01"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

=======================================================================

  Dataset: REXX(EBC2ASC)
  Author:  KTomiak
  Contact: "Kenneth Tomiak"<CBT_KEN@KTomiak.biz>
  Syntax:  EBC2ASC (filename)
           filename - [drive:][path\]filename
           ".xmi" will be added on output file.

  History of Modifications
  ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  01.01 Standardizing Rexx_Initialize routine
  20070624 KTomiak  01.00 Original code.

=======================================================================

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

  Parse Arg all_my_arguments
  Numeric Digits 12

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Call the other routines.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Main_EBC2ASC:
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
  Parse Var all_my_arguments xmit_file_in .
  file_size = Chars(xmit_file_in)
  If (file_size = 0) Then Return 12
  back_wards = Reverse(xmit_file_in)
  Parse Var back_wards in_file_xmit "\" path_drive
  just_file_name = Reverse(in_file_xmit)
  drive_path = Reverse(path_drive)
  xmit_file_xmi = xmit_file_in".xmi"
  Call rexx_build_arrays
  rpt = just_file_name "has" file_size "character(s)."
  Say rpt
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine read the entire file as a chunk, translate it
  from PC ASCII to EBCDIC, and then write it out as a chunk.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Process:
  line_out = CharIn(xmit_file_in,1,file_size)
  line_out = e2a(line_out)
  write_rc = CharOut(xmit_file_xmi,line_out,1)
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we close files and finish up.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Termination:
  If (file_size = 0) Then Return 12
  write_rc = LineOut(xmit_file_in)
  write_rc = LineOut(xmit_file_xmi)
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Convert EBCDIC value to PC ASCII value
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
e2a: Procedure Expose xlat_a2e
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

  Return


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
__DATA__
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

