rexx_CHARGRID: /* We still need rexx in comment if read from SYSPROC */
  rexxpgm_version = "01.01"
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

=======================================================================

  Dataset: CHARGRID.REX
  Author:  KTomiak
  Contact: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
  Syntax:  CHARGRID
  Purpose: Create a grid of char_subset 256 EBCDIC characters. I use
           this for testing character translation routines. It could
           also be used for testing CCSID translations.

  History of Modifications
  ------------------------
  When     Who      What you did
  -------- -------- ---------------------------------------------------
  20070729 KTomiak  01.01 Standardizing Rexx_Initialize routine
  20060113 KTomiak  Original code.

=======================================================================

STANDARD GLOBAL DISCLAIMER
The author explicitly disavows any claim whatsoever about the
correctness or functionality of this program, and disclaims liability
for anything and everything bad that might happen in connection with,
before, during, or after using it.  I have tried to make it work right,
and I am personally pretty confident that it does, but everybody makes
mistakes, so if you use it, you do so at your own risk.

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

Say ""
Say "Expect a line break when x'0A' is shown."
Say "Expect a line break when you view the file on a PC."
Say ""

grid_file = "DATA\chargrid.bin"
"erase" grid_file

char_subset = "+_0123456789ABCDEF_+"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('00'x,'0F'x)
char_subset = "0_"char_subset"_0"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('10'x,'19'x)x2c('00')xrange('1b'x,'1f'x)
char_subset = "1_"char_subset"_1"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('20'x,'2F'x)
char_subset = "2_"char_subset"_2"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('30'x,'3F'x)
char_subset = "3_"char_subset"_3"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('40'x,'4F'x)
char_subset = "4_"char_subset"_4"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('50'x,'5F'x)
char_subset = "5_"char_subset"_5"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('60'x,'6F'x)
char_subset = "6_"char_subset"_6"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('70'x,'7F'x)
char_subset = "7_"char_subset"_7"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('80'x,'8F'x)
char_subset = "8_"char_subset"_8"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('90'x,'9F'x)
char_subset = "9_"char_subset"_9"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('A0'x,'AF'x)
char_subset = "A_"char_subset"_A"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('B0'x,'BF'x)
char_subset = "B_"char_subset"_B"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('C0'x,'CF'x)
char_subset = "C_"char_subset"_C"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('D0'x,'DF'x)
char_subset = "D_"char_subset"_D"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('E0'x,'EF'x)
char_subset = "E_"char_subset"_E"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = xrange('F0'x,'FF'x)
char_subset = "F_"char_subset"_F"
q = Lineout(grid_file,char_subset)
Say char_subset
char_subset = "+_0123456789ABCDEF_+"
q = Lineout(grid_file,char_subset)
Say char_subset
q = Lineout(grid_file)
exit 0

