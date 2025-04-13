:HOSTDEFAULT.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-21 Kenneth E Tomiak
:rem              Added an assortment of z/OS related variables.
:rem              Plus comments and possible values.
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-16 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
set HOSTDEFAULT_COMMAND=%0
call ftpsgd.bat
cls
:rem
:rem These are required variables:
:rem =============================
:rem
set EMAIL=
:rem      your email address is your password when logging
:rem      in as anonymous.
:rem
set ZOSHOST=
:rem        a.host.name
:rem        an.ip.add.ress
:rem        ; Your z/OS system's hostname (DNS) or IP address.
:rem
set USERID=
:rem       USERID is your userid on your z/OS system.
set PASSWORD=
:rem         PASSWORD is your current password on the z/OS system.
:rem
:rem These are optional variables:
:rem =============================
:rem
:rem Interact with what filesystem type:
:rem -----------------------------------
set FILETYPE=SEQ
:rem         SEQ   ; files/datasets
:rem         JES   ; z/OS Job Entry Subsystem
:rem         SQL   ; Like Windows would support DB2, HAH!
:rem
:rem SEQ - new allocations
:rem ---------------------
:rem Best choice is to have SMS manage your high level qualifier (HLQ).
:rem It is named System Managed Storage, so use it. It is not
:rem only for Application data. If it was, it would be called
:rem Application Managed Storage.
:rem
:rem If you fully implemented the principles of System Managed Storage,
:rem then you have a DATACLASS you can select for dataset attributes.
:rem So, choose the variables you need below. If you do not need
:rem to override SMS, leave the variable unassigned.
:rem
:rem Management oriented
:rem -------------------
:rem SMS
:rem ===
set MGMTCLAS=
:rem         SMS mgmtclass name affects migration.
:rem
:rem Device allocation oriented
:rem --------------------------
:rem SMS
:rem ===
set STORCLAS=
:rem         SMS storclass name affects dataset placement.
:rem
:rem NON-SMS
:rem =======
set UNITNAME=SYSALLDA
:rem         SYSALLDA will be any DASD type, a preferred choice.
:rem         SYSDA    will get what you assigned to the esoteric.
:rem         3390     will get what is online as this generic.
:rem
set VOLUME=
:rem       volser of DASD device you want to use for FTP and JCL.
:rem
set UCOUNT=1
:rem       #     ; More than one means multi-volume, invalid for PDSE
:rem             ; Range: 1 - 59
:rem
set VCOUNT=59
:rem       #     ; How many volumes, more of a TAPE construct.
:rem             ; Range: 1 - 59
:rem
:rem Dataset oriented
:rem ----------------
:rem SMS
:rem ===
set DATACLAS=
:rem         SMS data class name affects DCB attributes
:rem
:rem NON-SMS
:rem =======
set SPACETYPE=CYLINDER
:rem          CYLINDER = 1 cylinder equlas 15 tracks
:rem          TRACK    = 1 track has a multiple of BLKSIZE, usually.
:rem                     A PDSE uses 4K pages and BLKSIZE is bufsize.
:rem          BLOCK    = Choose your BLKSIZE wisely or waste lots of space.
:rem
set PRIMARY=10
:rem        #        ; Range 1 to 65535 - per volume without SMS
:rem
set SECONDARY=3
:rem        #        ; Range 1 to 65535 - per volume without SMS
:rem
set PDSTYPE=PDSE
:rem                 ; Determines DCB=DSORG value.
:rem        PDSE     ; Ken's preferred format.
:rem        PDS      ; Get out of the 1970's! Use a PDSE.
:rem        blank    ; With DIRECTORY=0 will be a sequential dataset.
:rem
set DIRECTORY=
:rem                 ; Number of directory blocks in a PDS.
:rem                 ; PDSE has no such construct.
:rem          0      ; With PDSTYPE=blank will be a sequential dataset.
:rem          46     ; 46 fill one track on a 3390.
:rem
set DCBDSN=
:rem       'MODEL.DCB'         ; Use DCB from a model DSCB dataset
:rem       'SYS1.LINKLIB'      ; Use DCB from named LOADLIB
:rem       '%USERID%.ZOS$CNTL' ; Use DCB from named user PDSE
:rem
set RECFM=FB
:rem      fbsp       ; Record format
:rem                 ; f = File format
:rem                 ;   F - Fixed length records
:rem                 ;   U - Undefined record length
:rem                 ;   V - Variable length records
:rem                 ; b = Blocking
:rem                 ;   B - Blocked
:rem                 ;   null - Unblocked
:rem                 ; s = Spanned or Standard
:rem                 ;   S - Spanned (V) or Standard (F)
:rem                 ;   null - Not spanned
:rem                 ; p = Print Control Character
:rem                 ;   A - ASA print control
:rem                 ;   M - Machine print control
:rem                 ;   null - No print control
:rem
set BLKSIZE=32720
:rem        32720  ; Buffer size for a PDSE
:rem        ##     ; Multiple of LRECL if using archaic PDS format
:rem        ##+4   ; Multiple of (LRECL+4)+4 if PDS and RECFM=VB
:rem               ; Valid range is 0 to 32760
:rem
set LRECL=80
:rem      80       ; Perfect for JCL, REXX, PANELS, SOURCE.
:rem      0        ; Perfect for LOADLIB.
:rem               ; Valid range 0 through 32760.
set UMASK=755
:rem      UGO      ; UNIX file permissions
:rem               ; U = User, your own access
:rem               ; G = Group, others with the same Group ID
:rem               ; O = Other, otherwise known as everybody else
:rem
:rem               ; OCTAL mask derived by adding up access levels
:rem               ;  Security Bits
:rem               ;  ----------------------------------
:rem               ;  Permissions:
:rem               ;    bit 0         = File mode
:rem               ;    bit 1-3       = User
:rem               ;    bit 4-7       = Group
:rem               ;    bit 8-10      = other (world/public)
:rem               ;
:rem               ;    l rwx rwx rwx = Symbolic link to real object
:rem               ;    d rwx rwx rwx = Directory
:rem               ;    - rwx rwx rwx = File
:rem               ;    - rwx rwx rwt = File with execute and sticky bit
:rem               ;    - rwx rwx rwT = File with sticky bit
:rem               ;
:rem               ;    Read = 4
:rem               ;    Write = 2
:rem               ;    Execute = 1
:rem               ;
:rem               ;  File Attributes
:rem               ;  ---------------
:rem               ;  4000 = SetUID to zero and execute
:rem               ;  2000 = SetGID to system group and execute
:rem               ;  1000 = Set sticky bit to keep in swap space
:rem               ;
:rem
:rem Transfer oriented
:rem -----------------
set RDW=
:rem    NORDW         ; Strip Record Descriptor Word (RDW)
:rem    RDW           ; Retain Record Descriptor Word (RDW)
:rem
set TRAILINGBLANKS=
:rem               NOTRAINLINGBLANKS ; Strip trailing blanks
:rem               TRAILINGBLANKS    ; Retain trailing blanks
:rem
:rem
set SBDATACONN=
:rem           (IBM-1047,IBM-850)  ; Standard IBM z/OS to PC translation
:rem                               ; A file system code page name
:rem                               ; followed by a network transfer
:rem                               ; code page name according to
:rem                               ; iconv supported code pages.
:rem           (IBM-1141,IBM-1047) ;
:rem           (IBM-1047,UTF-8)    ;
:rem           (UTF-8,IBM=1047)    ;
:rem
:rem JES - Job Entry Subsystem
:rem -------------------------
:rem
:rem SQL - Select from DB2
:rem ---------------------
:rem
:goto all_done
:rem
@echo.
@echo.%0: Set variables that get used by these FTP samples.
@echo.This bat file is called by all the samples, thus if
@echo.you take the time to set this up once, life will be grand.
@echo.
@echo.Here is what you set:
@echo.
@echo.EMAIL=%EMAIL%
@echo.ZOSHOST=%ZOSHOST%
@echo.USERID=%USERID%
@echo.PASSWORD=%PASSWORD%
@echo.FILETYPE=%FILETYPE%
@echo.MGMTCLAS=%MGMTCLAS%
@echo.STORCLAS=%STORCLAS%
@echo.UNITNAME=%UNITNAME%
@echo.VOLUME=%VOLUME%
@echo.UCOUNT=%UCOUNT%
@echo.VCOUNT=%VCOUNT%
@echo.DATACLAS=%DATACLAS%
@echo.SPACETYPE=%SPACETYPE%
@echo.PRIMARY=%PRIMARY%
@echo.SECONDARY=%SECONDARY%
@echo.PDSTYPE=%PDSTYPE%
@echo.DIRECTORY=%DIRECTORY%
@echo.DCBDSN=%DCBDSN%
@echo.RECFM=%RECFM%
@echo.BLKSIZE=%BLKSIZE%
@echo.LRECL=%LRECL%
@echo.UMASK=%UMASK%
@echo.RDW=%RDW%
@echo.TRAILINGBLANKS=%TRAILINGBLANKS%
@echo.SBDATACONN=%SBDATACONN%
@echo.
@echo.Once you feel confident you have entered the correct values,
@echo.go ahead and uncomment the goto on line 214.
@echo.Remove the colon (:).
@echo.
:all_done
set HOSTDEFAULT_COMMAND=
