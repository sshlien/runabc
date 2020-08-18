###  Runabc

The latest version of the source code is still found on
[ifdo.ca/~seymour/runabc/top.html](https://ifdo.ca/~seymour/runabc/top.html).

**Runabc** is a user interface to the abcmidi, abcm2ps, and abc2svg packages
described elsewhere. Like EasyABC it allows you to create, edit, render and
play ABC music notation files. The user interface is not as nice as EasyABC,
but this program has a lot more functionality and is still being updated
fairly frequently. The program is written in tcl/tk scripting language which
unfortunately is tending to be forgotten language. In contrast, EasyABC is
written in Python, a very popular language like Java, JavaScript, and C++.
Owing to the difficulty of overcoming various problems with Python and its
libraries, development of EasyABC has been slow.

There is already extensive documentation on how to use runabc.tcl on
<https://runabc.sourceforge.io>, so this note merely describes the content of
this repository.

**runabc.tcl** is the biggest file and contains the source code. Assuming
tcl/tk is already installed on your system, you run runabc.tcl from a command
window (or terminal) by entering:

wish runabc.tcl

**runabc.ico** is the icon

**runabc.nsi** and **setup_runabc.iss** are scripts for creating an installer
on Windows using either Nullsoft Scriptable Install or Inno Setup Script
Wizard respectively. Presently I only use the latter. On Windows, I create a
runabc.exe executable which includes the tcl/tk interpreter using starkits.

**gpl.txt** contains the Gnu general public license.

**runabc.txt** describes the design of the source code.

The abc file, **nmodes.abc** is actually required by runabc.tcl, in the case
that you are using histogram matching to determine the mode (major, dorian,
minor, ...) of the music. The file should be placed where runabc can find it
-- usually in runabc_home.

The remaining stuff are in three separate folders described here.

**abc_examples** contains some files if you are interested in percussion
instruments.

**extensions** contains some tcl/tk code which can be loaded into runabc using
the options menu item load runabc extension.

and finally, **layout_files** contains a bunch of fmt files that abcm2ps or
abc2svg can use.

