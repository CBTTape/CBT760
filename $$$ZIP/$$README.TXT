
You have already figured out there are some PC based files in
this collection if you are reading this. By whatever means.
I would phrase it as there are DOS based files and z/OS based files
in this collection.

=======================================================================

Let me state up front, this collection is under construction. I have
been ferverently working to bundle everything I have related to
moving data from the Mother-Of-All-Servers (MOAS) to a PC, or other
weenie-platform, and back again. In my haste to make these files
available I have taken one huge step that goes against my idealogical
philosophy. I have made changes to just about every file/member and
not tested them, yet. If you have a problem with that, wait awhile.

I concentrated on using the DOSBAT files to move PC files to z/OS
PDSE members and back again. I also used FTPBACKUP to turn a PDSE
into one sequential dataset that I then download to my PC. From there
I can extract individual members and turn them into PC files.

I accumulated samples and examples that I have been working on and
started giving them a standardized Ken's Universe look. It takes quite
a lot of time to make sure every JCL member has the same look. And
for every REXX program to have the same look. And to then document
every file I added to two places. Sometimes I have DOS bat files in
my location and after adding a new one must also add it to my make760
file so it gets included. And document it.

=======================================================================

I mentioned an interest in hearing if you have a better way to
accomplish a task. Here are some ideas of what will not be deemed
as a better way:

 1)  Brevity of variable name size is not better.

 2)  Nor is lengthening them.

 3)  Nor is changing their name. I realize some of my variable names
     could be more descriptive. In this iteration of FILE760 my
     goal is content. So many of the included members do not conform
     to a standard I am still developing. The DOSBAT files were the
     first to have a pretty consistent style applied to them. In time,
     the other files will also undergo some grooming. And what a pain
     it is to apply some new style or technique to every file after
     the fact. All too often I have taken a quick and dirty attitude
     when writing the code.

 4)  Eliminating my [Do]-[End] blocks is not better.

 5)  Moving lines of code to eliminate a [Call] is not better.

 6)  Writing it in assembler is not better.

 7)  Changing indentation to your preference is not better.

 8)  Changing the order of operands to your preference is not better.

 9)  Converting to VB is not better.

10)  Converting to a PDS is not better. My examples contain decision
     points to consider for a PDS or PDSE. And why to COMPRESS a PDS
     and REORG a PDSE.

11)  Using an obscure method to tweak one less millisecond out of a
     30 second execution is not better. But interesting.

12) I know about ISPF File Tailoring a.k.a. SKELETONS.

13) I know lots of stuff I am not sharing, and forgot lots you may
    know. If I do not use it, then I lose it. If I lost it,
    it may not be worth using. I recently stumbled upon LastPos,
    which I knew at one time, and knew where I needed to start using
    it.

  So if you really have something worth sharing, share it. I will
  evaluate your suggestion and if I deem it worthy to spin in Ken's
  universe, I will go ahead and implement it and give you credit.

=======================================================================

There are a three major categories for what is included herein.

 1)  DOS, analogous with PC DOS and the Windows COMMAND prompt box.

   a)  DOSBAT contains BAT files, mostly related to scripting a DOS
       FTP client session with a z/OS host or manipulating files
       to ease transporting them to or from a PC and the z/OS host.

   b)  DOSDATA contains any sample files on the PC.

   c)  DOSREXX contains Open Object REXX (OORexx) source code.

   d)  HTML contains web pages you can view with your browser.

 2)  z/OS based elements. The directory name conforms with the
     TSO/E and ISPF standard for the Low Level Qualifier (LLQ). The
     LLQ has meaning to commands like MODEL, ISR, JCL, and UTILITY.

   a)  CONFIG is the saved file from using ISRCONFIG. Why IBM chose
       an LRECL > 80 for 80 byte data is a mystery to me. It means you
       need a special PDSE to hold what is nothing more than 80
       byte data. Delusions of grandieur. Lack of any real thought.

   b)  CLIST contains any Command Procedures (CLIST) source code.

   c)  CNTL contains JCL to execute batch jobs.

   d)  DATA contains any static data.

   e)  MSGS contains any ISPF Message members.

   f)  PANELS contains any ISPF Panel members.

   g)  REXX contains any z/OS REXX source code.

   h)  SHELL contains any z/OS UNIX scripts.

   i)  SKELS contains any ISPF Skeleton members.

 3)  Rudimentary (really basic) samples of PARMLIB, JCL and Utilities.

   a)  IBM$PARM contains some not so commonly used PARMLIB members.

   b)  ZOSJCL contains a brief example for each JCL element. This
       might be an entire statement or a single parameter of a
       statement.

   c)  ZOSCNTL contains some examples straight out of a manual that
       are slowly being updated to conform with how your system
       should be using Utilities in this day and age. That means
       removing almost every reference to specifying a volser on
       tape output. Using catalogued datasets. Using SMS. Get with
       the times.

       And there are samples going beyond the utilities manual. Not
       just your parent's utilities, but an entire collection of
       everyday utility-like programs for all sorts of components.
       The collection grows as I have time to add things I have or
       a rare individual shares something to be added. Very rare
       are those individuals. Most surfers are merely looking for
       what the web can do for them and not what they can do for
       the web.

=======================================================================

