//JOBNAME JOB (),'POPULATE PDS',
//            CLASS=a,
//            MSGCLASS=a,
//            MSGLEVEL=(1,1),
//            REGION=4M,TIME=1200,
//            NOTIFY=&SYSUID
//*
//LIBTYPE SET LIBTYPE=CNTL   <=== other levels of qualifiers
//EXELIB  SET EXELIB=<your.loadlib
//*
//* DOC: This job will add 22 MEMBER(S) to a PDS or PDSE.
//*
//* max_lrecl=80
//* half-track block size=27920
//*
//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//*<-- Created on 20070802 at 21:37:43 --->
//* Pick whether you want a PDS or a PDSE.
//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//ALLOC   EXEC PGM=IEFBR14
//PDS      DD  DISP=(NEW,CATLG),DSN=&SYSUID..&LIBTYPE,
//             SPACE=(TRK,(2,1,5)),
//             UNIT=SYSALLDA,
//             DSORG=PO,RECFM=FB,BLKSIZE=0,LRECL=80
//PDSE     DD  DISP=(NEW,CATLG),DSN=&SYSUID..&LIBTYPE,
//             SPACE=(TRK,(2,1,0)),
//             UNIT=SYSALLDA,
//             DSNTYPE=LIBRARY,
//             DSORG=PO,RECFM=FB,BLKSIZE=0,LRECL=80
//*
//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//* Load the PDS or PDSE
//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//UPDTE   EXEC PGM=IEBUPDTE,PARM='NEW'
//*PDTE   EXEC PGM=PDSLOAD,PARM='./'    or
//*TEPLIB  DD  DISP=SHR,DSN=&SYSUID..&EXELIB
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DISP=OLD,DSN=&SYSUID..&LIBTYPE
//SYSIN    DD  DISP=SHR,DSN=&SYSUID..CNTL.SEQ
//*
//
