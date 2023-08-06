rexx_DIR2UPDT: /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "01.04"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

=======================================================================

  Dataset: REXX(DIR2UPDT)
  Author:  KTomiak
  Contact: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
  Syntax:  DIR2UPDT (drive:path)
  Purpose: Combine all the files in a directory with IEBUPDTE ./
           control cards ahead of each file so that they could be
           uploaded to a z/OS dataset and then separated into
           individual PDS members.

           Assumption: You have a maximum of eight characters in your
           subdirectory name.

  History of Modifications
  ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  01.04 Send files to \IEBUPDTE\ sub-directory.
  20070729 KTomiak  01.03 Standardizing Rexx_Initialize routine
  20070727 KTomiak  01.02 Bat file is now in standard FILE760 format.
                          Use decode_drive_path_filename_ext.
                          Somebody is going to request > LRECL=80.
  20070616 KTomiak  01.01 Switched to using ObjectREXX.
  19960901 KTomiak  01.00 Original code

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
rexx_Main_DIR2UPDT:
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
  If (REXX_ENVIR >< "PC/ooREXX") Then,
    Do
      return_code = 24
      Say Copies("!",79)
      Say "Sorry, this only runs on a PC under Open Object REXX!"
      Say Copies("!",79)
      return return_code
    End
  return_code = 0

  help_rc = check_for_help()
  If (help_rc > 0) Then Return help_rc

  Parse Var all_my_arguments dir_to_pds dir_loc
  If (dir_to_pds = "") Then dir_to_pds = "."
  If (dir_loc = "") Then dir_loc = ".\"
  null_rc = decode_drive_path_file_ext(dir_to_pds)
  push filename
  pull pds_name

  line_index = 0
  tot_rec = 0
  tot_dir = 0
  pc_bytes = 0
  tot_bytes = 0
  tot_alias = 0
  max_lrecl = 80

  Call SysFileTree dir_to_pds"\*.*", "File", "L"
  If (file.0 = 0) Then return 12

  Say "I expect filename ends up with the last subdirectory name"
  Say pds_name

  output_seq = dir_loc"\IEBUPDTE\"pds_name".SEQ"
  del_rc = SysFileDelete(output_seq)

  output_jcl = dir_loc"\IEBUPDTE\"pds_name".JCL"
  del_rc = SysFileDelete(output_jcl)

  output_bat = dir_loc"\IEBUPDTE\"pds_name".BAT"
  del_rc = SysFileDelete(output_bat)

  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we loop through our input.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Process:
  Do idx = 1 to file.0
    Parse Var file.idx,
      file_date,
      file_time,
      file_size,
      file_attr,
      path_file,
      .
    null_rc = decode_drive_path_file_ext(path_file)
    Select
      When (Pos(".$$$",filename) > 0) Then Call add_an_alias
      Otherwise,
        Call add_the_file
    end
  End
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  In this routine we close files and finish up.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
rexx_Termination:
  If (tot_bytes = 0) Then Return 4
  Call Write_Trailers
  write_rc = LineOut(output_bat)
  write_rc = LineOut(output_jcl)
  write_rc = LineOut(output_seq)
  Return 0

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Append a ./ ALIAS NAME= control card.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
add_an_alias:
  rpt = LineIn(path_file)
  write_rc = LineOut(output_seq,rpt)
  tot_dir = tot_dir + 1
  tot_alias = tot_alias + 1
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Append another file to the sequential stream.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
add_the_file:
  parse var file_date cd + 2 yy "-" mm "-" dd
  udate = mm"/"dd"/"yy
  zlcjdate = yy""Date("D",udate,"U")
  zlmdtime = Left(file_time,2)""SubStr(file_time,4,2)
  max_records = Lines(path_file)
  zlidnorc = Right("00000"max_records,5)
  zlcdnorc = Right("00000"max_records,5)
  zlmdnorc = "00000"
  ispf_stats = "0666-"ZLCJDATE"-"ZLCJDATE"-"ZLMdTIME
  ispf_stats = ispf_stats"-"ZLIdNORC"-"ZLCdNORC
  ispf_stats = ispf_stats"-"ZLMdNORC"-DIR2UPDT"
  Parse var filename filename "." file_ext .
  rpt = "./ ADD NAME="Left(filename,8) ispf_stats
  l_rpt = Length(rpt)
  pc_bytes = pc_bytes + l_rpt + 2
  tot_bytes = tot_bytes + l_rpt
  write_rc = LineOut(output_seq,rpt)
  tot_dir = tot_dir + 1
  do while Lines(path_file) > 0
    rpt = LineIn(path_file)
    l_rpt = Length(rpt)
    If (l_rpt > max_lrecl) then,
      Do
        Say "Press Enter to continue:" filename":" l_rpt ">" max_lrecl
        pull any_response
        max_lrecl = l_rpt
      End
    tot_bytes = tot_bytes + l_rpt
    pc_bytes = pc_bytes + l_rpt + 2
    write_rc = LineOut(output_seq,rpt)
    tot_rec = tot_rec + 1
  end
  write_rc = LineOut(path_file)
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
  Write trailer and close files.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
Write_Trailers:
  rpt = "./ ENDUP"
  l_rpt = Length(rpt)
  tot_bytes = tot_bytes + l_rpt
  pc_bytes = pc_bytes + l_rpt + 2
  write_rc = LineOut(output_seq,rpt)

  dir = (tot_dir % 5) + 1
  if (dir = 0) then dir = 1
  half_track = (27998 % max_lrecl) * max_lrecl
  tot_space = (tot_rec * 80)
  pri = ((tot_space % half_track) % 2) + 1
  epri = ((tot_space % half_track) % 2) + 1 + (dir % 46)
  sec = (pri % 5) + 1
  write_rc = LineOut(output_jcl,"//JOBNAME JOB (),'POPULATE PDS',")
  write_rc = LineOut(output_jcl,"//            CLASS=a,")
  write_rc = LineOut(output_jcl,"//            MSGCLASS=a,")
  write_rc = LineOut(output_jcl,"//            MSGLEVEL=(1,1),")
  write_rc = LineOut(output_jcl,"//            REGION=4M,TIME=1200,")
  write_rc = LineOut(output_jcl,"//            NOTIFY=&SYSUID")
  write_rc = LineOut(output_jcl,"//*")
  write_rc = LineOut(output_jcl,"//LIBTYPE SET LIBTYPE="pds_name,
    "  <=== other levels of qualifiers")
  write_rc = LineOut(output_jcl,"//EXELIB  SET EXELIB=<your.loadlib")
  write_rc = LineOut(output_jcl,"//*")
  outline = "//* DOC: This job will add" tot_dir "MEMBER(S)",
    "to a PDS or PDSE."
  write_rc = LineOut(output_jcl,outline)
  write_rc = LineOut(output_jcl,"//*")
  write_rc = LineOut(output_jcl,"//* max_lrecl="max_lrecl)
  write_rc = LineOut(output_jcl,"//* half-track block size="half_track)
  write_rc = LineOut(output_jcl,"//*")
  If (tot_alias > 0) Then,
    Do
      write_rc = LineOut(output_jcl,"//* WARNING !")
      write_rc = LineOut(output_jcl,"//* There are" tot_alias,
        "ALIAS control card(s) that must be moved.")
      write_rc = LineOut(output_jcl,"//* If you do not move them,",
        "then will be defined on the wrong members.")
      write_rc = LineOut(output_jcl,"//*")
    End
  outline = "//*" Copies(">",66)
  write_rc = LineOut(output_jcl, outline)
  outline =,
    "//*<-- Created on" Date("S") "at" Time() "--->"
  write_rc = LineOut(output_jcl, outline)
  outline = "//* Pick whether you want a PDS or a PDSE."
  write_rc = LineOut(output_jcl, outline)
  outline = "//*" Copies("<",66)
  write_rc = LineOut(output_jcl, outline)
  outline = "//ALLOC   EXEC PGM=IEFBR14"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//PDS      DD  DISP=(NEW,CATLG),DSN=&SYSUID..&LIBTYPE,"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             SPACE=(TRK,("pri","sec","dir")),"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             UNIT=SYSALLDA,"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             DSORG=PO,RECFM=FB,BLKSIZE=0,LRECL="max_lrecl
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//PDSE     DD  DISP=(NEW,CATLG),DSN=&SYSUID..&LIBTYPE,"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             SPACE=(TRK,("epri","sec",0)),"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             UNIT=SYSALLDA,"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             DSNTYPE=LIBRARY,"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//             DSORG=PO,RECFM=FB,BLKSIZE=0,LRECL="max_lrecl
  write_rc = LineOut(output_jcl, outline)
  outline = "//*"
  write_rc = LineOut(output_jcl, outline)
  outline = "//*" Copies(">",66)
  write_rc = LineOut(output_jcl, outline)
  outline = "//* Load the PDS or PDSE"
  write_rc = LineOut(output_jcl, outline)
  outline = "//*" Copies("<",66)
  write_rc = LineOut(output_jcl, outline)
  outline = "//UPDTE   EXEC PGM=IEBUPDTE,PARM='NEW'"
  write_rc = LineOut(output_jcl, outline)
  outline = "//*PDTE   EXEC PGM=PDSLOAD,PARM='./'    or"
  write_rc = LineOut(output_jcl, outline)
  outline = "//*TEPLIB  DD  DISP=SHR,DSN=&SYSUID..&EXELIB"
  write_rc = LineOut(output_jcl, outline)
  outline = "//SYSPRINT DD  SYSOUT=*"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//SYSUT2   DD  DISP=OLD,DSN=&SYSUID..&LIBTYPE"
  write_rc = LineOut(output_jcl, outline)
  OUTLINE = "//SYSIN    DD  DISP=SHR,DSN=&SYSUID.."pds_name".SEQ"
  write_rc = LineOut(output_jcl, outline)
  write_rc = LineOut(output_jcl,"//*")
  write_rc = LineOut(output_jcl,"//")

  bat_line = ,
    ":"pds_name".bat"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "%echo off"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem  Author: ""Kenneth Tomiak""<CBT_Ken@KTomiak.biz>"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem  History of Changes"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem  -----------",
    "----------------------------------------------------"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem  02007-07-27 Kenneth E Tomiak"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem              Original code."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem  -----------",
    "----------------------------------------------------"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "cls"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "set "pds_name"_COMMAND=%0"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.%"pds_name"_COMMAND%: Attempt to allocate two sequential"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.datasets and upload the "pds_name".SEQ and .JCL file."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo [%FTPCONFIG%]"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "pause"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "call %FTPCONFIG%"
  bat_line = ,
    "if [%FTPCONFIG%]==[] goto :no_config"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "call %FTPCONFIG%"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "goto :check_basic_attributes"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":no_config"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "set FTPCONFIG=FTPDEFAULT"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "call %FTPCONFIG%"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":check_basic_attributes"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "if [%USERID%]==[]   goto :need_userid"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "if [%PASSWORD%]==[] goto :need_password"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "if [%ZOSHOST%]==[]  goto :need_zoshost_name"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  bat_line = ,
    ":rem login"
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.%USERID% >%TMP%\ftp.txt"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.%PASSWORD% >>%TMP%\ftp.txt"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "call ftpsetattributes.bat"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  bat_line = ,
    ":rem Allocate sequential dataset of correct size for DATA"
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.quote site recfm=fb blksize=0 lrecl=80 >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.quote site tracks pri="pri "sec="sec " >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  bat_line = ,
    ":rem Upload the DATA"
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.put "pds_name".seq '%USERID%."pds_name".SEQ' >>%TMP%\ftp.txt"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  bat_line = ,
    ":rem Allocate sequential dataset of correct size for JCL"
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.quote site tracks pri=1 sec=1 >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  bat_line = ,
    ":rem Upload the JCL"
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.put "pds_name".jcl '%USERID%."pds_name".JCL' >>%TMP%\ftp.txt"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.cd '%USERID%."pds_name" >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.bell >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "echo.dir >>%TMP%\ftp.txt "
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Watch the FTP session - look at the output."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.If all goes well, you will need to enter 'quit' to end",
    "the session."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.If the upload failed then you might fiddle with your"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.settings and try the 'put' that failed."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Total bytes to upload:" pc_bytes "+ crlf"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Total bytes to upload:" tot_bytes "- crlf"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "ftp -s:%TMP%\ftp.txt %ZOSHOST%"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "del %TMP%\ftp.txt"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "goto all_done"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":need_userid"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":need_password"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":need_zoshost_name"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Syntax: %"pds_name"_command%:"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.But first you must set a configuration file."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Edit ftpconfig.bat and set variables and save-as"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.some filename.bat. I recommend something along the"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.line of ftp[HOSTNAME].bat, where [HOSTNAME] matches"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.the z/OS system you will be connecting to. If you"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.have more than one z/OS system you can can have muliple"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.configuration files. Just remember to issue:"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.ftpsetconfig ftp[HOSTNAME]"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.Otherwise, I try ftpdefault.bat."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "goto :quick_exit"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":all_done"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.If the upload worked, you may edit the JCL and submit it."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":rem"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    ":quick_exit"
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo.%"pds_name"_COMMAND%: Done."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "@echo."
  write_rc = LineOut(output_bat,bat_line)
  bat_line = ,
    "set "pds_name"_COMMAND="
  write_rc = LineOut(output_bat,bat_line)
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
  Say ">>--"ucname"+file_name+----------------<<"
  Say ""
  Return

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 Break a drive_path_filename_extension string into parts.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
decode_drive_path_file_ext:
  parse arg a
  last_colon = LastPos(":",a)
  first_slash = Pos("\",a) - 1
  if (first_slash < 0) then first_slash = 0
  last_slash = LastPos("\",a) - first_slash
  last_period = LastPos(".",a)
  Parse Var a,
    drive      +(first_slash),
    path       +(last_slash),
    filename    ".",
    extension
  if (last_colon = 0) then drive = ""
  if (last_slash = 0) then path  = ""
  drive_path = drive""path
  ilq. = ""
  ilq_idx = 0
  temp_path = path
  Do while temp_path >< ""
    ilq_idx = ilq_idx + 1
    Parse Var temp_path ilq.ilq_idx "\" temp_path
  End
  ilq.0 = ilq_ctr
  return "OK"

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
=======================================================================
 No parameters were passed.
=======================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
show_some_history:
  Say Copies("-",79)
  Say "History:"
  Say "I first wrote a REXX form of PDS2SEQ for OS/390."
  Say "It wrote a ./ ADD control card and then the contents of"
  Say "the member. I even had a versoin that kept track of when it"
  Say "was last run and only selected members that had been changed"
  Say "after that date. While this reduced repetitive archiving, it"
  Say "merged members from different datasets into one sequential"
  Say "dataset. Poor implementation of a fairly okay idea."
  Say "Eventually scrapped that design and went with just selecting"
  Say "every member. Later started adding statisics on the ./"
  Say "control card. Recently adjusted the statistics to work with"
  Say "PDSLOAD."
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

