#package provide app-runabc 1.0

#!/bin/sh
# the next line restarts using wish \
exec wish8.6 "$0" "$@"
#
# runabc.tcl - by Seymour Shlien  fy733@ncf.ca
# This is graphics user interface to the abc2midi and abc2ps programs.
# This script and the above programs are public domain.
#

# runabc.tcl: a graphical user interface to abcMIDI and other packages
#
# Copyright (C) 1998-2021 Seymour Shlien
#
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Original page:
#      http://ifdo.ca/~seymour/runabc/top.html


set runabc_version 2.280
set runabc_date "(March 28 2021 19.40)"
set runabc_title "runabc $runabc_version $runabc_date"
set tcl_version [info tclversion]
set startload [clock clicks -milliseconds]
#lappend auto_path /usr/share/tcltk/tk8.5

package require Tk
if {[catch {package require Ttk} error]} {
    puts $error
    puts "I am looking for this package in $auto_path"
    puts "Be sure you are running Tcl/Tk 8.5 or higher"
}

# Part 1.0                Tooltip
# Part 2.0                Start up
# Part 3.0                images
# Part 4.0                Control Buttons
# Part 5.0                TOC
# Part 6.0                Core Functions
# Part 7.0                TOC creator
# Part 8.0                Extract Tune
# Part 9.0                Functions for Manipulating abc tune file
# Part 10.0               Abc Editor Functions
# Part 10.1		  Bar Picker
# Part 10.2               Guitar Chord ToolBox
# Part 10.3               Transposition ToolBox
# Part 10.4               Note Length ToolBox
# Part 10.5               Editor Clean Functions
# Part 10.6               Process Editor Buffer
# Part 10.7               Grace Notes Toolbox
# Part 10.8               Chords ToolBox
# Part 11.0               Show Summary Sheet ,tmpfile and message sheet
# Part 12.0               Property Sheets -- titles, voice, style, abc2abc, midi2abc etc
# Part 13.0               Help texts
# Part 14.0               Drum Editor
# Part 15.0               Title Search functions
# Part 16.0               Abcmatcher interface
# Part 17.0               Grouper interface
# Part 18.0               Diagnostic Support Functions
# Part 19.0               Abc Editor Filter functions
# Part 20.0               Bar Alignment
# Part 21.0               Console Page Support Functions
# Part 22.0               Midi2abc interface
# Part 23.0               Voice Support Functions for midi2abc
# Part 24.0               Chord substitution functions for Abc Editor
# Part 25.0               Midishow - Piano Roll
# Part 26.0               Midi Drum event viewer (drumgram)
# Part 27.0               Midi Statistics for Midishow
# Part 28.0               Graphics Namespace
# Part 29.0               File type registration
# Part 30.0               Mftext interface
# Part 31.0               Incipits file support functions
# Part 32.0               Beat Graph and Unique Chords for Midishow
# Part 33.0               Solfege vocalization for abc editor
# Part 34.0               Drum Editor
# Part 35.0               Gchord to voice
# Part 36.0               Drum to voice
# Part 37.0		  Refactor
# Part 38.0               Mode Recognition
# Part 39.0               Advanced abcm2ps support
# Part 40.0               Live Editor
# Part 41.0               Generate Guitar Chords
# Part 42.0               Midisummary
# Part 43.0               Notegram
# Part 44.0               Midistructure
# Part 45.0               big abc editor
# Part 46.0               pgram



# Important global variables:
# midi() -- array storing states in runabc.ini
# df             font
# abc_open       file name path of input abc file
# active_sheet   property sheet overlain on main window
# exec_out       passes output messages from executables
# fileseek       byte position of each tune in abc file
# keyorder       CDEFGAB
# keymap         flat and sharps map
# gchordtypes    aug dim  maj7 etc.
# m(1)-m(16)     names of 128 Midi programs
# progtranslator names of 128 Midi programs
# drumpatches    names of percussion instruments
# note(0)-(11)   C C# D etc.
# drumentry      drum pattern
# mididrum       preserved drum pattern for meter
# gchordentry    gchord for tune
# midigchord     preserved gchord pattern for meter
# dvoice         for g2v (gchords/drums to voices)
# modifiedflag   live editor modified

#  Graphical User Interface


# Part 1.0                Tooltip


# tooltip.tcl --
#
#       Balloon help
#
# Copyright (c) 1996-2003 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: tooltip.tcl,v 1.5 2005/11/22 00:55:07 hobbs Exp $
#
# Initiated: 28 October 1996


package require Tk 8.5
package provide tooltip 1.1


#------------------------------------------------------------------------
# PROCEDURE
#	tooltip::tooltip
#
# DESCRIPTION
#	Implements a tooltip (balloon help) system
#
# ARGUMENTS
#	tooltip <option> ?arg?
#
# clear ?pattern?
#	Stops the specified widgets (defaults to all) from showing tooltips
#
# delay ?millisecs?
#	Query or set the delay.  The delay is in milliseconds and must
#	be at least 50.  Returns the delay.
#
# disable OR off
#	Disables all tooltips.
#
# enable OR on
#	Enables tooltips for defined widgets.
#
# <widget> ?-index index? ?-item id? ?message?
#	If -index is specified, then <widget> is assumed to be a menu
#	and the index represents what index into the menu (either the
#	numerical index or the label) to associate the tooltip message with.
#	Tooltips do not appear for disabled menu items.
#	If message is {}, then the tooltip for that widget is removed.
#	The widget must exist prior to calling tooltip.  The current
#	tooltip message for <widget> is returned, if any.
#
# RETURNS: varies (see methods above)
#
# NAMESPACE & STATE
#	The namespace tooltip is used.
#	Control toplevel name via ::tooltip::wname.
#
# EXAMPLE USAGE:
#	tooltip .button "A Button"
#	tooltip .menu -index "Load" "Loads a file"
#
#------------------------------------------------------------------------

namespace eval ::tooltip {
    namespace export -clear tooltip
    variable tooltip
    variable G
    
    array set G {
        enabled		1
        DELAY		500
        AFTERID		{}
        LAST		-1
        TOPLEVEL	.__tooltip__
    }
    
    # The extra ::hide call in <Enter> is necessary to catch moving to
    # child widgets where the <Leave> event won't be generated
    bind Tooltip <Enter> [namespace code {
        #tooltip::hide
        variable tooltip
        variable G
        set G(LAST) -1
        if {$G(enabled) && [info exists tooltip(%W)]} {
            set G(AFTERID) \
                    [after $G(DELAY) [namespace code [list show %W $tooltip(%W) cursor]]]
        }
    }]
    
    bind Menu <<MenuSelect>>	[namespace code { menuMotion %W }]
    bind Tooltip <Leave>	[namespace code hide]
    bind Tooltip <Any-KeyPress>	[namespace code hide]
    bind Tooltip <Any-Button>	[namespace code hide]
}

proc ::tooltip::tooltip {w args} {
    variable tooltip
    variable G
    switch -- $w {
        clear	{
            if {[llength $args]==0} { set args .* }
            clear $args
        }
        delay	{
            if {[llength $args]} {
                if {![string is integer -strict $args] || $args<50} {
                    return -code error "tooltip delay must be an\
                            integer greater than 50 (delay is in millisecs)"
                }
                return [set G(DELAY) $args]
            } else {
                return $G(DELAY)
            }
        }
        off - disable	{
            set G(enabled) 0
            hide
        }
        on - enable	{
            set G(enabled) 1
        }
        default {
            set i $w
            if {[llength $args]} {
                set i [uplevel 1 [namespace code "register [list $w] $args"]]
            }
            set b $G(TOPLEVEL)
            if {![winfo exists $b]} {
                toplevel $b -class Tooltip
                if {[tk windowingsystem] eq "aqua"} {
                    ::tk::unsupported::MacWindowStyle style $b help none
                } else {
                    wm overrideredirect $b 1
                }
                wm positionfrom $b program
                wm withdraw $b
                label $b.label -highlightthickness 0 -relief solid -bd 1 \
                        -background lightyellow -fg black
                pack $b.label -ipadx 1
            }
            if {[info exists tooltip($i)]} { return $tooltip($i) }
        }
    }
}

proc ::tooltip::register {w args} {
    variable tooltip
    set key [lindex $args 0]
    while {[string match -* $key]} {
        switch -- $key {
            -index	{
                if {[catch {$w entrycget 1 -label}]} {
                    return -code error "widget \"$w\" does not seem to be a\
                            menu, which is required for the -index switch"
                }
                set index [lindex $args 1]
                set args [lreplace $args 0 1]
            }
            -item	{
                set namedItem [lindex $args 1]
                if {[catch {$w find withtag $namedItem} item]} {
                    return -code error "widget \"$w\" is not a canvas, or item\
                            \"$namedItem\" does not exist in the canvas"
                }
                if {[llength $item] > 1} {
                    return -code error "item \"$namedItem\" specifies more\
                            than one item on the canvas"
                }
                set args [lreplace $args 0 1]
            }
            default	{
                return -code error "unknown option \"$key\":\
                        should be -index or -item"
            }
        }
        set key [lindex $args 0]
    }
    if {[llength $args] != 1} {
        return -code error "wrong \# args: should be \"tooltip widget\
                ?-index index? ?-item item? message\""
    }
    if {$key eq ""} {
        clear $w
    } else {
        if {![winfo exists $w]} {
            return -code error "bad window path name \"$w\""
        }
        if {[info exists index]} {
            set tooltip($w,$index) $key
            #bindtags $w [linsert [bindtags $w] end "TooltipMenu"]
            return $w,$index
        } elseif {[info exists item]} {
            set tooltip($w,$item) $key
            #bindtags $w [linsert [bindtags $w] end "TooltipCanvas"]
            enableCanvas $w $item
            return $w,$item
        } else {
            set tooltip($w) $key
            bindtags $w [linsert [bindtags $w] end "Tooltip"]
            return $w
        }
    }
}

proc ::tooltip::clear {{pattern .*}} {
    variable tooltip
    foreach w [array names tooltip $pattern] {
        unset tooltip($w)
        if {[winfo exists $w]} {
            set tags [bindtags $w]
            if {[set i [lsearch -exact $tags "Tooltip"]] != -1} {
                bindtags $w [lreplace $tags $i $i]
            }
            ## We don't remove TooltipMenu because there
            ## might be other indices that use it
        }
    }
}

proc ::tooltip::show {w msg {i {}}} {
    # Use string match to allow that the help will be shown when
    # the pointer is in any child of the desired widget
    if {![winfo exists $w] || ![string match $w* [eval [list winfo containing] [winfo pointerxy $w]]]} {
        return
    }
    
    variable G
    
    set b $G(TOPLEVEL)
    $b.label configure -text $msg
    update idletasks
    if {$i eq "cursor"} {
        set y [expr {[winfo pointery $w]+20}]
        if {($y+[winfo reqheight $b])>[winfo screenheight $w]} {
            set y [expr {[winfo pointery $w]-[winfo reqheight $b]-5}]
        }
    } elseif {$i ne ""} {
        set y [expr {[winfo rooty $w]+[winfo vrooty $w]+[$w yposition $i]+25}]
        if {($y+[winfo reqheight $b])>[winfo screenheight $w]} {
            # show above if we would be offscreen
            set y [expr {[winfo rooty $w]+[$w yposition $i]-\
                        [winfo reqheight $b]-5}]
        }
    } else {
        set y [expr {[winfo rooty $w]+[winfo vrooty $w]+[winfo height $w]+5}]
        if {($y+[winfo reqheight $b])>[winfo screenheight $w]} {
            # show above if we would be offscreen
            set y [expr {[winfo rooty $w]-[winfo reqheight $b]-5}]
        }
    }
    if {$i eq "cursor"} {
        set x [winfo pointerx $w]
    } else {
        set x [expr {[winfo rootx $w]+[winfo vrootx $w]+\
                    ([winfo width $w]-[winfo reqwidth $b])/2}]
    }
    # only readjust when we would appear right on the screen edge
    if {$x<0 && ($x+[winfo reqwidth $b])>0} {
        set x 0
    } elseif {($x+[winfo reqwidth $b])>[winfo screenwidth $w]} {
        set x [expr {[winfo screenwidth $w]-[winfo reqwidth $b]}]
    }
    if {[tk windowingsystem] eq "aqua"} {
        set focus [focus]
    }
    wm geometry $b +$x+$y
    wm deiconify $b
    raise $b
    if {[tk windowingsystem] eq "aqua" && $focus ne ""} {
        # Aqua's help window steals focus on display
        after idle [list focus -force $focus]
    }
}

proc ::tooltip::menuMotion {w} {
    variable G
    
    if {$G(enabled)} {
        variable tooltip
        
        set cur [$w index active]
        # The next two lines (all uses of LAST) are necessary until the
        # <<MenuSelect>> event is properly coded for Unix/(Windows)?
        if {$cur == $G(LAST)} return
        set G(LAST) $cur
        # a little inlining - this is :hide
        after cancel $G(AFTERID)
        catch {wm withdraw $G(TOPLEVEL)}
        if {[info exists tooltip($w,$cur)] || \
                    (![catch {$w entrycget $cur -label} cur] && \
                    [info exists tooltip($w,$cur)])} {
            set G(AFTERID) [after $G(DELAY) \
                    [namespace code [list show $w $tooltip($w,$cur) $cur]]]
        }
    }
}

proc ::tooltip::hide {args} {
    variable G
    
    after cancel $G(AFTERID)
    catch {wm withdraw $G(TOPLEVEL)}
}

proc ::tooltip::wname {{w {}}} {
    variable G
    if {[llength [info level 0]] > 1} {
        # $w specified
        if {$w ne $G(TOPLEVEL)} {
            hide
            destroy $G(TOPLEVEL)
            set G(TOPLEVEL) $w
        }
    }
    return $G(TOPLEVEL)
}

proc ::tooltip::itemTip {w args} {
    variable tooltip
    variable G
    
    set G(LAST) -1
    set item [$w find withtag current]
    if {$G(enabled) && [info exists tooltip($w,$item)]} {
        set G(AFTERID) [after $G(DELAY) \
                [namespace code [list show $w $tooltip($w,$item) cursor]]]
    }
}

proc ::tooltip::enableCanvas {w args} {
    $w bind all <Enter> [namespace code [list itemTip $w]]
    $w bind all <Leave>		[namespace code hide]
    $w bind all <Any-KeyPress>	[namespace code hide]
    $w bind all <Any-Button>	[namespace code hide]
}





# Part 2.0       Start up

proc position_window {window} {
   global midi
   if {[string length $midi($window)] < 1} return
   if {$midi(autoposition) == 0} return
   wm geometry $window $midi($window)
   }

wm protocol . WM_DELETE_WINDOW {
    if  {[winfo exist .live]} {
            if {[.live.main.editor.t edit modified]} {
               update_wholefile "no"}
               }
    get_geometry_of_all_toplevels 
    confirm_save
    write_runabc_ini $runabcpath
    exit
    }

wm resizable . 1 1
global df
global ps_numb_start # used by display_section
global abc_file_mod

set abc_file_mod 0; # flag indicate that file midi(abc_open) was changed

# the user can pass as argument the .abc file to open
if {$argc == 1} {
    set filename [file normalize [lindex $argv 0]]
    #    puts $filename
    set abc_open $filename
}
# For abc files associated with runabc on Windows PC
# we need the following
if {$argc == 2} {
    set abc_open [file normalize [lindex $argv 1]]
}

# Avoid multiple runabc processes, use DDE to find if another
# instance of runabc is running
if {$tcl_platform(platform) == "windows"} {
    # get DDE support if available, if not keep going
    if {![catch {package require dde}]} {
        # Now check if runabc is already running: as you can see in the
        # else case below if we don't find an active 'runabc' topic
        # for 'TclEval' service we will start the DDE service and proceed.
        if {[dde services TclEval runabc] != {}} {
            # runabc was started earlier so this process asks the
            # existing (previous) process to call 'open_abc_file'
            # (only if it is a valid file)
            if {[info exist abc_open] && [file exists $abc_open]} {
                # send a message to open the .abc file,
                # take care of special chars
                regsub {\[} [set abc_open] {\[} abc_open
                dde eval runabc "open_abc_file \"$abc_open\""
            }
            # Now we can terminate the new process, the previous will
            # open the file for us and we avoid race conditions on .ini
            # /temp and /workfolder
            exit 0
        } else {
            # We did not find an instance of runabc running, so
            # we register this as the 'runabc' topic and proceed
            dde servername runabc
        }
    }
}


proc messages {msg} {
    global df
    if {[winfo exists .msg] != 0} {destroy .msg}
    toplevel .msg
    position_window ".msg"
    message .msg.out -text $msg -font $df -width 300
    pack .msg.out
}

proc greetings {msg} {
    global df midi
    if {[winfo exists .greetings] != 0} {destroy .greetings}
    toplevel .greetings -width 400
    position_window ".greetings"
    message .greetings.out -text $msg -font $df -width 400
    pack .greetings.out
    checkbutton .greetings.switch -text "do not show this message next time" -variable midi(donotshow) -font $df
    pack .greetings.switch
}

proc check_integrity {} {
    global midi tcl_platform
    global execpath runabcpath
    
    set prtmsg 0
    set msg ""
    if {$tcl_platform(platform) == "windows"} {
        set msg "You are running runabc.tcl under the Windows operating system.\n"
        } else {
        set msg "You are running runabc.tcl under the Unix operating system.\n"
        }
    append msg "runabc is running from $execpath\n"
    append msg "runabc created the folders $runabcpath and this is where it\
will store internal files it needs to read and write. In particular, runabc.ini is found there.\n"
    set abcmidi 0
    set result [check_file path_abc2midi]
    if {[string first "not found" $result] >= 0} {
        append msg "abc2midi was not found at: $midi(path_abc2midi) \n"
        set abcmidi 1
    }
    set result [check_file path_abc2abc]
    if {[string first "not found" $result] >= 0} {
        append msg "abc2abc was not found at: $midi(path_abc2abc) \n"
        set abcmidi 1
    }
    set result [check_file path_midi2abc]
    if {[string first "not found" $result] >= 0} {
        append msg "midi2abc was not found at: $midi(path_midi2abc) \n"
        set abcmidi 1
    }
    set result [check_file path_yaps]
    if {[string first "not found" $result] >= 0} {
        append msg "yaps was not found at: $midi(path_yaps) \n"
        set abcmidi 1
    }
    set result [check_file path_abcmatch]
    if {[string first "not found" $result] >= 0} {
        append msg "abcmatch was not found at: $midi(path_abcmatch) \n"
        set abcmidi 1
    }
    set result [check_file path_midicopy]
    if {[string first "not found" $result] >= 0} {
        append msg "midicopy was not found at:  $midi(path_midicopy) \n"
        set abcmidi 1
    }

    set result [check_file path_gs]
    if {[string first "not found" $result] >= 0} {
        append msg "ghostscript was not found at: $midi(path_gs) \n"
        set abcmidi 1
    }

    if {$abcmidi == 1 && $tcl_platform(platform) == "windows"} {
        append msg "\nYou can find the abcmidi_win32 executables for windows on\
                http://ifdo.ca/~seymour/runabc/top.html\n\
                You should put these executables in the same folder where runabc is found.\
                If the executables are in a different folder you need to specify their location\
                by going to the options/abc executables menu item (wrench icon).\n"
        set result [check_file path_abcm2ps]
        if {[string first "not found" $result] >= 0} {
            append msg "\nabcm2ps was not found at $midi(path_abcm2ps) \n"
            append msg "\nIt is recommended that you use abcm2ps rather than yaps.\
                    abcm2ps is also included with the abcmidi_win32 executables that you can\
                    download from http://ifdo.ca/~seymour/runabc/top.html.\n"
        }

        set result [check_file path_gv]
        set xmsg "\nYou can still use runabc to display (print) the music, but you will be restricted to using abcm2ps and xhtml format.\n"
        if {[string first "not found" $result] >= 0} {
            set prtmsg 1
            append msg "\nPostScript viewer was not found at $midi(path_gv) \n"
            append msg "\n$midi(path_gv) is a PostScript file viewer. You can get \
                    the install package from http://blog.kowalczyk.info/software/sumatrapdf/free-pdf-reader.html\n"}
        if {[file exist "c:/Program Files/gs/"] != 1} {
            set prtmsg 1
            append msg " You will also need Ghostview which you can get from http://www.cs.wisc.edu/~ghost/index.htm\n\
                    This should create a folder gs in your c:/program files/ directory."
        }
        if {$prtmsg} {append msg $xmsg
            set midi(m2ps_output)  "xhtml"
        }
    } else {
        if {$abcmidi == 1} {append msg "\nIf the abcmidi executables are\
                    already on your system, then you need to indicate their location by\
                    going to the options/abc executables menu item (wrench icon) and specifying\
                    their location. If you do not have the executables, you will need to\
                    build them from the source code which you can find on\
                    http://ifdo.ca/~seymour/runabc/top.html or on sourceforge.net.\n"}
        
        set result [check_file path_abcm2ps]
        if {[string first "not found" $result] >= 0} {
            append msg "\nabcm2ps was not found at $midi(path_abcm2ps) \n"
            append msg "\nIt is recommended that you use abcm2ps rather than yaps.\
                    Source code for abcm2ps may be found on the web page http://moinejf.free.fr/ \
                    Either the stable or development versions are fine."
        }
        
        set result [check_file path_gv]
        if {[string first "not found" $result] >= 0} {
            append msg "\nThe PostScript viewer was not found at $midi(path_gv) \n\n"
            append msg "\nYou will need ghostscript and a PostScript file viewer.\
                    on unix there is gs, gv, and evince. One of these should work."
        }

       set result [check_file path_gs]
        if {[string first "not found" $result] >= 0} {
            append msg "\n$midi(path_gs) was not found\n\n"
            append msg "\nYou will need to install ghostscript so that the live\
                    editor will work."
        }


        
        set result [check_file path_midiplayer_1]
        if {[string first "not found" $result] >= 0} {
            append msg "\n\nThe Midi file player was not found at $midi(path_midiplayer_1)\n"
            append msg "\nYou also need a midi player like TiMidity. The\
                    quality of the reproduction depends upon the SoundFont pages it uses.\
                    Free soundfont files are available from http://www.personalcopy.com/sfarkfonts1.htm."
        }
    }
    
    
    greetings $msg
}


proc check_file {execname} {
    global midi tcl_platform
    if {[file exist $midi($execname)]} {
        set msg [format "found"]
    } elseif {$tcl_platform(platform) != "windows"} {
        set cmd "exec which $midi($execname)"
        catch {eval $cmd} loc
        if {[string first "abnorm" $loc] > 0} {set msg [format "not found"]} else {
            set msg [format "found"]}} else {
        set msg [format "not found"]}
    return $msg
}


# default values for options
proc midi_init {} {
    global midi df sf dfreset tocf
    global runabc_version
    global tcl_platform
    global drumentry
    global env
    global runabcpath
    set drumentry "none"
    set midi(version) $runabc_version
    set midi(font_family) [font actual helvetica -family]
    set midi(font_family_toc) courier
    #set midi(font_size) [font actual . -size]
    set midi(font_size) 10
    set midi(encoder) [encoding system]
    if {$midi(font_size) <10} {set midi(font_size) 10}
    #set midi(font_weight) [font actual . -weight]
    set midi(font_weight) bold
    set df [font create -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)]
    set sf [font create -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)]
    set dfreset [font create -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)]
    set tocf [font create -family $midi(font_family_toc) -size $midi(font_size) \
            -weight $midi(font_weight)]
    set midi(dir_abcmidi) .
    #set midi(path_abc2ps) abc2ps deprecated
    set midi(path_yaps) yaps
    set midi(path_otherps) jcabc2ps
    if {$tcl_platform(platform) == "windows"} {
        set midi(path_yaps) yaps.exe
        set midi(path_abcm2ps) abcm2ps.exe
        set midi(path_abcmatch) abcmatch.exe
        set midi(path_abc2midi) abc2midi.exe
        set midi(path_abc2abc) abc2abc.exe
        set midi(path_midi2abc) midi2abc.exe
        set midi(path_midicopy) midicopy.exe
        set midi(path_gv) "C:/Program Files/SumatraPDF/SumatraPDF.exe"
	set midi(path_gs) ""
        if {[file exist "C:/Program Files (x86)/SumatraPDF/SumatraPDF.exe"]} {
           set midi(path_gv) "C:/Program Files (x86)/SumatraPDF/SumatraPDF.exe"}
           
        set midi(path_midiplayer_1) "C:/Program Files/Windows Media Player/wmplayer.exe"
        set midi(path_midiplayer_2) "C:/Program Files (x86)/Winamp/Winamp.exe"
        set midi(path_midiplayer_3) ""
        set midi(path_midiplayer_4) ""
        set midi(midiplayer_1_options) "/play /close"
        set midi(midiplayer_2_options) ""
        set midi(midiplayer_3_options) ""
        set midi(midiplayer_4_options) ""
        set midi(path_internet) "c:/Program Files/Internet Explorer/iexplore.exe"} else {
        set midi(path_yaps) yaps
        set midi(path_abcm2ps) abcm2ps
        set midi(path_abcmatch) abcmatch
        set midi(path_abc2midi) abc2midi
        set midi(path_abc2abc) abc2abc
        set midi(path_midi2abc) midi2abc
        set midi(path_midicopy) midicopy
        set midi(path_midiplayer_1) timidity
        set midi(path_midiplayer_2) ""
        set midi(path_midiplayer_3) ""
        set midi(path_midiplayer_4) ""
        set midi(midiplayer_1_options) "-A 50 -ik"
        set midi(midiplayer_2_options) ""
        set midi(midiplayer_3_options) ""
        set midi(midiplayer_4_options) ""
        set midi(path_internet) firefox
        set midi(path_gv) evince
        set midi(path_gs) gs
    }

    # abc2svg settings
    set midi(ps_fmt_file) ""
    set midi(fmt_chk) 0
    set midi(midi_chk) 0
    set midi(remote) 1
    set midi(jslib) "./js"
    set midi(outhtml) "tune.html"
    set midi(webscript) 2

    # window geometry
    set midi(autoposition) 1
    set midi(.) ""
    set midi(.msg) "" 
    set midi(.greetings) ""
    set midi(.error_msg) "" 
    set midi(.abc.copy) ""
    set midi(.abcedit) ""
    set midi(.gracecfg) ""
    set midi(.tmpfile) ""
    set midi(.summary) ""
    set midi(.notice) ""
    set midi(.data_info) ""
    set midi(.drumkit) ""
    set midi(.dk) ""
    set midi(.abcsearch) ""
    set midi(.matcher) ""
    set midi(.matchcfg) ""
    set midi(.midistructure) ""
    set midi(.msummary) ""
    set midi(.grouper) ""
    set midi(.piano) ""
    set midi(.ppqn) ""
    set midi(.drumroll) ""
    set midi(.drumrollconfig) ""
    set midi(.pitchpdf) ""
    set midi(.durpdf) ""
    set midi(.velocitypdf) ""
    set midi(.onsetpdf) ""
    set midi(.pitchclass) ""
    set midi(.midivelocity) ""
    set midi(.assoc) ""
    set midi(.mftext) ""
    set midi(.beatgraph) ""
    set midi(.chordstats) ""
    set midi(.drumtool) ""
    set midi(.cfg_drumtool) ""
    set midi(.headers) ""
    set midi(.pitchinterval) ""
    set midi(.histmatches) ""
    set midi(.m2ps) ""
    set midi(.live) ""
    set midi(.preferred_chords) ""
    set midi(.notegram) ""
    set midi(.preferences) ""
    set midi(.pgram) ""


    # button appearance
    set midi(butborder) 3
    set midi(butrelief) raised
    set midi(butbg) "light grey"

    set midi(path_editor) ""
    set midi(player) 0
    set midi(midiplayer_1_prot) 0
    set midi(midiplayer_2_prot) 0
    set midi(midiplayer_3_prot) 0
    set midi(midiplayer_4_prot) 0
    set midi(no_clipboard) 1
    set midi(bell_on) 1
    set midi(buttonlabels) 0
    set midi(noconfirmsave) 0
    
    # abc2midi default parameters
    set midi(channel) 1
    set midi(program) 0
    set midi(chordprog) 0
    set midi(bassprog) 0
    set midi(beat_a) 105
    set midi(beat_b) 95
    set midi(beat_c) 80
    set midi(beat_n) 4
    set midi(beat2_a) 105
    set midi(beat2_b) 95
    set midi(beat2_c) 80
    set midi(double) 0
    set midi(octave) 0
    set midi(octave2) 0
    set midi(program2) 0
    set midi(chord_octave) 0
    set midi(bass_octave) 0
    set midi(melvol) 127
    set midi(doublevol) 127
    set midi(beat_offset) 10
    set midi(ratio_m) 1
    set midi(ratio_n) 2
    set midi(drummap) 1
    set midi(nofermata) 0
    set midi(nograce) 0
    set midi(quiet) 0
    set midi(silent) 0
    set midi(chordvol) 127
    set midi(bassvol) 127
    set midi(transpose) 0
    set midi(tuning) 440
    set midi(gracedivider) 4
    set midi(tempo) 120
    set midi(beatsize) 1/4
    set midi(drone) 0
    set midi(tenordrone) 80
    set midi(bassdrone) 80
    set midi(drumon) 0
    set midi(mydrum) 0
    
    # ab2ps default parameters
    set midi(ps_creator) abcm2ps
    set midi(ps_scale) 0.8
    set midi(ps_width) 500
    set midi(ps_lmargin) 20
    set midi(ps_glue) fill
    set midi(ps_shrink) 0.9
    set midi(ps_staffsep) 50
    set midi(ps_c) 0
    set midi(ps_fmt_flag) 0
    set midi(ps_fmt_landscape) 0
    set midi(ps_fmt_file) letter.fmt
    set midi(ps_maxvent) 4
    set midi(ps_maxsent) 800
    set midi(bpsvoice) 0
    set midi(psvoice) ""
    set midi(ps_bbar) 0
    set midi(ps_bnumb) 0
    set midi(ps_bppage) 0
    set midi(ps_bxref) 0
    set midi(ps_nolyric) 0
    set midi(ps_noslur) 0
    set midi(ps_flat) 0
    set midi(ps_buffsize) 0
    set midi(ps_other_options) ""
    
    set midi(m2ps_output) ps
    
    # yaps default parameters
    set midi(papersize) 0
    set midi(yaps_voice) 0
    set midi(yaps_scale) 0.7
    set midi(yaps_lmargin) 50
    set midi(yaps_tmargin) 50
    set midi(yapsx) 0
    set midi(yaps_landscape) 0
    set midi(yaps_bbar) 0
    
    # other ps default parameters
    set midi(otherps) " > Out.ps"
    set midi(barflymode) 0
    set midi(stressmodel) 2
    
    # open/save parameters
    set midi(abc_open) samples.abc
    set midi(midi_save) sample.mid
    set midi(history_length) 0
    for {set i 0} {$i < 10} {incr i} {set midi(history$i) ""}
    set midi(abc_default_file) edit.abc
    set midi(abc_work_folder)  workfold
    
    for {set i 1} {$i <= 16} {incr i} {
        set midi(lvoice$i) 64
        set midi(voice$i) 0
        set midi(pvoice$i) 64
    }
    set midi(ignoreQ) 0
    set midi(ignoremidi) 0
    set midi(nogchords) 0
    set midi(blank_lines) 1
    #
    #editor settings
    set midi(edit_body_colour) red3
    set midi(edit_field_colour) green4
    set midi(edit_comment_colour) blue2
    set midi(edit_barline_colour) purple
    set midi(edit_guitar_colour) deeppink1
    set midi(edit_selectbackground) orange
    set midi(edit_initial_width) 66
    set midi(startnumber) 1
    
    #find setting
    set midi(searchdir) "../abcfiles"
    
    #match settings
    set midi(match_timesig) 2/4
    set midi(match_keysig) G
    set midi(match_length) 1/8
    set midi(match_body) GABC|
    set midi(match_selection) all
    set midi(match_method) sig
    set midi(match_mode) 0
    set midi(match_norhythm) 0
    set midi(grouper_thresh) 1
    set midi(levenshtein) 0
    
    # extract settings
    set midi(remove_voice) 1
    set midi(remove_backslashes) 1
    set midi(condense_on) 1
    set midi(condense_method) 1
    
    # midi2abc settings
    set midi(midifilein) Choose_input_midi_file.mid
    set midi(midifileout) test.abc
    set midi(midichannels) ""
    set midi(miditracks) ""
    set midi(beat1) ""
    set midi(beat2) ""
    set midi(unitval) ""
    set midi(anaval) ""
    set midi(tsigval) ""
    set midi(ksigval) ""
    set midi(anamethod) 0
    set midi(unitmethod) 2
    set midi(chan_method) 1
    set midi(trk_method) 1
    set midi(beat_method) 1
    set midi(tsig_method) 2
    set midi(ksig_method) 1
    set midi(save_shorts) 0
    set midi(no_triplets) 0
    set midi(no_grouping) 0
    set midi(no_lyrics) 0
    set midi(interleave) 0
    set midi(splits) 0
    set midi(midibpl) 1
    set midi(midibps) 4
    set midi(midippu) 2
    set midi(inline_voice) 1
    set midi(reformat_bars) 1
    set midi(startbar) 1
    set midi(midilden) 0
    set midi(midirest) 0
    
    # midishow
    set midi(midishow_sep) track
    set midi(midishow_follow) 1
    
    # grace notes
    set midi(grname1) cut
    set midi(grname2) strike
    set midi(grname3) mordent
    set midi(grname4) rmordent
    set midi(grname5) slide
    set midi(grname6) trill
    set midi(grseq1) "1"
    set midi(grseq2) "-1"
    set midi(grseq3) "0 1"
    set midi(grseq4) "0 -1"
    set midi(grseq5) "-3 -2 -1 0"
    set midi(grseq6) "0 1 0 1"
    
    #  for drumeditor.tcl
    set midi(selected_drums) ""
    set midi(dstrong) 110
    set midi(dmedium) 90
    set midi(dweak)  70
    
    #  for drumtool
    set midi(drumpatfile) drumpatterns.drum
    
    #  g2v
    set midi(g2v_clipboard) 0
    set midi(mode_guess) mse
    
    set midi(donotshow) 0
    set midi(index_by_position) 0
    set midi(moderef) nmodes.tab

    # drumroll
    set midi(playdrumdata) normaldrum    
    set midi(mutelev) 20
    set midi(mutefocus) 20
    set midi(mutenodrum) 0
    set midi(drumvelocity) 0
    set midi(drumloudness) 90

    set midi(live_editor) 0
    set midi(livehotspots) 0
    set midi(livescale) 0.85
    set midi(livesashorient) hor
    set midi(livesashvert) 420
    set midi(livesashhor) 630

    set midi(use_midi_header) 1
    set midi(use_ps_header) 1

    set midi(mftextunits) 2
    set midi(notegram) fifths

    set midi(attenuation) 20

    set midi(pgrammode) nochord
    set midi(pgramwidth) 500
    set midi(pgramheight) 350
    set midi(pgramthick) 2

}

# save all options, current abc file
proc write_runabc_ini {runabcpath} {
    global midi
    set outfile [file join $runabcpath runabc.ini]
    set handle [open $outfile w]
    #tk_messageBox -message "writing $outfile"  -type ok
    foreach item [lsort [array names midi]] {
        puts $handle "$item $midi($item)"
    }
    close $handle
}

# read all options
proc read_runabc_ini {runabcpath} {
    global midi df tocf
    set infile [file join $runabcpath runabc.ini]
    set handle [open $infile r]
    #tk_messageBox -message "reading $infile"  -type ok
    while {[gets $handle line] >= 0} {
        set error_return [catch {set n [llength $line]} error_out]
        if {$error_return} continue
        set contents ""
        set param [lindex $line 0]
        for {set i 1} {$i < $n} {incr i} {
            set contents [concat $contents [lindex $line $i]]
        }
        #if param is not already a member of the midi array (set by midi_init),
        #then we ignore it. This prevents midi array filling up with obsolete
        #parameters used in older versions of the program.
        set member [array names midi $param]
        if [llength $member] { set midi($param) $contents }
    }
    font configure $df -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)
    font configure $tocf -family $midi(font_family_toc) -size $midi(font_size) \
            -weight $midi(font_weight)
    if {$midi(livesashvert) < 100} {set midi(livesashvert) 100}
    if {$midi(livesashvert) > 650} {set midi(livesashvert) 650}
}

proc is_runabc_here {} {
    # return 1 if runabc.exe or runabc.tcl is in the
    # current directory
    if {[file exist runabc.tcl]} {return 1}
    if {[file exist runabc.exe]} {return 1}
    return 0
}


proc find_linux_executables {} {
global midi
set execlist "abc2midi abc2abc abcm2ps abcmatch midi2abc midicopy yaps gs"
foreach ex  $execlist {
  set cmd "exec which $ex"
  catch {eval $cmd} result
  if {[string first "abnormal" $result] > 0} {
    } else {
    set midi(path_$ex) $result
    }
  }
}



# init global variables
set types {{{abc files} {*.abc *.ABC}}
    {{all} {*}}}
set miditype {{{midi files} {*.mid *.MID *.midi *.kar *.KAR}}}
set exec_out "This window shows messages produced by play and display commands."


set install_folder [pwd]

set execpath [pwd]

if {[info exist env(RUNABCPATH)]} {
     set runabcpath [file join $env(RUNABCPATH) runabc_home]
     #puts "RUNABCPATH = $runabcpath"
     cd $env(RUNABCPATH)} else {
     # if no environment variable RUNABCPATH then
     set runabcpath [file join $env(HOME) runabc_home]} 
     if {[file exists $runabcpath]} {
     puts "folder $runabcpath exists"
     } else {
     file mkdir $runabcpath
     puts "created folder $runabcpath"
     cd $runabcpath
     set handle [open README.txt w]
     puts $handle "This folder is used by runabc to store\n
	    preferences and temporary data.\n\n\
	    You may delete this folder if runabc is not\
	    on your system."
    close $handle
    set nmodespath [file join $execpath nmodes.abc]
    if {[file exist $nmodespath]} {file copy $nmodespath $runabcpath}
    }

cd $runabcpath

midi_init
       
if {![file exists runabc.ini]} {
   if {$tcl_platform(platform) == "windows"} {
      set midi(dir_abcmidi) $install_folder
      set midi(path_abc2midi) [file join $install_folder abc2midi.exe]
      set midi(path_abc2abc) [file join $install_folder abc2abc.exe]
      set midi(path_abcm2ps) [file join $install_folder abcm2ps.exe]
      set midi(path_abcmatch) [file join $install_folder abcmatch.exe]
      set midi(path_midi2abc) [file join $install_folder midi2abc.exe]
      set midi(path_midicopy) [file join $install_folder midicopy.exe]
      set midi(path_yaps) [file join $install_folder yaps.exe]
      set midi(path_gs) ""
  } elseif {$tcl_platform(platform) == "unix"} {
      find_linux_executables  
       }
    
 
  } else {
      read_runabc_ini $runabcpath
      if {$midi(version) < 1.919} {
         set midi(path_gv) $midi(path_gs)
         set midi(path_gs) ""
         greetings "you need to set the path to ghostscript"}
      set midi(version) $runabc_version
  }

position_window "."

if {$midi(donotshow) == 0} check_integrity

# Part 3.0               images


#######################
#     Tk Interface    #
#######################

#The following images were obtained from http://wiki.tcl.tk/icons

image create photo kmidi-16 -data {
    R0lGODlhEAAQAIEAAPwCBAQCBPz+/Lz+/CH5BAEAAAAALAAAAAAQABAAAAIz
    hI+By7oBo5RH2GvDRRhre0xiVHXZVpqfEI5iKkQxalzQIIPGhI+pSAN4cjqA
    68VIHvwFACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41
    DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4N
    Cmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
}


image create photo misc-22 -data {
    R0lGODlhFgAWAIUAAAT+BMyaBMSSBPz+BMyWBPz6BPz2BMSOBLyKBLSCBPzm
    BPziBPzuBPzqBLyGBPzeBLR+BPzyBPzaBMySBPzWBLR6BLyCBPzSBKx6BKx2
    BPzOBKRyBKRuBMSKBKxyBJxmBKRqBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAa+
    QIBwSCwaj8SAAMkUCgaDZVMYCAwJBcNhiEgcA1ACQCAwaBGAhGLhLYKhTzOD
    0XAoHg/IkQAdGCIRdGsPEnpIE1mADQ2DeUxxf4ILeBQUFUZkZYoNFg6UFBcY
    GRlDT1kGc5xCBxKgGq8aG05+qIIOQhMUsLAcQwcdCJILZK6vHhy9RQ6Mk63F
    r8lHFgvNzxrRRmqElbu8R9oPFdYcsB9GFniXo9C9IK/mRhCXQh7QQx/wU/XX
    U0gcIP0CHjEQBAAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9u
    IDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2
    ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
}
image create photo exec-22 -data {
    R0lGODlhGAAYAIQAAPwCBISChAQCBAwubBw+fCRKhCxSjERmnFR2rFyCtGyW
    xISm1JS65KTO7JzC7BQ2dDRalExupGSKvHyezPz+9Pz+/FxaXKSipPz69Pz6
    7MTCxAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAYABgAAAXBICCOZGme
    aEoGbOu+sCAGw0AUhnEcSJIoisWCwWg4AjIA7XEzQA6RnkQxWVAEFSxyNmDi
    ntHENCgol7dKi3rNbrMvyYClQq9QMJQMJsPv9zVxFhl1hBR2d34ZgDNzhHQY
    FRiSdH6LaZB1kHiReYN/gY6RnHuUn4yDopp4e4mKoJmjmK2Wcqipq3wVibQW
    mJp3urqzgaiSq6Stroy+ornJymmDkneSz3y8j3aQns+0Gt/g4eLiSWbm5+jm
    Kuvs7SMGIQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIu
    NQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQu
    DQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
}
image create photo content-22 -data {
    R0lGODlhFgAWAIYAAAQCBAQiNPwCBCSW/Dye/BxefBQWJPz6/NzK/FxSZBSe
    /PT2/Pz2/Bya/Pz+/PTy/GRWbAxSbOS2/Ozi/GxadIxyzMSu/PTq/ASe9Ozu
    /MyW3GxafOzq/IRutHRejLSi/PTu/Aya5Ozm/IxyvNSy/GxehAyS1IxyrBSK
    xNzW/IxypOze/Pzy/HRenBSCrNTG/IRunPTm/AxujOTa/Oza/My2/IxunHxi
    pMSe/OTO/OTW/HxqrNSe/NzC/IRqjKR+5IRypIxyxIxy/LyO9MSS/IxylIxu
    9KSC/Lym/LSC9IxujMSW1JR2tLSO1KSCrIx6/JR23HxmhBRylBxunAQeLAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAIA
    LAAAAAAWABYAAAf/gAABAoSFhoeHAAMAiI2IAAQFjI6EAAaJkQeTjwAICYkK
    BQcLm5WdBwyfhgANBQ4OmoWnBwcPEAC4lQoRrw6kAgASE7QMBxQVFheMABiu
    B7AZABrCC68PG8gcEbjNz68ZHdMTD7QZHhUfINsAIc6wIiMaJOMLDw8l6Nq4
    JqK9EyfiQIDIAOLchwvrUIhiwABEChXTVoB4wIJDi3zrXBTgwOHChBcwpokQ
    EYODiIvJ1skosGIGDRo1bEybEYNkjBsYcRUogCOHjhwkZEoQsWKCiAk7sm0D
    JiMCjx4kePiIqGPCDyBBhHzQV6npEB5Eish7USOpkSNIEKjbBKBpkiFKO5ZI
    OMHkR9oLIC5wldW0SVwYTo48GUwYytJVTaP48CBlSuMpkCHLKNU1QoTJuDJr
    pkwoQAAqVCgRMhAIACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNp
    b24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNl
    cnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
}
image create photo help-22 -data {
    R0lGODlhFgAWAIUAAPwCBHx6BPz6vPTutKSidJSKLPz6BPz+BMzKjMS6vJya
    XMTCpOzqBLSqlNTOVPzyFLy2DGxqBBQOBOzqLMzKBKSiBLy6BOTaBAQCBJya
    BExKBMzCBFxaBMS+BHRqBLSudKyqBNTOBIyGBLy2jDw+BJSSNNzaBERCNBQW
    BCQeBFRSTFxaRERGHFxeXJySLLSypKSeNIyKjAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAa6
    QIBwKAwYj0aicmgUOJ0DAiGwJAYKhkN2i0goqNWAYmEomw2MxRdsbTgejLP5
    AYlIlgHHpEypBCwXZQwWERh4DHEGGRoYERtmhIZKAYmKjBgZgpF4GJ2dQhwd
    kB6SVUQfIBdxISIabKYAIwFnIiQasEMlIGgGJgF3uLm7Zb7AwQAFwwzFx0K6
    DFoXv80AJygp2CgSKtQAKyTgLC3dAB8i5y4v3bpmzM3saO7HHzAZGRWt3NQx
    np9LBkEAACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41
    DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4N
    Cmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
}
image create photo print-22 -data {
    R0lGODlhGAAYAIYAAPwCBIx+bIR2ZHxuZHRqXGReVFxWVFRWVPz6/PTy7Ozm
    5NzW1MS+tOzq5Ozu5Ozm3MTCxGRiZOzq3PTu7OTi3NzWzGRmZNzSxOzi1OTe
    1FxaXExKRNTKvMzCtMS2rKSelFRSVGxiXPTu5OTezNTCrLSunIR+fHRydOze
    zOTazOTWxOTWvNTKtERGRHx6fHx+fLS2tNTW1DxWdAwOPMTGxLy6vMS6tLy2
    rDxSbMTGzERefDRCXERifFRaXExqjDRKZDRCZExKXMzKzLy+vHx6hHyavIyi
    tJSitJSmtJyqtGxudFRSTKyqrIyKjJSWlJyanHyyjFyqNIyOjHTeVLTydDw2
    NDQ2NCQmJCQqLCwuLEw+NGymfLSupLSmlJyGfLyqlBwaHOzexOzaxNzOtFRO
    RNzKrDw6NOTSvOTStNzKtDQuLDQyLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
    LAAAAAAYABgAAAf/gACCg4SFhoeCAQICAwQFBQYHiIcBCAkJCgsMBA2Sk4SV
    lw4PEBEPEp6fAAKXCRMUFRYXGKiqAAOXExISGRobBxGpkwQTEw27DxwdHh8g
    tiEOIsgYIxckJcKEJicFBwUPFOAjKCkqKywHLd4ugy8wMTIzBTQ1NvYMDDU3
    HwczODEwTAgyUSOHjhkzdihcyBAhD3ovBJ2gx6OHDx04fiwE8uMHDx9BeNSo
    cUJQBCFDiJwoUsTIESRJYh45YqSIkomlBC2BUINJkxMRIlgISjToiSYlaghZ
    IqiFkydOnkqFSnUqlChNWjRt0sRJEylduXr9KmXsFComtAKoYsKEiw1Wca7I
    xSI3i1y5WrZMsWBFUJYgQa9k0celBJcuHxB3sdsjQosrgwTHbZHiAAQXBjx4
    EUDgywYwcSEf0oDhwbgwI8SsGOPBgK0NGAIc0DyAjBcCZdR+MmPuzBg0Y9KU
    KUOiii01a7KoUZ5FOXI1tqIXkhEIACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYg
    UHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJp
    Z2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
}
image create photo config-22 -data {
    R0lGODlhFgAWAIQAAPwCBAQCBISChFxaXNze3NTS1Ly6vKSipNTO1Ly2vNza
    3Pz+/MzOzOTe5DQyNOzu7MTCxGRmZMTGxPTy9Ozm7Hx6fPTu9MzGzGxmbAAA
    AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAW1ICCOZGme
    aEoGbBsI6joMRGEcbQwESDIrtVtAF1gwDLNaAmfKiVgLBJKgwB1KxQZrBHU0
    FAXmavFoQLYiB6TxFXMj5AZBwnJI2I3wcNWALyYEcgoKXxRhOHs7XxEVCwsW
    FgoUDRYUFwwQB25ZCxiNjo6GkwUXN2NsCxEYqhUHoQ0MEglYRQQXErcHrI55
    FycuB2YSmoyOBTEtB2sXuhU6XAENC2a6z9AKCwq+1tAN3E2J3ySkIQAh/mhD
    cmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENv
    ciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3
    LmRldmVsY29yLmNvbQA7
}
image create photo edit-22 -data {
    R0lGODlhFgAWAIYAAAT+BIxSLPyuXFRShPzqrPz+/PT6/PT2/Oz2/Ozy/MzK
    /OSaVPyWNPz6/OTu/IxeNPzavPyKBNzq/PyCBPyGBOTq/JxmNPzOpLx6PNRq
    BMSCRNySTPyCDPSGBMxiBKROBOTy/PS2lOyydMxmBJxKBAwODPzevPzm1Oya
    bNzm/Pzy5PTGrOyOXPR+DJxGBPzmzNxuPORqLMReFNTm/Pzq1PSylMyCXKxi
    NIRKHPzixJRaPFxONMTW/MyCZCwqJDQyLLzW9NTi/HRmTLSKbHROPFxKPMTa
    /LzW/LTO9MyuhEQuJFRSVLzS9DQyNFRGNLTS9AAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
    LAAAAAAWABYAAAf/gACCg4SFhQEChAOLjI2Lg4gEigUGlQcICAkJAwoDAAEL
    BAyTDQ0GBwcJCA4DDgoPCxAMEYqWl5oJrBKwshMUtaiZmg4VAxYLFwy+tIMD
    mLgO0RIYyAwU1xmKqbnRDhIaG8kcFB0eH4ogCSDRFRIhIsnXFCMkJYoJFezu
    Jico4+X1CrUiJkFCigsqVrBowWGEC3sCCaZIEeIFBBQwYsh46ElghRkFZ1yg
    UcPGjQA4SnQyNODjxxo5SuoIsKMEj5UCZ+gUuaKHjh0+fvAAglORziBChtgg
    UuSHER5HkBRtZmRGEiE+lCwxYgQIECZHpgoaMMMI1iZDnn6NKrWjIq5OHtIa
    YQIEyZEnSNqyVMC3r1+/bps5GtzIkOHDgwwEAgAh/mhDcmVhdGVkIGJ5IEJN
    UFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTgu
    IEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNv
    bQA7
}
image create photo exit-22 -data {
    R0lGODlhFgAWAIQAAPwCBMyaBPz6BPz+BMyWBMSSBPzyBPz2BMSOBPzuBPzq
    BMSKBLyKBPziBLyCBPzmBPzeBLyGBLSCBPzWBPzaBPzSBLR6BLR+BKxyBKx6
    BKx2BAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAW7ICCOZGme
    Y6AGaAsEwsC6aToIM0C08Bzcs4KgcPoNZK+BgVU4HAwIk9F3SBABBQO09MPN
    CAbFFbAwJBgkGFJUUDTGi0TCkRIIDrnCA7IYRRIKChIiAU47IwUQE30jDgoP
    gy9OY2QUFREkDg8PFiIETgZwDBGYIhcPDQ2dbGZRLRcNDxgkBXKMKBYNEBkl
    cQqkdCMWwxAQGicRgZsXzBbFxccoEbGpqc8Usy7Mutca2TQAwxre3+Dm5y4G
    IQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBE
    ZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRw
    Oi8vd3d3LmRldmVsY29yLmNvbQA7
}
image create photo kmix-16 -data {
    R0lGODlhEAAQAIMAAPwCBJxmBNSeBHx+fPz+JLy+vPz+RPz+/Pz+VPz+bPz+
    fPz+hPz+nAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARXEMgJQqCYihFG
    xgIRFMU3CcYwFIcnuZKAIOPRvqeQ7PUNywnFQmGxwWKIxIKxGAVumqSQyPGp
    OJtdogilWGQ0VhcTQPU8x0lZZcRlyqMCLC2B0z+Wjz8CACH+aENyZWF0ZWQg
    YnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcs
    MTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxj
    b3IuY29tADs=
}
image create photo settings-22 -data {
    R0lGODlhFgAWAIMAAASC/JRmBPz+lPzKBAQCBHx+fPz+/Ly+vPyWBJQCBPzK
    ZPwCZMyWBAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAR3EMhJq7040wAC
    11YgiAMBbkJJpObZCa1IFEBh25csyUZxGEBDazMYiQIEw2GpXA4ngeKIQDhQ
    fQXqEypAmKiSamu7Y1USCjLKe16ouaX2u8ymJNwa0vY+f9UnfHlmdngZIn8S
    gYaDgIUYAQwMewl9AGAVWi6adhEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQ
    cm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmln
    aHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
}
image create photo fileopen-16 -data {
    R0lGODlhEAAQAIMAAPwCBASCBMyaBPzynPz6nJxmBPzunPz2nPz+nPzSBPzq
    nPzmnPzinPzenAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARTEMhJq724hp1n
    8MDXeaJgYtsnDANhvkJRCcZxEEiOJDIlKLWDbtebCBaGGmwZEzCQKxxCSgQ4
    Gb/BbciTCBpOoFbX9X6fChYhUZYU3vB4cXTxRwAAIf5oQ3JlYXRlZCBieSBC
    TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
    LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
    b20AOw==
}

image create photo find-22 -data {
    R0lGODlhFgAWAIYAAPwCBBQSFJSWlFxaXJyanKy2tLzCxDw+PHyChNTa3Nzq
    7Nz29NTy9Mzu9OT29Nzi5Oz6/Mzy9Kzi7Jze5Lze5Nzy9JyenIyKjHR2dMTu
    9Kzm7JzW3ITW3ISChGxubERGROz+/Lzq9IzW5HzK1LTm7FRSVHTS3GS+zLTS
    1DQ2NMzOzMTq7Lzq7ITW5FS2vMTi5ExOTKTm7EzCzEy2vEyutJTa5FTK1ESi
    rGy+zMzi5ESerESmtITa5OTy9KTe5KyqrAz+/Azi3ASutERCRExKTFRWVAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
    LAAAAAAWABYAAAf/gACCggGFhYOIAAIDiYUEBQYFAoeJAweKhAgJCgsLDA0O
    CAGJg4wBCA8QDhENEhMUFaKDFhcYgwEJCxAQDBkaGxwSFaMAFh0eAx8AAQIK
    ECAODCEaIiMjJJMAtQMlygEGEBkVva4mJycTKKMYJd0pyyoOKyssGhMtIycu
    Gi/EMB/vlhmoQEFDjHsmZMygUUMdqWUCGgCbYMKEjRk3cEjI9jBADg3Wzs3Q
    sYOHA2IdO1SQkI/GjRMtFhBA2RFBDwk+OASrMPMHkIe3AhBA8QLFzAAHgvyg
    2dEQMSEHPCwltQgooSFSmVpSxKjjh6wPtwINgHVqsVpWESEFeywZ17RkED2s
    40YEgFirlIq4SwvUQCAAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVy
    c2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJl
    c2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
}

image create photo spellcheck-16 -data {R0lGODlhEAAQAIMAAPwCBAQCB
OTi5MT+fHTiBKz+RFyqBER+BCxSBFSmBHziBHzmBJT+FAAAAAAAAAAAACH5BAEAAA
AALAAAAAAQABAAAARKEMhJqwwY4CAuvx33iWGpCSPaTZuImWyZfvE5m/PrdYPlAwO
Cr1AJGiwFwmFiRFQQCYUSkDQ4LdAFgUGw/gBQqfcLTozJ4OvEHwEAIf5oQ3JlYXRl
ZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxO
Tk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
}

image create photo filesave22 -data {
   R0lGODlhFgAWAIUAAPwCBGxqbAQCBLy+vERCRExKTHRydIyKjMTCxFxaXGRi
   ZFRSVFRWVPz6/Nze3Nzm5Pz+/JyanDw+PExOTHR2dMTGxBQWFLSytHx+fISC
   hOzy9Ly6vAQGBJSWlMzKzAwODJSSlHx6fIyOjOTi5DQ2NISGhGxubCwuLOzq
   7ERGRFxeXNTW1CwqLPT29Dw6PGRmZKSmpAAAAAAAAAAAAAAAAAAAAAAAAAAA
   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAb/
   QIBQGBAMj8ikUDAgFAzKKCBwQCQUCcICKh0SEAhGw5EIZAmBrgCxeDQgcDJW
   yz0GIggJfL+XGwQJRxNgC3yGDwwUFUZDFhdthnwMGAZNQwEZFwQakXANBBQb
   HIIdERIBnRAOiR4ERx8gsSEMBBmGCyEGG3YGBwcgIr8UCwQHECOgG4xCtRkE
   JAvBJRklJgkSFBQeJ68hJiEoESkFKiEZIbkGARsLlwEGExENGhorGSkpFAYm
   66NDLAECpGiBYsUIFA8wLHBBQMWLVkdUCFCwaYVFBOymkVCgYEMgOykEpICB
   ccMBAhhELFigTEqAAgIIwCiQ4eRKDyS6EAlJIAI0EpaudF4iIKDAAn9CkRT5
   eMROEAAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
   qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
   dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
}

image create photo netscape -data {
R0lGODlhEAAQAIYAAPwCBFxaXNTW1Nze3Ly2rJyanPz+/Ozq7GxubPz6/OTi1Ozq3GxiTMzOzCwuLMSijGROLLSqjGRiZOze1LSOdIyKjEw+NHxGJNSqjMTGxPTy7Ozm1NzWxLSSfFw+LMzKvHRuVKyeZHxybOTazOTi3Ly2tDQyNOzm3MS6jFxaRPTu5LyulOzi1KSehMTCxKSOdHxuRMzCpJSGXOTStLyqlHRqRIR2TFRKLLyedLyqdGxWLIR6XOzezJyCZJySbEQqHKyKdFRONJSKfOzaxNTCpKSWbJSSjExKNHxuNOzWvLymhIyKhOTOpHRydHx6bIR+dOTOrLyidAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAfVgACCAAGFhoaDiQECA40CBAEFAYmCAQMGmAYHCAmSlAEKCwyZCA2dDoIPEIsREgkTFBUICBaoABcYGRobHAodHhkDBBW2AB8fIBwMESEiIxokJSaDJxAUKAwQESkaKicrqBssLS4vBzAfMTIRMwo00zU2LTc4OToQOzU3DDwr04Ixeljw8QNIiCBCYgyJUIxIESMfjuxAwoDDkCRK/j244CNHjhBIPDxYMoPJA1sXIDRxkuOIkycXHsyAEqUYoRk7GDAh8uJFDhw4/lUy4aCo0aJE/QQCACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
}



# Part 4.0   Control Buttons


###     Control Functions    ######

set tunenote ""
global tunenote
global sel

frame .abc
frame .abc.file
frame .abc.functions -borderwidth $midi(butborder)
frame .abc.titles

# file entry and button
if {[info exists abc_open]} {set midi(abc_open) $abc_open}
entry .abc.file.entry -width 62 -relief sunken -textvariable midi(abc_open) \
        -font $df
bind .abc.file.entry <KeyRelease> {
    if {[file exists $midi(abc_open)] && [file isfile $midi(abc_open)]} {
        load_whole_file $midi(abc_open)
        title_index $midi(abc_open)
        focus .abc.titles
       }
}

set w .abc.file.menu
menubutton .abc.file.menu -text file -image fileopen-16 -relief raised  -menu $w.type -font $df
menu $w.type -tearoff 0
$w.type add radiobutton  -label "browse" -command file_browser  -font $df
$w.type add radiobutton  -label "clear recent" -command delete_history  -font $df

for {set i 0} {$i < $midi(history_length)} {incr i} {
    $w.type add radiobutton  -label $midi(history$i) \
            -value $i -variable history_index -command process_history -font $df
}
pack .abc.file.menu -side left  -fill x
pack .abc.file.entry -side left  -fill x
pack .abc.file -side top -fill x

# first row of buttons
button .abc.functions.quit -text exit -image exit-22 \
        -command {confirm_save; write_runabc_ini $runabcpath; exit}\
        -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
button .abc.functions.play -text play -font $df -image kmix-16  -command play_action -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
button .abc.functions.disp -text display -font $df -image print-22 -command display_action -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
button .abc.functions.live -text live -borderwidth $midi(butborder) -relief $midi(butrelief)  -bg $midi(butbg) -font $df -image netscape \
-command {set midi(live_editor) [expr 1 - $midi(live_editor)]
	 switch_live_editor}
# suppress calling firefox if right button pressed
bind .abc.functions.disp <Button-3> {display_action 0} 

set w .abc.functions.editmenu
menubutton $w -text edit -font $df -image edit-22 -menu $w.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add command -label "edit file" -command  {
    . config -cursor watch
    update
    abc_edit midi(abc_open)
    set abc_file_mod 1
    . config -cursor arrow
    update}  -font $df
$w.type add command  -label "edit selection" -command  {
    set outfile [extract_title_of_first_tune [title_selected] $midi(abc_open)]
    set outfile [file join $midi(abc_work_folder) $outfile.abc]
    copy_selection_to_file [title_selected] $midi(abc_open) $midi(abc_default_file)
    file mkdir "[pwd]/$midi(abc_work_folder)"
    file rename -force $midi(abc_default_file) $outfile
    abc_edit outfile
} -font $df
$w.type add command  -label "TclAbcEditor"\
        -command {startup_tcl_abc_edit 1} -font $df
$w.type add command -label "TclMultiVoiceEditor"\
        -command {startup_tcl_abc_edit 0} -font $df

$w.type add command -label "new tune"       -command edit_new_tune -font $df
$w.type add command -label "new file"       -command edit_empty_file -font $df


set w .abc.functions.utilmenu
menubutton $w -text edit -font $df -image misc-22  -menu $w.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add command -label "abc2abc"        -command show_abc2abc_page -font $df
$w.type add command -label "gchords/drums to voice" -command g2v_startup -font $df
$w.type add command -label "reformat"   -command show_reformat_page -font $df
$w.type add command -label "extract part"   -command show_extract_page -font $df
$w.type add command -label "drum tool"    -command {drumtool_gui_setup} -font $df
$w.type add command -label "pitch histogram" -command {note_histogram} -font $df
$w.type add command -label "pitch interval histogram" -command {note_interval_histogram} -font $df
$w.type add command -label "save midi file(s)" -command midisave -font $df
$w.type add command -label "save sheet music as ps" -command postscriptsave -font $df
$w.type add command -label "save sheet music as pdf" -command pdfsave -font $df
$w.type add command -label "split abc file" -command split_abc_tool  -font $df
$w.type add command -label "copy incipits" -command show_incipits_page -font $df
$w.type add cascade -label "copy to file" -menu $w.type.copy -font $df
menu $w.type.copy -tearoff 0
$w.type.copy add command -label "copy" -font $df \
        -command {start_copy_selected_files w 0}
$w.type.copy add command -label "copy and renumber" -font $df \
        -command {start_copy_selected_files w 1}
$w.type.copy add command -label "copy all" -font $df \
        -command copy_all_and_renumber
$w.type.copy add command -label "append" -font $df \
        -command {start_copy_selected_files a 0}
$w.type.copy add command -label "append and renumber" -font $df \
        -command {start_copy_selected_files a 1}
$w.type.copy add command -label "merge abc files" -font $df \
        -command {merge_abc_files}
$w.type.copy add command -label "combine parts" -font $df \
        -command {combine_parts}
$w.type.copy add command -label help -font $df \
        -command {show_message_page $hlp_copy word}
$w.type add command -label "help" -command {show_message_page $hlp_utils word} -font $df

set hlp_utils "Abc Utilities\n\n\
abc2abc: most commonly it is used to transpose the abc notation to another\
key; however there are many other abc2abc functions available\n\n\
gchords/drums to voice: the guitar chord indications are used to create\
a separate voice in the abc notation. Similarly, the %%MIDI drum command\
can also be expanded into a separate voice.\n\n\
reformat: changes the way the abc notation is presented. You can change\
the number of bars in a text line or in a music staff. You can interleave\
the voices and etc.\n\n\
extract part: uses abc2abc to extract a particular voice from a multivoiced\
abc tune.\n\n\
drumtool: a tool for creating drum riffs to insert in your abc tune.\n\n\
pitch histogram: plots the histogram of the pitch classes in the abc\
tune and guesses the key and mode from the histogram.\n\n\
pitch interval histogram: plots the histogram of the pitch intervals\
between adjacent notes.\n\n\
save midi files(s): creates and saves the midi files of the selected tunes.\n\n\
save sheet music as ps: creates and saves the sheet music as a PostScript file.\n\n\
save sheet music as pdf: creates and saves the sheet music as a pdf file.\n\n\
'split abc file' splits a multitune\ abc file into separate files each\
containing one tune and puts the files into a selected directory.\
The file names can be derived from the X reference number or the title.\n\n\
copy incipits: creates a new abc file with only the first n bars of each\
tune.\n\n\
copy: see its separate help file in the cascaded menu.\n

"

tooltip::tooltip $w.type.copy -index 0  "copy selected tunes to an abc file"
tooltip::tooltip $w.type.copy -index 1  "copy selected tunes to an abc file\n and renumber X reference numbers"
tooltip::tooltip $w.type.copy -index 2  "copy all tunes to an abc file\n and renumber X reference numbers"
tooltip::tooltip $w.type.copy -index 3  "append selected tunes to an abc file"
tooltip::tooltip $w.type.copy -index 4  "append selected tunes to an abc file\n and renumber X reference numbers"
tooltip::tooltip $w.type.copy -index 5  "combine all abc files found in a folder\nand save to a single file"
tooltip::tooltip $w.type.copy -index 6  "split a multi-tune abc file into separate files\ncontaining one tune each and save in a folder"
tooltip::tooltip $w.type.copy -index 7  "click help button below"

menubutton .abc.functions.internals -text internals -image exec-22 -menu .abc.functions.internals.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu .abc.functions.internals.type -tearoff 0
.abc.functions.internals.type add command -label "messages" -command {show_console_page $exec_out char} -font $df -accelerator "ctrl-m"
.abc.functions.internals.type add command -label "processed tune" -command {show_processed_tune} -font $df
.abc.functions.internals.type add command -label "bar line alignment" -command {show_bar_line_alignment} -font $df
.abc.functions.internals.type add command -label "contents of runabc_home" -command dirhome -font $df -accelerator "ctrl-h"
.abc.functions.internals.type add command -label "mftext of output midi file (beats)" -font $df -command {set midi(mftextunits) 2
			  mftextwindow $midioutput 0} 
.abc.functions.internals.type add command -label "mftext of output midi file (pulses)" -font $df -command {set midi(mftextunits) 3
			  mftextwindow $midioutput 0} 
.abc.functions.internals.type add command -label "view X.tmp"     -command show_tmpfile -font $df
.abc.functions.internals.type add command -label "save X.tmp as an abc file" -command save_tmpfile -font $df
.abc.functions.internals.type add command -label "help" -font $df \
       -command {show_message_page $hlp_internals word}




menubutton .abc.functions.search -text search -image find-22 -menu .abc.functions.search.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu .abc.functions.search.type -tearoff 0
.abc.functions.search.type add command -label "find title" -font $df  -command {find_window}
.abc.functions.search.type add command -label "find bars"  -font $df  -command {match_window bars}
.abc.functions.search.type add command -label "match tune"  -font $df  -command {match_window tune}
.abc.functions.search.type add command -label "grouper"    -font $df  -command grouper_window
.abc.functions.search.type add command -label "histogram matcher"    -font $df \
-command Matcher::match_histogram_correlation


menubutton .abc.functions.midi -text midimenu -image kmidi-16  -width 24 -menu .abc.functions.midi.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu .abc.functions.midi.type -tearoff 0
.abc.functions.midi.type add command -label "midisummary"   -font $df  -command make_midi_summary
.abc.functions.midi.type add command -label "midi2abc"   -font $df  -command show_midi2abc_page
.abc.functions.midi.type add command -label "midistructure"   -font $df  -command midi_structure_window
.abc.functions.midi.type add command -label "pianoroll"   -font $df  -command {piano_window $midi(midifilein)}
.abc.functions.midi.type add command -label "drum events" -font $df -command drumroll_window
.abc.functions.midi.type add command -label "mftext by beats" -font $df  -command {
   set midi(mftextunits) 2
   mftextwindow $midi(midifilein) 0}
.abc.functions.midi.type add command -label "mftext by pulses" -font $df  -command {
   set midi(mftextunits) 3
   mftextwindow $midi(midifilein) 0}

# second row of buttons
button .abc.functions.toc -text toc -image content-22 -command show_titles_page -borderwidth $midi(butborder) -relief $midi(butrelief)  -bg $midi(butbg) -font $df
set w .abc.functions.playopt
menubutton $w -text "play options" -image settings-22 -font $df -menu $w.type -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add checkbutton -label "use midi header" -font $df -variable midi(use_midi_header)
$w.type add checkbutton -label "override tempo" -font $df -variable midi(ignoreQ) -command disable_enable_tempo_controller
$w.type add command  -label transposition/tuning  -command {show_midi_page 1} -font $df
$w.type add command  -label arrangement  -command {show_midi_page 2} -font $df
$w.type add command  -label "advanced settings" -command {show_midi_page 8} -font $df
$w.type add command  -label  drumkit     -command drum_editor -font $df
$w.type add command  -label voices       -command show_voice_page  -font $df
$w.type add command  -label "random voice arrangement"  -command random_voice_arrangement  -font $df
$w.type add command  -label help -command {show_message_page $hlp_playopt word} -font $df


set w .abc.functions.yaps
menubutton $w  -text "yaps opts" -menu $w.type -font $df -pady 6 -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add checkbutton  -label "use ps header" -font $df -variable midi(use_ps_header)
$w.type add command -label options -command {show_ps_page yaps} -font $df
$w.type add cascade -label "ps converter" -menu $w.type.selector -font $df
menu $w.type.selector -tearoff 0
$w.type.selector add radiobutton -label abcm2ps  -variable midi(ps_creator) \
        -value abcm2ps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label abc2svg  -variable midi(ps_creator) \
        -value abc2svg  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label other  -variable midi(ps_creator) \
        -value other -font $df -command switch_ps_button


set w .abc.functions.abc2svg
menubutton $w  -text "abc2svg" -menu $w.type -font $df -pady 6 -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add checkbutton  -label "use ps header" -font $df -variable midi(use_ps_header)
$w.type add command -label "create format file" -font $df \
  -command setup_m2ps
$w.type add command -label options -command {show_ps_page abc2svg} -font $df
$w.type add cascade -label "ps converter" -menu $w.type.selector -font $df
menu $w.type.selector -tearoff 0
$w.type.selector add radiobutton -label abcm2ps  -variable midi(ps_creator) \
        -value abcm2ps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label yaps  -variable midi(ps_creator) \
        -value yaps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label other  -variable midi(ps_creator) \
        -value other -font $df -command switch_ps_button

set w .abc.functions.abc2ps
menubutton $w   -text "abc2ps options" -menu $w.type -font $df -pady 6 -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add checkbutton  -label "use ps header" -font $df -variable midi(use_ps_header)
$w.type add command -label "boolean command options"  -command {show_ps_page m2psbool} -font $df
$w.type add command -label "numeric command options" -command {show_ps_page m2psfloat}  -font $df
$w.type add command -label "create format data" -font $df \
  -command setup_m2ps
$w.type add cascade -label "ps converter" -menu $w.type.selector -font $df

menu $w.type.selector -tearoff 1
$w.type.selector add radiobutton -label yaps  -variable midi(ps_creator) \
        -value yaps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label other  -variable midi(ps_creator) \
        -value other -font $df -command switch_ps_button
$w.type.selector add radiobutton -label abc2svg -variable midi(ps_creator) \
        -value abc2svg -font $df -command switch_ps_button



set w .abc.functions.otherps
menubutton $w   -text "other ps" -menu $w.type -font $df -pady 6 -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add checkbutton  -label "use ps header" -font $df -variable midi(use_ps_header)
$w.type add  radiobutton -label "options" -font $df  -command show_other_ps
$w.type add cascade -label "ps converter" -menu $w.type.selector -font $df
menu $w.type.selector -tearoff 0
$w.type.selector add radiobutton -label abcm2ps  -variable midi(ps_creator) \
        -value abcm2ps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label yaps  -variable midi(ps_creator) \
        -value yaps  -font $df -command switch_ps_button
$w.type.selector add radiobutton -label abc2svg -variable midi(ps_creator) \
        -value abc2svg -font $df -command switch_ps_button


set w .abc.functions.cfg
menubutton $w -image config-22 -text cfg -menu $w.type -font $df -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
menu $w.type -tearoff 0
$w.type add command  -label "abc executables" -command {show_config_page 1} -font $df
$w.type add command  -label "check integrity" -command check_integrity -font $df
$w.type add command  -label "sanity check"    -command {runabc_diagnostic}  -font $df
$w.type add command  -label "midi player"     -command {show_config_page 2} -font $df
$w.type add command  -label "font selector"   -command {show_config_page 4} -font $df
$w.type add command -label "character encoding" -command {show_config_page 5} -font $df
$w.type add command -label  "button style" -command {show_config_page 6} -font $df
$w.type add checkbutton -label "remember locations of windows" -font $df\
 -variable midi(autoposition)
$w.type add checkbutton  -label "use ps header" -font $df -variable midi(use_ps_header)
$w.type add checkbutton -label "index by position" -variable midi(index_by_position) -font $df
$w.type add checkbutton -label "ignore blank lines" -variable midi(blank_lines)  -font $df
$w.type add checkbutton -label "bell on file write" -variable midi(bell_on)  -font $df
$w.type add checkbutton -label "no confirm for unsaved file" -variable midi(noconfirmsave)  -font $df
$w.type add checkbutton -label "reveal button labels" -variable midi(buttonlabels) -command button_label_action -font $df
$w.type add command  -label "load runabc extension"    -command {load_extension}  -font $df
$w.type add checkbutton -label "help" -font $df -command {show_message_page $hlp_cfg word}

if {$tcl_platform(platform) == "windows"} {
    $w.type add command  -label "Register .abc files" -command associate_abc -font $df}

button .abc.functions.help -image help-22 -text help -command contexthelp -font $df -borderwidth $midi(butborder) -relief $midi(butrelief)  -bg $midi(butbg)


tooltip::tooltip .abc.functions.toc  "TOC"
tooltip::tooltip .abc.functions.editmenu "Edit menu"
tooltip::tooltip .abc.functions.utilmenu "Utilities"
tooltip::tooltip .abc.functions.play  "Play selection"
tooltip::tooltip .abc.functions.playopt "Play Option Menu"
tooltip::tooltip .abc.functions.disp  "Display"
tooltip::tooltip .abc.functions.live "Live Editor"
tooltip::tooltip .abc.functions.internals "Internals"
tooltip::tooltip .abc.functions.midi "Midi Menu"
tooltip::tooltip .abc.functions.search "Search Menu"
tooltip::tooltip .abc.functions.cfg   "Options"
tooltip::tooltip .abc.functions.help  "Help"
tooltip::tooltip .abc.functions.quit  "Quit"

pack .abc.functions.toc .abc.functions.editmenu \
        .abc.functions.utilmenu .abc.functions.play .abc.functions.playopt \
    -side left -fill y
if {$midi(ps_creator) == "yaps"} {
    pack .abc.functions.yaps -side left -fill y
} else {
    pack .abc.functions.abc2ps -side left -fill y
    if {$midi(ps_creator) == "abcm2ps"} {
        .abc.functions.abc2ps configure -text abcm2ps}
}
pack .abc.functions.disp .abc.functions.live .abc.functions.internals .abc.functions.search .abc.functions.midi -side left -fill y
pack .abc.functions.cfg -side left -fill y
pack .abc.functions.help -side left -fill y
pack .abc.functions.quit -side left -fill y

pack .abc.functions -side top

set beatlist {1/4 1/2 3/8 1/8}
set w .abc.titles.sliders
frame $w
label $w.tempolab -text "tempo" -font $df
label $w.tempolab1 -text " for "  -width 5 -font $df
label $w.tempolab2 -text " note "  -width 5 -font $df
scale $w.tempo -from 0 -to 480 -length 240 \
        -width 10 -orient horizontal  -showvalue true -troughcolor darkred\
        -variable midi(tempo)   -font $df
ttk::combobox $w.beatsize -width 4 -height 7 -textvariable midi(beatsize)\
        -font $df -values $beatlist
pack $w.tempolab $w.tempo $w.tempolab1 $w.beatsize $w.tempolab2  -side left -fill y
pack $w -side top

frame .abc.titles.notes -borderwidth 3
button .abc.titles.notes.but -text "" -font $df\
        -background lightyellow -command {Refactor::header_window}  -borderwidth 3 -relief raised
tooltip::tooltip .abc.titles.notes.but  "Reveal field commands"
pack .abc.titles.notes.but -fill x
pack .abc.titles.notes -fill x

proc configure_buttons {} {
global midi
set buttonlist {play disp live editmenu utilmenu internals search midi toc playopt yaps abc2ps otherps cfg help quit}
foreach but $buttonlist {
   .abc.functions.$but configure -borderwidth $midi(butborder) -relief $midi(butrelief) -bg $midi(butbg)
   }
}

bind . <Control-m> {show_console_page $exec_out word}
bind . <Control-h> dirhome


# Part 5.0          TOC

###    Table of Contents  - title index   ###
#puts [ttk::style element names]
ttk::style configure Treeview.Heading -font $df
ttk::style configure Treeview -background azure2
ttk::treeview .abc.titles.t -columns {refno key meter title}  -height 15\
        -show headings  \
        -selectmode extended -yscrollcommand {.abc.titles.ysbar set}
#puts [.abc.titles.t configure]
foreach col {refno key meter}  name {refnumb keysignature meter}  {
    .abc.titles.t heading $col -text $col
    .abc.titles.t heading $col -command [list SortBy $col 0]
    .abc.titles.t column $col -width [expr [font measure $df $name] +3]
}
.abc.titles.t heading title -text title
.abc.titles.t heading title -command [list SortBy title 0]
.abc.titles.t column title -width [font measure $df "WWWWWWWWWWWWWWWWWWWWWWWW"]

bind .abc.titles.t <<TreeviewSelect>> {extract_tune_info}

scrollbar .abc.titles.ysbar -bd 2 -command {.abc.titles.t yview}
pack .abc.titles.ysbar -side right -fill y
pack .abc.titles.t  -expand y -fill both
pack .abc           -expand y -fill both
focus .abc.titles.t


global ps_numb_start
menu .actionmenu
.actionmenu add command -label play -command {play_action}
.actionmenu add command -label display -command {set ps_numb_start 0
    display_action}
.actionmenu add command -label summary -command {Refactor::header_window}


bind .abc.titles.t <Button-3> {
    .abc.titles.t selection set {}
    .abc.titles.t selection set [.abc.titles.t identify row %x %y]
    set i [.abc.titles.t selection]
    tk_popup .actionmenu %X %Y
}

if {[winfo exists .msg] != 0} {raise .msg .abc}

#####  Bindings  #####
bind . <Next>  { .abc.titles.t yview scroll +1 page }
bind . <Prior> { .abc.titles.t yview scroll -1 page }
bind . <Down>  { .abc.titles.t yview scroll +1 units }
bind . <Up>    { .abc.titles.t yview scroll -1 units }

bind .abc.titles.t  <d>   { if {$active_sheet == "titles"} {display_action}}
bind .abc.titles.t  <p>   { if {$active_sheet == "titles"} {play_action}}
bind .abc.titles.t <space> { if {$active_sheet == "titles"} {play_action}}
bind .abc.titles.t <E>  {if {$active_sheet == "titles"} {
        abc_edit midi(abc_open)
        set abc_file_mod 1
    }}
bind .abc.titles.t <e> {if {$active_sheet == "titles"} {startup_tcl_abc_edit 1}}


proc startup_progress {message} {
    wm title . $message
    update
}

proc button_label_action {} {
    global midi
    if {$midi(buttonlabels)} {
        show_button_labels top
    } else {show_button_labels none}
}

proc show_button_labels {loc} {
    .abc.file.menu configure -compound $loc
    .abc.functions.quit configure -compound $loc
    .abc.functions.play configure -compound $loc
    .abc.functions.disp configure -compound $loc
    .abc.functions.editmenu configure -compound $loc
    .abc.functions.internals configure -compound $loc
    .abc.functions.toc configure -compound $loc
    .abc.functions.playopt configure -compound $loc
    .abc.functions.midi configure -compound $loc
    .abc.functions.otherps configure -compound $loc
    .abc.functions.cfg configure -compound $loc
    .abc.functions.help configure -compound $loc
    .abc.functions.utilmenu configure -compound $loc
    .abc.functions.search configure -compound $loc
}


startup_progress "loading core functions"
button_label_action


# Part 6.0	Core Functions

proc show_error_message {text} {
    global df
    set p .error_msg
    if [winfo exist $p] {
        $p.t configure -state normal -font $df
        $p.t delete 1.0 end
        $p.t insert end $text
        $p.t configure -state disabled -wrap word
    } else {
        toplevel $p
        position_window ".error_msg"
        text $p.t -height 6 -width 50 -wrap word -font $df -foreground darkred
        pack $p.t -in $p -fill both -expand true
        $p.t insert end $text
        $p.t configure -state disabled
    }
    raise $p .
}


proc abcmidi_no_such_error {exefile} {
    set pathname [file dirname $exefile]
    set tail [file tail $exefile]
    puts $pathname
    puts $tail
    set msg "Runabc could not find the executable $tail in the folder $pathname.\
            $tail is part of the abcMIDI package. If the package\
            is already on your system, then you need to indicate the path to the\
            package by going to the config/abc executables menu item (see wrench\
            icon)."
    show_error_message $msg
}



#####  Functions to Play, Display, Edit #####

# The variable console_clock is used to determine whether
# the displayed X.tmp file is not superceded. It is called
# when X.tmp file is updated. console_clock is copied to
# tmp_clock whenever the tmpfile window is displayed or updated.
# We need to do this so that the error messages in the
# console window are in sync with the tmpfile window.

set midioutput "first play music"

proc play_action {} {
    global midi exec_out
    global files
    global console_clock
    global active_sheet
    global nvoices
    # midioutput is used for internals/mftext of output midi
    global midioutput

    set console_clock [clock seconds]
    set cmd "file delete [glob -nocomplain *.mid]"
    catch {eval $cmd}
    
    set sel [title_selected]
    if {$midi(double)} {
        if {$nvoices == 0} {set sel [create_tmp_voiced_abc $sel]
        } else {
            midi1_msg "cannot duplicate voice in multivoiced tune"
            set sel [tune2Xtmp $sel $midi(abc_open)]
        }
    } else {
        set sel [tune2Xtmp $sel $midi(abc_open)]
    }
    set cmd "exec [list $midi(path_abc2midi)]  X.tmp"
    if {$midi(barflymode)} {append cmd " -BF $midi(stressmodel)"}
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    if {$midi(nofermata) == 1} {append cmd " -NFER"}
    if {$midi(nogchords) == 1} {append cmd " -NGUI"}
    if {$midi(nograce) == 1} {append cmd " -NGRA"}
    if {$midi(quiet) == 1} {append cmd " -quiet"}
    if {$midi(silent) == 1} {append cmd " -silent"}
    catch {eval $cmd} exec_out
    if {[string first "no such" $exec_out] >= 0} {
	    abcmidi_no_such_error $midi(path_abc2midi)} else {
            set midioutput X[lindex $sel 0].mid
            }
    set exec_out $cmd\n\n$exec_out
    set files ""
    foreach tune [lsort -integer $sel] {
        lappend files X$tune.mid
    }
    play_midis $sel
    update_console_page
}


proc play_midis {sel} {
    global midi exec_out files
    

    switch -- $midi(player) {
       0  {
        set cmd "exec [list $midi(path_midiplayer_1)] $midi(midiplayer_1_options) "
        switch -- $midi(midiplayer_1_prot) {
            0 {set cmd [concat $cmd [file join [pwd] X[lindex $sel 0].mid]]}
            1 {set cmd [concat $cmd $files]}
            2 {set cmd [concat $cmd .]}
        }
      }
        1  {
        set cmd "exec [list $midi(path_midiplayer_2)] $midi(midiplayer_2_options) "
        switch -- $midi(midiplayer_2_prot) {
            0 {set cmd [concat $cmd [file join [pwd] X[lindex $sel 0].mid]]}
            1 {set cmd [concat $cmd $files]}
            2 {set cmd [concat $cmd .]}
        }
       }
      2  {
        set cmd "exec [list $midi(path_midiplayer_3)] $midi(midiplayer_3_options) "
        switch -- $midi(midiplayer_3_prot) {
            0 {set cmd [concat $cmd [file join [pwd] X[lindex $sel 0].mid]]}
            1 {set cmd [concat $cmd $files]}
            2 {set cmd [concat $cmd .]}
         }
       }
      3  {
        set cmd "exec [list $midi(path_midiplayer_4)] $midi(midiplayer_4_options) "
        switch -- $midi(midiplayer_4_prot) {
            0 {set cmd [concat $cmd [file join [pwd] X[lindex $sel 0].mid]]}
            1 {set cmd [concat $cmd $files]}
            2 {set cmd [concat $cmd .]}
         }
       }
    }

    set cmd [concat $cmd &]
    set exec_out $exec_out\n\n$cmd
    #puts $cmd
    eval $cmd
}


set yaps_ptsize {612x792 792x1224 1224x792 612x1008 396x612 540x720 \
            840x1189 594x840  419x594 727x1030 515x727 612x936 \
            612x777  720x1008}


proc display_action {{svgviewer 1}} {
    global midi
    global console_clock
    global active_sheet
    global exec_out
    global ps_numb_start
    set console_clock [clock seconds]
    set sel [title_selected]
    if {$midi(ps_creator)=="abc2svg" } {
       tune2Xtmp_for_abc2svg $sel X.tmp 
    } else {
       copy_selected_tunes_for_display $sel X.tmp
       }
    set ps_numb_start 0
    display_tunes X.tmp $svgviewer
    update_console_page
}


set urlpointer(0) "https://boubounet.fr/misc/"
set urlpointer(1) "http://moinejf.free.fr/js/"
set urlpointer(2) $midi(jslib)/


proc make_js_script_list {url abcweb} {
set scriptlist "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n"
set styleblock "
        <style type=\"text/css\">
        svg {display:block}
        @media print{body{margin:0;padding:0;border:0}.nop{display:none}}
        </style>"
set w(1) "snd-1.js"
set tail "\"></script>\n"
append scriptlist "     <script src=\"$url$abcweb$tail"
append scriptlist "     <script src=\"$url$w(1)$tail"
append scriptlist $styleblock
return $scriptlist
}



proc copytohtml {abcfile} {
global midi
global urlpointer

set html_preamble "<!DOCTYPE HTML>
<html>
<head>
"

 switch $midi(webscript) {
     1 {set abcweb abcweb-1.js}
     2 {set abcweb abcweb1-1.js}
     }

set remote_svg_script [make_js_script_list $urlpointer(1) $abcweb]
set local_svg_script  [make_js_script_list $urlpointer(2) $abcweb]

set preface $html_preamble
  if {$midi(remote)} {
    set preface $preface$remote_svg_script
    } else {
    set preface $preface$local_svg_script
    }

set inhandle [open $abcfile r]
set wholefile [read $inhandle]
close $inhandle

set outhandle [open $midi(outhtml) w]
puts $outhandle $preface
puts $outhandle  "</head>\n<body>\n<script type=\"text/vnd.abc\">"

if {$midi(fmt_chk) && [file exist $midi(ps_fmt_file)]} {
  set inhandle [open $midi(ps_fmt_file)]
  set fmt [read $inhandle]
  close $inhandle
  puts $outhandle $fmt
  }
puts $outhandle $wholefile
puts $outhandle  "</script>\n</body>\n</html>\n"
close $outhandle
}

proc copy_selected_tunes_for_display {sel filename} {
    #copies or appends all selected tunes to an output file
    global fileseek midi exec_out
    global ps_header
    global midi
    set edithandle [open $midi(abc_open) r]
    set outhandle [open $filename w]
    set exec_out "copying $sel to $filename"
    foreach i $sel {
        set loc $fileseek($i)
        seek $edithandle $loc
        set line [find_X_code $edithandle]
        puts $outhandle $line
        if {[string length $ps_header] > 0 && $midi(use_ps_header)} {puts $outhandle $ps_header}
        incr n
        while {[string length $line] > 0 } {
            if {$midi(blank_lines)} {
                set line  [get_nonblank_line $edithandle]} else {
                set line  [get_next_line $edithandle]}
            if {[string index $line 0] == "X"} break;
            puts $outhandle $line
        }
        puts $outhandle "\n"
    }
    close $edithandle
    close $outhandle
}

proc display_tunes {abcfile {svgviewer 1} {nodisplay 0}} {
# if nodisplay == 1 only Out.ps is created
    global midi
    global yaps_ptsize exec_out
    global ps_numb_start
    global exec_out
    global runabcpath
    
    if {$midi(ps_creator) == "yaps"} {
        # YAPS
        set M $midi(yaps_lmargin)x$midi(yaps_tmargin)
        set yapsopt ""
        append yapsopt " -N -o Out.ps \
                -P [lindex $yaps_ptsize $midi(papersize)] -s $midi(yaps_scale) -M $M"
        if {$midi(yaps_voice)} {append yapsopt " -V"}
        if {$midi(yapsx)} {append yapsopt " -x"}
        if {$midi(yaps_landscape)} {append yapsopt " -l"}
        if {$midi(yaps_bbar)} {append yapsopt " -k"}
        set cmd "exec [list $midi(path_yaps)] [list $abcfile] $yapsopt"
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
        if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_yaps)}
        
    } elseif {$midi(ps_creator) == "other"} {
        set cmd "exec [list $midi(path_otherps)] [list $abcfile] $midi(otherps)"
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
        
    } elseif {$midi(ps_creator) == "abcm2ps"} {
        set abc2psopt ""
        if  {$midi(ps_fmt_flag)} {
              append abc2psopt " -F [list $midi(ps_fmt_file)]"
            } else {
              append abc2psopt " -s $midi(ps_scale) \
                        -a $midi(ps_shrink) -m $midi(ps_lmargin) \
                        -w $midi(ps_width)  \
                        -d $midi(ps_staffsep)"
                         }
        if {$midi(ps_bxref)} {append abc2psopt " -x"}
        if {$midi(ps_bppage)} {append abc2psopt " -1"}
        if {$midi(ps_bbar)}  {append abc2psopt " -j 1"}
        if {$ps_numb_start != 0} {append abc2psopt " -b $ps_numb_start"}
        if {$midi(ps_c)}     {append abc2psopt " -c"}
        if {$midi(ps_fmt_landscape)} {append abc2psopt " -l"}
        if {$midi(ps_nolyric)} {
            set abc2psopt [concat $abc2psopt -M]}
        if {$midi(ps_noslur)} {
            set abc2psopt [concat $abc2psopt -G]}
        if {$midi(ps_flat)} {
            set abc2psopt [concat $abc2psopt -f]}
        if {$midi(m2ps_output) == "svg"} {
            set abc2psopt [concat $abc2psopt -g]}
        if {$midi(m2ps_output) == "xhtml"} {
            set abc2psopt [concat $abc2psopt -X]}
        if {$midi(m2ps_output) == "eps"} {
            set abc2psopt [concat $abc2psopt -E]}
        if { [string length $midi(ps_other_options)] > 1} {
            set abc2psopt [concat $abc2psopt $midi(ps_other_options)]}
        if {$midi(ps_buffsize) != 0} {
            set abc2psopt [concat $abc2psopt "-k $midi(ps_buffsize)"]}
        
        set cmd "exec [list $midi(path_abcm2ps)] \
                [list $abcfile] $abc2psopt"
        
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
    } elseif {$midi(ps_creator) == "abc2svg"} {
	    copytohtml $abcfile
            set cmd "exec [list $midi(path_internet)] file:[list $midi(outhtml)] &"
	    catch {eval $cmd} exec_out
	    set exec_out "$cmd\n$exec_out"

	    return
    }
    
    # Do not start another svg viewer if svgview is 0
    if {!$svgviewer} {
           set exec_out "$exec_abcmps\n$cmd\n\n$exec_out" 
           return 
           }
    if {$nodisplay == 1} {return}

    if {$midi(ps_creator) == "abcm2ps"} {
        if {$midi(m2ps_output) == "svg" } {
            set cmd "exec [list $midi(path_internet)] file://[list [pwd]/Out001.svg] &"
        } elseif {$midi(m2ps_output) == "xhtml"} {
            set cmd "exec [list $midi(path_internet)] file://[list [pwd]/Out.xhtml] &"
        } elseif {$midi(m2ps_output) == "eps"} {
            set cmd "exec [list $midi(path_gv)] Out001.eps &"
	    set epsmsg "The temporary eps files can be found\
in your $runabcpath folder"
	    messages $epsmsg
        } else {
            set cmd "exec [list $midi(path_gv)] Out.ps &"
        }
    } else {
        set cmd "exec [list $midi(path_gv)] Out.ps &"
    }
   catch {eval $cmd} exec_out
   set exec_out "$exec_abcmps\n$cmd\n\n$exec_out"
}

proc display_tunes_thru_x_tmp {abcfile} {
    global midi console_clock
    global ps_numb_start
    set ps_numb_start 0
    file copy -force $abcfile  X.tmp
    set console_clock [clock seconds]
    display_tunes X.tmp
}

proc midisave {} {
    global midi
    global sel ;# sel is passed around to other midisave_.. proc
    set sel [title_selected]
    if {[llength $sel] < 2} {
        midisave_single} else {
        midisave_list}
    if {$midi(bell_on)} bell
}

proc midisave_single {} {
    global midi miditype
    global nvoices
    set sel [title_selected]
    if {$midi(double)} {
        if {$nvoices == 0} {set xsel [create_tmp_voiced_abc $sel]
        } else {
            midi1_msg "cannot duplicate voice in multivoiced tune"
            set xsel [tune2Xtmp $sel $midi(abc_open)]
        }
    } else {
        set xsel [tune2Xtmp $sel $midi(abc_open)]
    }
    set cmd "exec [list $midi(path_abc2midi)] X.tmp"
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    if {$midi(barflymode)} {append cmd " -BF $midi(stressmodel)"}
    catch {eval $cmd} exec_out
    set filedir [file dirname $midi(midi_save)]
    set filename [tk_getSaveFile -initialdir $filedir -filetypes $miditype]
    #  remove mid extension if present
    set namesplit [split $filename .]
    set mid [lsearch $namesplit mid]
    if {$mid != -1} {
        set namesplit [lreplace $namesplit $mid $mid]}
    set mid [lsearch $namesplit MID]
    if {$mid != -1} {
        set namesplit [lreplace $namesplit $mid $mid]}
    set filename ""
    foreach elem $namesplit {
        set filename $filename$elem}
    if {$filename != ""} {
        set midi(midi_save) $filename
        file rename -force X$xsel.mid $filename.mid
    }
    update_console_page
}

proc midisave_list {} {
    global midi
    midisave_tool
}

proc midisave_list_continue {} {
    global midi
    global nvoices
    set dirname [tk_chooseDirectory]
    if {[string length $dirname] < 1} return
    file mkdir $dirname
    set sel [title_selected]
    if {$midi(double)} {
        if {$nvoices == 0} {set xsel [create_tmp_voiced_abc $sel]
        } else {
            midi1_msg "cannot duplicate voice in multivoiced tune"
            set xsel [tune2Xtmp $sel $midi(abc_open)]
        }
    } else {
        set xsel [tune2Xtmp $sel $midi(abc_open)]
    }
    set cmd "exec [list $midi(path_abc2midi)] X.tmp"
    if {$midi(barflymode)} {append cmd " -BF $midi(stressmodel)"}
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    catch {eval $cmd} exec_out
    set i 0
    puts $dirname
    foreach tune $sel {
        set title [extract_title_of_tune $tune $midi(abc_open)]
        set title [string range $title 0 $midi(namelen)]
        flush stdout
        set title [string map {, _ ? _ : _ ; _ > _ < _ = _} $title]
        flush stdout
        set n [lindex $xsel $i]
        set m [format "%04d" $n]
        if {$midi(name)} {
            file rename -force X$n.mid $dirname/$title.mid} else {
            file rename -force X$n.mid $dirname/$midi(nameroot)$m.mid}
        incr i
    }
    pack forget .abc.midisavetool
    update_console_page
}

proc midisave_tool {} {
    global midi
    global df
    global sel
    set p .abc.midisavetool
    set midi(nameroot) [file root [file tail $midi(abc_open)]]
    set n [llength $sel]
    $p.1 configure -text "You are creating $n midi files" -font $df
    pack $p
}


proc tunes2Out.ps {abcfile} {
# if nodisplay == 1 only Out.ps is created
    global midi
    global yaps_ptsize exec_out
    global ps_numb_start
    global exec_out
    global runabcpath
    
    if {$midi(ps_creator) == "yaps"} {
        # YAPS
        set M $midi(yaps_lmargin)x$midi(yaps_tmargin)
        set yapsopt ""
        append yapsopt " -N -o Out.ps \
                -P [lindex $yaps_ptsize $midi(papersize)] -s $midi(yaps_scale) -M $M"
        if {$midi(yaps_voice)} {append yapsopt " -V"}
        if {$midi(yapsx)} {append yapsopt " -x"}
        if {$midi(yaps_landscape)} {append yapsopt " -l"}
        if {$midi(yaps_bbar)} {append yapsopt " -k"}
        set cmd "exec [list $midi(path_yaps)] [list $abcfile] $yapsopt"
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
        if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_yaps)}
        
    } elseif {$midi(ps_creator) == "other"} {
        set cmd "exec [list $midi(path_otherps)] [list $abcfile] $midi(otherps)"
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
        
    } elseif {$midi(ps_creator) == "abcm2ps" ||
              $midi(ps_creator) == "abc2svg"} {
        set abc2psopt ""
        if  {$midi(ps_fmt_flag)} {
              append abc2psopt " -F [list $midi(ps_fmt_file)]"
            } else {
              append abc2psopt " -s $midi(ps_scale) \
                        -a $midi(ps_shrink) -m $midi(ps_lmargin) \
                        -w $midi(ps_width)  \
                        -d $midi(ps_staffsep)"
                         }
        if {$midi(ps_bxref)} {append abc2psopt " -x"}
        if {$midi(ps_bppage)} {append abc2psopt " -1"}
        if {$midi(ps_bbar)}  {append abc2psopt " -j 1"}
        if {$ps_numb_start != 0} {append abc2psopt " -b $ps_numb_start"}
        if {$midi(ps_c)}     {append abc2psopt " -c"}
        if {$midi(ps_fmt_landscape)} {append abc2psopt " -l"}
        if {$midi(ps_nolyric)} {
            set abc2psopt [concat $abc2psopt -M]}
        if {$midi(ps_noslur)} {
            set abc2psopt [concat $abc2psopt -G]}
        if {$midi(ps_flat)} {
            set abc2psopt [concat $abc2psopt -f]}
        if { [string length $midi(ps_other_options)] > 1} {
            set abc2psopt [concat $abc2psopt $midi(ps_other_options)]}
        if {$midi(ps_buffsize) != 0} {
            set abc2psopt [concat $abc2psopt "-k $midi(ps_buffsize)"]}
        
        set cmd "exec [list $midi(path_abcm2ps)] \
                [list $abcfile] $abc2psopt"
        
        catch {eval $cmd} exec_out
        set exec_abcmps "$cmd\n\n$exec_out"
    }
    

   set exec_out "$exec_abcmps\n$cmd\n\n$exec_out"
}

proc postscriptsave {} {
   global ps_numb_start
   set types {{{PostScript files} {*.ps}}}
   set ps_numb_start 0
   set sel [title_selected]
   copy_selected_tunes_for_display $sel X.tmp
   tunes2Out.ps X.tmp
   set filename [tk_getSaveFile -filetypes $types]
   file copy Out.ps $filename
}

proc pdfsave {} {
   global ps_numb_start
   global midi
   global exec_out
   set types {{{Pdf files} {*.pdf}}}
   set ps_numb_start 0
   set sel [title_selected]
   copy_selected_tunes_for_display $sel X.tmp
   tunes2Out.ps X.tmp 
   set filename [tk_getSaveFile -filetypes $types]
   set cmd "exec [list $midi(path_gs)] -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -q -sOutputFile=$filename Out.ps "
   catch {eval $cmd} result2
   append exec_out "\n$cmd\n$result2"
   update_console_page
}

################################
#      Support Functions       #
################################

startup_progress "loading support functions"

proc update_history {openfile} {
    global midi history_index df
    
    #check if file is in history
    for {set i 0} {$i < $midi(history_length)} {incr i} {
        if {[string compare $midi(history$i) $openfile] ==  0} return
    }
    
    if {$midi(history_length) == 0}  {
        .abc.file.menu.type add radiobutton  -value 0 -font $df\
                -variable history_index -command process_history
    }
    
    # push history down open stack
    for {set i $midi(history_length)} {$i > 0} {incr i -1}  {
        set j [expr $i -1]
        set k [expr $i +2]
        set midi(history$i) $midi(history$j)
        if {$midi(history_length) < 10 && $i == $midi(history_length) } {
            .abc.file.menu.type add radiobutton  -label $midi(history$i) \
                    -value $i -variable history_index\
                    -font $df -command process_history
        } else {
            .abc.file.menu.type entryconfigure  $k -label $midi(history$j)
        }
    }
    set midi(history0) $openfile
    .abc.file.menu.type entryconfigure 2 -label $midi(history0)
    if {$midi(history_length) < 10} {incr midi(history_length)}
}

proc delete_history {} {
global midi
for {set i 1} {$i < $midi(history_length)} {incr i} {
  unset midi(history$i)}
.abc.file.menu.type delete 3 [expr $midi(history_length) + 2]
set midi(history_length) 1
}

proc process_history {} {
    global midi history_index active_sheet
    global modifiedflag
    if {![file exist $midi(history$history_index)]} {
        show_message_page\
                "can't read input abc file\n$midi(history$history_index)" word
        return
    }
    if {[winfo exist .live]} {
        set modifiedflag [.live.main.editor.t edit modified]
        if $modifiedflag update_wholefile_and_toc
        }
    set midi(abc_open) $midi(history$history_index)
    .abc.file.entry xview moveto 1.0
    load_whole_file $midi(abc_open)
    title_index $midi(abc_open)
    if {$active_sheet != "titles"} {show_titles_page}
    if {[winfo exist .abcedit]} {
        .abcedit.func.file.actions entryconfigure 3 -state disable}
    update
}


proc file_browser {} {
    global midi types
    
    set filedir [file dirname $midi(abc_open)]
    set openfile [tk_getOpenFile -initialdir $filedir \
            -filetypes $types]
    open_abc_file $openfile
}


proc open_abc_file {filename} {
    global midi active_sheet
    if {[string length $filename] > 0} {
        #       if {[string equal $filename $midi(abc_open)]} return
        if {[winfo exist .live]} {
            set modifiedflag [.live.main.editor.t edit modified]
            if $modifiedflag update_wholefile_and_toc
            }
        set midi(abc_open) $filename
        if {[winfo exist .abcedit]} {
            .abcedit.func.file.actions entryconfigure 3 -state disable}
        .abc.file.entry xview moveto 1.0
        load_whole_file $midi(abc_open)
        title_index $midi(abc_open)
        update_history $filename
        if {$active_sheet != "titles"} {show_titles_page}
    }
}


# Part 7.0       TOC creator

#
# the function scans the entire abcfile making a list of titles and
# storing the file location of each tune. Code X: T: must begin on the
# first character position of a line.
#
proc title_index {abcfile} {
    global fileseek midi
    global abc_file_mod
    global item_id
    global index_done
    global df
    global midi_header
    global ps_header

    if {[info exist itemposition]} {unset itemposition}
    if {$abc_file_mod} {
        set lastindex [.abc.titles.t selection]
        set itemposition [.abc.titles.t index $lastindex]
        #puts "index for $lastindex = $itemposition"
        incr itemposition
        #because it counts from 0
            }
    set abc_file_mod 0
    if {[info exist first_title_item]} {unset first_title_item}
    #    puts "title_index [info level 0]"
    #    puts "title_index abc_file_mod reset"
    set srch X
    set pat {[0-9]+}
    #.abc.titles.t selection set {}
    .abc.titles.t delete [.abc.titles.t children {}]
    set titlehandle [open $abcfile r]
    fconfigure $titlehandle -encoding $midi(encoder)
    set filepos 0
    set meter 4/4
    set i 1
    .abc.titles.t tag configure tune -font $df

    #extract any %%MIDI commands in the header
    set midi_header {}
    set ps_header {}
    while {[gets $titlehandle line] >= 0} {
        if {[string index $line 0] == "X"} {
            regexp $pat $line number
            if {$number != 0} {set number [string trimleft $number 0]}
            # 2017-05-05 set filepos
            set filepos [expr [tell $titlehandle] - [string length $line] -2]
	    if {$filepos < 0} {set filepos 0}
            set srch T
            break
            }
        if {[string first "%%MIDI" $line] == 0 } {
            append midi_header $line\n
        } elseif {[string first "%%" $line] == 0 } {
            append ps_header $line\n
            if {[string first "%%beginps" $line] == 0} {
              while {[gets $titlehandle line] >= 0} {
                  append ps_header $line\n
                  if {[string first "%%endps" $line] == 0} break
                  }
             }
        }
    }


    while {[gets $titlehandle line] >= 0} {
        if {!$midi(blank_lines) && [string length $line] < 1} {set srch X}
        if {[string index $line 0] == "M"} {
            set meter [string range $line 2 end]
            set meter [string trim $meter]
        }
        switch -- $srch {
            X {if {[string compare -length 2 $line "X:"] == 0} {
                    regexp $pat $line  number
            # in case the number has leading zero's eg 0035
            # to be compatible with C programs (eg abcmatch.c).
                    if {$number != 0} {set number [string trimleft $number 0]}
                    set srch T
                } else {
                    set filepos [tell $titlehandle]
                }
            }
            T {
                if {[string index $line 0] == "T" || [string index $line 0] == "P"} {
                    set name [string range $line 2 end]
                    set name [string trim $name]
                    set srch K
                }
            }
            K {
                if {[string index $line 0] == "K"} {
                    set keysig [string range $line 2 end]
                    set keysig [string trim $keysig]
                    set keysig [string range $keysig 0 18]
                    set outline [format "%4s  %-4s %s %s" $number [list $keysig] $meter [list $name]]
                    set toc_index [.abc.titles.t insert {}  end -values $outline -tag tune]
                    if {$midi(index_by_position)} {
                       set item_id($i) $toc_index
                       #puts "$abcfile item_id($i) = $item_id($i)"
                       } else {
                       set item_id($number) $toc_index
                       #puts "$abcfile item_id($number) = $item_id($number)"
                       }
                    #puts "$i $toc_index"
                    set fileseek($toc_index) $filepos
                    if {![info exist first_title_item]} {
                        .abc.titles.t focus $toc_index
                        .abc.titles.t selection set $toc_index
                        set first_title_item $toc_index
                        update
                    }
                    
                    
                    set srch X
                    incr i
                    if {[expr $i % 20] == 0} update
                }
            }
        }
    }
    close $titlehandle
    #puts -nonewline $midi_header
    if {$i == 0} {show_error_message "corrupted file $midi(abc_open)\nno K:,X:,T: found in file."
        return}
    if {$i < 15} {
        .abc.titles.t configure -height [expr $i + 1]
        set midi(abc_save) $midi(abc_open)
    } else {
        .abc.titles.t configure -height 15
        set midi(abc_save) edit.abc
    }
    if {[info exist itemposition] && [info exist item_id($itemposition)]} {
         #puts "item id for $itemposition = $item_id($itemposition)"
        .abc.titles.t selection set $item_id($itemposition)
        .abc.titles.t see $item_id($itemposition)
    }
    update
    set ps_header [string trimright $ps_header]
}

proc SortBy {col direction} {
    set data {}
    foreach row [.abc.titles.t children {}] {
        lappend data [list [.abc.titles.t set $row $col] $row]
    }
    
    set dir [expr {$direction ? "-decreasing" : "-increasing"}]
    set r -1
    
    
    
    # Now reshuffle the rows into the sorted order
    foreach info [lsort -dictionary -index 0 $dir $data] {
        .abc.titles.t  move [lindex $info 1] {} [incr r]
    }
    # Switch the heading so that it will sort in the opposite direction
    .abc.titles.t heading $col -command [list SortBy  $col [expr {!$direction}]]
    
}


# returns position in list

global tunestart tuneend

proc title_selected {} {
    global abc_file_mod
    global midi
    global fileseek
    global tunestart
    if {$abc_file_mod}  {load_whole_file $midi(abc_open)
                         title_index $midi(abc_open)}

    if {[winfo exist .live]} {
        set modifiedflag [.live.main.editor.t edit modified]
        if $modifiedflag update_wholefile_and_toc
        }

    set index [.abc.titles.t selection]
    #puts "title_selected =  [winfo exist .live]"
    #puts "title_selected index = $index"
    # in case index is a list 
    set xref [lindex [.abc.titles.t item [lindex $index 0] -values] 0]
    #puts "xref = $xref"
    if {$midi(live_editor)} {
       if {![winfo exist .live]} {switch_live_editor}
       set tunestart $fileseek([lindex $index 0])
       update_live_editor $tunestart $xref
       .live.main.editor.t edit modified 0
       }
    return $index
}

proc select_all_titles {} {
return [.abc.titles.t children {}]
}

proc update_wholefile_and_toc {} {
     global midi
     update_wholefile "no"
     set edited_wholefile $midi(abc_open)
     set index [.abc.titles.t selection]
     set loc [.abc.titles.t bbox $index]
     set locx [lindex $loc 0]
     set locy [lindex $loc 1]
     load_whole_file $edited_wholefile
     .live.main.editor.t edit modified 0
     title_index $edited_wholefile
     set new_index [.abc.titles.t identify item $locx [expr $locy+2]]
     .abc.titles.t selection set $new_index
     }

proc update_wholefile {choice} {
     global tunestart tuneend wholefile
     global runabcpath
     global midi
     set modifiedtunecontent [.live.main.editor.t get 1.0 end]
     set modifiedtunecontent [string range $modifiedtunecontent 0 end-1]
     #puts "before $tunestart $tuneend"
     #puts "replacing:"
     #puts [string range $wholefile $tunestart $tuneend]
     set wholefile [string replace $wholefile $tunestart $tuneend $modifiedtunecontent]

     set outhandle [open $runabcpath/livetemp.tmp w]
     puts -nonewline $outhandle $wholefile
     close $outhandle
     set edited_wholefile $midi(abc_open)

     if {$choice == "no"} {
       set choice [tk_messageBox -type yesno -default yes \
                -message "You have modified $edited_wholefile. Do you wish to save it before closing?"\
                -icon question]
       }
     if {$choice == yes} {
          set backup_abcfile $edited_wholefile.bak
          file rename -force $edited_wholefile $backup_abcfile
          file rename -force $runabcpath/livetemp.tmp $edited_wholefile
          #tk_messageBox -type ok -message "The original version was saved in $backup_abcfile"
         .live.header.save configure -fg black
	  puts "saved $edited_wholefile"
         .live.main.editor.t edit reset
         .live.main.editor.t edit modified 0
          }
    }


proc get_nonblank_line {handle} {
    set line ""
    while {[string length $line] == 0 && [eof $handle] != 1} {
        gets $handle line
    }
    return $line
}

proc get_next_line {handle} {
    gets $handle line
    return $line
}



# Part 8.0              Extract Tune


# finds X: command or else returns nothing if eof
proc find_X_code {handle} {
    set line 1
    while {[string index $line 0] != "X" && [eof $handle] !=1} {
        set line [get_nonblank_line $handle]
    }
    return $line
}


proc get_title {handle} {
    set line 1
    while {[string index $line 0] != "T" && [string index $line 0] != "P" && [eof $handle] !=1} {
        set line [get_nonblank_line $handle]
    }
    return [string range $line 2 end]
}


# The next two functions are used to map a string in V: to a number.
proc  init_voicecodebook {} {
    global voicecodes
    array unset voicecode
    set voicecodes 0
}

proc vcode2numb {code} {
    global voicecodes voicecode
    if {[info exist voicecode($code)]} {
        return $voicecode($code)} else {
        incr voicecodes
        set voicecode($code) $voicecodes}
    return $voicecodes
}


#
# The function copies the selected tunes into an abc
# file called X.tmp.
# After the X:n command, all the %%MIDI commands are
# sent as well as a Q: tempo # command.
# Depending upon options any %%MIDI commands
# in the input file or any tempo commands will be
# ignored.  When a M: command is encountered the
# program may issue a %%MIDI gchord command.
#
# The function returns a list with the selected tune numbers
#

proc tune2Xtmp {tunes abcfile} {
    global fileseek
    global midi
    global drumentry mididrum pickedmeter
    global gchordentry midigchord

    global midi_header
 
    set inp_fd [open $abcfile r]
    set out_fd [open X.tmp w]
    set pat {[0-9]+|C|C\|}
    set outlist ""
    set dronestatus 0
    
    init_voicecodebook
    foreach i $tunes {
        set loc $fileseek($i)
        #    puts "tune2Xtmp seeking to $loc for $i"
        seek $inp_fd $loc
        
        
        # The procedure expects to see an X command here. Otherwise it is
        # an error.
        set line [find_X_code $inp_fd]
        if {[string index $line 0] == "X"} {
            puts $out_fd $line
            if {[string length $midi_header] > 0 && $midi(use_midi_header)} {
                puts -nonewline $out_fd $midi_header
                for {set j 0} {$j < 17} {incr j} {set voice($j) 1}
                 } else {
                for {set j 0} {$j < 17} {incr j} {set voice($j) 0}
	        }

            scan $line "X:%d" track
            lappend outlist $track
            if {!$midi(use_midi_header) || [string length $midi_header] < 5} {write_midi_codes $out_fd}
            puts $out_fd "Q:$midi(beatsize) = $midi(tempo)"
            set line [get_nonblank_line $inp_fd]
            set body 0
        } else {
            puts "tune picked did not find X_code"
            title_index $midi(abc_open)
            return $outlist
        }
        
        while {[string length $line] > 0 && [string index $line 0] != "X"} {
            set code [string range $line 0 1]
            switch -- $code {
                M: {regexp $pat $line meter
                    puts $out_fd $line
                    if {$gchordentry != "default"} {
                        puts $out_fd "%%MIDI gchord $gchordentry"
                    }
                }
                Q: {if {$midi(ignoreQ) == 0} {
                        puts $out_fd $line}
                }
                %% {if {$midi(ignoremidi) == 1} {
                        # %%MIDI command: suppress only program, bassprog, and chordprog
                        # the rest including gchord, drum etc goes through
                        set midicommandlist [split $line]
                        set cmnd [lindex $midicommandlist 1]
                        if {$cmnd == "program" || $cmnd == "bassprog" \
                                    || $cmnd == "chordprog" || $cmnd == "chordvol" \
                                    || $cmnd == "bassvol"}  {
                            set suppress 1} else {
                            set suppress 0}
                        if {!$suppress} {puts $out_fd $line}
                    } else {
                        puts $out_fd $line
                    }
                }
                V: {set payload [string range $line\
                            [expr [string first : $line] +1] end]
                    set payload [string trimleft $payload]
                    set vcode [lindex [split $payload] 0]
                    puts $out_fd $line
                    if {[string is integer $vcode] != 1} {
                        set vc [vcode2numb $vcode]
                    } else {
                        scan $line "V:%d" vc}
                    if {$vc < 17} {
                        if {$voice($vc) == 0} {
                            puts $out_fd "%%MIDI program $midi(voice$vc)"
                            puts $out_fd "%%MIDI control 7 $midi(lvoice$vc)"
                            puts $out_fd "%%MIDI control 10 $midi(pvoice$vc)"
                            puts $out_fd "%%MIDI beat $midi(beat_a) $midi(beat_b) \
                                    $midi(beat_c) $midi(beat_n)"
                            set voice($vc) 1
                        }
                    }
                }
                K:  {
                    if {$midi(octave) != 0} {append line " octave=$midi(octave)"}
                    puts $out_fd $line
                    set payload [string range $line\
                            [expr [string first : $line] +1] end]
                    set payload [string trimleft $payload]
                    set payload [string toupper $payload]
                    if {!$body && $midi(drone) && [string compare $payload "HP"]==0} {
                        puts $out_fd "%%MIDI drone 70 45 33 $midi(tenordrone) $midi(bassdrone)"
                        set dronestatus 1
                        puts $out_fd "%%MIDI droneon"}
                    set drumon 1
                    if  {$drumentry == "none"} {set drumon  0}
                    if {!$body && $drumon} {
                        puts $out_fd "%%MIDI drum $drumentry" 
                        puts $out_fd "%%MIDI drumon"
                        }
                    set body 1
                   }
             default { puts $out_fd $line }
            }
            if {$midi(blank_lines)} {
                set line [get_nonblank_line $inp_fd]} else {
                set line [get_next_line $inp_fd]}
        }
        if {$dronestatus} {puts $out_fd "%%MIDI droneoff"}
        puts $out_fd "\n"
    }
    close $inp_fd
    close $out_fd
    set mididrum($pickedmeter) $drumentry
    set midigchord($pickedmeter) $gchordentry
    return $outlist
}


proc tune2Xtmp_for_abc2svg {sel fileout} {
    #copies or appends all selected tunes to an output file
    global fileseek  exec_out
    global midi
    global ps_header
    global hasfield

    for {set i 0} {$i < 17} {incr i} {
      if {$midi(midi_chk)} {
       set addmidi($i) 1
       } else {
       set addmidi($i) 0
       }
    }

    set inhandle [open $midi(abc_open) r]
    set outhandle [open $fileout w]
    set exec_out "copying $sel to $fileout"
    foreach i $sel {
        set loc $fileseek($i)
        seek $inhandle $loc
        set line [find_X_code $inhandle]
        puts $outhandle $line
        if {[string length $ps_header] > 0 && $midi(use_ps_header)} {puts $outhandle $ps_header}
        if {$midi(ignoreQ) || [info exist hasfield(Q)] == 0} {
           puts $outhandle "Q: $midi(beatsize) = $midi(tempo)"
           }
        if {$midi(nogchords) == 0} {
           puts $outhandle "%%MIDI gchordon"
           }
        while {[string length $line] > 0 } {
            if {$midi(blank_lines)} {
                set line  [get_nonblank_line $inhandle]} else {
                set line  [get_next_line $inhandle]
	        }
            if {[string index $line 0] == "X"} break;
            if {$midi(ignoreQ) && [string first "Q:" $line] == 0} continue
            puts $outhandle $line
	    set loc [string first "V:" $line]
# The procedure does not handle V: enclosed in brackets
	    if {$loc ==0 && $midi(midi_chk)} {
              incr loc 2
	      set payload [string range $line $loc end]
	      set payload [string trimleft $payload]
	      set vcode [lindex [split $payload] 0]
              if {[string is integer $vcode] != 1} {
                   set vc [vcode2numb $vcode]
                   } else {
                   scan $line "V:%d" vc
	           }

	      if {$addmidi($vc)} {
                 puts $outhandle "%%MIDI program $midi(voice$vc)"
		 puts $outhandle "%%MIDI control 7 $midi(lvoice$vc)"
		 puts $outhandle "%%MIDI control 10 $midi(pvoice$vc)"
		 set addmidi($vc) 0
	         }
              }
            if {[string first "K:" $line] && $addmidi(0) == 1} {
                 puts $outhandle "%%MIDI program $midi(program)"
		 puts $outhandle "%%MIDI control 7 85"
                 if {$midi(nogchords) == 0} {puts $outhandle "%%MIDI chordprog $midi(chordprog) octave=$midi(chord_octave)"}
		 set addmidi(0) 0
	         }

         }
         puts $outhandle "\n"	      
    }
    close $inhandle
    close $outhandle
}


proc eliminate_guitar_chords {line} {
    regsub -all  {"[^"]*"} $line "" result
    return $result
}



proc suppress_midicommand {line} {
    set midicommandlist [split $line]
    set cmnd [lindex $midicommandlist 1]
    if {$cmnd == "program" || $cmnd == "bassprog" \
                || $cmnd == "chordprog" || $cmnd == "chordvol" \
                || $cmnd == "bassvol" || $cmnd == "gchord"}  {
        set suppress 1} else {
        set suppress 0}
    return $suppress
}


proc create_tmp_voiced_abc {tunes} {
    #This is another version of tunepicked {} function customized
    #to create two voices from one. The main complexity is handling
    #multipart tunes. We need to keep the voices separate in each
    #part.
    global  fileseek
    global  midi
    global titlename
    global drumentry

    set pat {[0-9]+|C|C\|}
    set rhythm ""
    set output_handle [open X.tmp w]
    set xreflist {}
    
    
    set edit_handle [open $midi(abc_open) r]
    foreach ref $tunes {
        set inbody 0
        set loc  $fileseek($ref)
        seek  $edit_handle $loc
        set line [find_X_code $edit_handle]
        if {[string index $line 0] == "X"} {
            scan $line "X:%d" xref
            lappend xreflist $xref
        }
        puts $output_handle X:$xref
        write_midi_codes $output_handle
        puts $output_handle "Q:$midi(beatsize) = $midi(tempo)"
        set block(0) ""
        set bn 0
        
        while {[string length $line] > 0} {
            gets $edit_handle line
            if {$midi(ignoremidi) == 1 && [string range $line 0 1] == "%%"} {
                set donotwrite [suppress_midicommand $line]
            } else {set donotwrite 0}
            if {[string length $line] < 1} break;
            if {!$inbody && !$donotwrite} {puts $output_handle $line}
            if {[string first R: $line] == 0} {
                set rhythm [string range $line 2 end]
                set rhythm [string trimleft $rhythm]
            }
            if {[string first M: $line] == 0} {
                regexp $pat $line meter
            }
            if {$inbody} {
                if {[string first P: $line] == 0} {
                    incr bn
                    set block($bn) ""
                    set blockname($bn) [string range $line 2 end]
                } elseif {!$donotwrite} {
                    append block($bn) $line\n}
            }
            if {[string first K: $line] == 0 && $inbody == 0} {
                set block($bn) ""
                set blockname($bn) ""
                set mygchord [.abc.midi1.gchord.combo get]
                if {$mygchord != "default"} {
                    puts $output_handle "%%MIDI gchord $mygchord"
                }

                set drumon 1
                if  {$drumentry == "none"} {set drumon  0}
                if {!$inbody && $drumon} {
                    puts $output_handle "%%MIDI drum $drumentry" 
                    puts $output_handle  "%%MIDI drumon"
                    }

                set inbody 1

            }
        }
        # finished reading tune
        if {$bn == "0"} {
            puts $output_handle "V:1 octave=$midi(octave)"
            puts -nonewline $output_handle $block($bn)
            
            if {$midi(octave2) !=0} {
                puts $output_handle "V:2 octave=$midi(octave2)"} else {
                puts $output_handle "V:2"}
            puts $output_handle "%%MIDI program $midi(program2)"
            puts $output_handle "%%MIDI beat $midi(beat2_a) $midi(beat2_b) $midi(beat2_c) $midi(beat_n)"
            set block($bn) [eliminate_guitar_chords $block($bn)]
            puts $output_handle $block($bn)
        }  else {
            if {[info exist block(0)]} {
                puts -nonewline $output_handle $block(0)
            }
            for {set i 1} {$i <= $bn} {incr i} {
                puts $output_handle P:$blockname($i)
                puts $output_handle V:1
                puts -nonewline $output_handle $block($i)
                puts $output_handle V:2
                if ($i==1) {
                    puts $output_handle "%%MIDI program $midi(program2)"
                    puts $output_handle "%%MIDI beat $midi(beat2_a) $midi(beat2_b) $midi(beat2_c) $midi(beat_n)"
                    if {$midi(octave2) !=0} {
                        puts $output_handle "V:2 octave=$midi(octave2)"} else {
                        puts $output_handle "V:2"}
                }
                set block($i) [eliminate_guitar_chords $block($i)]
                puts -nonewline $output_handle $block($i)
            }
        }
    }
    close $output_handle
    close $edit_handle
    #if {[string length $rhythm] > 1} {append titlename " - $rhythm"}
    
    return $xreflist
}

proc write_midi_codes {outfd} {
    global midi
    global m
    
    set i1 [expr int(1 + $midi(program)/8)]
    set i2 [expr $midi(program)  % 8 ]
    set mel_instrum [lindex $m($i1) $i2]
    set i1 [expr int(1 + $midi(bassprog)/8)]
    set i2 [expr $midi(bassprog)  % 8 ]
    set bass_instrum [lindex $m($i1) $i2]
    set i1 [expr int(1 + $midi(chordprog)/8)]
    set i2 [expr $midi(chordprog)  % 8 ]
    set chord_instrum [lindex $m($i1) $i2]
    
    set mid "%%MIDI"
    puts $outfd "$mid channel $midi(channel)"
    puts $outfd "$mid chordprog $midi(chordprog) octave=$midi(chord_octave) % $chord_instrum"
    puts $outfd "$mid bassprog $midi(bassprog) octave=$midi(bass_octave) % $bass_instrum "
    puts $outfd "$mid program $midi(program) % $mel_instrum"
    puts $outfd "$mid beat $midi(beat_a) $midi(beat_b) \
            $midi(beat_c) $midi(beat_n)"
    puts $outfd "$mid ratio $midi(ratio_n) $midi(ratio_m)"
    puts $outfd "$mid chordvol $midi(chordvol)"
    puts $outfd "$mid bassvol $midi(bassvol)"
    puts $outfd "$mid transpose $midi(transpose)"
    puts $outfd "$mid gracedivider $midi(gracedivider)"
}


startup_progress "loading editor functions"


# Part 9.0                     Functions for Manipulating abc tune file

# Tcl Editor and Support Functions


proc copy_selection_to_file {tunes abcfile outfile} {
    global fileseek midi exec_out
    global copyfromloc copytoloc

    
    if {[string compare [file tail $abcfile] [file tail $outfile]] == 0} return
    set edithandle [open $abcfile r]
    fconfigure $edithandle -encoding $midi(encoder)
    set outhandle [open $outfile w]
    fconfigure $outhandle -encoding $midi(encoder)
    
    set exec_out "copying $tunes to $outfile"
    foreach i $tunes {
        set loc $fileseek($i)
        set copyfromloc $loc
        seek $edithandle $loc
        set line [find_X_code $edithandle]
        puts $outhandle $line
        while {[string length $line] > 0 } {
            set copytoloc [tell $edithandle]
            if {$midi(blank_lines)} {
                set line  [get_nonblank_line $edithandle]} else {
                set line  [get_next_line $edithandle]}
            if {[string index $line 0] == "X"} break;
            puts $outhandle $line
        }
        puts $outhandle ""
    }
    
    close $edithandle
    close $outhandle
    if {$midi(bell_on)} bell
}




proc extract_title_of_first_tune {tunes abcfile} {
    set tune [lindex $tunes 0]
    extract_title_of_tune $tune $abcfile
}


proc extract_title_of_tune {tune abcfile} {
    global fileseek midi
    set loc $fileseek($tune)
    set edithandle [open $abcfile r]
    fconfigure $edithandle -encoding $midi(encoder)
    seek $edithandle $loc
    set title [get_title $edithandle]
    close $edithandle
    fconfigure stdout -encoding $midi(encoder)
    set title [string trimleft $title]
    set comloc [string first "%" $title]
    if {$comloc > 3} {set title [string range $title 0 [expr $comloc-1]]}
    set title [string trimright $title]
    if {[string length $title] <1} {set title notitle}
    set pat \[\"\/\\\*:\;\?\.\^\]
    regsub -all $pat $title "" result
    set title [string map {\040 _ \\ ""} $result]
    return $title
}

proc split_abc_file {} {
  global midi
  set numpat {[0-9]+}
  set dirname [tk_chooseDirectory]
  puts $dirname
  set titlehandle [open $midi(abc_open) r]
  set filecontents ""
  set filename ""
  set n 0
  while {[gets $titlehandle line] >= 0} {
        if {[string index $line 0] == "X"} {
            regexp $numpat $line number
            if {$number != 0} {set number [string trimleft $number 0]}

            if {[string length $filename] > 1} {
               set dup [output_abc_file $filepath $filecontents]
               incr n
               if {$dup == 1} {return}
            } 
               
            set filecontents ""
            }
        if {[string index $line 0] == "T"} {
           set title [string range $line 2 end]
           set title [string trimleft $title]
           set title [string map {" " _ , _ ? _ : _ ; _ > _ < _ = _} $title]
            if {$midi(name)} {
              set filename $title.abc
              } else {
              set filename [format "X%04d.abc" $number]
              }
          set filepath $dirname/$filename
          }
          set filecontents [append filecontents "$line\n"]
   }
   close $titlehandle
   set acknowledge "$n files created in the folder $dirname"
   messages $acknowledge
}

proc output_abc_file {filepath filecontents} {
  if {[file exist $filepath]} {
    messages "file $filepath already exists...aborting"
    return 1
    } else {
  set outhandle [open $filepath w]
  puts $outhandle $filecontents
  close $outhandle
  return 0
  }
}



proc split_abc_tool {} {
global midi
global sel
global df
set sel [select_all_titles]
#puts "sel = $sel"
set p .abc.splittool
pack $p
set n [llength $sel]
$p.1 configure -text "You are creating $n abc files" -font $df
}



proc edit_new_tune {} {
    global midi
    
    set outfd [open $midi(abc_default_file) w]
    puts $outfd "X: 1"
    puts $outfd "T: Title"
    puts $outfd "C: Composer"
    puts $outfd "M: 2/4"
    puts $outfd "L: 1/8"
    puts $outfd "K: G"
    close $outfd
    abc_edit midi(abc_default_file)
}


proc edit_empty_file {} {
    global midi
    global barpickerflag
    set barpickerflag 1
    set outfd [open $midi(abc_default_file) w]
    close $outfd
    tcl_abc_edit $midi(abc_default_file) 1
}


proc merge_abc_files {} {
    global midi exec_out
    set folder [tk_chooseDirectory -title "Choose the directory containing the abc files"]
    if {[llength $folder] < 1} return
    puts $folder
    
    set collection [glob -directory $folder *.abc *.ABC]
    set exec_out  "[llength $collection] files were found"
    show_console_page $exec_out char
    set types {{{abc files} {*.abc}}
        {{all} {*}}}
    set filedir [file dirname $midi(abc_default_file)]
    set filename [tk_getSaveFile -initialdir $filedir \
           -filetypes $types -title "the file where all the abc tunes are saved"]
    if {[string length $filename] == 0} return
    set outhandle [open $filename  w]
    foreach abcfile $collection {
        set inputhandle [open $abcfile r]
        
        while {[gets $inputhandle line] >= 0} {
            puts $outhandle $line}
        puts $outhandle \n
        close $inputhandle
    }
    close $outhandle
    puts "saved in $filename"
    set exec_out "$exec_out\n[llength $collection] files were merged into $filename"
    show_console_page $exec_out char
}


proc copy_all_and_renumber {} {
global midi

set types {{{abc files} {*.abc}}
        {{all} {*}}}
renumber_message 
set fileout [tk_getSaveFile -filetypes $types]
puts $fileout
if {[string length $fileout] == 0} return
if {[string compare  $midi(abc_open) $fileout] == 0} {
        tk_messageBox -message "do not even think of writing over the input file" \
                -type ok
        return
        }
set msg "The program will copy the entire file $midi(abc_open) including all \
text and renumber the X reference numbers starting from $midi(startnumber):\
and store the results in the file $fileout"
set choice [tk_messageBox -type yesno -default yes \
                -message $msg -icon question]
if {$choice != "yes"} return

set inhandle [open $midi(abc_open) r]
fconfigure $inhandle -encoding $midi(encoder)

set outhandle [open $fileout  w]
set n $midi(startnumber)

while {[gets $inhandle line] >= 0} {
      if {[eof $inhandle]} break
      if {[string range $line 0 1] == "X:"} {
        puts $outhandle "X: $n"
        incr n} else {
        puts $outhandle $line}
       }
      close $inhandle
      close $outhandle
      puts "saved results in $fileout\n"
}



proc start_copy_selected_files {access renumber} {
    global midi
    set sel [title_selected]
    if {$sel == -1} return
    set types {{{abc files} {*.abc}}
        {{all} {*}}}
    set filedir [file dirname $midi(abc_default_file)]
    set filename [tk_getSaveFile -initialdir $filedir \
            -filetypes $types]
    if {[string length $filename] == 0} return
    if {[string compare  $midi(abc_open) $filename] == 0} {
        tk_messageBox -message "do not even think of writing over the input file" \
                -type ok
        return
    }
   if {$renumber} renumber_message
   set ntunes [llength $sel]
   switch $access {
        "w"	{set msg "The program will copy $ntunes tunes to the file $filename"}
        "a"	{set msg "The program will append $ntunes tunes to the file $filename"}
    }
    if {$renumber} {set msg "$msg\nThe program will renumber the x ref of the tunes sequentially starting from $midi(startnumber)"}
   set choice [tk_messageBox -type yesno -default yes \
                -message $msg -icon question]
    #copy_message $sel $access $renumber $filename
    if {$choice == "yes"} {copy_selected_files $sel $access $renumber $filename}
}

proc renumber_message {} {
    global df
    global midi
    set w .abc.copy
    toplevel $w
    position_window ".abc.copy"
    focus $w
    set msg "The program will renumber the x ref of the tunes sequentially starting from "
    message $w.msg -text $msg -width 300 -font $df
    button $w.continue -text continue -command {destroy .abc.copy} -font $df
    pack $w.msg -side top
    entry $w.ent -width 5 -textvariable midi(startnumber)
    pack $w.ent -side left
    pack $w.continue
    grab $w
    tkwait window $w
}

proc copy_selected_files {sel access renumber filename} {
    #copies or appends all selected tunes to an output file
    global fileseek midi exec_out
    set edithandle [open $midi(abc_open) r]
    set outhandle [open $filename $access]
    set n $midi(startnumber)
    set exec_out "copying $sel to $filename"
    foreach i $sel {
        set loc $fileseek($i)
        seek $edithandle $loc
        set line [find_X_code $edithandle]
        if {$renumber} {puts $outhandle "X: $n"} else {puts $outhandle $line}
        incr n
        while {[string length $line] > 0 } {
            if {$midi(blank_lines)} {
                set line  [get_nonblank_line $edithandle]} else {
                set line  [get_next_line $edithandle]}
            if {[string index $line 0] == "X"} break;
            puts $outhandle $line
        }
        puts $outhandle "\n"
    }
    close $edithandle
    close $outhandle
}




# These are special procedures designed to take
# Laura Conrads renaissance music in her allparts.abc
# files and reformat them so each part is a separate voice
# instead of a separate tune. The procedure eliminates
# multiple copies of the lyrics, replaces the X:
# with a V: and eliminates and T: fields occurring
# in the other voices. Unfortunately, the functions
# do not do everything and some hand editing may
# necessary.

proc concat_parts {tunes abcfile outfile} {
    global fileseek midi
    set body 0
    set first_tune 1
    set edithandle [open $midi(abc_open) r]
    set outhandle [open $outfile w]
    foreach i $tunes {
        
        #   either put a X:n field or a V:n field for the tune depending
        #   on whether this is the first selection or not. The variable
        #   body signals the first time we reach the body of one of
        #   the abc tunes.
        set loc $fileseek($i)
        seek $edithandle $loc
        set line [find_X_code $edithandle]
        if {$first_tune} {puts $outhandle $line} else {
            puts $outhandle V:[expr 1+$i]}
        
        #   for the rest of the tune we strip out the lyrics (w:) and
        #   title, if it is not the first part. For the first selection
        #   we find the start of the body, (prior to K:) and insert a
        #   V:1 field
        #
        while {[string length $line] > 0 } {
            if {$midi(blank_lines)} {
                set line  [get_nonblank_line $edithandle]} else {
                set line  [get_next_line $edithandle]}
            if {[string index $line 0] == "X"} break;
            if {$first_tune} {
                #           first part
                if {[string index $line 0] == "K" && $body == 0} {
                    puts $outhandle "V:1"
                    set body 1}
                puts $outhandle $line} else   {
                #           remaining parts
                if {[string index $line 0] == "w" || \
                            [string index $line 0] == "T" } {continue} else {
                    puts $outhandle $line}
            }
        }
        set first_tune 0
    }
    puts $outhandle ""
    close $edithandle
    close $outhandle
    if {$midi(bell_on)} bell
}


proc combine_parts {} {
    global midi
    set sel [title_selected]
    if {$sel == -1} return
    set types {{{abc files} {*.abc}}
        {{all} {*}}}
    set filedir [file dirname $midi(abc_default_file)]
    set filename [tk_getSaveFile -initialdir $filedir \
            -filetypes $types]
    concat_parts $sel $midi(abc_open) $filename
}

proc abc_edit {varname} {
    upvar #0 $varname abcfile
    global midi exec_out
    global barpickerflag
    
    if {[string length $midi(path_editor)] > 1} {
        set cmd "exec [list $midi(path_editor)] [list $abcfile] &"
        catch {eval $cmd} exec_out
        set exec_out $cmd\n\n$exec_out
        update_console_page
    } else {
        set barpickerflag  0
        tcl_abc_edit $abcfile 1
    }
}


# Part 10.0            Abc Editor Functions

set hlp_editor \
        "TclAbcEditor\n\n\
        The program edits either the selected tune or the entire abc file. If \
        your computer is slow and the abc file is very large, it is recommended\
        that you limit your selection to one or a few tunes. The editor syntax\
        highlights the different abc components, (field commands like X:, comments\
        and body). The highlighting is done in real time while you are editing\
        the text; however, if for some reason the highlighting appears incorrect,\
        you can restore the correct colours by clicking the clean/retag button.\
        The choice of colours for syntax highlighting can be changed by\
        editing the variables edit_body_colour, edit_field_colour etc in\
        the runabc.ini file.)\n\n\
        The editor does not display the global headers in the source file;\
        however, you have the option of importing them using the file\
        menu item in the abcedit window.\n\n\
        The undo button or the <cntl-z> key will undo\
        any of your changes. You have unlimited undo's provided there is sufficient\
        memory in your computer. The redo button or the <cntl-y> keys on Windows\
        or the <cntl-Z> keys on all other platforms, will redo your changes.\n\n\
        When you edit selected tunes, the program makes a copy\
        of these tunes in a temporary file specified by the variable abc_default_file \
        in your runabc.ini file. (By default it is called edit.abc but you are able to\
        change it by editing the runabc.ini file.) The file edit.abc is then renamed to\
        a new file name based on the title of the first tune  and placed in your\
        abc_work_folder directory also specified in runabc.ini. (Initially it is\
        set to the name workfold.) Note that if a file of the same name already\
        exists in that work folder, it will be overwritten without warning.\n\n\
        A guitar toolbox and a grace notes toolbox are displayed to the\
        left of the edit window. Separate help buttons on these toolboxes\
        describe their operation. You may shift the toolboxes out to the\
        right, if they are in your way.\n\n\
        Description of menu options:\n\n\
        The play button is designed to play a small \
        portion of the file. You can either play a single text line positioned \
        at your insert cursor or else you play a selected area. To designate a \
        selected area,  hold the left mouse button down and sweep an \
        area with your cursor in the edit window.  Avoid selecting an area \
        starting with a line feed.  The tcl/tk script will search backwards \
        for the X: and other field commands occurring before your highlighted \
        area and also use this  information for creating the midi file.\n\n\
        The 'play all' item allows you to play the edit window exactly as\
        written (verbatim) or to also include the MIDI indications that\
        you set under abcmidi/options. If the window already has MIDI\
        indications, they may not be overridden depending on your settings.\n\n\
        It is recommended that you use a midi player which either \
        automatically closes when the selection completes playing or one which \
        stays open and automatically captures other selections when you click \
        the play button again. On Microsoft Windows, I use either Winamp or \
        the new Windows Media Player. On Unix, I use timidity without any \
        user interface. If for some reason the play button does not produce \
        audio output but normally works when you do not run the editor, check \
        the internals/messages window or the internals/processed file to determine what has happened.\n\n\
        If you save over an existing abc file, it is a good idea to ensure \
        that you have a backup of this file since I cannot guarantee the software \
        is bug free.\n\n\
        The editor provides several  other features specificly designed for \
        abc files. These are accessible through the menu items clean and tools \
        for which there are other help messages. In particular there is a find \
        tool for searching for particular strings in editor window starting from\
        the current cursor position. Enter the string in the entry box and search \
        either forwards  or backwards. This search is case sensitive. To find \
        a particular barline, enter its sequence number starting from 1 in the \
        entry box and press the barline button. Barlines or double barlines are \
        counted from the first X: reference number preceding the insert cursor \
        position.\n\n\
        The tools/align bars improves the appearance and readablity\
        by putting spaces before the bar lines so that they line up\
        vertically. If the algorithm works correctly, the formatting\
        should  not change the way the music is converted to a postscript\
        file or midi file. The function is applied on the entire contents\
        of the edit window; therefore, you should only load a single tune.\
        The tools/squeeze bars does the reverse of above. It replaces\
        any sequence of spaces with a single space. The tune is harder to\
        read but otherwise it is the same as before.\n\n\
        The tools/add guitar chords inserts the appropriate guitar chords\
        based on the notes in the bar.\n\n\n\n\
        Text Widget standard binding.
<Button-1> Set the insert point, clear the selection, set focus.
<B1-Motion> Sweep out a selection from insert point.
<Shift-Button-1> Adjust the end of the selection closest to the mouse.
<Shift-Left> Move cursor and extend selection.
<Button-2> Paste the selection, or set the scrolling anchor.
<Button-2 motion> Scroll the window.
<Arrow keys> Shift insert point.
<Shift Arrow keys> Shift insert point and extend or clear selection.
<Cntl n> Shift insert point to next line.
<Cntl p> Shift insert point to previous line.
<Cntl f> Shift insert point one character to the right.
<Cntl b> Shift insert point one character to the left.
<Alt f>  Shift insert point one bar line to the left.
<Alt b>  Shift insert point one bar line to the right.
<Cntl d> Deletes character to right of the cursor.
<Cntl k> Deletes from cursor to end of the line.
<Cntl o> Inserts a new line but does not advance cursor.
<Cntl t> Transposes two characters.
<Cntl z> Undo last insert or delete. Unlimited undo's available.
<Cntl slash> Selects everything in the text widget
<Cntl backslash> Clears the selection.
<Shift arrow keys> Alter the selection.
<Delete> Delete selection if any, otherwise delete character to the right.
<Backspace> Delete selection if any, otherwise delete character to the left.

<Alt r> will raise the pitch of a note following the cursor.
<Alt l> will lower the pitch of a note following the cursor.
<Alt e> will increase (expand) the duration of the note.
<Alt c> will decrease (contract) the duration of the note.
<Alt s> will do a save as.
<Alt S> will do a save.
<Alt d> display

If you right click the mouse in the edit window, a small pop-up menu\
        allows you to display or play the edited tune. If part of the tune,\
        is highlighted, the play function will play just the highlighted portion.

There are many more bindings... see Tcl documentation for text widget.

On Windows you can use <cntl-c>, <cntl-x> <cntl-v> to copy, cut and \
        paste the selections. For other systems use <cntl-y> instead of <cntl-v>. \
        On some unix systems use <Cntl _> for undo."

set hlp_copy "Copy to file menu\n\nThe function 'copy' will copy the\
        selected tunes in the table of contents to a designated abc\
        file. If the file does not already exist, it will create\
        a new file; otherwise, it will destroy the existing file\
        and overwrite it with the selected tunes. The X: numbers will be\
        preserved.\n\n'Copy and renumber' will do the same as above but it will\
        renumber the selected tunes increasing sequentially from a selected\
        number.\n\n\'Copy all' will copy the entire open file to a specified\
	file including any intervening text but it will renumber the\
	X: reference numbers starting from a selected number.\n\n\
	'Append' will append the selected tunes to an existing file,\
        preserving the original numbering.\n\n'Append and renumber' will do the\
        same but renumber the selected tunes.\
        \n\n'Merge abc files' combines all the abc files in\
        a folder and saves it to a separate file.\
        \n\n'Combine parts' function is\
        specificly designed to reformat Laura Conrads renaissance music in\
        her allparts.abc files. Each part is written as a separate tune rather\
        than a separate voice. Therefore it is not possible to create a midi\
        file with all parts playing simultaneously. This function combines all\
        the parts into one tune, giving each part a separate voice.\
        Duplicate titles, and lyrics are removed. When using this function, you must\
        first select (highlight) all the tunes that you wish to combine. Like other\
        copy functions, you will prompted for the name of an output file.\n\n\
        Caution: do not try to copy over the source file already displayed in\
        the table of contents."



proc confirm_save {} {
    global midi
    global abctxtw
    set choice no
    if {$midi(noconfirmsave)} {
        destroy .abcedit
        return}
    if {![winfo exist .abcedit]} return
    if {[$abctxtw edit modified]} {
        set choice [tk_messageBox -type yesno -default yes \
                -message "You have unsaved work. Do you wish to save before closing?"\
                -icon question]
    }
    if {$choice == yes} {
        set_abc_save
        if {[llength $midi(abc_save)] >0} {Text_Dump $abctxtw}
    }
    destroy .abcedit
}

proc startup_tcl_abc_edit {opt} {
    global midi
    global barpickerflag
    global runabcpath
    set barpickerflag [expr 1 - $opt]
    set outfile [extract_title_of_first_tune [title_selected] $midi(abc_open)]
    set outfile [file join $midi(abc_work_folder) $outfile.abc]
    file mkdir $midi(abc_work_folder)
    set selected_tunes [title_selected]
    copy_selection_to_file $selected_tunes $midi(abc_open) $midi(abc_default_file)
    #encoding system $midi(encoder)
    file rename -force $midi(abc_default_file) $outfile
    #puts "renamed file to $outfile"
    if {$opt} {
        tcl_abc_edit $outfile $opt
    } else {
        tcl_abc_edit_with_voices $outfile $opt
    }
    if {[llength $selected_tunes] > 1} {
        .abcedit.func.file.actions entryconfigure 3 -state disable}
}


proc tcl_abc_edit {abcfile toolbox} {
    global midi df
    global abctxtw
    global barpickerflag
    
    if {[winfo exists .abcedit] != 0} {
        confirm_save
        destroy .abcedit
    }
    
    toplevel .abcedit
    position_window ".abcedit"
    
    
    panedwindow .abcedit.pane -orient horizontal -sashwidth 8
    wm protocol .abcedit WM_DELETE_WINDOW confirm_save
    set midi(abc_save) $abcfile
    frame .abcedit.pane.right
    set abctxtw .abcedit.pane.right.t
    text $abctxtw -width $midi(edit_initial_width) -wrap none \
            -yscrollcommand {.abcedit.pane.right.ysbar set} \
            -xscrollcommand {.abcedit.pane.right.xsbar set} \
            -font "[list $midi(font_family_toc)] $midi(font_size) $midi(font_weight)"
    scrollbar .abcedit.pane.right.ysbar -orient vertical -command {$abctxtw yview}
    scrollbar .abcedit.pane.right.xsbar -orient horizontal -command {$abctxtw xview}
    
    entry .abcedit.file  -textvariable midi(abc_save) -width 60 -font $df
    
    tcl_abc_edit_menu_bar $abcfile
    
    
    pack .abcedit.pane.right.xsbar -side bottom -fill x
    pack .abcedit.file -side top -anchor w -fill x -expand 1
    pack .abcedit.pane.right.ysbar -side right -fill y -expand 0
    pack $abctxtw -fill both -expand 1 -side right
    
    
    if {[file exist $abcfile]} {
        set edit_handle [open $abcfile r]
        fconfigure $edit_handle -encoding $midi(encoder)
        if {[eof $edit_handle] !=1} {gets $edit_handle line}
        $abctxtw insert end $line\n
        while {[eof $edit_handle] != 1} {
            gets $edit_handle line
            $abctxtw insert end $line\n
        }
        close $edit_handle
    }
    
    $abctxtw  tag configure blue -foreground blue
    
    
    $abctxtw configure -undo 1
    $abctxtw edit modified 0
    
    focus .abcedit
    # do not tag text if barpickerflag is on or else blue tag
    # will not show.
    if {!$barpickerflag} {tag_text $abctxtw}
    
    
    frame .abcedit.pane.toolbox
    .abcedit.pane add .abcedit.pane.toolbox .abcedit.pane.right
    
    pack .abcedit.pane -fill both -expand 1
    guitar_chord
    grace_toolbox
    bind $abctxtw <KeyRelease> "tag_line $abctxtw"
    
    bind $abctxtw <Button-3> {
        tk_popup .actionmenu2 %X %Y}
    
    if {[winfo exist .actionmenu2] != 1} {
        menu .actionmenu2
        .actionmenu2 add command -label play -command {edit_play_context}
        .actionmenu2 add command -label display -command {display_entire_edit_window}
    }
}

proc tcl_abc_edit_with_voices {abcfile toolbox} {
    global midi df
    global abctxtw
    global barpickerflag
    global do_reconstitute
    set do_reconstitute 0
    #puts "tcl_abc_edit_with_voices $abcfile $toolbox"
    
    if {[winfo exists .abcedit] != 0} {
        confirm_save
        destroy .abcedit
    }
    
    toplevel .abcedit
    position_window ".abcedit"
    
    
    #panedwindow .abcedit.pane
    panedwindow .abcedit.pane -background blue -orient vertical -sashwidth 8
    wm protocol .abcedit WM_DELETE_WINDOW confirm_save
    set midi(abc_save) $abcfile
    frame .abcedit.pane.tframe -background red
    set abctxtw .abcedit.pane.tframe.t
    text $abctxtw -width $midi(edit_initial_width) -wrap none \
            -xscrollcommand {.abcedit.pane.tframe.xsbar set} \
            -yscrollcommand {.abcedit.pane.tframe.ysbar set} \
            -font "[list $midi(font_family_toc)] $midi(font_size) $midi(font_weight)"
    scrollbar .abcedit.pane.tframe.ysbar -orient vertical -command {$abctxtw yview}
    scrollbar .abcedit.pane.tframe.xsbar -orient horizontal -command {$abctxtw xview}
    
    
    entry .abcedit.file  -textvariable midi(abc_save) -width 60 -font $df
    
    tcl_abc_edit_menu_bar $abcfile
    
    
    pack .abcedit.file -side top -anchor w -fill x
    pack .abcedit.pane.tframe.ysbar -side right -fill y
    pack .abcedit.pane.tframe.xsbar -side bottom -fill x
    pack $abctxtw -fill both -expand 1 -side right
    
    
    
    if {[file exist $abcfile]} {
        set edit_handle [open $abcfile r]
        fconfigure $edit_handle -encoding $midi(encoder)
        if {[eof $edit_handle] !=1} {gets $edit_handle line}
        $abctxtw insert end $line\n
        while {[eof $edit_handle] != 1} {
            gets $edit_handle line
            $abctxtw insert end $line\n
        }
        close $edit_handle
    }
    
    $abctxtw  tag configure blue -foreground blue
    

    Refactor::refactor_textcontents
    Barpicker::create_picker_interface
    #puts "tunepieces [Refactor::dump_tunepieces]"
    
    $abctxtw configure -undo 1
    $abctxtw edit modified 0
    
    focus .abcedit
    # do not tag text if barpickerflag is on or else blue tag
    # will not show.
    
    
    pack .abcedit.pane -expand 1 -fill both
    if {$barpickerflag} {
        .abcedit.pane add .abcedit.pane.tframe\
                .abcedit.pane.picker} else {
        pack .abcedit.pane.tframe -expand 1 -fill both}
    
    bind $abctxtw <KeyRelease> "tag_line $abctxtw"
    
    bind $abctxtw <Button-3> {
        tk_popup .actionmenu2 %X %Y}
    
    if {[winfo exist .actionmenu2] != 1} {
        menu .actionmenu2
        .actionmenu2 add command -label play -command {edit_play_context}
        .actionmenu2 add command -label display -command {display_entire_edit_window}
    }
}

proc edit_play_context {} {
    global abctxtw
    set point [$abctxtw index insert]
    set selrange [$abctxtw tag ranges sel]
    if {[llength $selrange] < 2} {
        play_entire_edit_window 0} else {
        play_from_edit_window sel $abctxtw
    }
}


proc tcl_abc_edit_menu_bar {abcfile} {
    global df
    global abctxtw
    global fileseek
    global hlp_barpicker
    frame [set w .abcedit.func]
    menubutton $w.file -text file -font $df -menu $w.file.actions
    menu $w.file.actions -tearoff 0
    $w.file.actions add command -label "insert global header" -font $df \
            -command tcl_abc_edit_copy_global_header
    $w.file.actions add command -label save -font $df \
            -command  tcl_abc_edit_save
    $w.file.actions add command -label "save as" -font $df \
            -command  tcl_abc_edit_save_as
    $w.file.actions add command -label "replace tune in collection" -font $df\
            -command replace_edited_tune
    $w.file.actions add command -label "quit" -font $df\
            -command confirm_save
    bind .abcedit <Alt-s> tcl_abc_edit_save_as
    bind .abcedit <Alt-S> tcl_abc_edit_save
    #fix    if {$fileseek(0) < 8} {$w.file.actions entryconfigure 0 -state disable}
    
    
    menubutton $w.clean -text clean -font $df \
            -menu $w.clean.type
    menu $w.clean.type -tearoff 0
    $w.clean.type add command -label retag -font $df \
            -command {. config -cursor watch
                update
                tag_text $abctxtw
                . config -cursor arrow
                update}
    $w.clean.type add command -label "erase all" -font $df \
            -command erase_all
    $w.clean.type add command -label "remove redundant guitar chords" \
            -font $df -command {process_buffer remove_redundant_guitar_chords 0}
    $w.clean.type add command -label "remove all guitar chords" \
            -font $df -command {process_buffer remove_guitar_chords 0}
    $w.clean.type add command -label "remove all grace notes" \
            -font $df -command {process_buffer remove_grace_notes 0}
    $w.clean.type add command -label "remove inline voice fields" \
            -font $df -command {process_buffer remove_voice_fields 0}
    $w.clean.type add command -label "remove backslash continuations" \
            -font $df -command {process_buffer remove_backslashes 0}
    $w.clean.type add command -label "remove tab chars" \
            -font $df -command {process_buffer remove_tab_chars 0}
    $w.clean.type add command -label "help" -font $df\
            -command {show_message_page $hlp_clean word
                focus .abc
                raise .abc .abcedit
            }
    
    menubutton  $w.play  -text play -font $df \
            -menu $w.play.type
    menu $w.play.type -tearoff 0
    $w.play.type add command -label line -accelerator <Alt-p><Alt-l> \
            -command {play_from_edit_window line $abctxtw} -font $df
    $w.play.type add command -label selection -accelerator <Alt-p><Alt-s> \
            -command {play_from_edit_window sel $abctxtw} -font $df
    $w.play.type add command -label all \
            -command {play_entire_edit_window 0} -font $df
    $w.play.type add command -label "all verbatim" \
            -command {play_entire_edit_window 1} -font $df
    bind .abcedit <Alt-p><Alt-l> {play_from_edit_window line $abctxtw}
    bind .abcedit <Alt-p><Alt-s> {play_from_edit_window sel $abctxtw}
    
    button $w.undo -text "undo" -relief flat -font $df \
            -command {$abctxtw edit undo; tag_text $abctxtw}
    button $w.redo -text "redo" -relief flat -font $df \
            -command {$abctxtw edit redo; tag_text $abctxtw}
    menubutton $w.tools -text tools -font $df -menu $w.tools.type
    menu $w.tools.type -tearoff 0
    $w.tools.type add cascade     -label transpose  -menu $w.tools.transpose -font $df
    $w.tools.type add cascade -label chords -menu $w.tools.chords -font $df
    $w.tools.type add cascade -label "replace chords" -menu $w.tools.replacechords\
            -font $df
    $w.tools.type add cascade -label "x replace chords" -menu $w.tools.xreplacechords\
            -font $df
    $w.tools.type add command -label "add guitar chords" -command "put_guitar_chords bars" \
            -font $df
    $w.tools.type add command -label "solfege vocalization" -command solfege_vocalization \
            -font $df
    $w.tools.type add command -label drumkit -command drum_editor -font $df
    $w.tools.type add command -label "align bars <Alt-a>" -command bar_align  -font $df
    bind .abcedit <Alt-a> {bar_align}
    $w.tools.type add command -label "squeeze bars" -command bar_squeeze -font $df
    $w.tools.type add command -label "find similar music" -font $df\
            -command transfer_editor_buffer_to_abcmatch
    
    menu $w.tools.transpose -tearoff 0
    $w.tools.transpose add command -label "octave up" -font $df\
            -command {process_buffer shift_all_notes 7}
    $w.tools.transpose add command -label "seventh up" -font $df\
            -command {process_buffer shift_all_notes 6}
    $w.tools.transpose add command -label "sixth up" -font $df\
            -command {process_buffer shift_all_notes 5}
    $w.tools.transpose add command -label "fifth up" -font $df\
            -command {process_buffer shift_all_notes 4}
    $w.tools.transpose add command -label "fourth up" -font $df\
            -command {process_buffer shift_all_notes 3}
    $w.tools.transpose add command -label "third up" -font $df\
            -command {process_buffer shift_all_notes 2}
    $w.tools.transpose add command -label "second up" -font $df\
            -command {process_buffer shift_all_notes 1}
    $w.tools.transpose add command -label "second down" -font $df\
            -command {process_buffer shift_all_notes -1}
    $w.tools.transpose add command -label "third down" -font $df\
            -command {process_buffer shift_all_notes -2}
    $w.tools.transpose add command -label "fourth down" -font $df\
            -command {process_buffer shift_all_notes -3}
    $w.tools.transpose add command -label "fifth down" -font $df\
            -command {process_buffer shift_all_notes -4}
    $w.tools.transpose add command -label "sixth down" -font $df\
            -command {process_buffer shift_all_notes -5}
    $w.tools.transpose add command -label "seventh down" -font $df\
            -command {process_buffer shift_all_notes -6}
    $w.tools.transpose add command -label "octave down" -font $df\
            -command {process_buffer shift_all_notes -7}
    $w.tools.transpose add command -label "help" -font $df\
            -command {show_message_page $hlp_transpose word
                focus .abc
                raise .abc .abcedit
            }
    
    menu $w.tools.chords -tearoff 0
    $w.tools.chords add command -label "2nd" -font $df\
            -command {process_buffer notes2chords -1}
    $w.tools.chords add command -label "3rd" -font $df\
            -command {process_buffer notes2chords -2}
    $w.tools.chords add command -label "4th" -font $df\
            -command {process_buffer notes2chords -3}
    $w.tools.chords add command -label "5th" -font $df\
            -command {process_buffer notes2chords -4}
    $w.tools.chords add command -label "6th" -font $df\
            -command {process_buffer notes2chords -5}
    $w.tools.chords add command -label "7th" -font $df\
            -command {process_buffer notes2chords -6}
    $w.tools.chords add command -label "8th" -font $df\
            -command {process_buffer notes2chords -7}
    $w.tools.chords add command -label "help" -font $df\
            -command {show_message_page $hlp_chords word
                focus .abc
                raise .abc .abcedit
            }
    
    menu $w.tools.replacechords -tearoff 0
    $w.tools.replacechords add command -label "with top note" -font $df\
            -command {process_buffer replace_chord 0}
    $w.tools.replacechords add command -label "with 2nd note" -font $df\
            -command {process_buffer replace_chord 1}
    $w.tools.replacechords add command -label "with 3rd note" -font $df\
            -command {process_buffer replace_chord 2}
    $w.tools.replacechords add command -label "with 4th note" -font $df\
            -command {process_buffer replace_chord 3}
    $w.tools.replacechords add command -label "help" -font $df\
            -command {show_message_page $hlp_replacechord word
                focus .abc
                raise .abc .abcedit
            }
    
    menu $w.tools.xreplacechords -tearoff 0
    $w.tools.xreplacechords add command -label "with top note" -font $df\
            -command {process_buffer replace_chord_x 0}
    $w.tools.xreplacechords add command -label "with 2nd note" -font $df\
            -command {process_buffer replace_chord_x 1}
    $w.tools.xreplacechords add command -label "with 3rd note" -font $df\
            -command {process_buffer replace_chord_x 2}
    $w.tools.xreplacechords add command -label "with 4th note" -font $df\
            -command {process_buffer replace_chord_x 3}
    $w.tools.xreplacechords add command -label "help" -font $df\
            -command {show_message_page $hlp_replacechord word
                focus .abc
                raise .abc .abcedit
            }
    
    
    $w.tools.type add cascade     -label multi-rests  -menu $w.tools.multirests -font $df
    menu $w.tools.multirests -tearoff 0
    $w.tools.multirests add command -label "multi-rests nztoZn" \
            -command {process_buffer multi_rests_nz2Z 0} -font $df
    $w.tools.multirests add command -label "multi-rests Zntonz" \
            -command {process_region multi_rests_Z2nz 0} -font $df
    $w.tools.multirests add command -label "condense whole rests to Zn" \
            -command {process_region edit_condense_whole_rests 0} -font $df
    $w.tools.multirests add command -label "condense whole rests to \"n\"z" \
            -command {process_region edit_condense_whole_rests 1} -font $df
    $w.tools.multirests add command -label "help" \
            -font $df -command {show_message_page $hlp_multirests word
                focus .abc
                raise .abc .abcedit
            }
    
    button $w.find -text "find" -font $df -relief flat -command find_frame
    
    button $w.display -text "display" -font $df -relief flat -command \
            display_entire_edit_window
    
    bind .abcedit <Alt-d> display_entire_edit_window
    
    button $w.help  -text help -font $df -relief flat
    pack $w.file $w.clean $w.undo $w.redo $w.play \
            $w.find $w.tools $w.display $w.help -side left -anchor w
    pack $w -side top -anchor w
    
    bind .abcedit.func.help <Button> {
        if {$barpickerflag} {
            show_message_page $hlp_barpicker word
        } else {
            show_message_page $hlp_editor word}
        focus .abc
        raise .abc .abcedit}
    bind .abcedit <Alt-f> shift_to_next_bar
    bind .abcedit <Alt-b> shift_to_previous_bar
    bind .abcedit <Alt-t> transfer_editor_buffer_to_abcmatch
    bind .abcedit <Alt-r> shift_note_up
    bind .abcedit <Alt-l> shift_note_down
    bind .abcedit <Alt-e> {expand_contract_note 1}
    bind .abcedit <Alt-c> {expand_contract_note 0}
    #    bind .abcedit <Alt-Key-Up> shift_note_up
    #    bind .abcedit <Alt-Key-Down> shift_note_down
    #    bind .abcedit <Alt-Key-Right> {expand_contract_note 1}
    #    bind .abcedit <Alt-Key-Left> {expand_contract_note 0}
}

# Part 10.1           Bar Picker

namespace eval Barpicker {
    
    proc create_picker_interface {} {
        global alreadyloaded
        global df
        set alreadyloaded 1
        set w .abcedit.pane.picker
        if {[winfo exists $w]} {
            voicelist_buttons
            barpicker_buttons
            barselector_control
            return
        }
        frame $w
        pack $w
        voicelist_interface
        barpicker_interface
        frame $w.piece
        entry $w.piece.entry -width 55 -textvariable barpiece -bg "light goldenrod" -font $df
        button $w.piece.update -text update -command Barpicker::update_barpiece -font $df
        label $w.piece.mesg -text "" -font $df
        pack $w.piece.mesg $w.piece.entry $w.piece.update -side left
        pack $w.piece -fill x -expand true
        make_pattern_button_set
        barselector_interface
        clear_pattern_buttons
        if {$alreadyloaded} {
            voicelist_buttons
            barpicker_next_previous 
            barpicker_buttons
            barselector_control
        }
        tooltip::tooltip $w.piece.update  "Paste the contents of entry box into the highlighted\n bar and update the internal representation."
    }
    
    
    proc voicelist_interface {} {
        global nbars voicelist df
        global nvoices_exposed
        set w .abcedit.pane.picker.voicepicker
        frame $w
        pack $w -fill x
        label $w.lab -text voice: -font $df
        grid $w.lab -row 0 -column 0
        set nvoices_exposed 0
    }
    
    proc voicelist_buttons {} {
        global nvoices_exposed
        global voicelist
        global voicepick
        global nvoices
        global df
        set w .abcedit.pane.picker.voicepicker
        #remove all exposed voices (they may have different names)
        foreach v [winfo children $w] {
          destroy $v
          }
        #place new voice selectors
        set i 1
        foreach voice $voicelist {
            radiobutton $w.$i -text $voice -variable voicepick -value $voice\
                    -command "Barpicker::switch_voice" -font $df
            grid $w.$i -row 0 -column $i
            incr i
        }
        set nvoices_exposed $i
        # to avoid potential problems
        if {$i > 1} {$w.1 invoke
            set voicepick [lindex $voicelist 0]
        } else {set voicepick 0}
    }

    proc barpicker_next_previous {} {
        global nbars
	global df
        set w .abcedit.pane.picker.next
        frame $w
        pack $w -fill x -after .abcedit.pane.picker.voicepicker
        button $w.next -text next -font $df -command {Barpicker::change_barpickerblock 1}
        button $w.previous -text previous -font $df -command {Barpicker::change_barpickerblock -1}
        grid $w.previous $w.next 
        if {$nbars > 50} {
        } else {
        pack forget $w
        }
    }
    
    proc barpicker_interface {} {
        global nbars_exposed
        set w .abcedit.pane.picker.barpicker
        # we cannot scroll a frame but we can scroll a canvas. We embed a
        # frame with the radiobuttons into the canvas since gridding the
        # radiobuttons directly into the canvas causes scrolling to fail.
        frame $w -borderwidth 3 -relief sunken
        pack $w -fill x
        frame $w.c
        pack $w.c -side left -fill both -anchor nw
        set nbars_exposed 0
    }
    
    proc barpicker_buttons {} {
        global nbars_exposed
        global nbars
        global df
	global barpickerblock
        set w .abcedit.pane.picker
        pack forget $w.barpicker
        pack $w.barpicker -after $w.voicepicker -expand 1 -fill both
        set w $w.barpicker.c
        if {$nbars_exposed > $nbars} {
            for {set i $nbars} {$i < $nbars_exposed} {incr i} {
                destroy $w.$i
            }
            set nbars_exposed $nbars
        } else {
            for {set i $nbars_exposed} {$i < $nbars} {incr i} {
                radiobutton $w.$i -text $i -width 3 -variable barpick -value $i \
                        -command "Barpicker::show_picked_bar $i" -font $df
                }
            set nbars_exposed $i
        }
	set barpickerblock 0
	show_barpicker_buttons 
    }

    proc show_barpicker_buttons {} {
        global nbars_exposed
        global nbars
	global barpickerblock
        global df
        set w .abcedit.pane.picker.barpicker.c
	set j 0
	set imin [expr $barpickerblock*50]
	set imax [expr $imin + 60]
        for {set i 0} {$i < $nbars} {incr i} {
           set r [expr $j / 10]
           set c [expr $j % 10]
	   if {$i < $imin || $i >= $imax} {
               grid remove $w.$i
           } else {
               grid $w.$i -row $r -column $c
	       incr j
           }
       }
    } 

    proc change_barpickerblock {dir} {
       global barpickerblock
       set barpickerblock [expr $barpickerblock + $dir]
       if {$barpickerblock < 0} {set barpickerblock 0}
       show_barpicker_buttons
       }
    
    proc make_pattern_button_set {} {
        global df
        set w .abcedit.pane.picker
        frame $w.patterns
        pack $w.patterns -fill x -expand true
        for {set n 0} {$n < 8} {incr n} {
            button $w.patterns.$n -text p$n -state disabled -background lightblue -font $df
            pack $w.patterns.$n -side left
        }
        button $w.patterns.clear -text clear -command Barpicker::clear_pattern_buttons -font $df
        button $w.patterns.import -text import  -font $df -command Barpicker::import_drumpatterns
        pack $w.patterns.clear -side left
        pack $w.patterns.import -side left
        tooltip::tooltip $w.patterns.clear  "Initialize all pattern buttons (Pn)"
        tooltip::tooltip $w.patterns.import  "Import drum patterns from drum tool"
    }
    
    proc clear_pattern_buttons {} {
        global npat
        set w .abcedit.pane.picker
        for {set n 0} {$n < 8} {incr n} {
            $w.patterns.$n configure -state disabled
            tooltip::tooltip clear $w.$n
        }
        set npat 0
    }
    
    proc import_drumpatterns {} {
        global npat last_drumpattern
        global pattern drumpatterns
        set npat last_drumpattern
        for {set i 0}  {$i <$last_drumpattern} {incr i} {
            set pattern($i) "$drumpatterns(D$i) |"
            .abcedit.pane.picker.patterns.$i configure -state normal
            .abcedit.pane.picker.patterns.$i configure -state normal -command "Barpicker::putpattern $i"
            tooltip::tooltip .abcedit.pane.picker.patterns.$i $pattern($i)
        }
    }
    
    set npat 0
    
    proc barselector_interface {} {
        global df
        set w .abcedit.pane.picker.barselector
        frame $w -borderwidth 3 -relief sunken
        pack $w -fill x -expand true
        set  w .abcedit.pane.picker.barselector.fun
        frame $w
        pack $w -fill x -expand true
        button $w.resync -text resync -font $df -command {
            Refactor::refactor_textcontents
            Barpicker::create_picker_interface
        }
        button $w.play -text play -command play_section -font $df
        button $w.display -text display -command display_section -font $df
        button $w.save -text save -command Refactor::output_file_direct -font $df
        button $w.debug -text debug -command Refactor::dump_tunepieces -font $df
        grid  $w.resync $w.play $w.display $w.save $w.debug
        tooltip::tooltip $w.resync  "Re-identify all components of the\n noated tune in the text frame."
        tooltip::tooltip $w.play  "Play the section delineated by\nthe sliders below."
        tooltip::tooltip $w.display  "Display the section delineated by\nthe sliders below."
        tooltip::tooltip $w.save  "Save delineated section in the file\n X.tmp as an abc file."
        tooltip::tooltip $w.debug "Display all the fragments of the tune\n in a separate window."
    }
    
    
    proc barselector_control {} {
        global nbars_exposed
        global nbars
        global firstbar lastbar
        global df
        set w .abcedit.pane.picker.barselector
        if {[winfo exist $w.lab1]} {
            $w.end configure -from 0 -to $nbars
            set lastbar $nbars
            return
        }
        label $w.lab1 -text "start bar" -font $df
        label $w.lab2 -text "end bar" -font $df
        set firstbar 0
        set lastbar $nbars
        scale $w.start -from 0 -to $nbars -length 150 -width 10\
                -orient horizontal -variable firstbar -font $df
        scale $w.end -from 0 -to $nbars -length 150 -width 10\
                -orient horizontal -variable lastbar -font $df
        pack $w.lab1 $w.start $w.lab2 $w.end -side left
    }
    
    proc barclick {varname} {
        global tag_id abctxtw
        global barpiece
        global voicelist
        global clickedbar clickedvoice
	global barpickerblock

        if {[info exist tag_id]} {remove_blue_tag $tag_id}
        set tag_id $varname
        add_blue_tag $tag_id
        .abcedit.pane.picker.piece.mesg configure -text "$tag_id" -fg red
        set rangev [$abctxtw tag range $tag_id]
        set apiece ""
        foreach {i1 i2} $rangev {
            append apiece [$abctxtw get $i1 $i2]
        }
        update_barpiece_entry_box $apiece
        if {$tag_id == "head"} return
        set splitag [split $tag_id -]
        if {[lindex $splitag 0] != "x"} {
            set clickedvoice [lindex $splitag 0]
            set clickedbar [lindex $splitag 1]
            set n [lsearch $voicelist $clickedvoice]
            incr n
            .abcedit.pane.picker.voicepicker.$n invoke
            .abcedit.pane.picker.barpicker.c.$clickedbar invoke
	    if {$clickedbar >58} {
               set barpickerblock [expr $clickedbar/50]
	       show_barpicker_buttons
               }
            }
    }
    
    
    proc add_blue_tag {tag_id} {
        global abctxtw
        set rangev [$abctxtw tag range $tag_id]
        foreach {ind1 ind2} $rangev {
            $abctxtw tag add blue $ind1 $ind2
        }
        $abctxtw see [lindex $rangev 1]
    }
    
    proc remove_blue_tag {tag_id} {
        global abctxtw
        set rangev [$abctxtw tag range $tag_id]
        foreach {ind1 ind2} $rangev {
            $abctxtw tag remove blue $ind1 $ind2
        }
    }
    
    
    
    
    
    proc show_picked_bar {i} {
        global tunepieces
        global abctxtw
        global tag_id
        global voicepick
        global pickedbar
        if {[info exist tag_id]} {remove_blue_tag $tag_id}
        set tag_id $voicepick-$i
        set range [$abctxtw tag range $tag_id]
	set curs [lindex $range 0] 
	$abctxtw mark set insert [lindex $range 0]
        set apiece ""
        foreach {i1 i2} $range {
            append apiece [$abctxtw get $i1 $i2]
        }
        Barpicker::update_barpiece_entry_box  $apiece
        $abctxtw see [lindex $range 1]
        add_blue_tag $tag_id
        set pickedbar $i
        .abcedit.pane.picker.piece.mesg configure -text "$tag_id" -fg red
    }
    
    proc switch_voice {} {
        global pickedbar
        if {[info exist pickedbar]} {Barpicker::show_picked_bar $pickedbar}
    }
    
    proc update_barpiece {} {
        #this function handles the button press update in the .picker window.
        #Please see the comments in update_barpiece_entry_box.
        global barpiece
        global tag_id
        #global oldbarpiece oldloc1 oldloc2
        global aoldbarpiece aoldloc1 aoldloc2
        activate_pattern_button $barpiece
        set newpiece $barpiece
        set anewpiece $barpiece
        if {[info exist aoldbarpiece] == 0} return
        if {$aoldbarpiece != ""} {
            set anewpiece [string replace $aoldbarpiece $aoldloc1 $aoldloc2 $barpiece]
        }
        replace_tagged_bar $newpiece $anewpiece
    }
    
    proc replace_tagged_bar {piece apiece} {
        global tag_id
        global abctxtw
        global tunepieces
        #puts "replacing_tagged_bar"
        #puts "apiece = $apiece"
        set range [$abctxtw tag range $tag_id]
        set ind1 [lindex $range 0]
        set ind2 [lindex $range 1]
        $abctxtw replace $ind1 $ind2 $apiece $tag_id
        set tunepieces($tag_id) $apiece
        add_blue_tag $tag_id
    }
    
    proc update_barpiece_entry_box {apiece} {
        global barpiece
        global oldbarpiece oldloc1 oldloc2
        global aoldbarpiece aoldloc1 aoldloc2
        #Anything in the global variable barpiece will show up in the
        #entry box .picker.piece.entry.
        #In the event that piece contains field commands and MIDI comments
        #before the music bar, we wish to trim off the extraneous information
        #prior to placing it in the entry box. We still have to save the
        #original piece, because we must preserve the leading info before
        #putting it back into the tunepieces array and text windows. This
        #is a complication because a bar fragment contain other information
        #that we do not want to destroy when we replace it by one of the
        #patterns in putpattern.
        set abarpiecelist [split $apiece \n]
        if {[llength $abarpiecelist] < 2} {
            set barpiece $apiece
            set abarpiece [lindex $abarpiecelist end]
            set aoldloc1 [string first $abarpiece $apiece]
            set aoldloc2 [expr $aoldloc1 + [string length $barpiece]]
            set aoldbarpiece $apiece
            .abcedit.pane.picker.piece.update configure -state normal
        } else {
            set barpiece ""
            .abcedit.pane.picker.piece.update configure -state disable
        }
    }
    
    set npat 0
    
    proc activate_pattern_button {barpiece} {
        # after doing an update in the .picker window, we save the new bar
        # in a pattern button Pn that we create. This allows us to repeat
        # this pattern in other bars if we wish.
        global npat
        global pattern
        if {$npat > 7} return
        set pattern($npat) $barpiece
        .abcedit.pane.picker.patterns.$npat configure -state normal -command "Barpicker::putpattern $npat"
        tooltip::tooltip .abcedit.pane.picker.patterns.$npat $barpiece
        incr npat
    }
    
    proc putpattern {n} {
        #This function handles pressing one of the pattern button P1,P2, etc
        #in the .picker window.
        global pattern
        global barpiece
        global aoldbarpiece
        global oldloc1 oldloc2 aoldloc1 aoldloc2
        set barpiece $pattern($n)
        set newpiece $barpiece
        set anewpiece $barpiece
        if {[info exist aoldbarpiece] == 0} return
        if {$aoldbarpiece != ""} {
            set anewpiece [string replace $aoldbarpiece $aoldloc1 $aoldloc2 $barpiece]
        }
        replace_tagged_bar $newpiece $anewpiece
    }
    
}

#end of namespace barpicker


set hlp_barpicker "TclMultiVoice Editor\n\n\
        The intent of this editor is to provide a tool for modifying the\
        contents of a voice that is used as an accompaniment to the\
        melody line. These voices would be created using the 'ghchords/drums\
        to voice' toolbox that is accessible through the utilities menu item.\
        The editor allows you to find a particular bar and replace it with\
        another bar which could be part of a small library of bars.\
        Though this was the original intention, the editor is fairly general\
        and could be used for many other purposes as it shares many\
        of the functions of the TclAbcEditor.\n\n\
        When you start the editor, the program fragments the tune into\
        smaller pieces mostly corresponding to individual bars and displays\
        the tune in a editable text window. (You can view this internal\
        representation by clicking on the debug button near the bottom\
        of the window.) The representation in the text window should match\
        the original file with perhaps a few exceptions. For example if a\
        bar is incomplete at the end of a text line (i.e. a | does not\
        end it) then the representation on the screen may be somewhat\
        different. Left clicking the mouse while the pointer is\
        inside any item or bar in the text window will cause that item\
        to be highlighted in blue. If that item is also a bar, then it\
        will also be displayed in the orange entry box below. Though you\
        can edit the contents of the item directly in the text window, the\
        recommended procedure is to change it in the orange entry box\
        and then press the update button. This will also enable one of\
        the blueish p buttons which will store the contents of the entry\
        for future reference. If you wish to replace another\
        bar with the same contents, you would highlight that bar in blue\
        in the same manner and then press the corresponding p button.\
        (You can view the contents of the active p button by hovering\
        the mouse pointer over that button.)\n\n\
        Note if you decide to edit the abc tune directly in the text\
        window, the internal representation of the tune will be out of\
        sync. It is necessary to press the 'resync' button to update the\
        internal representation.\n\n\
        The editor has several other convenient features which allow you\
        to find a particular bar or its matching bar in another voice.\
        There is an array of radio buttons designating the voices and bars\
        occuring below the edit window. When you highlight\
        a particular bar, the voice and bar number is also invoked in the\
        set of radio buttons. If you activate a different radio button,\
        then a different bar will be highlighted in the edit window and\
        placed in the orange entry box.\n\n\
        All the contents of the p memory buttons can be cleared using the\
        'clear' button. The 'import' button works in conjuction with the\
        'drum tool' which should be exposed before pressing that\
        button. The import button will transfer the contents of the D\
        memory buttons to the p buttons. A plain bar marker like | will\
        be added. When repeat markings are needed, you will have to\
        add them manually in the entry window.\n\n\
        The set of buttons and the sliders at the bottom of the window\
        is used to display, play or save a particular section of the\
        tune indicated by the sliders. This is a convenience when you\
        wish to test out only a particular section of the tune.\n\n\
        Finally, if you right click the mouse while the pointer is\
        anywhere in the text window, a small pop up menu will appear.\
        This saves you the effort of having to move the mouse button\
        to one of the top menu buttons.
"



proc tcl_abc_edit_copy_global_header {} {
    global abctxtw
    global fileseek
    global midi
    set handle [open $midi(abc_open) r]
    fconfigure $handle -encoding $midi(encoder)
    set header [read $handle $fileseek(0)]
    puts $header
    $abctxtw insert 1.0 $header
    close $handle
}

proc tcl_abc_edit_save {} {
    global midi
    global abctxtw
    if {[string compare $midi(abc_save) $midi(abc_default_file)] == 0 \
                || [llength $midi(abc_save)] == 0} set_abc_save
    if {[llength $midi(abc_save)] >0} {
        Text_Dump $abctxtw
        $abctxtw edit modified 0
    }
}

proc tcl_abc_edit_save_as {} {
    global midi
    global abctxtw
    set_abc_save
    if {[llength $midi(abc_save)] >0} {
        Text_Dump $abctxtw
        $abctxtw edit modified 0}
}


proc find_forwards {} {
    global findstring
    global abctxtw
    set point [$abctxtw index insert]
    set lastline [$abctxtw index end]
    if {[$abctxtw compare $point >= $lastline]} {
        set point 1.0} else {
        set point "$point+1 chars"}
    set point [$abctxtw search -forwards $findstring $point]
    if {[llength $point]>0} {
        $abctxtw mark set insert $point
        $abctxtw see $point
        focus $abctxtw
    }
}


proc find_backwards {} {
    global findstring
    global abctxtw
    set point [$abctxtw index insert]
    set lastline [$abctxtw index end]
    if {[$abctxtw compare $point >= $lastline]} {
        set point 1.0}
    set point [$abctxtw search -backwards $findstring $point]
    if {[llength $point]>0} {
        $abctxtw mark set insert $point
        $abctxtw see $point
        focus $abctxtw
    }
}


proc locate_barnum {} {
    #returns the position of the findbarnum barline
    global findbarnum body_start body_end
    global abctxtw
    set p {\|+}
    set point [$abctxtw index insert]
    set selstart [lindex [split $point .] 0]
    if {$selstart > $body_end} {
        set point $body_start.0
        set selstart [lindex [split $point .] 0]
    }
    set selstart $selstart.0
    set start [$abctxtw search -backwards X: $selstart]
    set start [lindex [split $start .] 0]
    set linend [$abctxtw index "end -1 char"]
    set linend [lindex [split $linend .] 0]
    incr start
    set bcount 1;
    for {set index $start} {$index < $linend} {incr index} {
        set value [$abctxtw get $index.0 $index.end]
        if {[string length $value] < 2} continue
        set initial [string index $value 0]
        set next [string index $value 1]
        if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
            >= 0 && $next == ":" } {
            if {[string equal $initial X] == 1} break else continue
        }
        set begin 0
        set result 1
        while {$result} {
            set result [regexp -start $begin -indices $p $value loc]
            if {$result} {set begin [lindex $loc 1]
                if {$bcount == $findbarnum} {return $index.$begin}
                incr begin
                incr bcount
            }
        }
    }
    return $index.$begin
}


proc find_barnum {} {
    global abctxtw
    set point [locate_barnum]
    $abctxtw mark set insert $point
    $abctxtw see $point
    focus $abctxtw
}


proc find_frame {} {
    global findstring df
    global findbarnum
    set findbarnum 1
    set p .abcedit.find
    if {[winfo exists .abcedit.find] == 0} {
        frame $p
        entry $p.en -textvariable findstring -width 24 -font $df
        button $p.forwards -text forwards -font $df
        button $p.backwards -text backwards -font $df
        button $p.bar -text barline -font $df
        entry  $p.barnum -textvariable findbarnum -width 3 -font $df
        button $p.close -text close -font $df \
                -command {destroy .abcedit.find}
        pack $p.en $p.forwards $p.backwards $p.bar $p.barnum $p.close -side left -anchor w
        pack .abcedit.find -after .abcedit.func -anchor w
        bind .abcedit.find.en  <Return> find_forwards
        bind .abcedit.find.forwards <Button> find_forwards
        bind .abcedit.find.backwards <Button> find_backwards
        bind .abcedit.find.bar <Button> find_barnum
    } else {
        focus .abcedit.find
    }
}

proc shift_to_next_bar {} {
    global abctxtw
    set nextbar [$abctxtw search | insert]
    $abctxtw mark set insert "$nextbar+1 char"
}

proc shift_to_previous_bar {} {
    global abctxtw
    set nextbar [$abctxtw search -backwards | insert]
    $abctxtw mark set insert "$nextbar-1 char"
    set nextbar [$abctxtw search -backwards | insert]
    $abctxtw mark set insert "$nextbar+1 char"
}

proc erase_all {} {
    global abctxtw
    $abctxtw delete 1.0 end
}

proc set_abc_save {} {
    global midi types
    set filedir [file dirname $midi(abc_save)]
    set midi(abc_save) [tk_getSaveFile -initialdir $filedir -filetypes $types]
}


proc Text_Dump {t {start 1.0} {end end}} {
    global midi
    
    set outhandle [open $midi(abc_save) w]
    foreach {key value index} [$t dump $start $end] {
        if {$key == "text"} {
            puts -nonewline $outhandle $value}
    }
    close $outhandle
    if {$midi(bell_on)} bell
}


proc tag_text {abctxtw} {
    global body_start body_end midi
    global midi
    set t $abctxtw
    set body_start {}
    set tocfb [font create -family $midi(font_family_toc)\
            -size $midi(font_size)  -weight bold]
    $t configure -selectbackground $midi(edit_selectbackground)
    $t tag delete "field" "body" "comment" "barline" "guitar"
    $t  tag configure "body"  -foreground $midi(edit_body_colour)
    $t  tag configure "field" -foreground $midi(edit_field_colour)
    $t  tag configure "comment" -foreground $midi(edit_comment_colour)
    $t  tag configure "barline" -foreground $midi(edit_barline_colour)  -font $tocfb
    $t  tag configure "guitar" -foreground $midi(edit_guitar_colour)
    set index [$t index "end -1 char"]
    set lines [lindex [split $index .] 0]
    for {set index 1} {$index < $lines} {incr index} {
        tag_text_line $index $abctxtw
        if {[llength $body_start] == 0} {set body_start $index}
        set body_end $index
    }
}

proc tag_line {abctxtw} {
    set loc [$abctxtw index insert]
    set lineloc [lindex [split $loc .] 0]
    tag_text_line $lineloc $abctxtw
}

proc tag_text_line {no abctxtw} {
    set t $abctxtw
    set value [$t get $no.0 $no.end]
    if {[string length $value] < 2} return
    set initial [string index $value 0]
    set next [string index $value 1]
    if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
        >= 0 && $next == ":" } {
        $t tag add "field" $no.0 $no.end
        set inbody 0
    } elseif {$initial == "%"} {
        $t tag add "comment" $no.0 $no.end
        set inbody 0
    } else {
        $t tag add "body" $no.0 $no.end
        set inbody 1
    }
    # tag bar lines
    if {$inbody} {tag_bar_lines $no $value $abctxtw
        tag_guitar_chords $no $value $abctxtw}
}


proc tag_bar_lines {lineno line abctxtw} {
    set start 0
    set loc 0
    while {$loc >= 0} {
        set loc [string first "|" $line $start]
        if {$loc <0} break
        set start [expr $loc +1]
        set loc1 [expr $loc-1]
        set loc2 [expr $loc+1]
        if {[string index $line $loc1] == ":"} {set loc $loc1}
        if {[string index $line $loc2] == ":"} {set loc2 [expr $loc2 +1]}
        $abctxtw tag add "barline" $lineno.$loc $lineno.$loc2
    }
}

proc tag_guitar_chords {lineno line abctxtw} {
    set start 0
    set loc 0
    $abctxtw tag remove "guitar" $lineno.0 "$lineno.0 lineend"
    while {$loc >= 0} {
        set loc [string first "\"" $line $start]
        if {$loc <0} break
        set start [expr $loc +1]
        set loc2 [string first "\"" $line $start]
        if {$loc2 > 0} {
            set loc2 [expr $loc2+1]
            $abctxtw tag add "guitar" $lineno.$loc $lineno.$loc2
            set start [expr $loc2 +1]
        }
    }
}



proc play_from_edit_window {mode abctxtw} {
    # The function is designed to play a short extract from
    # which has been selected from the editor. It searches
    # for the X: code preceding the selected region and
    # copies all the field commands preceding into the
    # X.tmp file. The rest of the body is ignored and
    # the selected portion of pasted in. abc2midi is
    # executed to produce a midi file X1.mid which is then
    # using the selected protocol played.
    # We check that the user has selected a region or
    # indicated an insert point in the body; otherwise
    # we just play the first line in the body.
    global midi exec_out files
    global body_start body_end
    # midioutput is used for internals/mftext of output midi
    global midioutput
    set files ""
    lappend files X1.mid
    set midioutput X1.mid

    #set cmd "file delete [glob -nocomplain $dir/X*.mid]"
    set cmd "file delete [glob -nocomplain *.mid]"
    catch {eval $cmd}
    set out_fd [open X.tmp w]
    
    if {[info exists body_end] == 0} {tag_text $abctxtw}
    
    if {[string compare $mode line] == 0} {
        set point [$abctxtw index insert]
	puts "point = $point"
        set selstart [lindex [split $point .] 0]
        if {$selstart > $body_end} {
            set point $body_start.0
            set selstart [lindex [split $point .] 0]
        }
        set selend $selstart.end
        set selstart $selstart.0
        $abctxtw tag add sel $selstart $selend
        update
    } else {
        set selrange [$abctxtw tag ranges sel]
        if {[llength $selrange] < 2} {
            set selrange [list $body_start.0 $body_start.end]
            set selstart [lindex $selrange 0]
            set selend [lindex $selrange 1]
            $abctxtw tag add sel $selstart $selend
            update
        } else {
            set selstart [lindex $selrange 0]
            set selend [lindex $selrange 1]
        }
    }
    set linend [lindex [split $selend .] 0]
    set start [$abctxtw search -backwards X: $selstart]
    set start [lindex [split $start .] 0]
    puts $out_fd "X: 1"
    write_midi_codes $out_fd
    for {set index $start} {$index < $linend} {incr index} {
        set value [$abctxtw get $index.0 $index.end]
        set initial [string index $value 0]
        set next [string index $value 1]
        if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
            > 0 && $next == ":" } {
            if {[string compare $initial "X"] != 0} {puts $out_fd $value}
        } elseif {$initial == "%"} {
            puts $out_fd $value}
    }
    set value [$abctxtw get $selstart $selend]
    puts $out_fd $value
    puts $out_fd "\n\n"
    close $out_fd
    set cmd "exec $midi(path_abc2midi) X.tmp"
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    play_midis 1
    update_console_page
}


# Part 10.2               Guitar Chord ToolBox


#source guitar.tcl

set keyorder CDEFGABCDEFGAB
global keyorder


proc setkeymap {sf} {
    # work out accidentals to be applied to each note
    # sf; /* number of sharps in key signature -7 to +7
    global keymap
    array set keymap {C C D D E E F F G G A A B B}
    if {$sf >= 1} {set keymap(F) F# }
    if {$sf >= 2} {set keymap(C) C# }
    if {$sf >= 3} {set keymap(G) G# }
    if {$sf >= 4} {set keymap(D) D# }
    if {$sf >= 5} {set keymap(A) A# }
    if {$sf >= 6} {set keymap(E) E# }
    if {$sf >= 7} {set keymap(B) B# }
    if {$sf <= -1} {set keymap(B) Bb }
    if {$sf <= -2} {set keymap(E) Eb }
    if {$sf <= -3} {set keymap(A) Ab }
    if {$sf <= -4} {set keymap(D) Db }
    if {$sf <= -5} {set keymap(G) Gb }
    if {$sf <= -6} {set keymap(C) Cb }
    if {$sf <= -7} {set keymap(F) Fb }
}


proc showkeys {from} {
    global keyorder keymap
    for {set i 0} {$i < 8} {incr i} {
        set key [string index $keyorder [expr $i +$from]]
        set key $keymap($key)
        puts $key
    }
}


proc keytosf {keysig} {
    #from key signature computes number of sharps/flats, mode
    #and first key in scale.
    global mode tonic modename
    set s [regexp {([A-G]|none)(#*|b*)(.*)} $keysig match tonic sub2 modename]
    if {$s < 1} {puts "can't understand key signature $keysig"
        return}
    #puts "$tonic $sub2 $modename"
    if {[string compare $tonic "none"] == 0} {set tonic C}
    set sf [expr [string first $tonic FCGDAEB] -1]
    if {$sub2 == "#"} {set sf [expr $sf + 7]}
    if {$sub2 == "b"} {set sf [expr $sf - 7]}
    if {[string length $modename] > 0} {set modename [string tolower $modename]} else {
        set modename "maj"
        }
    if {[string length $modename] > 3} {set modename [string range $modename 0 2 ]}
    if {$modename == "m"} {set modename "min"}
    set mode [lsearch -exact "maj min m aeo loc ion dor phr lyd mix" $modename]
    if {$mode == -1} {set mode 0}
    #puts "mode = $mode"
    if {$mode >= 0} {set sf \
                [expr $sf - [lindex "0 3 3 3 5 0 2 4 -1 1" $mode]]}
    #puts $sf
}



proc shift_note_wrap {note shift} {
    global notekey
    set n [string first [string index $note 0] $notekey]
    set n [expr $n + $shift]
    if {$n > 6} {set n [expr $n - 7]}
    set result [string index $notekey $n]
    return $result
}


proc guitar_toolbox {keysig} {
    global df
    global keyorder keymap
    global tonic mode modename
    global rootname triadname chordno
    global progression
    global preferredchords
    global chordtype
    # thanks to James Allwright for writing the original code in C
    # (parsekey and event_key see parseabc.c and store.c).
    set chordtype {0 1 1 0 0 1 2 0 1 1 0 0 1 1}
    set modeloc {0 5 5 5 6 0 1 2 3 4}
    set progression(0) {any}
    set progression(1) {6 4}
    set progression(2) {3 5}
    set progression(3) {2 4 6 0}
    set progression(4) {0}
    set progression(5) {1 3}
    set progression(6) {0}
    if {[string compare $keysig HP] == 0} {set keysig A}
    if {[string compare $keysig hp] == 0} {set keysig A}
    if {[string compare $keysig none] ==0} {set keysig C}
    set sf  [keytosf $keysig]
    #puts "guitar_toolbox modename = $modename"
    setkeymap $sf
    #puts "preferred chords = $preferredchords($modename)"
    set i1 [string first $tonic $keyorder]
    set i2 [lindex $modeloc $mode]
    set g .abcedit.pane.toolbox.guitartool
    if {[winfo exists $g]} {destroy $g}
    frame $g -borderwidth 2 -relief sunken
    
    # create list of harmonic triads for this key signature
    for {set i 0} {$i < 7} {incr i} {
        set k [string index $keyorder [expr $i1+$i]]
        set majmin ""
        if {[lindex $chordtype [expr $i2+$i]] == 1} {set majmin m}
        if {[lindex $chordtype [expr $i2+$i]] == 2} {set majmin dim}
        #  puts "$i2+$i $majmin"
        set rootname($i) $keymap($k)
        set key $keymap($k)
        set triadname($i) $key$majmin
    }
    
    
    #create chord type menu
    set gchordtypes { " " m  7  m7  maj7\
                M7  6  m6  aug  +\
                aug7  dim  dim7  9\
                m9  maj9  M9 11  dim9\
                sus  sus9  7sus4  7sus9  5}
    
    menubutton $g.ctypes -menu $g.ctypes.items -text types -font $df -relief raised -width 10
    menu $g.ctypes.items -tearoff 0
    set i 0
    set flag 0
    foreach item $gchordtypes {
        $g.ctypes.items add radiobutton -label $item -columnbreak $flag -font $df\
                -value $i -variable gtype -command "qualifychord $item"
        incr i
        set flag [expr $i % 5 == 0]
    }
    
    
    menubutton $g.invert -menu $g.invert.items -text inversion -font $df\
            -relief raised -width 10
    menu $g.invert.items -tearoff 0
    $g.invert.items add radiobutton -label none -font $df -command {invertchord 0}
    $g.invert.items add radiobutton -label first -font $df -command {invertchord 1}
    $g.invert.items add radiobutton -label second -font $df -command {invertchord 2}

    button $g.main -text main -font $df -command preferredchords_interface -width 8
    tooltip::tooltip $g.main "For specifying the principle chords to use for each mode."
    
    if {[string length $keysig] > 15} {set keysig [string range $keysig 0 15]...}
    label $g.lab -text "guitar chords for $keysig" -font $df
    grid $g.lab -columnspan 3 
    
    set chordno 0
    radiobutton $g.0 -text $triadname(0) -font $df  -indicatoron 1\
            -command "insert_chord $triadname(0)" -padx 1 -value 0 -variable chordno
    
    for {set i 1} {$i < 7} {incr i} {
        radiobutton $g.$i -text $triadname($i)  -font $df \
                -command "insert_chord $triadname($i)" -value $i -variable chordno
    }
    grid $g.0 $g.1 $g.2 -sticky w
    grid $g.3 $g.4 $g.5 -sticky w
    grid $g.6 -sticky w
    
    button $g.help -text help -width 8 -font $df\
            -command {show_message_page $hlp_guitar word
                focus .abc
                raise .abc .abcedit
            }
    menubutton $g.auto -menu $g.auto.items -text auto -font $df\
            -relief raised -width 10
    menu $g.auto.items -tearoff 0
    $g.auto.items add command -label "once per bar" -font $df -command {put_guitar_chords 1}
    $g.auto.items add command -label "twice per bar" -font $df -command {put_guitar_chords 2}
    $g.auto.items add command -label "three times per bar" -font $df -command {put_guitar_chords 3}
    $g.auto.items add command -label "four times per bar" -font $df -command {put_guitar_chords 4}
    tooltip::tooltip $g.auto "Automatically insert guitar chords"
    label $g.prog -text "" -font $df
    button $g.refresh -text refresh -font $df -command guitar_chord -width 8
    tooltip::tooltip $g.refresh "Recompute the guitar chords to use for the most recent mode."
    grid $g.help $g.refresh $g.ctypes 
    grid $g.invert $g.main $g.auto
    grid $g.prog -columnspan 3
    possible_progression
    #puts "modename = $modename"
    highlight_main_chords $preferredchords(maj)
}


proc qualifychord {{typeno ""}} {
    #appends chordtype to triad and updates chord selector
    global keyorder keymap
    global rootname triadname chordno
    set triadname($chordno) $rootname($chordno)$typeno
    set g .abcedit.pane.toolbox.guitartool
    $g.$chordno configure -text $triadname($chordno) -command "insert_chord $triadname($chordno)"
}


proc invertchord order {
    global triadname rootname chordno
    global keymap
    set key $rootname($chordno)
    set key [shift_note_wrap $key [expr $order*2]]
    set key $keymap($key) ;# add sharps or flats for key signature
    set g .abcedit.pane.toolbox.guitartool
    if {$order == 0} {
        $g.$chordno configure -text $triadname($chordno)\
                -command "insert_chord $triadname($chordno)" } else {
        $g.$chordno configure -text $triadname($chordno)/$key\
                -command "insert_chord $triadname($chordno)/$key"
    }
}


array set roman2arabic {I 1 II 2 III 3 IV 4 V 5 VI 6 VII 7}

proc highlight_main_chords {mainchords} {
    global roman2arabic
    set g .abcedit.pane.toolbox.guitartool
    for {set i 1} {$i < 7} {incr i} {
      $g.$i configure -fg grey32 
      }
    #puts "mainchords = $mainchords"
    foreach chord $mainchords {
        #eliminate trailing o if present (for diminished)
        set chord [string map {o ""} $chord]
        set i [string toupper $chord]
        set i $roman2arabic($i)
        incr i -1
        #puts $i
        $g.$i configure -fg black
        }
    }



proc possible_progression {} {
    global triadname chordno
    global progression
    set output ""
    if {[string equal any $progression($chordno)]} {set output "any chord"} else {
        foreach chord $progression($chordno) {
            set output "$output $triadname($chord) "
        }
    }
    .abcedit.pane.toolbox.guitartool.prog configure -text $output
}


proc insert_chord {chord} {
    #puts or replaces a chord in the TclAbcEditor editor text.
    #is there a guitar code already there?
    global abctxtw
    set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]\'*|z)(/?[0-9]*|[0-9]*/*[0-9]*)}
    #puts "insert_chord"
    possible_progression
    set nextbar [$abctxtw search | insert end]
    if {$nextbar == ""} return
    set nextnote [$abctxtw search  -regexp  -- $notepat insert $nextbar]
    set chordbegin [$abctxtw search \"  insert $nextbar]
    #puts "nextbar = $nextbar"
    #puts "nextnote = $nextnote"
    #puts "chordbegin = $chordbegin"
    
    if {[info exists nextbar] == 0} {
        $abctxtw insert insert "\"$chord\" " guitar
        return}
    
    if {$chordbegin == ""} {
        set lastinsert [$abctxtw index insert]
        $abctxtw insert insert "\"$chord\""  guitar
        $abctxtw mark set insert $lastinsert
        return}
    
    if {$chordbegin && $nextnote && [$abctxtw compare $nextnote < $chordbegin]} {
        set lastinsert [$abctxtw index insert]
        $abctxtw insert insert "\"$chord\""  guitar
        $abctxtw mark set insert $lastinsert
        return}
    
    set chordend [$abctxtw search \" "$chordbegin+1 char" $nextbar]
    #puts $chordend
    $abctxtw delete $chordbegin "$chordend +1 char"
    $abctxtw mark set insert $chordbegin
    $abctxtw insert insert "\"$chord\"" guitar
    $abctxtw mark set insert $chordbegin
}

set hlp_guitar "Guitar tool box\n\n\
        The tool box assists you in inserting guitar chords \
        (eg. \"Cm\") into the tune. When the tool box is created, the program \
        examines the preceding key signature and displays some of the guitar \
        chords that are appropriate for this key signature. The program recognizes \
        the major and minor key signatures as well as the various modes (eg. Ddor).\n\n\
        Instructions: to insert a guitar chord, position the insert \
        point of the editor where the chord is to be inserted \
        and then click the radio button of the desired chord. To replace\
        an existing guitar chord, position the insert before the guitar\
        chord and click the button of the desired chord. The `type' menubutton\
        allows you to change the type of chord that was selected. This will\
        remain the default as long as you don't do a refesh or move to another\
        file. After changing the type of chord, you should click on that chord\
        again in order to replace this chord in the text window. Note that\
        not all chords in the menu may be appropriate (ie. major versus minor);\
        however, these are all the chord types which abc2midi understand. The\
        inversion button allows you to invert the chord and make it a default.\
        The first inversion is indicated with a slash followed by the lowest note\
        in that chord (eg. C/E).\n\n\
        Following the chords is a list of other chords\
        which would follow in the progression. This is only for your information.\n\n\
        You can also move the insert point one bar at a time\
        using the <alt-f> and <alt-b> keys on your keyboard. You can listen to\
        the chord by using the <alt-p>  <alt-l> keys.\n\n\Note: if the key signature\
        changes and you wish to update the tool bar, merely position the insert\
        marker after the key change (indicated by the K: field command), and\
        click the refresh button. The chords in the toolbox will be replaced\
        with the new chords appropriate for this key signature.\n

The auto button, will insert guitar chords into the entire tune\
	automatically using a built in algorithm. The algorithm will\
	restrict the inserted guitar chords to a limited set which\
	you can modify by clicking the button labeled main. A new\
        window called preferred_chords will appear and the chosen\
	chords are shown in red for each mode. Clicking on that chord\
	changes its colour and status."

#end of guitar.tcl


proc guitar_chord {} {
    #identifies key signature and puts up appropriate chord toolbar.
    global abctxtw
    global body_start body_end
    set point [$abctxtw index insert]
    if {![info exist body_end]} return
    if {$point > $body_end} {set point $body_start.0}
    set keysig none
    set kfield [$abctxtw search -backwards K: $point]
    if {[string length $kfield] > 1} {
        set kfield [$abctxtw get $kfield  "$kfield lineend"]
        set keysig [string range $kfield 2 end]
        set keysig [string trimright $keysig]
    }
    if {[string equal [string trimleft $keysig] none]} {set keysig C}
    guitar_toolbox $keysig
    grid .abcedit.pane.toolbox.guitartool -row 0 -sticky w
}



# Part 10.3             Transposition ToolBox


#transpose.tcl

set notekey "CDEFGABcdefgab"

proc shift_note_up {} {
    shift_single_note 1
}

proc shift_note_down {} {
    shift_single_note -1
}


proc shift_single_note {shift} {
    global abctxtw
    #method: grab line, find note, change note, replace line
    #this is a messy method but I could not figure out a simpler way.
    set note {[A-G]\,*|[a-g]\'*}
    set point [$abctxtw index insert]
    set selstart [lindex [split $point .] 0]
    set charstart [lindex [split $point .] 1]
    set to $selstart.end
    set from  $selstart.0
    set tmp [$abctxtw get $from $to]
    set success [regexp  -start $charstart -indices  $note $tmp match]
    if {!$success} return
    set pos1 [lindex $match 0]
    set pos2 [lindex $match 1]
    set key [string range $tmp  $pos1 $pos2]
    set newkey [shift_note $key $shift]
    set tmp [string replace $tmp $pos1 $pos2 $newkey]
    $abctxtw delete $from $to
    $abctxtw insert $from $tmp body
    $abctxtw mark set insert $point
}


proc shift_all_notes {buffer shift} {
    #scans line for musical notes and shifts it up or down.
    #In order to continue from where we left off, we strip
    #off the part of string that we have already scanned,
    #and keep track of the amount we stripped in the variable
    #offset plus any expansion or contraction of note (eg. b to c').
    set note {[A-G]\,*|[a-g]\'*}
    # decorations regex explained:
    # (?n) - honor lines:  ^ and $
    # (\![^\!]*\!)           - !decoration!
    # (^[ \t]*%.*$)          - comment lines (lines beginning with %)
    # (^[ \t]*[A-Za-z]:.*$)  - keyword lines
    # (\![^\!]*\!)           - !decoration!
    # (\[[ \t]*\"[^\"]*\"))  - part strings "part1"   (probably should be any strings, including guitar chords)
    #   (\"[^\"]*\")	   - guitar chords
    #   (\[.:[^]]*\])       - inline field command like [K: Gm]
    set decoration {(?n)((\![^\!]*\!)|(^[ \t]*%.*$)|(^[ \t]*[A-Za-z]:.*$)|(\[[ \t]*\"[^\"]*\"))|(\"[^\"]*\")|(\[.:[^]]*\])}
    set tmp $buffer
    set success 1
    set offset 0
    while {$success} {
        set success [regexp -indices $note $tmp match]
        if {!$success} break
        set skip [regexp -indices $decoration $tmp match_skip]
        # if the decoration comes before the note then skip the decoration
        if {$skip && [lindex $match_skip 0] < [lindex $match 0]} {
            set pos2 [lindex $match_skip 1]
            set offset [expr $offset + $pos2 + 1]
            set tmp [string range $buffer $offset end]
        } else {
            set pos1 [lindex $match 0]
            set pos2 [lindex $match 1]
            set key [string range $tmp  $pos1 $pos2]
            set newkey [shift_note $key $shift]
            #      puts "$key $newkey"
            set tmp [string range $tmp [expr $pos2 +1] end]
            set apos1 [expr $pos1 + $offset]
            set apos2 [expr $pos2 + $offset]
            set buffer [string replace $buffer $apos1 $apos2 $newkey]
            set offset [expr $offset + $pos1 + [string length $newkey]]
            #      puts "$offset $pos1 $pos2"
        }
    }
    return $buffer
}




proc shift_note {note shift} {
    # shift note by a given musical interval,up or down.
    # 1 or -1 is second
    # 2 or -2 is third...
    global notekey
    set n [string first [string index $note 0] $notekey]
    set m [expr [string length $note] - 1]
    if {$n < 7 && $m >0} {set m [expr -$m] }
    set n [expr $n + $shift]
    if {$n>13} {set n [expr $n - 7]
        incr m
    } elseif {$n<0} {set n [expr $n + 7]
        incr m -1
    }
    if {$n < 7 && $m>0} {
        set n [expr $n + 7]
        incr m -1
    } elseif {$n > 6 && $m<0} {
        set n [expr $n - 7]
        incr m
    }
    set result [string index $notekey $n]
    if {$m > 0} {set suffix [string repeat "'" $m]
        set result $result$suffix
    } elseif {$m < 0} { set m [expr -$m]
        set suffix [string repeat "," $m]
        set result $result$suffix
    }
    return $result
}


# Part 10.4             Note Length ToolBox


proc note_length_value {len} {
    set pat1 {(\d)}
    set pat2 {/(\d)}
    set pat3 {(\d)/(\d)}
    if {[regexp $pat3 $len match n1 n2]} {
        return  $len}
    if {[regexp $pat2 $len match n1]} {
        #   puts $match
        return 1$len}
    if {[regexp $pat1 $len match n1]} {
        #   puts $match
        return $len/1}
    switch $len {
        / {return 1/2}
        // {return 1/4}
        /// {return 1/8}
        default {return $len}
    }
}


proc combinefractions {frac1 frac2 dir} {
    # adds or subtracts fraction1 to fraction2 and returns a fraction
    set pat3 {([0-9]+)/([0-9]+)}
    #puts "combinefraction $frac1 $frac2"
    if {![regexp $pat3 $frac1 match n1 n2]} {return $frac1}
    if {![regexp $pat3 $frac2 match m1 m2]} {return $frac1}
    set k1 [expr $n1*$m2+$dir*$n2*$m1]
    set k2 [expr $n2*$m2]
    return [euclid $k1 $k2]
}


proc euclid {a b} {
    if {$a > $b} {
        set n $a
        set m $b} else {
        set n $b
        set m $a}
    
    while {$m != 0} {
        set t [expr $n % $m]
        set n $m
        set m $t
    }
    
    set a [expr $a/$n]
    set b [expr $b/$n]
    return [list $a $b]
}


proc expand_notelength {length} {
    set pat3 {([0-9]+)/([0-9]+)}
    set success [regexp $pat3 $length match n1 n2]
    #puts "expand_notelength $length $match $n1 $n2"
    if {$success} {
        if {$n1 == 1} {
            set incre 1/[expr $n2*2]} else {
            set incre 1/$n2}
        set newlength [combinefractions $length $incre 1]
        #  puts "newlength $newlength"
        set num [lindex $newlength 0]
        set denom [lindex $newlength 1]
        #  skip invalid multipliers
        switch $num {
            5 {return [list 6 $denom]}
            9 -
            10 -
            11 {return [list 12 $denom]}
            13 {return [list 14 $denom]}
            default {return $newlength}
        }
    }
}


proc contract_notelength {length} {
    set pat3 {([0-9]+)/([0-9]+)}
    set success [regexp $pat3 $length match n1 n2]
    #puts "contract_notelength = $n1 $n2"
    if {$success} {
        if {$n1 == 1} {
            set incre 1/[expr 4*$n2]} else {
            set incre 1/$n2}
        set newlength [combinefractions $length $incre -1]
        set num [lindex $newlength 0]
        set denom [lindex $newlength 1]
        #  skip invalid multipliers
        switch $num {
            5 {return [list 4 $denom]}
            9 -
            10 -
            11 {return [list 8 $denom]}
            13 {return [list 12 $denom]}
            default {return $newlength}
        }
    }
}



proc expand_contract_note {dir} {
    global abctxtw
    #method: grab line, find note, change note, replace line
    #this is a messy method but I could not figure out a simpler way.
    #set note {[A-G]\,*|[a-g]\'*}
    set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]\'*|z)(/?[0-9]*|[0-9]*/*[0-9]*)}
    set point [$abctxtw index insert]
    set selstart [lindex [split $point .] 0]
    set charstart [lindex [split $point .] 1]
    set to $selstart.end
    set from  $selstart.0
    set tmp [$abctxtw get $from $to]
    set success [regexp  -start $charstart -indices  $notepat $tmp match]
    if {!$success} {puts "no note found"; return}
    set pos1 [lindex $match 0]
    set pos2 [lindex $match 1]
    
    #puts "note = $match"
    set keystr [string range $tmp $pos1 $pos2]
    regexp $notepat $keystr match acc key len
    if {$len == ""} {set len 1}
    #puts "extracted length = $len"
    set len [note_length_value $len]
    #puts "expand_contract_note: len = $len"
    
    #set len [expand_notelength $len]
    if {$dir} {set len [expand_notelength $len]
    } else {
        set len [contract_notelength $len]
    }
    #puts "new notelength $len"
    if {[lindex $len 1] == 1} {
        set len [lindex $len 0]
    } elseif {[lindex $len 0] == 1} {
        set len /[lindex $len 1]
    } else {
        set len [lindex $len 0]/[lindex $len 1]
    }
    #puts "expanded length $len"
    
    #set key [string range $tmp  $pos1 $pos2]
    if {$len != 1} {set newkey $acc$key$len
    } else {set newkey $acc$key}
    set tmp [string replace $tmp $pos1 $pos2 $newkey]
    $abctxtw configure -autoseparators False
    $abctxtw edit separator
    $abctxtw delete $from $to
    $abctxtw insert $from $tmp body
    $abctxtw configure -autoseparators True
    $abctxtw mark set insert $point
}



set hlp_transpose "Transpose function\n\n\
        The purpose of this function is to assist you in \
        creating a harmony line. First copy the music body and make it into \
        a separate voice. Then select a section of the voice by highlighting \
        it and then transpose it a certain number of intervals up or down. The \
        colour of the transposed section will be turned to black to make \
        it stand out. If you click the retag window it will be back to normal.\n\n\
        The function should ignore anything that is not a note, for example\
        guitar chords, comments and field commands however it may occasionally\
        make a mistake."


# Part 10.5           Editor Clean Functions

set hlp_clean "	Clean functions\n\n\
        retag:   color the comments, field comments and body of the edit window.\n\
        erase all:  clear the contents of the edit window.\n\n\
        The remaining functions require you to first select a region in the \
        body of the abc file (usually displayed as red).\n\
        remove redundant guitar chords: repeated guitar chords are deleted\
        in the selected area.\n\
        remove all guitar chords: all guitar chords enclosed in double quotes\
        are deleted in the selected area.\n\
        remove all grace notes: all ornaments and grace notes enclosed in\
        curly braces are removed.\n\
        remove inline voice fields: removes all occurring \[V:n\] indications\
        inside the selected area.\n\
        remove backslash continuations: removes the backslashes (typically at\
        the end of line) in the selected area.\n\
        remove tab chars: removes tabs in selected area.\n\n
Caution: guitar chords are recognized as pairs of double quotes. If your \
        selected area begins in the middle of a guitar chord, the function will \
        probably remove everything accept the guitar chords. The same also applies \
        to grace notes."

proc remove_guitar_chords {line dummy} {
    regsub -all  {"[^"]*"} $line "" result
    return $result
}

proc remove_redundant_guitar_chords {buffer dummy} {
    set pat {"[^"]*"}
    set tmp $buffer
    set success 1
    set offset 0
    set oldguitarchord ""
    while {$success} {
        set success [regexp -indices $pat $tmp match]
        if {!$success} break
        set pos1 [lindex $match 0]
        set pos2 [lindex $match 1]
        set guitarchord [string range $tmp  $pos1 $pos2]
        #puts $guitarchord
        set tmp [string range $tmp [expr $pos2 +1] end]
        set apos1 [expr $pos1 + $offset]
        set apos2 [expr $pos2 + $offset]
        if {[string compare $guitarchord $oldguitarchord] == 0} {
            set buffer [string replace $buffer $apos1 $apos2 ""]
            set offset [expr $offset - [string length $guitarchord]]}
        set offset [expr $offset + $pos2 +1]
        set oldguitarchord $guitarchord
    }
    return $buffer
}


# Part 10.6           Process Editor Buffer

proc process_buffer {action param} {
    global abctxtw
    set selrange [$abctxtw tag ranges sel]
    if {[llength $selrange] < 2} {
        messages "Please select an area in the body of the tune \
                and then try again. To select a region, hold the left mouse button \
                down and sweep an area."
        return
    } else {
        set selstart [lindex $selrange 0]
        set selend [lindex $selrange 1]
        set value [$abctxtw get $selstart $selend]
        set cmd [list $action $value $param]
        set value [eval $cmd]
        $abctxtw configure -autoseparators False
        $abctxtw edit separator
        $abctxtw delete $selstart $selend
        $abctxtw insert $selstart $value
        $abctxtw configure -autoseparators True
    }
    tag_text $abctxtw
}

proc process_region {action param} {
    global abctxtw
    set selrange [$abctxtw tag ranges sel]
    if {[llength $selrange] < 2} {
        messages "Please select an area in the body of the tune \
                and then try again. To select a region, hold the left mouse button \
                down and sweep an area."
        return
    } else {
        set selstart [lindex $selrange 0]
        set selend [lindex $selrange 1]
        set cmd [list $action [list $selstart $selend] $param]
        set value [eval $cmd]
        $abctxtw tag remove sel $selstart $selend
    }
    tag_text $abctxtw
}

# end of transpose.tcl


# Part 10.7                Grace Notes ToolBox

# source grace.tcl

proc grace_toolbox {} {
    global df
    global midi
    set g .abcedit.pane.toolbox.grace
    if {[winfo exist $g]} {destroy $g}
    frame $g -borderwidth 2 -relief sunken
    grid $g -row 1 -sticky w
    frame $g.0
    frame $g.1
    frame $g.2
    label $g.0.lab -text "Grace notes" -font $df
    button $g.0.help -text help -font $df -width 4 -padx 0\
            -command {show_message_page $hlp_grace word
                focus .abc
                raise .abc .abcedit}
    button $g.0.cfg -text cfg -font $df -width 3 -padx 0 -command grace_cfg
    button   $g.1.1 -text $midi(grname1) -font $df -width 9\
            -command "grace_note [list $midi(grseq1)]" -padx 0
    button   $g.1.2 -text $midi(grname2) -font $df -width 9\
            -command "grace_note [list $midi(grseq2)]" -padx 0
    button   $g.1.3 -text $midi(grname3) -font $df -width 9\
            -command "grace_note [list $midi(grseq3)]" -padx 0
    button   $g.2.1 -text $midi(grname4) -font $df -width 9\
            -command "grace_note [list $midi(grseq4)]" -padx 0
    button   $g.2.2 -text $midi(grname5) -font $df -width 9\
            -command "grace_note [list $midi(grseq5)]" -padx 0
    button   $g.2.3 -text $midi(grname6) -font $df -width 9\
            -command "grace_note [list $midi(grseq6)]" -padx 0
    
    pack $g.0.lab $g.0.help $g.0.cfg -side left -anchor w
    pack $g.1.1 $g.1.2 $g.1.3 -side left -anchor w
    pack $g.2.1 $g.2.2 $g.2.3 -side left -anchor w
    pack $g.0 $g.1 $g.2 -side top -anchor w
}


proc grace_cfg {} {
    global midi df
    set p .gracecfg
    if {[winfo exist $p]} return
    toplevel $p
    position_window ".gracecfg"
    label $p.lab -text "grace notes configuration" -font $df
    grid $p.lab -columnspan 2
    for {set i 1} {$i < 7} {incr i} {
        entry $p.grname$i -width 7 -textvariable midi(grname$i) -font $df
        entry $p.grseq$i -width 12 -textvariable midi(grseq$i) -font $df
        grid $p.grname$i $p.grseq$i
        bind $p.grseq$i <Return> {focus .gracecfg.lab}
        bind $p.grname$i <Return> {focus .gracecfg.lab
            grace_toolbox}
    }
    button $p.reset -text "reset" -font $df -command reset_grace_cfg
    button $p.help -text help -font $df  -command {
        show_message_page $hlp_grace_cfg word
        focus .abc
        raise .abc .abcedit}
    grid $p.reset $p.help
}


proc reset_grace_cfg {} {
    global midi
    set midi(grname1) cut
    set midi(grname2) strike
    set midi(grname3) mordent
    set midi(grname4) rmordent
    set midi(grname5) slide
    set midi(grname6) trill
    set midi(grseq1) "1"
    set midi(grseq2) "-1"
    set midi(grseq3) "0 1"
    set midi(grseq4) "0 -1"
    set midi(grseq5) "-3 -2 -1 0"
    set midi(grseq6) "0 1 0 1"
    grace_toolbox
}


proc make_grace {base sequence} {
    set res ""
    foreach action $sequence {
        set note [shift_note $base $action]
        set res $res$note
    }
    return $res
}


proc grace_note {sequence} {
    global abctxtw
    set note {[A-G]|[a-g]}
    remove_these_grace_notes_if_any
    set loc [$abctxtw search  -regexp  -- $note insert]
    #  puts "loc = $loc"
    set base [$abctxtw get $loc]
    # check for transpose
    set next [$abctxtw index "$loc+1 char"]
    #  puts "next = $next"
    set t [$abctxtw get $next]
    if {$t == "," | $t == "'"} {set base $base$t}
    set grace [make_grace $base $sequence]
    set lastinsert [$abctxtw index insert]
    $abctxtw insert insert "\{$grace\}"
    $abctxtw mark set insert $lastinsert
}

proc remove_grace_notes {buffer dummy} {
    regsub -all  {\{[^\}]*\}} $buffer "" result
    return $result
}

proc remove_these_grace_notes_if_any {} {
    global abctxtw
    set t [$abctxtw get insert]
    if {$t == "\{" } {
        set grace_end [$abctxtw search \}  insert]
        $abctxtw delete insert "$grace_end +1 char"
    }
}


set hlp_grace "Grace toolbox\n\n\
        This toolbox is used for creating and inserting a grace \
        note sequence before a specific note in the music body. For example, for \
        if the cursor is placed before the note C, clicking 'trill'
will insert {DCDC}. n\n\
        Instructions: place the insert marker just before the note and click \
        the desired ornament you wish to insert. If you change your mind, use \
        <cntl-z> or undo to remove it.\n\nThe program looks at the following \
        note and computes the grace sequence appropriate for this note. If the \
        note is preceded by an accidental, it may be necessary for you to edit \
        the grace sequence.\n\n\
        Caution: if you are not careful in placing the \
        insert marker, you can create a syntacticly meaningless abc file."

set hlp_grace_cfg "Grace notes configuration\n\n\
        This frame allows you to change the names and grace sequence\
        of the grace buttons in the grace tool box of TclAbcEditor.\
        The names should be restricted to 7 or less letters. Enter a\
        carriage return to activate the change and remove the focus from\
        the entry box. The sequence of numbers in the entry box to the\
        right specify the pitches of the notes in the grace sequence relative\
        to the note it is being applied.\n\n\
        The changes that you make will be stored in runabc.ini. Clicking\
        the reset button will return the grace settings to their initial\
        defaults."


# end of grace.tcl

# Part 10.8                   Chords ToolBox

#source chords.tcl

proc notes2chords {buffer shift} {
    #scans line for musical notes and shifts it up or down.
    #In order to continue from where we left off, we strip
    #off the part of string that we have already scanned,
    #and keep track of the amount we stripped in the variable
    #offset plus any expansion or contraction of note (eg. b to c').
    set note {(\^*|_*|=?)([A-G]\,*|[a-g]\'*)(/?[0-9]*|[0-9]*/*[0-9])}
    # see proc shift_all_notes for description of decoration
    set decoration {(?n)((\![^\!]*\!)|(^[ \t]*%.*$)|(^[ \t]*[A-Za-z]:.*$)|(\[[ \t]*\"[^\"]*\"))|(\"[^\"]*\")|(\[.:[^]]*\])}
    set tmp $buffer
    set success 1
    set offset 0
    while {$success} {
        set success [regexp -indices $note $tmp match]
        if {!$success} break
        set skip [regexp -indices $decoration $tmp match_skip]
        if {$skip && [lindex $match_skip 0] < [lindex $match 0]} {
            set pos2 [lindex $match_skip 1]
            set offset [expr $offset + $pos2 + 1]
            set tmp [string range $buffer $offset end]
        } else {
            set pos1 [lindex $match 0]
            set pos2 [lindex $match 1]
            set keystr [string range $tmp  $pos1 $pos2]
            regexp $note $keystr match acc key len
            #puts "$keystr $acc $key $len"
            set newkey [shift_note $key $shift]
            set chord "\[$acc$key$len$acc$newkey$len\]"
            #puts $chord
            set tmp [string range $tmp [expr $pos2 +1] end]
            set apos1 [expr $pos1 + $offset]
            set apos2 [expr $pos2 + $offset]
            set buffer [string replace $buffer $apos1 $apos2 $chord]
            set offset [expr $offset + $pos1 + [string length $chord]]
            #    puts "$offset $pos1 $pos2"
        }
    }
    return $buffer
}

set hlp_chords "Note to chord\n\n\
        The function replaces the notes in the selected \
        area with chords, going a specified interval down from the given note. \
        Thus G2 would be replaced with \[G2E2\] if a third is requested.\
        Note that abc2midi does not handle the syntax \[AC\] > \[GB\].\
        You should spell out C>B to C3/2B/ before applying the \
        chord operator."


#end chords.tcl

# Part 11.0                   Show Summary Sheet ,tmpfile and message sheet

proc show_tmpfile {} {
    global midi df
    set p .tmpfile
    set num 0
    if [winfo exist $p] {destroy $p}
    toplevel $p
    position_window ".tmpfile"
    text $p.t -height 15 -width 80 -wrap char \
            -font $df -yscrollcommand ".tmpfile.ysbar set"
    scrollbar $p.ysbar -orient vertical -command {.tmpfile.t yview}
    pack $p.ysbar -side right -fill y -in $p
    pack $p.t -in $p -expand y -fill both
    $p.t tag configure grey -background grey80
    $p.t tag configure red -foreground red
    set handle [open X.tmp]
    while {[eof $handle] != 1} {
        gets $handle line
        incr num
        $p.t insert end "$num: $line\n"
    }
    close $handle
}

proc save_tmpfile {} {
    global midi
    global types
    set filedir [file dirname $midi(midi_save)]
    set midi(abc_save) [tk_getSaveFile -initialdir $filedir -filetypes $types]
    file copy -force  X.tmp $midi(abc_save)
    puts "copied X.tmp to $midi(abc_save)"
}

proc make_summary_toplevel {} {
    global df
    set p .summary
    toplevel $p
    position_window ".summary"
    text $p.t -height 14 -width 70 -wrap char -bg #f4ece0 \
            -font $df -yscrollcommand ".summary.ysbar set"
    scrollbar $p.ysbar -orient vertical -command {.summary.t yview}
    pack $p.ysbar -side right -fill y -in $p
    pack $p.t -in $p -expand y -fill both
}

proc show_message_page {text wrapmode} {
    global active_sheet df
    #remove_old_sheet
    set p .notice
    if [winfo exist .notice] {
        $p.t configure -state normal -font $df
        $p.t delete 1.0 end
        $p.t insert end $text
        #   $p.t configure -state disabled -wrap $wrapmode
    } else {
        toplevel $p
        position_window ".notice"
        text $p.t -height 15 -width 50 -wrap $wrapmode -font $df -yscrollcommand {.notice.ysbar set}
        scrollbar $p.ysbar -orient vertical -command {.notice.t yview}
        pack $p.ysbar -side right -fill y -in $p
        pack $p.t -in $p -fill both -expand true
        $p.t insert end $text
        #   $p.t configure -state disabled
    }
    raise $p .
}


proc run_abc2abc {} {
    global midi df
    global abc2abc_s  abc2abc_u  abc2abc_d  abc2abc_t abc2abc_n abc2abc_V
    global abc2abc_e abc2abc_n_val  abc2abc_t_val abc2abc_V_val
    global abc2abc_P abc2abc_P_val
    global abc2abc_v abc2abc_nk abc2abc_useflats
    global abc2abc_usekey abc2abc_cl abc2abc_clef
    global barpickerflag
    global ps_numb_start
    set abc2abc_tofile 1
    set barpickerflag 0
    set abc2abc_opt ""
    if {$abc2abc_s} {append abc2abc_opt "-s "}
    if {$abc2abc_e} {append abc2abc_opt "-e "}
    if {$abc2abc_v} {append abc2abc_opt "-v "}
    if {$abc2abc_u} {append abc2abc_opt "-u "}
    if {$abc2abc_d} {append abc2abc_opt "-d "}
    if {$abc2abc_nk} {
        if {!$abc2abc_usekey} {
            if {$abc2abc_useflats}  {append abc2abc_opt "-nokeyf "
            } else {append abc2abc_opt "-nokeys "}
        } else {
            append abc2abc_opt "-usekey $abc2abc_usekey "
        }
    }
    if {$abc2abc_t} {append abc2abc_opt "-t $abc2abc_t_val "}
    if {$abc2abc_n} {append abc2abc_opt "-n $abc2abc_n_val "}
    if {$abc2abc_V} {append abc2abc_opt "-V $abc2abc_V_val "}
    if {$abc2abc_P} {append abc2abc_opt "-P $abc2abc_P_val "}
    if {$abc2abc_cl} {append abc2abc_opt "-useclef $abc2abc_clef "}
    copy_selection_to_file [title_selected] $midi(abc_open) X.tmp
    if {$midi(no_clipboard) == 1} {
        set cmd "exec [list $midi(path_abc2abc)] \
                X.tmp $abc2abc_opt > [list $midi(abc_default_file)]"
        catch {eval $cmd} exec_out
        if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_abc2abc)}
        tcl_abc_edit $midi(abc_default_file) 1
        .abc.abc2abc.10 configure -font $df -text "$cmd\n$exec_out"
    } elseif {$midi(no_clipboard) == 2} {
        set cmd "exec [list $midi(path_abc2abc)] \
                X.tmp $abc2abc_opt > [list $midi(abc_default_file)]"
        catch {eval $cmd} exec_out
        if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_abc2abc)}
      set ps_numb_start 0
      display_tunes $midi(abc_default_file)
    } else {
        set cmd "exec [list $midi(path_abc2abc)]  X.tmp $abc2abc_opt"
        catch {eval $cmd} exec_out
        if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_abc2abc)}
        clipboard clear
        clipboard append $exec_out
        .abc.abc2abc.10 configure -font $df -text "$cmd\nThe results are in the clipboard."
    }
    #puts $cmd
    update_console_page
}




startup_progress "loading property sheets"


#Part 12.0  Property Sheets -- titles, voice, style, abc2abc, midi2abc etc

######################
#   Property Sheets  #
######################


set active_sheet none

proc remove_old_sheet {} {
    global active_sheet
    switch -- $active_sheet {
        none   {pack forget .abc.titles}
        midi   {remove_midi_page}
        voice  {pack forget .abc.voice}
        m2psbool {pack forget .abc.m2psbool}
        m2psfloat {pack forget .abc.m2psfloat}
        extract {remove_extract_page}
        yaps   {pack forget .abc.yaps}
        config {remove_cfg_page}
        titles {pack forget .abc.titles}
        abc2abc {pack forget .abc.abc2abc}
        midi2abc {pack forget .midi2abc}
        otherps {pack forget .abc.otherps}
        abc2svg {pack forget .abc.abc2svg}
        incipits {pack forget .abc.incipits}
        g2v {pack forget .abc.g2v}
        reformat {pack forget .abc.reformat}
    }
}

proc show_other_ps {} {
    global active_sheet midi
    remove_old_sheet
    pack .abc.otherps -side left
    set active_sheet otherps
}

proc show_ps_page {type} {
    global active_sheet midi
    
    remove_old_sheet
    if {$active_sheet == $type} {
        set active_sheet "none"
    } else {
        if {$midi(ps_creator)=="yaps"} {
            pack .abc.yaps -side left
            set active_sheet yaps
        } else {
            pack .abc.$type
            set active_sheet $type
        }
# not used
#    if {$midi(ps_creator) == "abc2svg"} {
#	    show_format_file}
#    }
}

proc show_abc2abc_page {} {
    global active_sheet
    remove_old_sheet
    if {$active_sheet == "abc2abc"} {
        set active_sheet none
    }  else {
        pack .abc.abc2abc -side left
        set active_sheet abc2abc
        .abc.abc2abc.10 configure -text ""
    }
}


set midi_subsection 0

proc show_midi_page {subsection} {
    global active_sheet midi_subsection
    
    remove_old_sheet
    if {$active_sheet == "midi" && $subsection == $midi_subsection} {
        set active_sheet "none"
        set midi_subsection 0
    } else {
        switch -- $subsection {
            1 { set w_list {transpose tuning} }
            2 { set w_list {melody double chord bass beat over gchord drum drone msg} }
            8 { set w_list {player grace divider broken barfly drummethod fermata nograce quiet silent reset} }
            13 { set w_list {drone}}
            default { set w_list "" }
        }
        foreach i $w_list {
            pack .abc.midi1.$i -side top -anchor w
        }
        set midi_subsection $subsection
        pack .abc.midi1
        set active_sheet midi
    }
}


proc remove_midi_page {} {
    global midi_subsection
    
    switch -- $midi_subsection {
        1 { set w_list {transpose tuning} }
        2 { set w_list {melody double chord bass beat over gchord drum drumpat drone msg}}
        8 { set w_list {player grace divider barfly broken reset drummethod fermata nograce quiet silent} }
        13 { set w_list {drone}}
        default { set w_list "" }
    }
    foreach i $w_list {
        pack forget .abc.midi1.$i
    }
    pack forget .abc.midi1
}


proc show_voice_page {} {
    global active_sheet
    
    remove_old_sheet
    if {$active_sheet == "voice"} {
        set active_sheet "none"
    } else {
        pack .abc.voice
        set f .abc.voice.canvas.f
        set child $f.pan1
        tkwait visibility $child
        set bbox [grid bbox $f 0 0]
        #      puts $bbox
        set width [winfo reqwidth .abc]
        set height [winfo reqheight $f]
        set incr [lindex $bbox 3]
        .abc.voice.canvas config -scrollregion "0 0 $width $height"
        .abc.voice.canvas config -yscrollincrement $incr
        set height [expr $incr * 10]
        .abc.voice.canvas  config -width $width -height $height
        set active_sheet voice
    }
}


proc show_titles_page {} {
    global active_sheet
    
    remove_old_sheet
    if {$active_sheet == "titles"} {
        set active_sheet "none"
    } else {
        pack .abc.titles -expand y -fill both
        set active_sheet titles
    }
    focus .abc.titles.t
}


set cfg_subsection 0


proc show_config_page {subsection} {
    global active_sheet
    global cfg_subsection
    
    remove_old_sheet
    if {$active_sheet == "config" && $subsection == $cfg_subsection} {
        set active_sheet "none"
        set cfg_subsection 0
    } else {
        switch -- $subsection {
            1 { set w_list {26 1 20 4 30 10 23 29 22 12} }
            2 { set w_list {5 6 13 7 8 14 36 37 38 40 41 42 19 39} }
            4 { set w_list {9 18 15 16 17 27} }
            5 { set w_list {31} }
	    6 { set w_list {32 33 34 35} }
            default { set w_list "" }
        }
        foreach i $w_list {
            pack .abc.cfg.$i -side top
        }
        set cfg_subsection $subsection
        pack .abc.cfg
        set active_sheet config
    }
}

proc show_configure_abcmidi_packages {} {
    # abc2midi, abc2abc, yaps, midi2abc, and midicopy.
    pack .abc.cfg.3  -side top -after .abc.cfg.26
    pack .abc.cfg.21 -side top -after .abc.cfg.3
    pack .abc.cfg.2 -side top -after .abc.cfg.21
    pack .abc.cfg.24 -side top -after .abc.cfg.2
    pack .abc.cfg.25 -side top -after .abc.cfg.24
}

proc show_extract_page {} {
    global active_sheet
    
    remove_old_sheet
    if {$active_sheet == "extract"} {
        set active_sheet "none"
    } else {
        pack .abc.extract
        set active_sheet extract }
}

proc show_reformat_page {} {
    global active_sheet
    global df
    remove_old_sheet
    if {$active_sheet == "reformat"} {
        set active_sheet "none"
    } else {
        pack .abc.reformat
        set active_sheet reformat
        .abc.reformat.mesg configure -text "" -font $df}
}


proc show_g2v_page {} {
    global active_sheet
    
    remove_old_sheet
    if {$active_sheet == "g2v"} {
        set active_sheet "none"
    } else {
        pack .abc.g2v
        set active_sheet g2v }
}




proc remove_cfg_page {} {
    global cfg_subsection
    
    switch -- $cfg_subsection {
        1 { set w_list {26 1 20 2 21 24 3 25 4 10 23 29 22 12 30} }
        2 { set w_list {5 6 13 7 8 14 36 37 38 40 41 42 19 39} }
        4 { set w_list {9 18 15 16 17 27} }
        5 { set w_list {30} }
	6 { set w_list {32 33 34 35} }
        default { set w_list "" }
    }
    foreach i $w_list {
        pack forget .abc.cfg.$i
    }
    pack forget .abc.cfg
}

proc remove_extract_page {} {
    pack forget .abc.extract
}

proc setpath {path_var} {
    global midi
    
    set filedir [file dirname $midi($path_var)]
    set openfile [tk_getOpenFile -initialdir $filedir]
    if {[string length $openfile] > 0} {
        set midi($path_var) $openfile
        update
    }
}

proc setpathjslib {} {
    global midi
    set filedir [file dirname $midi(jslib)]
    set openfile [tk_chooseDirectory]
    if {[string length $openfile] > 0} {
        set midi(jslib) $openfile
        update
    }
    update_url_pointer
}

proc update_url_pointer {} {
    global midi
    global urlpointer
    set urlpointer(2) $midi(jslib)/
    }




proc locate_abcmidi_executables {} {
    global midi
    global exec_out
    set exec_out ""
    set dirname [tk_chooseDirectory -initialdir $midi(dir_abcmidi)]
    if {[string length $dirname] < 1} return
    set midi(dir_abcmidi) $dirname
    foreach exec {abc2midi abc2abc yaps midi2abc midicopy abcmatch abcm2ps} {
        if {[file exist $dirname/$exec.exe]} {
            set midi(path_$exec) $dirname/$exec.exe
        } elseif {[file exist $dirname/$exec]} {
            set filename $exec
            set midi(path_$exec) $dirname/$exec} else {
            append exec_out "cannot find $dirname/$exec or $dirname/$exec.exe\n" }
    }
    show_checkversion_summary
    show_configure_abcmidi_packages
    update_console_page
}


#	Abcm2ps Property Sheet

set w .abc.m2psfloat
frame $w
label $w.heading -text "abc2ps/abcm2ps options" -font $df
grid $w.heading

#radiobutton $w.myown -text "use my own style" \
#        -variable midi(ps_fmt_flag) -value 0  -font $df
checkbutton $w.ulayout -text "use format file" \
        -variable midi(ps_fmt_flag) -font $df\
       	-command enable_disable_style_boxes
button $w.browselayout -text "find format file" -font $df\
        -command {setpath ps_fmt_file}
entry $w.layoutfile -width 32 -textvariable midi(ps_fmt_file) -font $df
$w.layoutfile xview moveto 1.0


label $w.glue -text glue  -font $df
set glmenu [tk_optionMenu $w.gluemenu midi(ps_glue) shrink space stretch fill]
$w.gluemenu configure -font $df
$glmenu configure -font $df
label $w.scalelabel -text scale  -font $df
tooltip::tooltip .abc.m2psfloat.scalelabel  "increases or decreases the size of the font"
entry $w.scaleent -width 10 -relief sunken -textvariable midi(ps_scale) -font $df
label $w.widthlabel -text width -font $df
tooltip::tooltip .abc.m2psfloat.widthlabel  "a page 8.5 inches across is about 600 points"
entry $w.widthent -width 10 -relief sunken -textvariable midi(ps_width) -font $df
label $w.lmarglabel -text "left margin" -font $df
entry $w.lmargent -width 10 -relief sunken -textvariable midi(ps_lmargin) -font $df
label $w.shrinklabel -text shrinkage -font $df
tooltip::tooltip .abc.m2psfloat.shrinklabel  "valid value between 0.0 and 1.0"
entry $w.shrinkent -width 10 -relief sunken -textvariable midi(ps_shrink) -font $df
label $w.staffseplab -text "staff separation" -font $df
entry $w.staffsepent -width 10 -relief sunken -textvariable midi(ps_staffsep) -font $df
label $w.bufflab -text "buffer size kbytes" -font $df
spinbox $w.buffspin -from 0 -to 20 -increment 2 -font $df\
  -format %2.0f -width 3 -textvariable midi(ps_buffsize)


label $w.other_opts -text "other options" -font $df
entry $w.other_optsent -width 24 -relief sunken -textvariable midi(ps_other_options) -font $df

grid $w.ulayout $w.layoutfile -sticky w
grid $w.browselayout -sticky w

bind $w.layoutfile <Return> {focus .abc.m2psfloat.heading}
bind $w.scaleent   <Return> {focus .abc.m2psfloat.heading}
bind $w.widthent   <Return> {focus .abc.m2psfloat.heading}
bind $w.lmargent   <Return> {focus .abc.m2psfloat.heading}
bind $w.shrinkent  <Return> {focus .abc.m2psfloat.heading}
bind $w.staffsepent <Return> {focus .abc.m2psfloat.heading}
bind $w.other_optsent <Return> {focus .abc.m2psfloat.heading}


set w .abc.m2psbool
frame $w
checkbutton $w.bref -text "reference numbers" -variable midi(ps_bxref) -font $df
checkbutton $w.bar  -text "number bar lines"  -variable midi(ps_bbar) -font $df
checkbutton $w.bnumb -text "page numbers"     -variable midi(ps_bnumb) -font $df
checkbutton $w.bppage -text "one tune/page"   -variable midi(ps_bppage) -font $df
checkbutton $w.nolyric -text "no lyrics"      -variable midi(ps_nolyric) -font $df
checkbutton $w.noslur -text "no slurs"        -variable midi(ps_noslur) -font $df
checkbutton $w.flatbm -text "flat beams"      -variable midi(ps_flat) -font $df
checkbutton $w.landscape -text "landscape" -variable midi(ps_fmt_landscape)\
        -font $df

label $w.maxvlab -text "Maximum voices" -font $df
label $w.maxslab -text "Maximum symbols" -font $df
entry $w.maxvent -width 10 -relief sunken -textvariable midi(ps_maxvent) -font $df
entry $w.maxsent -width 10 -relief sunken -textvariable midi(ps_maxsent) -font $df
checkbutton $w.ps_c -text "ignore line ends" -variable midi(ps_c) -font $df
checkbutton $w.voices -text "select voices" -variable midi(bpsvoice) -font $df
entry $w.voicesent -width 10 -textvariable midi(psvoice) -font $df
radiobutton $w.psoutput -text "ps output" -font $df -value ps -variable midi(m2ps_output)
radiobutton $w.epsoutput -text "eps output" -font $df -value eps -variable midi(m2ps_output)
radiobutton $w.svgoutput -text "svg output" -font $df -value svg -variable midi(m2ps_output)
radiobutton $w.xhtmloutput -text "xhtml output" -font $df -value xhtml -variable midi(m2ps_output)

grid $w.bref    $w.bar       -sticky w
grid $w.ps_c    $w.flatbm    -sticky w
grid $w.bnumb   $w.bppage    -sticky w
grid $w.nolyric $w.noslur    -sticky w
grid $w.landscape            -sticky w
grid $w.psoutput   $w.svgoutput
grid $w.epsoutput  $w.xhtmloutput -sticky w


#       reformat property sheet
set w .abc.reformat
frame $w
frame $w.1
frame $w.2
frame $w.3
frame $w.4
label $w.1.1 -text "Reformat" -font $df
pack $w.1.1 -side left
pack $w.1
checkbutton $w.2.interleave -text "voice interleave" \
        -variable midi(interleave) -font $df
label $w.2.bpllab -text "bars per line" -font $df
entry $w.2.bplent -textvariable midi(midibpl) -width 2 -font $df
bind $w.2.bplent <Return> {focus .abc.reformat.1}
label $w.2.bpslab -text "bars per staff" -font $df
entry $w.2.bpsent -textvariable midi(midibps) -width 2 -font $df
bind $w.2.bpsent <Return> {focus .abc.reformat.1}
pack $w.2.bpllab $w.2.bplent $w.2.bpslab $w.2.bpsent $w.2.interleave\
        -side left -anchor w
pack $w.2
checkbutton $w.3.inv -text "inline voice cmd" \
        -variable midi(inline_voice) -font $df
checkbutton $w.3.bars -text "bar numbers" \
        -variable midi(reformat_bars) -font $df
label $w.3.startlab -text "start bar number" -font $df
entry $w.3.startent -textvariable midi(startbar) -font $df -width 4
pack $w.3.inv $w.3.bars $w.3.startlab $w.3.startent -side left -anchor w
pack $w.3
button $w.4.1 -text "reformat" -font $df\
        -command {startup_tcl_abc_edit 0
            set tunestring [return_selected_tune]
            Refactor::process_tune $tunestring
            Refactor::reconstitute
        }
pack $w.4.1 -side left
pack $w.4
label $w.mesg -text ""
pack $w.mesg


#	extract property sheet

set w .abc.extract
frame $w
frame $w.1
frame $w.2
frame $w.3
frame $w.4
set extract_v 1
set extract_t 0
label $w.1.2 -text "Voice:" -font $df
entry $w.1.3 -width 2 -relief sunken -textvariable extract_v -font $df
label $w.1.4 -text "Transpose:" -font $df
entry $w.1.5 -width 2 -relief sunken -textvariable extract_t -font $df
pack  $w.1.2 $w.1.3 $w.1.4 $w.1.5 -padx 3 -pady 3 -side left -anchor w

label $w.2.lab -text remove -font $df
checkbutton $w.2.chk1 -text "voice fields" -font $df -variable midi(remove_voice)
checkbutton $w.2.chk3 -text "backslashes" -font $df -variable midi(remove_backslashes)
pack $w.2.lab $w.2.chk1 $w.2.chk3 -side left -anchor w

checkbutton $w.3.chk1 -text "condense rests" -font $df -variable midi(condense_on)
radiobutton $w.3.rad1 -text "using Zn" -font $df -variable midi(condense_method) -value 0
radiobutton $w.3.rad2 -text "using \"n\"z" -font $df -variable midi(condense_method) -value 1
radiobutton $w.3.rad3 -text "auto" -font $df -variable midi(condense_method) -value 2
pack $w.3.chk1 $w.3.rad1 $w.3.rad2 $w.3.rad3 -side left -anchor w



button $w.4.0 -text "Display"      -font $df -borderwidth 3  -command {extract_action display}
button $w.4.1 -text "Save to file" -font $df -borderwidth 3  -command {extract_action save}
button $w.4.2 -text "To editor"    -font $df -borderwidth 3  -command {extract_action edit}
pack $w.4.0 $w.4.1 $w.4.2  -padx 15 -pady 3 -side left -anchor w

label $w.5
pack $w.1 $w.2 $w.3 $w.4  -side top
pack $w.5



#      g2v property sheet

set chosenvoice 1
set gchordvoiceid 2
set drumsvoiceid 3

set w .abc.g2v
frame $w
frame $w.1
frame $w.2
frame $w.3
frame $w.4
frame $w.5
frame $w.6
frame $w.7
frame $w.8
frame $w.9
frame $w.msg

label $w.0 -text "gchords/drums to voice" -font $df
label $w.1.lab -text "default gchord string" -font $df
entry $w.1.ent -width 24 -textvariable gvchordstring -font $df
label $w.5.lab -text "default drum string" -font $df

entry $w.5.ent -width 32 -textvariable drumentry -font $df
label $w.6.lab -text "input voice name or number" -font $df
entry $w.6.ent -width 10 -textvariable chosenvoice -font $df
button $w.4.go -text "create tune" -font $df -command g2v
label $w.7.lab -text "gchord voice id" -font $df
label $w.8.lab -text "drums voice id" -font $df
entry $w.7.ent -width 10 -textvariable gchordvoiceid -font $df
entry $w.8.ent -width 10 -textvariable drumsvoiceid -font $df
checkbutton $w.9.but -text "use drum map" -font $df -variable midi(drummap)

label $w.msg.txt -text "" -font $df
radiobutton $w.2.0 -text "output to clipboard"  -variable midi(g2v_clipboard) \
        -relief flat -value 1  -font $df
radiobutton $w.2.1 -text "output to editor"     -variable midi(g2v_clipboard) \
        -relief flat -value 0  -font $df
radiobutton $w.3.0 -text "gchords only" -font $df -variable dvoice -value 1
radiobutton $w.3.1 -text "drums only" -font $df -variable dvoice -value 2
radiobutton $w.3.2 -text "gchords and drums" -font $df -variable dvoice -value 0
pack $w.0
pack $w.1.lab  $w.1.ent -side left -anchor w
pack $w.5.lab $w.5.ent -side left -anchor w
pack $w.6.lab $w.6.ent -side left -anchor w
pack $w.7.lab $w.7.ent -side left -anchor w
pack $w.8.lab $w.8.ent -side left -anchor w
pack $w.9.but -side left -anchor w
pack $w.2.0 $w.2.1 -side left
pack $w.3.0 $w.3.1 $w.3.2 -side left
pack $w.4.go -side left
pack $w.msg.txt -side left
pack $w.1 $w.5 $w.6 $w.2 $w.3 $w.7 $w.8 $w.9 $w.4 $w.msg -side top -anchor w
bind .abc.g2v.1.ent   <Return> {focus .abc.g2v.1.lab}
bind .abc.g2v.5.ent   <Return> {focus .abc.g2v.1.lab}





# midisave_tool property sheet

set p .abc.midisavetool
set midi(namelen) 8
set midi(name) 1
frame $p
label $p.1
label $p.2 -text "You will need to specify a directory" -font $df
radiobutton $p.t -text "get filename from title" -variable midi(name) -value 1 -font $df
radiobutton $p.x -text "get filename from xref" -variable midi(name) -value 0 -font $df
entry $p.te -width 2 -textvariable midi(namelen) -font $df
label $p.char -text char -font $df
entry $p.xr -width 10 -textvariable midi(nameroot) -font $df
button $p.co -text continue -font $df -command {midisave_list_continue}
button $p.ca -text cancel -font $df -command {pack forget .abc.midisavetool}
button $p.he -text help -font $df -command {show_message_page $hlp_midisave word}
grid $p.1
grid $p.2
grid $p.t $p.te $p.char
grid $p.x $p.xr
grid $p.co $p.ca $p.he


#split abc file into tunes in separate files
set p .abc.splittool
frame $p
label $p.1
label $p.2 -text "You will need to specify a directory" -font $df
radiobutton $p.t -text "get filename from title" -variable midi(name) -value 1 -font $df
radiobutton $p.x -text "get filename from xref" -variable midi(name) -value 0 -font $df
button $p.co -text continue -font $df -command {split_abc_file
                                                pack forget .abc.splittool}
button $p.ca -text cancel -font $df -command {pack forget .abc.splittool}
grid $p.1 -sticky w
grid $p.2 -sticky w
grid $p.t $p.x  -sticky w
grid $p.co $p.ca  -sticky w



#	yaps property sheet

set yaps_size {"Letter 8.5 x 11 in" "Tabloid 11 x 17 in" "Ledger 17 x 11 in" \
            "Legal 8.5 x 14 in" "Statement 5.5 x 8.5 in" "Executive 7.5 x 10 in" \
            "A3 297 x 420 mm" "A4 210 x 297 mm" "A5 148 x 210 mm" "B4 257 x 364 mm" \
            "B5 182 x 257 mm" "Folio 8.5 x 13 mm" "Quarto 8.5 x 10.8 in" \
            "10 x 14 10 x14 in"}

set w .abc.yaps
frame $w
label $w.heading -text "yaps options" -font $df
grid $w.heading  -sticky w
label $w.scalelabel -text scale  -font $df
entry $w.scaleent -width 10 -relief sunken -textvariable midi(yaps_scale) -font $df
grid $w.scalelabel $w.scaleent -sticky w
label $w.lmarglabel -text "left margin" -font $df
entry $w.lmargent -width 10 -relief sunken -textvariable midi(yaps_lmargin) -font $df
label $w.lmargunits -text "points" -font $df
grid $w.lmarglabel $w.lmargent $w.lmargunits -sticky w
label $w.tmargbut -text "top margin" -font $df
entry $w.tmargent -width 10 -relief sunken -textvariable midi(yaps_tmargin) -font $df
label $w.tmargunits -text "points" -font $df
grid $w.tmargbut $w.tmargent $w.tmargunits -sticky w
label $w.papersizelab -text "paper size" -font $df
set v $w.papersizemenu
menubutton $v -text [lindex $yaps_size $midi(papersize)]   \
        -relief raised  -menu $v.type -font $df
menu $v.type -tearoff 0
set i 0
foreach item $yaps_size {
    $v.type add command -label $item -command "yaps_papersize $i" -font $df
    incr i
}
grid $w.papersizelab $w.papersizemenu -sticky w
checkbutton $w.voicechk -text "separate voices" -font $df \
        -variable midi(yaps_voice)

checkbutton $w.xchk -text "X tune number" -font $df \
        -variable midi(yapsx)
grid $w.voicechk $w.xchk -sticky w

checkbutton $w.land -text "Landscape" -font $df \
        -variable midi(yaps_landscape)

checkbutton $w.bar  -text "number bar lines"  -variable midi(yaps_bbar) -font $df
grid $w.land $w.bar -sticky w

set w .abc.otherps
frame $w
label $w.heading -text "other postscript converters" -font $df
pack $w.heading -side top
frame $w.exc
label $w.exc.lab -text executable -font $df
entry $w.exc.ent -textvariable midi(path_otherps) -width 36 -font $df
pack $w.exc.lab $w.exc.ent -side left
pack $w.exc -side top
frame $w.opt
label $w.opt.lab -text "exec options" -font $df
entry $w.opt.ent -width 36 -relief sunken -textvariable midi(otherps) -font $df
pack $w.opt.lab $w.opt.ent -side left
pack $w.opt -side top

set hlp_abc2svg "   abc2svg configuration sheet\n
Abc2svg is a javascript library which can display and play the abc music\
notation embedded in a html (xhtml) file when the file is viewed on\
a browser. The options in this frame control how the html file is\
created prior to being sent to the browser.\n
If you have your own\
copy of the javascript library, then you can tick the 'local javascript\
library' radio button, and then the browser will look for the\
javascript code on your system. The 'path to local javascript'\
adjoining entry box indicates where the library is found.\
The full path name starting from the C: drive should be given.\
Alternatively, you can tick the 'remote javascript' radio button\
and the javascript library will be obtained from Jef Moine's internet site.\
You should specify the name and location of the output html file.\
It is important that the full path name starting from C: be indicated.\
Clicking the 'html src' button will display the contents of this\
file in a text editor of your choice. This file is created\
or updated when you click the print button.\n
Jef's library includes two different methods for rendering the\
embedded abc notation. They are called abcweb-1 and abcweb1-1.\
Abcweb-1 displays all the abc notation, which can\
include several individual tunes, in one page. Abcweb1-1 contains\
an interface for selecting a particular tune in the collection.\
For both of these interfaces, is enclosed\
inside a special text/vnd.abc script block.\
This is one solution for handling broken rhythm notation, which\
would otherwise confuse the browser.\ 
This configuration page allows you to specify a particular\
format file which will provide various layout information.\
If the entry box is blank, then no format file is given.\
There is a separate window for creating or editing a format file\
which is accesible from the menu item abc2svg/create format file.
"

set w .abc.abc2svg
frame $w
checkbutton $w.formchk -variable midi(fmt_chk) -text "include ps header" -font $df
checkbutton $w.midichk -variable midi(midi_chk) -text "include midi settings" -font $df
checkbutton $w.replaceQ -variable midi(ignoreQ) -text "override tempo"\
 -command disable_enable_tempo_controller -font $df
checkbutton $w.noaccomp -variable midi(nogchords) -text "no accompaniment" -font $df
button $w.formlab -text "format file" -font $df\
  -command select_format_file -width 20
entry $w.forment -textvariable midi(ps_fmt_file) -width 36 -font $df
radiobutton $w.remote -text "remote javascript" -variable midi(remote)\
   -value 1 -font $df
radiobutton $w.local -text "local javascript lib" -variable midi(remote)\
   -value 0 -font $df 
button $w.htmlsrc -text "edit last html" -font $df -command view_html_src -width 20

button $w.javascriptlib -text "path to local javascript" -command setpathjslib\
-font $df -width 20
entry $w.jslib -width 36 -relief sunken -textvariable midi(jslib)\
-font $df
bind .abc.abc2svg.jslib <KeyRelease> {
   update_url_pointer
   }

button $w.outbut -text "output html file" -font $df\
    -command "setpath outhtml" -width 20
entry $w.outhtml -width 36 -relief sunken -textvariable midi(outhtml)\
   -font $df

radiobutton $w.web1 -text "abcweb-1" -variable midi(webscript)\
   -value 1 -font $df
radiobutton $w.web2 -text "abcweb1-1" -variable midi(webscript)\
   -value 2 -font $df



#not used
#text $w.text -width 50 -height 10


grid $w.formchk $w.midichk -sticky w
grid $w.replaceQ $w.noaccomp -sticky w
grid $w.web1 $w.web2  -sticky w
grid $w.remote $w.local -sticky w
grid $w.htmlsrc -sticky w
grid $w.javascriptlib $w.jslib -sticky w
grid $w.outbut $w.outhtml -sticky w 
grid $w.formlab $w.forment  -sticky w
#not used
#grid $w.text -columnspan 2 -sticky w

# not used
proc show_format_file {} {
global midi
if {[file exist $midi(ps_fmt_file)]} {
  set inhandle [open $midi(ps_fmt_file)]
  set fmt [read $inhandle]
  close $inhandle
  } else {return}
set w .abc.abc2svg
$w.text delete 1.0 end
$w.text insert 1.0 $fmt
}

proc select_format_file {} {
global midi
set types {{{format files} {*.fmt}}}
set midi(ps_fmt_file) [tk_getOpenFile -filetypes $types]
#show_format_file
}

proc view_html_src {} {
global midi
set cmd "exec [list $midi(path_editor)] [list $midi(outhtml)] &"
catch {eval $cmd} exec_out
}


proc yaps_papersize {size} {
    global midi yaps_size df
    
    .abc.yaps.papersizemenu config -text [lindex $yaps_size $size] -font $df
    set midi(papersize) $size
}



proc show_my_style {} {
    global midi
    
    set w .abc.m2psfloat
        grid $w.scalelabel $w.scaleent -sticky w
        grid $w.widthlabel $w.widthent -sticky w
        grid $w.lmarglabel $w.lmargent -sticky w
        grid $w.shrinklabel $w.shrinkent -sticky w
        grid $w.staffseplab $w.staffsepent -sticky w
	grid $w.bufflab $w.buffspin -sticky w
        if {$midi(ps_creator) == "abcm2ps"} {
            grid $w.other_opts $w.other_optsent -sticky w}
    enable_disable_style_boxes 
}

proc enable_disable_style_boxes {} {
global midi
set w .abc.m2psfloat
if {$midi(ps_fmt_flag) == 1} {
  $w.scaleent configure -state disabled
  $w.widthent configure -state disabled
  $w.lmargent configure -state disabled
  $w.shrinkent configure -state disabled
  $w.staffsepent configure -state disabled
  }  else {
  $w.scaleent configure -state normal
  $w.widthent configure -state normal
  $w.lmargent configure -state normal
  $w.shrinkent configure -state normal
  $w.staffsepent configure -state normal
  }
}

show_my_style

proc change_font {usesamplefont} {
    global midi df sf samplefont tocf
    if {[info exist samplefont] && $usesamplefont} {
        set midi(font_family) $samplefont}
    font configure $df -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)
    font configure $sf -size $midi(font_size) -weight $midi(font_weight)
    font configure $tocf -family $midi(font_family_toc)  -size $midi(font_size)\
            -weight $midi(font_weight)
    #.abc.titles.t configure -font $tocf
    .abc.titles.t tag configure tune -font $df
}

proc reset_font {} {
    global midi df
    set midi(font_family) helvetica
    font configure $df -family $midi(font_family) -size $midi(font_size) \
            -weight $midi(font_weight)
}



#	Midi Property Sheet

set w .abc.midi1
frame $w


frame $w.transpose
label $w.transpose.0 -text transpose -font $df
scale $w.transpose.1 -from -24 -to 24 -length 300 -width 10 \
        -orient horizontal  -showvalue true -variable midi(transpose)   -font $df
pack $w.transpose.0 $w.transpose.1 -side left

frame $w.tuning
label $w.tuning.0 -text tuning -width 8 -font $df
scale $w.tuning.1 -from 416 -to 466 -length 300  \
        -width 10 -orient horizontal  -showvalue true \
        -variable midi(tuning)   -font $df
pack $w.tuning.0 $w.tuning.1  -side left


frame $w.over
checkbutton $w.over.1 -text "override tempo " -variable midi(ignoreQ)\
        -font $df -command disable_enable_tempo_controller

checkbutton $w.over.2 -text "override  midi " \
        -variable midi(ignoremidi) -font $df

checkbutton $w.over.3 -text "no accompaniment" \
        -variable midi(nogchords) -font $df

button $w.over.random -text "random" -font $df -command random_arrangement



pack $w.over.1 $w.over.2 $w.over.3 $w.over.random -side left
tooltip::tooltip $w.over.1 "overrides tempo indications\nif any embedded in the tune"
tooltip::tooltip $w.over.2 "overrides MIDI indications\nif any embedded in the tune"
tooltip::tooltip $w.over.random "randomize the instrument assignments\nto the melody, chords and bass"

frame $w.player
label $w.player.lab -text "midi player" -font $df
radiobutton $w.player.b0 -text "player 1"  -variable midi(player) \
        -relief flat -value 0  -font $df
radiobutton $w.player.b1 -text "player 2"  -variable midi(player) \
        -relief flat -value 1  -font $df
radiobutton $w.player.b2 -text "player 3"  -variable midi(player) \
        -relief flat -value 2  -font $df
radiobutton $w.player.b3 -text "player 4"  -variable midi(player) \
        -relief flat -value 3  -font $df
pack  $w.player.lab $w.player.b0 $w.player.b1 $w.player.b2 $w.player.b3 -side left


set melody 1
set chords 1



# program property page

set m(1) {"0 Acoustic Grand" "1 Bright Acoustic" "2 Electric Grand" \
            "3 Honky-Tonk" "4 Electric Piano 1" "5 Electric Piano 2" "6 Harpsichord" \
            "7 Clav" }

set m(2) {" 8 Celesta" " 9 Glockenspiel" "10 Music Box" "11 Vibraphone" "12 Marimba" \
            "13 Xylophone" "14 Tubular Bells" "15 Dulcimer"}

set m(3) {"16 Drawbar Organ" "17 Percussive Organ" "18 Rock Organ" \
            "19 Church Organ" "20 Reed Organ" "21 Accordian" "22 Harmonica" "23 Tango Accordian"}

set m(4) { "24 Acoustic Guitar (nylon)" "25 Acoustic Guitar (steel)" \
            "26 Electric Guitar (jazz)" "27 Electric Guitar (clean)" \
            "28 Electric Guitar (muted)" "29 Overdriven Guitar" \
            "30 Distortion Guitar" "31 Guitar Harmonics"}

set m(5) {"32 Acoustic Bass" "33 Electric Bass (finger)" \
            "34 Electric Bass (pick)" "35 Fretless Bass" "36 Slap Bass 1" \
            "37 Slap Bass 2" "38 Synth Bass 1" "39 Synth Bass 2" }

set m(6) { "40 Violin" "41 Viola" "42 Cello" "43 Contrabass" "44 Tremolo Strings" \
            "45 Pizzicato Strings" "46 Orchestral Strings" "47 Timpani" }

set m(7) { "48 String Ensemble 1" "49 String Ensemble 2" "50 SynthStrings 1" \
            "51 SynthStrings 2" "52 Choir Aahs" "53 Voice Oohs" "54 Synth Voice" "55 Orchestra Hit" }

set m(8) { "56 Trumpet" "57 Trombone" "58 Tuba" "59 Muted Trumpet" "60 French Horn" \
            "61 Brass Section" "62 SynthBrass 1" "63 SynthBrass 2"}

set m(9) { "64 Soprano Sax" "65 Alto Sax" "66 Tenor Sax" "67 Baritone Sax" \
            "68 Oboe" "69 English Horn" "70 Bassoon" "71 Clarinet" }

set m(10) { "72 Piccolo" "73 Flute" "74 Recorder" "75 Pan Flute" "76 Blown Bottle" \
            "77 Skakuhachi" "78 Whistle" "79 Ocarina" }

set m(11) { "80 Lead 1 (square)" "81 Lead 2 (sawtooth)" "82 Lead 3 (calliope)" \
            "83 Lead 4 (chiff)" "84 Lead 5 (charang)" "85 Lead 6 (voice)" \
            "86 Lead 7 (fifths)" "87 Lead 8 (bass+lead)"}

set m(12) { "88 Pad 1 (new age)" "89 Pad 2 (warm)" "90 Pad 3 (polysynth)" \
            "91 Pad 4 (choir)" "92 Pad 5 (bowed)" "93 Pad 6 (metallic)" "94 Pad 7 (halo)" \
            "95 Pad 8 (sweep)" }

set m(13) { " 96 FX 1 (rain)" " 97 (soundtrack)" " 98 FX 3 (crystal)" \
            " 99 FX 4 (atmosphere)" "100 FX 5 (brightness)" "101 FX 6 (goblins)" \
            "102 FX 7 (echoes)" "103 FX 8 (sci-fi)" }

set m(14) { "104 Sitar" "105 Banjo" "106 Shamisen" "107 Koto" "108 Kalimba" \
            "109 Bagpipe" "110 Fiddle" "111 Shanai"}

set m(15) { "112 Tinkle Bell" "113 Agogo" "114 Steel Drums" "115 Woodblock" \
            "116 Taiko Drum" "117 Melodic Tom" "118 Synth Drum" "119 Reverse Cymbal" }

set m(16) { "120 Guitar Fret Noise" "121 Breath Noise" "122 Seashore" \
            "123 Bird Tweet" "124 Telephone ring" "125 Helicopter" "126 Applause" "127 Gunshot" }

global progtranslator
set mlist [concat $m(1) $m(2) $m(3) $m(4) $m(5) $m(6) $m(7) $m(8) \
$m(9) $m(10) $m(11) $m(12) $m(13) $m(14) $m(15) $m(16)]
foreach elem $mlist {
  set progtranslator([lindex $elem 0]) [lrange $elem 1 end]
  }
unset mlist


proc make_octave_menubutton {widget widgetcmd} {
    global df
    set ww $widget.menu
    menubutton $widget -menu $ww -text 0 -relief raised -font $df -width 2
    menu $ww -tearoff 0
    $ww add command -label -2 -command "$widgetcmd  $widget -2" -font $df
    $ww add command -label -1 -command "$widgetcmd  $widget -1" -font $df
    $ww add command -label  0 -command  "$widgetcmd  $widget 0" -font $df
    $ww add command -label  1 -command  "$widgetcmd  $widget 1" -font $df
    $ww add command -label  2 -command  "$widgetcmd  $widget 2" -font $df
}

proc label_octave {octave val} {
    global midi
    set midi($octave) $val
    return $val
}


proc midi1_msg {msg} {
    global exec_out
    set exec_out $exec_out\n$msg
    .abc.midi1.msg.txt configure -text $msg -foreground red
}


frame $w.msg
label $w.msg.txt -foreground red -text ""
pack $w.msg.txt

frame $w.melody

label $w.melody.label -text melody -font $df -width 10
scale $w.melody.vol -from 0 -to 127 -length 100  \
        -width 10 -orient horizontal -command setabclev\
        -variable midi(melvol)  -font $df
tooltip::tooltip $w.melody.vol "loudness level of\nmelody line"

set i1 [expr int(1 + $midi(program)/8)]
set i2 [expr $midi(program)  % 8 ]
button $w.melody.melodybut -text [lindex $m($i1) $i2]  -font $df -width 20

proc update_octave {widget val} {
    $widget configure -text [label_octave octave $val]}

make_octave_menubutton $w.melody.octave update_octave
tooltip::tooltip $w.melody.octave "octave shift for melody"

pack $w.melody.label $w.melody.vol $w.melody.melodybut $w.melody.octave -side left

proc double_action {} {
global midi
if {$midi(double)} {
  .abc.midi1.double.vol configure -state normal
  .abc.midi1.double.octave configure -state normal
  .abc.midi1.double.doublebut configure -state normal
  } else {
  .abc.midi1.double.vol configure -state disabled
  .abc.midi1.double.octave configure -state disable
  .abc.midi1.double.doublebut configure -state disable
  }
}

proc update_double_octave {widget val} {
    $widget configure -text [label_octave octave2 $val]}

set i1 [expr int(1 + $midi(program2)/8)]
set i2 [expr $midi(program2)  % 8 ]
frame $w.double
checkbutton $w.double.but -text double -font $df -width 8 \
 -variable midi(double) -command double_action

tooltip::tooltip $w.double.but "also play melody line
on a separate instrument"
scale $w.double.vol -from 0 -to 127 -length 100  \
        -width 10 -orient horizontal -command setdoublelev\
        -variable midi(doublevol)  -font $df
tooltip::tooltip $w.double.vol "loudness level of\ndoubled melody"
button $w.double.doublebut -text [lindex $m($i1) $i2]  -font $df -width 20
make_octave_menubutton $w.double.octave update_double_octave
tooltip::tooltip $w.double.octave "octave shift for\ndoubled instrument"
pack $w.double.but $w.double.vol $w.double.doublebut $w.double.octave -side left

proc update_bass_octave {widget val} {
    $widget configure -text [label_octave bass_octave $val]}

set i1 [expr int(1 + $midi(bassprog)/8)]
set i2 [expr $midi(bassprog)  % 8 ]
frame $w.bass
label $w.bass.basslab -text "bass"  -font $df -width 10
scale $w.bass.basscal -from 0 -to 127 -length 100 -width 10 \
        -orient horizontal -showvalue true -variable midi(bassvol)  -font $df
tooltip::tooltip $w.bass.basscal "loudness level of\n chordal accompaniment"
button $w.bass.bassbut -text [lindex $m($i1) $i2]  -font $df -width 20
make_octave_menubutton $w.bass.octave update_bass_octave
tooltip::tooltip $w.bass.octave "octave shift for\nbass accompaniment"
pack $w.bass.basslab $w.bass.basscal $w.bass.bassbut $w.bass.octave -side left


proc update_chord_octave {widget val} {
    $widget configure -text [label_octave chord_octave $val]}

set i1 [expr int(1 + $midi(chordprog)/8)]
set i2 [expr $midi(chordprog) % 8 ]
frame $w.chord
label $w.chord.chordlab -text "chord" -font  $df -width 10
scale $w.chord.chordscal -from 0 -to 127 -length 100  -width 10\
        -orient horizontal -showvalue true -variable midi(chordvol)  -font $df
tooltip::tooltip $w.chord.chordscal "loudness level of\nchordal accompaniment"
button $w.chord.chordbut -text [lindex $m($i1) $i2]  -font $df -width 20
make_octave_menubutton $w.chord.octave update_chord_octave
tooltip::tooltip $w.chord.octave "octave shift for\nchordal accompaniment"

pack $w.chord.chordlab $w.chord.chordscal $w.chord.chordbut $w.chord.octave -side left

update_octave $w.melody.octave $midi(octave)
update_double_octave $w.double.octave $midi(octave2)
update_chord_octave $w.chord.octave $midi(chord_octave)
update_bass_octave $w.bass.octave $midi(bass_octave)

double_action




set d2_4 {"d2dddddd 48 48 35 48 35 48 35" "dd 37 37" "dzdz 63 64" "dzzzdzzz 76 77" "dzdzdzdz 76 77 76 77"
 "dzzzzzzd 60 61 60 61"}
set d3_4 {"d2ddddd 43 76 77 76 77" "d2d2dd 60 60 77 36" "ddd 60 61 61"
 "dzdzdz 63 64 64"
 "z2dzdz 54 54" "d2z4 37"}
set d5_8 {"ddddd 48 75 75 35 75" "d3d2 48 35"}
set d6_8 {"d3ddd 76 37 37 37" "dddd3 37 37 37 61" "d2dd3 63 64 62" "dddd2d 75 37 37 75 37" "d3d2d 76 75 75"}
set d7_8 {"d3d2d2 38 35 35" "d2d2d3 35 35 38"}
set d4_4 {"d4d3dd4dddd 48 48 35 48 48 35 48 35" "d2ddd2dd 48 35 48 48 35 48" 
"dddd 63 64 63 64" "dzdzdzdz 59 59 59 59"  "d4d2d2 35 41 41"}
set d9_8 {"d2ddddddd 48 48 35 48 35 48 35 48" "ddd 48 46 46" "d3d2d2d2 35 43 43 43" "d2d3d2d2 43 35 43 43"
  "d2d2d3d2 60 61 61 61"}
set d11_8 {"d2d2d3d2d2 75 75 75 75 75" "d2d2d2d2d3 37 37 37 37 37"}
set d12_8 {"d2ddddd2dddd 75 37 37 37 37 75 37 37 37 37"}

set drumfamily 'none'
frame $w.drum
label $w.drum.lab -text "drum string" -font $df
button $w.drum.cfg -text drumkit -font $df -command drum_editor
ttk::combobox $w.drum.combo -width 36  -textvariable drumentry\
        -font $df -values $drumfamily
#button $w.drum.cfg -text drumkit -font $df -command drum_editor

bind $w.drum.combo <<ComboboxSelected>> {make_drum_command}

proc set_drum_combobox_values {pickedmeter} {
    global d2_4 d3_4 d5_8 d6_8 d7_8 d4_4 d9_8 d11_8 d12_8
    global drumentry
    global mididrum
    set values {}
    switch $pickedmeter {
       2  {set values $d2_4}
       3  {set values $d3_4}
       4  {set values $d4_4}
       C  {set values $d4_4}
       C| {set values $d4_4}
       5  {set values $d5_8}
       6  {set values $d6_8}
       7  {set values $d7_8}
       9  {set values $d9_8}
      11  {set values $d11_8}
      12  {set values $d12_8}
       default {set values "" }
      }
    set v "none "
    set values [append v $values]
   .abc.midi1.drum.combo configure -values $values
    if {[info exist mididrum($pickedmeter)]} {
       set drumentry $mididrum($pickedmeter)
       } else {
       set drumentry "none"
      }  
   }
  

proc make_drum_command {} {
    global pickedmeter
    global drumentry
    if  {$drumentry == "none"} return
    if {[winfo exists .drumkit] == 1} {prepare_drumentry}
    }


set w .abc.midi1
pack $w.drum.lab $w.drum.combo $w.drum.cfg  -side left





proc random_drum {} {
    global midi
    set n [llength $midi(selected_drums)]
    set m [expr int(rand()*$n)]
    return [lindex $midi(selected_drums) $m]
}

proc parse_drum_string {input} {
    set charlist [split $input ""]
    set result {}
    set item ""
    set kount 0
    foreach letter $charlist {
        switch -regexp $letter {
            d {
                set result [concat $result $item]
                incr kount
                set item d}
            z {
                set result [concat $result $item]
                set item z}
            [0-9]
            {set item [append item $letter]}
        }
    }
    set result [concat $result $item]
return [list $kount $result]
}

proc create_random_drum_command {code} {
    global midi drumvel
    set drumlist [lindex [parse_drum_string $code] 1]
    set drumcmd  $code
    set i 0
    foreach elem $drumlist {
        set initialchar [string index $elem 0]
        if {$initialchar != "d"} continue
        set n [expr [random_drum] + 35]
        set drumcmd "$drumcmd $n"
        set drumvel($i) dmedium
        incr i
    }
    set drumcmd [append_drum_velocities $drumcmd]
    if {[winfo exist .drumkit]} {prepare_drumentry $drumcmd}
    return $drumcmd
}

proc append_drum_velocities {drumcmd} {
    global drumvel midi
    set drumcmd "$drumcmd "
    set drumproglist [lrange $drumcmd 1 end]
    set i 0
    foreach elem $drumproglist {
        set n $midi($drumvel($i))
        set drumcmd "$drumcmd $n"
    }
    #puts $drumcmd
    return $drumcmd
}


frame $w.gchord
label $w.gchord.lab -text "gchord string" -font $df



set c2_4 {default f2z2 fzfz f2f2 c2c2 gi gI gihi}
set c3_4 {default f2z4 f2f2f2 c2c2c2 f4c2 ghihgh GHIHGH hghihg}
set c6_8 {default f3z3 f3f3 c3c3 hg ghihgh GHIGHI G2gG2g g2hg2h g2cg2c}
set c7_8 {f2z5 f2f2c3 f2f2f3 f3c2c2 f3f2f2}
set c4_4 {default f4f4 c4c4 gi gI ghihghih GHIH GHIHGHIH}
set c9_8 {default f2z6 f3f3f3 c3c3c3 ghighighi g2hg2hg2i G2HG2HG2I}
set c3_2 {default f4c4c4 f4f4f4 f2z2c2z2c2z2 c4c4c4}

set gchordfamily 'default'

set w .abc.midi1.gchord.combo
ttk::combobox $w -width 30  -textvariable gchordentry\
        -font $df -values $gchordfamily
tooltip::tooltip $w  "for chord C:\nf --> C,,  c -> \[C,E,G\] z --> rest\ng --> C, h --> E, i --> G, j--> B,
G --> C,, H --> E,, I --> G,, J --> B,"
$w set default


proc set_gchord_combobox_values {pickedmeter} {
    global c2_4 c3_4 c6_8 c7_8 c4_4 c9_8 c3_2
    global gchordentry midigchord
    switch $pickedmeter {
       2  {set values $c2_4}
       3  {set values $c3_4}
       4  {set values $c4_4}
       C  {set values $c4_4}
       C| {set values $c4_4}
       6  {set values $c6_8}
       7  {set values $c7_8}
       9  {set values $c9_8}
       default {set values default}
      }
   .abc.midi1.gchord.combo configure -values $values 
    set gchordentry "default"
    if {[info exist midigchord($pickedmeter)]} {
       set gchordentry $midigchord($pickedmeter)}
   }



proc setabclev {vol} {
    global midi
    set midi(beat_a) $vol
    set midi(beat_b) [expr $vol -$midi(beat_offset)]
    set midi(beat_c) [expr $vol -2*$midi(beat_offset)]
    if {$midi(beat_b) < 0} {set midi(beat_b) 0}
    if {$midi(beat_c) < 0} {set midi(beat_c) 0}
}

proc setdoublelev {vol} {
    global midi
    set midi(beat2_a) $vol
    set midi(beat2_b) [expr $vol -$midi(beat_offset)]
    set midi(beat2_c) [expr $vol -2*$midi(beat_offset)]
    if {$midi(beat2_b) < 0} {set midi(beat_b) 0}
    if {$midi(beat2_c) < 0} {set midi(beat_c) 0}
}

grid .abc.midi1.gchord.lab .abc.midi1.gchord.combo  -sticky w


# advanced midi features
set w .abc.midi1.beat
frame $w
label $w.lab1 -text "on beat" -font $df
label $w.lab2 -text "off beat" -font $df
label $w.lab3 -text "other" -font $df
entry $w.a -width 4 -textvariable midi(beat_a) -font $df
entry $w.b -width 4 -textvariable midi(beat_b) -font $df
entry $w.c -width 4 -textvariable midi(beat_c) -font $df
pack  $w.lab1 $w.a $w.lab2  $w.b $w.lab3 $w.c -side left
bind .abc.midi1.beat.a   <Return> {focus .abc.midi1.beat.lab1}
bind .abc.midi1.beat.b   <Return> {focus .abc.midi1.beat.lab1}
bind .abc.midi1.beat.c   <Return> {focus .abc.midi1.beat.lab1}

checkbutton .abc.midi1.fermata -text "ignore fermatas" -font $df -variable midi(nofermata)
checkbutton .abc.midi1.nograce -text "ignore grace notes" -font $df -variable midi(nograce)
checkbutton .abc.midi1.quiet -text "fewer messages" -font $df -variable midi(quiet)
checkbutton .abc.midi1.silent -text "no messages" -font $df -variable midi(silent)

set w .abc.midi1.grace
frame $w
label $w.grace -text "grace divider" -font $df
entry $w.graceval -width 2 -font $df -textvariable midi(gracedivider)
pack  $w.grace $w.graceval -side left
bind .abc.midi1.grace.graceval   <Return> {focus .abc.midi1.grace.grace}

set w .abc.midi1.broken
frame $w
label $w.lab2 -text "broken rhythm ratio" -font $df
entry $w.ent1 -width 1 -font $df -textvariable midi(ratio_n)
entry $w.ent2 -width 1 -font $df -textvariable midi(ratio_m)
pack  $w.lab2 $w.ent1 $w.ent2 -side left
bind .abc.midi1.broken.ent1   <Return> {focus .abc.midi1.grace.grace}
bind .abc.midi1.broken.ent2   <Return> {focus .abc.midi1.grace.grace}

set w .abc.midi1.barfly
frame $w
checkbutton $w.but -text "BarFly mode" -variable midi(barflymode) -font $df
radiobutton $w.rad1 -text "1" -variable midi(stressmodel) -font $df \
        -value 1
radiobutton $w.rad2 -text "2" -variable midi(stressmodel) -font $df \
        -value 2
label $w.lab -text "Stress Model" -font $df
pack $w.but $w.lab $w.rad1 $w.rad2 -side left



set w .abc.midi1.drummethod
frame $w
checkbutton $w.but -text "use drum map" -variable midi(drummap) -font $df
pack $w.but


set w .abc.midi1.divider
frame $w
label $w.lab1 -text "beat divider" -font $df
entry $w.n -width 3 -textvariable midi(beat_n) -font $df
pack $w.lab1 $w.n -side left -anchor w
bind .abc.midi1.divider.n   <Return> {focus .abc.midi1.divider.lab1}


set w .abc.midi1.reset
frame $w
button $w.default -text "reset default settings" -font $df -command reset_advanced_midi
pack  $w.default -side left -anchor w

set w .abc.midi1.drone
frame $w
checkbutton $w.drone -text "bagpipe drone on" -variable midi(drone) -font $df
pack $w.drone -side left -anchor w
scale $w.tenordrone -from 0 -to 127 -length 128  \
        -width 10 -orient horizontal  -showvalue true \
        -variable midi(tenordrone)   -font $df
scale $w.bassdrone -from 0 -to 127 -length 128  \
        -width 10 -orient horizontal  -showvalue true \
        -variable midi(bassdrone)   -font $df
tooltip::tooltip $w.bassdrone "bass level"
tooltip::tooltip $w.tenordrone "tenor level"
pack $w.tenordrone $w.bassdrone -side left -anchor w


proc enable_disable_drone {status} {
    if {$status} {
        .abc.midi1.drone.drone configure -state normal
        .abc.midi1.drone.bassdrone configure -state normal
        .abc.midi1.drone.tenordrone configure -state normal
    } else {
        .abc.midi1.drone.drone configure -state disabled
        .abc.midi1.drone.bassdrone configure -state disabled
        .abc.midi1.drone.tenordrone configure -state disabled
    }
}

proc reset_advanced_midi {} {
    global midi
    set midi(beat_a) 105
    set midi(beat_b) 95
    set midi(beat_c) 80
    set midi(beat_n) 4
    set midi(gracedivider) 4
    set midi(nofermata) 0
    set midi(nograce) 0
    set midi(silent) 0
    set midi(quiet) 0
    set midi(ratio_n) 2
    set midi(ratio_m) 1
}

# voice Property Sheet

frame .abc.voice
canvas .abc.voice.canvas -width 80 -height 20 \
        -yscrollcommand [list .abc.voice.yscroll set]
scrollbar .abc.voice.yscroll -orient vertical \
        -command [list .abc.voice.canvas yview]
pack  .abc.voice.yscroll -side right -fill y
pack  .abc.voice.canvas -side left -fill both -expand true

set w [frame .abc.voice.canvas.f -bd 0]
.abc.voice.canvas create window 0 0 -anchor nw -window $w

label $w.head0 -text V: -font $df
label $w.head1 -text program -font $df
label $w.head2 -text level -font $df
label $w.head3 -text pan -font $df

for {set i 1} {$i <17} {incr i} {
    label $w.lab$i -text $i -font $df
    set i1 [expr int(1 + $midi(voice$i)/8)]
    set i2 [expr $midi(voice$i) % 8 ]
    button $w.prog$i -text [lindex $m($i1) $i2]  -font $df -width 20 -pady 1
    eval {bind $w.prog$i <Button> [list voice_button $i %X %Y]}
    scale $w.pan$i -from 0 -to 127 -length 128  \
            -width 8 -orient horizontal  -showvalue true \
            -variable midi(pvoice$i) -font $df
    scale $w.vol$i -from 0 -to 127 -length 128  \
            -width 8 -orient horizontal  -showvalue true \
            -variable midi(lvoice$i) -font $df
}


proc random_voice_arrangement {} {
global midi
set midiproglist {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
    20 21 22 23 14 15 16 17 28 29 30 31 32 33 34 35 36 37 38 39 
    40 41 42 43 44 45 46 48 49 50 51 52 53 54 55 56 57 58 59 60
    61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80
    81 82 83 84 85 86 87 88 89 90 91 92 93 94 95
   104 105 106 107 108 109 110 111}
# we exclude timpani, rain and other effects

for {set i 1} {$i < 17} {incr i} {
   set v voice$i
   set num [expr int(rand()*103)]
   set midi($v) [lindex $midiproglist $num]
   }
   map_midi_to_voices
}

proc map_midi_to_voices {} {
global midi
global m
set w .abc.voice.canvas.f
for {set i 1} {$i <17} {incr i} {
  set i1 [expr int(1 + $midi(voice$i)/8)]
  set i2 [expr $midi(voice$i) % 8 ]
  $w.prog$i configure -text [lindex $m($i1) $i2]
  }
}

proc voice_button {num X Y} {
    global window chan
    set window .abc.voice.canvas.f.prog$num
    set chan voice$num
    program_popup $X $Y}

grid   $w.head0 $w.head1 $w.head2 $w.head3
for {set i 1} {$i < 17} {incr i} {
    grid   $w.lab$i  $w.prog$i  $w.vol$i  $w.pan$i -sticky w
}


proc program_popup {rootx rooty} {
    global m df
    
    if {![winfo exists .patchmap]} {
        set instrum_family {piano "chrom percussion" organ guitar bass \
                    strings ensemble brass reed pipe "synth lead" "synth pad" \
                    "synth effects" ethnic percussive "sound effects"}
        set w .patchmap
        menu $w -tearoff 0
        set i 1
        foreach class $instrum_family {
            $w add cascade  -label $class -menu $w.$i -font $df
            set w2 .patchmap.$i
            menu $w2 -tearoff 0
            set j 0
            foreach inst $m($i) {
                $w2 add radiobutton -label $inst \
                        -command "program_select  $i $j " -font $df
                incr j
            }
            incr i
        }
    }
    tk_popup .patchmap $rootx $rooty
}

proc program_select {p1 p2} {
    global midi chan window m
    
    #  puts "program_select $p1 $p2"
    set midi($chan) [expr ($p1-1)*8 + $p2]
    #  set name [.patchmap.$p1 entrycget $p2 -label]
    set name [lindex $m($p1) $p2]
    $window configure -text $name
}


bind .abc.midi1.melody.melodybut <Button> {set window .abc.midi1.melody.melodybut
    set chan program
    program_popup %X %Y}
bind .abc.midi1.chord.chordbut <Button> {set window .abc.midi1.chord.chordbut
    set chan chordprog
    program_popup %X %Y}
bind .abc.midi1.bass.bassbut <Button> {set window .abc.midi1.bass.bassbut
    set chan bassprog
    program_popup %X %Y}
bind .abc.midi1.double.doublebut <Button> {set window .abc.midi1.double.doublebut
    set chan program2
    program_popup %X %Y}


# abc2abc property page
set abc2abc_e 1
set w .abc.abc2abc
set abc2abc_useflats 0
frame $w
frame $w.1
checkbutton $w.1.1 -text "new spacing" -variable abc2abc_s  -font $df
checkbutton $w.1.2 -text "no error report" -variable abc2abc_e -font $df
pack $w.1.1 $w.1.2 -anchor w -side left
checkbutton $w.2 -text "use [] () for chords and slurs" -font $df -variable abc2abc_u
checkbutton $w.3 -text "double note length" -font $df -variable abc2abc_d
checkbutton $w.4 -text "halve note length" -font $df -variable abc2abc_v
frame $w.40
checkbutton $w.40.1 -text "force key to" -font $df -variable abc2abc_nk
menubutton $w.40.2 -menu $w.40.2.type -text none -font $df -relief raised
set p $w.40.2
menu $p.type -tearoff 0
$p.type add command -label Db -font $df -command "forcekeymenu -5"
$p.type add command -label Ab -font $df -command "forcekeymenu -4"
$p.type add command -label Eb -font $df -command "forcekeymenu -3"
$p.type add command -label Bb -font $df -command "forcekeymenu -2"
$p.type add command -label F -font $df -command "forcekeymenu -1"
$p.type add command -label none -font $df -command "forcekeymenu 0"
$p.type add command -label G -font $df -command "forcekeymenu 1"
$p.type add command -label D -font $df -command "forcekeymenu 2"
$p.type add command -label A -font $df -command "forcekeymenu 3"
$p.type add command -label E -font $df -command "forcekeymenu 4"
$p.type add command -label B -font $df -command "forcekeymenu 5"


frame $w.43
checkbutton $w.43.1 -text "force clef to" -font $df -variable abc2abc_cl\
  -command enable_clef_menu
menubutton $w.43.2 -menu $w.43.2.type -text "" -font $df -relief raised -width 5 -state disabled
menu $w.43.2.type -tearoff 0
$w.43.2.type add command -label treble -font $df -command "forceclef 1"
$w.43.2.type add command -label bass -font $df -command "forceclef 2"
pack $w.43.1 $w.43.2 -side left


set abc2abc_usekey 0
global abc2abc_usekey

radiobutton $w.40.3 -text "use sharps" -variable abc2abc_useflats \
        -relief flat -value 0 -font $df
radiobutton $w.40.4 -text "use flats" -variable abc2abc_useflats \
        -relief flat -value 1 -font $df
pack $w.40.1 $w.40.2 $w.40.3 $w.40.4 -side left
frame $w.5
checkbutton $w.5.1 -text "transpose" -font $df -variable abc2abc_t
entry $w.5.2 -width 3 -textvariable abc2abc_t_val -font $df
bind $w.5.2 <Return> {focus .abc.abc2abc.5}
label $w.5.3 -text semitones -font $df
pack $w.5.1 $w.5.2 $w.5.3 -side left
frame $w.6
checkbutton $w.6.1 -text "linebreaks every " -font $df -variable abc2abc_n
entry $w.6.2 -width 2 -textvariable abc2abc_n_val
label $w.6.3 -text "bars" -font $df
pack $w.6.1 $w.6.2 $w.6.3 -side left
frame $w.7
checkbutton $w.7.1 -text "extract only voice " -font $df -variable abc2abc_V
entry $w.7.2 -width 2 -textvariable abc2abc_V_val -font $df
pack $w.7.1 $w.7.2 -side left
frame $w.11
checkbutton $w.11.1 -text "apply to only voice " -font $df -variable abc2abc_P
entry $w.11.2 -width 2 -textvariable abc2abc_P_val -font $df
pack $w.11.1 $w.11.2 -side left
frame $w.8
radiobutton $w.8.0 -text "output to clipboard"  -variable midi(no_clipboard) \
        -relief flat -value 0  -font $df
radiobutton $w.8.1 -text "output to editor"     -variable midi(no_clipboard) \
        -relief flat -value 1  -font $df
radiobutton $w.8.2 -text "display"     -variable midi(no_clipboard) \
        -relief flat -value 2  -font $df
pack $w.8.0 $w.8.1 $w.8.2 -side left
frame $w.9
button $w.9.1 -text "abc2abc" -font $df -command run_abc2abc
button $w.9.2 -text "help" -font $df -command contexthelp
pack $w.9.1 $w.9.2 -side left
label $w.10 -text "" -font $df
pack $w.1 $w.2 $w.3 $w.4 $w.40 $w.43 $w.5 $w.6 $w.7 $w.11 $w.8 $w.9 $w.10 -side top -anchor w

proc forcekeymenu {fsf} {
    #fsf force sharps/flats
    global abc2abc_usekey
    set key [lindex {Db Ab Eb Bb F none G D A E B} [expr $fsf+5]]
    .abc.abc2abc.40.2 configure -text $key
    set abc2abc_usekey $fsf
    if {$fsf == 0} {
        .abc.abc2abc.40.3 configure -state normal
        .abc.abc2abc.40.4 configure -state normal
    } else {
        .abc.abc2abc.40.3 configure -state disabled
        .abc.abc2abc.40.4 configure -state disabled
    }
}


proc enable_clef_menu {} {
global abc2abc_cl
if {!$abc2abc_cl} {
  .abc.abc2abc.43.2 configure -state disabled
  } else {
  .abc.abc2abc.43.2 configure -state normal
  }
}


proc forceclef {choice} {
set clef ""
global abc2abc_clef
switch $choice {
	1 {set clef treble}
	2 {set clef bass}
}
.abc.abc2abc.43.2 configure -text $clef
set abc2abc_clef $clef
}

forceclef 1


# Config property page

set fontfamily [lsort [font families]]
set encodefamily [lsort [encoding names]]

set w .abc.cfg
frame $w
for {set i 1} {$i <= 30} {incr i} {
    frame $w.$i
}
#deprecated
#button $w.1.0 -text abc2ps -width 14 -command {setpath path_abc2ps}  -font $df
#entry $w.1.1 -width 38 -relief sunken -textvariable midi(path_abc2ps) -font $df
#pack $w.1.0 $w.1.1  -side left
#bind .abc.cfg.1.1 <Return> {focus .abc.cfg.1}

button $w.20.0 -text abcm2ps -width 14 -command {setpath path_abcm2ps}  -font $df
entry $w.20.1 -width 38 -relief sunken -textvariable midi(path_abcm2ps) -font $df
pack $w.20.0 $w.20.1  -side left
bind .abc.cfg.20.1 <Return> {focus .abc.cfg.20}

button $w.21.0 -text abc2abc -width 14 -command {setpath path_abc2abc}  -font $df
entry $w.21.1 -width 38 -relief sunken -textvariable midi(path_abc2abc) -font $df
pack $w.21.0 $w.21.1  -side left
bind .abc.cfg.21.1 <Return> {focus .abc.cfg.21}

button $w.24.0 -text midi2abc -width 14 -command {setpath path_midi2abc} -font $df
entry $w.24.1 -width 38 -relief sunken -textvariable midi(path_midi2abc) -font $df
pack $w.24.0 $w.24.1 -side left
bind .abc.cfg.24.1 <Return> {focus .abc.cfg.24}

button $w.25.0 -text midicopy -width 14 -command {setpath path_midicopy} -font $df
entry $w.25.1 -width 38 -relief sunken -textvariable midi(path_midicopy) -font $df
pack $w.25.0 $w.25.1 -side left
bind .abc.cfg.25.1 <Return> {focus .abc.cfg.25}

button $w.26.0 -text "abcmidi folder" -width 14 -command {locate_abcmidi_executables} -font $df
entry $w.26.1 -width 38 -relief sunken -textvariable midi(dir_abcmidi) -font $df
pack $w.26.0 $w.26.1 -side left
bind .abc.cfg.26.1 <Return> {focus .abc.cfg.26}

button $w.22.0 -text abcmatch -width 14 -command {setpath path_abcmatch}  -font $df
entry $w.22.1 -width 38 -relief sunken -textvariable midi(path_abcmatch) -font $df
pack $w.22.0 $w.22.1  -side left
bind .abc.cfg.22.1 <Return> {focus .abc.cfg.22}

button $w.2.0 -text yaps -width 14  -command {setpath path_yaps} -font $df
entry $w.2.1 -width 38 -relief sunken -textvariable midi(path_yaps) -font $df
pack $w.2.0 $w.2.1  -side left
bind .abc.cfg.2.1 <Return> {focus .abc.cfg.22}

button $w.3.0 -text abc2midi -width 14  -command {setpath path_abc2midi} -font $df
entry $w.3.1 -width 38 -relief sunken -textvariable midi(path_abc2midi) -font $df
pack $w.3.0 $w.3.1  -side left
bind .abc.cfg.3.1 <Return> {focus .abc.cfg.3}

button $w.4.0 -text "PostScript viewer" -width 14  -command {setpath path_gv} -font $df
entry $w.4.1 -width 38 -relief sunken -textvariable midi(path_gv) -font $df
pack $w.4.0 $w.4.1  -side left
bind .abc.cfg.4.1 <Return> {focus .abc.cfg.4}

button $w.30.0 -text ghostscript -width 14  -command {setpath path_gs} -font $df
entry $w.30.1 -width 38 -relief sunken -textvariable midi(path_gs) -font $df
pack $w.30.0 $w.30.1  -side left
bind .abc.cfg.30.1 <Return> {focus .abc.cfg.4}

button $w.5.0 -text "midiplayer 1" -width 14  -command {setpath path_midiplayer_1} -font $df
entry $w.5.1 -width 42 -relief sunken -textvariable midi(path_midiplayer_1) -font $df
pack $w.5.0 $w.5.1  -side left
bind .abc.cfg.5.1 <Return> {focus .abc.cfg.5}

button $w.6.0 -text "player 1 opts" -width 14 -command {}  -font $df
entry $w.6.1 -width 42 -relief sunken -textvariable midi(midiplayer_1_options) -font $df
pack $w.6.0 $w.6.1  -side left
bind .abc.cfg.6.1 <Return> {focus .abc.cfg.6}

button $w.7.0 -text "midiplayer 2" -width 14 -command {setpath path_midiplayer_2} -font $df
entry $w.7.1 -width 42 -relief sunken -textvariable midi(path_midiplayer_2) -font $df
pack $w.7.0 $w.7.1  -side left
bind .abc.cfg.7.1 <Return> {focus .abc.cfg.7}

button $w.8.0 -text "player 2 options" -width 14 -command {} -font $df
entry $w.8.1 -width 42 -relief sunken -textvariable midi(midiplayer_2_options) -font $df
pack $w.8.0 $w.8.1  -side left
bind .abc.cfg.8.1 <Return> {focus .abc.cfg.8}

frame $w.36
button $w.36.0 -text "midiplayer 3" -width 14  -command {setpath path_midiplayer_3} -font $df
entry $w.36.1 -width 42 -relief sunken -textvariable midi(path_midiplayer_3) -font $df
pack $w.36.0 $w.36.1  -side left
bind .abc.cfg.36.1 <Return> {focus .abc.cfg.36}

frame $w.37
button $w.37.0 -text "player 3 options" -width 14 -command {} -font $df
entry $w.37.1 -width 42 -relief sunken -textvariable midi(midiplayer_3_options) -font $df
pack $w.37.0 $w.37.1  -side left
bind .abc.cfg.37.1 <Return> {focus .abc.cfg.37}

frame $w.40
button $w.40.0 -text "midiplayer 4" -width 14  -command {setpath path_midiplayer_4} -font $df
entry $w.40.1 -width 42 -relief sunken -textvariable midi(path_midiplayer_4) -font $df
pack $w.40.0 $w.40.1  -side left
bind .abc.cfg.40.1 <Return> {focus .abc.cfg.40}

frame $w.41
button $w.41.0 -text "player 4 options" -width 14 -command {} -font $df
entry $w.41.1 -width 42 -relief sunken -textvariable midi(midiplayer_4_options) -font $df
pack $w.41.0 $w.41.1  -side left
bind .abc.cfg.41.1 <Return> {focus .abc.cfg.41}

frame $w.39
label $w.39.lab -text "default midi player" -font $df
radiobutton $w.39.b0 -text "player 1"  -variable midi(player) \
        -relief flat -value 0  -font $df
radiobutton $w.39.b1 -text "player 2"  -variable midi(player) \
        -relief flat -value 1  -font $df
radiobutton $w.39.b2 -text "player 3"  -variable midi(player) \
        -relief flat -value 2  -font $df
radiobutton $w.39.b3 -text "player 4"  -variable midi(player) \
        -relief flat -value 3  -font $df
pack  $w.39.lab $w.39.b0 $w.39.b1 $w.39.b2 $w.39.b3 -side left


label $w.9.0 -text "gui font" -width 10  -font $df
entry $w.9.1 -width 24 -relief sunken -textvariable midi(font_family) -font $df
pack $w.9.0 $w.9.1 -side left
bind $w.9.1 <Return> {
    change_font 0
    focus .abc.cfg.9.0}

button $w.10.0 -text editor -width 14  -command {setpath path_editor} -font $df
entry $w.10.1 -width 38 -relief sunken -textvariable midi(path_editor) -font $df
pack $w.10.0 $w.10.1  -side left
bind .abc.cfg.10.1 <Return> {focus .abc.cfg.10}

label $w.23.0 -text "work folder" -width 16 -padx 2  -font $df
entry $w.23.1 -width 38 -relief sunken -textvariable midi(abc_work_folder) -font $df
pack $w.23.0 $w.23.1  -side left
bind .abc.cfg.23.1 <Return> {focus .abc.cfg.23}

button $w.29.0 -text "internet browser" -width 14  -font $df -command {setpath path_internet}
entry $w.29.1 -width 38 -relief sunken -textvariable midi(path_internet) -font $df
pack $w.29.0 $w.29.1 -side left
bind .abc.cfg.29.1 <Return> {focus .abc.cfg.29}

#button options midi(butborder) midi(butrelief) midi(butbg)
frame $w.32
label $w.32.lab -text "border width" -font $df
radiobutton $w.32.b0 -text "0" -variable midi(butborder) \
   -relief flat -value 0 -font $df
radiobutton $w.32.b1 -text "1" -variable midi(butborder) \
   -relief flat -value 1 -font $df
radiobutton $w.32.b2 -text "2" -variable midi(butborder) \
   -relief flat -value 2 -font $df
radiobutton $w.32.b3 -text "3" -variable midi(butborder) \
   -relief flat -value 3 -font $df
radiobutton $w.32.b4 -text "4" -variable midi(butborder) \
   -relief flat -value 4 -font $df
radiobutton $w.32.b5 -text "5" -variable midi(butborder) \
   -relief flat -value 5 -font $df
pack $w.32.lab $w.32.b0 $w.32.b1 $w.32.b2 $w.32.b3 $w.32.b4 $w.32.b5 -side left

frame $w.33
label $w.33.lab -text "button relief" -font $df
radiobutton $w.33.b0 -text "raised" -variable midi(butrelief) \
   -relief flat -value raised -font $df
radiobutton $w.33.b1 -text "sunken" -variable midi(butrelief) \
   -relief flat -value sunken -font $df
radiobutton $w.33.b2 -text "ridge" -variable midi(butrelief) \
   -relief flat -value ridge -font $df
radiobutton $w.33.b3 -text "solid" -variable midi(butrelief) \
   -relief flat -value solid -font $df
radiobutton $w.33.b4 -text "groove" -variable midi(butrelief) \
   -relief flat -value groove -font $df
radiobutton $w.33.b5 -text "flat" -variable midi(butrelief) \
   -relief flat -value flat -font $df
pack $w.33.lab $w.33.b0 $w.33.b1 $w.33.b2 $w.33.b3 $w.33.b4 $w.33.b5 -side left

frame $w.34
label $w.34.lab -text "button background" -font $df
radiobutton $w.34.b0 -text "white" -value white -variable midi(butbg) -font $df 
radiobutton $w.34.b1 -text "azure" -value "azure" -variable midi(butbg) -font $df 
radiobutton $w.34.b2 -text "beige" -value "beige" -variable midi(butbg) -font $df 
radiobutton $w.34.b3 -text "light yellow" -value "light yellow" -variable midi(butbg) -font $df 
radiobutton $w.34.b4 -text "grey" -value "light grey" -variable midi(butbg) -font $df 
pack $w.34.lab $w.34.b0 $w.34.b1 $w.34.b2 $w.34.b3 $w.34.b4 -side left

frame $w.35
button $w.35.but -text "Apply options" -font $df -command {configure_buttons}
pack $w.35.but -side left

#frame $w.11 not used




label $w.13.lab -text "transfer protocol 1" -font $df
radiobutton $w.13.b0 -text "one file"  -variable midi(midiplayer_1_prot) \
        -relief flat -value 0  -font $df
radiobutton $w.13.b1 -text "file list"  -variable midi(midiplayer_1_prot) \
        -relief flat -value 1  -font $df
radiobutton $w.13.b2 -text "folder"  -variable midi(midiplayer_1_prot) \
        -relief flat -value 2  -font $df
pack $w.13.lab $w.13.b0 $w.13.b1 $w.13.b2 -side left

label $w.14.lab -text "transfer protocol 2" -font $df
radiobutton $w.14.b0 -text "one file"  -variable midi(midiplayer_2_prot) \
        -relief flat -value 0  -font $df
radiobutton $w.14.b1 -text "file list"  -variable midi(midiplayer_2_prot) \
        -relief flat -value 1  -font $df
radiobutton $w.14.b2 -text "folder"  -variable midi(midiplayer_2_prot) \
        -relief flat -value 2  -font $df
pack $w.14.lab $w.14.b0 $w.14.b1 $w.14.b2 -side left

frame $w.38
label $w.38.lab -text "transfer protocol 3" -font $df
radiobutton $w.38.b0 -text "one file"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 0  -font $df
radiobutton $w.38.b1 -text "file list"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 1  -font $df
radiobutton $w.38.b2 -text "folder"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 2  -font $df
pack $w.38.lab $w.38.b0 $w.38.b1 $w.38.b2 -side left

frame $w.42
label $w.42.lab -text "transfer protocol 4" -font $df
radiobutton $w.42.b0 -text "one file"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 0  -font $df
radiobutton $w.42.b1 -text "file list"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 1  -font $df
radiobutton $w.42.b2 -text "folder"  -variable midi(midiplayer_3_prot) \
        -relief flat -value 2  -font $df
pack $w.42.lab $w.42.b0 $w.42.b1 $w.42.b2 -side left

label $w.15.lab -text size -font $df
radiobutton $w.15.b0 -text 7  -variable midi(font_size) \
        -relief flat -value 7  -command {change_font 0} -font $df
radiobutton $w.15.b1 -text 8  -variable midi(font_size) \
        -relief flat -value 8  -command {change_font 0} -font $df
radiobutton $w.15.b2 -text 9  -variable midi(font_size) \
        -relief flat -value 9  -command {change_font 0} -font $df
radiobutton $w.15.b3 -text 10  -variable midi(font_size) \
        -relief flat -value 10  -command {change_font 0} -font $df
radiobutton $w.15.b4 -text 11  -variable midi(font_size) \
        -relief flat -value 11  -command {change_font 0} -font $df
radiobutton $w.15.b5 -text 12  -variable midi(font_size) \
        -relief flat -value 12  -command {change_font 0} -font $df
radiobutton $w.15.b6 -text 13  -variable midi(font_size) \
        -relief flat -value 13  -command {change_font 0} -font $df
radiobutton $w.15.b7 -text 14  -variable midi(font_size) \
        -relief flat -value 14  -command {change_font 0} -font $df
radiobutton $w.15.b8 -text 18  -variable midi(font_size) \
        -relief flat -value 18  -command {change_font 0} -font $df
pack $w.15.lab $w.15.b0 $w.15.b1 $w.15.b2 $w.15.b3 $w.15.b4 $w.15.b5 $w.15.b6 $w.15.b7 $w.15.b8 -side left

label $w.16.lab -text weight -font $df
radiobutton $w.16.b1 -text normal -font $df -variable midi(font_weight) -value normal -command {change_font 0}
radiobutton $w.16.b2 -text bold   -font $df -variable midi(font_weight) -value bold   -command {change_font 0}
pack $w.16.lab $w.16.b1 $w.16.b2 -side left

button $w.17.1 -text apply -command {change_font 1} -font $df
button $w.17.2 -text reset -font $dfreset -command reset_font
label $w.27.1 -text abcdeABCDE -font $sf
pack $w.27.1 -side left

set samplefont $midi(font_family)
ttk::combobox $w.17.4 -width 16  -textvariable samplefont\
        -font $df -values $fontfamily

pack $w.17.1 $w.17.2 -side left
pack $w.17.4 -side left

bind $w.17.4 <<ComboboxSelected>> {font configure $sf -family $samplefont}
bind $w.17.4 <Enter> {focus .abc.cfg}


label $w.18.0 -text "editor font" -width 10  -font $df
entry $w.18.1 -width 24 -relief sunken -textvariable midi(font_family_toc) -font $df
bind $w.18.1 <Return> {
    change_font 0
    focus .abc.cfg.18.0}
pack $w.18.0 $w.18.1 -side left

message $w.19.0 -aspect 300 -font $df
pack $w.19.0

frame $w.31
label $w.31.0 -text "character encoder" -font $df
set encodechar $midi(encoder)
ttk::combobox $w.31.1 -width 16  -textvariable encodechar\
        -font $df -values $encodefamily
button $w.31.2 -text apply -font $df -command {set midi(encoder) $encodechar}
button $w.31.3 -text reset -font $df -command {set midi(encoder) [encoding system]}

pack $w.31.0 $w.31.1 $w.31.2 $w.31.3 -side left


set active_ps_sheet abc2ps
global active_ps_sheet

proc switch_ps_button {} {
    global midi
    global active_ps_sheet
    if {$midi(ps_creator)=="yaps"} {
        pack forget .abc.functions.$active_ps_sheet
        pack .abc.functions.yaps -after .abc.functions.playopt -side left
        set active_ps_sheet yaps
    } elseif {$midi(ps_creator)=="other"} {
        pack forget .abc.functions.$active_ps_sheet
        pack .abc.functions.otherps -after .abc.functions.playopt -side left
        set active_ps_sheet otherps
    } elseif {$midi(ps_creator)=="abc2svg"} {
        pack forget .abc.functions.$active_ps_sheet
        pack .abc.functions.abc2svg -after .abc.functions.playopt -side left
        set active_ps_sheet abc2svg
    } else {
        pack forget .abc.functions.$active_ps_sheet
        pack .abc.functions.abc2ps -after .abc.functions.playopt -side left
        set active_ps_sheet abc2ps
        if {$midi(ps_creator)=="abcm2ps"} {
            .abc.functions.abc2ps config -text abcm2ps
            grid forget .abc.m2psbool.maxvlab .abc.m2psbool.maxvent
            grid forget .abc.m2psbool.maxslab .abc.m2psbool.maxsent
            grid forget .abc.m2psbool.voices  .abc.m2psbool.voicesent
            grid .abc.m2psbool.nolyric .abc.m2psbool.noslur -sticky w
            grid .abc.m2psbool.psoutput .abc.m2psbool.svgoutput .abc.m2psbool.xhtmloutput -sticky w
            if {$midi(ps_fmt_flag) == 0} {
                grid forget .abc.m2psfloat.glue .abc.m2psfloat.gluemenu}
            grid .abc.m2psfloat.other_opts .abc.m2psfloat.other_optsent -sticky w
# abc2ps being deprecated
        } else {
            .abc.functions.abc2ps config -text abc2ps
            grid forget .abc.m2psbool.nolyric .abc.m2psbool.noslur
            grid forget .abc.m2psbool.psoutput .abc.m2psbool.svgoutput .abc.m2psbool.xhtmloutput
            grid .abc.m2psbool.voices .abc.m2psbool.voicesent -sticky w
            grid .abc.m2psbool.maxvlab .abc.m2psbool.maxvent  -sticky w
            grid .abc.m2psbool.maxslab .abc.m2psbool.maxsent  -sticky w
            if {$midi(ps_fmt_flag) == 0} {
                grid .abc.m2psfloat.glue .abc.m2psfloat.gluemenu -sticky w
                grid forget .abc.m2psfloat.other_opts .abc.m2psfloat.other_optsent}
            bind .abc.m2psbool.maxvent    <Return> {focus .abc.m2psbool.maxvlab}
            bind .abc.m2psbool.maxsent    <Return> {focus .abc.m2psbool.maxvlab}
            bind .abc.m2psbool.voicesent  <Return> {focus .abc.m2psbool.maxvlab}
        }
    }
}



# Part 13.0                  Help texts


set hlp_overview "You are running runabc.tcl version $runabc_version $runabc_date\n\n\
        You can get the latest version of this application from the\
        web site http://ifdo.ca/~seymour/runabc/top.html\n\n\
        This is a graphical user interface to abcm2ps, yaps, abcmidi, a \
        PostScript file viewer and midi file player and many other executables.\
        If you are running the program for the first time, you need to specify\
        the path name to these executables in the configuration property sheet. \
        Click the config/abc executables button and then the help button for\
        further instructions.\n\n\
        Once you have properly configured the program, use the 'file' \
        button to select the input abc file. This is a button with a picture\
        of a file on the top left corner.) Click the browse menu to\
        to browse through you file structure. Alternatively, you may\
        enter the relative or absolute path name in the adjoining entry\
        box followed with a carriage return to activate. (This works only if\
        a table of contents is already displayed.) For many entry boxes\
        pressing a carriage return will remove the focus (cursor) from\
        that box.\n\n  The abc file may consist of \
        compilation of many tunes. The list of tune titles will be displayed \
        in the listbox below. Select one or tunes and then click one \
        of the buttons described below. To select several tunes, either sweep \
        the mouse cursor over the tunes holding the left button down, or else \
        click on each tune while holding either the shift or control key down.\n\n\
        Quit		Will write the runabc.ini to disk and exit the program.\n\n\
        Play selection	Will run abc2midi on the selected tune and play the resulting \
        midi file.\n\n\
        Display		Will run abc2ps on the selected tune and display the output. \n\n\
        Edit/menu	Will allow you to edit the selected tune and save only this tune \
        in a separate  file.\n\n\
        Console		Will display any error messages originating from abc2ps or \
        abc2midi.\n\n\
        The remaining buttons 'TOC', 'Play options', 'Display options' and \
        'Options' will replace the current sheet with a property sheet that allows \
        you to modify how the midi file or postscript file is created. There are \
        separate help pages for each button. Click the button once for the page \
        to appear. Click the same button again to remove that sheet. \
        Clicking a different button will bring up a different property page. \
        There are two possible property pages associated with the 'postscript' \
        button. The appropriate page will be displayed depending on whether abc2ps \
        or yaps was selected in the 'config' property page. \
        Click the help button for further instructions when \
        one of these property pages is in view.\n\n

The main page (showing the table of contents TOC) of the active\
        abc file, has a tempo slider allowing you to specify the tempo\
        in beats per minute. This is only effective when the specific\
        tune does not have a Q: tempo field or you have set runabc\
        to override the tempo indication. When the slider is enabled,\
        the trough is colored red. When it is disabled, the trough is\
        grey. The size of a beat is specified by the adjoining\
        combobox at the right. If the input tune does not specify\
        the beat size then it a beat is assumed to be 1/4 note.\n\n

Other bindings\n\n
The arrow, page up/down, home, end keys allow you to scroll up and\
        down the table of contents. The <cntl>-slash and <cntl>-backslash allow\
        you to select or deselect all titles in the table of contents.\
        The p key  or <space> will play the current selection and the d key will \
        display this selection. The E key will edit the file; the e key will\
        start up TclAbcEditor.\n\n\

If your browser supports auto-reload (eg firefox with an addon) then you can\
right click on the print button and a new copy of the browser will not\
be called. Instead the current displayed music will be replaced in the\
browser. This applies only to abcm2ps with xhtml or svg output.


Seymour.Shlien  fy733@ncf.ca February 22 2021."


set hlp_config_1 "Configuration Property Sheet\n\n\This page is\
        used to specify the file path names to the various executables called\
        by this program. It is probably most convenient to put these\
        executables (except for ghostview) in the same folder as runabc.\
        In particular all the executables in the abcmidi package should be in the\
        same folder.  When you start up runabc.tcl for the first time, the\
        entry boxes will \ be configured for my own computer. This is probably\
        not the way things are set up on your own computer but it at least\
        provides you with an example.\n\n\
        For convenience, clicking one of the left buttons on this property \
        sheet will pop up a file browser, which will allow you to find and \
        indicate the location of the desired executable. Once you have located \
        this file, click on 'open' to save this path name in the entry box. The \
        contents of the entry box can also be modified by clicking to the \
        position in the box using the regular keys on your keyboard. The left \
        and right arrow keys will move the entry cursor. Though Tcl/Tk supports \
        long file names it may get confused if the path name includes blanks or \
        the backward slash. If the filename or folder where the executable is \
        found contains embedded spaces, it may be necessary to substitute the \
        DOS filename instead.\n\n\
        The executables in the abcmidi package form the core of the program.\
        You specify the folder where all these executables are found, and\
        runabc will attempt to open these files and determine their version\
        numbers. This will be displayed in a separate window labeled 'summary'.\
        The last column in that display specifies the minimum version number\
        expected in order for the program to run properly. Runabc will also\
        append additional buttons and entries in the options page, in case\
        you need to tune up the pathnames to the individual abcmidi executables.\
        This should really not be necessary. \n\n\
        If runabc is running on Windows (98,ME,NT etc.) you can\
        associate the abc files to runabc through the registry. Click that\
        button and then the help button in the new window for more information.\n\n
If you are going to play your midi files on a midi player you should \
        also go to the config/player 1 configuration page. Go to this page \
        and click the help button for more instructions.\n\n"

set hlp_config_2 "Midi Player\n\n\
        This configuration page is used to specify the path name \
        to the midi player, any required run time options and the protocol for \
        passing the midi files to the midi player. All midi players handle single \
        files.  Others can accommodate a list of midi files, while some will even \
        accept a folder of midi files. The manner of passing the midi file(s) \
        to the player is specified by the protocol. You may use any of the three \
        protocols even if you are only passing one midi file to the player, provided \
        the player supports this method. If you are passing a \
        folder then the folder name should be given in the options entry \
        box and the 'folder' radio button should be selected. It is necessary \
        to do this manually since some midi players require the folder name \
        to be preceded by a flag. Note that in some operating systems there may \
        be a limit in the length of the string containing the list of midi files. \n\n\
        When you click the play button, runabc creates \
        a file called X.tmp containing the selected abc tunes and puts it \
        in a tmp folder in the same folder from which runabc.tcl is \
        invoked.  Prior to running abc2midi, any midi files \
        beginning with the letter X are removed from the tmp directory. Then \
        abc2midi is executed with the file X.tmp and it creates a new set of \
        midi files. These midi files are sent to a designated midi player using one \
        of three protocols. You are allowed to designate up to two possible midi \
        players which have their own option entry box and protocol.\
        The selected midi player is indicated in the midi options page.\n\n\
        A convenient way for viewing the X.tmp file is to click the edit/view X.tmp \
        menu item. Line numbers are added so it is easy to review the error \
        messages from abc2midi."


set hlp_config_3 "Font Selector\n\n\
        This feature allows you to specify the \
        default font, size and weight used by the program. This is a useful \
        feature if your monitor is running in a high resolution and you find the \
        text difficult to read. Increasing the font size will cause Tcl/Tk to \
        automatically readjust the size of all the buttons, entry boxes and \
        other widgets.  There are numerous possible fonts available. If you\
        are running Tcl/Tk version 8.4 a spinbox with the fonts available on\
        your system will appear. Clicking the apply button will make this font\
        the default gui font on your system. Alternatively, you can type the\
        name of the font in the gui font or editor font entry box followed with a <return>.\
        Or else you can enter the font family name in the spinbox entry window\
        and press the apply button.\n\n\
        For other systems you can see the list of available fonts by running\
        your Tcl/Tk interpreter (usually called 'wish') and \
        type 'font families' without the quotes.\n\n If you run into problems and \
        all the controls become unreadable or not usable, you can return to the \
        default font by clearing the family entry box and clicking the apply \
        button or alternatively click the button labeled Reset. In the worst\
        case, edit the runabc.ini file and delete the \
        offending font name associated with the variable font_family. (In \
        other words, leave it blank.)\n\nClicking any radio button causes an \
        immediate action; however if you change the font names in the entry box, \
        it is necessary to click the apply button in order to make the new \
        font immediately effective.\n\nThere is a separate font family assigned \
        to the table of contents (toc). The table of contents (toc) will proper \
        alignment if you use a fixed spacing font (eg Terminal which exists on \
        both Windows and Unix systems) rather than a  variable width spacing.\n\n\
        On Windows system, I prefer the System or Fixedsys font while on Linux \
        I use the fixed font."

set hlp_config_4 "Button appearance\n\n\
This function allows you to configure the appearance of the sequence of\
of button icons that appear on the top of the main window. Besides the\
font command, this function gives you some control on the look and feel\
of the interface. Click on any of the radio buttons and then apply the\
new options by clicking on the activate button."

set hlp_cfg "Other configuration items\n\n\
use ps header: if checked all the postscript commands beginning with %%\
occurring in the beginning of abc file (before the first X:)\
will be inserted in the selected tune before it is displayed.\n
greetings: shows the start up message you see the first time you run runabc.tcl\
i.e. (runabc.ini is missing). The message may report potential problems.\n
sanity check: checks the for the presence of all helper programs (eg. abc2midi)\
which are called by runabc. The version number's of the programs are compared\
with the minimum required version.\n
ignore blank lines: tells runabc not to use blank lines as separators\
between tunes in a collection. A X: reference number declaration is used\
to start a new tune.\n
bell on file write: causes the computer to acknowledge a file output with a\
beep. Does not work on all systems.\n
no confirm for unsaved files: when checked, runabc.tcl does not remind\
you to save an edited abc file when you attempt to close the editor.\
Applies only to editors built in runabc.\n
index by position: this option is mainly applicable to the bar matcher and\
grouper functions. The items in the TOC are normally located by X: reference\
assuming that the X: reference numbers are distinct for each tune in the file.\
If they are not distinct, it may help to reference the tunes by the order they\
are found in the file (index by position).\n
reveal button labels: displays the labels associated with the icons.\n
load runabc extension: allows you to load certain runabc add-ons\
which are too specialized to be included in the general version. These\
add-ons may be used for producing scikit-learn data files for future\
analysis or organizing specific music collections. The function\
asks you to specify the path of a specific tcl file which will be\
sourced in. In many cases the add-on may change the behaviour of\
a specific function in runabc.tcl. To recover the original behaviour,\
you must restart runabc.\n
Many of the modules will pop up their own window. By default\
the window will appear in the center of the screen. You should\
move it to another location so that it does not overlap another\
window. Runabc will remember this location if this window\
is still exposed when you exit midiexplorer and the option\
remember locations of windows is ticked.
"



set hlp_ps "Abcm2ps Boolean and Float Command Options\n\n\
    This property page is used to select the command options for the\
    programs abcm2ps which converts the designated tune in the abc file into a \
    PostScript file and then displays the resulting file. The first three \
    check boxes allow you to indicate whether you want the X: reference \
    numbers, numbered bar numbers and historic notes appearing in the \
    output score. Abcm2ps usually uses the layout of the abc\
    file for determining the number of bars in a line; however, if\
    you check the box 'ignore line ends', then it will fit in as many\
    bars as possible.\n\n\
    For best results, it is recommended that you use a layout file like \
    letter.fmt which is provided with the distribution. This is a text \
    file which can be edited and which allows you to control the font and size of \
    many of the headings. Alternatively, you can try to control the layout \
    using the other options which become available when \
    you untick the check box labeled 'use layout file'. The factory \
    settings were chosen for a low resolution screen.  Abcm2ps\
    can also create svg and xhtml formatted output instead of\
    ps (PostScript) files. The rest of this help is restricted to\
    abc2ps.\n\n\
    Some of the new abc files, in particular the multivoiced files, may be \
    too large for abcm2ps in its standard settings. Since abc2ps must store the \
    entire score in memory, enough dynamic memory needs to be \
    allocated for all the voices and symbols. Abcm2ps normally returns a \
    message (which you can view when you press the 'console' button) when it \
    runs out of space. You can increase the amount of dynamic memory \
    allocated using the entry boxes provided.\n\n"

set hlp_yaps "Yaps Property Sheet\n\n
The page sizes, correspond to the choices available in \
        gsview (ghostview). For multivoice abc tunes, you can choose between \
        combining the voices on an array of staves or displaying each voice \
        separately."

set hlp_otherps "Other abc to postscript converters\n\n
There are too many postscript converters for me to support and\
        furthermore new options are introduced every now and then.\
        Fortunately most of the converters are clones of abc2ps and adopt\
        similar parameter conventions.\
        To handle other converters, you need to specify a path to\
        the executable in the top entry  box and the list of options\
        used by the converter. The program no longer uses the xsel variable\
        to pass the selected tunes. Instead all the selected tunes are\
        copied to a file X.tmp in the tmp subdirectory and the entire file\
        X.tmp is processed.\
        Runabc expects the output postscript file to be called Out.ps.\
        Thus if you are using John Chamber's jcabc2ps, the minimal\
        option list would look like:\n
> Out.ps\n
For other converters the output file is specified using the\
        -o parameter. Thus the minimal option list would be\n
-o Out.ps\n\n
If things do not work out the first time, look at the console\
        output to see what is going wrong.\
        I have not tried this out on all converters, so if you are\
        having a problem, send me an e-mail and I will see what I can do."



set hlp_midi1 "Midi transpose/tuning\n\n\
        You can transpose the music up or down by a specific\
        number of semitones.  This is applied to all MIDI channels.\n\
        Normally the music is tuned to A = 440. You can shift the tuning\
        up or down by almost a semitone.\n\
        You must set the transposition or tuning prior to playing or\
        creating the midi file."

set hlp_midi2 "Midi melody bass/chord controls\n\n\
        Abc2midi will provide bass/chordal accompaniment when guitar\
        chords are indicated in the score. By default the accompaniment\
        is played on a piano and the pattern is determined by the time\
        signature. This page allows you to change these defaults.\
        Furthermore, you can play the melody on two different instruments\
        if the double checkbox is checked. This does not apply for tunes\
        which already define the voices with the V: command.\
        To provide more variety you can also transpose by one\
        or more octaves any of these parts.\n\n\
        There is a separate control page labeled voices on the menu\
        for multivoiced abc files.\n\n
The volume level of the melody is controled by 3 numbers\
        which specify the levels of the notes on the on beat, off beat,\
        or neither. These levels should not exceed 127. It is recommended\
        that you use the slider to adjust all three levels unless you\
        know what you are doing. To turn off the melody, set the volume\
        level to 0.\n\n
If you click the random button, a random set of instruments will\
        be chosen for the melody and accompaniment.\n\n

Gchord and drum accompaniment\n\n\
        Abc2midi chooses the chordal accompaniment based on the meter of the \
        piece. (See %%MIDI ghcord in the abcguide.txt for writing abc files for \
        abc2midi.)\n\nIn some cases a different chordal accompaniment\
        may be preferable. To access the other choices, replace 'default' \
        in the combobox with the desired pattern. The 'f','c' \
        and 'z' indicate bass (fundamental), chords and rest respectively. The\
        number following the letter indicates duration. For common meters,\
        the combobox provides various suggestions. The setting will apply\
        to other tunes having the same numerator in their meter provided\
        you do not restart runabc.\n\n\
        Unlike guitar chords, drum accompaniment is rarely notated in abc\
        tunes.  If you wish to add drum accompaniment, change 'none'\
        to 'default' or one of the choices in the combobox.\
        The program will remember this setting for other tunes having\
        the same numerator in the time signature. The drum assignments\
        is already built in; however, you have finer control using the\
        the drum editor accessible by clicking the 'drumkit' button.\n\n\
        Alternatively you edit the command directly in the combobox\
        entry box, assuming you know what you are doing. The d's indicate\
        a drum hit and the number is the duration. z's are rests. For\
	example for 6/8 time d2dddd what imply a quarter note followed\
        by 4 eigth notes. The pattern d2dddd must be followed by numbers\
	indicating the drum number for each of the d's (here 5). The\
        numbers must be between 35 and 81 inclusive. Following these\
        numbers are another set of numbers indicating the velocities\
        of these hits (d's). (The second set is optional.)\
        The velocities range between 0 and 127.n\n\.

Midi drone control\n\n\
        This setting applies only to bagpipe music which has an Hp key signature.\
        A drone in the keys of A,, and A,,, are played for music in the key signature\
        HP or Hp. You may specify the loudness (velocity) of the two drones.\
        For your information both HP and Hp imply the A major scale where\
        F and C are sharp and G is natural. By convention, if HP is\
        indicated no key signature is indicated in the score. It is indicated\
        for Hp."

set hlp_playopt " Play Options\n\n\
        There is context help for most of the options in this menu with some\
	exceptions.\n\n\
        use midi header: if checked all the midi commands beginning with %%MIDI\
        occurring in the beginning of the abc file (before the first X:)\
        will be inserted in the selected tune before it is played.\n\n\
	random voice arrangement: will assign random midi programs to the\
	voices in the voices frame exposed with the above menu item.
	"


set hlp_midi4 " Advanced settings\n\n\
        If you have specified an alternate midi player in the configuration \
        property page, you can select the desired midi player to use here.\n\n\
        These changes take effect, the next time the play button is clicked.\n\n\
        The parameter beat divider determines which notes are \
        strong. If the time signature is x/y then each note is given a position \
        0,1,2,..x-1. If k is a multiple of n, then the note is strong.\n\n\Gracedivider\
        sets the length of the note to be used as a grace. The length is obtained\
        by dividing the unit length set by the L: field by the given factor. \
        For example for L:1/8, a factor of 4 would make all grace notes 32nd\
        notes. The time used by the grace notes are stolen from the following\
        note. If the following note is not long enough, no grace notes are\
        played.\n\n\
        Broken rhythm ratio adjusts the times for > and < indications \
        in the music body (eg. B > c). The default is 2 to 1, meaning the notes \
        are played as B4/3 c2/3 even though it is printed as B3/2 c1/2. If you want \
        it to be played as written then you should set the ratio to 3 to 1.\n\n\
        Drummaps are used when a separate drum voice is created. If less than 10\
        drum instruments are used, using drummaps produces a cleaner music score.\n\n\
	Fermata notes can cause a problem in multivoiced files. The duration of these\
	notes are extended and lengthen the measure in which they are embedded. This\
	could cause a loss of synchronization between the voices if fermatas are\
	not applied equally in all voices. If this is a problem, you can check the\
	box ignore fermatas. Similarly, you have the option to suppress including\
        grace notes.\n\n\
        The number of warnings and error messages returned by abc2midi can be\
        reduced by ticking the checkboxes fewer messages and no messages.\n\n 
The default button resets all these values to their initial settings."







set hlp_voice "Voice / MIDI Property Sheet\n\n
The widgets on this sheet provide a means of controlling the\
        way abc2midi handles multivoiced abc tunes.  If the tune\
        already assigns MIDI instruments to the voices\
        in a syntax that abc2midi understands then any changes\
        that you make here are disregarded unless you had ticked the\
        check box 'override all midi indications' in the abc2midi\
        option/ tempo/pitch page. Otherwise, you can set your own\
        assignments, without actually modifying the file.\
        In addition you can change the volume level and panning\
        using the two scale widgets associated with the voice.\n\n\
        The level scale provides an additional method of adjusting the\
        volume level for a particular voice. This can be useful because\
        the audio level for a particular instrument also depends on the\
        MIDI synthesizer and the patches it uses. In some cases you may\
        wish to turn off one of the voices so you can concentrate on the\
        remaining lines of music.\n\n\
        The pan scale controls the mapping to the left or right speaker.\
        For some music this helps you to separate the different voices."


set hlp_abc2abc "Abc2abc Property Sheet\n\n\
        Check the desired options and click the abc2abc button. The \
        program will copy the selected files in the Table of Contents page (TOC) \
        to the X.tmp file and will run abc2abc on this file. Depending on the\
        radio button settings, the results will either be placed on a \
        clipboard or recorded on the abc_default_file (e.g. edit.abc) which\
        is automatically opened by an edit window. If you make the latter\
        choice, the contents of the abc_default_file will automatically be\
        overwritten each time you click the abc2abc button. If you use\
        clipboard instead, then open a blank abc file (using edit/new file)\
        and paste the contents of the clipboard using <cntl-v> on Windows\
        operating system or <cntl-y> on Unix and Linux systems.\n\n\
        The new spacing option, may introduce spaces between the notes in the \
        abc file in order for the notes to line up on beats.\n\n\
	If you tick the \
        transpose box, you need to indicate the number of semitones to shift in \
        the adjoining entry box. Positive and negative numbers are accepted by \
        abc2abc. Note that if you have forgotten to tick the transpose box, \
        this action will not be taken. Similarly for the linebreaks box. \n\n
Checking the `force key to' box will produce a tune with the specified\
        key signature. The music will not be transposed but accidentals will be\
        added to override the specified key signature. Specifying a key\
        signature `none' is equivalent to the C key key signature and all\
        accidentals will be shown explicitly. You have a choice of using sharps\
        or flats.  The transpose function also works with K:none.\n\n\
	The force clef option merely saves you the trouble of editing\
       	the K: command with the statement clef=treble or something similar.\
	It only works when you are also transposing the music and it\
	does not support multivoiced files.\n\n\
        For multivoiced music, you can apply one of these functions to a\
        specific voice leaving the other voices intact. Check the button\
        'apply to only voice' and indicate the voice number. Note for\
        transpose to work correctly, the selected voice requires its own K:\
        field so that it will be modified.\n\n\
        See the readme.txt file in the abcMIDI.zip distribution for any additional\
        documentations."

set hlp_extr "Extract and Transpose Part from Score\n\n\
        A score typically consists of many voices often interleaved every few\
        bars. The functions in this page allow you to extract a single voice from\
        a tune and transpose it using abc2abc. It is generally necessary to clean up\
        the results to print a part for an individual musician. For example, the\
        score usually explicitly lists every bar of rests for an individual voice.\
        Musicians, prefer to have it indicated with a multibar rest. This is\
        performed by the condense function implemented in this program. The condense\
        function is not very smart, so it expects a single bar of rest to be\
        indicated by zn where n is exactly the number of time units (eg. eigth notes\
        if L: 1/8) for that bar and time signature. For example if L: 1/8 and\
        M: 4/4 a whole bar rest is z8.\n\n\
        Abc music notation is not completely standardized with regard to the\
        representation of multibar rests. Abc2ps expects it to be in the format,\
        \"n\"zm where n denotes the number of bars and zm denotes the whole bar rest.\
        Abcm2ps expects it to be in the format Zn where n is the number of bars.\
        Yaps and others programs in the abcMIDI package accept both formats.\n\n\
        Like the edit/abc2abc function, the part is automatically written to the\
        default abc output file, typically edit.abc. The display button produces a\
        postscript file from this file and calls the postscript viewer. \
        The save file button, will allow you to rename the output file to something else.\
        The \"To editor\" button, will automatically show the resulting abc file using\
        TclAbcEditor.\n\n\
        Thanks to Luis Pablo Gasparotto for the suggestion and initial implementation."

set hlp_multirests "Multirest tool functions\n\n\
        There are two conventions for representing multiple bars of rests\
        in abc notation. If you are using abc2ps then you need to use the older notation\
        (e.g. \"4\"z8 which means 4 bars of rests where each bar is 8 L: units). If you\
        are using abcm2ps then you should use the Zn notation (eg. Z4 indicates 4 bars\
        of rests). The functions in this sub-menu allow you to convert from one convention\
        to another. Like many other tools in this editor, the function only acts on the\
        region that you have highlighted. If you are converting to the older notation,\
        then the function determines the whole rest size by searching for previous L: and M:\
        indications.\n\n\
        Two other tools are available for condensing a sequence of whole rest bars. You\
        can also do the same thing in the edit/extract part menu page but sometimes things\
        do not work out automatically and you may need more control."

set hlp_midisave "This tool makes it easier to create multiple midi files\
        from a selection in the TOC. The midi files are created and placed in\
        a separate directory that you choose. You have a choice of two ways\
        of naming the new midi files. Either the name is generated from the title\
        of the tune or else it is generated from the xref number. If the name\
        is generated from the title of the tune, you should specify the maximum\
        number of characters that can be used (by default it  is 8). If the\
        name is generated from the xref number, then you should specify the\
        root name. By default the root name is derived from the current open\
        abc file. For example, if the root name is jigs and you selected tunes\
        1 to 2, then the midi files would be named jigs1.mid, jigs2.mid. Pressing\
        the continue button, will start the operation. Pressing cancel will close\
        this property sheet."

set hlp_drumkit "Drumkit Configuration\n\n\
        This window is used to specify the %%MIDI drum sequence to be\
        inserted into the abc file. The function integrates with other\
        tools such as the 'Play Options/Arrangement' and 'gchords/drums\
        to voice.  A pallette of several drums is given\
        by an array of buttons at the bottom of the window. These buttons\
        allow you to add drum assignments to the %MIDI drum command, or\
        to change the assignments. Furthermore, you can change the\
        the intensity of the drum hit. The General MIDI specification\
        provides 46 percussion instruments, however, only a small\
        selection appears in the pallette below. You can change this\
        selection by clicking the 'drum selector' button.\n\n\
        A drum command consists of a pattern such as dzd2dd followed\
        by a sequence of numbers which specify the percussion instruments.\
        If you only enter the pattern and press the 'enter' button,\
        then you can add the percussion instruments corresponding to\
        each 'd' by clicking the pallette buttons until all d's are assigned.\
        A row of d buttons should now appear after the\
        'deselect' button. You can view the assignment\
        by hovering the mouse cursor over any one of these d's.\n\n\
        The d buttons can be selected on or off by clicking on one of them.\
        All the selected d buttons can be turned off by clicking the\
        'deselect' button. Assignments of all the selected d's can be\
        changed by clicking one of the pallette buttons.\n\n\
        If you wish to change the intensity of the hits (strong,\
        medium, and weak), you must ensure that provisional levels\
        have been added to the drum string. This is a series of numbers\
        less than 127 following the assignments. If they have not been\
        included, you can click the 'enter' button again and a bunch of\
        90's should be appended. Clicking the buttons labeled 'strong',\
        'medium', and 'weak' will change these levels and the d buttons\
        will be colored appropriately."


set hlp_drumtool "Drum Tool\n\n\
        The tool is used to edit a percussion voice \
        included in an abc tune. The tool allows you to create up to 8\
        drum patterns which is stored in the slots D0, D1, D2, and etc.\
        Each pattern represents a musical measure or bar.\
        These patterns can be imported into the TclMultiVoiceEditor where\
        they can be used to replace existing bars in the drum voice of\
        te abc file.\
        The drum pattern is specified graphically using a rectangular array\
        of squares. Each row represents a particular drum instrument and\
        each column represents a specific time unit in the bar. Clicking\
        any one of the squares in the array will flip its state from off to\
        on or vice-versa. The abc representation corresponding to the graphic\
        representation is given in the abc bar entry box.\
        (It is assumed you have some understanding on how abc represents\
        the percussion voice.) Once you have decided on the pattern, pressing,\
        the 'new' button will store the pattern in one of the available D\
        slots.\n\n\
        Prior to specifying the patterns you should press the  configure\
        button in order to specify the meter, rhythm structure, unit length\
        and other essential parameters. If you change your mind in the middle,\
        it invalidates all your previous work stored in the D buttons.\
        Please read the configure help file before for more details.\n\n\
        Each row of rectangles is labeled with the name of a percussion\
        instrument. If you click on the name of the\
        instrument, you should be able to preview its sound. You can change\
        the selection of percussion instruments (adding or subtracting) by\
        going to the selector menu button however you should do this before\
        recording any of the patterns in the D buttons.\n\n\
        Pressing the 'clear everything' button starts you at the beginning.\
        All the D buttons are wiped clean including the rectangular array\
        of squares. Since there is nothing stored in the D buttons, they\
        are all disabled. Clicking the 'new' button will enable the next\
        available button and store the drum pattern in that slot corresponding\
        to the graphical representation. It is possible to go back and\
        change the pattern in one of the slots.  Merely, press the\
        corresponding button and that pattern will be loaded in both the\
        abc bar entry box and the rectangular array.\n\n\
        The 'save' button will save your work in a file that you designate\
        in the configure menu. By default, the file name is drumpatterns.drum\
        which is a regular text file. The next time you start up the drumtool,\
        this information will be loaded automatically.\n\n\
        More documentation is on the web (http:\\\\ifdo.ca\\~seymour\\runabc\\top.html)."

set hlp_drumtool_cfg "DrumTool Configuration\n\n\
        Configuration information and the specified drum patterns are stored\
        in a user selected file which by convention should have a drum\
        extension. By default the file is given the name drumpatterns.drum.\
        The configuration file is automatically loaded each time the\
        drumtool Window is created assuming that this file exists. You can\
        update this file by clicking\
        the 'save' button in the drumtool window.\n\n\
        To allow you to handle more than one configuration file, you may\
        specify the name of the configuration file in the entry box.\n\n\
        The M: and L: entry boxes specify the meter and unit length to\
        be used in the abc representation of the drum patterns.\n\n\
        The beat entry box specifies how the beats are divided\
        into subbeats in the rectangular array of rectangles in the drumtool\
        window. The total number of columns in this array should be\
        either n, 2*n, 4*n, or 8*n where the meter is specified as n/m.\
        The configuration of the vertical columns mainly has impact\
        on how the notes are grouped in the bar. The groupings are mainly\
        a convenience for visualizing the drum patterns. The program does not\
        handle triplets, so factors of 3 and other primes should be avoided.\
        For example, if M:3/4, it may be convenient us a beat 2 2 2. Also\
        choosing L:1/8 would produce a more compact abc representation.\
        For complex meters such as M:7/8, you may choose the beat to be\
        3 2 2 or 2 2 3.\n\n\
        The beatstring specifies where the accents should be placed for\
        each of the subbeats. f stands for forte, m stands for mezzo, and\
        p for piano. The velocities associated for each of these indications\
        are specified in the entry boxes below.\n\n\
        The tempo scale only applies to the 'play', 'to abc file' buttons\
        as well as the preview function when you right click on one of the\
        pattern codes p0, p1, etc in the drumtool window.\n\n\
        Clicking any of the enter buttons will activate the change\
        in the entry box and cause the program to check that the values\
        in the entry box are self-consistent. If a discrepancy is detected\
        it will be reported at the bottom of the configuration window.
"


set hlp_g2v "Gchords/Drums to Voice\n\n\
        This function expands the guitar chords and drum strings into separate\
        voices. The output abc file should sound like the input file. Thus if\
        no gchord string is present in the tune it will use the default string for\
        the current key signature or the gchord string specified in the\
        Play Options/gchord&drums toolbox. If the drum output button is not\
        checked and there is no %%MIDI drum command in the input tune,\
        then there will not be any drum output. Similarly, the input file\
        should have guitar chord indications (in double quotes).\n\n\
        Assuming that output to editor is selected, the new tune is\
        displayed in the TclAbcEdit window and is stored in the\
        default file edit.abc.  The program is not as robust as\
        abc2midi so that it may be necessary to edit the output in some cases.\
        Like abc2midi, the gchord string determines how the guitar chords\
        are expressed. The gchord string may be indicated in the abc notated\
        tune using the %%MIDI gchord command. If it is not indicated, then\
        both abc2midi and this program uses the default gchord string based\
        on the time signature, assuming it is a common signature.\n\n\
        You may change the default gchord string for that time signature\
        by entering it in the entry box. The new string will remain the\
        default until you exit the program. Legal codes are\
        z,c,f,b,g,h,i,j,G,H,I,and J. (See abcguide.txt in the\
        doc folder.) Note to use J or j, the guitar chord\
        must be a 7th. In order to be able to express the\
        gchord into notes, the length of the gchord string should divide\
        evenly into the time signature so that each unit can be expressed\
        by a note. For example: for 3/4 time, the strings zfc, zfzczc are\
        fine but zf2c2 would not work since the gchord string is 5 units\
        long which could not be split up into 3 beats.\n\n\
        Important messages are shown at the bottom of the window; however,\
        more detailed messages are put in the internals/messages window.\n\n\
        If output to clipboard is selected, then just the gchord voice\
        is placed in the clipboard. You can now paste the contents\
        of the clipboard into any file. This method is more flexible, since\
        you can expand the abc tune with different gchord accompaniment\
        tracks. However, this method requires more editing. You need\
        to insert V: commands in the right places. If the input file\
        was multipart, then you need to move the different parts into\
        the right places. Furthermore, you need to look at the console\
        window for any warnings and errors.

If the tune contains a %%MIDI drum command the program can also\
        expand the drum pattern into a sequence of notes that form a bar\
        which is repeated in a separate voice. Like the gchord sequence,\
        the drum pattern should fit evenly in the bar. If no %%MIDI drum\
        pattern is given but drum output is selected in the Play options\
        /gchord&drums page, then the program would create the drum voice\
        using the default %%MIDI drum command appropriate for the time\
        signature of the piece. Alternatively, you can specify your own\
        drum pattern by clicking going to the drumkit window. Or you can\
        just enter the %%MIDI drum command in the entry box provided\
        in the ghcords/drums to voice window.

For most single voiced abc tunes, the input voice name or number\
        should be the numeral 1. If the abc tune contains more than one voice\
        then you should choose the voice which has embedded guitar chords.\
        "



# Help
proc contexthelp {} {
    global active_sheet cfg_subsection midi_subsection
    global hlp_overview hlp_config_1 hlp_config_2
    global hlp_config_3 hlp_config_4  hlp_ps
    global hlp_midi1 hlp_midi2 hlp_midi3 hlp_midi4
    global hlp_midi5
    global hlp_voice
    global hlp_yaps hlp_abc2abc hlp_midi2abc
    global hlp_extr
    global hlp_otherps
    global hlp_incipits
    global hlp_g2v
    global hlp_reformat
    global hlp_abc2svg
    

    switch -- $active_sheet {
        none   {show_message_page $hlp_overview word}
        titles {show_message_page $hlp_overview word}
        config {switch -- $cfg_subsection {
                1 {show_message_page $hlp_config_1 word}
                2 {show_message_page $hlp_config_2 word}
                3 {show_message_page $hlp_config_2 word}
                4 {show_message_page $hlp_config_3 word}
		6 {show_message_page $hlp_config_4 word}
            }
        }
        m2psbool {show_message_page $hlp_ps word}
        m2psfloat {show_message_page $hlp_ps word}
        yaps   {show_message_page $hlp_yaps word}
        midi   {switch -- $midi_subsection {
                1 {show_message_page $hlp_midi1 word}
                2 {show_message_page $hlp_midi2 word}
                8 {show_message_page $hlp_midi4 word}
                10 {show_message_page $hlp_midi5 word}
                default {puts $midi_subsection}
            }
        }
        voice  {show_message_page $hlp_voice word}
        abc2abc {show_message_page $hlp_abc2abc word}
        midi2abc {show_message_page $hlp_midi2abc word}
        extract {show_message_page $hlp_extr word}
        otherps {show_message_page $hlp_otherps word}
        incipits {show_message_page $hlp_incipits word}
        g2v {show_message_page $hlp_g2v word}
        reformat {show_message_page $hlp_reformat word}
	abc2svg {show_message_page $hlp_abc2svg word}
    }
}

# Part 14.0           Drum Editor


set drumpatches {
    {35	B,,,	{Acoustic Bass Drum}}
    {36	C,,	{Bass Drum 1}}
    {37	^C,,	{Side Stick}}
    {38	D,,	{Acoustic Snare}}
    {39	^D,,	{Hand Clap}}
    {40	E,,	{Electric Snare}}
    {41	F,,	{Low Floor Tom}}
    {42	^F,,	{Closed Hi Hat}}
    {43	G,,	{High Floor Tom}}
    {44	^G,,	{Pedal Hi-Hat}}
    {45	A,,	{Low Tom}}
    {46	^A,,	{Open Hi-Hat}}
    {47	B,,	{Low-Mid Tom}}
    {48	C,	{Hi Mid Tom}}
    {49	^C,	{Crash Cymbal 1}}
    {50	D,	{High Tom}}
    {51	^D,	{Ride Cymbal 1}}
    {52	E,	{Chinese Cymbal}}
    {53	F,	{Ride Bell}}
    {54	^F,	Tambourine}
    {55	G,	{Splash Cymbal}}
    {56	^G,	Cowbell}
    {57	A,	{Crash Cymbal 2}}
    {58	^A,	Vibraslap}
    {59	B,	{Ride Cymbal 2}}
    {60	C	{Hi Bongo}}
    {61	^C	{Low Bongo}}
    {62	D	{Mute Hi Conga}}
    {63	^D	{Open Hi Conga}}
    {64 	E	{Low Conga}}
    {65 	F	{High Timbale}}
    {66	^F	{Low Timbale}}
    {67	G	{High Agogo}}
    {68	^G	{Low Agogo}}
    {69	A	Cabasa}
    {70	^A	Maracas}
    {71	B	{Short Whistle}}
    {72	c	{Long Whistle}}
    {73	^c	{Short Guiro}}
    {74	d	{Long Guiro}}
    {75	^d	{Claves}}
    {76	e	{Hi Wood Block}}
    {77	f	{Low Wood Block}}
    {78	^f	{Mute Cuica}}
    {79	g	{Open Cuica}}
    {80	^g	{Mute Triangle}}
    {81	a	{Open Triangle}}
}


# needed for proc drum_bar_to_drumhits
foreach patch $drumpatches {
    set midino [lindex $patch 0]
    set notename [lindex $patch 1]
    set revpatch($notename) $midino
}




proc drum_editor {} {
    global midi df
    global drumpatches
    global drumpat
    global drumentry
    if {[winfo exists .drumkit] == 1} {focus .drumkit; return} else {
        toplevel .drumkit
        position_window ".drumkit"
        
        set w .drumkit.input
        frame $w -borderwidth 2
        entry $w.ent -width 40 -textvariable drumentry -font $df
        button $w.enter -text enter -font $df \
                -command {get_drumentry
                    focus .drumkit}
        pack $w.ent $w.enter -anchor w -side left
        pack $w
        
        set w .drumkit.ctl
        frame $w -borderwidth 2 -relief raised
        button $w.select -text "drum selector" -font $df -command drumkey
        button $w.play -command play_drum_test -text play -font $df
        button $w.paste -command paste_drumstring -text paste -font $df
        button $w.help -text help -font $df\
                -command {show_message_page $hlp_drumkit word}
        
        pack $w.select $w.play $w.paste $w.help -anchor w -side left
        pack $w
        
    }
    

    
    set w .drumkit.pat
    frame $w -borderwidth 2
    pack $w -side top
    
    set w .drumkit.accent
    frame $w -borderwidth 3
    pack $w -side top
    button $w.1 -text strong -font $df -fg red -command "change_drum_vel dstrong"
    button $w.2 -text medium -font $df  -command "change_drum_vel dmedium"
    button $w.3 -text weak -font $df -fg blue -command "change_drum_vel dweak"
    pack $w.1 $w.2 $w.3 -side left
    
    
    
    # create drum patches selector
    frame .drumkit.patches -borderwidth 2 -relief raised
    pack .drumkit.patches -side top
    refresh_drumkit_patches
    
    prepare_drumentry 
    
}

proc refresh_drumkit_patches {} {
    global npatches midi
    global drumpat
    global drumentry
    set npatches 0
    if {[winfo exist .drumkit]} destroy_all_drumkit_patches
    if {[winfo exist .dk]} {set midi(selected_drums) [return_selected_drumsel]}
    foreach patindex $midi(selected_drums) {
        add_selected_drum $patindex
    }
    if {$midi(drummap)} {drum2map $drumentry}
}

proc add_selected_drum {patindex} {
    global drumpatches
    global npatches
    global midi df
    if {[winfo exist .drumkit]} {
        set pat [lindex $drumpatches $patindex]
        set name [lindex $pat 2]
        button .drumkit.patches.$npatches -text $name -font $df\
                -width 20 -command "change_drum_prog $patindex"
        set c [expr $npatches % 2]
        set r [expr $npatches / 2]
        grid .drumkit.patches.$npatches -column $c -row $r
        incr npatches
    }
}


proc destroy_all_drumkit_patches {} {
    foreach w [winfo children .drumkit.patches] {
        destroy $w
    }
}

proc number_of_numbers {s} {
  set k 0
  #puts $s
  foreach a $s {
   if {[string is integer $a]} {incr k}
   }
  return $k
  }

proc change_drum_prog {j} {
    global drumpatches w drumprog
    # global drumproglist drumpat
    global drumentry

#   add more drum assignments if missing
    set drumlist [parse_drum_string $drumentry]
    set numberofdees [lindex $drumlist 0]
    set n [number_of_numbers $drumentry]
    if {$n < $numberofdees} {
        set index [lindex [lindex $drumpatches $j] 0]
        append drumentry " $index"
        return
       }

    set selection [make_list_of_dndex_on]
    set selected_drums [lindex $selection 0]
    set positions [lindex $selection 1]
    foreach drumindex $selected_drums pos $positions {
        set pat [lindex $drumpatches $j]
        set name [lindex $pat 2]
        set cmd "tooltip::tooltip .drumkit.pat.$drumindex [list $name]"
        set drumprog($drumindex) [expr $j+35]
        set p  [expr $pos + 1]
        set drumentry [lreplace $drumentry $p $p [expr $j +35]]
        eval $cmd
    }
}

proc change_drum_vel {vel} {
    global drumvel drumindex drumlist drumentry
    global midi
    set selection [make_list_of_dndex_on]
    set selected_drums [lindex $selection 0]
    set positions [lindex $selection 1]
    foreach drumindex $selected_drums pos $positions {
        set drumvel($drumindex) $vel
        switch $vel {
            dstrong {.drumkit.pat.$drumindex configure -fg red}
            dmedium {.drumkit.pat.$drumindex configure -fg black}
            dweak {.drumkit.pat.$drumindex configure -fg blue}
        }
        #puts "change_drum_vel $drumproglist"
        set l [llength $drumentry)]
        set p [expr 1+$pos +($l-1)/2]
        set drumentry [lreplace $drumentry $p $p $midi($vel)]
    }
}


proc drumkey {} {
    #produces a selector for the desired drum patches
    global drumpatches drumsel df
    if {[winfo exist .dk] != 1} {toplevel .dk
        position_window ".dk"
        set j 0
        load_drumsel
        foreach d $drumpatches  {
            set name "[lindex $d 0] [lindex $d 2]"
            checkbutton .dk.$j -text $name -variable drumsel($j)\
                    -command {refresh_drumkit_patches
                        setup_drum_grid} -font $df
            set k [expr $j % 3]
            set r [expr $j / 3]
            grid .dk.$j -row $r -column $k -sticky w
            incr j
        }
    }
}


proc clear_drumsel {} {
    global drumsel
    for {set i 0} {$i < 47} {incr i} {
        set drumsel($i) 0
    }
}

proc load_drumsel {} {
    global drumsel midi
    clear_drumsel
    foreach item $midi(selected_drums) {
        set drumsel($item) 1
    }
}

proc return_selected_drumsel {} {
    global midi
    set selected_drums {}
    global drumsel
    for {set i 0} {$i < 47} {incr i} {
        if $drumsel($i) {lappend selected_drums $i}
    }
    set midi(selected_drums) $selected_drums
    return $selected_drums
}


proc get_drumentry {} {
    prepare_drumentry 
}



proc prepare_drumentry {} {
    global midi drumvel drumproglist
    global drumpatches df
    global drumpat drumlist
    global drumprog
    global drumentry   
 
    set splitpat [split $drumentry]
    set drumpat [lindex $splitpat 0]
    set loc [string first "{}" $splitpat]
    if {$loc > 0} {set loc2 [expr $loc+1]
        set splitpat [string replace $splitpat $loc $loc2 ""]
    }
    
    
    set drumproglist [lrange $splitpat 1 end]
    set drumlist [parse_drum_string $drumpat]
    set numberofdees [lindex $drumlist 0]
    set drumlist [lindex $drumlist 1]
 
   
    # create drumprog and drumvel arrays
    set ndrums 0
    foreach elem $drumlist {
        set initialchar [string index $elem 0]
        if {$initialchar != "d"} continue
        if {[llength $drumproglist] > $ndrums} {
            set n [lindex $drumproglist $ndrums]
            set drumprog($ndrums) $n
            set drumvel($ndrums) dmedium
        } elseif {[info exist drumprog($ndrums)]} {
            set n $drumprog($ndrums)
            lappend drumproglist $drumprog($ndrums)
        } else {
            set drumprog($ndrums) [pick_random_drum]
            set drumvel($ndrums) dmedium
            lappend drumproglist $drumprog($ndrums)
        }
        incr ndrums
    }
 
    set n [number_of_numbers $drumentry]
    if {$n == $numberofdees} {
         set drumentry [append_drum_velocities $drumentry]}
    
    set w .drumkit.pat
    foreach w2 [winfo children $w] {
        destroy $w2
    }
    set i 0
    set i1 0
    button $w.desel -text deselect -font $df -command drumkit_deselect_all
    pack $w.desel -side left
    foreach elem $drumlist {
        checkbutton $w.$i -text $elem  -indicatoron 0\
                -variable dndex($i) -font $df
        pack $w.$i -side left
        set initial [string index $elem 0]
        if {$initial != "d"} {incr i; continue}
        set j [expr $drumprog($i1) -35]
        set pat [lindex $drumpatches $j]
        set name [lindex $pat 2]
        set cmd "tooltip::tooltip $w.$i [list $name]"
        eval $cmd
        incr i
        incr i1
    }
}

proc drumkit_deselect_all {} {
    global drumlist
    set i 0
    set w .drumkit.pat
    foreach elem $drumlist  {
        $w.$i deselect
        incr i
    }
}


proc make_list_of_dndex_on {} {
    global drumlist dndex
    set n [llength $drumlist]
    set dlist {}
    set dloc {}
    set dcount 0
    for {set i 0} {$i < $n} {incr i} {
        set elem [lindex $drumlist $i]
        set initial [string index $elem 0]
        if {$initial == "d" && $dndex($i) == 1} {
            lappend dlist $i
            lappend dloc $dcount
        }
        if {$initial == "d"}  {
            incr dcount
        }
    }
    return [list $dlist $dloc]
}



proc make_trial_abc_file {} {
    global drumentry
    global midi
    set outfd [open X.tmp w]
    puts $outfd "X: 1\nT: drum trial\nM: 2/4\nL: 1/8\nK: G"
    puts $outfd "%%MIDI drum $drumentry"
    puts $outfd "%%MIDI drumon"
    puts $outfd "z4|z4|z4|z4|z4|z4|z4|z4\n\n"
    close $outfd
}

proc play_drum_test {} {
    global midi exec_out drumentry
    global files
    make_trial_abc_file
    set cmd "file delete [glob -nocomplain X*.mid]"
    catch {eval $cmd}
    set cmd "exec $midi(path_abc2midi) X.tmp"
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files X1.mid
    update_console_page
    play_midis 1
}

proc paste_drumstring {} {
    global abctxtw midi drumentry
    set drumstring $drumentry
    set point [$abctxtw index insert]
    $abctxtw insert $point  "%%MIDI drum $drumstring\n"
}




set hlp_drums "This drum tool is designed to help you create a \
        drum string which is used by abc2midi. For a good explanation of \
        the drum string, you should refer to the file abcguide.txt \
        that is included with the abcMIDI.zip distribution.\n\n\
        The top  text line window shows the default drum string d2dz2d. \
        To change it, click on the entry box in the line below and enter \
        your desired string. You must complete the string with a \
        carriage return or click the enter button. \
        \n\nThere are two scrolled listboxes that are used to map the \
        individual drum hits (eg d2) to particular drum patches. The left \
        box shows the current mapping for each drum hit. \
        To change, the mapping select a particular drum \
        hit in the left listbox and then click on a desired patch \
        shown in the right list box. The mapping should change immediately. \
        The beige label immediately above the list box shows the \
        last selected patch. Whenever you click the enter button, all the drum \
        hits will be changed to that patch. \n\nThe play button will allow \
        you to listen to the particular drumstring. It will create and play \
        a midi file with 8 bars of this drumstring. The paste button will \
        paste the drumstring in your file being edited in the abcedit window. \
        The %%MIDI drum command will be pasted at the position of the insert \
        cursor. (Don't forget to insert the %%MIDI drumon command in the\
        body of the music.)"
#end of drumedit.tcl



# Part 15.0           Title Search functions


startup_progress "loading search functions"




#source abcsearch.tcl

# abcsearch.tcl
# The program searches for all abc tunes whose
# title contains a specific string.
# The search is started from the given directory
# and all abc files found in this directory or
# subdirectories are scanned.
#
#

proc find_window {} {
    set p .abcsearch
    global df midi
    if {[winfo exist $p]} return
    toplevel $p
    position_window ".abcsearch"
    frame $p.1
    frame $p.2
    label $p.lab -width 30 -text "" -font $df
    label $p.1.dirlab -text "top directory" -font $df
    entry $p.1.dirbox -width 30 -textvariable midi(searchdir) -font $df
    bind $p.1.dirbox <Return> {focus .abcsearch.1.dirlab}
    menubutton $p.1.menubut -text "browse" -font $df -menu $p.1.menubut.type
    menu $p.1.menubut.type -tearoff 0
    $p.1.menubut.type add command -label "for file"  -command match_file_browser -font $df
    $p.1.menubut.type add command -label "for folder"  -command match_dir_browser -font $df
    label $p.2.strlab -text "search string" -font $df
    entry $p.2.strbox -width 30 -textvariable searchstring -font $df
    bind $p.2.strbox <Return> {focus .abcsearch.1.dirlab
        title_match}
    button $p.2.but -text search -command title_match -font $df
    button $p.2.help -text help -font $df
    listbox $p.list -width 50 -bg #f4ece0 \
            -yscrollcommand {.abcsearch.ysbar set} \
            -xscrollcommand {.abcsearch.xsbar set} \
            -font $df -exportselection false
    scrollbar $p.ysbar -orient vertical -command {.abcsearch.list yview}
    scrollbar $p.xsbar -orient horizontal -command {.abcsearch.list xview}
    
    
    pack $p.1.dirlab $p.1.dirbox $p.1.menubut -side left
    pack $p.2.strlab $p.2.strbox $p.2.but $p.2.help -side left
    pack $p.1
    pack $p.2
    pack $p.ysbar -side right   -fill y -in $p
    pack $p.xsbar -side bottom  -fill x -in $p
    pack $p.list -fill both -expand y -in $p
    
    bind .abcsearch.list <Button> {show_file [.abcsearch.list nearest %y]}
    bind .abcsearch.2.help <Button> {show_message_page $hlp_find word
        focus .abc
        raise .abc .abcsearch}
    
}

set hlp_find "This tool is used for searching for tunes whose title\
        contains a specific string (eg. word or sequence of words). The search\
        is performed on all abc files contained in a specific directory including\
        all its subdirectories. This tool is useful if you have a large collection\
        of abc files some of which are compilations of many tunes. Before using\
        tool you should enter the path to this directory in the top entry box.\
        You may use the browser button on the left for finding the directory.\
        This directory will be stored in the runabc.ini file, so you will not\
        have to type it in each time you run this tool. Next enter a specific\
        string that you think is in the title. The program does not distinguish\
        upper and lower case letters. Avoid punctuation marks and other special\
        symbols as this string is actually interpreted as a regular Tcl expression\
        using the regexp function. You can actually specify fairly complex\
        patterns in the title if you know about the regexp function. For\
        example: \n\mary | john 	will return any title containing either\
        the word mary or john.\n\
        (CT \[0-9\]+)	will return any title containing something like (CT 140).\n\
        fairies$		will return any title ending with fairies.\n\
        ^some		will return any title starting with the string some.\n\n\
        After you enter a carriage return or click the search button, the\
        program will cd to this directory and locate all abc files using a\
        recursive glob.  For each file with an abc extension, the title line\
        of every tune will be scanned for the specified string. Whenever a\
        match is found, the title and source will be added to the listbox below.\
        If you feel you have enough matches, you can stop the search by clicking\
        on the stop button.\n\n\ All the identified titles in the listbox are\
        mouse sensitive. If you click on one of the titles, the selected file\
        will be automatically opened, the table of contents of that file will\
        appear and the listbox will automatically scroll so that the selected\
        tune will be visible.  Note that some tunes may have more\
        than one title. The match is done on all titles, but only the first\
        title appears in the table of contents. If it selects a title past the\
        one you wanted, it probably indicates that some tunes are missing a T:\
        field in the abc file. Correct the abc file so you do not miss some tunes."



# This function lists the X: index number, titles and key signature
# of every tune found in the specified abcfile. The function expects
# every tune to begin with an X: index specifier and the title to
# found in the T: field command. More than one title may belong to
# a specific tune.

# Method: search for an X: field and then all the associated T:
# fields. When a K: field is encountered, grab the key signature
# and output all the title, key information to the open output file
# referenced by the outhandle variable;  ignore everything else
# that follows until the next X: field is found. Stop when an
# eof is encountered.


proc search_string_in_title {abcfile filenum} {
    global searchstring
    global listbox_line
    global file_index locator
    global stopsearch
    set srch X
    set titlehandle [open $abcfile r]
    set loc 0
    while {[gets $titlehandle line] >= 0 && $stopsearch == 0} {
        if {[string length $line] < 1} {set srch X}
        set initialchar [string index $line 0]
        switch -- $srch {
            X {
                if { $initialchar == "X"} {
                    set number [string range $line 2 10]
                    set srch T
                    incr loc
                }
            }
            T {
                set name [string range $line 2 end]
                set name [string trim $name]
                if {[regexp -nocase  $searchstring $name] > 0} {
                     set match   [format "%s %s   %s" $number $name $abcfile]
                     .abcsearch.list insert end $match
                     update
                     set file_index($listbox_line) $filenum
                     set locator($listbox_line) $loc
                     .abcsearch.list see $listbox_line
                     incr listbox_line
                    } 
                }
             K  { set srch X
                }
            }
        }
    close $titlehandle
}


proc show_file {loc} {
    global midi
    global file_index gfiles locator
    global item_id
    if {$loc < 0} return
    set xrefno [lindex [.abcsearch.list get $loc] 0]
    
    .abc.titles.t selection set {}
    open_abc_file $midi(searchdir)/$gfiles($file_index($loc))
    if {$midi(index_by_position)} {
       set toc_index $item_id($locator($loc))
       } else {
       set toc_index $item_id($xrefno)
       }
    .abc.titles.t selection set $toc_index
    .abc.titles.t focus $toc_index
    .abc.titles.t see $toc_index
    update
}


#
#---------------------------------------------------------------------------
#  rglob, Performs a recursive glob
#
#  Copyright (C) 2000 Agnar Renolen
#     email: agnar@organizer.net
#
#  This module is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  .................
#---------------------------------------------------------------------------

##
#   rglob - recursive glob
#
# SYNOPSIS
#   [rglob <pattern>]
#
# DESCRIPTION
#   Executes a recursive /glob/ returning a list of all files matching
#   a <pattern>.  If the search is to be started in a particular
#   directory, this is obtained by prefixing the <pattern> with the
#   directory name as e.g., [rglob "c:/develop/tclproject/*.tcl"].
#
#   The globbing is executed using the [-nocomplain] option, so if
#   [rglob] finds no matches, an empty list is returned.
##

proc rglob {pattern} {
    set fileList {}
    foreach fname [glob -nocomplain $pattern] {
        if {![file isdirectory $fname]} {
            lappend fileList $fname
        }
    }
    foreach fname [glob -nocomplain -types d "[file dirname $pattern]/*"] {
        set fileList [concat $fileList [rglob "$fname/[file tail $pattern]"]]
    }
    return $fileList
}


proc title_match {} {
    global midi
    global gfiles
    global file_index
    global listbox_line
    global locator
    global stopsearch
    global searchstring
    if {[string length $searchstring] < 1} return
    set home [pwd]
    cd $midi(searchdir)
    pack .abcsearch.lab
    .abcsearch.2.but configure -text stop -command stopsearching
    .abc.functions.play  configure -state disabled
    .abc.functions.disp  configure -state disabled
    .abcsearch.list delete 0 end
    set file_list [rglob *.abc]
    set i 0
    set listbox_line 0
    if {[info exist file_index]} {unset file_index}
    if {[info exist locator]} {unset locator}
    set stopsearch 0
    foreach filename $file_list {
        if {$stopsearch} break;
        set gfiles($i) $filename
        .abcsearch.lab configure -text $filename
        update
        search_string_in_title $filename $i
        incr i
    }
    cd $home
    stopsearching
}

proc stopsearching {} {
    global stopsearch
    set stopsearch 1
    .abcsearch.2.but configure -text search -command title_match
    .abc.functions.play  configure -state normal
    .abc.functions.disp  configure -state normal
}
#end of abcsearch.tcl


proc get_version_number {executable} {
    set cmd "exec [list $executable] -ver"
    catch {eval $cmd} result
    return $result}



# Part 16.0        Abcmatcher interface


#source abcmatch.tcl

proc check_abcmatch_version {version} {
    global midi
    global exec_out
    if {[file exist $midi(path_abcmatch)] != 1} {
        messages "runabc requires the executable abcmatch.exe to run this \
                function. You need to specify the path to this executable using the \
                config/executables menu item."
        return}
    set result [get_version_number $midi(path_abcmatch)]
    set result [split $result]
    set result [lindex $result 0]
    set exec_out $result
    if {$result >= $version} {return 1}
    #version difference of 0.1 implies new version not compatible with runabc
    messages "runabc was expecting abcmatch version $version. Instead it \
            found version $result. Get the latest version of abcmatch from\
	    http:/ifdo.ca/~seymour/runabc/top.html" 
    update_console_page
    return 0
}


proc set_min_matches {value} {
   global midi
   set midi(grouper_thresh) $value
   if {[winfo exist .matcher]} { 
     .matcher.top.3.minlab configure -text $value} 
   if {[winfo exist .grouper]} { 
     .grouper.2.minlab configure -text $value} 
   }

proc save_color_abc {} {
    global types midi
    set filename [tk_getSaveFile -filetypes $types]
    if {$filename != ""} {
        set outhandle [open $filename w]
        if {$midi(ps_creator) == "yaps"} {dump_for_yaps_display
        } else dump_for_abcm2ps_display
	file rename -force X.tmp $filename
        }
    }
  
proc save_html_abc {} {
    global types midi
    set filename [tk_getSaveFile -filetypes $types]
    if {$filename != ""} {
        set outhandle [open $filename w]
        dump_for_html
	file rename -force X.tmp $filename
        }
    }

proc setup_match_window {} {
    global midi df hlp_match_bars tpxrefno 
    set f .matcher.top
    if {![info exist tpxrefno]} {set tpxrefno 1}
    toplevel .matcher
    position_window ".matcher"
    frame $f
    pack $f -side top 
    frame $f.1
    label $f.1.inputfilelab -text "path" -font $df
    entry $f.1.inputfilevar -width 50 -textvariable midi(searchdir) -font $df
    menubutton $f.1.menubut -text "browse" -font $df -menu $f.1.menubut.type
    menu $f.1.menubut.type -tearoff 0
    $f.1.menubut.type add command -label "for file"  -command match_file_browser -font $df
    $f.1.menubut.type add command -label "for folder"  -command match_dir_browser -font $df
    bind $f.1.inputfilevar <Return> {focus .matcher.top}
    
    frame $f.2
    label $f.2.keylab -text K: -font $df
    label $f.2.meterlab -text M: -font $df
    label $f.2.lengthlab -text L: -font $df
    entry $f.2.keyent -width 5 -textvariable midi(match_keysig) -font $df
    bind $f.2.keyent <Return> {focus .matcher.2.keylab}
    entry $f.2.meterent -width 5 -textvariable midi(match_timesig) -font $df
    bind $f.2.meterent <Return> {focus .matcher.2.meterlab}
    entry $f.2.lengthent -width 5 -textvariable midi(match_length) -font $df
    bind $f.2.lengthent <Return> {focus .matcher.2.lengthlab}
    frame $f.body
    label $f.body.bodylab -text template -font $df
    entry $f.body.bodyent -width 60 -textvariable midi(match_body) -font $df \
            -xscrollcommand "$f.scroll set"
    bind $f.body.bodyent <Return> {focus .matcher.body.bodylab
        create_match.abc
        start_matcher}
    pack $f.body.bodylab $f.body.bodyent -side left -anchor w
    scrollbar $f.scroll -relief sunken -orient horiz \
            -command "$f.body.bodyent xview"
    
    frame $f.con
    button $f.con.start -text match -font $df -command {create_match.abc
        start_matcher}
    button $f.con.play -text play -font $df -command play_match.abc
    button $f.con.display -text display -font $df -image print-22 -command display_matches -state disable
    button $f.con.transfer -text transfer -font $df -command transfer_editor_buffer_to_abcmatch
    button $f.con.cfg -text configure -font $df -command configure_match

    menubutton  $f.con.dump -menu $f.con.dump.men -text "save results" -font $df    -image filesave22 -state disable
    menu $f.con.dump.men -tearoff 0
    $f.con.dump.men add command -label "regular save" -command {dump_to_abc 0} -font $df
    $f.con.dump.men add command -label "color save" -command {save_color_abc} -font $df
    $f.con.dump.men add command -label "html save" -command {save_html_abc} -font $df



    button $f.con.help -text help -font $df \
            -command {
                show_message_page $hlp_match_bars word
                focus .abc
                raise .abc}

pack $f.con.start $f.con.play $f.con.transfer $f.con.cfg $f.con.dump $f.con.display $f.con.help\
            -side left -anchor w
    
    pack  $f.2.keylab $f.2.keyent $f.2.meterlab $f.2.meterent $f.2.lengthlab \
            $f.2.lengthent -side left -anchor w
    
    
    
    
    frame $f.3 
    label $f.3.transposition -text "key signature" -font $df
    
    set p $f.3.minmenu.choice
    menubutton $f.3.minmenu -text "minimum matches = " -font $df\
           -relief raised -menu $p
    menu $p -tearoff 0
    $p add command -label 1 -font $df -command "set_min_matches 1"
    $p add command -label 2 -font $df -command "set_min_matches 2"
    $p add command -label 3 -font $df -command "set_min_matches 3"
    $p add command -label 4 -font $df -command "set_min_matches 4"
    $p add command -label 5 -font $df -command "set_min_matches 5"
    $p add command -label 6 -font $df -command "set_min_matches 6"
    $p add command -label 7 -font $df -command "set_min_matches 7"
    $p add command -label 8 -font $df -command "set_min_matches 8"
    label $f.3.minlab -text 1 -font $df

    
    pack  $f.1.inputfilelab  $f.1.inputfilevar $f.1.menubut -side left -anchor w

    frame $f.4
    label $f.4.lab -text template -font $df
    entry $f.4.file -width 42 -font $df -textvariable midi(abc_open)
    label $f.4.xlab -text "ref number" -font $df
    entry $f.4.xref -width 4 -font $df -textvariable tpxrefno
    bind $f.4.xref <Return> {focus .matcher.top.4.lab}
    pack $f.4.lab $f.4.file $f.4.xlab $f.4.xref -side left -anchor w

    
    frame $f.msg
    label $f.msg.lab -width 60 -text "" -font $df
    pack $f.msg.lab -side left
    pack $f.msg -side top
    set_min_matches $midi(grouper_thresh) 
}



proc configure_match {} {
global midi df
global hlp_match_cfg
set f .matchcfg
if {[winfo exist $f]} return
toplevel .matchcfg
position_window ".matchcfg"
set f .matchcfg.res
#set midi(match_mode) 0
frame $f
    label $f.lab -text "accuracy" -font $df
    radiobutton $f.0 -value 0  -text "exact"  -font $df  -variable midi(match_mode)
    radiobutton $f.16th -value 16th -text "1/16 note"  -font $df -variable midi(match_mode)
    radiobutton $f.8th -value 8th -text "1/8 note"  -font $df -variable midi(match_mode)
    radiobutton $f.4th -value 4th -text "1/4 note"  -font $df -variable midi(match_mode)
    radiobutton $f.3rd -value 3rd -text "3/8 note"  -font $df -variable midi(match_mode)
    radiobutton $f.2nd -value 2nd -text "1/2 note"  -font $df -variable midi(match_mode)
    radiobutton $f.1 -value 1 -text "whole note"    -font $df -variable midi(match_mode)
pack $f.lab $f.0 $f.16th $f.8th $f.4th $f.3rd $f.2nd $f.1 -side top -anchor nw


set f .matchcfg.nobar
frame $f
    label $f.lab -text "no bar lines" -font $df
    radiobutton $f.3n -value 3n -text "3 notes" -font $df -variable midi(match_mode)
    radiobutton $f.4n -value 4n -text "4 notes" -font $df -variable midi(match_mode)
    radiobutton $f.5n -value 5n -text "5 notes" -font $df -variable midi(match_mode)
    radiobutton $f.6n -value 6n -text "6 notes" -font $df -variable midi(match_mode)
    radiobutton $f.7n -value 7n -text "7 notes" -font $df -variable midi(match_mode)
    radiobutton $f.8n -value 8n -text "8 notes" -font $df -variable midi(match_mode)
    radiobutton $f.9n -value 9n -text "9 notes" -font $df -variable midi(match_mode)
    radiobutton $f.10n -value 10n -text "10 notes" -font $df -variable midi(match_mode)
pack $f.lab $f.3n $f.4n $f.5n $f.6n $f.7n $f.8n $f.9n $f.10n   -side top -anchor n





set f .matchcfg.sel
frame $f

    checkbutton $f.rhythm -text "no rhythm" -font $df -variable midi(match_norhythm)
    
    radiobutton $f.all -value all -text all -variable midi(match_selection)\
            -font $df 
    radiobutton $f.any -value any -text any -variable midi(match_selection) -value any \
            -font $df 
    

    radiobutton $f.abs -text "absolute"\
            -font $df -variable midi(match_method) -value abs
    radiobutton $f.cnt -text "contour" \
            -font $df -variable midi(match_method) -value con
    radiobutton $f.qcnt -text "quantized contour" \
            -font $df -variable midi(match_method) -value qcon
    button $f.hlp -text help -font $df
    checkbutton $f.lev  -text "levenshtein distance" -font $df -variable midi(levenshtein)


pack $f.rhythm $f.lev $f.all $f.any $f.abs $f.cnt $f.qcnt  $f.hlp -side top -anchor nw
$f.hlp configure -command {
       show_message_page $hlp_match_cfg word
       focus .abc
       raise .abc}

set f .matchcfg
pack $f.res $f.nobar $f.sel -side left -anchor n
}
    

proc match_window {headtype} {
    global hlp_match_bars hlp_match_tune
    set f .matcher.top
    if {![winfo exist .matcher]} {
           if {[check_abcmatch_version 1.67] == 0} return
           setup_match_window}
    foreach w [winfo children $f] {pack forget $w}
    foreach w [winfo children $f.con] {pack forget $w}
    foreach w [winfo children $f.3] {pack forget $w}
    if {$headtype == "tune"} {
          pack $f.4 $f.3 $f.con $f.msg -side top
          pack $f.con.start $f.con.dump $f.con.display $f.con.cfg $f.con.help -side left -anchor w
          pack $f.3.minmenu $f.3.minlab -side left -anchor w
          $f.con.start configure -command grouper_findbars
          $f.con.help configure -command {
                show_message_page $hlp_match_tune word
                focus .abc
                raise .abc}
          $f.con.dump.men entryconfigure 0 -command {dump_to_abc 0}
          #puts [$f.con.dump.men entryconfigure 0]
          return
          } else {
          pack $f.1 $f.2 $f.body $f.3 $f.con $f.msg -side top
          pack $f.con.start $f.con.play $f.con.transfer $f.con.cfg $f.con.dump $f.con.display $f.con.help\
            -side left -anchor w
          $f.con.start configure -command {create_match.abc
                                           start_matcher}
          $f.con.help configure -command {
                show_message_page $hlp_match_bars word
                focus .abc
                raise .abc}
          #puts [$f.con.dump.men entryconfigure 0]
          $f.con.dump.men entryconfigure 0 -command {dump_to_abc 1}
          return
          }
}



proc return_matchmode_parameter {} {
   global midi
   global mfixed
   set mfixed 0
   switch $midi(match_mode) {
        0   {return "-r 0"}
       16th {return "-r 6"}
        8th {return "-r 12"}
        4th {return "-r 24"}
        3rd {return "-r 36"}
        2nd {return "-r 48"}
        1   {return "-r 96"}
        3n  {set mfixed 3
            return "-fixed 3"}
        4n  {set mfixed 4
            return "-fixed 4"}
        5n  {set mfixed 5
            return "-fixed 5"}
        6n  {set mfixed 6
            return "-fixed 6"}
        7n  {set mfixed 7
            return "-fixed 7"}
        8n  {set mfixed 8
            return "-fixed 8"}
        9n  {set mfixed 9
            return "-fixed 9"}
        10n  {set mfixed 10 
            return "-fixed 10"}
     default {return ""}
        }
    }




proc pop_matcher_results {} {
    global df
    set p .matcher.notice
    if [winfo exist .matcher.notice] {
        $p.t configure -state normal
        $p.t delete 1.0 end
    } else {
        frame $p
        text $p.t -height 25 -width 70 -wrap word -yscrollcommand {.matcher.notice.ysbar set} -font $df
        scrollbar $p.ysbar -orient vertical -command {.matcher.notice.t yview}
        pack $p.ysbar -side right -fill y -in $p
        pack $p.t -in $p
        pack $p}
}



proc create_match.abc {} {
    global midi
    set handle [open match.abc w]
    puts $handle  X:1
    puts $handle  T:match_template
    puts $handle  M:$midi(match_timesig)
    puts $handle  L:$midi(match_length)
    puts $handle  K:$midi(match_keysig)
    puts $handle  $midi(match_body)
    close $handle
    set last [string index $midi(match_body) [expr [string length $midi(match_body)] -1]]
    if {[string equal $last |] != 1} {
        messages "body should end with a bar line"}
}

proc start_matcher {} {
    global midi
    global stopsearch
    global match_index
    global exec_out
    set exec_out ""
    if {[file exist $midi(searchdir)] != 1} {
        messages "The file or directory $midi(searchdir) could not be \
                found. Searching was aborted."
        return
    }
    set match_index 0
    set stopsearch 0
    .matcher.top.con.start configure -text stop -command stop_matcher
    .abc.functions.play  configure -state disabled
    .abc.functions.disp  configure -state disabled
    update
    if {[file isdirectory $midi(searchdir)]} run_glob_matcher else run_matcher
}


proc stop_matcher {} {
    global stopsearch
    .matcher.top.con.start configure -text match -command {create_match.abc
        start_matcher}
    .abc.functions.play  configure -state normal
    .abc.functions.disp  configure -state normal
    set stopsearch 1
}

proc run_matcher {} {
    global matchlist
    global midi
    global exec_out
    set exec_out ""
    set cmd "exec [list $midi(path_abcmatch)]  [list $midi(searchdir)]" 
    if {$midi(match_selection) == "any"} {set cmd [concat $cmd -a]}
    if {$midi(match_method) == "con"} {set cmd [concat $cmd -con]}
    if {$midi(match_method) == "qcon"} {set cmd [concat $cmd "-con -qnt"]}
    if {$midi(levenshtein)} {set cmd [concat $cmd "-lev 2"]}
    if {$midi(match_norhythm) == 1} {
        set cmd [concat $cmd "-norhythm"]}
    set cmd [concat $cmd [return_matchmode_parameter]]
    set cmd [concat $cmd -ign]
 
    catch {eval $cmd} result
    set exec_out $exec_out\n$cmd\n$result
    set matchlist [split $result \n"]
    pop_matcher_results
    record_matched_tunes $midi(searchdir) 1 0
    set f .matcher.top
    $f.con.display configure -state normal
    $f.con.dump configure -state normal
    stop_matcher
    update_console_page
}


proc run_glob_matcher {} {
    global midi
    global matchlist
    global exec_out
    global stopsearch
    set home [pwd]
    cd $midi(searchdir)
    set file_list [rglob *.abc]
    cd $home
    set stopsearch 0
    pop_matcher_results
    set i 0
    set exec_out ""
    foreach filename $file_list {
        .matcher.top.msg.lab configure -text $filename"
        update
        set filepath [file join $midi(searchdir) $filename]
        set cmd "exec [list $midi(path_abcmatch)] [list $filepath]"
        if {$midi(match_selection) == "any"} {set cmd [concat $cmd -a]}
        if {$midi(match_method) == "con"} {set cmd [concat $cmd -con]}
        if {$midi(match_method) == "qcon"} {set cmd [concat $cmd "-con -qcon"]}
        if {$midi(match_norhythm) == 1} {
              set cmd [concat $cmd "-norhythm"]} 
        set cmd [concat $cmd [return_matchmode_parameter]]
        catch {eval $cmd} result
        set exec_out $exec_out\n$cmd\n$result
        set matchlist [split $result \n"]
        record_matched_tunes [file join $midi(searchdir) $filename] 1 0
        if {$stopsearch} break;
        set gfiles($i) $filename
        incr i
        update
    }
    stop_matcher
    update_console_page
}


proc record_matched_tunes {filename minlength xrefno} {
    # for each tune in matchlist, if there are more than or equal
    # to minlength matched bars, the tune is copied to the .matcher.notice.t
    # window and the matched bars are highlighted.
    global matchlist mlocator
    set lastxref -1
    set abchandle [open $filename r]
# Sort them because the xref of the template is presented last in matchlist
# and find_xref_in_file cycles only once through file filename.
    set matchlist [lsort -command compare_onset $matchlist]
    set matchesfound 0
    foreach matchpair $matchlist {
        set matches [lrange $matchpair 2 [llength $matchpair]]
        set xref [lindex $matchpair 1]
        if {[string is integer $xref] != 1} continue
        if {$xref == $xrefno} continue
        if {[llength $matches] >= $minlength} {incr matchesfound}
        }
    
    #if {$matchesfound == 0} {
    #    .matcher.notice.t insert end "no matches found\n"
    #    return
    #    }
    
     
    foreach matchpair $matchlist {
        set matches [lrange $matchpair 2 [llength $matchpair]]
        set xref [lindex $matchpair 1]
        if {[string is integer $xref] != 1} continue
        if {[llength $matches] < $minlength && $xref != $xrefno} continue
        set mlocator [lindex $matchpair 0]
        if {$xref != $lastxref} {
            find_xref_in_file $abchandle $xref $filename
            highlight_selected_bars $matches
            set lastxref $xref
        }
    }
    close $abchandle
}




proc copy_matched_tune {abchandle} {
    # copies tune from file and locates all bar lines in
    # body which are stored in the array barloc
    global barloc df
    set line [gets $abchandle]
    set bcount 1;
    .matcher.notice.t tag configure bl  -foreground red
    .matcher.notice.t insert end $line\n
    set p {\|+}
    if {[info exist barloc]} {unset barloc}
    while {[string length $line] > 0 } {
        set line  [gets $abchandle]
        if {[string index $line 0] == "X"} break;
        .matcher.notice.t insert end $line
        
        set initial [string index $line 0]
        set next [string index $line 1]
        if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
            >= 0 && $next == ":" } {
            .matcher.notice.t insert end \n
            continue
        }
        
        set start 0
        set result 1
        set index [.matcher.notice.t index "end -1 char"]
        set linenum [lindex [split $index .] 0]
        if {$bcount == 1} {set barloc(0) $linenum.0}
        while {$result} {
            set result [regexp -start $start -indices $p $line loc]
            if {$result} {set barpos [lindex $loc 1]
		#ignore first bar line if present
                set start [expr $barpos+1] 
                if {$bcount == 1} {
                    set a [string index $line 0]
                    #puts "char = $a barpos = $barpos"
                    if {![string is alpha $a] && $barpos < 3}   continue
                    }
                set barloc($bcount) $linenum.$barpos
                incr bcount
            }
        }
        .matcher.notice.t insert end \n
    }
   #puts "$bcount bars\n"
   #for {set i 0} {$i < $bcount} {incr i} {
   #    puts "barloc($i) = $barloc($i)"
   #    }
   #puts ""
}


proc highlight_selected_bars {bars} {
    global barloc
    global mfixed
    .matcher.notice.t tag configure bl  -foreground red
    foreach bar $bars {
        if {[string is integer $bar] == 0} break;
        set bar2 [expr $bar + 1]
        #puts "highlighting bar $bar $barloc($bar) $barloc($bar2) +1 chars"
        if {[info exist barloc($bar2)]} {
           if {$mfixed} {
              highlight_matched_notes $bar $mfixed
           } else {
             .matcher.notice.t tag add bl $barloc($bar) "$barloc($bar2) +1 chars"
           }
        }
    }
}

proc highlight_matched_notes {bar n} {
   global barloc
   set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]\'*|z|x)(/?[0-9]*|[0-9]*/*[0-9]*)}
   set gchordpat {\"[^\"]+\"}
   set bar2 [expr $bar + 1]
   set loc $barloc($bar)
   for {set i 0} {$i < $n} {incr i} {
     set gloc [.matcher.notice.t search -regexp $gchordpat "$loc+1 char"]
     set loc [.matcher.notice.t search -regexp $notepat "$loc+1 char"]
     if {[.matcher.notice.t compare $gloc < $loc]} {
# skip if the note was mistaken as a gchord
         set loc [.matcher.notice.t search -regexp $notepat "$loc+1 char"]
         }
     }
   #puts "from $barloc($bar) to $loc"
  .matcher.notice.t tag add bl $barloc($bar) "$loc+1 chars"
   }



proc find_xref_in_file {abchandle xref filename} {
    # The tune with reference number xref is
    # copied to the .matcher.notice.t text box.
    # We need to find its position in the file
    # filename so that its contents can be displayed
    # in a info box.
    global match_index
    global mlocator
    global midi
    while {[gets $abchandle line] >= 0 } {
        set initialchar [string index $line 0]
        if {[string equal $initialchar X]} {
            set number [string range $line 2 10]
# in case there are leading zero's eg 0035 which would be confused with
# and octal number, eg. Jack Campin's Aird_v*.abc files
            set number [string trimleft $number 0]
            if {$number == $xref} {
                .matcher.notice.t tag configure m$match_index -foreground darkblue
                .matcher.notice.t insert end  %$filename\n m$match_index
                .matcher.notice.t tag bind m$match_index <1> "show_match_file [list $filename] $xref"
                button .matcher.notice.t.play$match_index  -image kmix-16 \
                   -borderwidth $midi(butborder) \
                  -command "play_selected_tune_in_file [list $filename] $xref" 
               .matcher.notice.t window create end -window .matcher.notice.t.play$match_index
                tooltip::tooltip .matcher.notice.t.play$match_index "play midi"
                .matcher.notice.t insert end \n$line\n
                incr match_index
                copy_matched_tune $abchandle
                break}
        }
    }
}


#set types {{{abc files} {*.abc}}
#           {{all} {*}}}

proc match_file_browser {} {
    global types midi
    set filedir [file dirname $midi(searchdir)]
    set filename [tk_getOpenFile -initialdir $filedir -filetypes $types]
    if {[string length $filename] > 0} {set midi(searchdir) $filename}
}

proc match_dir_browser {} {
    global midi
    set filedir [file dirname $midi(searchdir)]
    set filename  [tk_chooseDirectory -initialdir $filedir]
    if {[string length $filename] > 0} {set midi(searchdir) $filename}
}



proc show_match_file {filename loc} {
    global midi
    global item_id
    if {$loc < 0} return
    open_abc_file $filename
    .abc.titles.t selection set {}
    see_item $loc
}

proc see_item {loc} {
    global item_id
    #puts [array names item_id]
    #set toc_index $item_id($locator($loc))
    set toc_index $item_id($loc)
    .abc.titles.t selection set $toc_index
    .abc.titles.t focus $toc_index
    .abc.titles.t see $toc_index
    update
    }

proc transfer_editor_buffer_to_abcmatch {} {
    global midi
    global body_start body_end
    global abctxtw
    if {[winfo  exist .abcedit] == 0} {
        messages "You need to run TclAbcEditor\
                and highlight several complete bars of the music body\
                of a specific tune before using this function."
        return
    }
    
    set selrange [$abctxtw tag ranges sel]
    if {[llength $selrange] < 2} {
        messages "Please select an area in the body of the tune \
                and then try again. To select a region, hold the left mouse button \
                down and sweep an area."
        return
    } else {
        set selstart [lindex $selrange 0]
        set selend [lindex $selrange 1]
        set value [$abctxtw get $selstart $selend]
        set value [remove_guitar_chords $value 0]
        set value [remove_grace_notes $value 0]
        # throw out \n
        set value [string map {\n \040} $value]
        set midi(match_body) $value
        
        set point [$abctxtw index insert]
        if {$point > $body_end} {set point $body_start.0}
        set kfield [$abctxtw search -backwards K: $point]
        set kfield [$abctxtw get $kfield  "$kfield lineend"]
        set midi(match_keysig) [string range $kfield 2 end]
        set lfield [$abctxtw search -backwards L: $point]
        if {[string length $lfield] > 0} {
            set lfield [$abctxtw get $lfield  "$lfield lineend"]
            set midi(match_length) [string range $lfield 2 end]
        } else {
            set midi(match_length) 1/8}
        
        
        set mfield [$abctxtw search -backwards M: $point]
        set mfield [$abctxtw get $mfield  "$mfield lineend"]
        set midi(match_timesig) [string range $mfield 2 end]
        match_window bars
    }
}



proc play_match.abc {} {
    global midi exec_out
    global files
    set cmd "file delete [glob -nocomplain X*.mid]"
    catch {eval $cmd}
    set out_fd [open X.tmp w]
    puts $out_fd "X: 1"
    write_midi_codes $out_fd
    puts $out_fd "M: $midi(match_timesig)"
    puts $out_fd "L: $midi(match_length)"
    puts $out_fd "K: $midi(match_keysig)"
    puts $out_fd "$midi(match_body)\n"
    close $out_fd
    set cmd "exec $midi(path_abc2midi) X.tmp"
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files X1.mid
    play_midis 1
}

proc dump_to_abc {with_match_body} {
   global types midi
    set filename [tk_getSaveFile -filetypes $types]
    set line ""
    if {$filename != ""} {
        set outhandle [open $filename w]

        if {$with_match_body} {
          puts $outhandle X:100000
          puts $outhandle "T:Matcher Input"
          puts $outhandle "N: abcmatcher output at [clock format [clock seconds]] using"
          puts $outhandle  "M:$midi(match_timesig)"
          puts $outhandle  "L:$midi(match_length)"
          puts $outhandle  "K:$midi(match_keysig)"
          puts $outhandle  "$midi(match_body)\n\n"
          }


        foreach {key value index} [.matcher.notice.t  dump -text 1.0 end] {
            set value [string trimright $value "\n"]
            #a matching bar is tagged and sent in a separate line.
            #we need  to combine those lines
            #puts "index = $index value = $value"
            set charnum [lindex [split $index .] 1]
            if {$charnum == 0} {
                puts $outhandle $line
                set line $value} else {
                set line $line$value}
        }
        puts $outhandle $line
        close $outhandle
        if {$midi(bell_on)} bell
    }
}

proc display_matches {} {
global midi
global ps_numb_start
#if {$midi(ps_creator) != "yaps"} {
#        messages "This will work better with the yaps software. You\
#        have configured the program to use $midi(ps_creator)."
#        }
set ps_numb_start 0
if {$midi(ps_creator) == "yaps"} {dump_for_yaps_display
   } else dump_for_abcm2ps_display
display_tunes X.tmp
}


proc dump_for_abcm2ps_display {} {
    global types midi
    set filename X.tmp
    set line ""
    set red 0
    if {$filename != ""} {
        set outhandle [open $filename w]
        foreach {key value index} [.matcher.notice.t  dump 1.0 end] {
            set eoln_at [string last "\n" $value] 
            if {$eoln_at > 0} {
                      set eoln1 [expr $eoln_at -1]
                      if {[string index $value $eoln1] == "\\"} {set eoln_at -1}
                      }
            set value [string trimright $value "\n"]
#we insert an empty symbol y0 before the %%postscript command
#to ensure that command is invoked in the right place and we
#do not get the clef or staff all red too.
            if {$key == "text" && [string length $value] > 0} {
              if {$eoln_at < 0 && [string index $value end] != "\\"} {
                 puts $outhandle "$value\\"} else {
                 puts  $outhandle $value}
    #         if {$eoln_at > 0 && $red} {puts "red running throu at $value"}
    #         we do nothing for the present time
              }  elseif {$key == "tagon" && $value == "bl"} {
              puts $outhandle \\
              #puts $outhandle "y0 \\"
              #puts $outhandle "%%postscript 1 0 0 setrgbcolor"
               puts $outhandle "%%voicecolor #c0000000"
              set red 1
              } elseif {$key == "tagoff" && $value == "bl"} {
              puts $outhandle \\
              #puts $outhandle "y0\\"
              #puts  $outhandle "%%postscript 0 0 0 setrgbcolor"
               puts $outhandle "%%voicecolor #000000"
              set red 0
             }
        }
        close $outhandle
        if {$midi(bell_on)} bell
    }
}

proc dump_for_yaps_display {} {
    global types midi
    set filename X.tmp
    set line ""
    if {$filename != ""} {
        set outhandle [open $filename w]
        foreach {key value index} [.matcher.notice.t  dump 1.0 end] {
            if {$key == "text" && [string length $value] > 0} {
                 puts -nonewline $outhandle "$value"
              } elseif {$key == "tagon" && $value == "bl"} {
              puts  -nonewline $outhandle !red!
              } elseif {$key == "tagoff" && $value == "bl"} {
                puts  -nonewline $outhandle !black!
             }
        }
        close $outhandle
        if {$midi(bell_on)} bell
    }
}


proc dump_for_html {} {
    global types midi
    set filename X.tmp
    set line ""
    if {$filename != ""} {
        set outhandle [open $filename w]
        puts $outhandle "<!-- delete the next 3 lines if you are pasting this into a html doc -->\n<!DOCTYPE HTML>\n<html>\n<body>\n"
        foreach {key value index} [.matcher.notice.t  dump 1.0 end] {
            if {$key == "text" && [string length $value] > 0} {
                 set hvalue [string map {\n <br>\n} $value]
                 puts -nonewline $outhandle "$hvalue"
              } elseif {$key == "tagon" && $value == "bl"} {
              puts  -nonewline $outhandle "<FONT COLOR = \"RED\">"
              } elseif {$key == "tagoff" && $value == "bl"} {
                puts  -nonewline $outhandle "<FONT COLOR = \"BLACK\">"
             }
        }
        puts $outhandle "<!-- delete the remaining lines if you are pasting this in a html doc -->\n</html>\n</body>\n" 
        close $outhandle
        if {$midi(bell_on)} bell
    }
}


set hlp_match_tune \
	"This function is usually invoked by the grouper when you\
	 click on the 'details' button but now can also run stand\
	 alone. Unlike 'match bars' recursive searches of folders\
	 for abc files is not available at this time.\n\n\
	The main purpose of the function is to display the results\
	from the grouper. The specific tune used as a template is\
	displayed differently. Only the bars which have matched bars\
	in other tunes are displayed in red in the template tune.\n\n\
	Normally, the grouper window specifies which tune to select\
	as template. However, that can be changed by entering its\
	X: reference number in the entry box, or more conveniently\
	by selecting it in the Table of Contents (TOC) window.\n\n\
	After clicking the 'match' button, the program should display\
	the selected tune and highlight any of the bars which were\
	matched in other tunes. If the number of matching bars in\
	the other tunes exceeded the specified threshold (minimum\
	matches), that tune is also shown.\n\n\
        When this function is invoked by the menu item 'search menu/\
        find tunes', the program uses the entire selected tune as\
        the template and the collection of tunes displayed in the\
        TOC as the search space.\n\n\
        After running the matcher, you can generate and view the\
        color enhanced PostScript file or you can save the results.\
        You have a choice of three formats. 'Regular save' saves the\
        results as an ordinary abc file. 'Color save' also saves the\
        results as an abc file, but there is additional code for\
	highlighting the red sections in red when the file is converted\
        to PostScript using either yaps or abcm2ps (The program\
	automatically chooses the right format for the PostScript\
        converter.) 'Html save' will save the results as an\
	 html file. This is useful for inclusion into a web document\
	 (you need to edit out some of the header\
	and tail sections). Alternatively, you can use other\
	software to import this file into a word processing document.\
	(This is the simplest way for preserving the red sections\
	in a text document.)"
  	


set hlp_match_bars "This function searches for any tune having music bars with\
        a specific pattern. The search is performed on either a specific\
        abc file (which is usually a compilation of many tunes) or on a\
        folder containing abc files. The file or folder is specified in\
        the path entry box.  If you specify a folder, the program will\
        search recursively for all abc files starting from this folder.\n\n\
        To specify the music pattern that you are searching for, you\
        edit the contents of the K: M: L: and template entry boxes.\
        The contents of the first three boxes are identical to the\
        corresponding field entries in an abc formated file. The template\
        should contain 1 or a few complete bars. It is not necessary\
        to start a bar with a bar line, but the last bar must end with a\
        bar line.\n\nClicking the `play' button allows you to hear the bar or\
        bars that you have specified. The button labeled `transfer' allows\
        you to fill in the K: M: L: and template fields rapidly, assuming that\
        the specific bar or bars is already highlighted in a the TclAabcEditor\
        editor. Thus you are able to search for other tunes which include\
        those highlighted bars. When you transfer these highlighted\
        bars, guitar chords and grace notes are automatically\
        removed. The match function ignores this information as well as\
        decorations, slurs and rolls. Instead of clicking the transfer button\
        you may also use the <Alt-t> key when the focus is on the abcedit\
        window.\n\nIt is possible to transfer the entire body of the tune\
        to the entry box. New lines are automatically converted to spaces so\
        the text string can be read properly in the runabc.ini file.\
        Though not everything is visible, the horizontal\
        scroll bar below allows you to scroll through the entry box.\n\n\
        The configure button allows you to configure the characteristics of\
        of the matching algorithm. A separate window matchcfg will appear\
        allowing you to select the different options.\n\n\
        To start the matching process click\
        the button labeled `match'. Matches will appear in a scrolled text\
        window appearing below and all bars that match the criterion will be\
        displayed in red. In addition the file where the match occurred will\
        appear above in blue. If you click on the blue file name, then the\
        selected tune will be loaded into the table of contents window and\
        the specific tune will be selected and centered in that window. This\
        allows you to get to that tune rapidly, assuming you wish to either\
        display the music notation or play the tune.\n\n\
        The speaker icon allows you to listen to that particular tune."

set hlp_match_cfg "Match configure menu\n\n\
        The matchcfg window is used to select the matching criterion. One\
	of the radiobuttons can be ticked in the first two columns that\
	are labeled 'accuracy' and 'no bar lines'. In addition any one\
	of the radiobuttons on the right most column can be ticked. The\
        'no rhythm' check box applies only if you select 'exact' or one\
	 of the methods in the middle column. Here is a brief explanation\
	 of the matching schemes, but more details can be found though\
         the link to runabc.html on the web page\
         http://ifdo.ca/~seymour/runabc/top.html .\n\n\
	 The methods in the left most column apply to full bars and\
	 both the template and the selected tunes must have the same\
	 time signature. If 'exact' is not selected, the matching method\
	 is less precise and approximates the bar in both the template\
	 and the tune with a series of 1/16 notes (or whatever was\
	 selected) which follows the melody.\n\n\
	 The matching methods in the second column, attempt to match\
	 only the first n notes in the bars. If n exceeds the number\
	 of notes in the bar, the algorithm will cross the bar into\
	 the next measure. The matching algorithm, nevertheless always\
	 starts at the beginning of the measure.\n\n\
	 If 'no rhythm' is ticked, then the duration of the notes is\
	 ignored.\n\n\
	 The last column controls other aspects of the matching method.\
	 You must tick, either 'all' or 'any'. 'all' implies that the\
	 entire template consisting of several bars must match a sequence\
	 of bars in the tune in order to be reported. 'any' implies that\
	 the bars in the template act independently, and any matched\
	 bar in the template is reported. One of the next three radio\
	 buttons, 'absolute', contour, or 'quantized contour' must also\
	 be selected. 'absolute' indicates that the position of the note\
	 in the musical scale is important. i.e. E in the C major scale,\
	 can match with B in the G major scale but not any other note.\
	 'contour' requires that only the musical intervals between the\
	 notes match. 'quantized contour' is also similar but the matching\
	 criterion is looser. e.g. both a major and minor second can\
	 match.\n\n\
	 Levenshtein distance check box is a recent feature. If checked,\
	 the matching algorithm will allow small discrepancies in the match\
	 where a note may be inserted, deleted or substituted."


#end of abcmatch.tcl



# Part 17.0              Grouper interface


#beginning of source grouper.tcl


proc grouper_window {} {
    global midi df hlp_grouper
    if {[check_abcmatch_version 1.60] == 0} return
    set f .grouper
    if {[winfo exist $f]} return
    toplevel $f
    position_window ".grouper"
    frame $f.1
    label $f.1.inputfilelab -text "input file" -font $df
    entry $f.1.inputfilevar -width 50 -textvariable midi(abc_open) -font $df
    bind $f.1.inputfilevar <Return> {focus .grouper.1.inputfilelab
        run_grouper}
    button $f.1.filebrowse -text browse -font $df -command file_browser
    pack $f.1.inputfilelab $f.1.inputfilevar $f.1.filebrowse -side left -anchor w
    pack $f.1 -anchor w
    frame $f.2
    button $f.2.start -text group -font $df -command run_grouper
    button $f.2.save -text "save output" -font $df -command dump_grouper_output
    set p $f.2.minmenu.choice
    menubutton $f.2.minmenu -text "minimum matches = " -font $df\
           -relief raised -menu $p
    menu $p -tearoff 0
    $p add command -label 1 -font $df -command "set_min_matches 1"
    $p add command -label 2 -font $df -command "set_min_matches 2"
    $p add command -label 3 -font $df -command "set_min_matches 3"
    $p add command -label 4 -font $df -command "set_min_matches 4"
    $p add command -label 5 -font $df -command "set_min_matches 5"
    $p add command -label 6 -font $df -command "set_min_matches 6"
    $p add command -label 7 -font $df -command "set_min_matches 7"
    $p add command -label 8 -font $df -command "set_min_matches 8"
    label $f.2.minlab -text 1 -font $df
    button $f.2.help -text help -font $df\
            -command {
                show_message_page $hlp_grouper word
                focus .abc
                raise .abc}
    button $f.2.cfg -text configure -font $df -command configure_match
    pack $f.2.start $f.2.save $f.2.minmenu $f.2.minlab $f.2.cfg $f.2.help -side left -anchor w
    pack $f.2 -anchor w
    frame $f.msg
    label $f.msg.lab -width 60 -text "" -font $df
    pack $f.msg.lab -side left
    pack $f.msg -side top
    update
    set_min_matches $midi(grouper_thresh) 
}


proc pop_grouper_results {} {
    global df
    set p .grouper.notice
    if [winfo exist .grouper.notice] {
        $p.t configure -state normal
        $p.t delete 1.0 end
    } else {
        frame $p
        text $p.t -height 25 -width 70 -wrap word -yscrollcommand {.grouper.notice.ysbar set} -font $df
        scrollbar $p.ysbar -orient vertical -command {.grouper.notice.t yview}
        pack $p.ysbar -side right -fill y -in $p
        pack $p.t -in $p
        pack $p}
    update
}



proc grouper_title_index {abcfile} {
    global fileseek tuneid
    
    set srch X
    #   i is the next file sequence number to search for X:
    #   when found we save it in i1 and incr i for next search
    #   We do it this way because a few tunes do not have a
    #   T: or P: indication (see John Chamber's site, maybe
    #   it is fixed by now :-) ).
    set i  0
    set pat {[0-9]+}
    set titlehandle [open $abcfile r]
    set fileseek(0) 0
    while {[gets $titlehandle line] >= 0} {
        if {[string length $line] < 1} {set srch X}
        switch -- $srch {
            X {if {[string compare -length 2 $line "X:"] == 0} {
                    regexp $pat $line  number
                    set srch T
                    set i1 $i
                    incr i
                    set tuneid($i1) ""
                } else {
                    set fileseek($i) [tell $titlehandle]}
            }
            T {
                if {[string index $line 0] == "T" || [string index $line 0] == "P"} {
                    if {[string length $tuneid($i1)] < 1} {
                      set name [string range $line 2 end]
                      set name [string trim $name]
# remove parentheses which can cause a problem
                      set name [string map {( {} ) {}} $name]

                      set tuneid($i1) [format "%s %s" $number $name]
                      }
                    set srch X
                }
            }
        }
    }
    close $titlehandle
    return $i
}



proc list_titles {n} {
    global fileseek tuneid
    for {set i 0} {$i <$n} {incr i} {
        puts "$fileseek($i) $i $tuneid($i)"
    }
}

proc start_grouper {} {
    global stopgrouper
    set stopgrouper 0
    .grouper.2.start configure -text stop -command stop_grouper
    update
}

proc stop_grouper {} {
    global stopgrouper
    set stopgrouper 1
    .grouper.2.start configure -text group -command run_grouper
}


proc create_matcher_template_for {grouper_handle seqno} {
    #overwrite match.abc file with the next tune
    global fileseek
    seek $grouper_handle $fileseek($seqno)
    set line [get_nonblank_line $grouper_handle]
    set outhandle [open match.abc w]
    #   replace xrefno with sequence number for match.abc in case
    #   they are not in sequence in abcfile.
    puts $outhandle "X: $seqno"
    while {[string length $line] > 0} {
        set line [get_nonblank_line $grouper_handle]
        if {[string index $line 0] == "X"} break;
        puts $outhandle $line
    }
    puts $outhandle ""
    close $outhandle
}


proc group_tunes {n abcfile} {
    global fileseek tuneid midi
    global stopgrouper
    global df
    global exec_out

#   for statistics
    set gfiles 0 
    set glinks 0
    set gbars 0
    set starttime [clock seconds]

    set p .grouper.notice
    start_grouper
    set cmd "exec [list $midi(path_abcmatch)] [list $abcfile] -br $midi(grouper_thresh)"
    if {$midi(match_selection) == "any"} {set cmd [concat $cmd -a]}
    if {$midi(match_method) == "con"} {set cmd [concat $cmd -con]}
    if {$midi(match_method) == "qcon"} {set cmd [concat $cmd "-con -qnt"]}
    if {$midi(levenshtein)} {set cmd [concat $cmd "-lev 2"]}
    if {$midi(match_norhythm) == 1} {
        set cmd [concat $cmd "-norhythm"]}
    set cmd [concat $cmd [return_matchmode_parameter]]
    set cmd [concat $cmd -ign]
    pop_grouper_results
    set grouper_handle [open $abcfile r]
    set j 0
    for {set i 0} {$i <$n} {incr i} {
        if {$stopgrouper} break
        create_matcher_template_for $grouper_handle $i
        .grouper.msg.lab configure -text "$i/$n $tuneid($i)"
        update
        # now run abcmatch.exe
        catch {eval $cmd} result
        if {[string first "segmentation" $result] > 0} break
        set exec_out $exec_out\n$cmd\n$result
        #if {$result != ""} {puts "grouper result for $i\n$result"}
        #if {[string first "segmentation" $result] > 0} break
        
        # grab the output of abcmatch.exe if any and
        # convert it into a list.
        if {[string length $result] > 0} {
            if {![string is integer [lindex $result 0]]} {
                $p.t insert end "\n\n**error**  $result"
                $p.t insert end "\n for tune $i\n\n"
                continue
                }
            incr gfiles
            set grouplist [split $result \n]
            set mbars [lindex $result 0]
            incr gbars $mbars
            # display the output in a text window.
            set tpxrefno [lindex $tuneid($i) 0]
            set title [lrange $tuneid($i) 1 end]
            button $p.t.play$i  -image kmix-16 -borderwidth $midi(butborder)\
                  -command "play_selected_tune_in_file [list $abcfile] $tpxrefno" 
            $p.t insert end "\nfor "
            $p.t tag configure p$j -foreground darkblue
            $p.t tag bind p$j <1> "see_item [expr $i+1]"
            $p.t insert end "$tpxrefno " p$j
            incr j
            $p.t window create end -window $p.t.play$i
            $p.t insert end " $title ($mbars bars)   "
            $p.t tag configure m$i -foreground darkblue
            $p.t tag bind m$i <1> "grouper_findbars_for [expr $i+1]"
            $p.t insert end details\n m$i
            set grouplist [lrange $grouplist 1 end]
            set k 0
            foreach item $grouplist {
                set xref [lindex $item 0]
                set count [lindex $item 1]
                set tcount [lindex $item 2]
                set tpxrefno [lindex $tuneid($xref) 0]
                set title [lrange $tuneid($xref) 1 end]
            #    button $p.t.$j -text $tpxrefno -font $df -borderwidth $midi(butborder)\
            #      -bg white -fg darkblue -pady 0 -padx 0\
            #      -command "see_item $tpxrefno"
                $p.t tag configure p$j -foreground darkblue
                $p.t tag bind p$j <1> "see_item [expr $xref+1]"
                $p.t insert end $tpxrefno p$j
                button $p.t.p$j -image kmix-16 -borderwidth $midi(butborder)\
                  -command "play_selected_tune_in_file [list $abcfile] $tpxrefno"
                #$p.t window create end -window $p.t.$j -padx 0 -pady 0
                $p.t window create end -window $p.t.p$j -padx 0 -pady 0
                $p.t insert end " $title ($count-$tcount bars)\n"
                incr j
                incr k
                if {$k > 50} {$p.t insert end "   and etc......\n"
                    break;
                }
            }
            incr glinks $k
        }
        update
    }
    stop_grouper
    close $grouper_handle
    set s "$gfiles tunes matched out of $i\n"
    append s "the $gfiles tunes had a total of $gbars bars\n"
    append s "average number of tunes linked to matched tune = [format %5.2f [expr $glinks/double($gfiles)]]\n"
    append s "elapsed time = [expr [clock seconds] - $starttime]\n\n"
    $p.t insert 0.0 $s
}

proc grouper_findbars_for {xref} {
global tpxrefno
set tpxrefno $xref
see_item $tpxrefno
grouper_findbars
}

proc grouper_findbars {}  {
    global midi
    global matchlist
    global match_index
    global exec_out
    global tpxrefno
    global selectedtitle
    global exec_out
    set exec_out ""
    match_window tune
    .matcher.top.msg.lab configure -text "results for $selectedtitle"
    set match_index 0
    set cmd "exec [list $midi(path_abcmatch)]  [list $midi(abc_open)] -tp [list $midi(abc_open)] $tpxrefno "
    if {$midi(match_selection) == "any"} {set cmd [concat $cmd -a]}
    if {$midi(match_method) == "con"} {set cmd [concat $cmd -con]}
    if {$midi(match_method) == "qcon"} {set cmd [concat $cmd "-con -qnt"]}
    if {$midi(levenshtein)} {set cmd [concat $cmd "-lev 2"]}
    if {$midi(match_norhythm) == 1} {
        set cmd [concat $cmd "-norhythm"]}
    set cmd [concat $cmd [return_matchmode_parameter]]
    #set cmd [concat $cmd -ign]

    set grouper_handle [open $midi(abc_open) r]
    #create_matcher_template_for $grouper_handle $seqno
    catch {eval $cmd} result
    set exec_out "$exec_out\n$cmd\n$result"
    set matchlist [split $result \n"]
    pop_matcher_results
    record_matched_tunes $midi(abc_open) $midi(grouper_thresh) $tpxrefno
    set f .matcher.top
    $f.con.display configure -state normal
    $f.con.dump configure -state normal
    update_console_page
}


proc run_grouper {} {
    global midi
    global exec_out
    set ntunes [grouper_title_index $midi(abc_open)]
    set exec_out ""
    group_tunes $ntunes $midi(abc_open)
}



proc dump_grouper_output {} {
    global midi
    set types {{{text files} {*.txt}}}
    set filename [tk_getSaveFile -filetypes $types]
    set line ""
    if {$filename != ""} {
        set outhandle [open $filename w]
        puts $outhandle "grouper output at [clock format [clock seconds]]\nfor $midi(abc_open)"
        foreach {key value index} [.grouper.notice.t  dump -text 1.0 end] {
            set line [string trimright $value "\n"]
            set line [string trimright $value]
            #puts "key = $key value = \"$value\" index = $index"
            if {$value == "details\n"} continue
            if {[string first "for" $line] < 0 && [string is digit $line] == 0} {
                puts $outhandle $line
                } else {
                puts -nonewline $outhandle "$line "
                }
          }
        close $outhandle
        if {$midi(bell_on)} bell
    }
}


set hlp_grouper \
        "Given a file composed of a collection of abc tunes, the function\
        is designed to identify groups of tunes sharing common bars of music.\
        It is useful for identifying duplicates, or groups of tunes that\
        may form a medley.\n\n Essentially, the function runs \
        abcmatch repeatedly on every tune in the file. For each tune the\
        entire body of the tune is made a template and compared with\
        all the tunes in the file. The number of bars in the tune\
        that are common with the template are counted. If the number is\
        greater than a threshold then that tune is reported as well as\
        the number of common bars. This threshold may be adjusted using\
        the scale widget labeled 'min bars'. The threshold controls the\
        amount of output.  When the number of common bars\
        is almost equal to the number of bars in the template tune,\
        it is likely that the tunes are the same. Otherwise, the\
        tunes probably share similar nuances. The button labeled\
        'save results' allows you to save the output of this function\
        in a separate text file.\n\n Some of the bars\
        may be very simple (eg. one note) and matches everything,\
        so there may be a lot of false positives.\n\n The program lists\
        two numbers separated by a dash for the number of matching\
        bars. The first number is the number of matching bars in\
        the listed tune. The second number is the number of bars in\
        the template that matched. This number is also important.\
        For example, if it is only one, it means only one bar in the\
        template is in common with the tune. That bar may appear many\
        times in that tune.\n\n The 'input file' entry\
        box is linked to the entry box in the runabc window so modifying\
        its contents also modifies the other box.\n\nIf you click on the\
        blue text marked details, then the group of tunes will be displayed\
        in a separate window labeled matcher (the same one used by find bars)\
        and all the matching bars will be highlighted in red. Essentially,\
        the find bars function is run using the selected tune as a template\
        on the active file. The function is not run with the same parameters\
        indicated in the matcher window so the output is not the same that\
        you would get if you clicked on the match button on the matcher window."

#end of source grouper.tcl



# Part 18.0                  Diagnostic Support Functions


#source diag.tcl
#Check configuration of runabc

bind . <Alt-s> {runabc_diagnostic}
bind . <Alt-S> {runabc_diagnostic}

set abcmidilist {path_abc2midi 4.48\
            path_abc2abc 2.13\
            path_yaps 1.86\
            path_midi2abc 3.47\
            path_midicopy 1.37\
            path_abcmatch 1.77\
            path_abcm2ps 8.14.11}
global abcmidilist

proc runabc_diagnostic {} {
    global midi
    global tcl_platform
    global abcmidilist
    global execpath runabcpath
    set diag_output [open  runabc.out   w ]
    set plat $tcl_platform(platform)
    set os $tcl_platform(os)
    set osver $tcl_platform(osVersion)
    set machine $tcl_platform(machine)
    set tclversion [info tclversion]
    set msg [format "runabc version $midi(version) running on $machine $plat/$os $osver tcl/tk $tclversion\n"]
    puts $diag_output $msg
    set msg  "The current directory is [pwd]"
    puts $diag_output $msg
    set msg "The program [info nameofexecutable] is running"
    puts $diag_output $msg
    set msg "The script [info script] is running from $execpath"
    puts $diag_output $msg
    set msg "The home directory is $runabcpath"
    puts $diag_output $msg
    set msg "\nThe following verifies the existence of an executable at
    the specific location specified in the config/executables property
    sheet. Note that executable may still be accessible using the
    PATH environment variable if only the filename is given.\n\n"
    puts $diag_output $msg
    
    foreach {path ver} $abcmidilist {
        set msg "$midi($path)\t [get_version_number $midi($path)]\t$ver"
        puts $diag_output $msg}
    foreach path {path_abcm2ps path_gv path_midiplayer_1} {
        set msg "$midi($path)\t\t [check_file $path]"
        puts $diag_output $msg}
    
    close $diag_output
    messages "Results of the sanity check are recorded in the\
            file $runabcpath/runabc.out. You may view these results using any text\
            editor or word processor."
    show_checkversion_summary
}


proc show_checkversion_summary {} {
    global abcmidilist
    global midi
    set p .summary
    if [winfo exist $p] {.summary.t delete 1.0 end} else make_summary_toplevel

    set msg "full file path                                   expected version      actual version"
    $p.t insert end "$msg\n\n"

    foreach {path ver} $abcmidilist {
        set result [get_version_number $midi($path)]
	# add this line for abcm2ps
	set result [lindex [split $result \n] 0]
        #set msg "$midi($path)\t $result"
	set msg [format "%-40s  %-5s     %-20s" $midi($path) $ver $result]
        $p.t insert end "$msg\n"
    }
        $p.t insert end "\n"
}


#end of diag.tcl


startup_progress "loading extract functions"




# Part 19.0           Abc Editor Filter functions


# filter.tcl
# includes various filters first implemented by
# Luis Pablo Gasparotto

proc remove_voice_fields {buffer dummy} {
    regsub -all {(\[)( )*(V:)( )*([0-9]+)( )*(\])} $buffer {} result
    return $result
}

proc remove_backslashes {buffer dummy} {
    regsub -all {\\} $buffer { } result
    return $result
}

proc remove_tab_chars {buffer dummy} {
    regsub -all \t $buffer { } result
    return $result
}

proc interp_M_field {line} {
    set pattern {(M:)( )*([0-9]+)*([/])*([0-9]+)}
    if { [regexp $pattern $line meas_line meas1 white num meas2 den] == 1 } {
        return [list $num $den]} else {return [list 4 4]}
}


proc interp_L_field {line} {
    set pattern {(L:)( )*([0-9]+)*([/])*([0-9]+)}
    if { [regexp $pattern $line beat_line beat1 white num beat2 den] == 1 } {
        return [list $num $den]} else {return [list 1 8]}
}


proc compute_bar_rest {Lfield Mfield} {
    set Lnum [lindex $Lfield 0]
    set Lden [lindex $Lfield 1]
    set Mnum [lindex $Mfield 0]
    set Mden [lindex $Mfield 1]
    set duration [expr $Lden * $Mnum / $Lnum / $Mden]
    return $duration
}


proc multi_rests_nz2Z {line dummy} {
    set pattern {(\")([0-9]+)(\")(z)([0-9]+)}
    while { [regexp $pattern $line mr_string sign1 meas_num sign2 \
                sign3 sign4] == 1 } {
        regsub {(\")([0-9]+)(\")(z)([0-9]+)} $line "Z$meas_num" line}
    return $line
}


proc whole_rest_from_region {start end} {
    #search backwards for any L: or M:
    global abctxtw
    global L_field M_field
    set Lpos [$abctxtw search -backwards L: $start 1.0]
    if {[string length $Lpos] > 0} {
        set Lline [$abctxtw get $Lpos "$Lpos lineend"]
        set L_field [interp_L_field $Lline]
    } else {set L_field [list 1 8]}
    set Mpos [$abctxtw search -backwards M: $start 1.0]
    if {[string length $Mpos] > 0} {
        set Mline [$abctxtw get $Mpos "$Mpos lineend"]
        set M_field [interp_M_field $Mline]
    } else {set M_field [list 4 4]}
    set whole_rest z[compute_bar_rest $L_field $M_field]
}

proc update_rest_duration {line} {
    #checks for an M: or L: field in the body line and
    #updates these fields and recomputes rest_duration.
    global L_field M_field
    set patternM {(M:)( )*([0-9]+)*([/])*([0-9]+)}
    set patternL {(L:)( )*([0-9]+)*([/])*([0-9]+)}
    set update 0
    if {[regexp $patternL $line] == 1} {set L_field [interp_L_field $line]
        incr update}
    if {[regexp $patternM $line] == 1} {set M_field [interp_M_field $line]
        incr update}
    set duration [compute_bar_rest $L_field $M_field]
    if {$update >0} {return $duration}
    return 0
}


proc multi_rests_Z2nz {region dummy} {
    global abctxtw
    set update 0
    set pattern {(Z)([0-9]+)}
    set start [lindex $region 0]
    set end   [lindex $region 1]
    set whole_rest [whole_rest_from_region $start $end]
    set lstart [expr int($start)]
    set lend   [expr int($end)]
    for {set linenum $lstart} {$linenum <= $lend} {incr linenum} {
        set line [$abctxtw get $linenum.0 "$linenum.0 lineend"]
        set ret [update_rest_duration $line]
        if {$ret} {set whole_rest z$ret}
        while  { [regexp $pattern $line mr_string meas_type meas_num] == 1 } {
            regsub {(Z)([0-9]+)} $line "\"$meas_num\"$whole_rest" line
            incr update
        }
        if {$update} {
            $abctxtw delete $linenum.0 "$linenum.0 lineend"
            $abctxtw insert $linenum.0  $line
        }
    }
}

proc remove_blank_lines {blanks} {
    # removes blank lines starting with last line number in list
    global abctxtw
    set size [llength $blanks]
    if {$size < 1} return
    incr size -1
    for {set i $size} {$i >= 0} {incr i -1} {
        set line [lindex $blanks $i]
        set pos $line.0
        $abctxtw delete $pos "$pos lineend+1 char"
    }
}

proc edit_condense_whole_rests  {region type} {
    #condense a sequence of whole rests to one bar.
    #this version is called by TclAbcEditor
    global cond_output_buffer cond_measures cond_running
    global wr_length whole_rest
    global abctxtw
    set blanks {}
    set start [lindex $region 0]
    set end   [lindex $region 1]
    set whole_rest [whole_rest_from_region $start $end]
    set wr_length [string length $whole_rest]
    set lstart [expr int($start)]
    set lend   [expr int($end)]
    set cond_running 0
    for {set linenum $lstart} {$linenum <= $lend} {incr linenum} {
        set line [$abctxtw get $linenum.0 "$linenum.0 lineend"]
        set ret [update_rest_duration $line]
        if {$ret} {set whole_rest z$ret}
        if { [string match *$whole_rest* $line] != 1 } continue
        set output_line [condense_line $line $type]
        $abctxtw delete $linenum.0 "$linenum.0 lineend"
        if {[string length $output_line] > 0} {
            $abctxtw insert $linenum.0 $output_line
        } else {
            set blanks [concat $blanks $linenum]
        }
    }
    remove_blank_lines $blanks
}

proc condense_whole_rest {buffer type} {
    #condense a sequence of whole rests to one bar.
    #this version is called by extract_action
    global midi
    global cond_running
    global L_field M_field
    global wr_length whole_rest
    set whole_rest z8
    set L_field [list 1 8]
    set M_field [list 4 4]
    set wr_length [string length $whole_rest]
    set cond_running 0
    set outfile [open $midi(abc_default_file) w]
    set music [split $buffer \n]
    foreach line $music {
        set ret [update_rest_duration $line]
        if {$ret} {set whole_rest z$ret}
        if {$type >= 0} {set outline [condense_line $line $type]} else {
            set outline $line}
        if {[string length $outline] > 0} {puts $outfile $outline}
        if {[string length $line] == 0} {puts $outfile $line}
    }
    close $outfile
}


proc condense_line {line type} {
    # The function processes a single line of abc tune, character
    # by character. If no whole rest is found, the function
    # just returns the same line back. If it detects a whole rest
    # then it sets the global variable cond_running to 1 to indicate that
    # it is now in the mode of counting bars with whole rests. Nothing
    # is returned while it is in this mode. There are various
    # rules for breaking a sequence of whole rests. When the
    # sequence is broken, the function returns back to the mode
    # cond_running 0. The various global variables are used
    # to maintain the state of the function between calls.
    #
    global cond_output_buffer cond_measures cond_running
    global wr_length whole_rest multimeasures barline
    set strlength [string length $line]
    if {$cond_running == 0} {
        set cond_output_buffer ""
    }
    set i 0
    while {$i < $strlength} {
        if {$cond_running == 0} {
            if  {[string range $line $i [expr $wr_length+$i-1]] == $whole_rest \
                        &&  [string index $line [expr $i-1] ] != "\"" \
                        &&  [string index $line [expr $i-1] ] != "!" } {
                set cond_running 1
                set i [expr $i + $wr_length]
                set barline "|"
                set cond_measures 1
                set multimeasures 1
            } else  {
                set cond_output_buffer $cond_output_buffer[string index $line $i ]
            }
        }
        # end of initialization after first whole_rest
        
        if {$cond_running == 1} {
            while {$multimeasures != 0 && $i < $strlength} {
                set multimeasures -1
                if {[string index $line $i] == "\\"} {incr i; continue}
                if {[string index $line $i] == "|"} {set multimeasures 1}
                # check for bar lines which break sequence
                set token [string range $line $i [expr $i +1]]
                if {$token == ":|" || $token == "|:" || $token == "||" || $token == "|]"} {
                    set barline $token
                    set multimeasures 0
                    incr i
                }
                # pass over spaces and tabs
                if {[string is space [string index $line $i]]} {
                    set multimeasures 1
                }
                # check for another whole_rest
                if { [string range $line $i [expr $i+$wr_length-1]] == $whole_rest } {
                    incr cond_measures
                    set multimeasures  $wr_length
                }
                # anything else breaks the sequence
                if {$multimeasures < 0} {
                    incr i -1
                    set multimeasures 0
                }
                incr i $multimeasures
            }
            # finished scanning either because we got to the end of the line or the
            # whole note sequence was broken. If multimeasures is non zero then we
            # we have a multirest to output.
            if {$multimeasures == 0} {
                if {$cond_measures != 1} {
                    if {$type} {
                        set cond_output_buffer $cond_output_buffer\"$cond_measures\"$whole_rest } else {
                        set cond_output_buffer $cond_output_buffer\Z$cond_measures}
                } else {
                    set cond_output_buffer $cond_output_buffer$whole_rest
                }
                
                # Adding a barline closing the multimeasure rest
                if { $barline == ":|" || $barline == "|:" || $barline == "||" || $barline == "|]" } {
                    set cond_output_buffer "$cond_output_buffer $barline"
                } elseif { $barline == "|" } {
                    set cond_output_buffer "$cond_output_buffer $barline"
                }
            }
            # finished multirest output.
            ####### puts "output: $cond_output_buffer"
            if {$multimeasures == 0} {set cond_running 0}
            #end cond_running == 1
        }
        
        incr i
        #######puts $cond_output_buffer
    }
    #end of loop over line
    #######puts "$cond_running final output: $cond_output_buffer"
    if {$cond_running == 0} {return $cond_output_buffer}
}


proc extract_action {action} {
    global midi df
    global abc2abc_e extract_t extract_v
    global barpickerflag
    
    set barpickerflag 0
    set abc2abc_opt ""
    if {$abc2abc_e} {append abc2abc_opt "-e "}
    append abc2abc_opt "-t $extract_t "
    append abc2abc_opt "-V $extract_v "
    copy_selection_to_file [title_selected] $midi(abc_open) X.tmp
    if {![file exist $midi(path_abc2abc)]} {messages "can't find $midi(path_abc2abc)"}
    set cmd "exec $midi(path_abc2abc) X.tmp $abc2abc_opt"
    catch {eval $cmd} exec_out
    .abc.extract.5 configure -font $df -text $cmd
    
    # we have to call condense_whole_rest even if it does nothing (with type = -1)
    # because it sends the output to edit.abc. If condense indeed does its job, be sure
    # there are no voice fields in the body line.
    set type $midi(condense_method)
    if {$midi(condense_on) == 0} {set type -1} else {
        set midi(remove_voice) 1}
    
    # If condense method is in automatic mode, then select the multirest respresentation
    # which suits the postscript file creator.
    if {$midi(condense_method) == 2 && $midi(condense_on)} {
        if {$midi(ps_creator) == "abcm2ps"} {set type 0}
    }
    
    if {$midi(remove_voice)} {set exec_out [remove_voice_fields $exec_out 0]}
    if {$midi(remove_backslashes)} {set exec_out [remove_backslashes $exec_out 0]}
    condense_whole_rest $exec_out $type
    switch -- $action {
        display {display_tunes_thru_x_tmp $midi(abc_default_file)}
        edit    {tcl_abc_edit $midi(abc_default_file) 1}
        save    {set_abc_save
            file rename -force $midi(abc_default_file) $midi(abc_save)}
    }
    update_console_page
}

startup_progress "loading bar align functions"



#Part 20.0             Bar Alignment


# bar_align.tcl
#The procedures attempt to line up the bar lines and music
#
# The abc tune is stored in the text structure
# $abctxtw. which is scanned and modified by
# bar_align.
#
# Important variables:
# music_start, numbars and linebar are arrays
# indexed by the line number in the text structure.
# numbars stores the number of barlines or | in each line
# linebar stores a list of the position of barlines for each line
# music_start indicates the position where the music begins
# ignoring | , |: or |[.
#
# Algorithm:
# -We scan $abctxtw locating the bar lines and
# begining of music for each abc line.
# -We find the maximum amount the music is indented
# far all  the abc text lines and then indent
# all the music lines by this amount.
# Going left to right we start aligning the bar
# lines for all the music. i.e. We line up the
# first bar line for all the music, then the second
# bar line etc. We can only shift a bar line to
# right by adding blanks just before the bar line.
# Whenever we insert spaces in the abc line
# all the bar lines in linebar get shifted so
# we need update the linebar list.
#
proc bar_align {} {
    global music_start numbars linebar
    global abctxtw
    set keypat {[^|: ]}
    set index [$abctxtw index "end -1 char"]
    set lines [lindex [split $index .] 0]
    # for each line count number of bars, store their position and
    # find start of music notes or chords indications
    for {set line 1} {$line < $lines} {incr line} {
        set nbars 0
        set barloc ""
        set loc [$abctxtw search "|" $line.0 $line.end]
        set firstsym [$abctxtw search -regexp $keypat $line.0 $line.end]
        set firstsym [lindex [split $firstsym .] 1]
        while {[llength $loc] > 0} {
            set barpos [lindex [split $loc .] 1]
            if {$barpos > $firstsym} {
                set barloc [concat $barloc $barpos]
                incr nbars
            }
            set loc [$abctxtw search "|" "$loc+1 chars" $line.end]
        }
        set linebar($line) $barloc
        set music_start($line) $firstsym
        set numbars($line) $nbars
    }
    # Now indent all music so they start on the same column
    set maxindent [music_indent $lines]
    indent_music $lines $maxindent
    # Get the position where we shall align the first barline
    # for all lines
    set align_pos [next_bar_pos $lines]
    # Now loop as long as we have bar lines to align
    while {$align_pos > 0} {
        align_next_bar $lines $align_pos
        remove_next_bar $lines
        set align_pos [next_bar_pos $lines]
    }
}

proc music_indent {lines} {
    # determines the number of spaces to indent the music
    global music_start numbars
    set maxindent 0
    for {set line 1} {$line < $lines} {incr line} {
        if {$numbars($line) > 0} {
            if {$music_start($line) > $maxindent} {set maxindent $music_start($line)}
        }
    }
    return $maxindent
}


proc indent_music {lines numchar} {
    # indent the music by numchar spaces
    global numbars music_start linebar
    global abctxtw
    for {set line 1} {$line < $lines} {incr line} {
        if {$numbars($line) > 0} {
            set numblanks [expr $numchar - $music_start($line)]
            if {$numblanks > 0} {
                set pos $line.$music_start($line)
                $abctxtw insert $pos [string repeat " " $numblanks]
                set linebar($line) [add_num_to_list $numblanks $linebar($line)]
            }
        }
    }
}

proc add_num_to_list {num numlist} {
    set newlist {}
    foreach val $numlist {
        set val [expr $num+$val]
        set newlist [concat $newlist $val]
    }
    return $newlist
}

proc next_bar_pos {lines} {
    # Finds the maximum of the first entry of all
    # the lists.
    global numbars linebar
    set maxloc 0
    for {set line 1} {$line < $lines} {incr line} {
        if {$numbars($line) > 0} {
            set loc [lindex $linebar($line) 0]
            if {$loc > $maxloc} {set maxloc $loc}
        }
    }
    return $maxloc
}

proc align_next_bar {lines bar_align_pos} {
    # Insert spaces in each abc line before the barline
    # if necessary for aligning.
    global numbars linebar
    global abctxtw
    for {set line 1} {$line < $lines} {incr line} {
        if {$numbars($line) > 0} {
            set loc [lindex $linebar($line) 0]
            set loc1 [expr $loc -1]
            if {[$abctxtw get $line.$loc1] == ":"} {set loc $loc1}
            if {$loc < $bar_align_pos} {
                set numblanks [expr  $bar_align_pos -$loc]
                set pos $line.$loc
                $abctxtw insert $pos [string repeat " " $numblanks]
                set linebar($line) [add_num_to_list $numblanks $linebar($line)]
            }
        }
    }
}

proc remove_next_bar {lines} {
    # Removes the first entry from a list.
    global numbars linebar
    for {set line 1} {$line < $lines} {incr line} {
        if {$numbars($line) > 0} {
            incr numbars($line) -1
            set linebar($line) [lreplace $linebar($line) 0 0]
        }
    }
}

proc bar_squeeze {} {
    global abctxtw
    set pat "\[ \]+"
    set index [$abctxtw index "end -1 char"]
    set lines [lindex [split $index .] 0]
    # for each line replace multiple spaces with single space
    for {set line 1} {$line < $lines} {incr line} {
        set value [$abctxtw get $line.0 $line.end]
        regsub -all $pat $value " " result
        $abctxtw delete $line.0 $line.end
        $abctxtw insert $line.0 $result
    }
    tag_text $abctxtw
}


# Part 21.0           Console Page Support Functions

#source warning.tcl

proc update_console_page {} {
    global exec_out
    if {[winfo exist .notice]} {show_console_page $exec_out char}
}

proc show_console_page {text wrapmode} {
    global active_sheet df
    #remove_old_sheet
    set p .notice
    set pat1 {Error in line-char ([0-9]+)\-([0-9]+)}
    set pat2 {Warning in line-char ([0-9]+)\-([0-9]+)}
    if [winfo exist .notice] {
        $p.t configure -state normal -font $df
        $p.t delete 1.0 end
        set taglist [$p.t tag names]
        foreach t $taglist {$p.t tag delete $t}
    } else {
        toplevel $p
        text $p.t -height 15 -width 50 -wrap $wrapmode -font $df -yscrollcommand {
            .notice.ysbar set}
        scrollbar $p.ysbar -orient vertical -command {.notice.t yview}
        pack $p.ysbar -side right -fill y -in $p
        pack $p.t -in $p -expand true -fill both
    }
    $p.t tag configure grey -background grey80
    set textlist [split $text \n]
    set lkount 1
    foreach textline $textlist {
        set ln 0
        set r [regexp $pat1 $textline result ln charpos]
        set r [regexp $pat2 $textline result ln charpos]
        if {$ln} {
            $p.t tag configure m$lkount -foreground darkblue
            $p.t insert end $textline\n m$lkount
            $p.t tag bind m$lkount <1> "highlight_line $lkount $ln $charpos"
        } else {
            $p.t insert end $textline\n
        }
        incr lkount
    }
    #$p.t configure -state disabled
    #set active_sheet notice
    #pack $p
    raise $p .
}

proc show_data_page {text wrapmode clean}  {
    global df
    #remove_old_sheet
    set p .data_info
    if [winfo exist $p] {
        $p.t configure -state normal -font $df
        $p.t delete 1.0 end
    } else {
        toplevel $p
	position_window ".data_info"
        text $p.t -height 20 -width 70 -wrap $wrapmode -font $df -yscrollcommand {
            .data_info.ysbar set}
        scrollbar $p.ysbar -orient vertical -command {.data_info.t yview}
        pack $p.ysbar -side right -fill y -in $p
        pack $p.t -in $p -expand true -fill both
        button $p.clean -text cleanup -font $df -command cleanup
    }
     
    if {$clean == 1} {pack $p.clean
    } else {pack forget $p.clean}

    $p.t tag configure grey -background grey80
    set textlist [split $text \n]
    set lkount 1
    foreach textline $textlist {
        set ln 0
        if {$ln} {
            $p.t insert end $textline\n m$lkount
        } else {
            $p.t insert end $textline\n
        }
        incr lkount
    }
    raise $p .
}

proc highlight_line {line1 line2 charpos} {
    .notice.t tag remove grey 0.0 end
    .notice.t tag  add grey $line1.0 $line1.end
    highlight_xtmp_line $line2 $charpos
}

proc highlight_xtmp_line {line charpos} {
    global tmp_clock console_clock
    set rightshift [expr int(log10($line))]
    set charpos [expr $charpos + $rightshift +3]
    set charpos2 [expr $charpos+1]
    if {[winfo exist .tmpfile] == 0\
                || $tmp_clock != $console_clock} show_tmpfile
    .tmpfile.t tag remove grey 0.0 end
    .tmpfile.t tag remove red 0.0 end
    .tmpfile.t tag add grey $line.0 $line.end
    .tmpfile.t tag add red $line.$charpos $line.$charpos2
    set viewline [expr $line -5]
    if {$viewline < 1} {set $viewline 1}
    .tmpfile.t yview $viewline
    set tmp_clock $console_clock
}

proc show_processed_tune {} {
    set showhandle [open X.tmp r]
    set processed_tune [read $showhandle]
    show_data_page $processed_tune char 0
    close $showhandle
}

proc show_bar_line_alignment {} {
    global midi
    global exec_out
    global cmd
    set tracklabel {NOTES WORDS NOTEWORDS GCHORD DRUMS DRONE};
    set sel [title_selected]
    set sel [tune2Xtmp $sel $midi(abc_open)]
    set cmd "exec [list $midi(path_abc2midi)]  X.tmp"
    append cmd " -c"
    catch {eval $cmd} exec_out
    update_console_page

    if {![file exist barloc.txt]} {show_message_page "you need abc2midi version 4.19 or higher" word
     return}
    set barlochandle [open barloc.txt r]
    set line " "
    set maxbars 0
    set vc {}
    set ty {}

    while {![eof $barlochandle]} {
      set line [gets $barlochandle]
      set r [scan $line "track = %d voice = %d type = %d number of bars = %d" trk v t nbars] 
      lappend vc $v
      lappend ty $t
      if {$nbars > $maxbars} {set maxbars $nbars}
      if {$r == 4} {set trackbars$trk ""}
      set nlines [expr 1 + $nbars/8]
      for {set i 0} {$i < $nlines} {incr i} {
        set line [gets $barlochandle]
	set line [string map {" " ""} $line]
	set line [string trimright $line \t]
	set data [split $line "\t"]
	append trackbars$trk " $data"
        }
      if {[eof $barlochandle]} break
      }
    close $barlochandle

    set textout "track"
    for {set i 0} {$i <= $trk} {incr i} {append textout "\t$i"}
    append textout "\nvoice"
    for {set i 0} {$i <= $trk} {incr i} {append textout "\t[lindex $vc $i]"}
    append textout "\ntype"
    for {set i 0} {$i <= $trk} {incr i} {append textout "\t[lindex $tracklabel [lindex $ty $i]]"}
    append textout "\n"

    for {set j 0} {$j <$maxbars} {incr j} {
      append textout $j
      for {set i 0} {$i <= $trk} {incr i} {
          append textout \t
          append textout [lindex [set trackbars$i] $j]
          }
      append textout "\n"
      }

      show_data_page $textout char 0
}



proc dirhome {} {
set textout ""
set filelist [glob *]
append textout "\trunabc_home\n\n"
set filedata {}
foreach filename $filelist {
	file stat $filename filestats
	lappend filedata [list $filename $filestats(mtime)]
         }
set sorted [lsort -index 1 -decreasing $filedata]
foreach item $sorted {
	append textout [lindex $item 0]
	append textout \t\t
	set t [clock format [lindex $item 1]]
	append textout $t
	append textout \n
        }
show_data_page $textout char 1
#puts $filedata
}

proc cleanup {} {
set filelist [glob *]
foreach item $filelist {
  set ext [file extension $item]
  switch $ext {
	  .pgm -
	  .svg -
	  .mid -
	  .xhtml { file delete $item}
  }
 if {$item == "interleave.abc"} {file delete $item}
 if {$item == "edit.abc"} {file delete $item}
 if {$item == "match.abc"} {file delete $item}
 if {$item == "barloc.txt"} {file delete $item}
 if {$item == "runabc.out"} {file delete $item}
 }
 dirhome
}


set hlp_internals "Internals\n\n\

The menu buttons on this page provide additional insight on how this program\
runs.\n\n\ The messages command, opens a window which shows the communications\
between this program and other executables. The information in this\
window is automatically updated whenever you take an action like creating\
and displaying a midi file, or creating a music score and displaying it.\
Error messages and warnings returned by these executables are shown in\
this window.\n\n\
Processed tune shows the contents of the abc file that is sent to one\
of the executables. The processed tune may contain additional comments\
which are recognized by the execuable. For example, comments specifying\
the midi programs to be assigned to the various voices are typically\
added when you play the abc tune.\n\n\
Bar line alignment is a new feature which is still experimental. If there\
is a loss of synchronization between the voices, the number of beats\
versus bar lines may not match across the different voices. This\
information is shown is a separate window.\n\n\
Abc2midi produces a temporary midi file (ex X2.mid) when you play any tune. This\
file is stored in runabc_home folder. As a convenience, you can view\
a text representation of the file using mftext of the output processed\
file. These temporary midi files disappear or replaced each time you\
you play a tune. The contents of these windows are not automatically\
refreshed; so you need to click on this menu button again.
"

# end of source.tcl


# Part 22.0           Midi2abc interface


startup_progress "loading midi2abc interface"

#source midi2abcimport.tcl

#midi2abc parameters

proc midi2abc_defaults {} {
    global midi
    set midi(midichannels) ""
    set midi(unitval) ""
    set midi(anaval) ""
    set midi(tsigval) ""
    set midi(ksigval) ""
    set midi(anamethod) 0
    set midi(unitmethod) 2
    set midi(chan_method) 1
    set midi(tsig_method) 2
    set midi(ksig_method) 1
    set midi(save_shorts) 0
    set midi(no_triplets) 0
    set midi(interleave) 0
    set midi(midibpl) 1
    set midi(midibps) 4
    set midi(midippu) 2
    set midi(midilden) 0
    set midi(midirest) 0
    set midi(splits) 0
    show_midi2abc_settings
}

proc setmidistart {} {
global midi
global beat1entry
if {[string length $beat1entry] < 1} return
if {[string is integer $beat1entry] == 1} {
   set midi(beat1) $beat1entry}
}

proc setmidiend {} {
global midi
global beat2entry
if {[string length $beat2entry] < 1} return
if {[string is integer $beat2entry] == 1} {
   set midi(beat2) $beat2entry}
}

# interface
global beat1entry
global beat2entry
set beat1entry $midi(beat1)
set beat2entry $midi(beat2)
set p .midi2abc
frame $p

set p .midi2abc.file
frame $p -relief ridge -borderwidth 2
label $p.fileinlab -text  "input midi file" -font $df
label $p.fileoutlab -text "output abc file" -font $df
button $p.fileinbr -text "browse" -command {set midi(midifilein) [midi_file_browser]} -font $df
button $p.fileoutbr -text "browse" -command save_browser -font $df
entry $p.fileinent -width 35 -textvariable midi(midifilein) -font $df
bind $p.fileinent <Return> {focus .midi2abc.file.fileinlab
                            update_midi_summary}
entry $p.fileoutent -width 35 -textvariable midi(midifileout) -font $df
bind $p.fileoutent <Return> {focus .midi2abc.file.fileoutlab}
.midi2abc.file.fileinent xview moveto 1.0
grid $p.fileinlab -sticky w
grid $p.fileinent -row 0 -column 1 -columnspan 3  -sticky w
grid $p.fileinbr -row 0 -column 4 -sticky w
grid $p.fileoutlab -sticky w
grid $p.fileoutent -row 1 -column 1 -columnspan 3  -sticky w
grid $p.fileoutbr -row 1 -column 4 -sticky w
pack .midi2abc.file

set p .midi2abc.0
frame $p
set p .midi2abc.1
frame $p
set p .midi2abc.1.unitmenu
menubutton $p -text "unit length" -relief raised -menu $p.type \
        -direction right -width 14  -font $df
menu $p.type -tearoff 0
$p.type add command -label "from entry box"  \
        -command {unit_cmd 1} -font $df
$p.type add command -label "from midi file"  \
        -command {unit_cmd 2} -font $df
$p.type add command -label "by minimizing quantization error"  \
        -command {unit_cmd 3} -font $df
$p.type add command -label "from tempo in entry box" \
        -command {unit_cmd 4} -font $df
$p.type add command -label "from expected bars in entry box" \
        -command {unit_cmd 5} -font $df


frame  .midi2abc.2
set p .midi2abc.2.anacrusis
menubutton $p -text "anacrusis" -relief raised -menu $p.type \
        -direction right -width 14  -font $df
menu $p.type -tearoff 0
$p.type add command -label "no anacrusis"  -command {anacrusis_cmd 0}\
        -font $df
$p.type add command -label "from entry box"  -command {anacrusis_cmd 1}\
        -font $df
$p.type add command -label "by minimizing tied notes" \
        -command {anacrusis_cmd 2} -font $df
$p.type add command -label "by finding strong beat"  \
        -command {anacrusis_cmd 3} -font $df

frame .midi2abc.3
set p .midi2abc.3.keysig
menubutton $p -text "key signature" -relief raised -menu $p.type \
        -direction right -width 14 -font $df
menu $p.type -tearoff 0
$p.type add command -label "from midi file"\
        -command {keysig_cmd 1} -font $df
$p.type add command -label "minimize accidentals" \
        -command {keysig_cmd 2} -font $df
$p.type add cascade -menu $p.type.sig  \
        -label "key signature" -font $df
menu $p.type.sig -tearoff 0
set keysiglist {"7# C# A#m" "6# F# D#m" "5# B G#m" "4# E C#m" \
            "3# A f#m" "2# D Bm" "# G Em" "C Am" "b F Dm" "2b Bb Gm" \
            "3b Eb Cm" "4b Ab F#" "5b Db Bbm" "6b Gb Ebm" "7b Cb Abm"}
set i3 0
foreach item $keysiglist {
    $p.type.sig add command -label $item \
            -command "keysig_select $i3" -font $df
    incr i3
}



frame .midi2abc.4
set p .midi2abc.4.timesig
menubutton $p -text "time signature" -relief raised -menu $p.type \
        -direction right -width 14 -font $df
menu $p.type -tearoff 0
$p.type add command -label "from entry box" \
        -command {timesig_cmd 1} -font $df
$p.type add command -label "extracted from midi file" \
        -command {timesig_cmd 2} -font $df

frame .midi2abc.5
set p .midi2abc.5.channel
menubutton $p -text "channel" -relief raised -menu $p.type \
        -direction right -width 14  -font $df
menu $p.type -tearoff 0
$p.type add command -label "all channels" \
        -command {channel_cmd 1} -font $df
$p.type add command -label "selected channel" \
        -command {channel_cmd 2} -font $df

frame .midi2abc.10
set p .midi2abc.10.tracks
menubutton $p -text "track" -relief raised -menu $p.type \
        -direction right -width 14  -font $df
menu $p.type -tearoff 0
$p.type add command -label "all tracks" \
        -command {track_cmd 1} -font $df
$p.type add command -label "selected tracks" \
        -command {track_cmd 2} -font $df

frame .midi2abc.11
set p .midi2abc.11.beats
menubutton $p -text "region" -relief raised -menu $p.type \
        -direction right -width 14  -font $df
menu $p.type -tearoff 0
$p.type add command -label "entire file" \
        -command {beat_cmd 1} -font $df
$p.type add command -label "selected section in quarter notes" \
        -command {beat_cmd 2} -font $df

frame .midi2abc.6
checkbutton .midi2abc.6.short -text "save short notes"\
        -variable midi(save_shorts) -font $df -command disable_playabc
checkbutton .midi2abc.6.triplets -text "no triplets"\
        -variable midi(no_triplets) -font $df -command disable_playabc
checkbutton .midi2abc.6.group -text "no grouping"\
        -variable midi(no_grouping) -font $df -command disable_playabc
checkbutton .midi2abc.6.lyric -text "no lyrics"\
        -variable midi(no_lyrics) -font $df -command disable_playabc


set p .midi2abc.1
label $p.unitlab -width 28  -anchor w
entry $p.unitent -width 6 -textvariable midi(unitval) -font $df
bind $p.unitent <Return> {focus .midi2abc.1.unitlab}
pack  $p.unitmenu $p.unitlab $p.unitent -side left -anchor w
pack $p -side top -anchor w


set p .midi2abc.2
label $p.analab -width 28  -anchor w
$p.analab configure
entry $p.anaent -width 6 -textvariable midi(anaval) -font $df
bind $p.anaent <Return> {focus .midi2abc.2.analab}
pack  $p.anacrusis $p.analab $p.anaent -side left -anchor w
pack $p -side top -anchor w

set p .midi2abc.3
label $p.keysiglab  -width 28 -anchor w
label $p.keysigsel -width 9
pack $p.keysig $p.keysiglab $p.keysigsel -side left -anchor w
pack $p -side top -anchor w


set p .midi2abc.4
label $p.timsiglab -width 28 -anchor w
entry $p.timsigent -width 6 -textvariable midi(tsigval) -font $df
bind $p.timsigent <Return> {focus .midi2abc.4.timsiglab}
pack $p.timesig $p.timsiglab $p.timsigent -side left -anchor w
pack $p -side top -anchor w

set p .midi2abc.5
label $p.chanlab -width 28 -anchor w
entry $p.chanent -width 14 -textvariable midi(midichannels) -font $df
bind $p.chanent <Return> {focus .midi2abc.5.chanlab}
pack $p.channel $p.chanlab $p.chanent -side left -anchor w
pack .midi2abc.5 -side top -anchor w

set p .midi2abc.10
label $p.trklab -width 28 -anchor w
entry $p.trkent -width 14 -textvariable midi(miditracks) -font $df
bind $p.trkent <Return> {focus .midi2abc.10.trklab}
pack $p.tracks $p.trklab $p.trkent -side left -anchor w
pack .midi2abc.10 -side top -anchor w

set p .midi2abc.11
label $p.beatlab -width 28 -anchor w
entry $p.beatent1 -width 6 -textvariable beat1entry -font $df
entry $p.beatent2 -width 6 -textvariable beat2entry -font $df
bind $p.beatent1 <Return> {focus .midi2abc.11.beatlab}
bind $p.beatent2 <Return> {focus .midi2abc.11.beatlab}
bind $p.beatent1 <KeyRelease> {setmidistart}
bind $p.beatent2 <KeyRelease> {setmidiend}
pack $p.beats $p.beatlab $p.beatent1 $p.beatent2 -side left -anchor w
pack .midi2abc.11 -side top -anchor w

pack .midi2abc.6.short .midi2abc.6.triplets .midi2abc.6.group\
        .midi2abc.6.lyric -side left -anchor w
pack .midi2abc.6 -side top -anchor w

set p .midi2abc.7
frame $p
label $p.bpllab -text "bars per line" -font $df
entry $p.bplent -textvariable midi(midibpl) -width 2 -font $df
bind $p.bplent <Return> {focus .midi2abc.7.bpllab}
label $p.bpslab -text "bars per staff" -font $df
entry $p.bpsent -textvariable midi(midibps) -width 2 -font $df
bind $p.bpsent <Return> {focus .midi2abc.7.bpslab}
pack $p.bpllab $p.bplent $p.bpslab $p.bpsent \
        -side left -anchor w
pack $p -side top -anchor w

set p .midi2abc.8
frame $p
label $p.ppulab -text "parts/unit" -font $df
entry $p.ppuent -textvariable midi(midippu) -width 2 -font $df
bind $p.ppuent <Return> {focus .midi2abc.8.ppulab}
label $p.ldenlab -text "L: denominator" -font $df
entry $p.ldenent -textvariable midi(midilden) -width 2 -font $df
bind $p.ldenent <Return> {focus .midi2abc.8.ldenlab}
label $p.minrestlab -text "minimum rest" -font $df
entry $p.minrestent -textvariable midi(midirest) -width 2 -font $df
bind $p.minrestent <Return> {focus .midi2abc.8.minrestlab}
pack $p.ppulab $p.ppuent $p.ldenlab $p.ldenent $p.minrestlab\
        $p.minrestent  -side left -anchor w
pack $p -side top -anchor w

set p .midi2abc.9
frame $p
radiobutton $p.nosplits -text "no splits" -value 0 -font $df -variable midi(splits) -command disable_playabc
radiobutton $p.voicesplits -text "voice splits" -value 2 -font $df -variable midi(splits) -command disable_playabc
pack $p.nosplits $p.voicesplits -side left -anchor w
pack $p -side top -anchor w

set p .midi2abc.last
frame $p
button $p.go -text "midi2abc" -font $df -command run_midi2abc
button $p.default -text "defaults" -font $df -command midi2abc_defaults
button $p.playorig -text "play orig" -font $df -command play_original_midi
button $p.playabc -text "play abc" -font $df -command play_generated_abc
button $p.display -text "display" -font $df \
        -command  {set ps_numb_start 0
            display_tunes [list $midi(midifileout)]
            update_console_page}
menubutton $p.edit -text "edit" -font $df -menu $p.edit.items
menu $p.edit.items -tearoff 0
$p.edit.items add command -label TclAbcEditor -command {midi2abc_tcl_abc_edit 1} -font $df
$p.edit.items add command -label TclMultiVoiceEditor -command {midi2abc_tcl_abc_edit 0} -font $df
$p.edit.items add command -label Editor -command {abc_edit midi(midifileout)} -font $df
$p.edit.items add command -label "Big Editor" -command big_create_abc_file -font $df

pack $p.go $p.default $p.playorig $p.playabc $p.display $p.edit  -side left -anchor w
pack $p -side top -anchor w

proc disable_playabc {} {
    .midi2abc.last.playabc configure -state disabled
    .midi2abc.last.display configure -state disabled
    .midi2abc.last.edit configure -state disabled
    .midi2abc.last.playorig configure -state disabled
}

proc anacrusis_cmd {sel} {
    global midi df
    disable_playabc
    switch -- $sel {
        0 {.midi2abc.2.analab configure -text "none" -font $df
            .midi2abc.2.anaent configure -state disable
            set midi(anamethod) 0
            set midi(anaval) ""
            update}
        1 {.midi2abc.2.analab configure -text "in units from entry box" -font $df
            .midi2abc.2.anaent configure -state normal
            set midi(anamethod) 1}
        2 {.midi2abc.2.analab configure -text "by minimizing tied notes" -font $df
            .midi2abc.2.anaent configure -state disable
            set midi(anamethod) 2}
        3 {.midi2abc.2.analab configure -text "by locating the strong beat" -font $df
            .midi2abc.2.anaent configure -state disable
            set midi(anamethod) 3}
    }
}

proc unit_cmd {sel} {
    global midi df
    switch -- $sel {
        1 {.midi2abc.1.unitlab configure -text "from entry box" -font $df
            .midi2abc.1.unitent configure -state normal
            set midi(unitmethod) 1}
        2 {.midi2abc.1.unitlab configure -text "from midi file" -font $df
            .midi2abc.1.unitent configure -state disable
            set midi(unitmethod) 2
            set midi(unitval) ""}
        3 {.midi2abc.1.unitlab configure -text "by minimizing quantization error"\
                    -font $df
            .midi2abc.1.unitent configure -state disable
            set midi(unitmethod) 3
            set midi(unitval) ""
        }
        4 {.midi2abc.1.unitlab configure -text "from tempo in entry box" -font $df
            .midi2abc.1.unitent configure -state normal
            set midi(unitmethod) 4
            set midi(unitval) ""
        }
        5 {.midi2abc.1.unitlab configure -text "from expected bars in entry box"\
                    -font $df
            .midi2abc.1.unitent configure -state normal
            set midi(unitmethod) 5
            set midi(unitval) ""
        }
    }
    disable_playabc
}

proc keysig_cmd {sel} {
    global keysiglist
    global midi df
    switch -- $sel {
        1 {.midi2abc.3.keysiglab configure -text "from midi file" -font $df
            set midi(ksig_method) 1
            .midi2abc.3.keysigsel configure -text ""
        }
        2 {.midi2abc.3.keysiglab configure -text "by minimizing accidentals" -font $df
            set midi(ksig_method) 2
            .midi2abc.3.keysigsel configure -text ""
        }
        3 {set sel [expr 7 - $midi(ksigval)]
            .midi2abc.3.keysiglab configure -text "specified key" -font $df
            .midi2abc.3.keysigsel configure -text [lindex $keysiglist $sel] -font $df
        }
    }
    disable_playabc
}

proc keysig_select {sel} {
    global keysiglist
    global midi df
    set midi(ksig_method) 3
    set midi(ksigval) [expr 7 - $sel]
    .midi2abc.3.keysigsel configure -text [lindex $keysiglist $sel] -font $df
    .midi2abc.3.keysiglab configure -text "specified key" -font $df
    disable_playabc
}

proc timesig_cmd {sel} {
    global midi df
    switch -- $sel {
        1 {.midi2abc.4.timsiglab configure -text "from entry box" -font $df
            .midi2abc.4.timsigent configure -state normal
            set midi(tsig_method) 1}
        2 {.midi2abc.4.timsiglab configure -text "extracted from midi file" -font $df
            .midi2abc.4.timsigent configure -state disable
            set midi(tsig_method) 2
            set midi(tsigval) ""
            update}
    }
    disable_playabc
}

proc midisummary_deselect {} {
if {![winfo exist .msummary]} return
set indices [.msummary.data.tree selection]
if {[llength $indices] == 0} return
.msummary.data.tree selection remove $indices
}

proc channel_cmd {sel} {
    global midi df
    switch -- $sel {
        1 {.midi2abc.5.chanlab configure -text "all channels" -font $df
            .midi2abc.5.chanent configure -state disable
            set midi(chan_method) 1
	    #midisummary_deselect 
            set midi(midichannels) ""
          }
        2 {.midi2abc.5.chanlab configure -text "selected channel in entry box" -font $df
            .midi2abc.5.chanent configure -state normal
            set midi(chan_method) 2
        }
    }
    disable_playabc
}

proc track_cmd {sel} {
    global midi df
    switch -- $sel {
        1 {.midi2abc.10.trklab configure -text "all tracks" -font $df
            .midi2abc.10.trkent configure -state disable
            set midi(trk_method) 1
	    #midisummary_deselect 
            set midi(miditracks) ""}
        2 {.midi2abc.10.trklab configure -text "selected tracks in entry box" -font $df
            .midi2abc.10.trkent configure -state normal
            set midi(trk_method) 2
        }
    }
    disable_playabc
    .midi2abc.last.playorig configure -state disabled
}

proc update_displayed_pdf_windows_for_summary {} {
if {[winfo exists .notegram]} {
   notegram_plot
   }
if {[winfo exists .pitchpdf]} {
   midi_statistics pitch
   plotmidi_pitch_pdf
   }
if {[winfo exists .pitchclass]} {
   midi_statistics pitch
   show_note_distribution
   }
if {[winfo exists .velocitypdf]} {
   midi_statistics velocity
   plotmidi_velocity_pdf
   }
if {[winfo exists .onsetpdf]} {
   midi_statistics onset
   plotmidi_onset_pdf
   }
if {[winfo exists .durpdf]} {
   midi_statistics duration
   plotmidi_duration_pdf
   }
}

proc beat_cmd {sel} {
    global midi df
    switch -- $sel {
        1 {.midi2abc.11.beatlab configure -text "entire file" -font $df
            set midi(beat_method) 1
            set midi(beat1) 0
            set midi(beat2) 0
            .midi2abc.11.beatent1 configure -state disable
            .midi2abc.11.beatent2 configure -state disable
            }
        2 {.midi2abc.11.beatlab configure -text "quarter note limits" -font $df
            .midi2abc.11.beatent1 configure -state normal
            .midi2abc.11.beatent2 configure -state normal
            set midi(beat_method) 2
        }
    }
    disable_playabc
    update_displayed_pdf_windows_for_summary 
}


proc show_midi2abc_settings {} {
    global midi
    set midi(beat_method) 1
    set midi(chan_method) 1
    set midi(trk_method) 1
    anacrusis_cmd $midi(anamethod)
    unit_cmd $midi(unitmethod)
    timesig_cmd $midi(tsig_method)
    keysig_cmd $midi(ksig_method)
    channel_cmd $midi(chan_method)
    track_cmd $midi(trk_method)
    beat_cmd $midi(beat_method)
}


proc show_midi2abc_page {} {
    global active_sheet midi
    remove_old_sheet
    if {$active_sheet == "midi2abc"} {
        set active_sheet none
    }  else {
        pack .midi2abc -side left
        set active_sheet midi2abc
    }
}


#check input parameters

proc unit_input {} {
    global midi midi2abc_options
    switch -- $midi(unitmethod) {
        1 {if {[string length $midi(unitval)] > 0} {
                set midi2abc_options \
                        [concat $midi2abc_options "-u $midi(unitval)"]} else {
                show_message_page "You need to enter unit length in the midimenu/midi2abc \
                        entry box or else change unit length option to `from midi file'.\n" word
                return 1
            }
        }
        3 {set midi2abc_options [concat $midi2abc_options -gu]}
        4 {if {[string length $midi(unitval)] > 0} {
                set midi2abc_options \
                        [concat $midi2abc_options "-Q $midi(unitval)"]} else {
                show_message_page "You need to enter estimated tempo in the \
                        midimenu/midi2abc entry box\n" word
                return 1
            }
        }
        5 {if {[string length $midi(unitval)] > 0} {
                set midi2abc_options \
                        [concat $midi2abc_options "-b $midi(unitval)"]} else {
                show_message_page "You need to enter expected number of bars \
                        in the midimenu/midi2abc entry box\n" word
                return 1
            }
        }
    }
    return 0
}


proc anacrusis_input {} {
    global midi midi2abc_options
    switch -- $midi(anamethod) {
        1  {if {[string length $midi(anaval)] > 0} {
                set midi2abc_options \
                        [concat $midi2abc_options "-a $midi(anaval)"]} else {
                show_message_page "You need to enter the number of units for anacrusis \
                        in the midimenu/midi2abc entry box\n" word
                return 1
            }
        }
        2  {set midi2abc_options [concat $midi2abc_options "-xa"]}
        3  {set midi2abc_options [concat $midi2abc_options "-ga"]}
    }
    return 0
}


proc timesig_input {} {
    global midi midi2abc_options
    switch -- $midi(tsig_method) {
        1 {if {[string length $midi(tsigval)] > 0} {
                set midi2abc_options \
                        [concat $midi2abc_options "-m $midi(tsigval)"]} else {
                show_message_page "You need to enter the time signature in the \
                        midimenu/midi2abc entry box\n" word
                return 1
            }
        }
    }
    return 0
}


proc keysig_input {} {
    global midi midi2abc_options
    if {$midi(ksig_method) == 3} {
        set midi2abc_options \
                [concat $midi2abc_options "-k $midi(ksigval)"]}
    if {$midi(ksig_method) == 2} {
        set midi2abc_options \
                [concat $midi2abc_options "-gk"]}
    return 0
}


proc channel_input {} {
    global midi midi2abc_options
    if {$midi(chan_method) == 2} {
        if {[string length $midi(midichannels)] > 0} {
            set midi2abc_options [concat $midi2abc_options "-c $midi(midichannels)"]} else {
            show_message_page "You need to enter the channel in the \
                    midimenu/midi2abc entry box\n" word
            return 1}
    }
    return 0
}

proc fileeq {pathmidi pathopen} {
    # determines whether pathnames reference the same file
    if {[file exist $pathopen] == 0} {return 1}
    if {[file exist $pathmidi] == 0} {return 0}
    file stat $pathopen stat1
    file stat $pathmidi stat2
    expr $stat1(ino) == $stat2(ino) && \
            $stat1(dev) == $stat2(dev)
}

proc powerof2 {num max} {
    set n 1
    for {set i 0} {$i < 8} {incr i} {
        if {$n == $num} {return 1}
        set n [expr $n*2]
        if {$n > $max} break;
    }
    return 0
}

proc check_midi2abc_options {filein onebpl} {
# if onebpl = 1, then this procedure is called from
# big_create_abc_file and output must be one bar per line
# and output goes to stdout instead of midi(midifileout).
    global midi midi2abc_options
    global abc_file_mod
    if {[file exists $filein] == 0} {
        puts "$filein was not found"
        show_message_page "Unable to open input file $filein. Select one using \
                the browse button on the top.\n" word
        return 1}
    if {[string length $midi(midifileout)] < 1} {
        show_message_page "You need to specify an output abc file.\n" word
        return 1
    }
    if {[powerof2 $midi(midippu) 8] == 0} {
        show_message_page "parts/unit must be a power of 2 less than 16 and greater than zero.\n" word
        return 1
    }
    if {$midi(midilden) != 0 && [powerof2 $midi(midilden) 32] == 0} {
        show_message_page "L: denominator must be a power of 2 less than 64.\n" word
        return 1
    }
    set midi2abc_options "-f [list $filein]"
    set midi2abc_options [concat $midi2abc_options]
    if {[unit_input] > 0} {return 1}
    if {[anacrusis_input] > 0} {return 1}
    if {[timesig_input] > 0} {return 1}
    if {[keysig_input] > 0} {return 1}
    #if {[channel_input] > 0} {return 1} midicopy does the job now
    if {$midi(midirest)>0} {set midi2abc_options \
                [concat $midi2abc_options "-sr $midi(midirest)"]}
    if {$midi(midilden) != 0} {set midi2abc_options \
                [concat $midi2abc_options "-aul $midi(midilden)"]}
    if {$midi(save_shorts)} {set midi2abc_options \
                [concat $midi2abc_options "-s"]}
    if {$midi(no_triplets)} {set midi2abc_options \
                [concat $midi2abc_options "-nt"]}
    if {$midi(no_grouping)} {set midi2abc_options \
                [concat $midi2abc_options "-nogr"]}
    if {$midi(no_lyrics)} {set midi2abc_options \
                [concat $midi2abc_options "-noly"]}
    if {$midi(splits) == 1} {set midi2abc_options \
                [concat $midi2abc_options "-splitbars"]}
    if {$midi(splits) == 2} {set midi2abc_options \
                [concat $midi2abc_options "-splitvoices"]}
    if {$midi(midibpl) > 16 || $midi(midibpl) < 1} {set midi(midibpl) 1}
    if {$midi(midibps) > 16 || $midi(midibps) < 1} {set midi(midibps) 4}
    if {$onebpl == 0} {set midi2abc_options [concat $midi2abc_options "-bpl $midi(midibpl)"]}
    set midi2abc_options [concat $midi2abc_options "-bps $midi(midibps)"]
    if {$onebpl == 0} {set midi2abc_options [concat $midi2abc_options "-sum -o $midi(midifileout)"]}
    if {[fileeq $midi(midifileout) $midi(abc_open)]} {
        set abc_file_mod 1
        #   puts "abc_file_mod set by check_midi_options"
    }
    return 0
}


proc save_browser {} {
    global midi types
    set filedir [file dirname $midi(midifileout)]
    set savefile [tk_getSaveFile -initialdir $filedir -filetypes $types]
    if {[string length $savefile] > 0} {set midi(midifileout) $savefile}
    disable_playabc
}


proc midi2abc_tcl_abc_edit {opt} {
    global midi
    global barpickerflag
    global runabcpath
    set barpickerflag [expr 1 - $opt]
    #encoding system $midi(encoder)
    #file rename -force $midi(abc_default_file) $outfile
    #puts "renamed file to $outfile"
    if {$opt} {
        tcl_abc_edit $midi(midifileout) $opt
    } else {
        tcl_abc_edit_with_voices $midi(midifileout) $opt
    }
    .abcedit.func.file.actions entryconfigure 3 -state disable
}


proc midi_file_browser {} {
    # contains Bob Sheskey's Windows 95 fix for double click problem
    # i.e. wm withdraw .. destroy .temp
    # comp.lang.tcl 1997/12/07
    #
    global midi tcl_platform
    global active_sheet
    global miditype
    set filedir [file dirname $midi(midifilein)]
    set str "Windows 95"
    set os $tcl_platform(os)
    if {[string compare $os $str] == 0} {
        wm withdraw [toplevel .temp]
        grab .temp}
    set openfile [tk_getOpenFile -initialdir $filedir \
            -filetypes $miditype]
    if {[string length $openfile] < 1} {
	    return $midi(midifilein)}
    if {[string compare $os $str] == 0} {
        update
        destroy .temp
    }
    
    if {[string length $openfile] > 0} {
        set midi(midifilein) $openfile
        .midi2abc.file.fileinent xview moveto 1.0
	update_midi_summary
    }
    disable_playabc
    return $openfile
}


proc copy_midi_to_tmp {newlimits} {
    global midi
    global exec_out
    global beat1entry
    global beat2entry
    global fbeat
    global tbeat


    if {[winfo exist .piano.can] && $newlimits == 1} {midi_limits}
    set fbeat $midi(beat1)
    set tbeat $midi(beat2)
    set beat1entry $midi(beat1)
    set beat2entry $midi(beat2)

    if {$fbeat > $tbeat} {
	    set tmp $fbeat
	    set fbeat $tbeat
	    set tbeat $tmp
    }


    if {$midi(chan_method) == 2 && [string length $midi(midichannels)] > 0} {
       set cmd "exec [list $midi(path_midicopy)] -chns $midi(midichannels) "
    } elseif {$midi(trk_method) == 2 && [string length $midi(miditracks)] > 0} {
       set cmd "exec [list $midi(path_midicopy)] -trks $midi(miditracks) "
    } else {
       set cmd "exec [list $midi(path_midicopy)]" 
    }
    if {$midi(beat_method) == 2} {
       append cmd " -frombeat $fbeat -tobeat $tbeat"
       }
    append cmd " [list $midi(midifilein)] tmp.mid"
    catch {eval $cmd} midicopyresult
    set exec_out "$cmd\n $midicopyresult\n"
    #puts $exec_out
    return $midicopyresult
}


proc run_midi2abc {} {
    global midi
    global exec_out
    global midi2abc_options
    global barpickerflag
    set title  "\"from $midi(midifilein)\""

    check_midi2abc_and_midicopy_versions 

    set exec_out ""
    copy_midi_to_tmp 1

    set err [check_midi2abc_options tmp.mid 0]
    append midi2abc_options " -title $title"
    set cmd "exec [list $midi(path_midi2abc)] $midi2abc_options"
    #eval $cmd
    catch {eval $cmd} midi2abcresult
    set exec_out $exec_out\n$cmd\n\n$midi2abcresult
    .midi2abc.last.playabc configure -state normal
    .midi2abc.last.display configure -state normal
    .midi2abc.last.edit configure -state normal
    .midi2abc.last.playorig configure -state normal
    set barpickerflag 0
    # do not update console page as it will obscure error
    # messages returned by check_midi2abc_options.
    }

proc play_midi_file {name} {
    global midi
    global exec_out
    #set exec_out ""
    switch -- $midi(player) {
        0  {
        set cmd "exec [list $midi(path_midiplayer_1)] $midi(midiplayer_1_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
        1  { 
        set cmd "exec [list $midi(path_midiplayer_2)] $midi(midiplayer_2_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
	2  {
        set cmd "exec [list $midi(path_midiplayer_3)] $midi(midiplayer_3_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
        3  {
        set cmd "exec [list $midi(path_midiplayer_4)] $midi(midiplayer_4_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
    }

    set cmd [concat $cmd &]
    eval $cmd
    set exec_out $exec_out\n\n$cmd
    update_console_page
}

proc play_original_midi {} {
    global midi
    #play_midi_file $midi(midifilein)
    play_midi_file tmp.mid
}


proc play_generated_abc {} {
    global midi
    global exec_out
    set exec_out ""
    set cmd "exec [list $midi(path_abc2midi)] [list $midi(midifileout)] \
            -o tmp.mid"
    if {$midi(nogchords) == 1} {append cmd " -NGUI"}
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    catch {eval $cmd} exec_out1
    set exec_out1 $cmd\n\n$exec_out1
    puts "play_generated_abc"
    set console_clock [clock seconds]
    set cmd "file delete [glob -nocomplain X*.mid]"
    set name tmp.mid
    catch {eval $cmd}

    switch -- $midi(player) {
        0  {
        set cmd "exec [list $midi(path_midiplayer_1)] $midi(midiplayer_1_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
        1  { 
        set cmd "exec [list $midi(path_midiplayer_2)] $midi(midiplayer_2_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
	2  {
        set cmd "exec [list $midi(path_midiplayer_3)] $midi(midiplayer_3_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
	3  {
        set cmd "exec [list $midi(path_midiplayer_4)] $midi(midiplayer_4_options) "
        set cmd [concat $cmd [file join [pwd] $name] ]
        }
    }
    
    set cmd [concat $cmd &]
    catch {eval $cmd} exec_out
    set exec_out $cmd\n$exec_out
    set exec_out $exec_out1\n\n$exec_out
    update_console_page
}


set hlp_midi2abc "Midi2abc\n\n\
        
The menu buttons on this page are used to control the manner by which \
        midi2abc computes the unit length, anacrusis, key signature and other \
        important characteristics of the abc file.  By default the program \
        uses the options which produce the best results with the least user \
        input. If the results are not satisfactory, it may be necessary \
        to fiddle around with these run time parameters. Here is a brief \
        description of some of these options.\n\n\
        
Unit length: midi2abc quantizes the MIDI time units into quantum\
        units usually corresponding to 1/16 or 1/32 notes. The number\
        of MIDI units corresponding to a quantum unit is specified here\
        and corresponds to the xunit parameter in midi2abc.  If the midi file was \
        created using music notation software, this length is already contained \
        in the headers of the midi file so it is unnecessary to specify it.\
        This is the case for almost all MIDI files available on the Web.\
        On the other hand, you may have recorded the midi file\
        from a midi instrument and the header information may\
        not be entirely relevant. The midi2abc program offers several alternatives\
        for estimating the conversion factor from MIDI time units to\
        quantum units as described below.\n\n\
        from entry box: You enter the length of the standard unit in the\
        entry box. This unit is referred to as xunit which displayed each\
        time you run midi2abc.(You view this information by clicking\
        the internals/messages button after clicking midi2abc.)  Typically xunit is\
        somewhere between 32 and 128.\
        Large unit lengths produces a score with many short notes while small\
        unit lengths produce a score with longer notes.\n\n\
        from midi file: the current default. The unit length is extracted from\
        the information in the midi header file and time signature indication\
        in this file.\n\n\
        by minimization quantization error. Midi2abc tries out different unit\
        lengths withen a certain range and chooses the one that produces the\
        least quantization error.\n\n\
        from tempo in entry box. This refers to the tempo that you think the\
        midi file is playing at. Changing its value will not change the actual\
        tempo of the output, (there is another way to do this from the midi option\
        property sheet). However, changing its value will tell midi2abc what \
        time duration corresponds to a beat (usually a quarter note).\n\n\
        from expected bars in entry box. You tell midi2abc how many measures\
        you expect in the output. Note that these last two methods may not work\
        well if the midi file has more than one tempo indication.\n\n
Anacrusis: a lot of music does not begin with a complete measure, but\
        instead has several leading notes. Midi2abc provides two methods for\
        computing the anacrusis, or else you can specify this yourself. The\
        anacrusis is specified in terms of quantum units.\n\n\
        Many midi files indicate the time signature or key signature; however,\
        there may be reasons for which you may have to specify it or change\
        it.\n\n\
        Advanced features; Some midi files have short rests between all notes\
        in order to improve the articulation. Though preserving these rests\
        results in a more accurate representation of the midi file, this results\
        in a very messy abc file as well as music notation display which is\
        hard to read. You can eliminate these short rests by specifying\
        a minimum rest specified in number of quantum units.\
        If the minimum rest is 0, nothing is done. For larger values,\
        those rests are absorbed into the preceding notes. (In other\
        words the preceding note is larger to include the rest.)\n\n\
        Notes shorter than the quantum unit are usually ignored by\
        midi2abc. This sometimes poses problems for percussion instruments\
        which assign a minimum duration for such notes. You may preserve\
        them by ticking save shorts check box. In this case the short notes\
        are expanded to the basic quantum unit\n\n\
        Midi2abc creates an abc file with the\
        voices all separate. This may be difficult to edit. As an option,\
        you may request runabc to interleave the voices.\n\n\
        Midi2abc by default chooses the L: unit length based on the\
        time signature (either 1/8 or 1/16). The quantum unit by default\
        is one half of this unit. Later versions of midi2abc allow you to\
        override these defaults. The options parts/unit and L: denominator\
        allow you to change these options. These specified values\
        must be powers of 2 (2,4,8,16 etc.). These features are not\
        fully tested.\n\n\
        Most chords are homomorphic, i.e. all the notes in the chord\
        are the same length and share a common onset. Polyphonic music,\
        in particular keyboard music does not share this characteristic\
        and notes in chords may begin at any time and end at any time.\
        If these notes are in the same voice, this poses an awkward\
        problem in abc notation. Midi2abc addresses this problem by\
        breaking such chords into tied chords where some notes in\
        the chords are tied to the adjacent chord. This leads to a\
        bloated abc file which is difficult to edit and read.\
        Voice splits is a new features which\
        provides an alternative way of handling polyphonic music.\
        If voice splits is selected, an entire voice may be split into\
       	several voices to avoid polyphonic chords.\n\n\
	As a convenience there is a certain level of integration\
       	with the pianoroll and midisummary windows. Changing the\
       	selected tracks or channels in either windows will affect\
       	the corresponding parameters in the midi2abc view.\
	In the case of the pianoroll window limits, the change may\
       	only occur when you click the play selected tracks\
       	(channels) button.
        "

show_midi2abc_settings
#end source midi2abcimport.tcl



# Part 23.0         Voice Support Functions for midi2abc


#source voiceproc.tcl

proc extract_all_voices {tunes abcfile} {
    
    # The function separates the voice information and
    # puts it into a global array called voicedata. The
    # index of this array addresses the separate lists
    # of voice information.
    # This function is not very smart (for example it
    # does not handle inline voices commands or voice
    # indications in the header. It only works with the
    # output of midi2abc.
    global fileseek midi
    global voicedata
    global outhandle
    
    array unset voicedata
    set pat {V:([0-9])}
    set edithandle [open [list $abcfile] r]
    set sel [lindex $tunes 0]
    set loc $fileseek($sel)
    seek $edithandle $loc
    set line [find_X_code $edithandle]
    puts $outhandle $line
    set vappend 0
    
    while {[string length $line] > 0 } {
        if {$midi(blank_lines)} {
            set line  [get_nonblank_line $edithandle]} else {
            set line  [get_next_line $edithandle]}
        if {[string index $line 0] == "X"} break;
        # search for voice id
        if {[regexp $pat $line result sub]} {
            if {![info exist voicedata($sub)]} {
                set voicedata($sub) ""}
            set vappend 1
            continue}
        if {$vappend} {
            set voicedata($sub) $voicedata($sub)$line\n
        } else {
            puts $outhandle $line}
    }
    
    
    close $edithandle
}



proc getnonblank_bar {id} {
    global voicedata voicelen voiceind
    # There may blank entries in the voicedata list that
    # we do not want to retrieve.
    set bar ""
    while {[string length $bar] < 2} {
        set bar [lindex $voicedata($id) $voiceind($id)]
        incr voiceind($id)
        if {$voiceind($id) >= $voicelen($id)} break;
    }
    return $bar
}



proc interleave_voices {} {
    # once all the voicedata has been separated, we
    # output the data interleaving each voice
    global voicedata voicelen voiceind
    global outhandle
    set ids [array names voicedata]
    set ids [lsort $ids]
    set maxlen 0
    
    foreach id $ids {
        set voicedata($id) [split $voicedata($id) \n]
        set voicelen($id) [llength $voicedata($id)]
        set voiceind($id) 0
        if {$voicelen($id) > $maxlen} {set maxlen $voicelen($id)}
    }
    set remainingbars 1
    set barcount 0
    while {$remainingbars} {
        set min_index 10000
        foreach id $ids {
            set bar [getnonblank_bar $id]
            if {[string index $bar 0] == "%"} {
                puts $outhandle "V:$id"
                puts $outhandle $bar
                while {[string index $bar 0] == "%"} {
                    set bar [getnonblank_bar $id]
                    if {[string index $bar 0] != "%"} {
                        incr voiceind($id) -1
                        break
                    }
                    puts $outhandle $bar
                }
            } elseif {[string compare -length 2 $bar "K:"] ==0 ||\
                        [string compare -length 2 $bar "L:"] ==0 ||\
                        [string compare -length 2 $bar "M:"] ==0} {
                puts $outhandle V:$id\n$bar
            } else {
                if {$bar != ""} {puts $outhandle "\[V:$id\] $bar"}
            }
            if {$min_index > $voiceind($id)} {set min_index $voiceind($id)}
        }
        if {$min_index >= $maxlen} {set remainingbars 0}
    }
    #foreach id $ids {
    # puts "$id $voiceind($id) $voicelen($id)"
    # }
}


proc abc_voice_interleave {} {
    global midi
    global outhandle
    global abc_file_mod
    set outhandle [open X.tmp w]
    set sel [title_selected]
    extract_all_voices $sel $midi(midifileout)
    interleave_voices
    close $outhandle
    file rename -force [list $midi(midifileout)] interleave.abc
    file rename -force X.tmp [list $midi(midifileout)]
    if {[fileeq $midi(midifileout) $midi(abc_open)]} {
        set abc_file_mod 1
        #   puts "abc_file_mod set by abc_voice_interleave"
    }
}

#end of source voiceproc.tcl


# Part 24.0  Chord substitution functions for Abc Editor

#source chordclean.tcl

proc replace_chord {buffer level} {
    # replaces chord eg [A2d2f2] with single note from chord
    # where level indicates note position starting from higher
    # pitch to lower pitch. This is done for all chords in
    #the input string.
    set pat {\[[^\]\[]*\]}
    set success 1
    set offset 0
    set tmp $buffer
    while {$success} {
        set success [regexp -indices $pat $tmp match]
        if {!$success} break
        set pos1 [lindex $match 0]
        set pos2 [lindex $match 1]
        set chord [string range $tmp [expr $pos1 +1] [expr $pos2 -1]]
        set tmp [string range $tmp [expr $pos2+1] end]
        set firstchar [string index $chord 0]
        set apos1 [expr $pos1 + $offset]
        set apos2 [expr $pos2 + $offset]
        #    puts "chord=$chord"
        #   ignore [1 [2 [V: [K: [M: [L
        if {[string first $firstchar "123VKML"] < 0} {
            set brokenchord [split_chord $chord]
            #    puts $brokenchord
            set note [pick_chord_note $brokenchord $level]
            #    puts "selected note $note"
            set buffer [string replace $buffer $apos1 $apos2 $note]
            set offset [expr $offset - $pos2 + $pos1 + [string length $note]]
        }
        set offset [expr $offset + $pos2]; #from replacing $tmp
        #    puts $buffer
        #    puts "tmp = $tmp"
    }
    return $buffer
}


proc notesubstitute {note} {
    set pat \[A-Ga-g|z\]
    #puts "notesubstitute $note"
    regexp -indices $pat $note indices
    set nchar [string length $note]
    set s [lindex $indices 0]
    set stripnote [string range $note $s $nchar]
    set notespace [string replace $stripnote 0 0 x]
    #puts $notespace
}

proc replace_chord_x {buffer level} {
    # The function sweeps through the buffer string replacing
    # notes with x rests and chords with one of the notes
    # in the chord (determined by level).
    
    set chordpat {\[[^\]\[]*\]}
    set notepat {(\.|M|R|T|~?)(\^*|_*|=?)([0-9]?)(/?)([0-9]?)([A-G]\,*|[a-g]\'*|z)(/?[0-9]*|[0-9]*/*[0-9])}
    set success 1
    set offset 0
    set tmp $buffer
    while {$success} {
        #   find first note or first chord in tmp string
        #    puts "tmp =$tmp"
        set success_note [regexp -indices $notepat $tmp notematch]
        set success_chord [regexp -indices $chordpat $tmp chordmatch]
        set success [expr $success_note | $success_chord]
        if {!$success} break
        
        #   which came first?
        # set match to whatever comes first -notematch or chordmatch
        if {!$success_note} {
            set match $chordmatch
            set type chord
        } elseif {!$success_chord} {
            set match $notematch
            set type note
        } elseif {[lindex $notematch 0] < [lindex $chordmatch 0]} {
            set match $notematch
            set type note
        } else {set match $chordmatch
            set type chord}
        
        #   chord match
        if {$type == "chord"} {
            set pos1 [lindex $match 0]
            set pos2 [lindex $match 1]
            set chord [string range $tmp [expr $pos1 +1] [expr $pos2 -1]]
            set tmp [string range $tmp [expr $pos2+1] end]
            set firstchar [string index $chord 0]
            set apos1 [expr $pos1 + $offset]
            set apos2 [expr $pos2 + $offset]
            #    puts "chord=$chord"
            #   ignore [1 [2 [V: [K: [M: [L
            if {[string first $firstchar "123VKML"] < 0} {
                set brokenchord [split_chord $chord]
                #    puts $brokenchord
                set note [pick_chord_note $brokenchord $level]
                #    puts "selected note $note"
                set buffer [string replace $buffer $apos1 $apos2 $note]
                set offset [expr $offset - $pos2 + $pos1 + [string length $note]]
            }
            set offset [expr $offset + $pos2]; #from replacing $tmp
            #    puts $buffer
            #    puts "tmp = $tmp"
        }
        
        if {$type == "note"} {
            set pos1 [lindex $match 0]
            set pos2 [lindex $match 1]
            #puts "pos1 pos2 $pos1 $pos2"
            set note [string range $tmp $pos1 $pos2]
            #puts "note $note"
            set tmp [string range $tmp [expr $pos2+1] end]
            set notespace [notesubstitute $note]
            set apos1 [expr $pos1 + $offset]
            set apos2 [expr $pos2 + $offset]
            #puts "offset pos1 pos2 $offset $pos1 $pos2"
            #puts "before buffer =$buffer"
            set buffer [string replace $buffer $apos1 $apos2 $notespace]
            #puts "after  buffer =$buffer"
            set offset [expr $offset + $pos1   + [string length $notespace]]
        }
        #puts $buffer
    }
    #puts $buffer
    return $buffer
}



proc split_chord {string} {
    # given a chord eg [A2c2] it returns a list {{A2 n1} {c2 n2}}
    # where n1 reflects the pitch of the note. The list is
    # sorted in order of decreasing pitch.
    set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]\'*)(/?[0-9]*|[0-9]*/*[0-9])}
    set success 1
    set tmp $string
    set notelist ""
    while {$success} {
        set success [regexp -indices $notepat $tmp match]
        if {!$success} break
        set pos1 [lindex $match 0]
        set pos2 [lindex $match 1]
        #    puts "$pos1 $pos2"
        set note [string range $tmp $pos1 $pos2]
        set priority [note2pitch $note]
        lappend notelist [list $note $priority]
        set tmp [string range $tmp [expr $pos2+1] end]
    }
    lsort -index 1 -decreasing -integer  $notelist
}

proc pick_chord_note {notelist notenumber} {
    set size [expr [llength $notelist] -1]
    #  if {$notenumber > $size} {set notenumber $size}
    if {$notenumber > $size} {return x}
    return [lindex [lindex $notelist $notenumber] 0]
}

global fullnotekey
set fullnotekey "C,D,E,F,G,A,B,C.D.E.F.G.A.B.c.d.e.f.g.a.b.c'd'e'f'g'a'b'c'"

proc note2pitch {note} {
    global fullnotekey
    set barenotepat {[A-G]\,*|[a-g]\'*}
    regexp $barenotepat $note match
    if {[string length $match] < 2} {set match $match.}
    set priority [string first $match $fullnotekey]
    #  puts "   $match $priority"
    return $priority
}

set hlp_replacechord "    Replace chord\n\n\
        This tool replaces chords, eg \[CEG\] \[DFA\] etc with one\
        of the notes in the chords, eg G A. The notes in the\
        chords are sorted by pitch. For example, if you select\
        top note, then the highest pitch note in the chord\
        replaces the chord. The program tries to avoid touching\
        anything else in the music including inline field\
        commands such as \[K: Am] or repeat part indications\
        such as \[1 or \[2, but it may not be perfect: so check\
        the results before commiting them to a file.\n\n
There are two version of this function. The first version\
        without the x just copies notes which are not inside chords.\
        The second version (with the x) replaces the note with an x\
        which acts like an invisible rest in abcm2ps.\n\n
To use this tool you must first select a region in\
        the file to operate."

#end of source chordclean.tcl




# Part 25.0           Midishow - Piano Roll


#source midishow.tcl

#global variables

# needed by show_events. switch been tracks or chan.
set pixels_per_file 2000

set trkchan 1
# flag to to separate by track or channel

set exec_out ""
#run time messages
set piano_yview_pos 0.35 ;# scroll position for piano roll display
set pianoresult {} ;# midilyze output for compute_pianoroll or get_midi_stats
#flag to cause pianoroll to be regenerated
#counter for  channel program indications in midi file

global activechan
global trksel
global highlighted_trk
global trkchan
global exec_out
global piano_yview_pos

# We initialize them to 0 to indicate
# that no tracks have been selected yet.
for {set i 0} {$i < 32} {incr i} {
    set trksel($i) 0
    update_console_page
}



proc check_midi2abc_and_midicopy_versions {} {
    global midi
    
    set result [get_version_number $midi(path_midi2abc)]
    #puts $result
    set err [scan $result "%f" ver]
    set msg "You need midi2abc.exe version 3.41 or higher"
    if {$err == 0} {return $msg}
    if {$ver < 3.41} {tk_messageBox -message $msg
	              return $msg}
    
    set result [get_version_number $midi(path_midicopy)]
    set err [scan $result "%f" ver]
    set msg "You need midicopy.exe version 1.32 or higher"
    if {$err == 0} {return $msg}
    if {$ver < 1.32} {tk_messageBox -message $msg
	              return $msg}
    return pass
}


proc trksel_to_midi {} {
global midi
global trksel
set select ""
for {set i 0} {$i < 24} {incr i} {
   if {[info exist trksel($i)]} {
     if {$trksel($i) == 1} {
        append select "$i,"	
        }
     }
   }
#remove last comma
set select [string range $select 0 end-1 ]
if {[string length $select] < 1} return
set midi(miditracks) ""
set midi(midichannels) ""
if {$midi(midishow_sep) == "track"} {
   set midi(miditracks) $select
   } else {
   set midi(midichannels) $select
   }
if {[string length $midi(miditracks)] >0} {
   .midi2abc.5.channel.type invoke 0
   .midi2abc.10.tracks.type invoke 1
   }
if {[string length $midi(midichannels)] > 0} {
   .midi2abc.5.channel.type invoke 1
   .midi2abc.10.tracks.type invoke 0
   }
}


proc piano_window {midifile} {
    global df
    global midispeed
    if {[winfo exist .piano]} {destroy .piano}
    toplevel .piano
    position_window ".piano"
    #Create top level menu bar.
    set p .piano.f
    frame $p
    
    #buttons for zooming in and zooming out
    menubutton $p.config -text config -width 8 -menu $p.config.items -font $df
    menu $p.config.items -tearoff 0
    $p.config.items add radiobutton -label "separate by track" -font $df\
            -value track -variable midi(midishow_sep) -command compute_pianoroll
    $p.config.items add radiobutton -label "separate by channel" -font $df\
            -value chan -variable midi(midishow_sep) -command compute_pianoroll
    $p.config.items add checkbutton -label "follow while playing" -font $df\
            -variable midi(midishow_follow)
    $p.config.items add command -label "ppqn adjustment" -font $df\
            -command ppqn_adjustment_window
    
    
    button $p.zoom -text zoom -relief flat -command piano_zoom -font $df
    menubutton $p.unzoom -text unzoom -width 8 -menu $p.unzoom.items -font $df
    menu $p.unzoom.items -tearoff 0
    $p.unzoom.items add command -label "Unzoom 1.5" -font $df \
            -command {piano_unzoom 1.5}
    $p.unzoom.items add command -label "Unzoom 3.0" -font $df \
            -command {piano_unzoom 3.0}
    $p.unzoom.items add command -label "Unzoom 5.0" -font $df \
            -command {piano_unzoom 5.0}
    $p.unzoom.items add command -label "Total unzoom" -command piano_total_unzoom -font $df
    
    menubutton $p.action -text action -menu $p.action.items -font $df
    menu $p.action.items -tearoff 0
    $p.action.items add command  -label "create abc file" -command create_abc_file -font $df
    $p.action.items add command  -label "display abc" -font $df \
            -command create_abc_file_and_display
    $p.action.items add command  -label "play abc" -font $df \
            -command create_abc_file_and_play
    $p.action.items add command -label "mftext" -font $df \
            -command mftext_tmp_midi
    $p.action.items add command  -label "velocity distribution" -font $df \
            -command {pianoroll_statistics velocity
                      plotmidi_velocity_pdf}
    $p.action.items add command  -label "pitch distribution" -font $df \
            -command {pianoroll_statistics pitch
                plotmidi_pitch_pdf}
    $p.action.items add command  -label "pitch class plot" -font $df \
            -command {pianoroll_statistics pitch
                show_note_distribution
                if {$midi(mode_guess) == "mse"} {
                   guess_mode_mse} else {
                guess_mode_correlation}
                }
    $p.action.items add command -label "notegram" -font $df\
            -command notegram_plot
    $p.action.items add command  -label "onset distribution" -font $df \
             -command {pianoroll_statistics onset
                       plotmidi_onset_pdf
                      }
    $p.action.items add command  -label "velocity map" -font $df \
            -command plot_velocity_map
    $p.action.items add command  -label "beat graph" -font $df \
            -command beat_graph
    $p.action.items add command  -label "unique chords" -font $df \
            -command unique_chords
    $p.action.items add command  -label "create midi" -font $df \
            -command create_abc_and_midi
    $p.action.items add command  -label "create PostScript file" -font $df \
            -command piano_window_ps_output
    $p.action.items add command -label "help" -font $df\
            -command {show_message_page $hlp_midishow_actions word}
    
    scale $p.speed -length 100 -from 0.1 -to 3.0 -orient horizontal\
 -resolution 0.05 -width 10 -variable midispeed
    set midispeed 1.0
    label $p.speedlabel -text speed -font $df
    button $p.help -text help -relief flat -font $df\
            -command {show_message_page $hlp_midishow word}
    
    grid  $p.config $p.zoom $p.unzoom $p.action $p.speedlabel $p.speed $p.help -sticky news
    grid $p -column 1
    
    set p .piano.file
    frame $p -relief ridge -borderwidth 2
    label $p.fileinlab -text  "input midi file" -font $df
    button $p.fileinbr -text "browse" -relief flat -font $df\
            -command {midi_file_browser
                show_events $midi(midifilein)}
    entry $p.fileinent -width 48 -textvariable midi(midifilein) -font $df
    $p.fileinent xview moveto 1.0
    bind $p.fileinent <Return> {focus .piano.file
        show_events $midi(midifilein)}
    grid $p.fileinlab $p.fileinent $p.fileinbr 
    grid $p -column 0 -columnspan 3
    
    
    set p .piano
    
    # create frame for displaying canvas of piano roll.
    
    scrollbar $p.hscroll -orient horiz -command [list BindXview [list $p.can\
            $p.canx]]
    scrollbar $p.vscroll -command pBindYview
    
    canvas $p.can -width 400 -height 400 -border 3 -relief sunken -scrollregion\
            {0 0 2500 500} -xscrollcommand "$p.hscroll set" -yscrollcommand\
            "$p.vscroll set" -border 3 -bg white
    canvas $p.canx -width 400 -height 20 -border 3 -relief sunken -scrollregion\
            {0 0 2500 20}
    canvas $p.cany -width 20 -height 300 -border 3 -relief sunken -scrollregion\
            {0 0 20 724}
    grid $p.cany $p.can $p.vscroll -sticky news
    grid $p.canx -sticky news -column 1
    label $p.txt -text pianoroll
    grid $p.hscroll -sticky ew -column 1
    grid $p.txt -column 1
    grid rowconfig $p 2 -weight 1 -minsize 0
    grid columnconfig $p 1 -weight 1 -minsize 0
    
    frame .piano.trkchn
    grid .piano.trkchn -columnspan 3
    
    for {set i 0} {$i < 24} {incr i} {
        checkbutton .piano.trkchn.$i -text $i -variable trksel($i) -font $df \
          -command update_displayed_pdf_windows
    }
    button .piano.trkchn.but -relief flat -padx 1 -pady 1
    pack .piano.trkchn.but -side left -anchor w
    bind .piano.trkchn.but <Button> {
        .midi2abc.11.beats.type invoke 2
        set miditime [copy_midi_to_tmp 1]
        piano_play_midi_extract
        startup_playmark_motion $miditime
    }
    
    
    bind $p.can <ButtonPress-1> {piano_Button1Press %x %y}
    bind $p.can <ButtonRelease-1> {piano_Button1Release}
    bind $p.can <Double-Button-1> piano_ClearMark
    bind $p.can <Button-3> {
	set miditime [copy_midi_to_tmp 1]
        piano_play_midi_extract
        startup_playmark_motion $miditime
    }
    set result [check_midi2abc_and_midicopy_versions]
    if {[string equal $result pass]} {show_events $midifile} else {
        .piano.txt configure -text $result -foreground red -font $df}
}

proc ppqn_adjustment_window {} {
    global df
    if {[winfo exist .ppqn]} return
    toplevel .ppqn
    position_window ".ppqn"
    button .ppqn.1 -text "increase ppqn" -font  $df -repeatdelay 500\
            -repeatinterval 50 -command {qnote_spacing_adjustment 1}
    button .ppqn.2 -text "decrease ppqn" -font $df -repeatdelay 500\
            -repeatinterval 50 -command {qnote_spacing_adjustment -1}
    button .ppqn.3 -text "+ pulse offset" -font $df -repeatdelay 500\
            -repeatinterval 50 -command {qnote_offset_adjustment 1}
    button  .ppqn.4 -text "- pulse offset" -font $df -repeatdelay 500\
            -repeatinterval 50 -command {qnote_offset_adjustment -1}
    pack .ppqn.1 .ppqn.2 .ppqn.3 .ppqn.4
}



set hlp_midishow "In order to use this tool you require midi2abc\
        version 3.02 or higher and midicopy 1.22 or higher. Be sure to\
        specify the path to midicopy in the config/abc executables page.\n\n\
        The function will display the selected MIDI file in a piano\
        roll form in a resizeable separate window.\n\n\
        Vertical lines indicate beat numbers as determined by the\
        the conversion factor PPQN (pulses per quarter note) defined in the\
        header of the MIDI file. If you place the mouse pointer on\
        any one of the MIDI notes as indicated by a black horizontal\
        arrow, this note and all other notes belonging to the same\
        track (channel) will appear in red, and the parameters of this note\
        will appear in a short text line below the scroll bar of this display.\
        If you click the right mouse button, while the notes in the\
        track are highlighted, then these notes will be sent to the\
        MIDI player you have designated. If you right click elsewhere\
        in the piano roll display, then all the displayed notes will be\
        sent to the midi player. Note that if any of these functions\
        do not seem to run correctly, you should click the console\
        button and view the messages.\n\n The program attempts to follow\
        the playing with a vertical red line based on the estimated duration\
        of the output. Due to possible latencies in the midiplayer there may\
        be some loss of synchronization for some players. Pressing any key on\
        the keyboard while the focus is on the piano canvas will stop the tracker.\
        Unfortunately, I have not found a way of stopping the midi player from\
        runabc. You can turn off the tracker from the options menu.\n\n\
	There is a speed control slider which allows you to adjust\
	the tempo of the MIDI file. You must set it prior to playing\
	the exposed music.\n\n\
        The zoom and unzoom buttons will magnify or scale down the display.\
        You can specify an area to zoom into by holding down the mouse left\
        mouse button and sweeping an area. This area will be highlighted.\
        (A double click will clear the highlighted area marker -- yellow stipple.)\
        Clicking the zoom button will zoom into the highlighted area.\
        Clicking the right mouse button while a zoom area is highlighted\
        will send only the highlighted area to the MIDI player.\n\n\
        You may configure the program to either distinguish tracks\
        or channels. It is recommended that you separate the midi notes\
        by channel rather than by tracks. A sequence of checkbuttons\
        at the bottom of the window allows you to select the particular\
        channels or tracks for playing or for further analysis using\
        the action menu. If nothing is selected then all channels/tracks\
        are processed. Hovering the mouse button on any of these\
        checkbuttons will indicate what musical instrument (program) that was\
        assigned to this channel. The notes assigned to the associated\
        channel (or track) will also be displayed in red while the\
        mouse pointer is over that checkbutton. Note that the highlighted\
        notes may not be present in the particular scrolled region of\
        the display. In the case where the program assignment was\
        changed at a later time, only the last assignment is displayed.\n\n\

        If you are creating an abc file from the displayed portion of\
        the MIDI file. The midi2abc option string is shared with the\
        midi2abc frame (obtained from midimenu/midi2abc) or a default\
        string is used if the midi2abc was not run from midi2abc window.\n\n
It is possible to shift or change the spacing of the vertical quarter\
        note line indications by selecting the config/ppqn adjustment item.\
        This temporarily changes the ppqn value of the MIDI file which\
        also affects the output of action/beat graph."

set hlp_midishow_actions "The action menu provides miscellaneous\
        functions that can be applied on the exposed temporal part of the\
        MIDI file. Many of the plots that are generated are dynamic in the\
        sense that they are updated any time exposed area is changed.\n\n\
        create abc file - will copy the exposed part of the MIDI file to\
        tmp.mid (possibly selecting specific tracks or channels) and call\
        midi2abc to make an abc file.\n\n\
        display abc  - does the above but also displays the new abc file.\n\n\
        play abc     - does the above but also plays the new abc file.\n\n\
        create midi  - creates tmp.mid and renames it to whatever you select.\n\n\
        mftext  -  creates tmp.mid and displays the midi file in mftext form.\n\n\
        velocity distribution - produces a histogram of the velocity values\
        of the notes in the exposed area and for the selected channels or\
        tracks.\n\n\
        pitch distribution - produces a histogram of the MIDI pitch values\
        for the exposed area and the selected channels (tracks).\n\n\
        pitch class plot - produces a histogram of the pitch classes for the\
        exposed area and the selected channels or tracks. \n\n\
	notegram - plots the pitch classes for the exposed area and selected\
	channels or tracks versus beat number. It is useful for detecting\
	key signature modulations.\n\n\
        onset distribution - plots a histogram of the onset time of the notes\
        inside a beat for the exposed area and the selected channels or tracks.\n\n\
        velocity map - plots the velocity of the notes versus beat number for\
        the exposed area and the selected channels or tracks.\n\n\
        beat graph - plots the onset time relative to the start of a beat\
        versus the beat number for each note. You should see horizontal lines\
        if the note onset times follow exact musical positions in a measure.\n\n\
        unique chords - lists a histogram of all the distinct chords.\n\n\
        create PostScript file - produces a PostScript file called piano.ps showing\
        the visible portion of the piano roll."



#        Support functions

proc piano_Button1Press {x y} {
    set xc [.piano.can canvasx $x]
    .piano.can raise mark
    .piano.can coords mark $xc 0 $xc 720
    bind .piano.can <Motion> { piano_Button1Motion %x }
    update_piano_txt $x $y
}

proc piano_Button1Motion {x} {
    set xc [.piano.can canvasx $x]
    if {$xc < 0} { set xc 0 }
    set co [.piano.can coords mark]
    .piano.can coords mark [lindex $co 0] 0 $xc 720
}

proc piano_Button1Release {} {
    bind .piano.can <Motion> {}
    set co [.piano.can coords mark]
}

proc piano_ClearMark {} {
    .piano.can coords mark -1 -1 -1 -1
}



# for handling x scrolling of piano roll
proc BindXview {lists args} {
    foreach l $lists {
        eval {$l xview} $args
    }
    update_displayed_pdf_windows
}

# for handling y scrolling of piano roll
proc pBindYview {args} {
    global piano_yview_pos
    eval .piano.can yview $args
    eval .piano.cany yview $args
    set piano_yview_pos [lindex [.piano.can yview] 0]
}







proc unpack_mthd_header {} {
    # read binary header block of midi file to get
    # format type and number of tracks. Saves having
    # to call a C program.
    global mthd_header id mlen mformat ntrk ppqn trkchan
    binary scan $mthd_header a4ISSS id mlen mformat ntrk ppqn
    set trkchan $mformat
}


proc read_midifile_header {openfile} {
    global ntrk
    global ppqn
    global midihandle
    global mthd_header
    global mlen mformat ppqn
    global piano_qnote_offset
    if {[string length $openfile] > 0} {
        set midihandle [open $openfile r]
    }
    fconfigure $midihandle -translation binary
    set mthd_header [read $midihandle 14]
    unpack_mthd_header
    close $midihandle
    set piano_qnote_offset 0
}


# This procedure is associated with the piano roll button.
# It calls the midi2abc executable to do most of the work.
proc show_events {midifile} {
    global midi trkchan
    global trk
    global pianoresult
    global midilength
    global piano_yview_pos
    global exec_out
    global pixels_per_file
    global df
    focus .
    
    
    #puts "show_events: $midifile"
    if {[file exist $midifile] == 0} {
        .piano.txt configure -text "can't open file $midifile"\
                -foreground red -font $df
        puts "show_events cannot open $midifile"
        return
    }
    
    read_midifile_header $midifile; # read midi header
    
    set exec_options "[list $midifile] -midigram"
    
    set cmd "exec [list $midi(path_midi2abc)] $exec_options"
    #    puts $cmd
    catch {eval $cmd} pianoresult
    if {[string first "no such" $pianoresult] >= 0} {abcmidi_no_such_error $midi(path_midi2abc)}
    set exec_out show_events:\n$cmd\n\n$pianoresult
    # required if pianoroll called from midisummary
    if {$midifile == "tmp.mid"} {
	    relabel_track_numbers}
    set nrec [llength $pianoresult]
    set midilength [lindex $pianoresult [expr $nrec -1]]
    if {[string is integer $midilength] != 1} {
        .piano.txt configure -text "$midilength ??"
        return
    }
    
    set pixels_per_file 2000
    compute_pianoroll
    .piano.can yview moveto $piano_yview_pos
    .piano.cany yview moveto $piano_yview_pos
    piano_horizontal_scroll 0
    update_console_page
}


#horizontal zoom of piano roll
proc piano_zoom {} {
    global pixels_per_file
    set co [.piano.can coords mark]
    set zoomregion [expr [lindex $co 2] - [lindex $co 0]]
    set displayregion [winfo width .piano.can]
    set scrollregion [.piano.can cget -scrollregion]
    if {$zoomregion > 5} {
        set mag [expr $displayregion/$zoomregion]
        set pixels_per_file [expr $pixels_per_file*$mag]
        compute_pianoroll
        set xv [expr double([lindex $co 0])/double([lindex $scrollregion 2])]
        piano_horizontal_scroll $xv
    } else {
        set pixels_per_file [expr $pixels_per_file*1.5]
        if {$pixels_per_file > 250000} {
            set $pixels_per_file 250000}
        set xv [lindex [.piano.can xview] 0]
        compute_pianoroll
        piano_horizontal_scroll $xv
    }
    update_displayed_pdf_windows
}


proc piano_unzoom {factor} {
    global pixels_per_file
    set pixels_per_file [expr $pixels_per_file /$factor]
    set xv [.piano.can xview]
    set xvl [lindex $xv 0]
    set xvr [lindex $xv 1]
    set growth [expr ($factor - 1.0)*($xvr - $xvl)]
    set xvl [expr $xvl - $growth/2.0]
    if {$xvl < 0.0} {set xv 0.0}
    #set xv [expr $xv/$factor]
    compute_pianoroll
    piano_horizontal_scroll $xvl
    update_displayed_pdf_windows
}

proc piano_total_unzoom {} {
    global pixels_per_file
    set displayregion [winfo width .piano.can]
    # subract 12 to allow for growth of bounding box of .piano.can
    set pixels_per_file [expr $displayregion -12]
    compute_pianoroll
    .piano.can configure -scrollregion [.piano.can bbox all]
    update_displayed_pdf_windows
}

proc adjust_vert_spacing {vspace} {
# make vspace either 1,2,5 or 10 times suitable power of 10
  set pow 0
  while {$vspace > 10.0} {
    incr pow
    set vspace [expr $vspace/10.0]
    }
  if {$vspace > 7.0} {set vspace 10.0
   } elseif {$vspace > 3.0} {set vspace 5.0
   } elseif {$vspace > 1.4} {set vspace 2.0
   } else {set vspace 1.0}
  while {$pow > 0} {
   incr pow -1
   set vspace [expr $vspace * 10]
   }
 set vspace [expr int($vspace)]
 return $vspace
 }

proc relabel_track_numbers {} {
# needed for tmp.mid created by copy_midi_to_tmp
# changes sequential track numbers to selected tracknumbers
global pianoresult
global midi
set newtracks [split $midi(miditracks) ,]
if {[llength $newtracks] < 1} return
puts "relabel_track_numbers $newtracks"
set newpianoresult ""
  foreach line [split $pianoresult \n] {
    if {[llength $line] != 6} {
      append newpianoresult $line\n
    } else {
      set newline $line
      set t [lindex $line 2]
      set t [expr $t -1]
      set new_t [lindex $newtracks $t]
      set newline [lreplace $line 2 2 $new_t]
      append newpianoresult $newline\n
      }
  }
set pianoresult $newpianoresult
}


# procedure for drawing on the piano roll canvas.
proc compute_pianoroll {} {
    global midi
    global midilength
    global pixels_per_file
    global pianoresult pianoxscale
    global activechan
    global ppqn
    global piano_vert_lines
    global chanprog
    global track2channel
    global df

    #set midi(beat_method) 2
    
    if {[array exist track2channel]} {unset track2channel}
    
    if {[llength $pianoresult] < 1} {
        return
    }
    
    
    set p .piano
    set pianoxscale [expr ($midilength / double($pixels_per_file))]
    
    set qnspacing  [expr $pixels_per_file*$ppqn/double($midilength)]
    #set piano_vert_lines [expr round(40/$qnspacing)]
    set piano_vert_lines [expr 40.0/$qnspacing]
    set piano_vert_lines [adjust_vert_spacing $piano_vert_lines]
    if {$piano_vert_lines <1} {set piano_vert_lines 1}
    
    set xvright [expr round($midilength/$pianoxscale)]
    $p.can delete all
    
    $p.can create rect -1 -1 -1 -1 -tags mark -fill yellow -stipple gray25
    #      -width 1 -outline red
    
    if [info exist activechan] {
        unset activechan
    }
    for {set i 0} {$i <89} {incr i} {
        set j [expr ($i+8)%12]
        switch -- $j {
            1 -
            3 -
            6 -
            8 -
            10 {
                $p.can create rectangle 0 [expr 724-$i*8] $xvright\
                        [expr 716-$i*8] -fill gray80 -outline ""
            }
            default {
                $p.can create rectangle 0 [expr 724-$i*8] $xvright\
                        [expr 716-$i*8] -fill white -outline ""
            }
        }
        if {$j == 0} {
            set octave [expr $i/12 + 1]
            set legend [format "C%d" $octave]
            $p.cany create text 10 [expr 724-$i*8] -text $legend
        }
        if {$j == 5} {
            set octave [expr $i/12 + 1]
            set legend [format "F%d" $octave]
            $p.cany create text 10 [expr 724-$i*8] -text $legend
        }
    }
    .piano.txt configure -text "" -foreground Black
    
    piano_qnotelines
    
    foreach line [split $pianoresult \n] {

        if {[string match [lindex $line 1] "Program"]} {
          set chanprog([lindex $line 2]) [lindex $line 3]
        } elseif {[string match [lindex $line 0] "Header"]} {
          set midifiletype [lindex $line 1]
          #set miditracks [lindex $line 2]
          .piano.txt configure -text [format "midi file type %d" $midifiletype] -foreground Black -font $df
        }
        if {$midifiletype == 0} {set midi(midishow_sep) "chan"} 
       	if {[llength $line] != 6} continue

        set begin [lindex $line 0]
        if {[string is double $begin] != 1} continue
        set end [lindex $line 1]
        set t [lindex $line 2]
        set c [lindex $line 3]
        set track2channel($t) $c
        if {$midi(midishow_sep) == "track"} {set sep $t} else {set sep $c}
        set note [lindex $line 4]
        set ix1 [expr $begin/$pianoxscale]
        set ix2 [expr $end/$pianoxscale]
        set iy [expr 720 - ($note-20)*8]
        $p.can create line $ix1 $iy $ix2 $iy -width 2 -tag trk$sep -arrow last\
                -arrowshape {2 2 2}
        set activechan($sep) 1
    }
    bind_tracks
    set bounding_box [$p.can bbox all]
    set top [lindex $bounding_box 1]
    set bot [lindex $bounding_box 3]
    
    
    
    
    set bounding_boxx [list [lindex $bounding_box 0] 0 [lindex $bounding_box\
            2] 20]
    set bounding_boxy [list 0 [lindex $bounding_box 1] 20\
            [lindex $bounding_box 3]]
    $p.can configure -scrollregion $bounding_box
    $p.canx configure -scrollregion $bounding_boxx
    $p.cany configure -scrollregion $bounding_boxy
    put_trkchan_selector
}

proc piano_qnotelines {} {
    global ppqn midilength pianoxscale piano_vert_lines
    global piano_qnote_offset vspace
    global midi
    set p .piano
    set beatoffset $midi(beat1)
    $p.canx delete all
    set bounding_box [$p.can bbox all]
    set top [lindex $bounding_box 1]
    set bot [lindex $bounding_box 3]
    $p.can delete -tag  barline
    if {$piano_vert_lines > 0} {
        set vspace [expr $ppqn*$piano_vert_lines]
        set txspace $vspace
        while {[expr $txspace/$pianoxscale] < 40} {
            set txspace [expr $txspace + $vspace]
        }
        
        
        for {set i $piano_qnote_offset} {$i < $midilength} {incr i $vspace} {
            set ix1 [expr $i/$pianoxscale]
            if {$ix1 < 0} continue
            $p.can create line $ix1 $top $ix1 $bot -width 1 -tag barline
        }
        
        for {set i $piano_qnote_offset} {$i < $midilength} {incr i $txspace} {
            set ix1 [expr $i/$pianoxscale]
            if {$ix1 < 0} continue
            $p.canx create text $ix1 5 -text [expr $beatoffset + $piano_vert_lines*int($i/$vspace)]
        }
    }
}

proc qnote_spacing_adjustment {ppqn_incr} {
    global ppqn piano_qnote_offset
    #change ppqn and adjust piano_qnote_offset so that
    #the qnote line near left edge remains almost stationary.
    set limits [midi_limits]
    set leftedge [lindex $limits 0]
    set leftedgeqnote [expr double($leftedge - $piano_qnote_offset)/$ppqn]
    incr ppqn $ppqn_incr
    set leftedgeqnote2 [expr double($leftedge - $piano_qnote_offset)/$ppqn]
    set deltaqnote [expr $leftedgeqnote2 - $leftedgeqnote]
    set offset_adjustment [expr int($deltaqnote*$ppqn)]
    incr piano_qnote_offset $offset_adjustment
    piano_qnotelines
    .piano.txt configure -text [format "ppqn = %d" $ppqn] -foreground Black
    if {[winfo exists .beatgraph]} {beat_graph}
}

proc qnote_offset_adjustment {offset} {
    global piano_qnote_offset
    incr piano_qnote_offset $offset
    piano_qnotelines
    if {[winfo exists .beatgraph]} {beat_graph}
}

proc put_trkchan_selector {} {
    global activechan midi chanprog progtranslator df
   if {$midi(midishow_sep)=="track"} {
        .piano.trkchn.but configure -text "play selected tracks" -font $df} else {
        .piano.trkchn.but configure -text "play selected channels" -font $df}

    for {set i 0} {$i < 24} {incr i} {
        pack forget .piano.trkchn.$i
        if {[info exist activechan($i)]} {
            pack .piano.trkchn.$i -side left -anchor w
            bind .piano.trkchn.$i <Enter> {
              set n [lindex [split %W .] 3]
              set num $n
              if {$midi(midishow_sep)=="track"} {
                 set num $track2channel($n)}
              if {$num == 10} {
                 .piano.txt configure -text "drum channel" -font $df
              } elseif {[info exist chanprog($num)]} {
                 .piano.txt configure -text $progtranslator($chanprog($num)) -font $df
              } else {
                 .piano.txt configure -text $progtranslator(0) -font $df
              }
              .piano.can itemconfigure trk$n -fill red -width 3
              } 
            bind .piano.trkchn.$i <Leave> {
              set n [lindex [split %W .] 3]
              .piano.can itemconfigure trk$n -fill black -width 2
              }
            }
    }
}





proc piano_horizontal_scroll {val} {
    .piano.can xview moveto $val
    .piano.canx xview moveto $val
}



# set binding when mouse pointer enters or leaves a note on/off bar.
proc bind_tracks {} {
    global activechan
    foreach {num} [array names activechan] {
        .piano.can bind trk$num <Enter> "highlight_track $num %x %y"
        .piano.can bind trk$num <Leave> "unhighlight_track $num"
        #puts "trk$num"
    }
}


# change color and thickness of all note on/off bar belonging to
# the track. We need different thickness when two channels (tracks)
# overlap same note and time.
proc highlight_track {num x y} {
    global highlighted_trk
    .piano.can itemconfigure trk$num -fill red -width 3
    set highlighted_trk $num
    update_piano_txt $x $y
}


proc unhighlight_track {num} {
    global highlighted_trk
    .piano.can itemconfigure trk$num -fill black -width 2
    set highlighted_trk 0
}


proc update_displayed_pdf_windows {} {
trksel_to_midi
if {[winfo exists .notegram]} {
   notegram_plot
   }
if {[winfo exists .pitchpdf]} {
   pianoroll_statistics pitch
   plotmidi_pitch_pdf
   }
if {[winfo exists .pitchclass]} {
   pianoroll_statistics pitch
   show_note_distribution
   }
if {[winfo exists .velocitypdf]} {
   pianoroll_statistics velocity
   plotmidi_velocity_pdf
   }
if {[winfo exists .onsetpdf]} {
   pianoroll_statistics onset
   plotmidi_onset_pdf
   }
}
  


proc midi_to_key {midipitch} {
    global note
    set midipitch [expr round($midipitch)]
    set octave [expr $midipitch/12 -1]
    set keyname $note([expr $midipitch % 12])
    return $keyname$octave
}


proc update_piano_txt {x y} {
    global pianoxscale ppqn
    global trkchan
    global midi
    global track2channel
    global chanprog
    global progtranslator
    focus .piano.can
    set x [.piano.can canvasx $x]
    set y [.piano.can canvasy $y]
    set pos [expr $x*$pianoxscale]
    set beat [expr $pos/$ppqn]
    set pitch [expr int(32 +(628 - $y)/8)]
    set note [midi_to_key $pitch]
    set id [.piano.can find withtag current]
    set taglist [.piano.can gettag $id]
    set trk [lindex $taglist [lsearch -glob $taglist trk*]]
    set notedata $trk

    #puts "track2channel [array names track2channel]"

    # if this is a not a note just show the position.
    if {[string length $notedata] == 0} {
      .piano.txt configure -text \
          [format "%s = %6.0f pulses = %4.0f beats" $note $pos $beat] \
          -foreground Black
       return}

    # get note information (channel/track and program)
    set num [scan $notedata trk%d]
    if {$midi(midishow_sep) == "chan"} {
        set trk [string replace $trk 0 2 chan]
       } else {
       set num $track2channel($num)
       }
    if {$num == 10} {set prog "drum channel"
       } elseif {[info exist chanprog($num)]} {
      set prog $progtranslator($chanprog($num))
       } else {set prog $progtranslator(0)
       }
    .piano.txt configure -text \
          [format "%s = %6.0f pulses = %4.0f beats %s %s" $note $pos $beat $trk $prog] \
          -foreground Black
 }


proc midi_limits {} {
    global pianoxscale
    global midi
    global ppqn
    set beatoffset $midi(beat1)
    set can .piano.can
    set co [$can coords mark]
    #   is there a marked region of reasonable extent ?
    set extent [expr [lindex $co 2] - [lindex $co 0]]
    if {$extent > 10} {
        set xvleft [lindex $co 0]
        set xvright [lindex $co 2]
    } else {
        #get start and end time of displayed area
        set xv [$can xview]
        #puts $xv
        set scrollregion [$can cget -scrollregion]
        #puts $scrollregion
        set xvleft [lindex $xv 0]
        set xvright [lindex $xv 1]
        set width [lindex $scrollregion 2]
        set xvleft [expr $xvleft*$width]
        set xvright [expr $xvright*$width]
    }
    #    puts "xvleft = $xvleft xvright=$xvright"
    
    set begin [expr round($xvleft*$pianoxscale)]
    set end [expr round($xvright*$pianoxscale)]
    if {$begin < 0} {
        set $begin 0
    }
    set midi(beat1) [expr  $begin/$ppqn]
    set midi(beat2) [expr  $end/$ppqn]
    #puts "midi_limits: $midi(beat1) $midi(beat2)"
    return [list $begin $end]
}

proc midi_limits_for_drumroll {} {
    global pianoxscale
    global midi
    global ppqn
    #set beatoffset $midi(beat1)
    set can .drumroll.can
    set co [$can coords mark]
    #   is there a marked region of reasonable extent ?
    set extent [expr [lindex $co 2] - [lindex $co 0]]
    if {$extent > 10} {
        set xvleft [lindex $co 0]
        set xvright [lindex $co 2]
    } else {
        #get start and end time of displayed area
        set xv [$can xview]
        #puts $xv
        set scrollregion [$can cget -scrollregion]
        #puts $scrollregion
        set xvleft [lindex $xv 0]
        set xvright [lindex $xv 1]
        set width [lindex $scrollregion 2]
        set xvleft [expr $xvleft*$width]
        set xvright [expr $xvright*$width]
    }
    #    puts "xvleft = $xvleft xvright=$xvright"
    
    set begin [expr round($xvleft*$pianoxscale)]
    set end [expr round($xvright*$pianoxscale)]
    if {$begin < 0} {
        set $begin 0
    }
    set midi(beat1) [expr  $begin/$ppqn]
    set midi(beat2) [expr  $end/$ppqn]
    #puts "midi_limits: $midi(beat1) $midi(beat2)"
    return [list $begin $end]
}

proc count_selected_midi_tracks {} {
    set tsel 0
    global trksel
    for {set i 0} {$i <32} {incr i} {
        if {$trksel($i)} {
            incr tsel
        }
    }
    return $tsel
}



proc midi_to_midi {sel} {
    # creates midi.tmp containing an extract from the open midi file.
    # If sel = 0, midi_to_midi was called by right clicking on the
    # piano canvas and the highlighted_trk is used to control
    # what is played. If sel = 1, then midi_to_midi was called
    # from other functions and it is controlled by the tsel array.
    #
    # Everything in the displayed time interval is copied if tsel
    # is empty or no highlight_track was set.
    
    global highlighted_trk
    global  midi
    global exec_out
    global trkchan
    global trksel
    global midi
    global midipulse_limits
    global midispeed
    
    set midipulse_limits [midi_limits]
    set begin [lindex $midipulse_limits 0]
    set end   [lindex $midipulse_limits 1]
    
    #puts "sel = $sel"
    set tsel 0
    set trkstr ""
    puts "midi_to_midi: sel = $sel"
    if {$sel} {
        #always include track 1 because it contains the tempo and other stuff
        for {set i 0} {$i <32} {incr i} {
            if {$trksel($i)} {
                if {$tsel > 0} {
                    set trkstr $trkstr,$i
                    } else {
                    set trkstr $i
                    }
                incr tsel
            }
        }
    } else {
        if {[info exist highlighted_trk] == 0} {set highlighted_trk 0}
        if {$highlighted_trk != 0} { set trkstr $highlighted_trk}
        } 

   set selvoice ""
   puts "midi_to_midi trkstr = $trkstr"
   if {[string length $trkstr] > 0} {
     puts "midi_to_midi: trkstr = $trkstr"
     if {$tsel < 1} {set selvoice ""
     } else {
       if {$midi(midishow_sep) == "track"} {
          set selvoice "-trks 1,$trkstr"
         } else {
          set selvoice "-chns $trkstr"
         }
       }
     }

   #puts "selvoice = $selvoice"

    # We first delete the old file in case winamp is still playing it.
    set cmd "file delete -force -- tmp.mid"
    catch {eval $cmd} pianoresult
        
    # create tmp.mid file
    set cmd "exec [list $midi(path_midicopy)]  $selvoice  -from $begin\
                -to $end" 
    if {$midispeed != 1.00} {lappend cmd -speed $midispeed}
    append cmd  " [list $midi(midifilein)] tmp.mid"

    #puts "cmd = $cmd"
    
    catch {eval $cmd} miditime
    #    puts $miditime
    set exec_out midi_to_midi:\n$cmd\n\n$miditime
    puts "midi_to_midi: $exec_out"
    update_console_page
    return $miditime
}

proc startup_playmark_motion {miditime} {
    global midipulse_limits
    global playtime
    global pianoplayend
    global advance_per_50ms
    global midi
    if {!$midi(midishow_follow)} return
    if {[string length $miditime] ==  0 } return
    if {![string is double $miditime]} return
    if {$miditime < 0.01} return
    set begin [lindex $midipulse_limits 0]
    set end   [lindex $midipulse_limits 1]
    set rate [expr ($end - $begin)/$miditime]
    set advance_per_50ms [expr $rate/20.0]
    #puts "startup_playmark_motion $advance_per_50ms"
    set playtime $begin
    set pianoplayend $end
    #puts "playtime $playtime playend $pianoplayend"
    .piano.can create line -1 -1 -1 -1 -fill red -tags playmark
    
    bind .piano.can  <KeyPress> stop_playmarker
    move_playmark
}



proc move_playmark {} {
    global advance_per_50ms
    global playtime
    global pianoxscale
    global pianoplayend
    set ix [expr int($playtime/$pianoxscale)]
    .piano.can coords playmark $ix 0 $ix 720
    #puts "$playtime $ix"
    set playtime [expr $playtime + $advance_per_50ms]
    if {$playtime > $pianoplayend} {
        .piano.can coords playmark -1 -1 -1 -1
        after 0
        return
    }
    after 50 move_playmark
}

proc stop_playmarker {} {
    global pianoplayend
    global playtime
    set pianoplayend $playtime
}



proc piano_play_midi_extract {} {
    global midi
    play_midi_file  [file join [pwd] tmp.mid]
}




proc create_abc_file {} {
    # This function is called by one of the action functions
    # in the midishow window.
    global midi df midi2abc_options
    global ppqn
    global exec_out
    global ps_numb_start
    set ps_numb_start 0
    copy_midi_to_tmp 1
    if {[winfo exist .ppqn]} {
        set midi(unitval) [expr $ppqn/2]
        unit_cmd 1
        set midi(midilden) 8
    }
    set err [check_midi2abc_options tmp.mid 0]
    puts "create_abc_file err = $err"
    set highlighted_trk 0 ;# the track number highlighted in piano roll view
    set cmd "exec [list $midi(path_midi2abc)] $midi2abc_options"
    eval $cmd
    catch {eval $cmd} pianoresult
    set exec_out $exec_out\n$cmd\n\n$pianoresult
    #    puts $exec_out
    if {$err == 0} {
        .piano.txt configure -text "created $midi(midifileout)" -foreground red -font $df
    } else {
        .piano.txt configure -text "unable to create $midi(midifileout)" -foreground red -font $df
    }
    update_console_page
}

proc create_abc_file_and_display {} {
    global midi
    create_abc_file
    display_tunes [list $midi(midifileout)]
}

proc create_abc_file_and_play {} {
    global midi
    create_abc_file
    play_generated_abc
}

proc create_abc_and_midi {} {
    global midi exec_out miditype
    copy_midi_to_tmp 1
    set filedir [file dirname $midi(midi_save)]
    set filename [tk_getSaveFile -initialdir $filedir -filetypes $miditype]
    file rename -force tmp.mid $filename
    set exec_out "$exec_out\nand renamed to $filename"
}

proc mftext_tmp_midi {} {
    global midi
    copy_midi_to_tmp 1
    set cmd "exec [list $midi(path_midi2abc)] tmp.mid -mftext"
    mftextwindow tmp.mid 1
}


#end of source midishow.tcl


# Part 26.0        Midi Statistics for Midishow
#source drumgram.tcl

proc active_drums {} {
    global pianoresult
    global drumpatches
    global drumstrip rdrumstrip
    global gram_ndrums
    global activedrum avgvel
   
    for {set i 35} {$i <82} {incr i} {
      set activedrum($i) 0
      set avgvel($i) 0
      }
    
    foreach line [split $pianoresult \n] {
        if {[llength $line] != 6} continue
        set c [lindex $line 3]
        if {$c != 10} continue
        set note [lindex $line 4]
        set vel [lindex $line 5]
        incr activedrum($note) 
        incr avgvel($note) $vel
    }

    set gram_ndrums 0
    for {set i 35} {$i <82} {incr i} {
      if {$activedrum($i) != 0} {
         set j [expr $i -35]
         set p [lindex $drumpatches $j]
         set drumstrip($i) $gram_ndrums
         set rdrumstrip($gram_ndrums) $i
         set avgvel($i) [expr $avgvel($i)/$activedrum($i)]
         incr gram_ndrums
         }
      }
}


proc drumroll_Button1Press {x y} {
    set xc [.drumroll.can canvasx $x]
    .drumroll.can raise mark
    .drumroll.can coords mark $xc -10 $xc 600
    bind .drumroll.can <Motion> { drumroll_Button1Motion %x }
}

proc drumroll_Button1Motion {x} {
    set xc [.drumroll.can canvasx $x]
    if {$xc < 0} { set xc 0 }
    set co [.drumroll.can coords mark]
    .drumroll.can coords mark [lindex $co 0] -10 $xc 600
}

proc drumroll_Button1Release {} {
    bind .drumroll.can <Motion> {}
    set co [.drumroll.can coords mark]
}

proc drumroll_ClearMark {} {
    .drumroll.can coords mark -1 -1 -1 -1
}


set drumrollwidth 400
                               

proc drumroll_window {} {
    global df
    global midispeed
    global drumrollwidth

    set midispeed 1.0
    if {[winfo exist .drumroll]} {destroy .drumroll}
    toplevel .drumroll
    position_window ".drumroll"
    #Create top level menu bar.
    set p .drumroll.f
    frame $p
    

    button $p.config -text config -width 8 -relief flat\
	 -command drumroll_config -font $df
    button $p.play -text play -relief flat -font $df -command play_drumroll 
    button $p.zoom -text zoom -relief flat -command drumroll_zoom -font $df
    menubutton $p.unzoom -text unzoom -width 8 -menu $p.unzoom.items -font $df
    menu $p.unzoom.items -tearoff 0
    $p.unzoom.items add command -label "Unzoom 1.5" -font $df \
            -command {drumroll_unzoom 1.5}
    $p.unzoom.items add command -label "Unzoom 3.0" -font $df \
            -command {drumroll_unzoom 3.0}
    $p.unzoom.items add command -label "Unzoom 5.0" -font $df \
            -command {drumroll_unzoom 5.0}
    $p.unzoom.items add command -label "Total unzoom" -command drumroll_total_unzoom -font $df
    
    button $p.help -text help -relief flat -font $df\
            -command {show_message_page $hlp_drumroll word}
    
    grid  $p.play $p.config $p.zoom $p.unzoom $p.help -sticky news
    grid $p -column 1
    
    set p .drumroll.file
    frame $p -relief ridge -borderwidth 2
    label $p.fileinlab -text  "input midi file" -font $df
    button $p.fileinbr -text "browse" -relief flat -font $df\
            -command {midi_file_browser
                show_drum_events}
    entry $p.fileinent -width 48 -textvariable midi(midifilein) -font $df
    $p.fileinent xview moveto 1.0
    bind $p.fileinent <Return> {focus .drumroll.file.roll
        show_drum_events}
    grid $p.fileinlab $p.fileinent $p.fileinbr 
    grid $p -column 0 -columnspan 3
    
    
    set p .drumroll
    
    # create frame for displaying canvas of drum roll.
    
    scrollbar $p.hscroll -orient horiz -command [list BindXview [list $p.can\
            $p.canx]]
    
    canvas $p.can -width $drumrollwidth -height 200 -border 3 -relief sunken -scrollregion\
            {0 0 2500 500} -xscrollcommand "$p.hscroll set" -border 3 -bg white
    canvas $p.canx -width $drumrollwidth -height 20 -border 3 -relief sunken -scrollregion\
            {0 0 2500 20}
    canvas $p.cany -width 180 -height 200 -border 3 -relief sunken -scrollregion\
            {0 0 20 200}
    label $p.speedlabel -text speed -font $df
    scale $p.speed -length 140 -from 0.1 -to 4.0 -orient horizontal\
 -resolution 0.05 -width 10 -variable midispeed
    grid $p.cany $p.can -sticky news
    grid $p.speedlabel $p.canx -sticky news
    label $p.txt -text drumgram
    grid $p.speed $p.hscroll -sticky ew
    grid $p.txt -column 1
    grid rowconfig $p 2 -weight 1 -minsize 0
    grid columnconfig $p 1 -weight 1 -minsize 0
    
    
    
    bind $p.can <ButtonPress-1> {drumroll_Button1Press %x %y}
    bind $p.can <ButtonRelease-1> {drumroll_Button1Release}
    bind $p.can <Double-Button-1> drumroll_ClearMark
  set result [check_midi2abc_and_midicopy_versions]
  if {[string equal $result pass]} {show_drum_events} else {
      .drumroll.txt configure -text $result -foreground red -font $df
      }
}

    proc drumroll_config {} {
    set p .drumrollconfig
    global df midi
    if {[winfo exist $p]} return
    toplevel $p
    position_window $p
    radiobutton $p.normal -text "play everything" -variable midi(playdrumdata) -value normaldrum -font $df
    radiobutton $p.nodrum -text "do not play the percussion lines" -variable midi(playdrumdata) -font $df -value nodrums
    radiobutton $p.onlydrum -text "play only the percussion lines" -variable midi(playdrumdata) -font $df -value onlydrums
#    radiobutton $p.focussel -text "boost selection" -variable midi(playdrumdata) -font $df -value boostdrumsel
#    checkbutton $p.mute -text "mute nondrum channels"\
# -variable midi(mutenodrum) -font $df
#    checkbutton $p.drumboost -text "set selected drum loudness"\
# -variable midi(drumvelocity) -font $df
    pack $p.normal $p.nodrum $p.onlydrum -side top -anchor w
#    pack $p.focussel $p.mute $p.drumboost -side top -anchor w

#    frame $p.muteval
#    label $p.muteval.lab -text "mute no drum level" -font $df
#    entry $p.muteval.ent -width 3 -font $df -textvariable midi(mutelev)
#    pack $p.muteval.ent $p.muteval.lab -side left 
#    pack $p.muteval -anchor w
#    frame $p.focus
#    entry $p.focus.ent -width 3 -font $df -textvariable midi(mutefocus)
#    label $p.focus.lab -text "mute focus level" -font $df
#    pack $p.focus.ent $p.focus.lab -side left
#    pack $p.focus -anchor w
#    frame $p.boost
#    entry $p.boost.ent -width 3 -font $df -textvariable midi(drumloudness)
#    label $p.boost.lab -text "selected drum loudness" -font $df
#    pack $p.boost.ent $p.boost.lab -side left
#    pack $p.boost -anchor w
#    button $p.help -text help -font $df\
#            -command {show_message_page $hlp_drumroll_config word}
#    pack $p.help -anchor w
}

set hlp_drumroll_config "Drum Roll Configuration\n\n\
The options control how the drum midi events are played.\
If the 'mute nondrum channels' is checked the regular midi\
events that are not in channel 9 are reduced in loudness to the\
level specified by in the 'mute no drum level' entry box.\
The level must be in the range of 0 and 127.\n\n\
The mute focus level refers to the playback of individual drum\
lines. It controls the maximum loudness of the nonselected drums.\
Its value must also be in the range of 0 and 127.\n\n\
The checkbox 'set selected drum loudness' also applies to\
the playback of the individual drum line. In some cases,\
even though the focus is on the individual drum line, its\
loudness may be set low in the original MIDI file.\
If the checkbox is set, then the original loudness is overriden\
and set to the specified value in the entry box 'selected\
drum loudness.
"

proc show_drum_events {} {
    global pixels_per_file
    global midi
    global pianoresult
    global df
    global exec_out
    global drumrollwidth

 if {[file exist $midi(midifilein)] == 0} {
        .drumroll.txt configure -text "can't open file $midi(midifilein)"\
                -foreground red -font $df
        return
    }
    .drumroll.txt configure -text drumgram -font $df -foreground black

    set pixels_per_file $drumrollwidth
    read_midifile_header $midi(midifilein); # read midi header

    set exec_options "[list $midi(midifilein)] -midigram"

    set cmd "exec [list $midi(path_midi2abc)] $exec_options"
    catch {eval $cmd} pianoresult
    if {[string first "no such" $pianoresult] >= 0} {abcmidi_no_such_error $midi(path_midi2abc)}
    set exec_out show_events:\n$cmd\n\n$pianoresult
    set nrec [llength $pianoresult]
    set midilength [lindex $pianoresult [expr $nrec -1]]
    if {[string is integer $midilength] != 1} {
        .drumroll.txt configure -text "$midilength ??"
        return
    }
    compute_drumroll 
}


proc drumroll_qnotelines {} {
    global ppqn midilength pianoxscale piano_vert_lines
    global piano_qnote_offset vspace
    set p .drumroll
    $p.canx delete all
    set bounding_box [$p.can bbox all]
    set top [lindex $bounding_box 1]
    set bot [lindex $bounding_box 3]
    $p.can delete -tag  barline
    if {$piano_vert_lines > 0} {
        set vspace [expr $ppqn*$piano_vert_lines]
        set txspace $vspace
        while {[expr $txspace/$pianoxscale] < 40} {
            set txspace [expr $txspace + $vspace]
        }
        
        
        for {set i $piano_qnote_offset} {$i < $midilength} {incr i $vspace} {
            set ix1 [expr $i/$pianoxscale]
            if {$ix1 < 0} continue
            $p.can create line $ix1 $top $ix1 $bot -width 1 -tag barline
        }
        
        for {set i $piano_qnote_offset} {$i < $midilength} {incr i $txspace} {
            set ix1 [expr $i/$pianoxscale]
            if {$ix1 < 0} continue
            $p.canx create text $ix1 5 -text [expr $piano_vert_lines*int($i/$vspace)]
        }
    }
}
proc compute_drumroll {} {
    global midi
    global midilength
    global pixels_per_file
    global pianoresult pianoxscale
    global activechan
    global ppqn
    global piano_vert_lines
    global drumstrip rdrumstrip
    global drumpatches
    global gram_ndrums
    global df
    global activedrum avgvel
    global drumpick

    if {[llength $pianoresult] < 1} {
        return
    }


    set nrec [llength $pianoresult]
    set midilength [lindex $pianoresult [expr $nrec -1]]
    set sep 10


    set p .drumroll
    set pianoxscale [expr ($midilength / double($pixels_per_file))]

    set qnspacing  [expr $pixels_per_file*$ppqn/double($midilength)]
    set piano_vert_lines [expr 40.0/$qnspacing]
    set piano_vert_lines [adjust_vert_spacing $piano_vert_lines]
    if {$piano_vert_lines <1} {set piano_vert_lines 1}

    $p.can delete all
    $p.cany delete all

    $p.can create rect -1 -1 -1 -1 -tags mark -fill yellow -stipple gray25

    if [info exist activechan] {
        unset activechan
    }

    active_drums

   if {$gram_ndrums < 1} {.drumroll.txt configure -text "no drum notes" \
                -foreground red -font $df}
    for {set i 0} {$i <$gram_ndrums} {incr i} {
            $p.can create line 0 [expr $i*20 +20] $pixels_per_file\
                        [expr $i*20+20]
            set jj $rdrumstrip($i)
            set j [expr $jj - 35]
            set patch [lindex [lindex $drumpatches $j] 2]
            set legend [format "%s" $patch]
            set legend "$rdrumstrip($i) $legend"
    	    if {[winfo exist $p.cany.drm$i] != 1} {
              set drumpick($i) 0
	      checkbutton $p.cany.drm$i -text $legend -variable drumpick($i) -font $df
              tooltip::tooltip $p.cany.drm$i  "$activedrum($jj) strikes\nvelocity = $avgvel($jj)"
	      } else {
             $p.cany.drm$i configure -text $legend -font $df
             $p.cany.drm$i deselect
             }
	     set item [$p.cany create window 10 [expr $i*20 + 0] -anchor nw -window $p.cany.drm$i]

        }
    set canheight [expr $gram_ndrums*20 + 10]
    $p.can configure -height $canheight
    $p.cany configure -height $canheight

    drumroll_qnotelines

    foreach line [split $pianoresult '\n'] {
        if {[llength $line] != 6} continue
        set begin [lindex $line 0]
        if {[string is double $begin] != 1} continue
        set end [lindex $line 1]
        set t [lindex $line 2]
        set c [lindex $line 3]
        if {$c != 10} continue
        set note [lindex $line 4]
        if {$note < 35 || $note > 81} continue
        set ix1 [expr $begin/$pianoxscale]
        set ix2 [expr $ix1+3]
        if {$ix2 > $pixels_per_file} {
           #puts "$begin $note $ix1 $ix2"
           continue
           }
        set iy [expr $drumstrip($note)*20 + 10]
        $p.can create line $ix1 $iy $ix2 $iy -width 8 -tag trk$sep
        set activechan($sep) 1
    }
    #bind_tracks
    set bounding_box [$p.can bbox all]
    set top [lindex $bounding_box 1]
    set bot [lindex $bounding_box 3]




    set bounding_boxx [list [lindex $bounding_box 0] 0 [lindex $bounding_box\
            2] 20]
    set bounding_boxy [list 0 [lindex $bounding_box 1] 20\
            [lindex $bounding_box 3]]
    $p.can configure -scrollregion $bounding_box
    $p.canx configure -scrollregion $bounding_boxx
    $p.cany configure -scrollregion $bounding_boxy


}

proc make_in_and_ex_lists {} {
    global gram_ndrums
    global drumpick
    global drumstrip rdrumstrip
    set includelist {}
    set excludelist {}
    for {set i 0} {$i <$gram_ndrums} {incr i} {
      set perc $rdrumstrip($i)
      if {$drumpick($i) == 0} {
              lappend excludelist $perc
      } else {
              lappend includelist $perc
      }
    }

    if {[llength $includelist] == 0} {
      # switch includelist with excludelist
      return ""
      }

    if {[llength $includelist] < [llength $excludelist]} {
       set output " -indrums "
       foreach i $includelist {
         append output "$i,"
         }
       append output " "
       return $output
       } else {
       set output " -xdrums "
       foreach i $excludelist {
         append output "$i,"
         }
       append output " "
       return $output
       }
}
           


proc drumroll_horizontal_scroll {val} {
    .drumroll.can xview moveto $val
    .drumroll.canx xview moveto $val
}

#horizontal zoom of piano roll
proc drumroll_zoom {} {
    global pixels_per_file
    set co [.drumroll.can coords mark]
    set zoomregion [expr [lindex $co 2] - [lindex $co 0]]
    set displayregion [winfo width .drumroll.can]
    set scrollregion [.drumroll.can cget -scrollregion]
    if {$zoomregion > 5} {
        set mag [expr $displayregion/$zoomregion]
        set pixels_per_file [expr $pixels_per_file*$mag]
        compute_drumroll
        set xv [expr double([lindex $co 0])/double([lindex $scrollregion 2])]
        drumroll_horizontal_scroll $xv
    } else {
        set pixels_per_file [expr $pixels_per_file*1.5]
        if {$pixels_per_file > 250000} {
            set $pixels_per_file 250000}
        set xv [lindex [.drumroll.can xview] 0]
        compute_drumroll
        drumroll_horizontal_scroll $xv
    }
}




proc drumroll_unzoom {factor} {
    global pixels_per_file
    set pixels_per_file [expr $pixels_per_file /$factor]
    set xv [.drumroll.can xview]
    set xvl [lindex $xv 0]
    set xvr [lindex $xv 1]
    set growth [expr ($factor - 1.0)*($xvr - $xvl)]
    set xvl [expr $xvl - $growth/2.0]
    if {$xvl < 0.0} {set xv 0.0}
    #set xv [expr $xv/$factor]
    compute_drumroll
    drumroll_horizontal_scroll $xvl
}

proc drumroll_total_unzoom {} {
    global pixels_per_file
    set displayregion [winfo width .drumroll.can]
#   reduce displayregion by 20 to account for expansion
#   of bounding box of .drumroll.can
    set pixels_per_file [expr $displayregion -20]
    compute_drumroll
    .drumroll.can configure -scrollregion [.drumroll.can bbox all]
}

proc play_drumroll {} {
global midi
set miditime [drum_to_midi]
piano_play_midi_extract
startup_playmark_motion $miditime
}

proc drum_to_midi  {} {
    global  midi
    global exec_out
    global midi
    global midipulse_limits
    global midispeed
    global rdrumstrip
    
    set midipulse_limits [midi_limits_for_drumroll]
    set begin [lindex $midipulse_limits 0]
    set end   [lindex $midipulse_limits 1]
    
    # We first delete the old file in case winamp is still playing it.
    set cmd "file delete -force -- tmp.mid"
    catch {eval $cmd} pianoresult

    switch $midi(playdrumdata) {
      normaldrum {
      set percsubset [make_in_and_ex_lists]
      set cmd "exec [list $midi(path_midicopy)]  -from $begin\
 -to $end $percsubset" 
      }
      onlydrums {
      set percsubset [make_in_and_ex_lists]
      set cmd "exec [list $midi(path_midicopy)]  -from $begin\
 -to $end  -onlydrums $percsubset" 
      }
      nodrums {
      set cmd "exec [list $midi(path_midicopy)]  -from $begin\
 -to $end  -nodrums " 
      }
      onlysel {
      set cmd "exec [list $midi(path_midicopy)]  -from $begin\
 -to $end  $percsubset" 
      }
      boostdrumsel {
      set cmd "exec [list $midi(path_midicopy)]  -from $begin\
 -to $end -drumfocus $rdrumstrip($drmno) $midi(mutefocus)" 
      if {$midi(mutenodrum)} {append cmd " -mutenodrum $midi(mutelev) "}
      if {$midi(drumvelocity) && $drmno != -1} {append cmd " -setdrumloudness $rdrumstrip($drmno)  $midi(drumloudness) "}
      }
    }

    if {$midispeed != 1.00} {append cmd " -speed $midispeed "}
    append cmd  "[list $midi(midifilein)] tmp.mid"
    
    catch {eval $cmd} miditime
    #    puts $miditime
    set exec_out midi_to_midi:\n$cmd\n\n$miditime
    #puts "drum_to_midi: $exec_out"
    update_console_page
    return $miditime
}

set hlp_drumroll "This tool is designed for viewing and analyzing\
midi drum sequences. The tool behaves somewhat similar to pianoroll\
but in addition labels the individual drum events.\n\n\
The percussion channel can address many percussion instruments.\
Some of these instruments may be barely audible. This interface\
allows you to hear some of these percussion instruments alone\
without competing sounds. You can select the instruments of interest\
by checking the adjacent checkbox and then clicking play.\
If you do not check any of the boxes, then all the percussion\
instruments are played.\n\n\
The manner in which the file is played can be modified using\
the config button. For example, you can play only the percussion\
channel.\n\n\
As usual you can select a specific time interval to play by\
highlighting the designated area. (You can also zoom into this\
area and see more detail.\n\n\
"



# end of source drumgram.tcl




# Part 27.0        Midi Statistics for Midishow


#source midistats.tcl


proc pianoroll_statistics {choice} {
    global pianoresult midi
    global histogram
    global ppqn
    global trksel
    global total
    global start stop
    for {set i 0} {$i < 128} {incr i} {set histogram($i) 0}
    set limits [midi_limits]
    set start [lindex $limits 0]
    set stop  [lindex $limits 1]
    set exec_out "Pitch Class Distribution\n\n"
    append exec_out "from $start to $stop\n\n"
    set tsel [count_selected_midi_tracks]
    
    foreach line [split $pianoresult \n] {
        if {[llength $line] != 6} continue
        set begin [lindex $line 0]
        if {[string is double $begin] != 1} continue
        if {$begin < $start} continue
        set end [lindex $line 1]
        if {$end   > $stop}  continue
        set t [lindex $line 2]
        set c [lindex $line 3]
        if {$midi(midishow_sep) == "track"} {set sep $t} else {set sep $c}
        if {$tsel != 0 && $trksel($sep) == 0} continue
        set note [lindex $line 4]
        set vel [lindex $line 5]
        switch $choice {
            pitch {set histogram($note) [expr $histogram($note)+1]}
            velocity {set histogram($vel) [expr $histogram($vel)+1]}
            duration {set index [expr int(($end - $begin)*32/$ppqn)]
                if {$index > 127} {set index 127}
                set histogram($index) [expr $histogram($index)+1]
            }
            onset {set s [expr int((100.0*$begin)/$ppqn) % 100]
                set histogram($s) [expr $histogram($s) + 1]
                }
        }
    }
    set total 0;
    for {set i 0} {$i <128} {incr i} {
        set total [expr $total+$histogram($i)]
    }
    #puts "total = $total"
    if {$total < 1} return
    for {set i 0} {$i <128} {incr i} {
        set histogram($i) [expr double($histogram($i))/$total]
    }
}



set plotwidth 300
set plotheight 200
set xlbx 60; # left margin of bounding box
set ytbx 10; # top margin of bounding box
set xrbx [expr $xlbx + $plotwidth]
set ybbx [expr $ytbx + $plotheight]
set scanwidth [expr $xrbx+20]
set scanheight [expr $ybbx+30]


proc plotmidi_pitch_pdf {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global histogram
    set hgraph ""
    set maxhgraph 0.0
    set statc .pitchpdf.c
    for {set i 0} {$i < 128} {incr i} {
        lappend hgraph $i
        lappend hgraph $histogram($i)
        if {$histogram($i) > $maxhgraph} {set maxhgraph $histogram($i)}
    }
    set maxhgraph [expr $maxhgraph + 0.1]
    if {[winfo exists .pitchpdf] == 0} {
        toplevel .pitchpdf
        position_window ".pitchpdf"
        pack [canvas $statc -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {
        .pitchpdf.c delete all}
    wm title .pitchpdf "probability versus midi pitch value"
    $statc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx 0.0 130 0.0 $maxhgraph
    Graph::draw_x_ticks $statc 0.0 128.0 10.0 2 0 %4.0f
    Graph::draw_y_ticks $statc 0.0 $maxhgraph 0.05 2 %3.1f
    Graph::draw_impulses_from_list .pitchpdf.c $hgraph
}

proc plotmidi_velocity_pdf {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global histogram
    set hgraph ""
    set maxhgraph 0.0
    set statc .velocitypdf.c
    for {set i 0} {$i < 128} {incr i} {
        lappend hgraph $i
        lappend hgraph $histogram($i)
        if {$histogram($i) > $maxhgraph} {set maxhgraph $histogram($i)}
    }
    set maxhgraph [expr $maxhgraph + 0.1]
    if {[winfo exists .velocitypdf] == 0} {
        toplevel .velocitypdf
        position_window ".velocitypdf"
        pack [canvas $statc -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {
        .velocitypdf.c delete all}
    wm title .velocitypdf "probability versus midi velocity"
    $statc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx 0.0 130 0.0 $maxhgraph
    Graph::draw_x_ticks $statc 0.0 128.0 10.0 2 0 %4.0f
    Graph::draw_y_ticks $statc 0.0 $maxhgraph 0.05 2 %3.1f
    Graph::draw_impulses_from_list .velocitypdf.c $hgraph
}

proc plotmidi_onset_pdf {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global histogram
    set hgraph ""
    set maxhgraph 0.0
    set statc .onsetpdf.c
    for {set i 0} {$i < 100} {incr i} {
        set index [format %4.2f [expr $i/100.0]]
        lappend hgraph $index
        lappend hgraph $histogram($i)
        if {$histogram($i) > $maxhgraph} {set maxhgraph $histogram($i)}
    }
    set maxhgraph [expr $maxhgraph + 0.1]
    if {[winfo exists .onsetpdf] == 0} {
        toplevel .onsetpdf
        position_window ".onsetpdf"
        pack [canvas .onsetpdf.c -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {
        .onsetpdf.c delete all}
    wm title .onsetpdf "probability versus note onset time in beat"
    $statc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx -0.03 1.03 0.0 $maxhgraph
    Graph::draw_x_ticks $statc 0.0 1.01 0.10 2 0 %4.2f
    Graph::draw_y_ticks $statc 0.0 $maxhgraph 0.05 2 %3.1f
    Graph::draw_impulses_from_list .onsetpdf.c $hgraph
}


proc plotmidi_duration_pdf {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global histogram
    set hgraph ""
    set maxhgraph 0.0
    set statc .durpdf.c
    for {set i 0} {$i < 64} {incr i} {
        set index [format %4.2f [expr $i/48.0]]
        lappend hgraph $index
        lappend hgraph $histogram($i)
        if {$histogram($i) > $maxhgraph} {set maxhgraph $histogram($i)}
    }
    set maxhgraph [expr $maxhgraph + 0.1]
    if {[winfo exists .durpdf] == 0} {
        toplevel .durpdf
        position_window .durpdf
        pack [canvas .durpdf.c -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {
        .durpdf.c delete all}
    wm title .durpdf "probability versus note duration"
    $statc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx 0.00 1.5 0.0 $maxhgraph
    Graph::draw_x_ticks $statc 0.0 1.5 0.25 1 0 %4.2f
    Graph::draw_y_ticks $statc 0.0 $maxhgraph 0.05 2 %3.1f
    Graph::draw_impulses_from_list .durpdf.c $hgraph
    }


proc show_note_distribution {} {
    global histogram
    global exec_out total
    global start stop
    global notedist
    for {set i 0} {$i < 13} {incr i} {
        set notedist($i) 0}
    for {set i 0} {$i <128} {incr i} {
        set index [expr $i % 12]
        set notedist($index) [expr $notedist($index) + $histogram($i)]
    }
    plot_pitch_class_histogram
}

proc plot_pitch_class_histogram {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global pitchxfm
    global notedist
    global total
    global exec_out
    global df
    set notes {C C# D D# E F F# G G# A A# B}
    set maxgraph 0.0
    set xpos [expr $xrbx -40]
    for {set i 0} {$i < 13} {incr i} {
        if {$notedist($i) > $maxgraph} {set maxgraph $notedist($i)}
    }
    
    set maxgraph [expr $maxgraph + 0.2]
    set pitchc .pitchclass.c
    if {[winfo exists .pitchclass] == 0} {
        toplevel .pitchclass
        position_window ".pitchclass"
        pack [canvas $pitchc -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {.pitchclass.c delete all}
    
    $pitchc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx 0.0 12.0 0.0 $maxgraph
    set pitchxfm [Graph::save_transform]
    Graph::draw_y_ticks $pitchc 0.0 $maxgraph 0.1 2 %3.1f
    
    set iy [expr $ybbx +10]
    set i 0
    foreach note $notes {
        set ix [Graph::ixpos [expr $i +0.5]]
        $pitchc create text $ix $iy -text $note -font $df
        set iyb [Graph::iypos $notedist($i)]
        set count [expr round($notedist($i)*$total)]
        append exec_out  "$note $count\n"
        set ix [Graph::ixpos [expr double($i)]]
        set ix2 [Graph::ixpos [expr double($i+1)]]
        $pitchc create rectangle $ix $ybbx $ix2 $iyb -fill blue
        incr i
    }
    $pitchc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2
    bind .pitchclass.c <3> {histogram_ps_output .pitchclass.c}
    if {[winfo exist .notice]} {show_message_page $exec_out word}
}


proc histogram_ps_output {canvaslink} {
global df midi
set types {{{postscript files} {*.ps}}}
set filedir [file dirname $midi(abc_open)]
set filename [tk_getSaveFile -initialdir $filedir \
            -filetypes $types]
if {[string length $filename] == 0} return
set extname [file extension $filename]
if {$extname != ".ps"} {set filename $filename.ps}
set pdf [list Helvetica 14]
set fontMap($df) $pdf
$canvaslink postscript -file $filename -fontmap fontMap
puts "$filename created"
}


# Part 28.0      Graphics Namespace


###   Graph ### support functions

namespace eval Graph {
    
    variable x_scale
    variable y_scale
    variable x_shift
    variable  y_shift
    variable left_edge
    variable bottom_edge
    variable top_edge
    variable right_edge
    
    
    
    namespace export set_xmapping
    proc set_xmapping {left right xleft xright} {
        variable x_scale
        variable x_shift
        variable left_edge
        variable right_edge
        set left_edge $left
        set right_edge $right
        set x_scale [expr double($right - $left) / double($xright - $xleft)]
        set x_shift [expr $left - $xleft*$x_scale]
    }
    
    namespace export set_ymapping
    proc set_ymapping {bottom top ybot ytop} {
        variable y_scale
        variable  y_shift
        variable bottom_edge
        variable top_edge
        set bottom_edge $bottom
        set top_edge $top
        set y_scale [expr double($top - $bottom) / double($ytop - $ybot)]
        set y_shift [expr $bottom - $ybot*$y_scale]
    }
    
    
    namespace export save_transform
    proc save_transform { } {
        variable x_scale
        variable x_shift
        variable y_scale
        variable y_shift
        list $x_scale $y_scale $x_shift $y_shift
    }
    
    
    namespace export restore_transform
    proc restore_transform {xfm} {
        variable x_scale
        variable x_shift
        variable y_scale
        variable y_shift
        foreach {x_scale y_scale x_shift y_shift} $xfm {}
    }
    
    
    namespace export alter_transformation
    proc alter_transformation {left right bottom top xleft xright ybot ytop} {
        set_xmapping $left $right $xleft $xright
        set_ymapping $bottom $top $ybot $ytop
    }
    
    namespace export ixpos
    proc ixpos xval {
        variable x_scale
        variable x_shift
        return [expr $x_shift + $xval*$x_scale]
    }
    
    namespace export iypos
    proc iypos yval {
        variable y_scale
        variable y_shift
        return [expr $y_shift + $yval*$y_scale]
    }
    
    
    namespace export pix_to_x
    proc pix_to_x ix {
        variable x_scale
        variable x_shift
        return [expr ($ix - $x_shift)/$x_scale]
    }
    
    namespace export pix_to_y
    proc pix_to_y iy {
        variable y_scale
        variable y_shift
        return [expr ($iy - $y_shift)/$y_scale]
    }
    
    
    namespace export draw_x_ticks
    proc draw_x_ticks {can xstart xend xstep nskip labindex fmt} {
        global df
        variable bottom_edge
        set xticks {}
        set i 0
        for {set x $xstart} {$x < $xend} {set x [expr $x + $xstep]} {
            set ix [ixpos $x]
            set xticks [concat $xticks [$can create line $ix $bottom_edge $ix \
                    [expr $bottom_edge - 5]]]
            if {[expr $i % $nskip] == $labindex} {
                set str [format $fmt $x]
                set xticks [concat $xticks [$can create text $ix \
                        [expr $bottom_edge + 20] -text $str -font $df]]
                set xticks [concat $xticks [$can create line $ix $bottom_edge $ix \
                        [expr $bottom_edge - 10]]]
            }
            incr i
        }
        set xticks
    }


    namespace export draw_x_grid
    proc draw_x_grid {can xstart xend xstep nskip labindex fmt {colfg black}} {
        global df
        variable bottom_edge
        variable top_edge
        set xticks {}
        set i 0
        for {set x $xstart} {$x < $xend} {set x [expr $x + $xstep]} {
            set ix [ixpos $x]
            set xticks [concat $xticks [$can create line $ix $bottom_edge $ix \
                    [expr $bottom_edge - 5]]]
            if {[expr $i % $nskip] == $labindex} {
                set str [format $fmt $x]
                set xticks [concat $xticks [$can create text $ix \
                        [expr $bottom_edge + 20] -text $str -font $df -fill $colfg]]
                set xticks [concat $xticks [$can create line $ix $bottom_edge $ix \
                        $top_edge -dash {1 2}]]]
            }
            incr i
        }
        set xticks
    }

    
    namespace export draw_y_ticks
    proc draw_y_ticks {can ystart yend ystep nskip fmt} {
        global df
        variable left_edge
        set i 0
        set yticks {}
        for {set y $ystart} {$y < $yend} {set y [expr $y + $ystep]} {
            set iy [iypos $y]
            set yticks [concat $yticks [$can create line  $left_edge \
                    $iy [expr $left_edge + 5] $iy]]
            if {[expr $i % $nskip] == 0} {
                set str [format $fmt $y]
                set yticks [concat $yticks [$can create text \
                        [expr $left_edge - 33] $iy -text $str -font $df]]
                set yticks [concat $yticks [$can create line \
                        $left_edge $iy [expr $left_edge + 10] $iy]]
            }
            incr i
        }
        set yticks
    }
    
    namespace export draw_x_log10ticks
    proc draw_x_log10ticks {can  start end fmt} {
        variable bottom_edge
        set xstart [expr floor($start)]
        set xend [expr floor($end)]
        for {set x $xstart} {$x<$xend} {set x [expr $x +1.0]} {
            set xval [expr pow(10.0,$x)]
            set ix [ixpos $x]
            $can create line $ix $bottom_edge $ix [expr $bottom_edge -10]
            set str [format $fmt $xval]
            $can create text $ix [expr $bottom_edge+20] -text $str
            for {set i 2} {$i<10} {incr i} {
                set xman [expr log10($i)]
                set ix [ixpos [expr $xman + $x]]
                $can create line $ix $bottom_edge $ix [expr $bottom_edge -5]
            }
        }
    }
    
    
    namespace export draw_graph_from_arrays
    proc draw_graph_from_arrays {can xvals yvals npoints} {
        upvar $xvals xdata
        upvar $yvals ydata
        set points {}
        for {set i 0} {$i < $npoints} {incr i} {
            set ix [ixpos $xdata($i)]
            set iy [iypos $ydata($i)]
            lappend points $ix
            lappend points $iy
        }
        eval {$can create line} $points
    }
    
    
    namespace export draw_graph_from_list
    proc draw_graph_from_list {can datalist} {
        #can canvas
        #datalist {x y x y x y ...}
        set points {}
        foreach {xdata ydata} $datalist {
            set ix [ixpos $xdata]
            set iy [iypos $ydata]
            lappend points $ix
            lappend points $iy
        }
        eval {$can create line} $points
    }
    
    namespace export draw_impulses_from_list
    proc draw_impulses_from_list {can datalist} {
        #can canvas
        #datalist {x y x y x y ...}
        foreach {xdata ydata} $datalist {
            if {$ydata != 0.0} {
                set ix [ixpos $xdata]
                set iy [iypos $ydata]
                $can create line $ix [iypos 0] $ix $iy -fill blue -width 2
            }
        }
    }
} ;# end of namespace declaration

namespace import Graph::*


#end of midistats.tcl

#source velocitymap.tcl

proc plot_velocity_map {} {
    global pianoresult midi ppqn
    global trksel
    set velmap .midivelocity.c
    if {[winfo exists .midivelocity] == 0} {
        toplevel .midivelocity
        position_window ".midivelocity"
        pack [canvas $velmap]
    } else {
        .midivelocity.c delete all}
    set limits [midi_limits]
    set start [expr double([lindex $limits 0])/$ppqn]
    set stop  [expr double([lindex $limits 1])/$ppqn]
    set delta_tick [expr int(($stop - $start)/10.0)]
    if {$delta_tick < 1} {set delta_tick 1}
    set tsel [count_selected_midi_tracks]
    $velmap create rectangle 50 20 350 220 -outline black\
            -width 2 -fill white
    Graph::alter_transformation 50 350 220 20 $start $stop 0.0 132
    Graph::draw_x_ticks $velmap $start $stop $delta_tick 2  0 %4.0f
    Graph::draw_y_ticks $velmap 0.0 132.0 8.0 2 %3.0f
    foreach line [split $pianoresult \n] {
        if {[llength $line] != 6} continue
        set begin [expr double([lindex $line 0])/$ppqn]
        if {[string is double $begin] != 1} continue
        if {$begin < $start} continue
        set end [expr double([lindex $line 1])/$ppqn]
        if {$end   > $stop}  continue
        set v [lindex $line 5]
        set t [lindex $line 2]
        set c [lindex $line 3]
        if {$midi(midishow_sep) == "track"} {set sep $t} else {set sep $c}
        if {$tsel != 0 && $trksel($sep) == 0} continue
        set ix1 [Graph::ixpos $begin]
        set ix2 [Graph::ixpos $end]
        set iy [Graph::iypos $v]
        $velmap create line $ix1 $iy $ix2 $iy -width 2
    }
}

#end of velocitymap.tcl



#end of source stats.tcl



# Part 29.0             File type registration


#start of source abc_register.tcl

#----------------------------------------------------------------------
#
# RegisterFileType --
#
#       Register a file type on Windows
#
# Author:
#       Kevin Kenny <kennykb@acm.org>.
#       Last revised: 27 Nov 2000, 22:35 UTC
#
# Parameters:
#       extension -- Extension (e.g., .tcl) of the new type
#                    being registered.
#       className -- Class name (e.g., "tclfile") of the new type
#       textName  -- Textual name (e.g. "Tcl Script") of the
#                    new type.
#       script    -- Name of the file containing a Tcl script
#                    to run when a file of the given type is
#                    opened.  The script will receive the name
#                    of the file in [lindex $argv 0].
#
# Options:
#       -icon FILENAME,NUMBER
#               Set the icon for files of the new type
#               to be the NUMBER'th icon in the given file.
#               The file must be a full path name.
#       -mimetype TYPE
#               Set the MIME type corresponding to the new
#               file type to the specified string.
#       -new BOOLEAN
#               If BOOLEAN is true, set things up so that
#               the new file type appears in the "New" menu
#               in the Explorer and the system tray.
#       -text BOOLEAN
#               If BOOLEAN is true, the new file type contains
#               plain ASCII text of some sort.  Set the
#               Edit and Print actions to open and print
#               ASCII files.
#
# Results:
#       None.
#
# Side effects:
#       Adds the following keys to the system registry:
#
#       HKEY_CLASSES_ROOT
#         (Extension)           (Default value)         ClassName
#                               "Content Type"          MimeType        [1]
#           ShellNew            "NullFile"              ""              [2]
#         (ClassName)           (Default value)         TextName
#           DefaultIcon         (Default value)         IconName,#      [3]
#           Shell
#             Open
#               command         (Default value)         -SEE BELOW-
#             Edit
#               command         (Default value)         -SEE BELOW-     [4]
#             Print
#               command         (Default value)         -SEE BELOW-     [4]
#         MIME
#           Database
#             Content Type
#               (MimeType)      (Default value)         Extension       [1]
#
#       [1] These values are added only if the -mimetype option is used.
#       [2] This value is added only if the -new option is true.
#       [3] This value is added only if the -icon option is used.
#       [4] These values are added only if the -text option is true.
#
#       The command to open the file consists of three arguments.
#       The first is the name of the current Tcl executable.  The
#       second is the script name, and the third is "%1", which causes
#       the target file to be passed as a command-line argument.
#       The edit command is the command that opens text files, and the
#       print command is the command that prints text files.
#
#   Modified by Seymour Shlien to register abc files
#   for freewrapped scripts (i.e. *.exe files)
#----------------------------------------------------------------------


proc RegisterFileType { extension className textName script args } {
    
    set scriptype [file extension $script]
    
    package require registry
    
    # extPath is the class path for the file's extension
    
    set extPath HKEY_CLASSES_ROOT\\$extension
    registry set $extPath {} $className sz
    
    # classPath is the class path for the file's class
    
    set classPath HKEY_CLASSES_ROOT\\$className
    registry set $classPath {} $textName sz
    
    # shellPath is the shell key within classPath
    
    set shellPath $classPath\\Shell
    
    # Set up the 'Open' action
    
    set openCommand {}
    
    puts $scriptype
    if {[string equal $scriptype ".tcl"]} {
        append openCommand \" \
                [file nativename [info nameofexecutable]] \
                \" { } \" [file nativename $script] \" { } \"\$1\" { } \"%1\"
    }
    
    if {[string equal $scriptype ".exe"]} {
        append openCommand \
                \" [file nativename $script] \" { } \"\$1\" { } \"%1\"
    }
    
    #     puts "openCommand = $openCommand"
    
    registry set $shellPath\\open\\command {} $openCommand sz
    
    # Process optional args
    
    foreach {key val} $args {
        switch -exact -- $key {
            
            -mimetype {
                
                # Set up the handler for the MIME content type,
                # and add the content type item to the database
                
                registry set $extPath "Content Type" $val sz
                set mimeDbPath \
                        "HKEY_CLASSES_ROOT\\MIME\\Database"
                append mimeDbPath "\\Content Type\\" $val
                registry set $mimeDbPath Extension \
                        $extension sz
            }
            
            -icon {
                
                # Add the file icon to the shell database
                
                if {![regexp {^(.*),([^,]*)} $val \
                            junk file icon]} {
                    error "-icon option requires\
                            fileName,iconNumber"
                }
                registry set $classPath\\DefaultIcon {} \
                        [file nativename $file],$icon sz
            }
            
            -text {
                if {$val} {
                    
                    # Copy the Print action for text files
                    # into the Print action for the new type
                    
                    set textPath \
                            HKEY_CLASSES_ROOT\\txtfile\\Shell
                    if {![catch {
                            registry get \
                                    $textPath\\print\\command {}
                        } pCmd]} {
                        registry set \
                                $shellPath\\print\\command \
                                {} $pCmd sz
                        registry set \
                                $shellPath\\print {} \
                                &Print sz
                        
                    }
                    
                    # Copy the Open action for text files
                    # into the Edit action for the new type.
                    
                    if {![catch {
                            registry get \
                                    $textPath\\open\\command {}
                        } eCmd]} {
                        registry set \
                                $shellPath\\edit\\command \
                                {} $eCmd sz
                        registry set \
                                $shellPath\\edit {} \
                                &Edit sz
                    }
                }
            }
            
            -new {
                if {$val} {
                    
                    # Add the 'NullFile' action to the
                    # shell's New menu
                    
                    registry set $extPath\\ShellNew NullFile \
                            {} sz
                }
            }
            
            default {
                error "unknown option $key, must be -icon,\
                        -mimetype, -new or -text"
            }
        }
    }
}

proc associate_abc {} {
    global df
    if {[winfo exist .assoc]} return
    toplevel .assoc
    position_window ".assoc"
    frame .assoc.1
    label .assoc.1.lab -text "associate abc files with " -font $df
    button .assoc.1.tcl -text "runabc.tcl" -font $df
    button .assoc.1.exe -text "runabc.exe" -font $df
    pack .assoc.1.lab .assoc.1.tcl .assoc.1.exe -side left
    pack .assoc.1
    frame .assoc.2
    button .assoc.2.exit -text exit -font $df -command {destroy .assoc}
    button .assoc.2.help -text help -font $df -command {
        show_message_page $hlp_associate word
        focus .abc
        raise .abc
    }
    pack .assoc.2.exit .assoc.2.help -side left
    pack .assoc.2
    
    
    bind .assoc.1.tcl <Button> {
        #puts "for assoc.tcl"
        if {$tcl_platform(platform) == "windows"} {
            if {[glob -nocomplain runabc.tcl] != ""} {
                registry set "HKEY_LOCAL_MACHINE\\Software\\runabc" \
                        InstallDir "[pwd]"
                RegisterFileType .abc "ABCfile" "ABC Music File" [pwd]/runabc.tcl \
                        -text 1 -icon [file normalize [pwd]/runabc.ico],0
                .assoc.2.exit configure -text "File Association done, click to exit"
            } else {
                .assoc.2.exit configure -text "Run this script in the same dir as runabc.tcl"
            }
        } else {
            .assoc.2.exit configure -text "Only for Windows! Click to Exit"
        }
    }
    
    bind .assoc.1.exe <Button> {
        #puts "for assoc.exe"
        if {$tcl_platform(platform) == "windows"} {
            if {[glob -nocomplain runabc.exe] != ""} {
                registry set "HKEY_LOCAL_MACHINE\\Software\\runabc" \
                        InstallDir "[pwd]"
                RegisterFileType .abc "ABCfile" "ABC Music File" [pwd]/runabc.exe \
                        -text 1 -icon [file normalize [pwd]/runabc.ico],0
                .assoc.2.exit configure -text "File Association done, click to exit"
            } else {
                .assoc.2.exit configure -text "Run this script in the same dir as runabc.exe"
            }
        } else {
            .assoc.2.exit configure -text "Only for Windows! Click to Exit"
        }
    }
}

set hlp_associate "For Windows only -- associate abc files with runabc\n\n\
        This function modifies the windows registry in order to set up an association\
        between an abc file and either runabc.tcl or runabc.exe. Once this is done,\
        the abc files will have a new icon displaying runabc and double clicking on an\
        abc file will automaticly start up runabc and load up this abc file.\
        If runabc is already running, then double clicking on an abc file\
        will load that file in the current running process.\n\n\
        Normally it is only necessary to create this association once. The\
        association remains permanent (unless changed by another abc application).\
        If you later decide to move runabc to a new directory, then it is necessary\
        to reestablish the association the same way. If at sometime you wish to \
        destroy or change this association, you can do this by going to\
        'Folder Options' which is accessed from the file manager under the menu\
        item view or toolbar or somthing else (depending on which version \
        of Windows you are running -- 95,98,ME,etc.); then select 'File Types'\
        find ABC, select it and take the appropriate action (eg remove).\n\n\
        When you double click on abc file, windows starts up runabc and loads up\
        the selected abc file. However, the current directory is the same directory\
        where the abc file was found. This poses a problem, since the runabc.ini and\
        tmp directory is normally in the same directory as where runabc was installed.\
        To fix this problem, this function also stores the path name to the runabc\
        install directory in the registry. Runabc determines whether runabc.tcl or\
        runabc.exe are found in the current directory. If they are not found, then\
        runabc looks in the registry to find out where they are located and changes\
        the current directory to this location. Now it is possible to load and\
        store the correct runabc.ini file."

#end of source abc_register.tcl


# Part 30.0         Mftext interface

#source mftextwin.tcl

proc mftextwindow {midifilein nofile} {
    global midi df
    global mfnotes mftouch mfcntl mfprog mfmeta
    set f .mftext
    if {[winfo exist $f] == 0} {
        toplevel $f
        position_window ".mftext"
        frame $f.1

    label $f.fillab -text $midifilein  -font $df -width 60
    button $f.1.browse -text browse -font $df -command {
             set midifilein [midi_file_browser]
             output_mftext [list $midifilein]
	     .mftext.fillab configure -text $midifilein
             }
    button $f.1.help -text help -font $df\
            -command {show_message_page $hlp_mftext word}
    pack $f.fillab
    pack $f.1.browse $f.1.help -side left
    pack $f.1
    frame $f.2
    pack $f.1 $f.2 -side top


        set f .mftext.4
        frame $f
        label $f.lab -text hide -font $df
        set mfnotes 0
        set mftouch 0
        set mfprog  0
        set mfmeta  0
        set mfcntl  0
        checkbutton $f.note -variable mfnotes  -text notes      -font $df\
                -command mfnotescmd
        checkbutton $f.touch -variable mftouch -text aftertouch -font $df\
                -command mftouchcmd
        checkbutton $f.prog  -variable mfprog  -text program    -font $df\
                -command mfprogcmd
        checkbutton $f.meta  -variable mfmeta  -text metatext   -font $df\
                -command mfmetacmd
        checkbutton $f.cntl  -variable mfcntl  -text cntl       -font $df\
                -command mfcntlcmd
        pack $f.lab $f.note $f.touch $f.prog $f.meta $f.cntl -side left
        pack $f -side top -anchor w
    }
    if {$nofile} {
       pack forget .mftext.1
       } else {
       pack .mftext.1 -before .mftext.2 
       }

    output_mftext [list $midifilein]

}


proc output_mftext {midifilein} {
    global midi exec_out
    global df elidetrk
    global mfnotes mftouch mfcntl mfprog mfmeta
    global mfntracks
    set mfnotes 0
    set mftouch 0
    set mfprog  0
    set mfmeta  0
    set mfcntl  0
    if {[winfo exist .mftext.2.txt]} {
        destroy .mftext.3
        .mftext.2.txt tag delete everywhere
        destroy .mftext.2.txt .mftext.2.scroll
        if {[info exist elidetrk]} {unset elidetrk}
    }
    if {[winfo exist .mftext.31]} {destroy .mftext.31}
    text .mftext.2.txt -yscrollcommand {.mftext.2.scroll set} -width 52 -font $df
    scrollbar .mftext.2.scroll -orient vertical -command {.mftext.2.txt yview}
    pack .mftext.2.txt .mftext.2.scroll -side left -fill y
    if {$midi(mftextunits) == 2} {
       set cmd "exec [list $midi(path_midi2abc)] $midifilein -mftext"
    } else {
       set cmd "exec [list $midi(path_midi2abc)] $midifilein -mftextpulses"
    }
    catch {eval $cmd} mftextresults
    set exec_out $mftextresults
    if {[string first "no such" $exec_out] >= 0} {abcmidi_no_such_error $midi(path_midi2abc)}
    #$f delete 1.0 end
    set mflines [split $mftextresults \n]
    foreach line $mflines {
        tag_and_insert_mftext_line $line
    }
   for {set i 1} {$i <= $mfntracks} {incr i} {
        set elidetrk($i) 0
        elide_reveal_track $i
        }


}


proc tag_and_insert_mftext_line {line} {
    global df
    global trktag
    global elidetrk
    global mfntracks
    set f .mftext.2.txt
    set pat \[A-Za-z\]+
    set linelist [split $line]
    set type ""
    .mftext.2.txt tag configure blue -foreground blue
    if {[string equal [lindex $linelist 0] "Track"]} {
        set trk [lindex $linelist 1]
        set trktag t$trk
        $f insert end $line\n tr$trk
        $f tag configure tr$trk -foreground blue
        $f tag bind tr$trk <1> "elide_reveal_track $trk"
        $f tag bind tr$trk <Enter> "$f tag configure tr$trk -foreground red"
        $f tag bind tr$trk <Leave> "$f tag configure tr$trk -foreground blue"
    } else {
        regexp $pat $linelist keyword
        switch $keyword {
            Note {set type note}
            Pressure {set type touch}
            Pitchbend {set type touch}
            Metatext {set type meta}
            Program  {set type prog}
            Chanpres {set type touch}
            CntlParm {set type cntl}
        }
        if {[info exist trktag]} {
            $f insert end $line\n [list $trktag $type]
        } else {
            $f insert end $line\n $type
        }
        #puts $keyword
    }
   if {[info exist trk]} {set mfntracks $trk}
}


proc elide_reveal_track no {
    global elidetrk
    global mfnotes mftouch mfcntl mfprog mfmeta
    set elidetrk($no) [expr 1 - $elidetrk($no)]
    .mftext.2.txt tag configure t$no -elide $elidetrk($no)
    .mftext.2.txt tag raise t$no
    if {$elidetrk($no) == 0} {
       if {$mfnotes} mfnotescmd
       if {$mftouch} mftouchcmd
       if {$mfprog}  mfprogcmd
       if {$mfcntl}  mfcntlcmd
       if {$mfmeta}  mfmetacmd
       }
}

proc elide_tracks {} {
# Turning off the elide of one of the note, touch, cntl, ... tags
# effects all the tracks. We ensure that the hidden tracks remain
# hidden by raising the t$i tag. (Only the top tag on a line
# is effective in the case of when there is more than one tag
# configured.
    global mfntracks elidetrk
    for {set i 1} {$i <= $mfntracks} {incr i} {
      if {$elidetrk($i) == 1} {.mftext.2.txt tag raise t$i}
    }
}


proc mfnotescmd {} {
    global mfnotes
    .mftext.2.txt tag configure note -elide $mfnotes
    .mftext.2.txt tag raise note
    if {$mfnotes == 0} elide_tracks 
}

proc mftouchcmd {} {
    global mftouch
    .mftext.2.txt tag configure touch -elide $mftouch
    .mftext.2.txt tag raise touch
    if {$mftouch == 0} elide_tracks 
}

proc mfprogcmd {} {
    global mfprog
    .mftext.2.txt tag configure prog -elide $mfprog
    .mftext.2.txt tag raise  prog
    if {$mfprog == 0} elide_tracks 
}

proc mfmetacmd {} {
    global mfmeta
    .mftext.2.txt tag configure meta -elide $mfmeta
    .mftext.2.txt tag raise meta
    if {$mfmeta == 0} elide_tracks 
}

proc mfcntlcmd {} {
    global mfcntl
    .mftext.2.txt tag configure cntl -elide $mfcntl
    .mftext.2.txt tag raise cntl
    if {$mfcntl == 0} elide_tracks 
}

set hlp_mftext "mftext window\n\n\
        This window shows a textual representation of the MIDI\
        file specified in the entry box.\n\n\
        Clicking on the track number line will reveal or hide the\
        contents of the track.  The checkbuttons at the bottom of\
        the screen allow you to hide or reveal the output for\
        the specified MIDI commands. (Aftertouch includes both pressure\
        and pitchbend commands.) The number on the left is the beat number,\
        usually quarter notes. The channel number is usually placed after\
        the MIDI command."


#end of source mftextwin.tcl


# Part 31.0             Incipits file support functions


#source copybar.tcl

proc copy_tunes {abchandle nbars outhandle noX} {
    # copies the first nbars of every voice
    # in a abc file. Method: count number
    # of bars in each voice and suppress output
    # for bar numbers greater than nbars.
    
    # to handle any header text
    set no 0
    set barcount($no) 0
    set firstX 1
    set nchars 0 ;# protection file file runover
    set barmax $nbars
    set p {\|+}
    while {![eof $abchandle]} {
        set line  [gets $abchandle]
        if {[string length $line] > 0 } {
            if {[string equal [string range $line 0 1] "X:"]} {
                if {[info exist barcount]} {unset barcount}
                set no 0
                set barcount($no) 0
                if {!$noX || $firstX} {
                    puts $outhandle ""
                    puts $outhandle $line; incr nchars 10
                    set firstX 0
                }
                incr nchars
                continue
            }
            set vindex [string first V: $line]
            if {$vindex > -1} {
                set remainline [string range $line [expr $vindex+2] end]
                regexp {\w+} $remainline no
                if {![info exist barcount($no)]} {set barcount($no) 0}
            }
            
            # allow field commands to go through if bar count less than barmax
            set initial [string index $line 0]
            set next [string index $line 1]
            if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
                >= 0 && $next == ":" } {
                if {$barcount($no) < $barmax} {puts $outhandle $line; incr nchars 10}
                if {$nchars > 500000} return
                continue
            }
            
            # handle body one character at a time
            if   {$barcount($no) >= $barmax} {continue} else {
                for {set i 0} {$i < [string length $line]} {incr i} {
                    set char [string index $line $i]
                    if {$char == "|"} {incr barcount($no)}
                    puts -nonewline $outhandle $char
                    incr nchars
                    if {$nchars > 500000} return
                    if {$barcount($no) >= $barmax} {
                        break
                    }
                }
                #           gets stdin
                puts $outhandle ""
                if {$nchars > 500000} return
                incr nchars
            }
        }
        
    }
}


set incipits_length 8
set incipits_noX 0
set w .abc.incipits
frame $w
frame $w.1
label $w.1.2 -text "Create file of incipits" -font $df
frame $w.2
label $w.2.1 -text "number of bars" -font $df
scale $w.2.2 -from 0 -to 16 -length 100 -orient horizontal \
        -font $df -variable incipits_length
checkbutton $w.2.3 -text "to single tune" -variable incipits_noX -font $df
frame $w.3
button $w.3.1 -text "to file" -font $df -command incipits_to_file
button $w.3.2 -text "to TclAbcEditor" -font $df -command incipits_to_TclAbcEditor
pack $w.1.2 -side left
pack $w.2.1 $w.2.2 $w.2.3 -side left -anchor w
pack $w.3.1 $w.3.2 -side left -anchor w
pack $w.1 $w.2 $w.3 -side top

set hlp_incipits "Create file of incipits\n\n\
        The function will copy the first few bars of all the tunes\
        in the table of contents to a designated file or place it\
        in the TclAbcEditor buffer. If the checkbox 'to single tune'\
        is ticked, all the incipits will be stuffed into a single\
        tune. This produces the most compact Postscript file when\
        abcm2ps is executed on the output file and also allows you\
        to put all the incipits in one MIDI file. If the checkbox is\
        not ticked then each incipit goes into a separate tune and\
        all the X: reference numbers are preserved. The number of\
        bars in the incipit can be configured using the scale widget.\n\n\
        For multivoiced files, the first few bars of each voice will be\
        copied. The function handles inline voice commands eg \[V:2\]\
        but they should be placed at the beginning of the line.\n\n\
        If you want to produce incipits for any a selection of tunes,\
        first copy the selected tunes to a separate abc file using\
        runabc edit/copy command and then load that file into the TOC."

proc show_incipits_page {} {
    global active_sheet
    remove_old_sheet
    if {$active_sheet == "incipits"} {
        set active_sheet "none"
    } else {
        pack .abc.incipits
        set active_sheet incipits}
}

proc incipits_to_TclAbcEditor {} {
    global midi incipits_length incipits_noX
    set outhandle [open $midi(abc_default_file) w]
    set inhandle  [open $midi(abc_open) r]
    copy_tunes $inhandle $incipits_length $outhandle $incipits_noX
    close $outhandle
    close $inhandle
    tcl_abc_edit $midi(abc_default_file) 1
}

proc incipits_to_file {} {
    global midi incipits_length incipits_noX
    set types {{{abc files} {*.abc}}
        {{all} {*}}}
    set filedir [file dirname $midi(abc_default_file)]
    set filename [tk_getSaveFile -initialdir $filedir \
            -filetypes $types]
    if {[string length $filename] == 0} return
    if {[string compare  $midi(abc_open) $filename] == 0} {
        tk_messageBox -message "do not even think of writing over the input file" \
                -type ok
        return
    }
    set outhandle [open $filename w]
    set inhandle  [open $midi(abc_open) r]
    copy_tunes $inhandle $incipits_length $outhandle $incipits_noX
    close $outhandle
    close $inhandle
}
#end of source copybar.tcl



# source playall.tcl

proc play_entire_edit_window {verbatim} {
    global midi exec_out files
    global body_start body_end
    global abctxtw
    set files ""
    set sel ""
    lappend files X1.mid
    set cmd "file delete [glob -nocomplain X*.mid]"
    catch {eval $cmd}
    set out_fd [open X.tmp w]
    set nlines [lindex [split [$abctxtw index end] .] 0]
    for {set i 1} {$i <= $nlines} {incr i} {
        set value [$abctxtw get $i.0 $i.end]
        puts $out_fd $value
        if {[string equal [string range $value 0 1] "X:"]} {
            regexp {[0-9]+} $value number
            lappend sel $number
            if {!$verbatim} {write_midi_codes $out_fd
                puts $out_fd "Q:$midi(beatsize) = $midi(tempo)"
            }
        }
    }
    close $out_fd
    set cmd "exec $midi(path_abc2midi) X.tmp"
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files [glob X*.mid]
    play_midis $sel
    update_console_page
}

#end of source playall.tcl


# Part 32.0            Beat Graph and Unique Chords for Midishow

#source beatgraph.tcl

proc beat_graph {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global pianoresult ppqn
    
    set nrec [llength $pianoresult]
    set midilength [lindex $pianoresult [expr $nrec -6]]
    
    set limits [midi_limits]
    set start [expr double([lindex $limits 0])/$ppqn]
    set stop  [expr double([lindex $limits 1])/$ppqn]
    set tsel [count_selected_midi_tracks]
    
    set bgraph .beatgraph.c
    if {[winfo exists .beatgraph] == 0} {
        toplevel .beatgraph
        position_window ".beatgraph"
        pack [canvas .beatgraph.c -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {.beatgraph.c delete all}
    
    if {$start > 1.0} {set start [expr $start -1.0]}
    set delta_tick [expr int(($stop - $start)/10.0)]
    if {$delta_tick < 1} {set delta_tick 1}
    $bgraph create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx $start $stop -0.0625 1.0
    Graph::draw_x_ticks $bgraph $start $stop $delta_tick 2 0 %3.0f
    Graph::draw_y_ticks $bgraph 0.0 1.0 0.125 2 %3.2f
    
    set i 0
    foreach line [split $pianoresult \n] {
        if {[llength $line] != 6} continue
        set onset [expr double([lindex $line 0])/$ppqn]
        if {$onset < $start} continue
        if {$onset > $stop} break
        set beat [expr floor($onset)]
        set frac [expr $onset - $beat]
        #  puts "$beat $frac"
        incr i
        set ix [Graph::ixpos $beat]
        set iy [Graph::iypos $frac]
        $bgraph create rectangle $ix $iy [expr $ix +1] [expr $iy +1] -fill black
    }
}
# end source beatgraph.tcl


#source uniquechords.tcl

#wuniquechords.tcl
#list combination notes which are on at the same time

set maxchordlength 3

proc list_unique_chords_window {} {
    global df
    
    if {[winfo exist .chordstats]} return
    set w .chordstats
    toplevel $w
    position_window ".chordstats"
    
    frame $w.file
    button $w.file.list -text chordlist -font $df  -command "make_and_display_chords 0"
    button $w.file.class -text chordclasses  -font $df -command "make_and_display_chords 1"
    scale $w.file.size -variable maxchordlength -orient vertical -length 40\
            -from 1 -to 10 -label "max chord size" -font $df
    pack  $w.file.size $w.file.list $w.file.class -side left
    pack $w.file
    
    frame $w.chords
    text $w.chords.t -width 70 -height 20 -yscrollcommand {.chordstats.chords.ysbar set} -font $df
    scrollbar $w.chords.ysbar -orient vertical -command {.chordstats.chords.t yview}
    pack $w.chords.t -side left
    pack $w.chords.ysbar -side left -fill y
    pack $w.chords
    
    
    $w.chords.t configure -tabs "180 left 360 left 540 left 720 left"
}


proc compare_onset {a b} {
    set a_onset [lindex $a 0]
    set b_onset [lindex $b 0]
    if {$a_onset > $b_onset} {
        return 1}  elseif {$a_onset < $b_onset} {
        return -1} else {return 0}
}

array set note {0 C  1 C#  2 D  3 D#  4 E  5 F  6 F#  7 G  8 G#  9 A   10 A# \
            11 B }


proc midi_to_pitchclass {midipitch} {
    global note
    set midipitch [expr round($midipitch)]
    set keyname $note([expr $midipitch % 12])
    return $keyname
}



proc label_notelist {notelist} {
    set labeled_list ""
    foreach elem $notelist {
        set labeled_list "$labeled_list [midi_to_key $elem]"
    }
    return $labeled_list
}

proc label_pitchlist {pitchlist} {
    set labeled_list ""
    foreach elem $pitchlist {
        set labeled_list "$labeled_list [midi_to_pitchclass $elem]"
    }
    return $labeled_list
}

set notelist {}



proc count_chords {chord} {
    global chordcount
    global total_chordcount
    if {[info exist chordcount($chord)]} {
        incr chordcount($chord)
    } else {
        set chordcount($chord) 1
    }
    incr total_chordcount
}

proc chord_instants {chord instant} {
    global chordtimes
    if {[info exist chordtimes($chord)]} {
        lappend chordtimes($chord) $instant
    } else {
        set chordtimes($chord) $instant
    }
}


proc print_chordcount_by_size {} {
    global chordcount
    global total_chordcount
    set chordcountlist [array get chordcount]
    #puts "$total_chordcount chords [expr [llength $chordcountlist]/2] unique chords"
    for {set i 0} {$i < 6} {incr i} {
        set chordlist {}
        foreach {chord count} $chordcountlist {
            if {[llength [split $chord " "]] == $i} {
                lappend chordlist $chord $count
            }
        }
        foreach {chord count} $chordlist {
            puts "$chord $count"
            
        }
    }
}

proc print_chordcount_by_key {w} {
    global chordcount
    global total_chordcount
    set chordcountlist [array get chordcount]
    #puts "$total_chordcount chords [expr [llength $chordcountlist]/2] unique chords"
    
    set chordlist {}
    foreach {chord count} $chordcountlist {
        lappend chordlist $chord
    }
    
    set sortedchordlist [lsort $chordlist]
    set i 0
    set nrows [expr 1+ [llength $sortedchordlist] /2]
    foreach chord $sortedchordlist {
        set j [expr ($i % $nrows)+1]
        set n [expr $i/ $nrows]
        if {$n == 0} {
            $w.chords.t insert $j.0  "$chord $chordcount($chord)\n"
        } else {
            $w.chords.t insert $j.end  "\t$chord $chordcount($chord)"
        }
        incr i
    }
}

proc print_chordinstants {} {
    global chordtimes
    set chordtimeslist [array get chordtimes]
    puts "[llength $chordtimeslist] distinct chord instances"
    foreach {chord instants} $chordtimeslist {
        puts "$chord $instants"
    }
}

proc reorganize_midicmd {} {
    global midicmds
    global sorted_midiactions
    set midiactions {}
    foreach midi $midicmds {
        set onset [lindex $midi 0]
        set stop  [lindex $midi 1]
        set pitch [lindex $midi 4]
        lappend midiactions [list $onset $pitch 1]
        lappend midiactions [list $stop  $pitch 0]
    }
    set sorted_midiactions [lsort -command compare_onset $midiactions]
}


proc turn_off_all_notes {} {
    global notestatus
    for {set i 0} {$i < 128} {incr i } {
        set notestatus($i) 0}
}

proc turn_off_all_pitches {} {
    global pitchstatus
    for {set i 0} {$i < 12} {incr i} {
        set pitchstatus($i) 0}
}


proc list_on_notes {maxlength} {
    global notestatus
    set notelist {}
    set j 0
    for {set i 0} {$i < 128} {incr i } {
        if {$j >= $maxlength} break
        if {$notestatus($i)} {lappend notelist $i
            incr j}
    }
    return $notelist
}

proc list_on_pitches {} {
    global pitchstatus
    set notelist {}
    for {set i 0} {$i < 12} {incr i} {
        if {$pitchstatus($i)} {lappend notelist $i}
    }
    return $notelist
}



proc switch_note_status {midicmd} {
    global notestatus
    set notestatus([lindex $midicmd 1]) [lindex $midicmd 2]
    #puts "notestatus([lindex $midicmd 1]) = $notestatus([lindex $midicmd 1])"
}

proc set_pitch_status {} {
    global notestatus pitchstatus
    turn_off_all_pitches
    for {set i 0} {$i < 128} {incr i} {
        if {$notestatus($i)} {
            set pitch [expr $i % 12]
            set pitchstatus($pitch) 1
        }
    }
}

proc make_and_display_chords {pitchclass} {
    global midi
    global sorted_midiactions
    global total_chordcount
    global midicmds
    global chordcount
    global maxchordlength
    global ppqn
    
    set limits [midi_limits]
    set start [lindex $limits 0]
    set stop  [lindex $limits 1]
    #puts "start stop = $start $stop"
    set tsel [count_selected_midi_tracks]
    
    set exec_options  "-midigram"
    set cmd "exec [list $midi(path_midi2abc)] [list $midi(midifilein)]  $exec_options"
    set w .chordstats
    $w.chords.t delete 0.0 end
    
    catch {eval $cmd} midi2abc_output
    #puts $cmd
    #puts $midi2abc_output
    set midicmds [split $midi2abc_output \n]
    reorganize_midicmd
    turn_off_all_notes
    turn_off_all_pitches
    array unset chordcount
    
    set last_time 0.0
    set i 0
    set total_chordcount 0
    global total_chordcount
    
    
    foreach midiunit $sorted_midiactions {
        set begin [lindex $midiunit 0]
        if {[string is double $begin] != 1} continue
        if {$begin < $start} continue
        set end [lindex $midiunit 0]
        if {$end   > $stop}  continue
        
        #  if {$i > 40} break
        incr i
        set present_time [lindex $midiunit 0]
        if {[expr $present_time - $last_time] > 0.2} {
            if {$pitchclass} {
                set onlist [list_on_pitches]
                set chordstring [label_pitchlist $onlist]
            } else {
                set onlist [list_on_notes $maxchordlength]
                set chordstring [label_notelist $onlist]
            }
            
            count_chords $chordstring
            set last_time $present_time
        }
        
        switch_note_status $midiunit
        if {$pitchclass} set_pitch_status
    }
    print_chordcount_by_key $w
}


proc unique_chords {} {
    list_unique_chords_window
    make_and_display_chords 0
}

#end of source uniquechords.tcl

proc display_entire_edit_window {} {
    global midi exec_out files
    global body_start body_end
    global abctxtw
    global ps_numb_start
    set ps_numb_start 0
    set files ""
    set sel ""
    lappend files X1.mid
    set cmd "file delete [glob -nocomplain X*.mid]"
    catch {eval $cmd}
    set out_fd [open X.tmp w]
    set nlines [lindex [split [$abctxtw index end] .] 0]
    for {set i 1} {$i <= $nlines} {incr i} {
        set value [$abctxtw get $i.0 $i.end]
        puts $out_fd $value
    }
    close $out_fd
    display_tunes X.tmp
}

#source pianops.tcl

proc piano_window_ps_output {} {
    #This function creates a postscript file of the exposed
    #piano roll display. It temporarily annotates the vertical
    #and horizontal scale. Creates the postscript file and
    #then erases the annotation. Most of the global variables
    #are shared with the functions compute_pianoroll and
    #piano_qnote listes
    global piano_qnote_offset midilength pianoxscale vspace
    global piano_vert_lines vspace
    global df
    set pdf [list Helvetica 14]
    set fontMap($df) $pdf
    
    set xv [.piano.can xview]
    #puts $xv
    set scrollregion [.piano.can cget -scrollregion]
    #puts $scrollregion
    set xvleft [lindex $xv 0]
    set xvright [lindex $xv 1]
    set width [lindex $scrollregion 2]
    set height [lindex $scrollregion 3]
    set xvleft [expr $xvleft*$width]
    set xvright [expr $xvright*$width]
    set yv [.piano.can yview]
    set ytop [lindex $yv 0]
    set ybot [lindex $yv 1]
    
    set ytop [expr $ytop * $height]
    set ybot [expr $ybot * $height]
    #puts $scrollregion
    #puts "$xvleft $xvright"
    #puts "$ytop $ybot"
    set ixleft [expr int($xvleft)]
    set iybot [expr int($ybot+1)]
    set ixright [expr int($xvright)]
    set ixright2 [expr $xvright +6]
    set iybot2 [expr $iybot -20]
    set iybot3 [expr $iybot -10]
    set iytop [expr int($ytop-1)]
    set iytop2 [expr $ytop -9]
    set ixleft2 [expr $ixleft + 22]
    #clear some space for the annotation
    .piano.can create rectangle $ixleft $iybot $ixright $iybot2 \
            -fill white -outline "" -tag ps
    .piano.can create rectangle $ixleft $iybot $ixleft2 $iytop  \
            -fill white -outline "" -tag ps
    .piano.can create rectangle $ixleft $iytop $ixright $iytop2 \
            -fill white -outline "" -tag ps
    .piano.can create rectangle $ixright $iybot $ixright2 $iytop  \
            -fill white -outline "" -tag ps
    #put everything in a box
    .piano.can create rectangle $ixleft2 $iybot2 $ixright $iytop -outline black -width 2 -tag ps
    
    #label x axis
    set txspace $vspace
    for {set i $piano_qnote_offset} {$i < $midilength} {incr i $txspace} {
        set ix1 [expr $i/$pianoxscale]
        if {$ix1 < 0} continue
        .piano.can create text $ix1 $iybot3 -text [expr $piano_vert_lines*int($i/$vspace)] -tag ps -font $df
    }
    
    #label y axis
    set ix [expr $ixleft +10]
    for {set i 0} {$i <89} {incr i} {
        set j [expr ($i+8)%12]
        
        set iy [expr 724 -$i*8]
        if {$iy >$iybot} continue
        if {$iy <$iytop} continue
        
        if {$j == 0} {
            set octave [expr $i/12 + 1]
            set legend [format "C%d" $octave]
            .piano.can create text $ix $iy -text $legend -tag ps -font $df
        }
        if {$j == 5} {
            set octave [expr $i/12 + 1]
            set legend [format "F%d" $octave]
            .piano.can create text $ix $iy -text $legend -tag ps -font $df
        }
    }
    
    
    set height [expr $iybot - $iytop +1]
    set width [expr $ixright -$ixleft ]
    .piano.can postscript -file piano.ps -y [expr $iytop - 1] \
            -height $height -fontmap fontMap -x [expr $ixleft +2] -width $width
    .piano.can delete -tag ps
    .piano.txt configure -text [format "piano.ps was created"] -foreground Black
}
# source pianops.tcl ends here




# Part 33.0         Solfege vocalization for abc editor

#source vocalize.tcl
# vocalize.tcl
#adds vocalization in w: lyrics.
#does not support accidentals.

set notekey "CDEFGABcdefgab"


proc solfege_vocalization {} {
    global abctxtw
    global body_start body_end
    set point [$abctxtw index insert]
    if {![info exist body_end]} return
    if {$point > $body_end} {set point $body_start.0}
    set keysig none
    set kfield [$abctxtw search -backwards K: $point]
    if {[string length $kfield] > 1} {
        set kfield [$abctxtw get $kfield  "$kfield lineend"]
        set keysig [string range $kfield 2 end]
        set keysig [string trimright $keysig]
    }
    #puts "keysig = $keysig"
    set tonic [key2number $keysig]
    
    set selrange [$abctxtw tag ranges sel]
    if {[llength $selrange] < 2} {
        messages "Please select an area in the body of the tune \
                and then try again. To select a region, hold the left mouse button \
                down and sweep an area."
        return
    } else {
        set selstart [lindex $selrange 0]
        set selend [lindex $selrange 1]
        
        set lselstart [lindex [split $selstart .] 0]
        set lselend  [lindex [split $selend .] 0]
        
        #puts "region $lselstart to $lselend"
        for {set linenum $lselend} {$linenum >= $lselstart} {incr linenum -1} {
            set line [$abctxtw get $linenum.0 $linenum.end]
            #puts $line
            if {[string length $line] < 2} continue
            set vocalization [vocalize_all_notes $line $tonic]
            $abctxtw insert [expr $linenum+1].0 $vocalization
        }
        $abctxtw tag remove sel 0.0 end
    }
}

proc vocalize_all_notes {buffer tonic} {
    #scans line for musical notes and shifts it up or down.
    #In order to continue from where we left off, we strip
    #off the part of string that we have already scanned,
    #  puts vocalize_all_notes
    set note_or_bar {[|]|[A-G]\,*|[a-g]\'*}
    # decorations regex explained:
    # (?n) - honor lines:  ^ and $
    # (\![^\!]*\!)           - !decoration!
    # (^[ \t]*%.*$)          - comment lines (lines beginning with %)
    # (^[ \t]*[A-Za-z]:.*$)  - keyword lines
    # (\![^\!]*\!)           - !decoration!
    # (\[[ \t]*\"[^\"]*\"))  - part strings "part1"   (probably should be any strings, including guitar chords)
    #   (\"[^\"]*\")         - guitar chords
    #   (\[.:[^]]*\])       - inline field command like [K: Gm]
    set decoration {(?n)((\![^\!]*\!)|(^[ \t]*%.*$)|(^[ \t]*[A-Za-z]:.*$)|(\[[ \t]*\"[^\"]*\"))|(\"[^\"]*\")|(\[.:[^]]*\])}
    set success 1
    set offset 0
    set result "w: "
    set space " "
    set start 0
    #  puts $buffer
    while {$success} {
        set success [regexp -indices $note_or_bar $buffer match]
        if {!$success} break
        set skip [regexp -indices $decoration $buffer match_skip]
        # if the decoration comes before the note then skip the decoration
        if {$skip && [lindex $match_skip 0] < [lindex $match 0]} {
            #    puts "match match_skip $match $match_skip"
            set pos2 [lindex $match_skip 1]
            set offset [expr $pos2 + 1]
            set buffer [string range $buffer $offset end]
        } else {
            set pos1 [lindex $match 0]
            set pos2 [lindex $match 1]
            set key [string range $buffer  $pos1 $pos2]
            #    puts $key
            if {$key != "|"}  {
                set result $result[vocalize_note $key $tonic]$space
                set start 1
            } else {
                # suppress bar line prior to first note
                if {$start > 0}  {
                    set result $result$key$space
                }
            }
            #puts "$key $vocal"
            set buffer [string range $buffer [expr $pos2 +1] end]
        }
    }
    # puts $result
    return $result\n
}


proc vocalize_note {note tonic} {
    global notekey
    set vocalization "do re me fa so la ti"
    set n1 [string first [string index $note 0] $notekey]
    set n [expr $n1 % 7]
    set n [expr $n - $tonic]
    if {$n < 0} {set n [expr $n + 7]}
    #puts "$note $n1 $n"
    set result [lindex $vocalization $n]
    return $result
}


proc key2number {keysig} {
    #from key signature computes number of sharps/flats, mode
    #and first key in scale.
    global notekey
    set s [regexp {([A-G]|none)(#*|b*)(.*)} $keysig match tonic sub2 sub3]
    if {$s < 1} {puts "can't understand key signature $keysig"
        return}
    #puts "$tonic $sub2 $sub3"
    set n1 [string first [string index $tonic 0] $notekey]
    set n [expr $n1 % 7]
    #puts "unadjusted tonic $n"
    if {[string compare $tonic "none"] == 0} {set tonic C}
    if {[string length $sub3] > 0} {set sub3 [string tolower $sub3]}
    if {[string length $sub3] > 3} {set sub3 [string range $sub3 0 2 ]}
    set mode [lsearch -exact "maj min m aeo loc ion dor phr lyd mix" $sub3]
    if {$mode == -1} {set mode 0}
    #puts "mode = $mode"
    if {$mode >= 0} {set tonic \
                [expr $n -  [lindex "0 5 5 5 6 0 1 2 3 4" $mode]]
        set tonic [expr $tonic % 7]
    }
    
    #puts "tonic is $tonic"
    return $tonic
}
#end of source vocalize.tcl


# Part 34.0        Drum Editor



#source drumeditor.tcl



proc get_drumpattern {} {
    global active_drumpattern
    global drumpatterns
    global cabcbar
    set cabcbar $drumpatterns(D$active_drumpattern)
    drum_bar_to_drumhits $cabcbar
}



set invfactor(*2) 1/2
set invfactor(*1) 1
set invfactor(/2) 2
set invfactor(/4) 4
global invfactor

proc drum_bar_to_drumhits {bar} {
    global revpatch drumtoolfactor midi
    global invdrummap
    global invfactor
    set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]|\]|\[|z)(/?[0-9]*|[0-9]*/*[0-9]*)}
    set selected_drums $midi(selected_drums)
    set i 0
    set col 0
    set chord "off"
    clear_all
    while {$i < [string length $bar]} {
        set success [regexp -indices -start $i $notepat $bar location]
        # search for notes
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            #puts [string range $bar $loc1 $loc2]
            regexp -start $i $notepat $bar var acc key dur
            if {$key == "\["} {set chord on}
            if {$dur == "" && $chord == "off"} {set dur 1}
            if {$key == "z" || $key == "]"} {
                set chord "off"
                set midino "none"} elseif {$key != "\["}  {
                if {$midi(drummap)} {
                    set midino [expr $invdrummap($acc$key) -35] } else {
                    set midino [expr $revpatch($acc$key) - 35]
                }
                set row [lsearch $selected_drums $midino]
                if {$row != -1} {
                    set r  r$row
                    set c  c$col
                    flipcolor $r$c
                }
            }
            if {$key == "]" && $dur == ""} {set dur 1}
            if {$dur != ""} {
                set timeunit [expr $dur*$invfactor($drumtoolfactor)]
                if {$timeunit == 0} {set timeunit [expr $invfactor($drumtoolfactor)*$dur]}
                incr col $timeunit
            }
            set i [expr $loc2+1]} else {incr i}
    }
}

proc setdpatno {n} {
    global active_drumpattern
    set active_drumpattern $n
    highlight_selected_drum_pattern $n
    get_drumpattern
}

proc highlight_selected_drum_pattern {sel} {
    for {set i 0} {$i < 8} {incr i} {
        if {$i != $sel} {
            .drumtool.pat.$i configure -borderwidth 2}
    }
    .drumtool.pat.$sel configure -borderwidth 5
}

proc new_drumpattern {} {
    global active_drumpattern
    global last_drumpattern
    global df
    #    set w .drumtool.ctl
    if {$last_drumpattern <= 7} {
        set active_drumpattern $last_drumpattern
        .drumtool.pat.$active_drumpattern configure -state normal
        highlight_selected_drum_pattern $active_drumpattern
        set token [.drumtool.pat.$active_drumpattern cget -text]
        #   button $w.$last_drumpattern -text $token -command "add_drumvoice_token $token" -font $df
        #        pack $w.$last_drumpattern -side left
        incr last_drumpattern
    }
}

proc save_drumpatterns {} {
    global last_drumpattern
    global drumpatterns
    global midi
    global drumtoolmeter drumtoollength drumbeatstring drumtoolfactor
    global rhythmpattern
    global drum_f drum_m drum_p
    set handle [open $midi(drumpatfile) w]
    puts $handle "set rhythmpattern \"$rhythmpattern\""
    puts $handle "set midi(selected_drums) \"$midi(selected_drums)\""
    puts $handle "set drumtoolmeter $drumtoolmeter"
    puts $handle "set drumtoollength $drumtoollength"
    puts $handle "set drumtoolfactor $drumtoolfactor"
    puts $handle "set drumbeatstring $drumbeatstring"
    puts $handle "set drum_f $drum_f"
    puts $handle "set drum_m $drum_m"
    puts $handle "set drum_p $drum_p"
    
    for {set i 0} {$i < $last_drumpattern} {incr i} {
        set s $drumpatterns(D$i)
        set s [string map {\[ \\\[ \] \\\]} $s]
        puts $handle "set drumpatterns(D$i) \"$s\""
    }
    close $handle
    drumvoice_msg "$midi(drumpatfile) was updated"
}

proc drumtool_gui_setup {} {
    # Graphics User Interface
    global p
    global df midi
    global drumpatterns
    global active_drumpattern
    global last_drumpattern
    global files
    global drumtoolmeter drumtoollength drumtoolfactor
    global drumbeatstring
    global drum_f drum_m drum_p
    global cabcbar
    global drumtempo
    global rhythmpattern
    global drumentry

    set drumtoolfactor *1
    set drum_f $midi(beat_a)
    set drum_m $midi(beat_b)
    set drum_p $midi(beat_c)
    set drumtempo 160
    set rhythmpattern "4 4"
    set drumbeatstring ""
    set files X1.mid
    if {[winfo exist .drumtool]} return
    toplevel .drumtool
    position_window ".drumtool"
    set p .drumtool.f
    frame $p
    button $p.save -text save -font $df -command save_drumpatterns
    button $p.select -text selector -font $df -command drumkey
    button $p.cfg -text configure -font $df -command config_drumtool
    button $p.clear -text "clear everything" -command clear_everything -font $df
    button $p.help -text help -font $df\
            -command {show_message_page $hlp_drumtool word}
    
    pack $p.save  $p.clear $p.select  $p.cfg $p.help -side left
    
    
    
    set p .drumtool.cav
    frame $p
    canvas $p.can -width 400
    canvas $p.cany -width 140
    pack $p.cany $p.can -side left -anchor w
    
    
    set p .drumtool.abcbar
    frame $p
    label $p.barlab -text "abc bar" -font $df
    entry $p.bar -textvariable cabcbar -width 60 -font $df
    pack $p.barlab $p.bar -side left
    
    
    set p .drumtool.pat
    frame $p
    button $p.new -text new -command new_drumpattern -font $df
    pack  $p.new  -side left
    
    for {set i 0} {$i < 8} {incr i} {
        button $p.$i -text D$i -font $df -command "setdpatno $i" -state disabled
        pack  $p.$i -side left
        set drumpatterns(D$i) ""
        bind $p.$i <3> {play_bar 2}
    }
    
    pack .drumtool.f -side top -anchor w
    pack .drumtool.cav -side top -anchor w
    pack .drumtool.abcbar -side top -anchor w
    pack .drumtool.pat -side top -anchor w
    
    $p.0 configure -state normal
    label .drumtool.msg  -text "" -font $df
    pack .drumtool.msg
    
    set active_drumpattern 0
    set last_drumpattern 0
    set drumtoolmeter 4/4
    set drumtoollength 1/8
    
    load_drumsel
    setup_drum_grid
    init_drum_hits
    #drumvoice_gui
    load_drumpatterns
    if {$drumentry == "none" || $drumentry == "default"} return
    if {$midi(drummap)} {drum2map $drumentry)}
}


global lineindex
set lineindex 0

proc drumvoice_msg {msg} {
    .drumtool.msg configure -text $msg
}

proc config_drumtool {} {
    global df midi drumtempo
    global drumtoolmeter drumtoollength drumbeatstring drumtoolfactor
    global rhythmpattern
    global last_drumpattern
    if {![winfo exist .cfg_drumtool]} {
        toplevel .cfg_drumtool
        position_window ".cfg_drumtool"
        set p .cfg_drumtool
        button $p.help -font $df -text help\
                -command {show_message_page $hlp_drumtool_cfg word}
        label $p.filelabel -font $df -text file
        entry $p.fileent -width 18 -textvariable midi(drumpatfile) -font $df
        button $p.filebut -text enter -font $df -command {clear_everything
            set last_drumpattern [load_drumpatterns]
            focus .cfg_drumtool.filelabel
            setup_drum_grid}
        label $p.meterlab -font $df -text "meter M:"
        entry $p.meterent -font $df -width 5 -textvariable drumtoolmeter
        button $p.meterbut -font $df -text enter -command drumtool_consistency
        label $p.lengthlab -font $df -text "unit length L:"
        entry $p.lengthent -font $df -width 5 -textvariable drumtoollength
        button $p.lengthbut -font $df -text enter -command drumtool_consistency
        scale $p.tempo -from 0 -to 400 -length 100 -width 4 -resolution 10 -orient horizontal -variable drumtempo -font $df
        label $p.beatlab -text beat -font $df
        label $p.tempolab -text tempo -font $df
        entry $p.rhythm -textvariable rhythmpattern -width 12 -font $df
        button $p.rhythmbut -text enter -font $df -command {drumtool_consistency
            setup_drum_grid}
        label $p.beatstringlab -text beatstring -font $df
        tooltip::tooltip .cfg_drumtool.beatstringlab  "use f,m,p to indicate strong,medium and weak beats eg. f3m2p2"
        entry $p.beatstring -width 20 -font $df -textvariable drumbeatstring
        button $p.beatbut -text enter -font $df -command drumtool_consistency
        label $p.msg -text "" -font $df
        frame $p.beat
        label $p.beat.f -text f -font $df
        entry $p.beat.fe -width 3 -font $df -textvariable drum_f
        label $p.beat.m -text m -font $df
        entry $p.beat.me -width 3 -font $df -textvariable drum_m
        label $p.beat.p -text p -font $df
        entry $p.beat.pe -width 3 -font $df -textvariable drum_p
        pack $p.beat.f $p.beat.fe $p.beat.m $p.beat.me $p.beat.p $p.beat.pe -side left
        label $p.midibeatlab -text "MIDI beat" -font $df
        
        
        grid $p.help
        grid $p.filelabel $p.fileent $p.filebut
        grid $p.meterlab $p.meterent $p.meterbut
        grid $p.lengthlab $p.lengthent $p.lengthbut
        grid $p.beatlab $p.rhythm $p.rhythmbut
        grid $p.beatstringlab $p.beatstring $p.beatbut
        grid $p.midibeatlab $p.beat
        grid $p.tempolab $p.tempo
        grid $p.msg -columnspan 3
        bind $p.rhythm  <Return> {setup_drum_grid
            drumtool_consistency}
        bind $p.meterent <Return> drumtool_consistency
        bind $p.lengthent <Return> drumtool_consistency
        bind $p.beatstring <Return> drumtool_consistency
    }
}

proc check_beatstring {input length} {
    set charlist [split $input ""]
    set beatstringlength [string length $input]
    if {$beatstringlength != 0 && $beatstringlength !=  $length} {
        cfg_drumtool_msg "beatstring length is $beatstringlength
        it should be $length"
        return 1
    }
    foreach letter $charlist {
        if {$letter == "f"} continue
        if {$letter == "m"} continue
        if {$letter == "p"} continue else {
            puts "letter = $letter"
            cfg_drumtool_msg "only f,m, and p are allowed in the beastring"
            return 1
        }
    }
    return 0
}

proc drumtool_consistency {} {
    global df drumtoolfactor
    global drumtoolmeter drumtoollength drumbeatstring
    global rhythmpattern
    focus .cfg_drumtool.filelabel
    scan $drumtoolmeter "%d/%d" num denom
    set rhythm $rhythmpattern
    set subbeats 0
    foreach n $rhythm {
        incr subbeats $n
    }
    set ratio [expr $subbeats/double($num)]
    if {!($ratio == 1 || $ratio == 2 || $ratio == 4)} {
        set msg "summation of beat $rhythm = $subbeats should be $num, [expr 2*$num], or [expr 4 *$num]"
        cfg_drumtool_msg $msg
        return
    }
    set ratio1 [expr 32 * $drumtoollength * $subbeats /32.0]
    set ratio2 [expr 32 * $drumtoolmeter /32.0]
    set ratio [expr $ratio2/$ratio1]
    switch $ratio {
        0.25 {set drumtoolfactor /4}
        0.5 {set drumtoolfactor /2}
        1.0 {set drumtoolfactor *1}
        2.0 {set drumtoolfactor *2}
        4.0 {set drumtoolfactor *4}
    }
    if {[check_beatstring $drumbeatstring $subbeats]} return
    set msg ""
    cfg_drumtool_msg $msg
    #puts "drumtoolfactor= $drumtoolfactor"
}

proc cfg_drumtool_msg {msg} {
    .cfg_drumtool.msg configure -text $msg
}

proc add_drumvoice_token {token} {
    global lineindex
    global drlinetok
    global font df
    set selected [make_selected_drumvoice_list]
    if {[llength $selected]} {
        foreach i $selected {
            .drumtool.line.$i configure -text $token
        }
    } else {
        checkbutton .drumtool.line.$lineindex -text $token -indicatoron 0 -variable drlinetok($lineindex) -font $df
        pack .drumtool.line.$lineindex -side left
        incr lineindex
    }
    drumvoice_msg ""
}

proc delete_last_drumvoice_token {} {
    global lineindex
    incr lineindex -1
    destroy .drumtool.line.$lineindex
    drumvoice_msg ""
}

proc make_selected_drumvoice_list {} {
    global lineindex drlinetok
    set drumvoice_list ""
    for {set i 0} {$i < $lineindex} {incr i} {
        if {$drlinetok($i) == 1} {
            set drumvoice_list [lappend drumvoice_list $i]
        }
    }
    return $drumvoice_list
}


proc load_drumpatterns {} {
    global drumpatterns df
    global midi
    global drumtoolmeter drumtoollength drumbeatstring drumtoolfactor
    global drum_f drum_m drum_p
    global rhythmpattern
    global last_drumpattern
    if {![file exist $midi(drumpatfile)]} {return 0}
    set handle [open $midi(drumpatfile) r]
    set n 0
    set line " "
    while {[eof $handle] != 1} {
        if {[string length $line] < 1} break
        gets $handle line
        eval $line
        if {[string first "drumpatterns" $line] > 0} {incr n}
    }
    create_abc_drum_rep
    
    for {set i 0} {$i < $n} {incr i} {
        .drumtool.pat.$i configure -state normal
        set name p$i
    }
    close $handle
    drumvoice_msg "$midi(drumpatfile) was loaded"
    set last_drumpattern $n
    return [expr $i]
}


proc createdrumfile {filename} {
    global drumtoolmeter drumtoollength drumbeatstring drumtempo
    global drum_f drum_m drum_p
    global midi
    set outhandle [open $filename w]
    puts $outhandle "X:1\nT:1 drum tune\nM:$drumtoolmeter\nL:$drumtoollength\nQ:1/4=$drumtempo\nK:C"
    if {$drumbeatstring != ""} {
        puts $outhandle "%%MIDI beatstring $drumbeatstring"
        puts $outhandle "%%MIDI beat $drum_f $drum_m $drum_p 2"
    }
    if {$midi(drummap)} {puts -nonewline $outhandle [output_drummap]}
    set body [create_drumbody]
    puts $outhandle $body
    close $outhandle
    drumvoice_msg "$filename was created"
}

proc create_drumbody {} {
    global drumpatterns
    set body "%%MIDI channel 10\n"
    set tokenlist [create_drum_token_list]
    foreach token $tokenlist {
        if {$token == ":|"} {
            set last [expr [string length $body] -2]
            set body [string replace $body $last end]
            set body "$body $drumpatterns($token)"
        } elseif {[string index $token 0] == "p"} {
            set body "$body $drumpatterns($token)|\n"
        } else {
            set body "$body $drumpatterns($token)"
        }
    }
    return $body
}


proc drum_to_clipboard {} {
    global drumtoollength drumbeatstring drumtoolmeter
    global drum_f drum_m drum_p
    global midi
    clipboard clear
    set body [create_drumbody]
    clipboard append "V: drum\n"
    clipboard append "M: $drumtoolmeter\n"
    clipboard append "L: $drumtoollength\n"
    if {$drumbeatstring != ""} {clipboard append "%%MIDI $drumbeatstring\n"
        clipboard append "%%MIDI beat $drum_f $drum_m $drum_p 2\"
    }
    if {$midi(drummap)} {clipboard append [output_drummap]}
    clipboard append $body
    drumvoice_msg "drum voice was saved in the clipboard"
}

proc play_drumline {} {
    global midi files
    createdrumfile X.tmp
    set cmd "file delete [glob -nocomplain X*.mid]"
    catch {eval $cmd}
    set cmd "exec $midi(path_abc2midi) X.tmp"
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files X1.mid
    update_console_page
    play_midis 1
}

proc create_drum_token_list {} {
    global lineindex
    set tokenlist ""
    for {set i 0} {$i < $lineindex} {incr i} {
        set token [.drumtool.line.$i cget -text]
        set tokenlist [lappend tokenlist $token]
    }
    return $tokenlist
}




proc drum_abchead {} {
    global drumtoolmeter drumtoollength drumbeatstring drumtoolfactor drumtempo
    global drum_f drum_m drum_p
    set abchead "X:1\nT:drum\nM:$drumtoolmeter\nL:$drumtoollength\nQ:1/4=$drumtempo\nK:C\n%%MIDI channel 10\n%%MIDI chordattack 50\n"
    if {[info exist drumbeatstring]} {
        set abchead "$abchead%%MIDI beatstring $drumbeatstring\n%%MIDI beat $drum_f $drum_m $drum_p 2\n"
    }
    return $abchead
}


proc make_random_drumsel {n max} {
    global drumsel midi
    for {set i 0} {$i < $n} {incr i} {
        set j [expr int($max*rand())]
        set drumsel($j) 1
    }
    set midi(selected_drums) [return_selected_drumsel]
}


proc pick_random_drum {} {
    global midi
    set size [llength $midi(selected_drums)]
    set n [expr int(rand()*$size)]
    set m [lindex $midi(selected_drums) $n]
    return [expr $m + 35]
}


proc flipcolor {tagid} {
    global  drumhits
    global drumpatterns active_drumpattern
    global cabcbar
    
    scan $tagid "r%dc%d" row col
    #puts "flipcolor drumhits($col) = $drumhits($col)"
    set index [lsearch $drumhits($col) $row]
    #puts $index
    if {$index >= 0} {
        set drumhits($col) [lreplace $drumhits($col) $index $index]
        .drumtool.cav.can itemconfigure $tagid -fill white
    } else {
        lappend drumhits($col) $row
        .drumtool.cav.can itemconfigure $tagid -fill black
    }
    set abcbar [create_abc_drum_rep]
    set cabcbar [compress_rests $abcbar]
    set drumpatterns(D$active_drumpattern) $cabcbar
}

proc clear_all {} {
    global  drumhits
    global active_drumpattern
    global cabcbar ntatum
    for {set k 0} {$k < $ntatum} {incr k} {
        set col c$k
        set drumhits($k) ""
        for {set j 0} {$j < 47} {incr j} {
            set row r$j
            .drumtool.cav.can itemconfigure $row$col -fill white
        }
    }
    set abcbar [create_abc_drum_rep]
    set cabcbar [compress_rests $abcbar]
    set drumpatterns(D$active_drumpattern) $cabcbar
}



proc clear_everything {} {
    global  drumhits cabcbar ntatum
    global last_drumpattern
    for {set i 0} {$i < $last_drumpattern} {incr i} {
        for {set k 0} {$k < $ntatum} {incr k} {
            set col c$k
            set drumhits($k) ""
            for {set j 0} {$j < 47} {incr j} {
                set row r$j
                .drumtool.cav.can itemconfigure $row$col -fill white
            }
        }
        set abcbar [create_abc_drum_rep]
        set cabcbar [compress_rests $abcbar]
        set drumpatterns(D$i) $cabcbar
        .drumtool.pat.$i configure -state disable
        destroy .drumtool.ctl.$i
    }
    set last_drumpattern 0
}


proc setup_drum_grid {} {
    global drumhits midi drumsel drumpatches df ntatum
    global rhythmpattern
    set p .drumtool.cav
    if {![winfo exist $p]} return
    $p.can delete all
    $p.cany delete all
    set m 0
    set selected_drums ""
    set k 0
    for {set j 0} {$j < 47} {incr j} {
        if $drumsel($j) {
            lappend selected_drums $j
            set iy [expr $m*20 + 10]
            set iy2 [expr $iy +12]
            set ix 5
            set str [lindex [lindex $drumpatches $j] 2]
            $p.cany create text 5 $iy -text $str -anchor w -tag p$j -font $df
            $p.cany bind p$j <1> "play_patch $j"
            $p.cany configure -height $iy2
            $p.can configure -height $iy2
            set k 0
            foreach tatum $rhythmpattern {
                for {set i 0} {$i < $tatum} {incr i} {
                    set ix2 [expr $ix + 12]
                    set col c$k
                    set row r$m
                    $p.can create rect $ix $iy $ix2 $iy2 -tag $row$col -fill white
                    $p.can bind $row$col <1> "flipcolor $row$col"
                    set drumhits($k) ""
                    incr k
                    incr ix 20
                }
                incr ix 5
            }
            incr m
        }
    }
    set ntatum $k
    set midi(selected_drums) $selected_drums
}




proc play_patch {no} {
    global drumpatches
    global midi
    set abchead [drum_abchead]
    #  puts "play $no"
    set note [lindex [lindex $drumpatches $no] 1]
    #  puts $note
    set abcfile $abchead$note
    set outfd [open X.tmp w]
    puts $outfd $abcfile
    close $outfd
    set cmd "exec $midi(path_abc2midi) X.tmp"
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    catch {eval $cmd} exec_out
    set files X1.mid
    play_midis 1
}


proc init_drum_hits {} {
    global drumhits ntatum
    for {set i 0} {$i <$ntatum} {incr i} {set drumhits($i) ""}
}


proc create_abc_drum_rep {} {
    global midi tat ntatum
    global drumhits
    global drumpatches
    global drumsel
    global drummap
    set length ""
    set backbracket \]
    set abcbar ""
    set selected_drums [return_selected_drumsel]
    set midi(selected_drums) $selected_drums
    #puts "selected_drums $selected_drums"
    for {set i 0} {$i <$ntatum} {incr i} {
        #puts "drumhits($i) = $drumhits($i)"
        set ldrumhits [llength $drumhits($i)]
        if {!$ldrumhits} {
            set abcbar [concat $abcbar "z$length "]
        } elseif {$ldrumhits == 1} {
            set note_index $drumhits($i)
            if {$note_index >= 0} {
                set patch_index [lindex $selected_drums $note_index]
                if {$midi(drummap)} {
                    set note $drummap([expr $patch_index+35])} else {
                    set note [lindex [lindex $drumpatches $patch_index] 1]
                }
                set note $note$length
            } else {set note z}
            #puts "note = $note"
            set abcbar [concat $abcbar $note ]
        } else {
            set chord "\["
            foreach note_index $drumhits($i) {
                if {$note_index >= 0} {
                    set patch_index [lindex $selected_drums $note_index]
                    if {$midi(drummap)} {
                        set note $drummap([expr $patch_index+35])} else {
                        set note [lindex [lindex $drumpatches $patch_index] 1]
                    }
                    set note $note$length } else  {set note ""}
                set chord  $chord$note
            }
            set chord $chord$backbracket
            #puts "chord = $chord"
            set abcbar [concat $abcbar "$chord "]
        }
    }
    #puts "abcbar = $abcbar"
    return $abcbar
}

proc reduce {fraction} {
    set lfraction [split $fraction /]
    set a [lindex $lfraction 0]
    set b [lindex $lfraction 1]
    if {$a > $b} {
        set n  $a
        set m  $b
    } else {
        set n $b
        set m $a
    }
    while {$m != 0} {
        set t [expr $n % $m]
        set n $m
        set m $t
    }
    set a [expr $a/$n]
    set b [expr $b/$n]
    return $a/$b
}

proc evalmath {mathexp} {
    if {[string first * $mathexp ] != -1} {
        return [expr $mathexp]
    } elseif {[string first / $mathexp ] != -1} {
        set lexp [split $mathexp /]
        set a [lindex $lexp 0]
        set b [lindex $lexp 1]
        if {[expr $a % $b] == 0} {
            return [expr $a/$b]
        } else {
            set val [reduce $mathexp]
            return $val
        }
    } else {return $mathexp}
}



proc compress_rests {drumbar} {
    global midi drumtoolfactor
    global rhythmpattern
    #puts "compress_rests $drumbar"
    set i 0
    set s " "
    set compressedbar ""
    foreach beat $rhythmpattern {
        set note [lindex $drumbar $i]
        set count 1
        for {set j 1} {$j <$beat} {incr j} {
            incr i
            set nextnote [lindex $drumbar $i]
            if {$nextnote == "z"} {
                incr count
            } else {
                set value [evalmath $count$drumtoolfactor]
                if {$value == 1} {set value ""}
                set compressedbar $compressedbar$note$value
                set note  $nextnote
                set count 1}
        }
        set value [evalmath $count$drumtoolfactor]
        if {$value == 1} {set value ""}
        set compressedbar $compressedbar$note$value
        incr i
        set compressedbar $compressedbar$s
    }
    return $compressedbar
}

proc play_drum_pattern {bar times} {
    global midi files
    set abchead [drum_abchead]
    if {$midi(drummap)} {set abchead $abchead[output_drummap]}
    set abcfile $abchead$bar|
    if {$times > 1} {set abcfile $abcfile$bar|}
    if {$times > 2} {set abcfile $abcfile$bar|}
    #puts $abcfile
    set outfd [open X.tmp w]
    puts $outfd $abcfile
    close $outfd
    set cmd "exec $midi(path_abc2midi) X.tmp"
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files X1.mid
    play_midis 1
}

proc play_bar {times} {
    set bar [create_abc_drum_rep]
    set bar [compress_rests $bar]
    play_drum_pattern $bar $times
    return $bar
}



proc convert_drumhits_to_list {} {
    global drumhits
    global ntatum
    set drumhitslist {}
    for {set i 0} {$i < $ntatum} {incr i} {
        lappend drumhitslist $drumhits($i)
    }
    puts "drumhitslist $drumhitslist"
    return $drumhitslist
}






#end of source drumeditor.tcl

proc random_arrangement {} {
    global chan window
    set chan program
    set num [expr int(rand()*128)]
    set p1 [expr 1 + $num/8]
    set p2 [expr $num % 8]
    set window .abc.midi1.melody.melodybut
    program_select $p1 $p2
    set chan chordprog
    set num [expr int(rand()*128)]
    set p1 [expr 1 + $num/8]
    set p2 [expr $num % 8]
    set window .abc.midi1.chord.chordbut
    program_select $p1 $p2
    set chan bassprog
    set num [expr int(rand()*128)]
    set p1 [expr 1 + $num/8]
    set p2 [expr $num % 8]
    set window .abc.midi1.bass.bassbut
    program_select $p1 $p2
}



proc replace_edited_tune {} {
    global midi
    set abcfile $midi(abc_open)
    global copyfromloc copytoloc
    set inhandle [open $abcfile r]
    set outhandle [open runabc_out.abc w]
    set done 0
    while {[eof $inhandle] != 1} {
        set loc [tell $inhandle]
        gets $inhandle line
        if {$loc < $copyfromloc || $loc >= $copytoloc} {
            puts $outhandle $line
        } else {
            if {!$done} { paste_abcedit_text $outhandle
                set done 1
            }
        }
    }
    close $inhandle
    close $outhandle
    set backup_abcfile $abcfile.bak
    file rename -force $abcfile $backup_abcfile
    file rename -force runabc_out.abc $abcfile
    destroy .abcedit
    show_console_page "backup copy stored in $backup_abcfile" char
    #title_index $midi(abc_open)
    title_selected
}

proc paste_abcedit_text {outhandle} {
    global midi
    global abctxtw
    set start 1.0
    set end end
    foreach {key value index} [$abctxtw dump $start $end] {
        if {$key == "text"} {
            puts -nonewline $outhandle $value}
    }
    if {$midi(bell_on)} bell
}



# Part 35.0               Gchord to voice

#abcg2v.tcl

# The functions in this file scan a tune in a
# abc file and produce a new tune with the
# guitar chords (gchords) replaced with a separate
# voice where they have been replaced by notes.
# For example the body:
#
# %%MIDI gchord fzcz
# |: cB | "F"A2F2 FAGF |
# "C7"EGB2 BdcB |"F"Acde "Dm"fagf :|
#
# is replaced with
#
# V:1
# |: cB | A2F2 FAGF |
# EGB2 BdcB |Acde fagf :|
# V:chords
# |: z2 |F,,z[F,A,C]z |
# C,,z[C,E,G,B,]z |F,,z[D,F,A,]z :|

# The guitar chords are expanded into accompaniment
# using the same convention as abc2midi; however,
# the gchord string cannot be arbitrary so that they
# can be represented by musical symbols. (See abcguide.txt
# which comes with the abcMIDI package for more details
# regarding guitar chords.)

# Method: we need the key signature, time signature,
# unit length (L:1/?) and gchord string to determine
# how to expand the guitar chords. In the music body,
# we only care about the note durations. All other
# information is ignored. For each note in the body
# we call gchord_generator, which decides whether
# to add another note or chord sequence into the
# chord voice (stored in chordvoice).
#
# For each music part (P:A, P:B etc,) we store the
# music bodytext and the expanded chords in separate
# strings. When we finish we dump everything out
# producing a new abc file.



#key.tcl

# this array is used to determine the key equivalency of the
# different modes, dorian, phrygian, etc.
array set modeshift {
    maj 0
    min -3
    m -3
    aeo -3
    loc -5
    ion 0
    dor -2
    phr -4
    lyd 1
    mix -1
}

# sequence of notes in a chromatic scale assuming sharps
array set sharpnotes {
    0 C
    1 ^C
    2 D
    3 ^D
    4 E
    5 F
    6 ^F
    7 G
    8 ^G
    9 A
    10 ^A
    11 B
}

# sequence of notes in a chromatic scale assuming flats
array set flatnotes {
    0 C
    1 _D
    2 D
    3 _E
    4 E
    5 F
    6 _G
    7 G
    8 _A
    9 A
    10 _B
    11 B
}

# key2sf {keysig}
# It interprets the key signature string in the K: command
# and determines the number of sharps/flats that are placed
# on the staff. For example Bb major has two flats so sf = -2
proc key2sf {keysig} {
    global modeshift
    set key "FCGDAEB"
    set s [regexp {([A-G]|none)(#*|b*)(.*)} $keysig match tonic accid mode]
    if {$s < 1} {puts "can't understand key signature $keysig"
        return}
    set sf [string first [string index $tonic 0] $key]
    incr sf -1
    if {$accid == "#"} {incr sf 7}
    if {$accid == "b"} {incr sf -7}
    set mode [string tolower $mode]
    if {[info exist modeshift($mode)]} {
        set sf \ [expr $sf + $modeshift($mode)]  }
    return $sf
}


# setupkey {sf}
# sets up table to convert MIDI pitches to
# notes taking into account the key signature
proc setupkey {sf} {
    global basekeytable
    global sharpnotes flatnotes
    #if {$sf == 0} return
    if {$sf >= 0} {
        for {set i 0} {$i < 12} {incr i} {
            set basekeytable($i) $sharpnotes($i)
        }
        for {set i 1} {$i <= $sf} {incr i} {
            switch $i {
                1 {set basekeytable(5) =F
                    set basekeytable(6) F}
                2 {set basekeytable(0) =C
                    set basekeytable(1) C}
                3 {set basekeytable(7) =G
                    set basekeytable(8) G}
                4 {set basekeytable(2) =D
                    set basekeytable(3) D}
                5 {set basekeytable(9) =A
                    set basekeytable(10) A}
                6 {set basekeytable(4) =E
                    set basekeytable(5) E}
                7 {set basekeytable(11) =B
                    set basekeytable(0) B}
            }
        }
        return
    }
    if {$sf < 0} {
        for {set i 0} {$i < 12} {incr i} {
            set basekeytable($i) $flatnotes($i)
        }
        for {set i -1} {$i >= $sf} {incr i -1} {
            switch -- $i {
                -1 {set basekeytable(10) B
                    set basekeytable(11) =B
                }
                -2 {set basekeytable(3) E
                    set basekeytable(4) =E}
                -3 {set basekeytable(8) A
                    set basekeytable(9) =A}
                -4 {set basekeytable(1) D
                    set basekeytable(2) =D}
                -5 {set basekeytable(6) G
                    set basekeytable(7) =G}
                -6 {set basekeytable(11) C
                    set basekeytable(0) =C}
                -7 {set basekeytable(4) F
                    set basekeytable(5) =F}
                default {puts "nothing done for $i"}
            }
        }
        return
    }
}

proc resetkeytable {} {
    # copies basekeytable to keytable
    global keytable basekeytable
    array set keytable [array get basekeytable]
}


#converts MIDI pitch to abc music notation note
proc midi2key {midipitch} {
    global keytable
    set midi12 [expr $midipitch % 12]
    set octave [expr $midipitch / 12]
    set note $keytable($midi12)
    #propagate accidentals across the bar
    if {[string index $note 0] == "^"} {
        set keytable($midi12) [string index $note 1]
        set keytable([expr $midi12 -1]) "=[string index $note 1]"
    } elseif {
        [string index $note 0] == "_"} {
        set keytable($midi12) [string index $note 1]
        set keytable([expr $midi12 +1]) "=[string index $note 1]"
    } elseif {
        [string index $note 0] == "="} {
        set keytable($midi12) [string index $note 1]
    }
    
    if {$octave == 3} {return $note,,}
    if {$octave == 4} {return $note,}
    return $note
}

#end of key.tcl



#tempo.tcl

namespace eval gchordsetup {
    
    variable default_gchord
    variable gchordstring
    variable barunits
    variable noteunits
    
    global hasgchordstring
    
    set default_gchord(2/2) fzczfzcz
    set default_gchord(2/4) fzczfzcz
    set default_gchord(4/4) fzczfzcz
    set default_gchord(3/4) fzczcz
    set default_gchord(6/8) fzcfzc
    set default_gchord(12/8) fzcfzcfzcfzc
    
    # setup_meter {line}
    # Handles M: command
    proc setup_meter {line} {
        variable default_gchord
        variable gchordstring
        variable barunits
        variable noteunits
        if {[string first "C|" $line] >= 0} {
            set m1 2
            set m2 2} elseif {
            [string first "C" $line] >= 0} {
            set m1 4
            set m2 4} else {
            set r [scan $line "M:%d/%d" m1 m2]}
        set barunits [expr 4*384 * $m1 /$m2]
        set meter $m1/$m2
        if {[info exist default_gchord($meter)]} {
            set gchordstring $default_gchord($meter)
            set gcstring::gcstringlist [gcstring::scangchordstring $gchordstring]
        } elseif {$hasgchordstring} {
            g2v_errormsg "MIDI gchord string embedded in abc file"
        } else {
            g2v_errormsg  "no default gchord string for this meter"
        }
        if {[info exists noteunits]} return
        if {[expr double($m1)/$m2] < 0.75} {
            setup_unitlength L:1/16} else {
            setup_unitlength L:1/8}
        
    }
    
    #Handles L: command
    proc setup_unitlength {line} {
        variable noteunits
        set r [scan $line "L:%d/%d" m1 m2]
        set noteunits [expr 384 *4* $m1 /$m2]
    }
}

#end tempo.tcl




namespace eval gchordspace {
    #gchord.tcl
    
    # The guitar chord indications in the body of the abc file
    # need to be translated in actual notes. Guitar chords
    # can be quite complex and contain inversions (eg GM7/D).
    # Also the notes need to be translated to the current
    # key signature to avoid a proliferation of accidentals.
    # (We do not account for propagation of accidentals
    # inside a bar.)
    
    # The results are stored in the lists midichord and
    # gchordnotes. bassnote is the note corresponding to
    # f in the gchord string.
    
    
    # This array indicates the offsets in semitones of the notes
    # in the different chords
    
    variable chordnames
    
    array set chordnames {
        Maj  {0 4 7}
        m {0 3 7}
        7 {0 4 7 10}
        m7 {0 3 7 10}
        m7b5 {0 3 6 10}
        maj7 {0 4 7 11}
        M7 {0 4 7 11}
        6 {0 4 7 9}
        m6 {0 3 7 9}
        aug {0 4 8}
        plus {0 4 8}
        aug7 {0 4 8 10}
        dim {0 3 6}
        dim7 {0 3 6 9}
        9 {0 4 7 10 2}
        m9 {0 3 7 10 2}
        maj9 {0 4 7 11 2}
        M9 {0 4 7 11 2}
        11 {0 4 7 10 2 5}
        dim9 {0 4 7 10 13}
        sus {0 5 7}
        sus9 {0 2 7}
        7sus4 {0 5 7 10}
        7sus9 {0 2 7 10}
        5 {0 7}
    }
    
    # expandgchord {gchord}
    # The function interprets a gchord (enclosed by a pair of double quotes) in
    # the music body and returns the equivalent notes forming the bass/chordal
    # accompaniment in the variables bassnote and gchordnotes.
    proc expandgchord {gchord} {
        global notekey
        variable chordnames
        global notescale
        global gchordnotes
        global bassnote
        set chord {}
        set inverpat {(.+)/(.+)}
        # check for inversion
        set inversion -1
        if {[regexp $inverpat $gchord match a b]} {
            set gchord $a
            set invert $b
            set s [regexp {([A-G]|[a-g]|)(#*|b*)} $invert match note accid]
            if {$s <1} {puts "cannot understand inversion"}
            set n1 [string first [string index $note 0] $notekey]
            set n [expr $n1 % 7]
            set inversion [lindex $notescale $n]
            if {$accid == "#"} {incr inversion}
            if {$accid == "b"} {incr inversion -1}
        }
        
        set s [regexp {([A-G]|[a-g]|none)(#*|b*)(.*)} $gchord match bass accid type]
        if {$s < 1} {puts "can't understand chord $gchord"
            return}
        set n1 [string first [string index $bass 0] $notekey]
        set n [expr $n1 % 7]
        if {[string compare $bass "none"] == 0} {set bass C}
        set basspitch [lindex $notescale $n]
        if {$accid == "#"} {incr basspitch}
        if {$accid == "b"} {incr basspitch -1}
        #if {[string length $sub3] > 3} {set type [string range $type 0 2 ]}
        if {$type == ""} {set type Maj}
        
        if {![info exist chordnames($type)]} {
            g2v_errormsg "no such chord $type"
            return
        }
        set midichordnotes {}
        foreach pitch $chordnames($type) {
            set midipitch [expr $pitch + $basspitch]
            lappend midichordnotes $midipitch
        }
        
        set inchord 0
        set j 0
        if {$inversion != -1} {
            foreach pitch $midichordnotes {
                if {$pitch == $inversion} {set inchord $j}
                incr j
            }
        }
        
        # Converts the gchord representation to the
        # bassnote and the list of notes in the chord.
        # For example Gmaj translates to bassnote G,,
        # and gchordnotes {G, B, D}.
        set gchordnotes {}
        set j 0
        set bassnote [midi2key [expr $basspitch + 36]]
        foreach pitch $midichordnotes {
            set midipitch [expr $pitch +48]
            if {$j < $inchord} {incr midipitch 12}
            lappend gchordnotes [midi2key $midipitch]
            incr j
        }
    }
}

#end gchord.tcl






#gcstring.tcl
namespace eval gcstring {
    variable gcstringlist
    variable gchordunitlength
    variable gc_string_length
    
    proc process_MIDI_gchord_command line {
        variable gcstringlist
        variable gchordunitlength
        global expandedchords
        # Interpret the %%MIDI gchord command, eg. %%MIDI gchord fzcz.
        g2v_errormsg  "using gchord string embedded in tune"
        set words [regexp -inline -all -- {\S+} $line]
        set cmd [lindex $words 1]
        set gchordstring [lindex $words 2]
        set gcstringlist [scangchordstring $gchordstring]
        gcgen::setup_gchord_generator
        set gchordunitlength [return_gchord_unitlength]
        if {[info exist expandedchords]} {
            set expandedchords $expandedchords$gchordunitlength\n} else {
            set expandedchords $gchordunitlength\n}
    }
    
    proc process_MIDI_drum_command line {
        global midi
        global expandeddrums
        variable drumunitlength
        g2v_errormsg  "using drum string embedded in tune"
        set pos [string first "drum" $line]
        set pos [expr $pos +5]
        set line [string range $line $pos end]
        set drumpat $line
        drumgen::setup_drum_generator $drumpat
        set drumunitlength [return_d_unitlength]
        set expandeddrums $expandeddrums$drumunitlength\n
        if {$midi(drummap)} {
            set expandeddrums $expandeddrums[output_drummap]
        }
    }
    
    
    proc scangchordstring {gc} {
        # Expands a gchord string (eg. fzc2fzc2 to
        # f z c2 f z c2) and stores it in gcstringlist.
        # Also computes the gchord string length (here 8).
        variable gc_string_length
        set gc_string_length 0
        set gclength [string length $gc]
        set pat {[zcfbghijGHIJ]\d*}
        set i 0
        set gcstringlist {}
        while {$i < $gclength} {
            set s [regexp  -indices -start $i $pat $gc r]
            if {!$s} break
            set loc1 [lindex $r 0]
            set loc2 [lindex $r 1]
            # puts "[string range $gc $loc1 $loc2]  $i $loc1 $loc2"
            if {$i != $loc1} {
                g2v_errormsg  "[string index $gc $i] is not a legal gchord code"}
            set gchordelem  [string range $gc $loc1 $loc2]
            lappend gcstringlist $gchordelem
            # puts $gcstringlist
            if {[string length $gchordelem] > 1} {
                set n [string index $gchordelem 1]
            } {set n 1}
            incr gc_string_length $n
            set i [expr $loc2+1]
        }
        #puts "gc_string_length=$gc_string_length"
        #puts $gcstringlist
        return $gcstringlist
    }
    
    
    proc interpret_gcstringlist {gcstringlist} {
        # Converts the gchord string to an actual
        # sequence of notes to place in the measure.
        # This is stored in gchord_output.
        global gchordnotes
        global bassnote
        global gchord_output
        set gchord_output {}
        foreach gcmd $gcstring::gcstringlist {
            set g [string index $gcmd 0]
            if {[string length $g] > 0} {
                set n [string index $gcmd 1]} else {
                set n ""}
            #  puts "g $g $n"
            switch $g {
                z {lappend gchord_output $gcmd}
                c {set chordstr \[
                    foreach note $gchordnotes {
                        set chordstr $chordstr$note
                    }
                    set chordstr $chordstr\]
                    #      puts $chordstr
                    lappend gchord_output $chordstr$n
                }
                f {
                    set bass $bassnote
                    lappend gchord_output $bass$n
                }
                b {
                    set chordstr \[$bassnote
                    foreach note $gchordnotes {
                        set chordstr $chordstr$note
                    }
                    set chordstr $chordstr\]
                    lappend gchord_output $chordstr$n
                }
                g {lappend gchord_output [lindex $gchordnotes 0]$n}
                h {lappend gchord_output [lindex $gchordnotes 1]$n}
                i {lappend gchord_output [lindex $gchordnotes 2]$n}
                j {if {[llength $gchordnotes] < 4} {g2v_errormsg "guitar chord is not a 7th"
                    } else {
                        lappend gchord_output [lindex $gchordnotes 3]$n}}
                G {lappend gchord_output [lindex $gchordnotes 0],$n}
                H {lappend gchord_output [lindex $gchordnotes 1],$n}
                I {lappend gchord_output [lindex $gchordnotes 2],$n}
                J {if {[llength $gchordnotes] < 4} {g2v_errormsg "guitar chord is not a 7th"
                    } else {
                        lappend gchord_output [lindex $gchordnotes 3]$n}}
                default {puts "cannot recognize $g"}
            }
        }
        #puts "interpret_gcstringlist: gchord_output $gchord_output"
        #puts "gstringlist $gcstringlist"
        return $gchord_output
    }
    #end gcstring.tcl
}



namespace eval gcgen {
    
    variable gchordindex
    variable gchordaccumulator
    variable expandedchords_for_line
    variable gchordunit
    #gcgen.tcl
    
    # The notes in the expanded gchord are placed in the
    # voice chord track note by note as the body of the
    # abc file is scanned. This allows handling of incomplete
    # measures and chord changes occurring inside a bar.
    #
    # gchord_generator is called each time a note in the
    # body is scanned. Anytime the gchord string (eg fczfcz)
    # is changed, setup_gchord() is called.
    #
    # At the end of each bar, we call process_barline
    # to ensure that the corresponding bar in the gchord
    # track matches the length of the bar in the abc body.
    #
    # gchordindex keeps track of the index in the
    # gchord string.
    #
    # gchordunit is a time unit for each gchord string
    # element.
    
    # gchordaccumulator and bar_accumulator accumulate
    # the time units.
    
    
    # When a measure ends we make any adjustments to the expandedchords
    # so it completes the measure. We reinitialize counters.
    
    proc setup_gchord_generator {} {
        variable gchordunit
        variable gchordaccumulator
        variable gchordindex
        if {[info exist gcstring::gc_string_length]} {
            if {$gcstring::gc_string_length == 0} return
            set gchordunit [expr $gchordsetup::barunits/$gcstring::gc_string_length]
            #puts "setup_gchord_generator:  gchordunit = $gchordunit gchordlength=$gcstring::gc_string_length barunits=$gchordsetup::barunits"
            set gchordindex 0
            set gchordaccumulator 0
        }
    }
    
    # gchord_generator is called after each note is
    # scanned. The function keeps time with the
    # scanned notes and issues another note in the
    # gchord sequence when appropriate.
    proc gchord_generator {} {
        global bar_accumulator
        variable gchordunit
        variable gchordindex
        variable gchordaccumulator
        global gchord_output
        variable expandedchords_for_line
        set space " "
        if {![info exist gcstring::gcstringlist]} return
        if {![info exist gchord_output]} return
#        puts "gchordaccumulator bar_accumulator = $gchordaccumulator $gchordindex $bar_accumulator"
        if {$bar_accumulator < $gchordaccumulator} return
        while {[set dif [expr $bar_accumulator - $gchordaccumulator]] > 0} {
            if {$gchordindex >= [llength $gcstring::gcstringlist]} return
            set gchord_output_elem [lindex $gchord_output $gchordindex]
            set gchordelem [lindex $gcstring::gcstringlist $gchordindex]
            if {[string length $gchordelem] == 1} {
                set ginc $gchordunit
            }  else {
                set n [string index $gchordelem 1]
                set ginc [expr $gchordunit*$n]
            }
            if {$ginc > $dif} break
            if {[string index $gchord_output_elem 0] == "\["} {
                set expandedchords_for_line $expandedchords_for_line$space$gchord_output_elem$space} else {
                set expandedchords_for_line "$expandedchords_for_line$gchord_output_elem"
            }
            incr  gchordaccumulator $ginc
            incr gchordindex
        }
    }
}


#end gcgen.tcl


# When a measure ends we make any adjustments to the expandedchords
# and drumnotes so it completes the measure. We reinitialize counters.
proc process_barline {token} {
    global bar_accumulator
    global dvoice
    if {[info exist gcgen::gchordaccumulator]} {
        if { $gcgen::gchordaccumulator < $bar_accumulator} {
            
            set numerator [expr $bar_accumulator - $gcgen::gchordaccumulator]
            set adjust [expr $numerator/$gcgen::gchordunit]
            if {$adjust == 0 && $numerator > 0} {
                set adjust $numerator/$gcgen::gchordunit
                set adjust  [reduce $adjust]}
            set adjustelem z$adjust
            set gcgen::expandedchords_for_line $gcgen::expandedchords_for_line\ $adjustelem
        }
        set gcgen::gchordindex 0
        set gcgen::gchordaccumulator 0
        set gcgen::expandedchords_for_line $gcgen::expandedchords_for_line\ $token
        #puts "expandedchords_for_line = $gcgen::expandedchords_for_line"
    }
    if {$dvoice != 1 && [info exist drumgen::drumaccumulator]} {
        if { $drumgen::drumaccumulator < $bar_accumulator} {
            
            set numerator [expr $bar_accumulator - $drumgen::drumaccumulator]
            set adjust [expr $numerator/$drumgen::drumunit]
            if {$adjust == 0 && $numerator > 0} {
                set adjust $numerator/$drumgen::drumunit
                set adjust  [reduce $adjust]}
            set adjustelem z$adjust
            set drumgen::drumnotes_for_line $drumgen::drumnotes_for_line\ $adjustelem
        }
        set drumgen::drumindex 0
        set drumgen::drumaccumulator 0
        set drumgen::drumnotes_for_line $drumgen::drumnotes_for_line\ $token
    }
    set bar_accumulator 0
}

# Part 36.0               Drum to voice
#start of drumgen

proc scandrumstring {dstring} {
    # Expands a drum string (eg. zd2dz to
    # z d2 d z) and stores it in dstringlist.
    # Also computes the dstring length (here 5).
    global d_string_length
    set d_string_length 0
    set dlength [string length $dstring]
    set pat {[zd]\d*}
    set i 0
    set dstringlist {}
    while {$i < $dlength} {
        set s [regexp  -indices -start $i $pat $dstring r]
        if {!$s} break
        set loc1 [lindex $r 0]
        set loc2 [lindex $r 1]
        if {$i != $loc1} {
            g2v_errormsg  "[string index $gc $i] is not a legal drum code"}
        set delem  [string range $dstring $loc1 $loc2]
        lappend dstringlist $delem
        if {[string length $delem] > 1} {
            set n [string index $delem 1]
        } else  {set n 1}
        incr d_string_length $n
        set i [expr $loc2+1]
    }
    #puts "d_string_length=$gc_string_length"
    #puts $dstringlist
    return $dstringlist
}


proc get_drum_notes {drumcmd} {
    set last [llength $drumcmd]
    return [lrange $drumcmd 1 $last]
}


proc drum2notes {drumpat} {
    global drumpatches
    global dstring
    global midi
    set drumcodes [scandrumstring [lindex $drumpat 0]]
    set notes [get_drum_notes $drumpat]
    set i 0
    set drumnotes {}
    set dstring {}
    foreach elem $drumcodes  {
        if {[string index $elem 0] == "d"} {
            if {[string length $elem] > 1} {
                set n [string index $elem 1]
            } {set n ""}
            set indx [expr [lindex $notes $i] -35]
            if {$indx > 46} {g2v_errormsg "$indx is not a legal drum patch number"}
            lappend drumnotes [lindex [lindex $drumpatches $indx] 1]$n
            lappend dstring $elem
            incr i
        } else {
            lappend drumnotes $elem
            lappend dstring $elem
        }
    }
    return $drumnotes
}

#set drumsymbols {A c F e E f B G d D g}
set drumsymbols {^A ^c ^F ^e _E _f _B _G _d _D _g}




proc drum2map {drumpat} {
    #creates a drum map for all the drum patch numbers
    #in the drum string.
    #also adds any selected drums in midi(selected_drums)
    global drumsymbols
    global drummap invdrummap
    global dstring
    global midi
    if {[info exist drummap]} {unset drummap}
    if {[string first "none" $drumpat] == 0} return
    set drumcodes [scandrumstring [lindex $drumpat 0]]
    set notes [get_drum_notes $drumpat]
    set i 0
    set drumnotes {}
    set dstring {}
    
    set k 0
    foreach elem $drumcodes  {
        if {[string length $elem] > 1} {
            set n [string index $elem 1]
        } {set n ""}
        set indx [lindex $notes $i]
        if {[string index $elem 0] == "d"} {
            if {$indx > 81} {g2v_errormsg "$indx is not a legal drum patch number"}
            if {![info exist drummap($indx)]} {
                set drummap($indx) [lindex $drumsymbols $k]
                set invdrummap([lindex $drumsymbols $k]) $indx
                if {$k < 10} {incr k}
            }
            lappend drumnotes $drummap($indx)$n
            lappend dstring $elem
            incr i
        } else {
            lappend drumnotes $elem
            lappend dstring $elem
        }
    }
    
    # now search through midi(selected_drums) and add anything missing
    foreach elem $midi(selected_drums) {
        set indx [expr $elem + 35]
        if {![info exist drummap($indx)]} {
            set drummap($indx) [lindex $drumsymbols $k]
            set invdrummap([lindex $drumsymbols $k]) $indx
            if {$k < 10} {incr k}
            lappend drumnotes $drummap($indx)$n
        }
    }
    return $drumnotes
}

proc output_drummap {} {
    global drummap
    global drumpatches
    set drummaplist [array get drummap]
    set map ""
    foreach {p n} $drummaplist {
        set m [expr $p - 35]
        #  puts [lindex [lindex $drumpatches $m] 2]
        append map  "%%MIDI drummap $n $p % [lindex [lindex $drumpatches $m] 2]\n"
    }
    return $map
}


proc return_d_unitlength {} {
    set dunit $drumgen::drumunit
    if {![info exist dunit]} {
        return "L:1/1"} elseif {
        $dunit == 768} {
        return "L:1/2"} elseif {
        $dunit == 384} {
        return "L:1/4"} elseif {
        $dunit  == 192} {
        return "L:1/8"} elseif {
        $dunit  == 96} {
        return "L:1/16"} elseif {
        $dunit == 48} {
        return "L:1/32"} else {
        g2v_errormsg "drum string does not divide into meter"
    }
}






#drumgen
namespace eval drumgen {
    
    variable drumindex
    variable drumaccumulator
    variable drumnotes_for_line
    variable drumunit
    
    # The notes in the drum command  are placed in the
    # voice chord track note by note as the body of the
    # abc file is scanned. This allows handling of incomplete
    # measures and chord changes occurring inside a bar.
    #
    # drum_generator is called each time a note in the
    # body is scanned. Anytime the drum string
    # is changed, setup_dchord() is called.
    #
    # At the end of each bar, we call process_barline
    # to ensure that the corresponding bar in the gchord
    # track matches the length of the bar in the abc body.
    #
    # drumindex keeps track of the index in the
    # drum string.
    #
    # drumunit is a time unit for each gchord string
    # element.
    
    # drumaccumulator and bar_accumulator accumulate
    # the time units.
    
    
    
    proc setup_drum_generator {drumpat} {
        global d_string_length barunits
        variable drumunit
        variable drumaccumulator
        variable drumindex
        global  drumstringlist d_string_length
        global midi
        if {$midi(drummap)} {
            set drumstringlist [drum2map $drumpat]
        } else {
            set drumstringlist [drum2notes $drumpat]
        }
        if {[info exist d_string_length]} {
            set drumunit [expr $gchordsetup::barunits/$d_string_length]
            #puts "setup_drum_generator:  drumunit = $drumunit drumlength=$d_string_length "
            set drumindex 0
            set drumaccumulator 0
        }
    }
    
    # drum_generator is called after each note is
    # scanned. The function keeps time with the
    # scanned notes and issues another note in the
    # drum sequence when appropriate.
    proc drum_generator {} {
        global bar_accumulator
        global drumstringlist
        global dstring
        variable drumunit
        variable drumindex
        variable drumaccumulator
        global drum_output
        variable drumnotes_for_line
        if {![info exist drumstringlist]} return
        if {![info exist dstring]} return
        #puts "drumaccumulator bar_accumulator = $drumaccumulator $bar_accumulator"
        if {$bar_accumulator < $drumaccumulator} return
        while {[set dif [expr $bar_accumulator - $drumaccumulator]] > 0} {
            if {$drumindex >= [llength $drumstringlist]} return
            set d_elem [lindex $dstring $drumindex]
            set drum_output_elem [lindex $drumstringlist $drumindex]
            if {[string length $d_elem] == 1} {
                set dinc $drumunit}    else {
                set n [string index $d_elem 1]
                set dinc [expr $drumunit*$n]
            }
            # add drum_output_elem only if it is not too long. process_bar will
            # look after the leftovers.
            if {$dinc > $dif} break
            incr drumaccumulator $dinc
            set drumnotes_for_line "$drumnotes_for_line$drum_output_elem"
            incr drumindex
        }
    }
}


set dvoice 1

global chordnames



proc appendtext {line} {
    global fieldtext bodytext body
    if {$body} {
        set bodytext $bodytext$line\n
    } else {
        set fieldtext $fieldtext$line\n
    }
}


proc return_selected_tune {} {
    global fieldtext bodytext
    global midi fileseek
    set sel [title_selected]
    set inputhandle [open $midi(abc_open) r]
    set loc $fileseek($sel)
    seek $inputhandle $loc
    # copy tune to tunestring
    gets $inputhandle line
    set tunestring $line\n
    while {[gets $inputhandle line] >0}  {
        set tunestring $tunestring$line\n
    }
    close $inputhandle
    return $tunestring
}



set partlabel(0)  "none"

proc gv_process_post_P {line} {
    #To handle multiple parts, we save the body and chord voice
    #for each part  in separate strings which are put in
    #bodyvoicelist and chordvoicelist lists respectively.
    global expandedchords bodytext expandeddrums
    global chordvoice bodyvoice drumvoice
    global partlabel
    global npart
    # the P: always precedes the body.
    if {[string length $bodytext] < 1} {
        set partlabel($npart) $line
        return}
    set expandedchords [string trimright $expandedchords \n]
    set chordvoice($npart) $expandedchords
    set expandeddrums [string trimright $expandeddrums \n]
    set drumvoice($npart) $expandeddrums
    set bodyvoice($npart) $bodytext
    set expandedchords ""
    set expandeddrums ""
    set bodytext ""
    incr npart
    set partlabel($npart) $line
}

proc process_voice {line} {
    #global activevoice
    global voicelab voicelist
    global barnum nvoices
    global nbarsv
    set tline [string range $line 2 end]
    set tline [string trimleft $tline]
    set tline [split $tline]
    set voicelab [lindex $tline 0]
    if {[lsearch $voicelist $voicelab] == -1} {
        lappend voicelist $voicelab
        set barnum 0
        incr nvoices
        set nbarsv($voicelab) 0
    } else {
        set barnum $nbarsv($voicelab)
    }
    Refactor::make_component_name
    #set activevoice [lindex $tline 0]
}


proc process_line {line} {
    # processes the notes in a single line of the body in sequence.
    # We only care about the duration of the note and position of
    # the guitar chord indications. Thus we need to recognize
    # barlines eg. | || :| |: |[1 |[2
    # chords eg. [CEG]
    # tuplets eg. (n:m:pDEF 
    # gchords (anything enclosed by double quotes)
    # notes eg. A3/2 A/ A3 A
    # Each of these entities are handled by different functions.
    # When we finish the line, the string expandedchords_for_line
    # contains line of music containing the gchord accompaniment.
    # This string is appended to the string expandedchords.
    #set barpat {\||:\|\[\d|:\||\|:|\|\[\d|\||::}
    set barpat {\|\||\|[0-9]?|:\|\[\d|:\|[0-9]?|:\||\|:|\|\[\d|\||::}
    set notepat {(\^*|_*|=?)([A-G]\,*|[a-g]\'*|z|x)(/?[0-9]*|[0-9]*/*[0-9]*)}
    set gchordpat {\"[^\"]+\"}
    set curlypat {\{[^\}]*\}}
    set chordpat {(\[[^\]\[]*\])(/?[0-9]*|[0-9]*/*[0-9]*)}
    set instructpat {![^!]*!}
    set tupletpat  {\(\d(\:\d)*}
    set sectpat {\[[0-9]+}
    
    global expandedchords
    global expandeddrums
    global bodytext
    global activevoice
    global preservegchord
    global dvoice
    global chosenvoice chosenvoicefound
    
    set gcgen::expandedchords_for_line ""
    set drumgen::drumnotes_for_line ""
    if {$preservegchord == 1} {
        set bodytext $bodytext$line\n
    } else {
        # remove all guitar chords and print the result.
        regsub -all  {"[^"]*"} $line "" result
        set bodytext $bodytext$result\n
    }
    
    # scan through the whole line (including gchords)
    set i 0
    while {$i < [string length $line]} {
        # search for bar lines
        set success [regexp -indices -start $i $barpat $line location]
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {
                if {$activevoice == $chosenvoice} {process_barline [string range $line $loc1 $loc2]}
                set i [expr $loc2+1]
                resetkeytable
                continue}
        }
        
        # for repeat sections
        set success [regexp -indices -start $i $sectpat $line location]
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {
                set sect [string range $line $loc1 $loc2]
                set gcgen::expandedchords_for_line  $gcgen::expandedchords_for_line$sect
                set i [expr $loc2+1]
                continue
            }
        }
        
        
        
        set success [regexp -indices -start $i $gchordpat $line location]
        # search for guitar chords
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {process_gchord [string range $line $loc1 $loc2]
                set i [expr $loc2+1]
                continue}
        }
        
        set success [regexp -indices -start $i $curlypat $line location]
        # search for grace note sequences
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            #  ignore grace notes in curly brackets
            if {$loc1 == $i} {
                set i [expr $loc2+1]
                continue}
        }
        
       set success [regexp -indices -start $i $tupletpat $line location]
# search for triplet indication
         if {$success} {
          set loc1  [lindex $location 0]
          set loc2  [lindex $location 1]
          if {$loc1 == $i} {gv_process_tuplet $location $line
            set i [expr $loc2+1]
            continue}
        }


        
        
        set success [regexp -indices -start $i $instructpat $line location]
        # search for embedded instructions like !fff!
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {
                #    skip !fff! and similar instructions embedded in body
                set i [expr $loc2+1]
                continue}
        }
        
        set success [regexp -indices -start $i $notepat $line location]
        # search for notes
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {
                set i [expr $loc2+1]
                if {$activevoice == $chosenvoice} {
                    set chosenvoicefound 1
                    gv_process_note [string range $line $loc1 $loc2]
                    if {$dvoice != 2} {gcgen::gchord_generator}
                    if {$dvoice != 1} {
                        drumgen::drum_generator
                    }
                }
                continue
            }
        }
        
        set success [regexp -indices -start $i $chordpat $line location]
        # search for chords
        if {$success} {
            set loc1  [lindex $location 0]
            set loc2  [lindex $location 1]
            if {$loc1 == $i} {gv_process_chord [string range $line $loc1 $loc2]
                set i [expr $loc2+1]
                if {$activevoice == $chosenvoice} {gcgen::gchord_generator}
                if {$activevoice == 1 && $dvoice != 1} {
                    drumgen::drum_generator}
                continue}
        }
        
        incr i
    }
    if {$activevoice == $chosenvoice} {
        set expandedchords $expandedchords$gcgen::expandedchords_for_line\n
        #puts "expandedchords = $expandedchords"
    }
    
    if {$dvoice != 1 && $activevoice == $chosenvoice} {
        set expandeddrums $expandeddrums$drumgen::drumnotes_for_line\n
    }
}


# set flag to adjust the duration of the next notes enclosed in tuplet
proc gv_process_tuplet {location line} {
global triplet_running
global nequiv
global tuplenotes
global tupletscalefactor
set tuplet [string range $line [lindex $location 0] [lindex $location 1]]
set n [scan $tuplet "(%d:%d:%d" n1 n2 n3]
#puts "tuplet = $tuplet n = $n"
set triplet_running 1
if {$n == 1} {
  set tuplesize $n1
  set tuplenotes $tuplesize
  switch $n1 {
    2 {set nequiv 3}
    3 {set nequiv 2}
    4 {set nequiv 3}
    6 {set nequiv 2}
    }
} elseif {$n == 2} {
   set tuplesize $n1
   set tuplenotes $tuplesize
   set nequiv $n2
} elseif {$n == 3} {
   set tuplesize $n1
   set nequiv $n2
   set tuplenotes $n3
}
set tupletscalefactor [expr $nequiv/double($tuplesize)]
}




# determine the duration of the note. We ignore broken
# notes (eg A > C) because the two notes usually complete
# a beat. We also do not need to pay attention to tied
# notes.
proc gv_process_note {token} {
    global triplet_running
    global tuplenotes
    global tupletscalefactor
    global bar_accumulator
    set durpatf {([0-9])\/([0-9])}
    set durpatn {[0-9]}
    set durpatd {\/([0-9])}
    set dur2 {/+}
    if {[regexp $durpatf $token match val1 val2]} {
        set increment  [expr $gchordsetup::noteunits*$val1/$val2]
    } elseif {
        [regexp $durpatd $token val1 val2]} {
        set increment  [expr $gchordsetup::noteunits/$val2]
    } elseif {
        [regexp $durpatn $token val]} {
        set increment  [expr $gchordsetup::noteunits*$val]
    } elseif {
        [regexp $dur2 $token val]} {
        set increment  [expr $gchordsetup::noteunits/2]
    } else {
        set increment $gchordsetup::noteunits
    }
    if {$triplet_running} {
       set increment [expr round($tupletscalefactor * $increment)]
       incr triplet_running
       if {$triplet_running > $tuplenotes} {set triplet_running 0}
       }

    incr bar_accumulator $increment
    return
}

# separate the guitar chord from the double quotes
# determine the type of chord and find the equivalent
# notes.
proc process_gchord {token} {
    global gchordstring gchord_output gcstringlist
    set token [string trimleft $token \"]
    set token [string trimright $token \"]
    set pre [string index $token 0]
    if {$pre == "^" || $pre == "_"} return
    gchordspace::expandgchord $token
    set gchord_output [gcstring::interpret_gcstringlist $gcstring::gcstringlist]
}

# We hope all the notes in the chord are of equal.
# We get the time value of the chord from the time
# value of the first note in the chord.
proc gv_process_chord {token} {
    gv_process_note $token
}


# This is the function which processes the tune.
# Assume only one tune per file.
proc gv_process_tune {tunestring} {
    global expandedchords
    global expandeddrums
    global triplet_running
    global npart
    global body
    global debug
    global activevoice
    global nvoices
    global dvoice
    global chosenvoice chosenvoicefound
    
    global recover_key key_change
    global recover_meter meter_change
    global bar_accumulator
    
    global midi
    global drumentry    

    set npart 0
    set nvoices 0
    set activevoice 1
    set fieldpat {^X:|^T:|^C:|^O:|^A:|^Q:|^Z:|^N:|^H:|^S:|^F:}
    set triplet_running 0
    set expandedchords "%%MIDI program $midi(chordprog)\n"
    set expandeddrums ""
    set body 0
    set chosenvoicefound 0
    
    foreach line [split $tunestring \n]  {
        if {$debug > 0} {puts ">>$line"}
        if {[string length $line] < 1} continue
        if {[string first "%%MIDI" $line] >= 0} {
            if {[string first "gchord" $line] >=0} {
                gcstring::process_MIDI_gchord_command $line
                appendtext $line
            } elseif {[string first "drum " $line] >=0} {
                gcstring::process_MIDI_drum_command $line
                appendtext %$line
            }
        } elseif {
            [string index $line 0] == "I"} {
            appendtext $line
            continue
        } elseif {
            [string index $line 0] == "R"} {
            appendtext $line
            continue
        } elseif {
            [string index $line 0] == "%"} {
            appendtext $line
            continue
        } elseif {
            [regexp $fieldpat $line] } {
            appendtext $line
        } elseif {
            [string first "K:" $line] == 0} {
            appendtext $line
            if {$body} {
                set expandedchords $expandedchords$line\n}
            set kfield [string range $line 2 end]
            setupkey [key2sf $kfield]
            resetkeytable
            set key_change 1
            set bar_accumulator 0
            if {!$body} {
                set body 1
                set recover_key $line
                set key_change 0
                appendtext "%%MIDI program $midi(voice1)"
                appendtext "%%MIDI bassprog $midi(bassprog)"
                appendtext "%%MIDI chordprog $midi(chordprog)"
            }
        } elseif {
            [string first "M:" $line] == 0} {
            appendtext $line
            if {$body} {
                set expandedchords $expandedchords$line\n
                set meter_change 1} else {
                set recover_meter $line
                set meter_change 0}
            gchordsetup::setup_meter $line
            if {$dvoice != 2} gcgen::setup_gchord_generator
            set gchordunitlength [return_gchord_unitlength]
            set expandedchords $expandedchords$gchordunitlength\n
            #       global dvoice
            if {$dvoice != 1} {
                if {$drumentry != "none"} {
                    drumgen::setup_drum_generator $drumentry
                } else {drumgen::setup_drum_generator "zz"}
                set drumunitlength [return_d_unitlength]
                set expandeddrums $expandeddrums$drumunitlength\n
                set expandeddrums "$expandeddrums%%MIDI channel 10\n"
                if {$midi(drummap)} {
                    set expandeddrums $expandeddrums[output_drummap]
                }
            }
        } elseif {
            [string first "L:" $line] == 0} {
            appendtext $line
            gchordsetup::setup_unitlength $line
        } elseif {
            [string first "P:" $line] == 0} {
            gv_process_post_P $line
        } elseif {
            [string first "V:" $line] == 0} {
            process_voice $line
            appendtext $line
            incr nvoices
        } elseif {
            $body==1} {
            process_line $line
        } else {g2v_errormsg *-*-*$line }
        
    }
    if {$chosenvoicefound == 0} {g2v_errormsg "could not find voice $chosenvoice"}
}



# for translating notes C,D, etc to MIDI pitches
set  notescale  {0  2  4  5  7  9  11}
set  key "cdefgab";
set notekey "CDEFGABcdefgab"





proc return_gchord_unitlength {} {
    #puts "return_gchord_unitlength $gcgen::gchordunit"
    if {![info exist gcgen::gchordunit]} {
        return "L:1/1"} elseif {
        $gcgen::gchordunit == 768} {
        return "L:1/2"} elseif {
        $gcgen::gchordunit == 384} {
        return "L:1/4"} elseif {
        $gcgen::gchordunit == 192} {
        return "L:1/8"} elseif {
        $gcgen::gchordunit == 96} {
        return "L:1/16"} elseif {
        $gcgen::gchordunit == 48} {
        return "L:1/32"} else {
        g2v_errormsg "gchordstring does not divide into meter"
    }
}





set debug 0
set preservegchord 1

proc g2v_startup {} {
    global gvchordstring gvmeter
    global tunestring
    global gvmsg
    global midi
    global hasgchordstring
    global gchordentry

    set gvmsg ""
    g2v_clear_errormsg
    show_g2v_page
    set tunestring [return_selected_tune]
    set index [string first "M:" $tunestring ]
    set index2 [expr $index + 10]
    set line [string range $tunestring $index $index2]
    if {[string first "C|" $line] >= 0} {
        set m1 2
        set m2 2} elseif {
        [string first "C" $line] >= 0} {
        set m1 4
        set m2 4} else {
        set r [scan $line "M:%d/%d" m1 m2]}
    set gvmeter $m1/$m2
    if  {$gchordentry != "default"}  {
        set gvchordstring $gchordentry} else {
        if {[info exist gchordsetup::default_gchord($gvmeter)]} {
            set gvchordstring $gchordsetup::default_gchord($gvmeter)
        } elseif {$hasgchordstring} {
            g2v_errormsg "MIDI gchord string embedded in abc file"
        } else {
            g2v_errormsg  "no default gchord string for this meter"
        }
    }
    .abc.g2v.1.lab configure -text "default gchord string for $gvmeter"
}

proc g2v_errormsg {msg} {
    global gvmsg exec_out
    set exec_out $exec_out\n$msg
    if {[string length $gvmsg] < 1} {set gvmsg $msg} else {
        set gvmsg $gvmsg\n$msg}
    .abc.g2v.msg.txt configure -text $gvmsg -foreground red
}

proc g2v_clear_errormsg {} {
    global gvmsg exec_out
    set exec_out "running g2v..."
    set gvmsg ""
    .abc.g2v.msg.txt configure -text $gvmsg
}



proc g2v {} {
    global tunestring
    global midi
    global inputfile fieldtext
    global bodyvoice
    global abctxtw
    global npart
    global partlabel
    global chordvoice
    global drumvoice dvoice
    global fieldtext bodytext
    global gvchordstring gvmeter
    global gchordvoiceid drumsvoiceid
    
    global recover_key key_change
    global recover_meter meter_change
    global barpickerflag
    
    set fieldtext ""
    set bodytext ""
    set barpickerflag 1
    
    
    set gchordsetup::default_gchord($gvmeter) $gvchordstring
    g2v_clear_errormsg
    gv_process_tune $tunestring
    gv_process_post_P "none"
    
    # output
    if {$midi(g2v_clipboard)} {
        
        clipboard clear
        for {set i 0} {$i <$npart} {incr i} {
            if {$partlabel($i) != "none"} {
                #puts $partlabel($i)
                clipboard append  "%$partlabel($i)\n"
            }
            clipboard append $chordvoice($i)\n
            if {$dvoice != 1} {clipboard append \ndrums\n$drumvoice($i)\n}
        }
        .abc.g2v.msg.txt configure  -text "The results are in the clipboard."
    } else {
        
        set vc "V:$gchordvoiceid clef=bass\n"
        set vd "V:$drumsvoiceid name=drum clef=perc stafflines=4\nK: none\n"
        edit_empty_file
        $abctxtw insert end $fieldtext
        for {set i 0} {$i <$npart} {incr i} {
            if {$partlabel($i) != "none"} {
                $abctxtw insert end $partlabel($i)\n part
            }
            $abctxtw insert end V:1\n$bodyvoice($i)
            #puts "bodyvoice($i) = $bodyvoice($i)"
            if {$dvoice != 2} {
                $abctxtw insert end $vc
                $abctxtw insert end $chordvoice($i)\n
            }
            if {$dvoice != 1} {
                $abctxtw insert end $vd
                $abctxtw insert end $drumvoice($i)\n}
        }
    }
    
    update_console_page
}

#end of abcg2v.tcl


# Part 37.0 Refactor

proc disable_enable_tempo_controller {} {
global hasfield
global midi
if {[info exist hasfield(Q)] && !$midi(ignoreQ)} {
  .abc.titles.sliders.tempo configure -state disabled -troughcolor grey
  .abc.titles.sliders.beatsize configure -state disabled
  } else {
  .abc.titles.sliders.tempo configure -state normal -troughcolor darkred
  .abc.titles.sliders.beatsize configure -state normal
  }
}

proc extract_tune_info {} {
    global fileseek
    global midi
    global nbars
    global firstbar lastbar
    global hasfield
    global barpickerflag
    global tpxrefno
    global selectedtitle 
    midi1_msg ""
    set sel [title_selected]
    if {[llength $sel] > 1} {set sel [lindex $sel 0]}
    set selectedrefno [.abc.titles.t set $sel refno]
    set selectedtitle [.abc.titles.t set $sel title]
    set tpxrefno $selectedrefno
    #puts "extract_tune_info for $sel"
    if {[llength $sel] != 1} {return}
    set loc $fileseek($sel)
    #skip first X: 2021.03.04
    incr loc 2 
    set handle [open $midi(abc_open) r]
    seek $handle $loc
    gets $handle line
    #set tunestring $line\n
    set tunestring "X: $sel\n"
    while {[gets $handle line]> 0} {
        if {[string first "X:" $line] == 0} break
        if {!$midi(blank_lines) && [string length $line] < 1} break 
        set tunestring $tunestring$line\n
    }
    close $handle
    extract_tune_features $tunestring
    disable_enable_tempo_controller 
}


proc extract_tune_features {tunestring} {
    global hasfield
    global pickedmeter
    array unset hasfield
    
    set pat {[0-9]+|C|C\|}
    set pickedmeter 4/4
    foreach line [split $tunestring \n]  {
        #if {$debug > 0} {puts ">>$line"}
        if {[string length $line] < 1} continue
        if {[string first "M:" $line] == 0} {
            regexp $pat $line pickedmeter
            update_gchord_and_drums $pickedmeter
        } elseif {[string first "B:" $line] == 0 } {
            append hasfield(B) $line\n
        } elseif {[string first "C:" $line] == 0 } {
            append hasfield(C) $line\n
        } elseif {[string first "O:" $line] == 0 } {
            append hasfield(O) $line\n
        } elseif {[string first "P:" $line] == 0 && ![info exist hasfield(P)]} {
            append hasfield(P) $line\n
        } elseif {[string first "Z:" $line] == 0 } {
            append hasfield(Z) $line\n
        } elseif {[string first "N:" $line] == 0 } {
            append hasfield(N) $line\n
        } elseif {[string first "S:" $line] == 0 } {
            append hasfield(S) $line\n
        } elseif {[string first "R:" $line] == 0 } {
            append hasfield(R) $line\n
        } elseif {[string first "F:" $line] == 0 } {
            append hasfield(F) $line\n
        } elseif {[string first "Q:" $line] == 0 } {
            append hasfield(Q) $line\n
        } elseif {[string first "T:" $line] == 0 } {
            append hasfield(T) $line\n
        } elseif {[string first "V:" $line] >= 0 } {
            append hasfield(V) $line\n
        } elseif {[string first "W:" $line] == 0} {
            append hasfield(W) $line\n
        } elseif {[string first "%%MIDI" $line] == 0} {
            append hasfield(MIDI) $line\n}
        if {[string first "\"" $line] >= 0} {
            set hasfield(gc) " "}
        if {[string first "gchord" $line] >0} {
            append hasfield(gchord) $line}
        if {[string first "drum" $line] >0} {
            append hasfield(drum) $line}
        
        
    }
    finish_tune
}


proc  update_gchord_and_drums {pickedmeter} {
    global hasfield
    set_gchord_combobox_values $pickedmeter 
    set_drum_combobox_values $pickedmeter
    }


proc finish_tune {} {
    global hasfield tunenote
    global nvoices nbars
    global hasgchordstring
    set tunenote {}
    set codelist ""
    # set nvoices to 0 so voice doubling works
    set nvoices 0
    foreach  code {T B C O P Z N S R F Q V W gc MIDI} {
        if {[info exist hasfield($code)]} {
            #if {[string length $tunenote] >  0} {set tunenote $tunenote\n}
            set tunenote $tunenote$hasfield($code)
            #puts "code = $code\n$hasfield($code)"
            if {$code != "MIDI"} {
                set codelist "$codelist$code: "
            } else {
                set codelist "$codelist%%MIDI "
            }
        }
    }
    .abc.titles.notes.but configure -text $codelist
    if {[winfo exist .headers]} {
          if {[.headers.more cget -state] == "disabled"} {
                 Refactor::show_more} else {
                 Refactor::header_window}
          }
    set hasgchordstring 0
    if {[info exist hasfield(MIDI)]} {
        if {[string first "gchord " $hasfield(MIDI)] > 0} {
           set hasgchordstring 1}
    }
    set msg ""
    if {[info exist hasfield(V)]} {set nvoices 1}
    if {[info exist hasfield(gc)] == 0} {
      append msg "No guitar chords are present in the selected tune.\n"
      }
    if {[info exist hasfield(MIDI)]} {
      append msg "The tune has %%MIDI directives "
      }
    if {[info exist hasfield(gchord)]} {
      append msg " including gchord indications"
      }
    if {[string length $msg] > 20} {append msg "\n"}
    if {[info exist hasfield(drum)]} {
      append msg " including drum indications"
      }

   midi1_msg $msg

    if {[winfo exist .pitchclass]} note_histogram
    if {[winfo exist .histmatches]}  Matcher::match_histogram_correlation
    if {[winfo exist .pitchinterval]} note_interval_histogram
}


proc play_section {} {
    global midi exec_out
    global console_clock
    global files
    global midiname
    set console_clock [clock seconds]
    set cmd "file delete [glob -nocomplain *.mid]"
    catch {eval $cmd}
    
    Refactor::output_file_direct
    set cmd "exec [list $midi(path_abc2midi)] X.tmp -Q $midi(tempo)"
    if {$midi(barflymode)} {append cmd " -BF $midi(stressmodel)"}
    if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
    if {$midi(nofermata) == 1} {append cmd " -NFER"}
    if {$midi(nograce) == 1} {append cmd " -NGRA"}
    if {$midi(quiet) == 1} {append cmd " -quiet"}
    if {$midi(silent) == 1} {append cmd " -silent"}
    catch {eval $cmd} exec_out
    set exec_out $cmd\n\n$exec_out
    set files X$midiname.mid
    play_midis $midiname
    update_console_page
}


proc display_section {} {
    global midi
    global console_clock
    global active_sheet
    global exec_out
    global ps_numb_start firstbar
    set ps_numb_start $firstbar
    set console_clock [clock seconds]
    Refactor::output_file_direct
    display_tunes X.tmp
    update_console_page
}



namespace eval Refactor {
    
    proc process_line {line} {
        # This function breaks a body line into bars and save
        # each bar into the array tune_pieces using the functions
        # make_component_name and appendtext.
        # Complications occur when (1) a line begins with a bar line
        # (2) a bar is incomplete at the end of a line (3) comments
        # like %%MIDI commands and (4) field commands  occur in
        # the body.
        #
        # The following are considered as bar separators
        # | |: || :| :: |[1 |[2 etc. If a MIDI command (%%MIDI ...)
        # is encountered or a field command, it is also included
        # with the bar.
        
        set barpat {\|\||\|[0-9]?|:\|\[\d|:\|[0-9]?|:\||\|:|\|\[\d|\||::|\|\]}
        set invoicepat {[\[V:*\]]}
        # for matching inline voices -- not used presently

        global barnum
        global nbars
        global nbarsv
        global voicelab
        global incomplete
        global component
        global barpickerflag
        global abctxtw
        
        set newline  1

	# trim out any comments after column 1 (ie. allow %%MIDI) but
	# exclude ABCD| % bar 3
	set from [string first "%" $line 2]
	if {$from > 0} {
            set line [string range $line 0 [expr $from -1]]
            }
        
        #trim white space at end of line, so we know when we finish the line
	set line [string trimright $line] 
        
        if {[string index $line 0] == "%"} {
            appendx $line\n
            return
        }
        if {[string first "P:" $line] == 0} {
            # do not append P: because it is put in the wrong place
            return
        }
        if  {[string first "V:" $line] == 0} {
            if {[string length $incomplete] > 0} {
		  appendx $incomplete
		  appendx "|\n"
		  set incomplete ""
                  }
            process_voice $line
            appendx $line\n
            return
        }
        if   {[string first "L:" $line] == 0} {
            appendx $line\n
            return
        }
        if   {[string first "M:" $line] == 0} {
            appendx $line\n
            return
        }
        if   {[string first "Q:" $line] == 0} {
            appendx $line\n
            return
        }
        if   {[string first "K:" $line] == 0} {
            appendx $line\n
            return
        }
        
# catch inline voice
        if  {[string first "\[V:" $line] == 0} {
            set i2 [string first "\]" $line]
            incr i2 -1
            set vline [string range $line 1 $i2]
            process_voice $vline
            #appendtext $vline\n
            appendx $vline\n
            incr i2 2
            set line [string range $line $i2 end]
        }
        
        
        # eliminate any indentation
        set line [string trimleft $line]
        
        # scan through the whole line
        set i 0
        set start 0
        if {[string first "\\" $line] > 0} {set backslash 1
        } else {set backslash 0}
        set line [string trimright $line \\]
        while {$i < [string length $line]} {
            #set success [regexp -indices -start $i $invoicepat $line location]
            #if {$success} {puts "inline voice in $line"}
            # search for bar lines
            set success [regexp -indices -start $i $barpat $line location]
            if {$success} {
                set loc1  [lindex $location 0]
                set loc2  [lindex $location 1]
                set start $i
                #in case a line starts with a bar line type we include the contents
                #preceding this bar line (in the previous line) if any.
                if {[expr $loc2] < 3 && $loc1 == 0 } {
                    if {[string length $incomplete] > 0} {
                        append incomplete [string range $line $start $loc2]
                        appendtext $incomplete
                        set incomplete ""
                        incr barnum
                        set i [expr $loc2 +1]
                        set start $i
                        if {$barnum > $nbars} {set nbars $barnum}
                        if {$barnum > $nbarsv($voicelab)} {set nbarsv($voicelab) $barnum}
                        # previous line is now complete add a \n
                    } else {
                        # nothing precedes scan to the next bar line
                        set success [regexp -indices -start $i $barpat $line location]
                        if {$success} {
                            set loc1  [lindex $location 0]
                            set loc2  [lindex $location 1]
                            appendtext [string range $line $start $loc2]
                            incr barnum
                            if {$barnum > $nbars} {set nbars $barnum}
                            if {$barnum > $nbarsv($voicelab)} {set nbarsv($voicelab) $barnum}
                        } else {
                            # bar line still not found, save everything before end of line
                            append incomplete [string range $line 0  end]
                            set loc2 [string length $line]
                            set newline 0
                        }
                    }
                } else {
                    #  if there is anything left over from the last line, send it
                    if {[string length $incomplete] > 0} {
                        appendtext $incomplete
                        set incomplete ""
                    }
                    appendtext [string range $line $start $loc2]
                    incr barnum
                    if {$barnum > $nbars} {set nbars $barnum}
                    if {$barnum > $nbarsv($voicelab)} {set nbarsv($voicelab) $barnum}
                }
                set i $loc2
                make_component_name
            } else {
                # failed to find bar object. Maybe it is found in the next line.
                # we need to increment start before getting incomplete or else
                # we will get a double bar.
                set incomplete [string range $line $start end]
                # get rid of trailing white spaces
                set incomplete [string trimright $incomplete]
                return}
            incr i
            set start $i
        }
        if {$barpickerflag} {
            if {$newline} {
                if {$backslash} {$abctxtw insert end \\\n
                } else   {$abctxtw insert end \n}
            }
        }
    }
    
    
    
    proc appendtext {piece} {
        global abctxtw
        global component
        global tunepieces
        global barpickerflag
        #set piece [string trimright $piece \\ ]
        append tunepieces($component) $piece
        if {$barpickerflag} {
            $abctxtw insert end $piece $component
            $abctxtw tag bind $component <ButtonPress-1> [list Barpicker::barclick $component]
        }
    }
    
    proc appendx {piece} {
        global abctxtw
        global xcomponent
        global tunepieces
        global barpickerflag
        if {$barpickerflag} {
            $abctxtw insert end $piece $xcomponent
            $abctxtw tag bind $xcomponent <ButtonPress-1> [list Barpicker::barclick $xcomponent]
        }
        append tunepieces($xcomponent) $piece
    }
    
    
    proc make_component_name {} {
        global partname
        global voicelab
        global barnum
        global component
        global xcomponent
        set component $voicelab-$barnum
        set xcomponent x-$voicelab-$barnum
    }
    
    global hasfield
    
    
    # This is the function which processes the tune.
    # Assume only one tune per file.
    proc process_tune {tunestring} {
        global partname
        global voicelab
        global voicelist
        global barnum
        global nbars
        global body
        global debug
        # global activevoice
        global nvoices
        global tunepieces
        global component
        global incomplete
        global nbarsv
        global crlf
        
        array unset tunepieces
        set partname Z
        set voicelab 0
        set barnum 0
        set nbars 0
        set npart 0
        set nvoices 0
        set voicelist {}
        set component head
        set body 0
        set incomplete ""
        set nbarsv(0) 0
        
        
        foreach line [split $tunestring \n]  {
            if {$debug > 0} {puts ">>$line"}
            if {[string length $line] < 1} continue
            
            
            if {!$body} {
                if {[string first "K:" $line] == 0} {
                    set keystring [string range $line 2 end]
                    if {[string first "Hp" $line] > 0 ||
                        [string first "HP" $line] > 0
                    } {enable_disable_drone 1} else {
                        enable_disable_drone 0}
                    
                    set body 1
                    appendtext $line\n
                    make_component_name
                } else {
                    appendtext $line\n
                }
            } else {
                process_line $line
            }
        }
        if {$nvoices == 0} {set voicelist {0}}
    }
    
    proc header_window {} {
        global tunenote midi
        set p .headers
        global df
        if {![winfo exist $p]} {
            toplevel $p
            position_window ".headers"
            text $p.t -width 50 -height 10 -bg #f4ece0 \
                    -yscrollcommand {.headers.ysbar set} \
                    -xscrollcommand {.headers.xsbar set} \
                    -font $df -exportselection false
            scrollbar $p.ysbar -orient vertical -command {.headers.t yview}
            scrollbar $p.xsbar -orient horizontal -command {.headers.t xview}
            button $p.more -text more... -font $df -bd 0\
                    -command Refactor::show_more
            pack $p.ysbar -side right   -fill y -in $p
            pack $p.xsbar -side bottom  -fill x -in $p
            pack $p.t -fill both -expand y -in $p
            pack $p.more -anchor w
        }
        $p.more configure -state normal
        $p.t delete 0.0 end
        #$p.t tag configure link -foreground darkblue
        set linkindex 0
        foreach line [split $tunenote \n] {
            if {[string first "F:" $line] == 0} {
                $p.t tag configure m$linkindex -foreground darkblue
                $p.t insert end $line\n m$linkindex
                set url [string range $line 2 end]
                $p.t tag bind m$linkindex <1> "exec [list $midi(path_internet)] $url &"
                incr linkindex
            } else {
                $p.t insert end $line\n
            }
        }
    }
    
    
    proc show_more {} {
        global midi
        set tunestring [return_selected_tune]
        set p .headers
        $p.t delete 0.0 end
        set linkindex 0
        foreach line [split $tunestring \n] {
            if {[string first "F:" $line] == 0} {
                $p.t tag configure m$linkindex -foreground darkblue
                $p.t insert end $line\n m$linkindex
                set url [string range $line 2 end]
                $p.t tag bind m$linkindex <1> "exec [list $midi(path_internet)] $url &"
                incr linkindex
            } else {
                $p.t insert end $line\n
            }
        }
        $p.more configure -state disable
    }
    
    proc myputs {out_fd mydata} {
        # this version saves the last output character in case
        # we need it.
        global lastoutputchar
        set l [string length $mydata]
        incr l -1
        set lastoutputchar [string index $mydata $l]
        puts -nonewline $out_fd $mydata
    }
    
    proc extract_comments_for_voice {i} {
        # extracts comments like %%MIDI program command
        # and field commands like L:1/8 from tunepieces()
        global tunepieces
        global firstbar lastbar
        set saved_elements {}
        for {set j 0} {$j < $firstbar} {incr j} {
            if {[info exist tunepieces(x-$i-$j)]} {
                lappend saved_elements $tunepieces(x-$i-$j)
                #        puts "x-$i-$j = $tunepieces(x-$i-$j)"
            }
        }
        return $saved_elements
    }
    
    
    
    proc output_file_direct {} {
        # creates a tmp.abc file from the info in tunepieces
        # between bars firstbar and lastbar.
        global tunepieces
        global nvoices nbars voicelist
        global lastoutputchar
        global firstbar lastbar
        global midi
        global midiname
        set fieldpat {^L:|^M:|^K:|^Q:|V:}
        set barsperline 4
        # to address problem with Windows Media Player we give the
        # MIDI file a random name
        set xhead [lindex [split $tunepieces(head) \n] 0]
        set midiname [expr int(rand()*100000)]
        set tunepieces(head) [string replace $tunepieces(head) 0 [string length $xhead] "X:$midiname\n"]
        set out_fd [open X.tmp w]
        myputs  $out_fd $tunepieces(head)
        set barsminus1 [expr $barsperline - 1]
        # cause problem for plain abc tune with no voices
        #if {[info exist tunepieces(0-0)]} {
        #   myputs  $out_fd $tunepieces(0-0)}
        if {$nvoices >= 1} {
            # for multivoiced tunes
            for {set n 0} {$n < $nvoices} {incr n} {
                set voice [lindex $voicelist $n]
                set vital_info [extract_comments_for_voice $voice]
                puts $out_fd V:$voice
                foreach elem $vital_info {
                    myputs $out_fd $elem
                }
                for {set i $firstbar} {$i < $lastbar} {incr i} {
                    if {![info exist tunepieces($voice-$i)]} continue
                    set firstchar [string index $tunepieces($voice-$i) 0]
                    if {$firstchar == "%"} {
                        if {$lastoutputchar != "\n"} {myputs  $out_fd "\n"}
                        myputs  $out_fd $tunepieces($voice-$i)
                        continue} elseif {
                        [regexp $fieldpat $tunepieces($voice-$i)]} {
                        if {$lastoutputchar != "\n"} {myputs  $out_fd "\n"}
                        myputs  $out_fd $tunepieces($voice-$i)
                        continue}
                    myputs  $out_fd $tunepieces($voice-$i)
                    if {[expr $i % $barsperline] == $barsminus1} {
                        myputs  $out_fd \n
                    }
                }
                if {$lastoutputchar != "\n"} {myputs  $out_fd "\n"}
            }
        } else {
            # for tunes with no voices
            set vital_info [extract_comments_for_voice 0]
            foreach elem $vital_info {
                myputs $out_fd $elem
            }
            for {set i $firstbar} {$i < $lastbar} {incr i} {
                if {![info exist tunepieces(0-$i)]} continue
                set firstchar [string index $tunepieces(0-$i) 0]
                if {$firstchar == "%"} {
                    if {$lastoutputchar != "\n"} {myputs  $out_fd "\n"}
                    myputs  $out_fd $tunepieces(0-$i)
                    continue} elseif {
                    [regexp $fieldpat $tunepieces(0-$i)]} {
                    if {$lastoutputchar != "\n"} {myputs  $out_fd "\n"}
                    myputs  $out_fd $tunepieces(0-$i)
                    continue}
                myputs  $out_fd $tunepieces(0-$i)
                if {[expr $i % $barsperline] == $barsminus1} {
                    myputs  $out_fd "\n"
                }
            }
        }
        close $out_fd
    }
    
    proc piece_cmp {a b} {
       if {[string index $a 0] == "x"} {set a [string range $a 1 end]}
       if {[string index $b 0] == "x"} {set b [string range $a 1 end]}
       set a [split $a "-"]
       set b [split $b "-"]
       set a0 [lindex $a 0]
       set b0 [lindex $b 0]
       if {$a0 > $b0} {return 1}
       if {$a0 < $b0} {return -1}
       set a0 [lindex $a 1]
       set b0 [lindex $b 1]
       if {$a0 > $b0} {return 1}
       if {$a0 < $b0} {return -1}
       return 0 
       }
    

    proc dump_tunepieces {} {
        global tunepieces
        global exec_out
        set exec_out ""
        set clist [array names tunepieces]
        set clist [lsort -command piece_cmp $clist]
        foreach elem $clist {
            # puts "$elem $tunepieces($elem)"
            append exec_out "$elem\t $tunepieces($elem)\n"
        }
        show_console_page $exec_out char
    }
    
    
    
    proc reconstitute {} {
        global midi
        global abctxtw
        global barsperline barsperstaff
	global do_reconstitute
	set do_reconstitute 1
        set barsperline $midi(midibpl)
        set barsperstaff $midi(midibps)
        if {$barsperline > $barsperstaff} {
            .abc.reformat.mesg configure -text "barsperline > barsperstaff. adjusting."
            set barsperline $barsperstaff
            set midi(midibpl) $barsperline
            }
        $abctxtw delete 1.0 end
        if {$midi(interleave)} {
            reconstitute_pieces_voice_interleaved
        } else {
            reconstitute_pieces_separate_voices
        }
        tag_text $abctxtw
	$abctxtw edit reset
    }
    
    proc strip_out_V_command {s} {
    # The reconstitute functions insert ignore the existing
    # V: commands in the tune and write its own V: commands.
    # Thus, if there are additional options such as clef=
    # in the V: command, they will have to be added manually.
        set s [split $s "\n"]
        #puts "strip_out ... before $s"
        set t ""
        foreach l $s {
          if {[string first "V:" $l] == -1} {
            if {[string length $l] < 1} continue
            set t $t$l\n
            }
        }
        #puts "strip_out ... after $t"
        return $t
   }

 
    proc reconstitute_pieces_voice_interleaved {} {
        global abctxtw
        global tunepieces
        global nvoices nbars nbarsv voicelist
        global barsperline barsperstaff
	global midi
        set fieldpat {^L:|^M:|^K:|^Q:|^w:|V:}
        
        #puts "barsperline = $barsperline barsperstaff = $barsperstaff"

        if {$barsperline < 1} {set barsperline 1}
        
        #check_nbarsv
        $abctxtw insert end $tunepieces(head) head
        # $abctxtw tag bind head <ButtonPress-1> [list barclick head]
        if {$nvoices < 1} {.abc.reformat.mesg configure -text "no voices are present"
            reconstitute_pieces_separate_voices
            return
        }
        if {[info exist tunepieces(0-0)]} {
            $abctxtw insert end $tunepieces(0-0)}
        set i 0
        while {$i < $nbars} {
            for {set n 0} {$n < $nvoices} {incr n} {
                set voice [lindex $voicelist $n]
                if {$i >= $nbarsv($voice)} continue
                # each line should have a voice command.
                #puts "$voice-$i --> $tunepieces($voice-$i)"


                set lastchar [$abctxtw get "end -2 chars"]
                #puts "lastchar = $lastchar i = $i"
                if {$lastchar != "\n"} {
                        $abctxtw insert end "\n"}
                if {$midi(inline_voice)} {
			$abctxtw insert end "\[V:$voice\] "} else {
                        $abctxtw insert end "V:$voice \n"}
                set lastchar  "\n"
                set barsinline 0
                for {set j 0} {$j < $barsperstaff} {incr j} {
                    set k [expr $i + $j]
                    #puts "voice = $voice  k = $i + $j $tunepieces(x-$voice-$k)"
                    if {$k >= $nbarsv($voice)} break

                    # put any comments or field commands on a new line
                    if {[info exist tunepieces(x-$voice-$k)]} {
                        set t $tunepieces(x-$voice-$k)    
                        set t [strip_out_V_command $t]
                        #puts "k = $k $tunepieces($voice-$k) $tunepieces(x-$voice-$k)"
                        if {[string length $t] > 0} { 
                           if {$lastchar != "\n"} {
                               if {$k % $barsperstaff != 0} {
                                  $abctxtw insert end "\\\n"
                                  } else {
                                  if {$n == 0} {$abctxtw insert end " % [expr $i +$j + $midi(startbar) -1]"}
                                  $abctxtw insert end "\n"}
                               set lastchar "\n"}
                           $abctxtw insert end $t x-$voice-$k
                           $abctxtw tag bind x-$voice-$k <ButtonPress-1> [list barclick x-$voice-$k]
                        }
                    }
		$abctxtw insert end $tunepieces($voice-$k) $voice-$k
                incr barsinline
                if {[expr $j + 1] >= $barsperstaff} continue
                if {$barsinline >= $barsperline} {
                     $abctxtw insert end "\\\n"
                     set barsinline 0
                     }
                }
                if {$n == 0} {
                   if {$midi(reformat_bars)} {
		      $abctxtw insert end " % [expr $i +$j + $midi(startbar) -1]"}
                   $abctxtw insert end "\n"
                   set barsinline 0 
                   }
            }
            
            incr i $barsperstaff
        }
    }
    
    
    proc reconstitute_pieces_separate_voices {} {
        global abctxtw
        global tunepieces
        global nvoices nbars voicelist
        global barsperline barsperstaff
	global midi
        set fieldpat {^L:|^M:|^K:|^Q:|^w:}
        $abctxtw delete 1.0 end
        $abctxtw insert end $tunepieces(head) head
        #        $abctxtw tag bind head <ButtonPress-1> [list barclick head]
        # we ignore all V: commands in the tunepieces() except for
        # the first one belonging to the voice.

        set barsinline 0
        set barsinstaff 0
        set newline 1
        if {$nvoices >= 1} {
            # for multivoiced tunes

            for {set n 0} {$n <= $nvoices} {incr n} {
                set firstvoicecmd 1
                set voice [lindex $voicelist $n]
                for {set i 0} {$i < $nbars} {incr i} {
                    if {![info exist tunepieces($voice-$i)]} continue
                    #puts "newline = $newline"
                    if {[info exist tunepieces(x-$voice-$i)]} {
                        set t $tunepieces(x-$voice-$i) 
                        if {[string first "V:" $t] != -1 && $firstvoicecmd == 1} {
                            if {$newline == 0} {
                                $abctxtw insert end "\n"
                                }
                            $abctxtw insert end $t x-$voice-$i
                            set firstvoicecmd 0
                            set barsinstaff 0
                       } else {
                            set t [strip_out_V_command $t]
                            if {[string length $t] > 1}  {
                                if {$newline == 0} {
                                    $abctxtw insert end "\n"
                                    }
                                $abctxtw insert end $tunepieces(x-$voice-$i) x-$voice-$i
                                set barsinline 0
                                set newline 1
                            }
                      }

                       #puts "x-$voice-$i $tunepieces(x-$voice-$i) $barsinline $barsinstaff"
                       set newline 1
                       }
                    
                    $abctxtw insert end $tunepieces($voice-$i) $voice-$i
                    set newline 0
                    incr barsinline
                    incr barsinstaff
                    #puts "$voice-$i $tunepieces($voice-$i) $barsinline $barsinstaff"
                    

                    if {$barsperstaff == $barsinstaff && $newline == 0 } {
			if {$midi(reformat_bars)} {
                           $abctxtw insert end " % [expr $i + $midi(startbar)]\n"
                           } else {
                           $abctxtw insert end "\n"
                           }
                        set barsinline 0
                        set barsinstaff 0
                        set newline 1
                        }
                    if  {$barsinline == $barsperline} {
                         $abctxtw insert end "\\\n"
                         set barsinline 0
                         set newline 1 
                        }

                    if {$barsinline != 0} {set newline 0}
                    }
                #$abctxtw insert end "\n"
                }
           } else {

            # for tunes with no voices
            set newline 1
            for {set i 0} {$i < $nbars} {incr i} {

                if {![info exist tunepieces(0-$i)]} continue

                if {[info exist tunepieces(x-0-$i)]} {
                    if {!$newline} {
                      $abctxtw insert end "\n"
                      set newline 1
                      }
                    $abctxtw insert end $tunepieces(x-0-$i) x-0-$i
                    }

                set firstchar [string index $tunepieces(0-$i) 0]
                set lastchar [$abctxtw get "end -2 chars"]
                if {$firstchar == "%" && $lastchar != "\n"} {
                    $abctxtw insert end "\n"
                    }
                # put any field commands on a new line
                set success [regexp -indices  $fieldpat $tunepieces(0-$i) location]
                if {$success} {
                    set f  [lindex $location 0]} else {
                    set f -1}
                if {$f == 0}  {$abctxtw insert end "\n"
                } else {
                       $abctxtw insert end $tunepieces(0-$i) 0-$i
                       incr barsinline
                       incr barsinstaff
                       set newline 0
                       }

                if {$barsperstaff == $barsinstaff && $newline == 0 } {
			if {$midi(reformat_bars)} {
                           $abctxtw insert end " % [expr $i + $midi(startbar)]\n"
                           } else {
                           $abctxtw insert end "\n"
                           }
                        set barsinline 0
                        set barsinstaff 0
                        set newline 1
                        }
               
                if {$barsinline == $barsperline} {$abctxtw insert end "\\\n"
                    set barsinline 0
                    set newline 1}
            }
            set lastchar [$abctxtw get "end -2 chars"]
            if {$lastchar != "\n"} {$abctxtw insert end "\n"
                incr nlines}
        }
    }
    
    proc refactor_textcontents {} {
        global abctxtw
        global alreadyloaded
	global do_reconstitute
        foreach {key value index} [$abctxtw dump 1.0 end] {
            if {$key == "text"} {
                append tunestring $value}
        }
        erase_all
        Refactor::process_tune $tunestring
        set alreadyloaded 1
        if {$do_reconstitute} {reconstitute}
    }
    
    
    
}

# end of namespace Refactor

#end of Refactor

set hlp_reformat "Reformat\n\n\
        The function is designed for multivoiced abc notated files. It will\
        reorganize the tune in one of two ways. If voice interleave is not\
        selected, then all the lines for a voice are grouped together.\
        If voice interleave is selected, then the voices are printed for\
        each staff line.  Both representations have their advantages\
        and disadvantages. For example, it is easier to remove a voice if all\
        the lines are grouped together.\n\n\
        Other parameters control the number of bars on a text line or on\
        a musical staff.\n\n\
        The function does not handle multipart tunes correctly and V:\
        descriptors such as clef= will have to be added manually.
"


# Part 38.0               Mode Recognition

proc note_histogram {} {
    global midi sel
    global exec_out
    set sel [title_selected]
    set sel [tune2Xtmp $sel $midi(abc_open)]
    set cmd "exec [list $midi(path_abcmatch)] X.tmp"
    append cmd " -wpitch_hist"
    catch {eval $cmd} exec_out
    if {[string first "no such" $exec_out] >= 0} {
      abcmidi_no_such_error $midi(path_abcmatch)
      return}
    interpret_note_histogram
}

proc interpret_note_histogram {} {
global exec_out
global total
global histogram
global midi
set total 0
for {set i 0} {$i < 128} {incr i} {set histogram($i) 0}
set results [split $exec_out "\n"]
foreach line $results {
  if {[llength $line] == 2} {
     scan $line "%d %d" pitch freq
     if {$pitch == 0} continue
     set histogram($pitch) $freq
     incr total $freq
     }
  }

if {$total < 1} {messages "Corrupted histogram from abcmatch"
                 return
                }

for {set i 0} {$i < 128} {incr i} {
    set histogram($i) [expr $histogram($i)/double($total)]
    }
show_note_distribution
if {$midi(mode_guess) == "mse"} {
  guess_mode_mse} else {
  guess_mode_correlation}
}

proc plot_pitch_interval_histogram {} {
    global scanwidth scanheight
    global xlbx ytbx xrbx ybbx
    global histogram
    global total
    global exec_out
    set maxgraph 0.0
    set xpos [expr $xrbx -40]
    for {set i -12} {$i < 12} {incr i} {
        if {$histogram($i) > $maxgraph} {set maxgraph $histogram($i)}
    }
    
    set maxgraph [expr $maxgraph + 0.2]
    set pitchc .pitchinterval.c
    if {[winfo exists .pitchinterval] == 0} {
        toplevel .pitchinterval
        position_window ".pitchinterval"
        pack [canvas $pitchc -width $scanwidth -height $scanheight]\
                -expand yes -fill both
    } else {.pitchinterval.c delete all}
    
    $pitchc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2 -fill white
    Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx -12.0 12.0 0.0 $maxgraph
    Graph::draw_y_ticks $pitchc 0.0 $maxgraph 0.1 2 %3.1f
    Graph::draw_x_ticks $pitchc -10.0 12.0 2.0 2 0 %3.1f

    
    set iy [expr $ybbx +10]
    for {set i -12} {$i <12} {incr i} {
        set ix [Graph::ixpos [expr $i +0.5]]
        set iyb [Graph::iypos $histogram($i)]
        set count [expr round($histogram($i)*$total)]
        append exec_out  "$histogram($i) $count\n"
        set ix [Graph::ixpos [expr double($i)]]
        set ix2 [Graph::ixpos [expr double($i+1)]]
        $pitchc create rectangle $ix $ybbx $ix2 $iyb -fill blue
    }
    $pitchc create rectangle $xlbx $ytbx $xrbx $ybbx -outline black\
            -width 2
    if {[winfo exist .notice]} {show_message_page $exec_out word}
    bind .pitchinterval.c <3> {histogram_ps_output .pitchinterval.c}
}


proc note_interval_histogram {} {
    global midi sel
    global exec_out
    set sel [title_selected]
    set sel [tune2Xtmp $sel $midi(abc_open)]
    set cmd "exec [list $midi(path_abcmatch)] X.tmp"
    append cmd " -interval_hist"
    catch {eval $cmd} exec_out
    interpret_note_interval_histogram
}

proc interpret_note_interval_histogram {} {
global exec_out
global total
global histogram
global midi
set total 0
for {set i -12} {$i < 13} {incr i} {set histogram($i) 0}
set results [split $exec_out "\n"]
foreach line $results {
  if {[llength $line] == 2} {
     scan $line "%d %d" pitch freq
     if {$pitch == 0} continue
     set histogram($pitch) $freq
     #puts "histogram($pitch) = $histogram($pitch)"
     incr total $freq
     }
  }

if {$total < 1} {messages "Corrupted interval histogram from abcmatch"
                 return
                }

for {set i -12} {$i < 12} {incr i} {
    set histogram($i) [expr $histogram($i)/double($total)]
    }
plot_pitch_interval_histogram
}



array set mode_reference {
        maj {4 0 2 0 3 2 0 3 0 2 0 2}
        min {4 0 2 3 0 2 0 3 2 0 0 2}
        dor {4 0 2 3 0 2 0 3 0 2 2 0}
        phr {4 2 0 3 0 2 0 3 2 0 2 0}
        lyd {4 0 2 0 3 0 2 3 0 2 0 2}
        mix {4 0 2 0 3 2 0 3 0 2 2 0}
        aeo {4 0 2 3 0 2 0 3 2 0 2 0}
}

array set mode_reference {
        hexmaj {4 0 2 0 3 2 0 3 0 2 0 0}
        hexmin {4 0 2 3 0 2 0 3 2 0 0 0}
        }

array set mode_reference {
    penmaj {
        3 0 2 0  2 0 0 3  0 2 0 0
    }
    penmin {
        3 0 0 2  0 2 0 3  0 0 2 0
    }
    whole {
        2 0 1 0 1 0 1 0 1 0 1 0
    }
    octatonic-HalfWhole {
        2 1 0 1.5  1.5 0 1 1.5  0 1 1 0
    }
    octatonic-WholeHalf {
        3 0 2 2  0 2 2 0  2 2 0 2
    }
}


array set modenames {maj major min minor
 dor dorian phr phrygian
 lyd lydian mix mixolydian
 aeo "natural minor"
 hexmaj "hexatonic major" hexmin "hexatonic minor"
 penmaj "pentatonic major" penmin "pentatonic minor"
 whole "whole tone"}

set hlp_pitchclass "Mode Determination\n\n\
The program attempts to estimate the key and mode of the\
tune based on the distribution of the musical pitches (weighted\
by the note length). The distribution is compared to the\
expected patterns for the different modes either\
using the correlation measure or the euclidean\
distance (selected by the user). The five best\
hypotheses are listed with the preferred one at the\
top.\n\n\
If you right click on the pitchclass histogram,  the histogram will be saved\
in a PostScript file that you choose.\
"



proc guess_mode_correlation {} {
    global notedist
    global mode_reference
    set scorelist {}
    foreach mode {maj min dor phr lyd mix aeo hexmaj hexmin penmaj penmin whole} {
      set ref $mode_reference($mode)
#     compute reference mean
      set rmean 0
      for {set k 0} {$k < 12} {incr k} {      
        set rmean [expr $rmean + [lindex $ref $k]]
        }
      set rmean [expr $rmean/12.0]
      for {set k 0} {$k < 12} {incr k} {
        set dotprod 0.0
        set d1sum 0.0
        set d2sum 0.0
        for {set i 0} {$i < 12} {incr i} {
          set multiplier [lindex $ref [expr ($i - $k + 12) % 12]]
# subract the expected mean
          set multiplier [expr $multiplier - $rmean] 
          set notelikelihood [expr $notedist($i) - 0.083333333]
          set elem [expr $notelikelihood * $multiplier]
          set d1 [expr $multiplier * $multiplier]
          set d2 [expr $notelikelihood * $notelikelihood]
          set dotprod [expr $dotprod + $elem]
          set d1sum [expr $d1sum + $d1]
          set d2sum [expr $d2sum + $d2]
          }
        set correlation [expr $dotprod / sqrt($d1sum * $d2sum)]
        #set score [list $dotprod [list $mode $k]]
        set score [list $correlation [list $mode $k]]
        lappend scorelist $score
        } 
      }
   set scoreresults [lsort -index 0 -decreasing -real  $scorelist]
   show_mode_guess_results $scoreresults
}

proc guess_mode_mse {} {
    global notedist
    global mode_reference
    set scorelist {}
    foreach mode {maj min dor phr lyd mix aeo hexmaj hexmin penmaj penmin whole} {
      set ref $mode_reference($mode)
      set refsum 0.0
      for {set k 0} {$k < 12} {incr k} {
          set refsum [expr $refsum + [lindex $ref $k]]
          }
      for {set k 0} {$k < 12} {incr k} {
        set summedsqerr 0.0
        for {set i 0} {$i < 12} {incr i} {
          set predicted [lindex $ref [expr ($i - $k + 12) % 12]]
          set predicted [expr $predicted /$refsum]
          set err [expr $predicted - $notedist($i)]
        #  puts "[format %6.3f $predicted] [format %6.3f $notedist($i)] [format %6.3f $err] [format %7.5f $summedsqerr]"
          set summedsqerr [expr $err*$err + $summedsqerr]
          }
        set euclid [expr sqrt($summedsqerr)]
        set score [list $euclid [list $mode $k]]
        lappend scorelist $score
        } 
      }
   set scoreresults [lsort -index 0 -increasing -real  $scorelist]
   show_mode_guess_results $scoreresults
}


proc show_mode_guess_results {scoreresults} {
    global note
    global midi
    global hlp_pitchclass
    global modenames
  
    if {[winfo exists .pitchclass.d] != 0} {
        destroy .pitchclass.d
        }
    pack [frame .pitchclass.d]
    set w .pitchclass.d.c
    pack [frame .pitchclass.d.c] [frame .pitchclass.d.r] -side left
    radiobutton $w.cor -text "correlation" -command guess_mode_correlation -variable midi(mode_guess) -value cor
    radiobutton $w.euc -text "euclid distance" -command guess_mode_mse -variable midi(mode_guess) -value mse
    button $w.help -text "help" -command {show_message_page $hlp_pitchclass word}
    pack $w.cor $w.euc $w.help -side bottom -anchor w
    for {set i 0} {$i < 5} {incr i} {
      set guess [lindex $scoreresults $i]
      set val [lindex $guess 0]
      set val [format "%7.4f    " $val]
      set model [lindex $guess 1]
      set mode [lindex $model 0]
      set key $note([lindex $model 1])
      set w .pitchclass.d.r
      label $w.0$i -text $val
      label $w.1$i -text $key
      label $w.2$i -text $modenames($mode) 
      grid $w.0$i $w.1$i $w.2$i
      }
    }



global xref title ref filename inhandle

namespace eval Matcher {
    
    proc load_pdf {} {
#load probability distribution function
        global inhandle
        global xref title keysignature ref filename inhandle
        set n [scan [gets $inhandle] "%4d %s %s" xref filename keysignature]
        set title [gets $inhandle]
        for {set i 0} {$i <12} {incr i} {
            set pitchdata [gets $inhandle]
            set n [scan $pitchdata "%4d %f" j pdf]
            if {$n < 2} break
            set ref($j) $pdf
        }
    }

    proc find_pdf_for {refno} {
        global ref
        global midi
        set inhandle [open $midi(moderef) r]
        while {![eof $inhandle]} {
          set n [scan [gets $inhandle] "%4d" xref]
          if {$xref == $refno} {
            gets $inhandle
            for {set i 0} {$i <12} {incr i} {
              set pitchdata [gets $inhandle]
              set n [scan $pitchdata "%4d %f" j pdf]
              if {$n < 2} break
              set ref($j) $pdf
              }
            return
            } else {
              for {set i 0} {$i <13} {incr i} {gets $inhandle}
            }  
          }
        }

    
    proc match_histogram_correlation {} {
        global notedist ref
        global idtune xref title keysignature filename
        global inhandle
        global scoreresults
        global midi
        if {![winfo exist .pitchclass]} {
          note_histogram}
        set scorelist {}
        set k 0
        if {![file exist $midi(moderef)]} {
          if {[file exist nmodes.abc]} {
             exec $midi(path_abcmatch) nmodes.abc -pitch_table > nmodes.tab
             messages "I could not find $midi(moderef) but I found nmodes.abc.\
I converted nmodes.abc to nmodes.tab and made it the reference database."
             set midi(moderef) nmodes.tab
             } else {
             messages "You need to specify a abc file with a collection of
             tunes in the entry box and press return."
             expose_histmatches
             return
             }
          #exec $midi(path_abcmatch) nmodes.abc -pitch_table > nmodes.tab
          #messages "nmodes.tab was created from nmodes.abc"
          #set midi(moderef) nmodes.tab
        }
        if {[file extension $midi(moderef)] != ".tab"} {
             make_tab_file
             }
        set inhandle [open $midi(moderef) r]
        ttk::progressbar .pitchclass.prg -mode indeterminate
        pack .pitchclass.prg
        update
        .pitchclass.prg start
        while {![eof $inhandle]} {
            load_pdf
            update
            set idtune($k) [list $xref $keysignature $title $filename]
            set dotprod 0.0
            set d1sum 0.0
            set d2sum 0.0
            for {set i 0} {$i < 12} {incr i} {
                set multiplier $ref($i)
                set multiplier [expr $multiplier - 0.08333333]
                set notelikelihood [expr $notedist($i) - 0.083333333]
                set elem [expr $notelikelihood * $multiplier]
                set d1 [expr $multiplier * $multiplier]
                set d2 [expr $notelikelihood * $notelikelihood]
                set dotprod [expr $dotprod + $elem]
                set d1sum [expr $d1sum + $d1]
                set d2sum [expr $d2sum + $d2]
            }
            set correlation [expr $dotprod / sqrt($d1sum * $d2sum)]
            #      puts $correlation
            #set score [list $dotprod  $k]
            set score [list $correlation  $k]
            lappend scorelist $score
            incr k
        }
        .pitchclass.prg stop
        destroy .pitchclass.prg
        set scoreresults [lsort -index 0 -decreasing -real  $scorelist]
        list_best_matches $scoreresults
    }
    
    proc expose_histmatches {} {
        global hlp_histmatches
        global df
        global midi
        if {![winfo exist .histmatches]} {
          toplevel .histmatches
          position_window ".histmatches"
          frame .histmatches.top
          set h .histmatches.top
          label $h.lab -text "mode ref file" -font $df
          entry $h.ent -width 32 -textvariable midi(moderef) -font $df
          button $h.bro -text browse -font $df -command Matcher::browse_tab_file
          button $h.help -text help -font $df \
             -command {show_message_page $hlp_histmatches word}
          pack $h -side top 
          pack $h.lab $h.ent $h.bro $h.help -side left
        
          frame .histmatches.rest
          pack .histmatches.rest
          bind .histmatches.top.ent <Return> {
            Matcher::make_tab_file 
            focus .histmatches.top
            Matcher::match_histogram_correlation 
            }
         }    
}

    proc list_best_matches {scoreresults} {
        global idtune
        global df
        global midi
        expose_histmatches
        set h .histmatches.rest
#destroy all descendents of .histmatches leaving .histmatches intact
        foreach w [winfo children $h] {destroy $w}

        grid [label $h.z -text "best matches" -font $df] -column 3
        for {set i 0} {$i < 10} {incr i} {
            set result [lindex $scoreresults $i]
            if {$result <0.95 && $i > 3} break
            set val [format "%7.4f    " [lindex $result 0]]
            set idnum [lindex $result 1]
            set refno [lindex $idtune($idnum) 0]
            set key [lindex $idtune($idnum) 1]
            set title [lindex $idtune($idnum) 2]
            set filename [lindex $idtune($idnum) 3]
            label $h.v$i -font $df -text $val
            label $h.r$i -font $df -text $refno 
            label $h.k$i -font $df -text $key
            label $h.t$i -font $df -text $title
            radiobutton $h.radio$i -text $i -value $i\
             -command "Matcher::plot_pdf_for $i" -variable choice
            button $h.play$i -text play -font $df -image kmix-16  \
             -borderwidth $midi(butborder) \
             -command "play_selected_tune_in_file $filename $refno" 
            button $h.abc$i -text display -font $df -image spellcheck-16\
             -borderwidth $midi(butborder) \
             -command "show_selected_tune_in_file $filename $refno" 
            set choice 0
            grid $h.v$i $h.r$i $h.k$i $h.t$i $h.radio$i $h.play$i $h.abc$i -sticky w
        }
# plot results for first choice
    set result [lindex $scoreresults 0]
    set best_idnum [lindex $result 1]
    set xref [lindex $idtune($best_idnum) 0]
    find_pdf_for $xref
    plot_pdf
    $h.radio0 invoke
    }

   proc plot_pdf {} {
       global ref
       global xlbx ytbx xrbx ybbx
       global pitchxfm
       set pitchc .pitchclass.c
       Graph::restore_transform $pitchxfm
       for {set i 0} {$i < 12} {incr i} {
        set ix [Graph::ixpos [expr $i +0.5]]
        set ix2 [expr $ix - 2]
        set iyb [Graph::iypos $ref($i)]
        set iy2 [expr $iyb + 2]
        $pitchc create rectangle $ix $ybbx $ix2 $iyb -fill red -tag pdf
        }
       }

   proc plot_pdf_for {n} {
       global scoreresults idtune
       set pitchc .pitchclass.c
       $pitchc delete pdf
       set result [lindex $scoreresults $n]
       set idnum [lindex $result 1]
       set xref [lindex $idtune($idnum) 0]
       find_pdf_for $xref
       plot_pdf
       }

   proc browse_tab_file {} {
    global midi 
    set ext {
            {{tab or abc file} {.tab .abc}}
    }
    set openfile [tk_getOpenFile -filetypes $ext]
    if {[string length $openfile] < 1} return 
    set extname [file extension $openfile]
    set rootname [file rootname $openfile]
    if {$extname == ".tab"} { 
      set midi(moderef) $openfile } elseif {$extname == ".abc"} {
        messages "The program will create a *.tab formatted file from $openfile and save it in $rootname.tab"
        exec $midi(path_abcmatch) $openfile -pitch_table > $rootname.tab
        set midi(moderef) $rootname.tab
        }
    }


proc make_tab_file {} {
global midi
set openfile $midi(moderef)
set extname [file extension $openfile]
set rootname [file rootname $openfile]
if {$extname == ".abc"} { 
     messages "The program will create a *.tab formatted file from $openfile and save it in $rootname.tab"
    exec $midi(path_abcmatch) $openfile -pitch_table > $rootname.tab
    set midi(moderef) $rootname.tab
    }
}





# end of Matcher Namespace    
}

set hlp_histmatches "histmatches help\n\n\
Though nmodes.tab may come with the runabc distribution, it still\
needs to be customized for your system. To do this, browse to\
the file nmodes.abc and open. A new nmodes.tab file will be created for\
your system and the program should succeed in playing or displaying\
the selected tune from now on.\n\n\
You need to do this anytime you update runabc. (nmodes.abc\
is updated too occasionally.)
"

proc play_selected_tune_in_file {filename refno} {
  global midi files
  global exec_out
  global hlp_histmatches
  if {![file exist $filename]} {show_message_page $hlp_histmatches word}
  if {[file exist $filename]} {
    set modereftime [file mtime $midi(moderef)]
    set filereftime [file mtime $filename]
    if {$modereftime < $filereftime} {
       show_message_page "The file $filename was updated recently. You\
	need to recreate $midi(moderef). Click the help button in the\
	histmatches window to find out how to do this." word}
    }
# in case  $midi(midiplayer_2_prot) is set to 1
  set files X1.mid
  set cmd "exec $midi(path_abc2midi) $filename $refno -Q $midi(tempo) -o X1.mid"
  if {$midi(tuning) != 440} {append cmd " -TT $midi(tuning)"}
  if {$midi(nofermata) == 1} {append cmd " -NFER"}
  catch {eval $cmd} result
  set exec_out $cmd\n$result
  play_midis 1
  } 

proc show_selected_tune_in_file {filename xref} {
  global df
  global hlp_histmatches
  global midi
  if {![file exist $filename]} {show_message_page $hlp_histmatches word}
  if {[file exist $filename]} {
    set modereftime [file mtime $midi(moderef)]
    set filereftime [file mtime $filename]
    if {$modereftime < $filereftime} {
       show_message_page "The file $filename was updated recently. You\
	need to recreate $midi(moderef). Click the help button in the\
	histmatches window to find out how to do this." word}
    }
  set abchandle [open $filename r]
  set p .headers
  if {![winfo exist $p]} {
      toplevel $p
      text $p.t -width 50 -height 10 -bg #f4ece0 \
                    -yscrollcommand {.headers.ysbar set} \
                    -xscrollcommand {.headers.xsbar set} \
                    -font $df -exportselection false
      scrollbar $p.ysbar -orient vertical -command {.headers.t yview}
      scrollbar $p.xsbar -orient horizontal -command {.headers.t xview}
      button $p.more -text more... -font $df -bd 0\
                -command Refactor::show_more -state disable
      pack $p.ysbar -side right   -fill y -in $p
      pack $p.xsbar -side bottom  -fill x -in $p
      pack $p.t -fill both -expand y -in $p
      pack $p.more -anchor w
      }

  $p.t delete 0.0 end
  while {[gets $abchandle line] >= 0 } {
        set initialchar [string index $line 0]
        if {[string equal $initialchar X]} {
            set number [string range $line 2 10]
            if {$number == $xref} {
               $p.t insert end $line\n
               while {[string length $line] > 0 } {
               set line  [gets $abchandle]
               if {[string index $line 0] == "X"} break;
               $p.t insert end $line\n
               }
        }
     }
  }
}

# Part 39.0               Advanced abcm2ps support

#source m2ps.tcl


global m2psresetcmd


set abcm2ps_entry ""
set fmtcmd ""
set m2psarg($fmtcmd) ""
set m2psresetcmd 1

proc m2ps_show_intro {} {
set introtext "This tool is used for inserting abcm2ps/abc2svg\
inline header statements into abc notated files. The tool was created\
using the information in the\
http://moinejf.free.fr/abcm2ps-doc/index.html web page. Examples\
from this web page are not included here.\n\n\
Click on any command names in the\
left listbox.  A description of the command should appear here and\
either a button or combobox should appear below. If a combobox appears,\
there are several suggested values for the command.\
Select the version of the command to be added to the text window\
below (light blue background). You are able to edit command\
in the text window if you wish to change the parameter values.\n\n\ 
Note that not all commands are listed on the left. For example,\
if this window was called when abc2svg is active, the commands\
autoclef, micronewps, alignbar, ... are not available.\
Likewise, if this wndow as called when abcm2ps is active, the\
commands equalbars, singleline, beamslope,... are not available.\n\n\
You can save the contents of the text window to a fmt file\
or to a clipboard. The clipboard is handy when you are manually\
editing an abc file. The fmt file can be used to instruct\
either abcm2ps or abc2svg on how to render the abc music notation.\
The clip board is updated automatically. However, if\
you edited the text window directly, you should update the clip board using\
the button 'copy to clip board'.\n\n\
Note that when this application closes, the clipboard does not persist\
on Linux (using the X display) but it persists on Microsoft Windows.\n\n\
The button labeled 'test' will insert all the abcm2ps commands at\
the head of a selected abc tune (in X.tmp) and display the\
resulting file.
"
  set p .m2ps.top.right
  $p.t delete 1.0 end
  $p.t configure -wrap char
  $p.t insert end $introtext
}

proc m2ps_show_descript {fmtcmd} {
  global m2pshelp
  set p .m2ps.top.right
  $p.t delete 1.0 end
  $p.t configure -wrap char
  $p.t insert end $m2pshelp($fmtcmd)
  }

proc m2ps_show_command {fmtcmd} {
global m2psarg
global m2psdefault
global m2psscope
global abcm2ps_entry
#set psarg [string map {"//" ""} $m2psarg($fmtcmd)]
set psarg [string map {\{ "{" \} "}" \[ "[" \] "]" \\ ""} $m2psarg($fmtcmd)]
#puts $m2psarg($fmtcmd)
#puts $psarg
if {$psarg == "{}"} {
    set t $fmtcmd} else {
    set t "$fmtcmd $psarg"}
.m2ps.head.l configure -text $t 
if {![info exist m2psdefault($fmtcmd)]} {set m2psdefault($fmtcmd) none}
set t "Defaults: $m2psdefault($fmtcmd)"
.m2ps.head.d configure -text $t

#set t "Scope: $m2psscope($fmtcmd)"
#.m2ps.top.right.s configure -text $t

set abcm2ps_entry "%%$fmtcmd $m2psdefault($fmtcmd)"
show_m2ps_comboboxes $fmtcmd
}

proc m2ps_replace_custom_args {} {
global fmtcmd
global abcm2ps_entry
global m2psresetcmd
global customvalue
update
set value [.m2ps.bot.a.custom get]
set abcm2ps_entry $value
m2ps_append_to_text
}


proc m2ps_replace_bool_arg  {} {
global fmtcmd
global m2psarg
global boolvalue 
global abcm2ps_entry
global m2psresetcmd
set abcm2ps_entry $boolvalue
}

proc m2ps_replace_def {} {
global fmtcmd m2psarg abcm2ps_entry
set abcm2ps_entry "%%$fmtcmd $m2psarg($fmtcmd)"
m2ps_append_to_text
}

proc m2ps_show_help {loc} {
global fmtcmd
global m2psresetcmd
set m2psresetcmd 1
if {$loc < 0} return
set fmtcmd [.m2ps.top.left.list get $loc]
m2ps_show_descript $fmtcmd
m2ps_show_command $fmtcmd
}

proc m2ps_append_to_text {} {
global abcm2ps_entry
global m2psresetcmd
if {$m2psresetcmd == 0} {m2ps_delete_last}
.m2ps.bot.t insert end $abcm2ps_entry\n
m2ps_copy_to_clipboard
set m2psresetcmd 0
}

proc m2ps_delete_all {} {
.m2ps.bot.t delete 1.0 end
}

proc m2ps_delete_last {} {
.m2ps.bot.t delete  "end -2 lines" end
}


proc m2ps_copy_to_clipboard {} {
selection clear
clipboard clear
foreach {key value index} [.m2ps.bot.t dump 1.0 end] {
  if {$key == "text"} {clipboard append $value}
  }
}

proc m2ps_load {} {
global midi
set doublepercent %%
set formattype {{{format files} {*.fmt}}}
set filedir [file dirname $midi(ps_fmt_file)]
set formatname [tk_getOpenFile -filetypes $formattype -initialdir $filedir]
if {[string length $formatname] > 1} {
  set midi(ps_fmt_file) $formatname
  }
if {[file exist $midi(ps_fmt_file)]} {
  set inhandle [open $midi(ps_fmt_file)]
  set fmt [read $inhandle]
  close $inhandle
  } 
.m2ps.bot.t delete 1.0 end
foreach line [split $fmt \n] {
  if {[string length $line] < 2} continue
  set line [string trimleft $line]
  set line $doublepercent$line
  .m2ps.bot.t insert end $line\n
  }
}

proc m2ps_save {} {
set formattype {{{format files} {*.fmt}}}
set formatname [tk_getSaveFile -filetypes $formattype]
set outhandle [open $formatname w]
foreach {key value index} [.m2ps.bot.t dump 1.0 end] {
  if {$key == "text"} {
    #remove preceding %%
    set value [string range $value 2 end]
    puts -nonewline $outhandle $value}
  }
  close $outhandle
}


proc m2ps_search_keyword {key from_index} {
global fmtcmdlist m2pshelp
global next_index
#puts "search_keyword $key $from_index"
if {$from_index < 0} {set from_index 0}
set size [llength $fmtcmdlist]
for {set i $from_index} {$i < $size} {incr i} {
 set found [string first $key $m2pshelp([lindex $fmtcmdlist $i])]
 if {$found >= 0} {
    #puts $m2pshelp([lindex $fmtcmdlist $i])
   .m2ps.top.left.list selection clear 1 end
   .m2ps.top.left.list selection set $i $i
   .m2ps.top.left.list see $i
    m2ps_show_help $i
   .m2ps.head.search configure -text "search next"
    set next_index $i
    incr next_index
   return;
   }
 }
set next_index 0
.m2ps.head.search configure -text "search"
}



proc setup_m2ps_window {} {
global midi
global df
toplevel .m2ps
position_window ".m2ps"
frame .m2ps.top 
frame .m2ps.bot
frame .m2ps.head
pack .m2ps.head .m2ps.top .m2ps.bot -side top

frame .m2ps.top.left
frame .m2ps.top.right
pack .m2ps.top.left .m2ps.top.right -side left -expand y -fill y

#label $p.s -text "Scope: " -anchor w

set p .m2ps.head
set m2ps_searchword ""
button $p.help -width 5 -text "help" -font $df -command m2ps_show_intro
button $p.search -width 15 -text "search" -padx 0 -pady 1\
-font $df -command m2ps_search_entry
entry $p.ent -width 15 -textvariable m2ps_searchword -font $df
bind .m2ps.head.ent <Return> {
  m2ps_search_entry
  focus .m2ps.head.search
  set next_index 0
  }
bind .m2ps.head.ent <Button> {
  set next_index 1
  .m2ps.head.search configure -text search
   }
tooltip::tooltip .m2ps.head.search "search for keyword in
format statement documentation."

if {$midi(ps_creator) == "abc2svg"} {
   label $p.l -text "abc2svg statements" -width 30 -anchor w -font $df
   } else {
   label $p.l -text "abcm2ps statements" -width 30 -anchor w -font $df
   }
pack $p.l -fill x -expand true -side left
label $p.d -text "Defaults: " -width 20  -anchor w -font $df
pack $p.d -fill x -expand true -side left
pack $p.search $p.ent $p.help -side left

#comboboxes
set p .m2ps.bot.a
frame $p
pack $p -anchor w
set boolvalues {0 1}
set boolvalue <bool>
set fontvalues {Times-Roman Time-Bold Times-BoldItalic Helvetica Helvetica-Bold}
set customvalue ""
ttk::combobox $p.bool -values $boolvalues -textvariable boolvalue -width 20 
ttk::combobox $p.custom -width 30 -textvariable customvalue
bind $p.bool <<ComboboxSelected>> {m2ps_replace_bool_arg; m2ps_append_to_text}
bind $p.custom <<ComboboxSelected>> {m2ps_replace_custom_args}


# controls
set p .m2ps.bot.f
frame $p
pack $p -anchor w 
button $p.remove -text "remove last" -padx 0 -pady 1\
 -font $df -command m2ps_delete_last
button $p.clr -text "clear all" -padx 0 -pady 1\
 -font $df -command m2ps_delete_all
button $p.copy -text "copy to clipboard" -padx 0 -pady 1 \
 -font $df -command m2ps_copy_to_clipboard
button $p.load -text "load file" -padx 0 -pady 1 -font $df -command m2ps_load
button $p.save -text "save to file" -padx 0 -pady 1\
 -font $df -command m2ps_save
entry $p.fmtfile -text midi(ps_fmt_file) -width 35 -font $df
button $p.test -text test -padx 0 -pady 1 \
 -font $df -command m2ps_test_abcm2ps_cfg
pack $p.remove $p.clr $p.copy $p.load $p.save $p.fmtfile  $p.test  -anchor w -side left

text .m2ps.bot.t -height 15 -width 90 -bg lightblue
pack .m2ps.bot.t



#pack $p.s -fill x -expand true -side top

set p .m2ps.top.right
set dfont [font actual df]
set tabspacing [expr {2 * [font measure $dfont 0]}]
text $p.t -height 15 -width 73 -wrap char -yscrollcommand {.m2ps.top.right.ysbar set}
$p.t configure -tabs "$tabspacing left" -tabstyle wordprocessor
scrollbar $p.ysbar -orient vertical -command {.m2ps.top.right.t yview}
pack $p.ysbar -side right -fill y -in $p
pack $p.t -in $p -fill both -expand true
$p.t configure -wrap word
m2ps_show_intro
}

proc prune_formatcmdlist {} {
global formatcmdlist
global fmtcmdlist
global not_in_abc2svg
global not_in_abcm2ps
global midi

set fmtcmdlist {}
foreach elem $formatcmdlist {
  if {$midi(ps_creator) == "abc2svg"} {
    set pos [lsearch $not_in_abc2svg $elem]
    } else {
    set pos [lsearch $not_in_abcm2ps $elem]
    }
  if {$pos == -1} {
    lappend fmtcmdlist $elem
    }
  }
}


proc setup_m2ps_listbox {} {
global fmtcmdlist
prune_formatcmdlist
set f .m2ps.top.left
listbox $f.list -yscrollcommand {.m2ps.top.left.ysbar set} -selectmode single
scrollbar $f.ysbar -orient vertical -command {.m2ps.top.left.list yview}
pack $f.ysbar -side right -fill y -in $f
pack $f.list -fill both -expand y -in $f

set f .m2ps.top.left
foreach elem $fmtcmdlist {
    $f.list insert end $elem
    }

bind $f.list <Button> {m2ps_show_help [.m2ps.top.left.list nearest %y]}

}


proc setup_m2ps {} {
setup_m2ps_window 
setup_m2ps_listbox
}

#setup_m2ps

proc m2ps_configure_boolbox {fmtcmd} {
global m2psdefault
global boolvalue
set boxvalues [list "%%$fmtcmd 0" "%%$fmtcmd 1"]
.m2ps.bot.a.bool configure -values $boxvalues
set boolvalue "%%$fmtcmd $m2psdefault($fmtcmd)"
}

proc m2ps_configure_custombox {fmtcmd} {
global m2pschoices
global m2psdefault
global customvalue
global m2psdefault
set customvalues  "%%$fmtcmd $m2psdefault($fmtcmd)"
set customvalues \{$customvalues\}
foreach choice $m2pschoices($fmtcmd) {
    lappend customvalues "%%$fmtcmd $choice"
    }
.m2ps.bot.a.custom configure -values $customvalues
set customvalue "%%$fmtcmd $m2psdefault($fmtcmd)"
}



proc show_m2ps_comboboxes {fmtcmd} {
global m2psarg
global m2pschoices
global boolvalue intvalue unitvalue floatvalue
foreach p [winfo children .m2ps.bot.a ] {
  pack forget $p
  destroy .m2ps.bot.a.def
  }
if {[info exist m2pschoices($fmtcmd)]} {
  m2ps_configure_custombox $fmtcmd
  pack .m2ps.bot.a.custom -side left -anchor w
  return;
  } 

if {[string first "bool" $m2psarg($fmtcmd)] > 0} {
  m2ps_configure_boolbox $fmtcmd
  pack .m2ps.bot.a.bool -side left -anchor w
  return}
  
if {[string length $m2psarg($fmtcmd)] < 3} {
  button .m2ps.bot.a.def -text "%%$fmtcmd" -pady 1\
   -command { set abcm2ps_entry "%%$fmtcmd"
              m2ps_append_to_text}
  pack .m2ps.bot.a.def -side left -anchor w
  return
  }
button .m2ps.bot.a.def -text "%%$fmtcmd $m2psarg($fmtcmd)" -pady 1\
   -command m2ps_replace_def
pack .m2ps.bot.a.def -side left -anchor w
}

set next_index 0

proc m2ps_search_entry {} {
global m2ps_searchword
global next_index
set keyword $m2ps_searchword
m2ps_search_keyword $keyword $next_index
}

proc m2ps_test_abcm2ps_cfg {} {
global midi
global fileseek
global exec_out
set out_fd [open X.tmp w]
foreach {key value index} [.m2ps.bot.t dump 1.0 end] {
  #puts  "key = $key value = $value"
  if {$key == "text"} {puts -nonewline $out_fd $value}
  }

set sel [title_selected]
set in_fd [open $midi(abc_open) r]
foreach i $sel {
    set loc $fileseek($i)
    seek $in_fd $loc
    gets $in_fd line
    puts $out_fd $line
    while {[string length $line] > 0 } {
      if {$midi(blank_lines)} {
         set line [get_nonblank_line $in_fd]} else {
         set line [get_next_line $in_fd]
         }
      if {[string index $line 0] == "X"} break
      puts $out_fd $line
      }
  }
close $in_fd
close $out_fd

if {![file exist $midi(path_abcm2ps)]} {
       tk_messageBox -message "cannot find $midi(path_abcm2ps)"
	return
	}

set cmd "exec [list $midi(path_abcm2ps)] X.tmp"
catch {eval $cmd} result
set exec_out $cmd\n$result
set cmd "exec [list $midi(path_gv)] Out.ps &"
append exec_out \n$cmd
catch {eval $cmd} result
append exec_out \n$result
}

# end of m2ps.tcl


#source m2psdef.tcl

set not_in_abc2svg {abc2pscompat autoclef decoration micronewps alignbar
EPS format tablature dateformat landscape glyph linewarn pango pdfmark
setdefl tune}

set not_in_abcm2ps {equalbars singleline beamslope sth ambitus soloffs
	diagram grid grid2 begingrid capofont gridfont beginml
	fgcolor printmargin perc temperament clairnote jianpu}


set formatcmdlist { abc2pscompat abcm2ps alignbars aligncomposer ambitus
 annotationfont autoclef barsperstaff beamslope begingrid beginml
 beginps beginsvg begintext bgcolor botmargin
 break breaklimit breakoneoln bstemdown
 cancelkey capo capofont center clef combinevoices composerfont
 composerspace contbarnb continueall custos dateformat
 deco decoration decoerr dblrepbar diagram dynalign dynamic
 EPS equalbars flatbeams font footer footerfont
 format fullsvg gchord gchordbox gchordfont graceslurs
 gracespace graceword grid grid2 gridfont gstemdir glyph header headerfont
 historyfont hyphencont indent infofont infoline infoname
 infospace keywarn landscape leftmargin linebreak
 lineskipfac linewarn maxshrink maxstaffsep maxsysstaffsep
 measurebox measurefirst measurefont measurenb micronewps microscale
 multicol musicfont musiconly musicspace newpage notespacingfactor
 oneperpage ornament ottava pageheight pagewidth pango
 parskipfac partsbox partsfont partsspace pdfmark pos
 postscript ps repbra repeat repeatfont
 rightmargin scale score sep setbarnb
 setdefl setfont-1 setfont-2 setfont-3 setfont-4
 shiftunison singleline slurheight soloffs splittune squarebreve staff
 staffbreak stafflines staffnonote staffscale staffsep
 staffwidth staves stemdir stemheight straightflags
 stretchlast stretchstaff subtitlefont subtitlespace sysstaffsep
 tablature tempofont text textfont textoption
 textspace timewarn titlecaps titlefont titleformat
 titleleft titlespace titletrim topmargin topspace
 transpose tuplets user vocal vocalabove
 vocalfont vocalspace voicecolor voicecombine voicefont voicemap
 voicescale volume vskip wordsfont wordsspace writefields clip
 select tune voice}


array set m2psarg {
abc2pscompat <bool>
abcm2ps {<char> [<char>]*}
alignbars <int>
aligncomposer <int>
ambitus <bool>
annotationfont {<font> [<encoding>] [<size>]} 
autoclef <bool>
barsperstaff <int>
beamslope <float>
begingrid none
beginml none
beginps {["nosvg"]}
beginsvg {}
begintext {[<option>]} 
bgcolor <color>
botmargin <unit>
break []
breaklimit <float>
breakoneoln <bool>
bstemdown <bool> 
cancelkey <bool>
capo <int>
capofont <font>
center {<line of text>}
clef {<clef_name>[<clef_line>][<octave_indication>]}
combinevoices <int>
composerfont {<font> [<encoding>] [<size>]} 
composerspace <unit>
contbarnb <bool>
continueall <bool>
custos <bool>
dateformat <text> 
deco {<name> <c_func> <ps_func> <h> <wl> <wr> [<str>]}
decoration <character> dblrepbar <bar> dynalign <bool> dynamic <int> 
decoerr <bool>
diagram <int>
EPS <eps_file>
equalbars <bool>
flatbeams <bool>
font {<font> [[<encoding>] <scale>]}
footer <text>
footerfont {<font> [<encoding>] [<size>]} 
format <filename>
fullsvg <string>
gchord <int>
gchordbox <bool>
gchordfont {<font> [<encoding>] <size> ["box"]}
graceslurs <bool> 
gracespace {<float> <float> <float>}
graceword <bool>
grid {<int> [nomusic] [norepeat] [include=list]}
grid2 <int>
gridfont <font>
gstemdir <int>
glyph {<unicode> <glyph_name>}
header <text>
headerfont {<font> [<encoding>] [<size>]}
historyfont {<font> [<encoding>] [<size>]} 
hyphencont <bool>
indent <unit>
infofont {<font> [<encoding>] [<size>]}
infoline <bool>
infoname {<uppercase letter> [<information name>]} 
infospace <unit>
keywarn <bool>
landscape <bool>
leftmargin <unit>
linebreak {<list of linebreak separators>} 
lineskipfac <float>
linewarn <bool>
maxshrink <float>
maxstaffsep <unit>
maxsysstaffsep <unit> 
measurebox <bool>
measurefirst <int>
measurefont {<font> [<encoding>] <size> ["box"]}
measurenb <int>
micronewps <bool> 
microscale <int>
multicol <command>
musicfont <string>
musiconly <bool>
musicspace <unit>
newpage {[<int>]}
notespacingfactor <float> 
oneperpage <bool>
ornament <int>
ottava <int>
pageheight <unit>
pagewidth <unit>
pango <bool> 
parskipfac <float>
partsbox <bool>
partsfont {<font> [<encoding>] <size> ["box"]}
partsspace <unit>
pdfmark <int> 
pos {type position}
postscript <text>
ps <text>
repbra <bool>
repeat {[<n> [k]]}
repeatfont {<font> [<encoding>] [<size>]} 
rightmargin <unit>
scale <float>
score <definition>
sep {[<h1> <h2> <len>]}
setbarnb <int> 
setdefl <bool>
setfont-1 {<font> [<encoding>] <size>}
setfont-2 {<font> [<encoding>] <size>}
setfont-3 {<font> [<encoding>] <size>}
setfont-4 {<font> [<encoding>] <size>} 
shiftunison <int>
singleline <bool>
slurheight <float>
soloffs {type=value}
splittune <bool>
squarebreve <bool>
staff {<["+" | "-"] int>} 
staffbreak {[<unit>] ["f"]}
stafflines <int>
staffnonote <bool>
staffscale <float>
staffsep <unit> 
staffwidth <unit>
staves <definition>
stemdir <int>
stemheight <float>
straightflags <bool> 
stretchlast <float>
stretchstaff <bool>
subtitlefont {<font> [<encoding>] [<size>]}
subtitlespace <unit>
sysstaffsep <unit> 
tablature \[#<int>\]\ \[pitch=<pitch>\]\ \[\[<unit-1>\]\ <unit-2>\]\ <unit-3>\ \\
tempofont {<font> [<encoding>] [<size>]}
text <text>
textfont {<font> [<encoding>] [<size>]}
textoption <int> 
textspace <unit>
timewarn <bool>
titlecaps <bool>
titlefont {<font> [<encoding>] [<size>]}
titleformat <text> 
titleleft <bool>
titlespace <unit>
titletrim <bool>
topmargin <unit>
topspace <unit> 
transpose {<int> [ "#" | "b" ]}
tuplets {<int> <int> <int>}
user {<char> [ = ] <decoration>}
vocal <int>
vocalabove <bool> 
vocalfont {<font> [<encoding>] [<size>]}
vocalspace <unit>
voicecolor <color>
voicecombine <int>
voicefont {<font> [<encoding>] [<size>]}
voicemap map_name
voicescale <float>
volume <int> 
vskip <unit>
wordsfont {<font> [<encoding>] [<size>]}
wordsspace <unit>
writefields {<list> <bool>}
clip {\[ <start symbol> \]  \"-\" \[ <end symbol> \]} 
select {\[ <tune index list> \] \[ <regular expression> \]}
tune {\[ <regular expression> \]}
voice {\[ <regular expression> \]}
 }


array set m2psdefault {
abc2pscompat 0
abcm2ps %
alignbars 0
aligncomposer 1
ambitus 0
annotationfont {Helvetica 12} 
autoclef 1
barsperstaff 0
beamslope 0.4
begingrid none
beginml none
beginps none
beginsvg none
begintext none 
bgcolor none
botmargin 1cm
break none
breaklimit 0.7
breakoneoln 1
bstemdown 0 
cancelkey 0
capo 0
capofont {sans-serif 12}
center none
clef none
combinevoices 0
composerfont {Times-Italic 14} 
composerspace 0.2cm
contbarnb 0
continueall 0
custos 0
dateformat {"%b %e, %Y %H:%M"} 
deco none
decoration !
decoerr 1
dblrepbar {:][:}
diagram 0
dynalign 1
dynamic 0 
EPS 0
equalbars none
flatbeams 0
font none
footer none
footerfont {Times-Roman 12} 
format none
fullsvg none
gchord 0
gchordbox 0
gchordfont {Helvetica 12}
graceslurs 1 
gracespace {6.5 8.0 12.0}
graceword 0
grid none
grid2 0
gridfont {serif 16}
gstemdir 0
glyph none
header none
headerfont {Times-Roman 12}
historyfont {Times-Roman 16} 
hyphencont 1
indent 0
infofont {Times-Italic 14}
infoline 0
infoname {} 
infospace 0
keywarn 1
landscape 0
leftmargin 1.8cm
linebreak <EOL> 
lineskipfac 1.1
linewarn 1
maxshrink 0.65
maxstaffsep 2000pt
maxsysstaffsep 2000pt 
measurebox 0
measurefirst 1
measurefont {Times-Italic 14}
measurenb -1
micronewps 0 
microscale none
multicol 0
musicfont none
musiconly 0
musicspace 0.2cm
newpage none
notespacingfactor 1.414 
oneperpage 0
ornament 0
ottava none
pageheight PAGEHEIGHT
pagewidth PAGEWIDTH
pango 1 
parskipfac 0.4
partsbox 0
partsfont {Times-Roman 15}
partsspace 0.3cm
pdfmark 0 
pos auto
postscript none
ps none
repbra 1
repeat none
repeatfont {Times-Roman 13} 
rightmargin 1.8cm
scale 0.75
score none
sep none
setbarnb none 
setdefl 0
setfont-1 {Times-Roman 0}
setfont-2 {Times-Roman 0}
setfont-3 {Times-Roman 0}
setfont-4 {Times-Roman 0} 
shiftunison 0
singleline 0
slurheight 1.0
soloffs {part=0 space=0}
splittune 0
squarebreve 0
staff none 
staffbreak none
stafflines 5
staffnonote 1
staffscale 1
staffsep 46pt 
staffwidth none
staves none
stemdir 0
stemheight 20.0
straightflags 0 
stretchlast 0.8
stretchstaff 1
subtitlefont {Times-Roman 16}
subtitlespace 0.1cm
sysstaffsep 36pt 
tablature none
tempofont {Times-Bold 15}
text none
textfont {Times-Roman 16}
textoption {0 (obeylines)} 
textspace 0.5cm
timewarn 0
titlecaps 0
titlefont {Times-Roman 20}
titleformat none 
titleleft 0
titlespace 0.2cm
titletrim 1
topmargin 1cm
topspace 0.8cm 
transpose 0
tuplets {0 0 0}
user none
vocal 0 
vocalabove 0 
vocalfont {Times-Bold 13} 
vocalspace 23pt
voicecolor #000000
voicecombine 0
voicefont {Times-Bold 13}
voicemap none
voicescale 1
volume 0 
vskip {Times-Roman 16}
wordsfont {Times-Roman 16}
wordsspace 0cm
writefields {COPQTWw 1}
clip {} 
select {}
tune {}
voice {}
 }


array set m2pschoices {
alignbars {1 2 3 4 5 6 7 8}
aligncomposer {-1 0 1}
annotationfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } 
barsperstaff {1 2 3 4 5 6 7 8}    
beamslope {0.1 0.2 0.3 0.4 0.5 0.6}
bgcolor {white yellow pink \#faf0e6}
botmargin {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}
breaklimit {0.5 0.6 0.7 0.8 0.9 1.0}   
capo {1 2 3 4 5 6}
combinevoices {-1 0 1 2}
composerfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } 
composerspace {0.0cm 0.2cm 0.4cm 0.6cm 0.8cm 1.0cm}
dateformat {"%F" "%D" "%A %F"} 
decoration {"!" "+"}
dblrepbar {"::" ":|:" ":||:"}
dynamic {0 1 2 3 4} 
footerfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } 
gchord {0 1 2 3}    
gracespace {{8.0 8.0 10.0} {4.0 8.0 6.0}}
gstemdir {0 1 2}
headerfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } historyfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } 
indent {0.5cm 1.0cm 1.5cm 2.0cm 3.0cm} infofont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }   
infospace {0.5cm 1.0cm 1.5cm 2.0cm 3.0cm}
leftmargin {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}  
lineskipfac {0.2 0.4 0.6 0.8 1.0}
maxshrink {0.2 0.4 0.6 0.8 1.0}   
measurefont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
measurenb {0 2 4 -1}  
musicspace {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}
notespacingfactor {1.0 1.2 1.4 1.6 1.8 2.0} 
ornament {0 1 2 3}    
parskipfac {0.2 0.4 0.6 0.8 1.0}  partsfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
partsspace {0.5cm 1.0cm 1.5cm 2.0cm 3.0cm}  
repeatfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" } 
rightmargin {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}
scale {0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2}    
shiftunison {0 1 2 3}
slurheight {0.8 0.9 1.1 1.2}    
soloffs {"part=-20 space=0" "part=-15 space=0"}
staffscale {0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2}
staffsep {1.4cm 1.5cm 1.6cm 1.7cm} 
staffwidth {15.0cm 16.0cm 17.0cm 18.0cm 19.0cm}
stemdir {0 1 2}
stemheight {17.0 19.0 21.0 23.0}  
stretchlast {0.2 0.4 0.6 0.8 1.0}
subtitlefont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
subtitlespace {0.2cm 0.3cm 0.4cm}
sysstaffsep {1.0 1.2 1.4 1.6 1.8 2.0} 
tempofont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
textfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
textoption {obeylines justify fill center skip right} 
textspace {0.2cm 0.3cm 0.4cm}
titlefont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }  
titlespace {0.2cm 0.3cm 0.4cm}
topmargin {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}
topspace {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm} 
vocalspace {0.0cm 1.0cm 2.0cm 3.0cm 4.0cm 5.0cm}
voicecolor {#0000c0 #c00000 #00c000 #00b0b0}
voicecombine {0 1 2 3}
voicefont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }
voicescale {0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2}
volume {0 1 2 3} 
wordsfont {"Times-Roman 12" "Time-Bold 12" "Times-Roman 14" "Times-Bold 14" "Times-Italic 12" "Times-BoldItalic 12" "Helvetica 10" "Helvetica-Bold 10" "Helvetica-Oblique" "Courier" "Platino" "Platino-Bold" }    
   }


set m2pshelp(abc2pscompat)  {		Handle old abc2ps tunes.
		When set, 'M' becomes the !tenuto! decoration and a pitch
		translation may be done for the bass and alto clefs
		(respectively, 2 and 1 octaves down).
		It is preferable to rewrite the old tunes to comply with
		the current standard rather than using this parameter.
		For example, you could include in the tune,
			U: M = !tenuto!
		and/or:
			K:C clef=bass octave=-2
		and the old tune would be interpreted correctly.
}

set m2pshelp(abcm2ps)  {		Change the pseudo-comment prefix(es).
		By default, pseudo-comments are lines starting with two percent
		signs ("%%"). This command redefines a list of possible second
		characters of these commands (up to 3 different characters).
		This permits to avoid conflicts with pseudo-comments of other
		programs and also to have a simple conditional generation.
		Example 1:
			%%abcm2ps *
			%*voice Mib	% the voices which name contains "Mib"
			%*transpose -3	% are transposed a minor third lower
			%*voice end
			%*abcm2ps %	% restore standard pseudo-comments
		Example 2:
		   - tune.abc:
			X:1
			...
			K:C
			%			% default 4 staves
			%Fstaves [(S A) (T B)]	% 2 staves
			%Sstaves S		% Soprano only
			%Astaves A		% Alto only
			V:S
			...
			V:A
			...
			V:T
			...
			V:B
			...
		   - command line:
			abcm2ps --abcm2ps %A tune.abc	# generate alto only
}

set m2pshelp(alignbars)  {		Align the bars of the next <int> music lines.
		Such an alignment works only when there is only one
		voice (i.e. no V:, %%staves or %%score are permitted).
}

set m2pshelp(aligncomposer)  {		This parameter specifies where the composer field
		is displayed.
		A negative value means 'on the left', 0 means 'center',
		and a positive value means 'on the right'.
}

set m2pshelp(ambitus)   {		Adds an ambitus at the start of the first musicline.
}

set m2pshelp(annotationfont)  {		Set the annotation font.
}

set m2pshelp(autoclef)  {		When this parameter is false, the voices which don't contain
		a 'clef=' in K: or V: use the treble clef, according to the
		ABC standard.
		When true, the clefs and possibly the clef changes for these
		voices are determined from the note pitches and inserted
		automatically.
}

set m2pshelp(barsperstaff)  {		Try to typeset with <int> bars on each line.
}

set m2pshelp(beamslope)  {		Set the maximum slope of beams (on
	  normal and gracenotes).
	  The value 0 sets flat beams.
  }

set m2pshelp(begingrid) { This command inserts a grid of chords for improvisation.

Each line in the source defines a line in the grid.

The cells in the grid are separated by measure bars, |, |: or :|.

A cell may contain one to four blank separated chords. The
special name - indicates the chord continues on this beat.
}

set m2pshelp(beginml) {This command introduces a Markup Language sequence that ends
with %%endml and which will be included in the output.
}

set m2pshelp(beginps)  {		This command introduces a PostScript sequence that
		ends with '%%endps' and which will be included in the
		PostScript output file.
		Such a sequence cannot be greater than 128 Kb.
		When the output file format is SVG (command options '-g',
		'-v' or '-X'), the PostScript code is executed by the
		small abcm2ps PS interpreter. Sequences which cannot
		be executed (as font redefinitions) must be skipped
		checking the presence of the symbol 'svg':
		/svg where {pop} {
		.. PostScript code which cannot be executed by abcm2ps ..
		} ifelse
		When the option "nosvg" is present, the sequence is not
		executed on SVG output.
}

set m2pshelp(beginsvg)  {		This command introduces a SVG sequence that ends with
		'%%endsvg' and which will be included in the SVG output file.
		It allows adding a CSS to the generated SVG files.
		The sequence is ignored when the SVG output file has begun
		to be written (for example if it is found after the first
		K: information field).
}

set m2pshelp(begintext)  {		Start printing the free text of the followng lines up to
		%%endtext.
		When a line of text starts with '%%', these characters are
		removed.
		When a sequence %%begintext .. %%endtext appears inside a
		tune, blank lines must be replaced with '%%' to prevent
		them from being confused with the end of the tune marker.
		<option> may be:
		    'obeylines':	  keep lines as they are (default)
		    'align' or 'justify': justify the lines
		    'ragged' or 'fill':	  fill the lines
		    'center':		  center the lines
		    'skip':		  don't print the lines
							(same as comments)
		    'right':		  align at the right side
		When <option> is omitted, it defaults to the %%textoption
		value.
		Inside the free text, an empty line starts a new paragraph.
		Page breaks (start of new pages) cannot occur in the middle
		of a paragraph.
}

set m2pshelp(bgcolor)  {		This parameter defines the background color of SVG images.
		It is applicable only with pure SVG output (options '-g'
		and '-v').
		The <color> may be a color name (like 'white') or
		a hexadecimal RGB color (like '#faf0e6').
}

set m2pshelp(botmargin)  {		Set the page bottom margin.
}

set m2pshelp(break)  {			Insert a music line after the selected symbol(s).
		  This command may appear one or more times, but only in
	     the tune header.
}

set m2pshelp(breaklimit)  {		This parameter is used with 'maxshrink' to adjust the
		place where automatic music line breaks may occur.
		To know how many music symbols will be in a music line,
		the width of each symbol is computed by:
			width = minimal_space * 'maxshrink'
				+ natural_space * (1 - 'maxshrink')
		When the sum of all the symbol widths is greater than
			(paper width - margins) * 'breaklimit'
		and smaller than (paper width - margins), a line break
		may occur.
		The value <float> is limited between 0.5 (line breaks may
		occur when the line is 50% full) and 1 (the music line is
		split at the exact computed symbol).
}

set m2pshelp(breakoneoln)  {		When set, a space (beam break) is inserted after each end of
		(ABC source) line.
		This prevents a beam from being continued between two music
		lines.
		(don't confuse this parameter with %%continueall or
		%%linebreak)
}

set m2pshelp(bstemdown)  {		When set, the stem of the note in the middle of the
		staff goes downwards. Otherwise, it goes upwards
		or downwards according to either the previous or
		following note.
}

set m2pshelp(cancelkey)  {		When set, the accidentals associated with the last key
		signature are cancelled using naturals prior to
		introducing the new key signature.
}

set m2pshelp(capo)  {		This command is used to redefine the chord symbols
		when a guitar player uses a capo.
		int is the fret number on which the capo is put.

}

set m2pshelp(capofont) {Sets font for capo.}

set m2pshelp(center)  {		Print one line of centered text.
}

set m2pshelp(clef)  {		Insert a clef change.
		<clef_name> may be:
			treble (same as G2)
			alto (same as C3)
			tenor (same as C4)
			bass (same as F4)
			perc (same as P2)
			G
			C
			F
			P
			none (to avoid clefs on the next music lines)
			"<user_clef_name>" (<user_clef_name> is the name of
				a PostScript function which  draws the clef
				glyph)
		<clef_line> gives the number of the line on which the note of
		the clef is defined. When omitted, it defaults according to
		the clef name: line #3 for "C", line #4 for "F" and line #2
		for the other clefs.
		<octave_indication> is either
		- "+8" or "-8", in which case a '8' is drawn above or below
		  the clef without octave transposition.
		- "^8" or "_8", in which case a '8' is drawn above or below
		  the clef with octave transposition.
		There should be no space in the %%clef value.
		Example:
			%%clef bass	% same as K: clef=bass
}

set m2pshelp(combinevoices)  {		Define how notes of different voices in a same staff
		may be combined.
		<int> may be:
			- < 0: the voices are displayed as written
			- 0: the rests of same duration are displayed
				as one rest
			- 1: the notes of same duration are combined
				to chords except when there could be
				a second, a unison or a voice inversion
			- > 1: the notes of same duration are always combined
				to chords
}

set m2pshelp(composerfont)  {		Set the composer font.
}

set m2pshelp(composerspace)  {		Set the vertical space above the composer.
}

set m2pshelp(contbarnb)  {		If not set, the bar number of the second repeat(s) is reset to
		the number of the first repeat.
		If set, the bars are sequentially numbered.
}

set m2pshelp(continueall)  {		When true, all line breaks of the tune are ignored.
		This parameter is deprecated in favour of '%%linebreak <none>'.
}

set m2pshelp(custos)  {		When set, a custos is added at the end of each music line.
		This parameter works with single voice tunes only.
}

set m2pshelp(dateformat)  {		Define the format of the date and time.
		The possible values of this parameter are described in the
		manual pages of date(1) and strftime(3).
		Note: the '%'s must be escaped as '\%' if the is not enclosed
		in double quotes (otherwise it is taken as the start of a
		comment).
}

set m2pshelp(deco)  {		Define a decoration.
		This command assumes a good knowledge of the abcm2ps internals.
		The arguments are:
		<name>: name of the decoration. If it is the name of an
			existing decoration, this one is redefined.
		<c_func>: index of a C function (defined in deco.c).
			The possible values are:
			0, 1, 2: the decoration goes near the note, possibly
					inside the staff.
				0: 'dot' and 'tenuto'
				1: 'slide'
				2: 'arpeggio'
			3, 4, 5: the decoration goes near the note but outside
					the staff. It is usually printed above
					the staff.
				3: general
				4: below the staff
				5: long 'trill' (with start and stop)
			6, 7: the decoration is tied to the staff (dynamic
					marks). It is generally printed below
					the staff.
				6: general
				7: long dynamic (with start and stop)
		<ps_func>: postscript function name or '-' for the start
			of a long decoration.
		<h>: decoration height.
			It is the minimum height for +arpeggio+.
		<wl> and <wr>: left and right widths.
			These values are actually used for general dynamic
			marks only.
		<str>: text to display (for some postscript functions
			- see code).
		The decorations, which names begin with 'head-', prevent the
		note head(s) to be drawn.
		See deco.abc for examples.
}

set m2pshelp(decoration)  {		Define the decoration separator.
		It may be set only to '!' (default) or '+' (for compatibility
		with the ABC standard 2.0).
}

set m2pshelp(decoerr) {Raise an error when a decoration is not defined.}

set m2pshelp(dblrepbar)  {		Define how the double repeat bars (::, :|: :||:) are drawn.
}

set m2pshelp(diagram)  {		When set, this command adds chord diagrams under
   	 the chord symbols.  Actually, the diagrams are only
    	those of the guitar (6 strings EADGBE).
}

set m2pshelp(dynalign)  {		When true, the dynamic marks are horizontally aligned.
}

set m2pshelp(dynamic)  {		Set the position of the dynamic informations (crescendo,
		diminuendo..).
		<int> may be:
			0 or 'auto' for automatic position (it depends on
				the presence and position of lyrics)
			1 or 'above' above the staff
			2 or 'below' below the staff
			3 or 'hidden' don't print
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When it appears inside
		a tune body, it applies to the current voice only.
}

set m2pshelp(EPS)  {		Include the file <eps_file> (Encapsulated PostScript).
		The file content is left or right aligned, or centered
		according to the current value of '%%textoption'.
}

set m2pshelp(equalbars) {		This command changes the rendering so
	  that, the measures have a width proportional
	  to their duration.
}


set m2pshelp(flatbeams)  {		Draw flat beams.
}

set m2pshelp(font)  {		Define a font and its encoding.
		This parameter is required with PostScript output when
		specific fonts are defined later in ABC files/tunes.
		<scale> is the width factor to apply to the Time-Roman
		character width. It is needed to adjust the string width
		when the computation using the default scale gives
		erroneous values:
			- if the strings collide with other elements,
			  set <scale> to a value lower than 1.0.
			- if there is too much space between elements
			  because of the strings, set it to a value
			  greater than 1.0.
		Note that the <scale> is not applied immediately: it will
		used only in further font assignment.
}

set m2pshelp(footer)  {		Specify the text to be printed at the bottom of each page.
		There may be one or two lines in the footer.
		To specify 2 lines, put the 2 characters "\n" (not
		a real 'newline') as a separator in the command.
		In each line, 3 areas may be defined: left, center and
		right.
		These areas are separated by tabulations (real TABs,
		not "\t") and may be empty (if the left area is empty,
		double quote the string - see sample3.abc for example).
		The prefix '$' introduces variable substitution:
			- '$d' is the date and time of the last modification
			   of the current ABC input file,
			- '$D' is the current date and time,
			- '$F' is the current input file name,
			- '$Ix' is any header information type ('x' is a
			   letter range 'A' to 'Z').
			- '$P' is the current page number,
			- '$P0' and '$P1' are also the page number, but apply
			   only to the even ('0') or odd ('1') page numbers,
			- '$T' is the current tune title,
			- '$V' is 'abcm2ps-' followed by the program version.
		For example, the command line option '-N3' is the same
		as:
			%%header "$P0		$P1"
		(note the 2 TABs).
		If the footer (or header) begins with '-' (hyphen/minus),
		it is not printed on the first page.
}

set m2pshelp(footerfont)  {		Set the footer font.
		Note that the footer is not scaled.
}

set m2pshelp(format)  {		Load the format (or PostScript) file <filename>.
		When found in the command line, this parameter is
		equivalent to '-F'.
}

set m2pshelp(fullsvg) {Include all the styles in each SVG image.

When this parameter is not set, the SVG styles are defined only once,
then, the images cannot be easily extracted and displayed in some other
context.

When this parameter is set, each image may be extracted and copied to an other context.
To avoid inheritance problems, the string is added to the font class names
and makes them unique.

%%fullsvg may appear only in a global definition (outside the tunes).
}

set m2pshelp(gchord)  {		Set the position of the guitar chords.
		<int> may be:
			0 or 'auto' for automatic position (usually
				above the staff)
			1 or 'above' above the staff
			2 or 'below' below the staff
			3 or 'hidden' don't print
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When inside a tune body,
		it applies to the current voice only.
}

set m2pshelp(gchordbox)  {		Draw a box around the guitar chords.
		This value may be set to 'true' by the option "box"
		in %%gchordfont.
}

set m2pshelp(gchordfont)  {		Set the guitar chord font.
		If "box" is present, a box is drawn around the guitar chords.
}

set m2pshelp(graceslurs)  {		Draw slurs on grace notes.
}

set m2pshelp(gracespace)  {		Define the space before, inside and after the grace notes.
}

set m2pshelp(graceword)  {		When set and when a note with a lyric 
  	  word (in w:) is preceeded by grace notes, the
	  word is shifted to the starting grace note.
}

set m2pshelp(grid)  {		%%grid adds a chord grid of the tunes.

	  The int value is the number of columns. When '1' or '-1',
	  this number is computed.
	  When this value is negative, the grid is under the music.

	  nomusic displays the grid only.

	  norepeat removes the ':' (repeat indications) from the grid.

	  repbrk starts a new grid line on a start or stop of repeat.

	  include= defines which measures are used to define the grid.
	  list is a comma separated list of measure numbers (the measure
	  numbers are the ones displayed with %%contbarnb 1).
}

set m2pshelp(grid2)  {		This command replaces the music of a voice by a chord grid.

}

set m2pshelp(gridfont) {Sets the grid font.}


set m2pshelp(gstemdir)  {		Set the direction of the stems of the grace notes.
		<int> may be:
			0 or 'auto' for automatic position
			1 or 'up' stem up
			2 or 'down' stem down
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When inside a tune body,
		it applies to the current voice only.
}

set m2pshelp(glyph) {Set the name of a unicode glyph.

This command is useful only for PostScript output without pango support.

unicode is a hexadecimal value, and glyph_name is the name of the
associated glyph in the font files.
}

set m2pshelp(header)  {		Set the text printed at the top of each page.
		See 'footer' above for the header syntax.
}

set m2pshelp(headerfont)  {		Set the header font.
		Note that the header is not scaled by %%scale.
}

set m2pshelp(historyfont)  {		Set the history font.
}

set m2pshelp(hyphencont)  {		If set, when a word of lyric under staff ends with a hyphen,
		put a hyphen in the next line.
}

set m2pshelp(indent)  {		Indent the first line of the tune by <unit>.
}

set m2pshelp(infofont)  {		Set the infoline font.
}

set m2pshelp(infoline)  {		Display the rhythm (R:) and area (A:) on a same line
		before the first music line:
			Rhythm (Area)
}

set m2pshelp(infoname)  {		Define the name of the information fields which may be
		printed after the tunes.
		Note: For being printed, a field must be set to 'on' in a
		%%writefields parameter and have an information name.
		When <information name> is not present, the field name is
		removed. This is usefull to change the field order.
		Examples:
		%%infoname G "Group: "	% display the group
		%%writefields G 1
		%%infoname N		% notes after the other fields
		%%infoname N "Notes: "
}

set m2pshelp(infospace)  {		Set the vertical space above the infoline.
}

set m2pshelp(keywarn)  {		When set, if a key signature change occurs at the
		beginning of a music line, a cautionary key signature
		is added at the end of the previous line.
}

set m2pshelp(landscape)  {		Set the page orientation to landscape.
}

set m2pshelp(leftmargin)  {		Set the page left margin.
}

set m2pshelp(linebreak)  {		Define the character(s) which break(s) the music lines.
		The <list of linebreak separators> is a blank separated
		list of none, one or more of:
			<EOL> (End Of Line of any system)
			$
			!
			<none>
		For compatibility, when <EOL> is in the list, the character
		'!' does a linebreak if it does not introduce a decoration.
		If the value '<none>' occurs alone or if the list is empty,
		the program computes the linebreaks automatically. This
		replaces the deprecated '%%continueall 1'.
}

set m2pshelp(lineskipfac)  {		Set the factor for spacing between lines of text.
}

set m2pshelp(linewarn)  {		When set, raise a warning when there are too few or
		too many elements in a music line.
}

set m2pshelp(maxshrink)  {		Set how much to compress horizontally when music line breaks
		are automatic.
		<float> must be between 0 (natural spacing)
		and 1 (max shrinking).
}

set m2pshelp(maxstaffsep)  {		Set the maximum staff system separation.
}

set m2pshelp(maxsysstaffsep)  {		Set the maximum staves separation inside a system.
		This values applies to all staves when global or in
		the tune header. Otherwise, it defines the maximum
		vertical offset of the next staff.
}

set m2pshelp(measurebox)  {		Draw a box around the measure numbers.
		This value may be set to 'true' by the option "box"
		in %%measurefont.
}

set m2pshelp(measurefirst)  {		Start numbering the measures of the tune from <int>.
		This parameter is obsolete and should be replaced by
		'%%setbarnb' in the tune header.
}

set m2pshelp(measurefont)  {		Set the measure font.
		If "box" is present, a box is drawn around the measure
		numbers.
}

set m2pshelp(measurenb)  {		If positive, draw the measure number every <int> bars.
		If <int> = 0, the measure number appears only on the
		left of the staff systems.
		On the command line only, if a trailing 'b' is present,
		a box is also drawn around the measure numbers.
}

set m2pshelp(micronewps)  {		If set, use the new PostScript function to draw the microtonal
		accidentals.
		(see "Microtone" in features.txt for more information)
}

set m2pshelp(microscale)  {		Define the tone fraction (denominator) to use for microtone
		accidental definitions.
		This denominator must be even.
}

set m2pshelp(multicol)  {		Define multicolumn printing.
		<command> may be:
		    'start':	save the current vertical position and the
				left and right margins. Then, these margins
				may be changed to print music or text.
		    'new':	reset the vertical offset at the place of
				the previous '%%multicol start', and restore
				the left and right margins.
		    'end':	restore the left and right margins, and skip
				down to a safe place.
		(see 'sample3.abc' for an example).
		This command may also be used to group some tunes and text in
		a same page.
}

set m2pshelp(musicfont) {Define an alternate music font.

By default, abcm2ps uses PostScript definitions of the music glyphs,
and abc2svg uses an internal music font.

This command permits to use an other font for the music.
}

set m2pshelp(musiconly)  {		If true, don't output the lyrics under staff.
}

set m2pshelp(musicspace)  {		Set the vertical space above the first staff.
}

set m2pshelp(newpage)  {		Continue printing on a new page and optionally restart page
		numbering from <int>.
}

set m2pshelp(notespacingfactor)  {		Set the note spacing factor to <float> (range 1..2).
		This value is used to compute the natural spacing of
		the notes. The base spacing of the crotchet is always
		40 pts. When the duration of a note type is twice the
		duration of an other note type, its spacing is multiplied
		by this factor.
		The default value causes the note spacing to be multiplied
		by 2 when its duration is multiplied by 4, i.e. the
		space of the semibreve is 80 pts and the space of the
		semiquaver is 20 pts.
		Setting this value to 1 sets all note spacing to 40 pts.
}

set m2pshelp(oneperpage)  {		Output one tune per page.
}

set m2pshelp(ornament)  {		Set the position of the ornaments (mordent, trill..).
		<int> may be:
			0 or 'auto' for automatic positioning (usually above
				the staff)
			1 or 'above' above the staff
			2 or 'below' below the staff
			3 or 'hidden' don't print
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When it is inside a tune
		body, it applies to the current voice only.
}

set m2pshelp(ottava) {Start / stop ottava sequences.

int may be

2:	quindicessima alta
1:	ottava alta
0:	stop the ottava/quindicessima sequence
-1:	ottava bassa
-2:	quindicessima bassa
When there are many voices on a staff, the ottava sequences apply to all voices.

For ottava, the commands may be replaced by the decorations !8va(! .. !8va)! and !8vb(! .. !8vb)! which exist in abcm2ps (but apply to one voice only).
}


set m2pshelp(pageheight)  {		Set the page height.
}

set m2pshelp(pagewidth)  {		Set the page width.
}

set m2pshelp(pango)  {		When abcm2ps is compiled with pango/freetype support,
		enable or disable the text generation with pango glyphs.
		Trick: This parameter may be set to '2' to force pango
		generation of texts which contain only ASCII and latin1
		characters.
}

set m2pshelp(parskipfac)  {		Set the factor for spacing between text paragraphs.
}

set m2pshelp(partsbox)  {		Draw a box around the part names.
		This value may be set to 'true' by the option "box"
		in %%partsfont.
}

set m2pshelp(partsfont)  {		Set the part font.
		If "box" is present, a box is drawn around the part names.
}

set m2pshelp(partsspace)  {		Set the vertical space above a new part.
}

set m2pshelp(pdfmark)  {		When set to a non null value, the PostScript output file
		contains marks which may be used by the PS to PDF translators
		to create a PDF index of the tunes.
		If <int> is greater than 1, generate pdfmarks for titles and
		subtitles, otherwise, if <int> is 1, generate pdfmarks
		for the main titles only.
}

set m2pshelp(pos) {Set the direction or vertical position of some music elements.

The type may be:
dynamic for dynamic decorations (crescendo, diminuendo..)
gchord for chord information
gstem for stem direction of grace notes
ornament for ornament decorations (mordent, trill..)
stem for stem direction
vocal for the words under the staff
volume for the volume decorations (!p!, !fff!...)
It may be abbreviated.

The position may be:
auto for automatic position
above or up above the staff
below or down below the staff
hidden don't print or opposite stem opposite direction for gstem
When this parameter appears outside a tune or inside a tune header, it applies to all voices.
When it appears inside a tune body, it applies to the current voice only.
}


set m2pshelp(postscript)  {		Define a line to be included in the PostScript output
		file.
		This parameter may be used to override any PostScript
		function or to define new functions for use in a 'deco'
		format.
		See 'beginps' above.
}

set m2pshelp(ps)  {		Define a line to be included in the PostScript output
		file.
		This parameter may be used to override any PostScript
		function or to define new functions for use in a 'deco'
		format.
		See 'beginps' above.
}

set m2pshelp(repbra)  {		The repeat brackets are normally displayed as they are found
		in a voice. %%repbra 0' prevents displaying them for the
		current voice.
}

set m2pshelp(repeat)  {		Try to replace a sequence by one or many repeat signs.
		When placed after a bar, <n> indicates the number of measures
		to be repeated (it may be only one or two). <k> indicates how
		many times the previous measure is to be repeated.
		When placed after a note or rest, <n> indicates the number of
		notes and rests to be repeated, and <k> how many times this
		repetition occurs.
		When omitted, <n> and <k> default to 1.
		No check is done on the equality of the sequences.
		See 'sample5.abc' for examples.
}

set m2pshelp(repeatfont)  {		Set the repeat number/text font.
}

set m2pshelp(rightmargin)  {		Set the page right margin.
}

set m2pshelp(scale)  {		Set the page scale factor.
		Note that the header and footer are not scaled.
}

set m2pshelp(score)  {		Controls the layout of multivoiced tunes.
		See the ABC standard version 2.1 for description.
}

set m2pshelp(sep)  {		Print a separator (centered line) of length <len> with
		space <h1> above and space <h2> below
		(defaults: h1 = h2 = 0.5cm,len = 3.0cm).
}

set m2pshelp(setbarnb)  {		Set the number of the next measure.
		When this command appears at the beginning of the tune
		(after K:), only the 2nd measure will have the new number.
		It must appear in the tune header to set the first measure.
}

set m2pshelp(setdefl)  {		When true, output some indications about the note, chord
		and/or decorations for customization purpose. These
		indications are stored in the PostScript variable 'defl'.
}

set m2pshelp(setfont-1)  {		Set the alternate fonts for strings.
		In most strings, the current font may be changed
		by "$n" (n = 0, 1 .. 4 - "$0" resets the font to
		its default value).
		Note: <size> is mandatory at the first definition.
}

set m2pshelp(setfont-2)  {		Set the alternate fonts for strings.
		In most strings, the current font may be changed
		by "$n" (n = 0, 1 .. 4 - "$0" resets the font to
		its default value).
		Note: <size> is mandatory at the first definition.
}

set m2pshelp(setfont-3)  {		Set the alternate fonts for strings.
		In most strings, the current font may be changed
		by "$n" (n = 0, 1 .. 4 - "$0" resets the font to
		its default value).
		Note: <size> is mandatory at the first definition.
}

set m2pshelp(setfont-4)  {		Set the alternate fonts for strings.
		In most strings, the current font may be changed
		by "$n" (n = 0, 1 .. 4 - "$0" resets the font to
		its default value).
		Note: <size> is mandatory at the first definition.
}

set m2pshelp(shiftunison)  {		Set the way voice unison is displayed.
		<int> may be:
		'0': for one note head if possible
		'1': for two shifted notes when one note is dotted
		     and the other one is not,
		'2': also for two shifted notes when one note is a
		     minim (half note) and the other one has some flags,
		'3': for two shifted notes on all unison cases.
}

set m2pshelp(singleline)  {		Output a single music line.
}

set m2pshelp(slurheight)  {		Set the slur height factor.
}

set m2pshelp(soloffs) {		This command permits to change the horizontal offset
       	  of some music type elements that are found at the start of music lines.

	  type is one of part, tempo or space.

	  value is the new X offset from the start of the staff in
	  pixels. Its value may be negative.

 	  eg.
	  %%soloffs part=-10 space=0
}

set m2pshelp(splittune)  {		If false, a tune starts on a new page when it does not
		fit in the current one. If true, there is no page
		check, and the tune may be splitted.
}

set m2pshelp(squarebreve)  {		Display the breve notes in square format.
}

set m2pshelp(staff)  {		Put the next symbols of the current voice on the staff <int>
		(1..n - see sample4.abc for example), or on the <+int>th or
		<-int>th staff.
}

set m2pshelp(staffbreak)  {		Set a break in the current staff.
		<unit> gives the width of the break (in points, inches or cm)
		and defaults to 0.5 cm.
		As a side effect, when the width exceeds 0.5 cm and when all
		the voices have the same staffbreak, the left side of the
		staff system is redrawn.
		When "f" is not present, the staff break is removed if it
		occurs at the start or end of the music line.
}

set m2pshelp(stafflines)  {		Set the number of lines of the staff of the current voice.
}

set m2pshelp(staffnonote)  {		If not set, do not display the staves which have no notes
		in the music lines.
}

set m2pshelp(staffscale)  {		Set the scale of the staff of the current voice.
}

set m2pshelp(staffsep)  {		Do not put a staff system closer than <unit> from the
		previous system.
}

set m2pshelp(staffwidth)  {		Adjust the page right margin so that the staff width
		is <unit>.
}

set m2pshelp(staves)  {		This command is deprecated. Use %%score instead.
		See 'features.txt' for description.
}

set m2pshelp(stemdir)  {		Set the direction of the stems.
		<int> may be:
			0 or 'auto' for automatic positioning
			1 or 'up' stem up
			2 or 'down' stem down
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When inside a tune body,
		it applies to the current voice only.
		This parameter may also be set using the parameter 'stem='
		in the K: and V: information fields.
}

set m2pshelp(stemheight)  {		Set the stem height.
}

set m2pshelp(straightflags)  {		Have straight flags on the stems for bagpipe tunes.
}

set m2pshelp(stretchlast)  {		Stretch the last music line of a tune when it exceeds
		the <float> fraction of the page width.
		<float> range is 0.0 to 1.0.
}

set m2pshelp(stretchstaff)  {		Stretch underfull music lines inside a tune.
}

set m2pshelp(subtitlefont)  {		Set the subtitle font.
}

set m2pshelp(subtitlespace)  {		Set the vertical space above the subtitle.
}

set m2pshelp(sysstaffsep)  {		Do not place the staves closer than <unit> inside a system.
		This values applies to all staves when global or in
		the tune header. Otherwise, it defines the minimum
		vertical offset of the next staff.
}

set m2pshelp(tablature)  {		Define a tablature for the current voice.
		<int> gives the tablature number (from 1 to 8, default=1).
		<pitch> is the pitch of the instrument. It looks like a
			normal ABC note. When present, the pitch of each
			note is given as argument to the note function.
			When absent, the information about the note(s)
			is given by one or many lyrics (w:).
		<unit-1> specifies the width of the header (left side of
			the music line).
		<unit-2> specifies the tablature height above the staff.
		<unit-3> specifies the tablature height under the staff.
		<head-func> is the PostScript function called at start
			of a new music line.
		<note-func> is the PostScript function called at each note.
		<bar-func> is the PostScript function called at each bar.
		The arguments of the PostScript functions depend on the
		presence of the pitch.
		When the pitch is absent, the stack contains:
			- head function:
				- the music line width,
				- the x and y offsets,
				- the number of w: lines.
			- note function:
				- the string as defined by the 'w:' line.
				- the x and y offsets.
				- the w: line number (0 .. n-1).
			- bar function:
				- the ABC bar as a string.
				- the x and y offsets.
				- the w: line number (0 .. n-1).
		Otherwise (pitch present), the PS origins are translated to
		the tablature area and the stack contains:
			- head function:
				- the instrument pitch with a single
				  uppercase letter and a sharp or flat.
			- note function:
				- the octave (0 is 'C') letting pitch >= 0
				  and < 36
				- the pitch in 12th of octave on 3 octaves
				  (0..35 - it may be not a whole number with
				  microtone)
				- the x offset
			- the bar function is never called.
		For examples of tablatures without pitch, see:
			'accordion.abc'
			'http://moinejf.free.fr/abc/banjo.abc',
			'http://moinejf.free.fr/abc/bataille.abc'
			'http://moinejf.free.fr/abc/tabyf1.abc'
		For examples of tablatures with pitch, look at
			flute.fmt
		and try:
			abcm2ps sample.abc -e1 -F flute.fmt -T1 -T3
}

set m2pshelp(tempofont)  {		Set the tempo font.
}

set m2pshelp(text)  {		Print one line of text using the current value of
		'%%textoption'.
}

set m2pshelp(textfont)  {		Set the text font.
}

set m2pshelp(textoption)  {		Set the default text option.
		This option is used for the text between '%%begintext' and
		'%%endtext', '%%text' and '%%EPS'.
		<int> may be an integer or a keyword. The values are:
			0: obeylines
			1: justify
			2: fill
			3: center
			4: skip
			5: right
		When <int> is 4 (skip), there is no output of texts
		(%%text, %%center, %%begintext..%%endtext...) and %%EPS.
}

set m2pshelp(textspace)  {		Set the vertical space above the history.
}

set m2pshelp(timewarn)  {		When set, if a time signature change occurs at the
		beginning of a music line, a cautionary time signature
		is added at the end of the previous line.
}

set m2pshelp(titlecaps)  {		When set, print the titles in uppercase letters.
}

set m2pshelp(titlefont)  {		Set the title font.
}

set m2pshelp(titleformat)  {		Define the format of the tune title.
		This format overrides the standard way to display the
		tune title. Then, parameters as %%titleleft, %%infoline
		and also  %%writefields are not used.
		The format is a set of letters, numbers, commas and
		plus and minus signs. Unrecognized characters are ignored.
		A letter gives the ABC header information type. It may be any
		type range 'A' to 'Z', but 'I', 'L', 'M', 'U' and 'V'.
		Alignment is defined by a number and/or a minus sign
		following the letter. It may be:
			'0' for 'center',
			'1' for 'right align'
			'-1' (or '-') for 'left align'.
		When absent, alignment defaults to center ('0').
		A plus sign ('+') may appear between two fields
		in which case these fields are concatenated (this works
		only with fields of the same type and same alignment).
		A comma defines a box edge. In each box, the fields are
		vertically added in their alignment zones.
		Example:
			%%titleformat R-1 P-1 Q-1 T C1 O1 , T + T N1
		displays:
		- in the 1st box:
		    - on the left: the rhythm, part and tempo
		    - in the middle: the main title (only)
		    - on the right: the composer and origin
		- in the 2nd box:
		    - in the middle: the concatenated subtitles
		    - on the right: the notes
		When <text> is empty, the default standard tune format is
		set back.
}

set m2pshelp(titleleft)  {		Output the title on the left (instead of centered).
}

set m2pshelp(titlespace)  {		Set the vertical space above the title.
}

set m2pshelp(titletrim)  {		When set, if the last word of a title starts with a capital
		letter and is preceded by a comma and a space, this word is
		moved at the head. For example: the title
			T:Clair de la lune, Au
		is printed as
			Au Clair de la lune
			
}

set m2pshelp(topmargin)  {		Set the page top margin.
}

set m2pshelp(topspace)  {		Set the vertical space above the tunes and on the top of
		the continuation pages.
}

set m2pshelp(transpose)  {		Transpose the music.
		<int> is a signed number of semitones.
		When "#" or "b" is present, the new key signature(s) will have
		sharps or flats in case of enharmonic keys.
		When this command appears in a global definition (format file
		or file header), it applies to all voices of all the following
		tunes.
		When it appears in a tune header, it applies to all voices.
		When inside a tune body, it applies to the current voice only.
		Note 1: Transposition of key signatures with explicit or
			added accidental list does not work.
		Note 2: The transposition is always relative to the ABC source
			(it does not depend on a previous %%transpose command).
}

set m2pshelp(tuplets)  {		Define how to draw the tuplets.
		The first <int> tells when to draw:
			0: auto (draw when no beam on some note of the tuplet)
			1: never
			2: always
		The second <int> tells what to draw:
			0: a square bracket
			1: a slur
			2: do beam extension on rests (does not work yet)
		The third <int> tells which value to print:
			0: a simple number (value of 'p')
			1: no value
			2: a ratio ('p':'q')
}

set m2pshelp(user)  {		Define a user decoration.
		This parameter is the same as the information field U:.
		In may be used in format files to change default decorations.
}

set m2pshelp(vocal)  {		Set the position of the lyrics.
		<int> may be:
			0 or 'auto' for automatic position (usually above
				the staff)
			1 or 'above' above the staff
			2 or 'below' below the staff
			3 or 'hidden' don't print
		When this command appears outside a tune or inside a tune
		header, it applies to all voices. When inside a tune body,
		it applies to the current voice only.
}

set m2pshelp(vocalabove)  {		Force the vocals to be above the staff.
		This command is obsolete. Use "%%vocal above' instead.
}

set m2pshelp(vocalfont)  {		Set the font of the lyrics under staves.
}

set m2pshelp(vocalspace)  {		Set the vertical space above the lyrics under the staves.
}

set m2pshelp(voicecolor)  {		Set a color on the symbols of the current voice.

		  With abcm2ps, color can be only defined by a 24 bits 
		  numerical color '#rrggbb' or by a HTML4 color name (aqua,
		  black, blue, fuchsia, gray, green, lime, maroon, navy,
		  olive, purple, red, silver, teal, white and yellow).
}

set m2pshelp(voicecombine)  {		Define how the notes/rests of the current
	  voice may be combined with the notes/rests of the next voice on
	  the same staff.

	  int may be:
	  < 0: the voices are displayed as written
	  0: the rests with the same duration are displayed as one rest
	  1: the notes with the same duration are combined to chords,
	    except when there could be a second, a unison or a voice inversion
	  2: the notes with the same duration are always combined to chords
	  > 2: display the unisons as single notes
}

set m2pshelp(voicefont)  {		Set the font of the voice names.
}

set m2pshelp(voicemap) {		Define the note mapping of a voice.

	  map_name is the name of a map defined by one or
	  many previous %%map definitions.

	  When appearing in the file or tune headers, the mapping
	  is to be applied to all voices.
	  When appearing in the tune body, its effect is
	  immediate for the current voice.

	  An empty map_name may be used to stop note mapping.
}

set m2pshelp(voicescale)  {		Set the scale of
		- all voices when in the tune header,
		- the current voice when found in the tune body.
		The <float> value must be in the range [0.6 .. 1.5].
}

set m2pshelp(volume)  {		Set the position of the volume decorations (!p!, !fff!...).
		<int> may be:
			0 or 'auto' for automatic position (usually below
				the staff)
			1 or 'above' above the staff
			2 or 'below' below the staff
			3 or 'hidden' don't print
		When this parameter appears outside a tune or inside a tune
		header, it applies to all voices. When inside a tune body,
		it applies to the current voice only.
}

set m2pshelp(vskip)  {		Skip vertical space of height <unit>.
}

set m2pshelp(wordsfont)  {		Set the font of the lyrics at end of tune.
}

set m2pshelp(wordsspace)  {		Set the vertical space above the lyrics at the end of
		the tune.
}

set m2pshelp(writefields)  {		<list> is an unsorted list of ASCII letters, each being
		the type of an information field.
		<bool> indicates whether the information field(s) is to be
		displayed or not.
}

set m2pshelp(clip)  { 	Define the subset of the tune(s) to be printed.
 
 	<start symbol> and <end symbol> are <symbol selection>s (see below).
 	The starting and ending symbols are included in the clip.
 	This command may appear only in a %%tune sequence.
 	There may be only one %%clip command in a %%tune sequence.
 
}

set m2pshelp(select)  { 	Select a subset of tunes in an ABC file to be printed.
 
 	<tune index list> is a comma separated list of tune numbers.
 	Each selector applies to the current ABC file.
 	A tune number may be:
 	- a single index value as indicated in the 'X:' field,
 	- a range of such values.
 	  A range is indicated as <first_index> \"-\" \[ <last_index> \].
 	  The last index may be omitted meaning 'last tune of file'.
 	The <regular expression> applies to the tune headers on their whole.
 	An empty %%select selects all the tunes of the next ABC files.
 
 	Command line examples:
 		abcm2ps voices.abc -e 1,3-5 newfeatures.abc -e5-
 		abcm2ps sample2.abc -eclefs voices.abc -e 'K:C\\s'
 
 	ABC file example:
 		%%select C:.*Bach
 		%%abc-include voices.abc
 		%%abc-include sample5.abc
 
 	Note: Such selections may give strange results when there are global
 	definitions in the ABC files (before and between the tunes).
 
}

set m2pshelp(tune)  { 	Select the tune(s) to which the following options will be applied.
 
 	The options are pseudo-comments (starting with %%), up to an other
 	'%%tune' command. The command \"%%tune end\" may be used to mark the
 	end of the options.
 
 	The options are inserted at start of the tunes (after the first K:)
 	whose header matches the <regular expression>.
 	When an option is %%score or %%staves, it replaces a %%score or
 	%%staves of the tune. There may be many such options, each one
 	replacing one %%staves/score of the tune.
 	%%tune may appear only in a global definition (command line,
 	format file or file header).
 	When the <regular expression> is the same as the one of a previous
 	%%tune, all the previous tune options for this regular expression
 	are removed.
 	When the <regular expression> is absent, all the tune options of
 	all tunes are removed.
 	ABC file example:
 	  Remove the 'ossia' part from sample5.abc of the abcm2ps package
 
 		%%tune Bach
 		%%leftmargin 1cm lock
 		%%rightmargin 1cm lock
 		%%scale 0.7
 		%%staves \{(1 2) (3 4)\}
 		%%staves \{(1 2) (3 4)\}
 		%%staves \{(1 2) (3 4)\}
 		%%abc-include sample5.abc
 
}

set m2pshelp(voice)  { 	Select the voice(s) to which the following options will be applied.
 
 	The options are pseudo-comments (starting with %%), up to an other
 	'%%voice', '%%tune' or %%score/%%staves command.
 	The command \"%%voice end\" may be used to mark the end of the options
 	for the last voice.
 
 	The commands are inserted before the first symbol of each voice which
 	identifier or full name match the <regular expression>.
 	%%voice may appear only in a global definition (command line,
 	format file,r file header or %%tune option list).
 	When the <regular expression> is the same as the one of a previous
 	%%voice, all the previous voice options for this regular expression
 	are removed.
 	When the <regular expression> is absent, all the global or tune
 	related voice options are removed.
 	ABC file example:
 	  Print 'Tridal a ra va c'halon' with 4 staves, lyrics at the top
 	  and with a 'tenor' clef.
 
 		%%select Tridal
 		%%tune Tridal
 		%%staves S A T B
 		%%voice S
 		%%vocal up
 		%%voice T
 		%%clef G,-8
 		%%abc-include voices.abc
 
}

#end of m2psdef.tcl




# Part 40.0
# start of Live Editor functions



proc load_whole_file {filename} {
    global wholefile
    global midi runabcpath
    #puts "load_whole_file = $filename"
    set inhandle [open $filename rb]
    # title_index uses gets to read the file and ignores \r.
    # In order that wholefile looks the same we replace \r\n with \n.
    # 2017-05-05. This may not work with the Mac.
    fconfigure $inhandle -encoding $midi(encoder) -translation lf
    set wholefile [read $inhandle]
    close $inhandle
    }

proc search_backwards_for_xref {loc xref} {
    global wholefile
    set actualref -1
    incr loc -1
    set k 0
    while {($loc >= 0) && ($actualref != $xref) && ($k < 5)} {
      set loc [string last "X:" $wholefile $loc]
      set value [string range $wholefile $loc [expr $loc + 10]]
      set match [scan $value "X:%d" actualref]
      if {$actualref == $xref} {return $loc}
      incr k
      }
    }

proc load_tune {from xref} {
     global wholefile
     global midi
     global tunestart tuneend
     # should see X: command here
     set actualref -1
     set xloc [string first "X:" $wholefile $from]
     set value  [string range $wholefile $xloc [expr $xloc + 10]]
     set match [scan $value "X:%d"  actualref]
     #puts "load_tune from = $from xloc = $xloc, value =  $value"
     #puts "actualref = $actualref"
     
     # may not match because of presence of foreign characters  2015-10-22
     if {$actualref != $xref} {
       set xloc [search_backwards_for_xref $from $xref]
       }
     #puts "load_tune: xloc = $xloc from = $from"
     #puts "xref = $xref"
     # if there is a header before the first X: it is possible
     # that from does not point to the start of the tune.
     if {$xloc != $from} {set from $xloc}
     set lastchar [string first "X:" $wholefile [expr $from + 1]]
     if {$lastchar > 0} {
        set tune [string range $wholefile $from [expr $lastchar -1]]
        } else {
        set tune [string range $wholefile $from end]
        }
     set tunestart $from
     set tuneend [expr [string length $tune]+$tunestart]
     #remove \r if any (2017-05-05). Could cause problem with Mac?
     regsub -all \r $tune "" fixedtune
     return $fixedtune
     }

proc insert_ps_header {tune} {
     # copies ps_header after the X:1 line
     global ps_header
     # replace \n after X:n with \n$ps_header
     set eol [string first "\n" $tune 2]
     if {[string length $ps_header] > 0 } {
       set tune [string replace $tune $eol $eol \n$ps_header]
       }
     return $tune
     }


proc update_musicscore {tunecontent} {
    global midi
    global cmn
    global npgms
    global midi
    global psheader_lines
    global ps_header
    global exec_out
    global pgmindex npgms
    global live_refreshed
    if {$midi(use_ps_header)} {
        set atunecontent [insert_ps_header $tunecontent]
        set psheader_lines [countlines_in $ps_header]
        #puts "psheader_lines = $psheader_lines"
        #puts "atunecontent =\n$atunecontent"

    } else {
        set psheader_lines 0
        set atunecontent $tunecontent}

    # cannot handle long file names when input comes from stdin
    # abcm2ps - feature. This prevents opening abcm2ps when in
    # c:/program files (x86)/runabc/abcm2ps. 2017-01-22.

    set out_fd [open "X.tmp" w]
    puts $out_fd $atunecontent
    close $out_fd

    set exec_out "exec [list $midi(path_abcm2ps)] X.tmp -A -j 2 -s $midi(livescale)   << ..."
    #catch {exec  [list $midi(path_abcm2ps)] X.tmp -A -s $midi(livescale)  << $atunecontent} result
    set cmd "exec  [list $midi(path_abcm2ps)] X.tmp -A -j 2 -s $midi(livescale)  << $atunecontent" 
    catch {eval $cmd} result
    append exec_out "\n$result"
    set cmd "file delete [glob -nocomplain *.pgm]"
    catch {eval $cmd}
    set cmd "exec [list $midi(path_gs)] -dBATCH -dNOPAUSE -sDEVICE=pgmraw -q -sOutputFile=out%d.pgm Out.ps "
    catch {eval $cmd} result2
    append exec_out "\n$result2"
    set cmd "glob *.pgm"
    catch {eval $cmd} result
    if {[string first "no files" $result] == 0} {
         return } else {
         set npgms [llength $result]}
    $cmn read out$pgmindex.pgm
    .live.header.middle configure -text "1/$npgms"
    extract_notes_from_ps 
    if {$midi(livehotspots)} {show_objects 1} 
    set live_refreshed 1
}


 
proc button_press {x y} {
    global pgmindex
    set xc [.live.main.music.c canvasx $x]
    set yc [.live.main.music.c canvasy $y]
    #puts "$xc $yc"
    set c [closest_note_in_list $xc $yc $pgmindex]
    }

proc determine_page_height {infile} {
    set inhandle [open $infile "r"]
    set line [gets $inhandle]
    set line [gets $inhandle]
    set line [gets $inhandle]
    set dim [split $line]
    close $inhandle
    return [lindex $dim 1]
    }


proc extract_notes_from_ps {} {
    # This procedure is customized to read the Out.ps file
    # produced by abcm2ps and extract the coordinates of 
    # the note heads.
    global objectlist psscale objectpage
    set pageheight [determine_page_height out1.pgm]

    #puts "extract_notes_from_ps"
    if {[info exist psscale]} {unset psscale}
    array unset objectpage

    set inhandle  [open "Out.ps" r ]

    set line [gets $inhandle]
    while {![eof $inhandle]} {
         if {[string first "%%EndSetup" $line] > -1} break
         set line [gets  $inhandle]
         }


    while {![eof $inhandle]} {
        set line [gets $inhandle]

        set match [scan $line "%%%%Page: %d" p]
        if {$match >0} {
            set xtrans 0
            set ytrans 0
            set objectlist($p) {}
            continue
            }

        set match [scan $line "gsave %f %f T" tx ty]
        if {$match == 2} {
            #puts $line
            set ytrans [expr $ty - $pageheight]
            #puts "ytrans = $ytrans"
            continue
            }

        # for abcm2ps versions 8.9.*
        set match [scan $line "gsave %f dup scale %f %f T" xscale tx ty]
        # ignore if grestore present 2021-01-17 -- to handle text in Q:
        if {$match == 3 && [string first "grestore" $line] < 0} {
            #puts $line
            set ytrans [expr $ty*$xscale - $pageheight]
            set psscale $xscale
            #puts "ytrans = $ytrans psscale = $psscale"
            set match 0
            }

        set match [scan $line "%f %s %s" xscale c1 c2]
        if {$match == 3} {
            if {$c1 == "dup" && $c2 == "scale"} {
              #puts "line = $line"
              if {[info exist psscale] == 1} {
                 set psscale [expr $xscale * $psscale]} else {
                 set psscale $xscale}
              #puts "psscale = $psscale"
              set match 0
              continue
              }
            }



        set match [scan $line "%f %f %s %f %s" px py pc pb pd"]
        #puts $line
        #puts $match
        if {[string first "%A N" $line] == 0} {
            #puts $line
             scan $line "%cA N %d %d %f %f" c row col x y
             set yp [expr round(-$psscale*($py + $ytrans )) + 4]
             set xp [expr round($psscale*($px + $xtrans))]
             #puts "$row $col $x $y $xp $yp"
             lappend objectlist($p) [list $xp $yp $row $col]
             if {[info exist arrayobject($row)] == 0} {set objectpage($row) $p}
            }
        if {[string length $line] < 13 && [string last "T" $line] > 5} {
            if {[string first "pop" $line] >= 0} continue
            scan $line "%f %f" tx ty
            set ytrans [expr $ytrans+$ty]
            set xtrans [expr $xtrans+$tx]
            #puts "T tx ty = $tx $ty $xtrans $ytrans"}

        }
    #puts $objectlist(1)
    close $inhandle
    }

# live editor support functions

proc closest_note_in_list {x y page} {
global objectlist 
global psheader_lines
set nobject [llength $objectlist($page)]
set min_d 2000
set min_i -1
for {set i 0} {$i < $nobject} {incr i} {
    set obj [lindex $objectlist($page) $i]
    set ix [lindex $obj 0]
    set iy [lindex $obj 1]
    set d [expr abs($ix-$x) + abs($iy-$y)]
    if {$d < $min_d} {set min_i $i
                      set min_d $d}
    }
if {$min_d < 150} {
    set obj [lindex $objectlist($page) $min_i]
    set r [lindex $obj 2]
    set c [lindex $obj 3]
    # in case ps_header is imported and not expressed
    # in the editor window frame
    set r [expr $r - $psheader_lines]
    focus .live.main.editor.t
   .live.main.editor.t mark set insert $r.$c
   .live.main.editor.t  see $r.$c
   #puts "row = $r"
    }

return ""
}

proc closest_note_object {loc} {
# finds the note in the music canvas corresponding to the
# note at position loc in the editor and highlights that note
# with a red rectangle.
global objectlist objectpage
global pgmindex
global psheader_lines
set  loclist [split $loc .]
set row [lindex $loclist 0]
set col [lindex $loclist 1]
# in case we have imported the ps_header
set row [expr $row + $psheader_lines ]
#puts [array get objectpage]
#puts "row col = $row $col"
if {[info exist objectpage($row)] == 0} return
set page $objectpage($row)
if {$page != $pgmindex} {
      set pgmindex $page
      show_pgmfile
      }
set nobject [llength $objectlist($page)]
for {set i 0} {$i < $nobject} {incr i} {
    set obj [lindex $objectlist($page) $i]
    set r [lindex $obj 2]
    set c [lindex $obj 3]
    if {$r != $row} continue
    if {$c >= $col} {
        set ix1 [lindex $obj 0]
        set iy1 [lindex $obj 1]
        set ix2 [expr $ix1 + 5]
        set iy2 [expr $iy1 + 5]
        .live.main.music.c  create rect $ix1 $iy1 $ix2 $iy2 -tag pos -outline red -width 2
        set vfract [.live.main.music.c yview]
        set vtop [expr [lindex $vfract 0] * 796.0]
        set vbot [expr [lindex $vfract 1] * 796.0]
        if {$iy1 < $vtop || $iy1 > $vbot} {
            set fraction [expr ($iy2 - 100) /796.0]
            .live.main.music.c yview moveto $fraction
            }
        break}
    } 
}
    


# live editor support functions

proc show_objects {page} {
# for debugging
global objectlist psscale
.live.main.music.c delete -tag hot
#puts "show_objects for page $page:\n$objectlist($page)"
foreach obj $objectlist($page) {
   set ix1 [lindex $obj 0]
   set iy1 [lindex $obj 1]
   set ix2 $ix1
   set iy2 $iy1
   #set ix1 [expr $ix1 - $psscale]
   set iy1 [expr $iy1 + $psscale]
   set ix2 [expr $ix2 - 5]
   set iy2 [expr $iy2 - 5]
  .live.main.music.c create rect $ix1 $iy1 $ix2 $iy2 -fill red3 -tag hot
   }
}


proc shift_pgmfile {pgmdir} {
global pgmindex
global npgms
switch $pgmdir {
  -2 {set pgmindex $npgms}
  2  {set pgmindex 1}
  -1 {incr pgmindex
      if {$pgmindex > $npgms} {set pgmindex $npgms}
     }
  1  {incr pgmindex -1
      if {$pgmindex < 1} {set pgmindex 1}
     }
  }
show_pgmfile 
}

proc show_pgmfile {} {
global cmn
global midi
global npgms
global pgmindex
$cmn read out$pgmindex.pgm
if {$midi(livehotspots)} {show_objects $pgmindex} 
.live.header.middle configure -text "$pgmindex/$npgms"
}


proc live_scale {scalefac} {
global midi
global tunecontent
set midi(livescale) $scalefac
update_musicscore $tunecontent
}

set hlp_live_editor \
    "Live Editor\n\n\
     The live editor is activated (or deactivated) from main\
     menu icon to the right of the printer icon.\
     It is a 'live editor' in the sense that any edits will immediately change\
     the music representation in the top window frame. When you edit the tune,\
     the save button will be shown in red to signal that you need to do a save\
     in order to update the open abc file. Provided that you have not done\
     a save, you can undo or redo any of your changes.\n\n\
     If you click on a note in the music window, a cursor will be placed at the corresponding\
     note in the editor. If you hold the left alt button down while the editor is in focus,\
     the corresponding note in the music window will be highlighted in red.\n\n\
     This feature may not work correctly if the PostScript header block\
     appearing before the first X: reference command is imported and\
     modifies the scale factor. (You may need to untick the option\
     'use ps header' in the options menu.)\n\n\
     In the case that the score does not fit on a page, the top arrow buttons allow you\
     to go to the first, next, previous, or final page. The page number and number\
     of pages is shown as a fraction in the middle.\n\n\
     The play menu button is designed to play a small \
     portion of the file. You can either play a single text line positioned \
     at your insert cursor or else you can play a selected area. To designate\
     a selected area,  hold the left mouse button down and sweep an \
     area with your cursor in the edit window.  Avoid selecting an area \
     starting with a line feed.  The tcl/tk script will search backwards \
     for the X: and other field commands occurring before your highlighted \
     area and also use this  information for creating the midi file.\n\n\
     The options menu allows you to scale the score representation or\
     switch between horizontal and vertical orientation. (Show\
     hotspots is useful to check the operation of the program.)
     "

proc create_live_editor {} {
global cmn
global midi
global tunecontent
global live_refreshed
global font df
global abc_file_mod

set live_refreshed 1

if {[string length $midi(path_gs)] < 2} {
   messages "You need to go to options/settings and set the path to ghostscript and then restart runabc. (On Windows find gswin32c or gswin64c.) If you do not want to install ghostscript and see this message, go to options and untick activate live editor."
   return
   }


toplevel .live
position_window ".live"


set head .live.header
frame .live.header
pack .live.header


if {$midi(livesashorient) == "ver"} {
  panedwindow .live.main -orient vertical -handlesize 12 -handlepad 5
  } else {
  panedwindow .live.main -orient horizontal -handlesize 12 -handlepad 5
  }
.live.main configure -relief sunken -borderwidth 6 -background lightblue -showhandle 1 -handlesize 16 -sashwidth 10
pack .live.main -expand 1 -fill both
frame .live.main.music 
frame .live.main.editor
.live.main add .live.main.music .live.main.editor

button $head.save -text "save" -font $df\
   -command {update_wholefile "yes"
            set abc_file_mod 1
	    title_selected
	    }
button $head.undo -text "undo" -font $df \
   -command {.live.main.editor.t edit undo
             set tunecontent [.live.main.editor.t get 1.0 end]
             update_musicscore $tunecontent}
button $head.redo -text "redo" -font $df \
   -command {.live.main.editor.t edit redo
             set tunecontent [.live.main.editor.t get 1.0 end]
             update_musicscore $tunecontent}
button $head.lleft -text "|<" -command "shift_pgmfile 2" -font $df
button $head.left -text "<-"  -command "shift_pgmfile 1" -font $df
label $head.middle -text "1/1" -font $df
button $head.right -text "->" -command "shift_pgmfile -1" -font $df
button $head.rright -text ">|" -command "shift_pgmfile -2" -font $df

menubutton  $head.play  -text play -font $df \
            -menu $head.play.type
menu $head.play.type -tearoff 0
 $head.play.type add command -label line  \
          -command {play_from_edit_window line .live.main.editor.t} -font $df
 $head.play.type add command -label selection  \
          -command {play_from_edit_window sel .live.main.editor.t} -font $df

set wmenu $head.livemenu.type
menubutton $head.livemenu -text options -menu $wmenu -font $df
menu $wmenu -tearoff 0
$wmenu add checkbutton -label "show hotspots" -command toggle_hotspots -variable midi(livehotspots) -font $df
$wmenu add cascade -label "scale" -menu $wmenu.scale -font $df
set wmenu2 $wmenu.scale
menu $wmenu2 -tearoff 0
$wmenu2 add radiobutton -label "0.75" -command "live_scale 0.75" -font $df
$wmenu2 add radiobutton -label "0.80" -command "live_scale 0.80" -font $df
$wmenu2 add radiobutton -label "0.85" -command "live_scale 0.85" -font $df
$wmenu2 add radiobutton -label "0.90" -command "live_scale 0.90" -font $df
$wmenu2 add radiobutton -label "0.95" -command "live_scale 0.95" -font $df
$wmenu2 add radiobutton -label "1.00" -command "live_scale 1.00" -font $df
$wmenu add  radiobutton -label "horizontal orientation" -variable midi(livesashorient) -value hor -command toggle_orientation -font $df
$wmenu add  radiobutton -label "vertical orientation"  -variable midi(livesashorient) -value ver -command toggle_orientation -font $df

button $head.help -text "help" -font $df\
     -command {show_message_page $hlp_live_editor word}


pack $head.save $head.undo $head.redo $head.lleft $head.left $head.middle $head.right $head.rright $head.play $head.livemenu $head.help -side left

canvas .live.main.music.c -width 616 -height 300 -scrollregion {0 0 616 796} -yscrollcommand ".live.main.music.vscroll set"
scrollbar .live.main.music.vscroll -command ".live.main.music.c yview"

pack .live.main.music.c -fill both -expand 1 -side left
pack .live.main.music.vscroll -fill y -expand 1

text .live.main.editor.t  -width 50 -height 25 -wrap none -bg bisque\
            -yscrollcommand {.live.main.editor.ysbar set} \
            -xscrollcommand {.live.main.editor.xsbar set} 
scrollbar .live.main.editor.ysbar -orient vertical -command {.live.main.editor.t yview}
scrollbar .live.main.editor.xsbar -orient horizontal -command {.live.main.editor.t xview}

pack .live.main.editor.ysbar -side right -fill y -expand 0
pack .live.main.editor.xsbar -side bottom -fill x
pack .live.main.editor.t -side left -anchor w -fill both -expand 1

.live.main.editor.t configure -undo 1


bind .live.main.editor.t <KeyPress> {
    if {"%K" == "Alt_L"} { 
        set loc [.live.main.editor.t index insert]
        closest_note_object $loc 
        }
    }

bind .live.main.editor.t <KeyRelease> {
    if {"%K" == "Alt_L"} { 
        set loc [.live.main.editor.t index insert]
        .live.main.music.c  delete -tag pos
        } elseif {"%K" == "Right" || "%K" == "Left" ||
                  "%K" == "Up" || "%K" == "Down"} {
            continue} else {
        #.live.main.editor.t mark set insert $r.$c
        update
	# do not update_musicscore after each letter insert. Wait until
	# you get a bunch of letters.
        if {$live_refreshed} {		    
           set live_refreshed 0
	   after 200
           set tunecontent [.live.main.editor.t get 1.0 end]
           update_musicscore $tunecontent
	   .live.header.save configure -fg red
           }
        }
    }

bind .live.main.music.c <Button> {button_press %x %y }   

set cmn [image create photo]
wm protocol .live WM_DELETE_WINDOW {destroy .live}

tkwait visibility .live

if {$midi(livesashorient) == "ver"} {
   .live.main sash place 0 1 $midi(livesashvert)
   } else {
   .live.main sash place 0 $midi(livesashhor) 0
   }
bind .live.main <ButtonRelease> {set sashp [.live.main sash coord 0]
   if {$midi(livesashorient) == "ver"} {
           set midi(livesashvert) [lindex $sashp 1]
   } else {
           set midi(livesashhor) [lindex $sashp 0]
   }
 }
}



proc countlines_in {string} {
        set rc [llength [split $string "\n"]] 
        # split adds an empty object after the last \n
        if {$rc > 0} {incr rc -1}
        return $rc
 }

 


proc update_live_editor {loc xref} {
    # returns end position of tune in wholefile
    global midi cmn
    global npgms
    global pgmindex
    global exec_out
    global tunecontent
    global ps_header
    global psheader_lines

    set tunecontent [load_tune $loc $xref]
    set pgmindex 1
    update_musicscore $tunecontent



    .live.main.music.c create image 0 0 -anchor nw -image $cmn
     # restore scroll view
    .live.main.music.c yview moveto 0.0


    .live.main.editor.t delete 1.0 end
    .live.main.editor.t insert 1.0 $tunecontent 
    extract_notes_from_ps 
    if {$midi(livehotspots)} {show_objects 1} 
   }

proc switch_live_editor {} {
    global midi fileseek
    if {$midi(live_editor)} {
       create_live_editor
       after 100
       if {[info exist fileseek]} {title_selected}
       } else {destroy .live}
    }

proc toggle_hotspots {} {
    global midi
    global pgmindex
    if {$midi(livehotspots) == 0} {
        .live.main.music.c delete -tag hot} else {
        show_objects $pgmindex
        }
    }


proc toggle_orientation {} {
global midi
if {$midi(livesashorient) == "ver"} {
 .live.main configure -orient vertical
 } else {
 .live.main configure -orient horizontal
 }
}

switch_live_editor 

# End of Live Editor Functions


# Part 41.0 Generate Guitar Chords

proc put_guitar_chords {numb} {
global fieldtext bodytext
global abctxtw


set tunestring [$abctxtw get 0.0 end]
add_guitar_chords_to_tune $tunestring $numb

# output
set output_text $fieldtext
$abctxtw delete 1.0 end
$abctxtw insert end $fieldtext 
$abctxtw insert end $bodytext
tag_text $abctxtw
}

proc gc_process_line {line} {
# processes the notes in a single line of the body in sequence.
# We only care about the duration of the note and position of
# the guitar chord indications. Thus we need to recognize
# barlines eg. | || :| |: |[1 |[2
# chords eg. [CEG]
# triplets eg. (3CDD
# gchords (anything enclosed by double quotes)
# notes eg. A3/2 A/ A3 A
# Each of these entities are handled by different functions.
#set barpat {\||:\|\[\d|:\||\|:|\|\[\d|\||::}
set barpat {\|\||\|[0-9]?|:\|\[\d|:\|[0-9]?|:\||\|:|\|\[\d|\||::}
set notepat {(~?)(\^*|_*|=?)([A-G]\,*|[a-g]\'*|z)(/?[0-9]*|[0-9]*/*[0-9]*)}
set gchordpat {\"[^\"]+\"}
set curlypat {\{[^\}]*\}}
set chordpat {\[[^\]\[]*\]}
set instructpat {![^!]*!}
set tupletpat  {\(\d(\:\d)*}
set sectpat {\[[0-9]+}

global bar_accumulator beat_accumulator
global bodytext
global preservegchord
global beatsize barunits

set lineout ""
set beatstart 0
set lastguitarchord ""
# remove existing gchords if any
regsub -all  {"[^"]*"} $line "" result
set line $result

# scan through the whole line (including gchords)
set i 0
while {$i < [string length $line]} {
# search for bar lines
 set success [regexp -indices -start $i $barpat $line location]
 if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {
     set matchinfo [best_chord_match] 
     set guitarchord [lindex $matchinfo 0]
     if {$guitarchord != 0 && [string equal $guitarchord $lastguitarchord] != 1} {
        append lineout " \"$guitarchord\" "}
     append lineout [string range $line $beatstart $loc2]
     set lastguitarchord $guitarchord
     set beatstart [expr $loc2 + 1]
     gc_process_barline 
     set i [expr $loc2+1]
     continue}
   }

# for repeat sections
 set success [regexp -indices -start $i $sectpat $line location]
 if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {
     #set sect [string range $line $loc1 $loc2]
     set i [expr $loc2+1]
     continue
     }
  }



 set success [regexp -indices -start $i $curlypat $line location]
# search for grace note sequences
  if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
#  ignore grace notes in curly brackets
   if {$loc1 == $i} {
     set i [expr $loc2+1]
     continue}
   }


 set success [regexp -indices -start $i $tupletpat $line location]
# search for tuplet indication
  if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {gv_process_tuplet $location $line
     set i [expr $loc2+1]
     continue}
   }

 set success [regexp -indices -start $i $instructpat $line location]
# search for embedded instructions like !fff!
  if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {
#    skip !fff! and similar instructions embedded in body
     set i [expr $loc2+1]
     continue}
   }

 set success [regexp -indices -start $i $notepat $line location]
# search for notes
 if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {
     gc_process_note [string range $line $loc1 $loc2]
     if {$beat_accumulator >= $beatsize && $bar_accumulator != $barunits} {
        set matchinfo [best_chord_match] 
        set guitarchord [lindex $matchinfo 0]
        if {$guitarchord != 0 && [string equal $guitarchord $lastguitarchord] != 1} {
           append lineout " \"$guitarchord\" "
           append lineout [string range $line $beatstart $loc2]
           #puts "lineout = $lineout"
           set lastguitarchord $guitarchord
           set beatstart [expr $loc2 + 1]
           }
        reset_pitcharray}   else {
        #read stdin 1
        set i $loc2
        }
     }
 }

 set success [regexp -indices -start $i $chordpat $line location]
# search for chords
  if {$success} {
   set loc1  [lindex $location 0]
   set loc2  [lindex $location 1]
   if {$loc1 == $i} {process_chord [string range $line $loc1 $loc2] $line $loc2
     set i [expr $loc2+1]
     continue}
     }

 incr i
 }
#puts $line
set bodytext $bodytext$lineout\n
}




# set flag to adjust the duration of the next three notes
proc gc_process_triplet {} {
process_tuplet
}

# determine the duration of the note. We ignore broken
# notes (eg A > C) because the two notes usually complete
# a beat. We also do not need to pay attention to tied
# notes.
proc gc_process_note {token} {
  global bar_accumulator beat_accumulator
  global noteunits
  global triplet_running
  global tupletscalefactor
  global tuplenotes
  global pitcharray 

  set durpatf {([0-9])\/([0-9])}
  set durpatn {[0-9]}
  set durpatd {\/([0-9])}
  set dur2 {/+}
  set pitchpat {([A-G]\,*|[a-g]\'*|z)}
  regexp $pitchpat $token match pitchval
  set pitchval [string toupper $pitchval]
  if {[regexp $durpatf $token match val1 val2]} {
     set increment  [expr $noteunits*$val1/$val2]
    } elseif {
  [regexp $durpatd $token val1 val2]} {
     set increment  [expr $noteunits/$val2]
     } elseif {
 [regexp $durpatn $token val]} {
     set increment  [expr $noteunits*$val]
    } elseif {
  [regexp $dur2 $token val]} {
     set increment  [expr $noteunits/2]
     } else {
  set increment $noteunits
  }
 if {$triplet_running} {
     set increment [expr round($tupletscalefactor * $increment)]
     incr triplet_running
     if {$triplet_running > $tuplenotes} {set triplet_running 0}
     }

  incr bar_accumulator $increment
  incr beat_accumulator $increment
  #puts "$token $pitchval $bar_accumulator $increment $pitchval"
  incr pitcharray($pitchval) $increment
  return 
 }


# We hope all the notes in the chord are of equal.
# We get the time value of the chord from the time
# value of the first note in the chord.
proc process_chord {token line loc} {
  #set line [gc_process_note $token]
  }


# This is the function which processes the tune.
# Assume only one tune per file.
proc add_guitar_chords_to_tune {tunestring numb} {
 global bar_accumulator beat_accumulator
 global bar_number
 global triplet_running
 global body
 global debug
 global pitcharray
 global fieldtext bodytext
 global barunits beatsize
 
 set fieldtext ""
 set bodytext ""

 array set pitcharray {A 0 B 0 C 0 D 0 E 0 F 0 G 0}
 set fieldpat {^X:|^T:|^C:|^O:|^A:|^Q:|^Z:|^N:|^H:|^S:}
 set triplet_running 0
 set body 0
 set bar_number 0
 foreach line [split $tunestring \n] {
   #puts "line = $line"
   if {[string length $line] < 1} continue
   if {[string index $line 0] == "%"} {
      appendtext $line
      continue
      } elseif {
   [regexp $fieldpat $line] } {
      appendtext $line
      } elseif {
   [string first "K:" $line] == 0} {
       appendtext $line
       set kfield [string range $line 2 end]
       gc_setup_key $kfield
       set bar_accumulator 0
       set beat_accumulator 0
       if {!$body} {
         set body 1
         }
      } elseif {
   [string first "M:" $line] == 0} {
       appendtext $line
       gc_setup_meter $line
       # one beat per bar ?
       set beatsize [expr $barunits/$numb]
       } elseif {
   [string first "P:" $line] == 0} {
       appendtext $line
       } elseif {
   [string first "L:" $line] == 0} {
       appendtext $line
       gc_setup_unitlength $line
      } elseif {$body} {
       gc_process_line $line
   } else {appendtext $line}
 }
}


# Handles M: command
proc gc_setup_meter {line} {
  global default_gchord
  global gchordstring
  global barunits beatsize
  global noteunits
  if {[string first "C|" $line] >= 0} {
    set m1 2
    set m2 2} elseif {
      [string first "C" $line] >= 0} {
    set m1 4
    set m2 4} else {
    set r [scan $line "M:%d/%d" m1 m2]}
  set barunits [expr 96 * $m1 /$m2]
  set meter $m1/$m2

  #if {[info exists noteunits]} return
  if {[expr double($m1)/$m2] < 0.75} {
    gc_setup_unitlength L:1/16} else {
    gc_setup_unitlength L:1/8}

  if {$m1 == 2 || $m1 == 4} {
       set beatsize 24 
     } else {
       set beatsize 36}
  }

#Handles L: command
proc gc_setup_unitlength {line} {
  global noteunits
  set r [scan $line "L:%d/%d" m1 m2]
  set noteunits [expr 96 * $m1 /$m2]
  }

array set preferredchords {maj {I IV V} min {i iv VII} dor {i VII IV} phr {i II vii} lyd {I II vii}  mix {I v VII} loc {I V}}
set fullnotekey "CDEFGABCDEFGABCDEFGABC"

proc gc_setup_key {keysig} {
# Given the key signature, the function returns a list of the
# preferred guitar chords to use (chords_for_key). The array
# chords_spelled() spells out the notes for each of the preferred
# guitar chord. The function recognizes the common modes (eg.
# minor, major, dorian etc.)

  global preferredchords roman2arabic fullnotekey
  global keymap
  global  chords_for_key chords_spelled
  set sf [keytosf $keysig]
  setkeymap $sf
  set s [regexp {([A-G]|none)(#*|b*)(.*)} $keysig match key sub2 mode]
  if {$s < 1} {puts "can't understand key signature $keysig"
        return}
  if {[string compare $key "none"] == 0} {set key C}
  set key $key$sub2
  #puts "key = $key"
  if {$mode == ""} {set mode "maj"}
  if {$mode == "m"} {set mode "min"}
  #puts "key mode = $key $mode" 
  # eliminate sharp or flat if present
  set key [string index $key 0]
  set loc [string first $key $fullnotekey]
  set mode [string tolower $mode]
  set usechords $preferredchords($mode)
  #puts "usechords = $usechords"
  set chords_for_key ""
  foreach gchord $usechords {
      set majmin ""
      if {[string is lower $gchord]} {set majmin "m"}
      if {[string first "o" $gchord ] > 0} {set majmin "dim"}
      #eliminate trailing o if present (for diminished chord)
      set gchord [string map {o ""} $gchord]
      set g [string toupper $gchord]
      set g $roman2arabic($g)
      # convert to guitar chord
      set gc [string index $fullnotekey [expr $loc - 1 + $g]]
      set gc $keymap($gc) 
      #puts "gc = $gc"
      set chords_spelled($gc$majmin) $gc
      lappend chords_spelled($gc$majmin)  [string index $fullnotekey [expr $loc +1 +  $g]] 
      lappend chords_spelled($gc$majmin) [string index $fullnotekey [expr $loc +3  + $g]] 
      #puts "$gc$majmin $chords_spelled($gc$majmin)"
      lappend chords_for_key $gc$majmin
      }
  }


proc print_pitcharray {} {
global pitcharray
foreach c {A B C D E F G} {
 puts -nonewline "$pitcharray($c) "
 }
puts -nonewline "  "
}


proc gc_process_barline {} {
  global bar_accumulator beat_accumulator
  global bar_number
  set bar_accumulator 0
  set beat_accumulator 0
  incr bar_number
  }

proc reset_pitcharray {} {
  # The pitcharray counts the number of times a particular note
  # appears inside a bar (or beat).
  global beat_accumulator
  global pitcharray
  #print_pitcharray
  array set pitcharray {A 0 B 0 C 0 D 0 E 0 F 0 G 0}
  set beat_accumulator 0
  }

proc match_pitcharray_with_gchord {chord} {
# The function determines how many notes in the bar match
# the pattern of notes for a given guitar chord.
global pitcharray
set match 0
foreach note $chord {
    # remove flat/sharp if any
    set note [string index $note 0]
    incr match $pitcharray($note)
    }
return $match
}

proc best_chord_match {} {
# The function returns the guitar chord which best fits the
# notes in the bar (or beat).
global chords_for_key chords_spelled
set largestmatchval 0
set bestchord ""
foreach chord $chords_for_key {
    set match [match_pitcharray_with_gchord $chords_spelled($chord)]
    if {$match > $largestmatchval} {set largestmatchval $match
                                    set bestchord $chord}
    }
return "$bestchord $largestmatchval"
}

# End Put Guitar Chords


 #array set preferredchords {maj {I IV V} min {i iv VII} dor {i ii IV} phr {i II vii} lyd {I II vii} mix {I v VII} loc {io V}}
 #set chordtype {0 1 1 0 0 1 2 0 1 1 0 0 1 1}

 proc preferredchords_interface {} {
 global preferredchords 
 global chordtype
 set roman_numbers {I II III IV V VI VII}
 set modeseq {maj dor phr lyd mix min loc}
 if {[winfo exist .preferred_chords]} return
 toplevel .preferred_chords
 position_window ".preferred_chords"
 set p .preferred_chords
 set i 0
 set m 0
 label $p.head -text "principle chords to use for each mode"
 grid $p.head -columnspan 6
 for {set i 0} {$i < 7} {incr i} {
   set i1 [expr $i + 1]
   set mode [lindex $modeseq $i]
   set chosenchords $preferredchords($mode)
   incr m
   label $p.$m  -text $mode
   grid $p.$m -row $i1 -column 1
   for {set j 0} {$j < 7} {incr j} {
       set k [expr $i + $j]
       #puts -nonewline " [lindex $chordtype $k]"
       set chordcode [lindex $roman_numbers $j]
       set colour "blue"
       if {[lindex $chordtype $k] == 1} {
          set chordcode [string tolower $chordcode]
       } elseif {[lindex $chordtype $k] == 2} {
          set chordcode [string tolower $chordcode]
          append chordcode "o"
         } 
       if {[lsearch $chosenchords $chordcode] > -1} {
          set colour "red"
          }
       set j1 [expr $j+2]
       incr m
       button $p.$m -text $chordcode -fg $colour -command "modify_preferredchords $mode $chordcode $m"
       grid $p.$m -row $i1 -column $j1
       #puts -nonewline " $chordcode"
       }
   }
}

 proc modify_preferredchords {mode chord m} {
   # inserts chord in preferredchords(mode) if missing, otherwise deletes
   # chord from preferredchords(mode)
   global preferredchords
   set idx [lsearch $preferredchords($mode) $chord]
   if {$idx < 0} {
     lappend preferredchords($mode) $chord
     .preferred_chords.$m configure -fg red
  } else {
     set preferredchords($mode) [lreplace $preferredchords($mode) $idx $idx]
     .preferred_chords.$m configure -fg blue
  }
 }

#Part 42.0 summarize midi structure

set hlp_msummary "\t\tMidi Summary\n\n\

Besides summarizing the structure and contents of the midi file\
this window provides many of the features in the piano roll window\
(pianoroll) that are accessible in the action menu. You can plot\
many of the distributions (eg. pitch class) and furthermore\
you can limit these plots to a particular track or channel that\
you have selected. Hold the control key down to select or deselect\
any of the tracks. They will be highlighted in blue. If one or more of\
the plots is exposed, they will be updated to reflect the current\
track selections.\n\n\
The piano roll shows only the selected tracks (or channel).\n\n\
The abc notation menu links to the midi2abc property page and the\
big abc editor. Only the selected tracks or channels are used.
"

 
proc make_midi_summary {} {
 global df
 global midi
 set w .msummary
 if {![winfo exist $w]} {
   toplevel .msummary
   position_window .msummary
   set w .msummary.menuline
   frame $w
   pack $w -anchor w
   menubutton $w.rhythm -text "rhythm plots" -font $df -menu $w.rhythm.items
   menu $w.rhythm.items -tearoff 0
   $w.rhythm.items add command -label "onset distribution" -font $df\
     -command {midi_statistics onset
	       plotmidi_onset_pdf}
   $w.rhythm.items add command -label "note duration distribution" -font $df\
     -command {midi_statistics duration
	       plotmidi_duration_pdf}

   menubutton $w.pitch -text "pitch plots" -font $df -menu $w.pitch.items
   menu $w.pitch.items -tearoff 0
   $w.pitch.items add command -label "pitch distribution" -font $df\
    -command {midi_statistics pitch
              plotmidi_pitch_pdf}
   $w.pitch.items add command -label "pitch class distribution" -font $df\
    -command {midi_statistics pitch
	      show_note_distribution}
   $w.pitch.items add command -label "notegram" -font $df\
    -command notegram_plot
   $w.pitch.items add command -label "velocity pdf" -font $df\
    -command {midi_statistics velocity
	      plotmidi_velocity_pdf}
   button $w.roll -text "piano roll" -font $df \
    -command show_pianoroll
   menubutton $w.abcmenu -text "abc notation" -font $df -menu $w.abcmenu.items 
   menu $w.abcmenu.items -tearoff 0
   $w.abcmenu.items add command  -label midi2abc -font $df -command show_midi2abc_page
   $w.abcmenu.items add command  -label editor -font $df -command big_create_abc_file
   button $w.pgram -text pgram -font $df -command pgram_window
   button $w.browse -text "browse" -command midi_file_browser -font $df
   button $w.help -text "help" -font $df -command {show_message_page $hlp_msummary word}

   pack $w.rhythm $w.pitch $w.roll $w.pgram $w.abcmenu $w.browse $w.help -side left -anchor w

   set w .msummary.data
   frame $w
   pack $w
   ttk::treeview $w.tree -columns {trk chn program notes activity pavg duration } -show headings -height 14 -yscroll "$w.vsb set"
   ttk::scrollbar $w.vsb -orient vertical -command ".msummary.tree yview"
   grid $w.tree $w.vsb -sticky nsew
   foreach col {trk chn program notes activity pavg duration} {
     $w.tree heading $col -text $col
     $w.tree heading $col -command [list Tinfo_SortBy $col 0]
     $w.tree column $col -width [expr [font measure $df $col] + 13]
     }
   $w.tree column program -width [font measure $df "WWWWWWWWWWWWWWWWWW"]
   $w.tree column notes -width [font measure $df "WWWWWW"]
   $w.tree tag configure fnt -font $df

   bind $w.tree <<TreeviewSelect>> {midisummary_selected}

   set w .msummary.limits
   frame $w
   label $w.lab1 -text "start beat" -font $df
   label $w.lab2 -text "end beat" -font $df
   scale $w.start -from 0 -to 1000 -length 180 -font $df -orient horizontal\
   -width 5 -variable midi(beat1) -command beat1_changed
   scale $w.end   -from 0 -to 1000 -length 180 -font $df -orient horizontal\
   -width 5 -variable midi(beat2) -command beat2_changed
   pack $w.lab1 $w.start $w.lab2 $w.end -side left
   pack $w -side top
  

   set w .msummary.bot
   frame $w
   label $w.name -text "file name" -font $df
   label $w.size -text "file size" -font $df
   pack $w.name $w.size -side top
   pack $w
   }
   midisummary::summarize_midi_file
 }

proc beat1_changed {val} {
global beat1entry
set beat1entry $val
beat_cmd 2
}

proc beat2_changed {val} {
global beat2entry
set beat2entry $val
beat_cmd 2
}


proc update_midi_summary {} {
if {[winfo exist .msummary]} midisummary::summarize_midi_file
if {[winfo exists .pgram]} pgram_window
}

  

set mlist {"0 Acoustic Grand" "1 Bright Acoustic" "2 Electric Grand" "3 Honky-Tonk"
"4 Electric Piano 1" "5 Electric Piano 2" "6 Harpsichord" "7 Clav"
" 8 Celesta" " 9 Glockenspiel" "10 Music Box" "11 Vibraphone"
"12 Marimba" "13 Xylophone" "14 Tubular Bells" "15 Dulcimer"
"16 Drawbar Organ" "17 Percussive Organ" "18 Rock Organ" "19 Church Organ"
"20 Reed Organ" "21 Accordian" "22 Harmonica" "23 Tango Accordian"
"24 Acoustic Guitar (nylon)" "25 Acoustic Guitar (steel)" "26 Electric Guitar (jazz)" "27 Electric Guitar (clean)"
"28 Electric Guitar (muted)" "29 Overdriven Guitar" "30 Distortion Guitar" "31 Guitar Harmonics"
"32 Acoustic Bass" "33 Electric Bass (finger)" "34 Electric Bass (pick)" "35 Fretless Bass"
"36 Slap Bass 1" "37 Slap Bass 2" "38 Synth Bass 1" "39 Synth Bass 2"
"40 Violin" "41 Viola" "42 Cello" "43 Contrabass"
"44 Tremolo Strings" "45 Pizzicato Strings" "46 Orchestral Strings" "47 Timpani"
"48 String Ensemble 1" "49 String Ensemble 2" "50 SynthStrings 1" "51 SynthStrings 2"
"52 Choir Aahs" "53 Voice Oohs" "54 Synth Voice" "55 Orchestra Hit"
"56 Trumpet" "57 Trombone" "58 Tuba" "59 Muted Trumpet"
"60 French Horn" "61 Brass Section" "62 SynthBrass 1" "63 SynthBrass 2"
"64 Soprano Sax" "65 Alto Sax" "66 Tenor Sax" "67 Baritone Sax"
"68 Oboe" "69 English Horn" "70 Bassoon" "71 Clarinet"
"72 Piccolo" "73 Flute" "74 Recorder" "75 Pan Flute"
"76 Blown Bottle" "77 Skakuhachi" "78 Whistle" "79 Ocarina"
"80 Lead 1 (square)" "81 Lead 2 (sawtooth)" "82 Lead 3 (calliope)" "83 Lead 4 (chiff)"
"84 Lead 5 (charang)" "85 Lead 6 (voice)" "86 Lead 7 (fifths)" "87 Lead 8 (bass+lead)"
"88 Pad 1 (new age)" "89 Pad 2 (warm)" "90 Pad 3 (polysynth)" "91 Pad 4 (choir)"
"92 Pad 5 (bowed)" "93 Pad 6 (metallic)" "94 Pad 7 (halo)" "95 Pad 8 (sweep)"
" 96 FX 1 (rain)" " 97 (soundtrack)" " 98 FX 3 (crystal)" " 99 FX 4 (atmosphere)"
"100 FX 5 (brightness)" "101 FX 6 (goblins)" "102 FX 7 (echoes)" "103 FX 8 (sci-fi)"
"104 Sitar" "105 Banjo" "106 Shamisen" "107 Koto"
"108 Kalimba" "109 Bagpipe" "110 Fiddle" "111 Shanai"
"112 Tinkle Bell" "113 Agogo" "114 Steel Drums" "115 Woodblock"
"116 Taiko Drum" "117 Melodic Tom" "118 Synth Drum" "119 Reverse Cymbal"
"120 Guitar Fret Noise" "121 Breath Noise" "122 Seashore" "123 Bird Tweet"
"124 Telephone ring" "125 Helicopter" "126 Applause" "127 Gunshot"
}


proc Tinfo_SortBy {col direction} {
    set data {}
    foreach row [.msummary.tree children {}] {
        lappend data [list [.msummary.tree set $row $col] $row]
    }

    set dir [expr {$direction ? "-decreasing" : "-increasing"}]
    set r -1



    # Now reshuffle the rows into the sorted order
    foreach info [lsort -dictionary -index 0 $dir $data] {
        .msummary.tree  move [lindex $info 1] {} [incr r]
    }
    # Switch the heading so that it will sort in the opposite direction
    .msummary.tree heading $col -command [list Tinfo_SortBy  $col [expr {!$direction}]]
}


proc midisummary_selected {} {
global ntrks midi
if {![winfo exist .msummary]} return
set indices [.msummary.data.tree selection]
set midi(midichannels) ""
set midi(miditracks) ""
set k 0
foreach i $indices {
  set iline [.msummary.data.tree item $i -values]
  if {$ntrks == 1} {
    if {$k == 0} {
	 append midi(midichannels) [lindex $iline 1]
    } else {
         append midi(midichannels) ","
	 append midi(midichannels) [lindex $iline 1]
    }
       
    channel_cmd 2
    .midi2abc.10.trkent configure -state disable
    set midi(trk_method) 1
    set midi(miditracks) ""
    }  else {
    track_cmd 2 
    .midi2abc.5.chanent configure -state disable
    set midi(chan_method) 1
    set midi(midichannels) ""
    if {$k == 0} {
      append midi(miditracks) [lindex $iline 0]
    } else {
      append midi(miditracks) ","
      append midi(miditracks) [lindex $iline 0]
      }
    }
  incr k
  }
if {[llength $indices] < 1} {
  channel_cmd 1
  track_cmd 1
  }
#  puts "midisummary_selected:"
#  puts "midi(midichannels) = $midi(midichannels)"
#  puts "midi(miditracks) = $midi(miditracks)"
update_displayed_pdf_windows_for_summary 
}



proc normalize_activity {vector} {
set fnorm 0.0
if {[llength $vector] < 1} {return vector}
foreach pc $vector {
  set pc [expr double($pc)]
  set fnorm [expr $fnorm + ($pc*$pc)]
  }
set fnorm [expr sqrt($fnorm)]
set nvector [list]
foreach pc $vector {
  lappend nvector [expr $pc/$fnorm]}
return $nvector
}

proc normalize_vectorlist {vector} {
set fnorm 0.0
if {![info exist vector]} {
  puts $outhandle "damaged data"
  puts $outhandle "file [list $midifile]"
  return
  }
foreach pc $vector {
  set fnorm [expr $fnorm + ($pc*$pc)]
  }
set fnorm [expr sqrt($fnorm)]
if {$fnorm < 0.01} {set fnorm 0.01}
set dim [llength $vector]
for {set i 0} {$i < $dim} {incr i} {
  set p [lindex $vector $i]
  set p [expr $p/$fnorm]
  set p [format "%6.3f" $p]
  lappend pcolor [lindex $p 0]
  }
return $pcolor
}


proc show_pianoroll {} {
    global midi
    global trksel
    global ntrks
    copy_midi_to_tmp 0
    if {$ntrks > 1} {
    set midi(midishow_sep) track
    #set trksel(1) 1
    } else {
    set midi(midishow_sep) chan
    foreach ind $midi(midichannels) {
      set trksel($ind) 1
      }
    }
    piano_window tmp.mid
}    

proc midi_statistics {choice} {
# derived from pianoroll_statistics
    global pianoresult midi
    global histogram
    global ppqn
    global total
    global exec_out
    global midi

    copy_midi_to_tmp 1

    set cmd "exec [list $midi(path_midi2abc)] tmp.mid -midigram"
    catch {eval $cmd} pianoresult
    #set exec_out "copy $midi(midifilein) to tmp.mid\n\n$cmd\n\n $pianoresult"
    update_console_page


    for {set i 0} {$i < 128} {incr i} {set histogram($i) 0}

    
    foreach line [split $pianoresult \n] {
        if {[llength $line] != 6} continue
        set begin [lindex $line 0]
        set end [lindex $line 1]
        set t [lindex $line 2]
        set c [lindex $line 3]
        set note [lindex $line 4]
        set vel [lindex $line 5]
        switch $choice {
            pitch {set histogram($note) [expr $histogram($note)+1]}
            velocity {set histogram($vel) [expr $histogram($vel)+1]}
            duration {set index [expr int(($end - $begin)*32/$ppqn)]
                if {$index > 127} {set index 127}
                set histogram($index) [expr $histogram($index)+1]
            }
            onset {set s [expr int((100.0*$begin)/$ppqn) % 100]
                set histogram($s) [expr $histogram($s) + 1]
                }
        }
    }
    set total 0;
    for {set i 0} {$i <128} {incr i} {
        set total [expr $total+$histogram($i)]
    }
    if {$total < 1} return
    for {set i 0} {$i <128} {incr i} {
        set histogram($i) [expr double($histogram($i))/$total]
    }
}

namespace eval midisummary {

# the name space defines the procedures
# in order to avoid conflicts with global variables
# summarize_midi_file
# present_midi_info 
# grab_all_program_commands 
# get_midi_info_for
# parse_midi_info {midi_info} 
# get_trkinfo {channel nnotes nharmony pmean duration token} 
# midi_type0_table
# midi_type1_table 
#
# The code was borrowed from midiexplorer.tcl

 variable trkinfo
 global xchannel2program
 variable channel2program
 variable channel_activity

 proc summarize_midi_file {} {
  global midi
  global ntrks
  global npulses
  global ppqn
  set midi_info [get_midi_info_for]
  if {[string length $midi_info] < 1} return
  set size [file size $midi(midifilein)]
  if {$midi_info == ""} return
  parse_midi_info $midi_info
  set nbeats [expr $npulses/$ppqn]
  present_midi_info
  .msummary.bot.name configure -text $midi(midifilein)
  .msummary.bot.size configure -text "file size $size bytes: \t$nbeats quarter notes \tppqn: $ppqn"
  .msummary.limits.start configure -to $nbeats
  .msummary.limits.end configure -to $nbeats
  set midi(beat1) 0
  set midi(beat2) $nbeats
 } 

 proc grab_all_program_commands {} {
# Determine xchannel2program -the channel to program mapping. 
# Some type 1 midi files define all the program
# assignments in a separate track (eg last track).
# As a precaution we look for the program commands
# separately rather than rely on trkinfo
 global ntrks
 variable trkinfo
 global xchannel2program
 for {set i 0} {$i < 17} {incr i}  {set xchannel2program($i) 0}
 for {set i 1} {$i <= $ntrks} {incr i} {
   foreach token $trkinfo($i) {
      if {[lindex $token 0] == "program"} {
        set c [lindex $token 1]
        set p [lindex $token 2]
        set xchannel2program($c) $p
        }
   }
 }
 }

 proc present_midi_info {} {
   global midi
   global ntrks
   grab_all_program_commands
   if {$ntrks == 0} return
    
   if {$ntrks == 1} {
      midi_type0_table
      } else {
      midi_type1_table
      }
 }

 proc get_midi_info_for {} {
 global midi_info midi exec_out
 global midilength
 global exec_out
 set midilength 0
 set fileexist [file exist $midi(midifilein)]
 if {$fileexist} {
   set exec_options "[list $midi(midifilein) -stats]"
   set cmd "exec [list $midi(path_midi2abc)] $exec_options"
   catch {eval $cmd} midi_info
   set exec_out $cmd\n$midi_info
   update_console_page
   return $midi_info
   } else {
   set msg "Unable to find file $midi(midifilein). Use the browse \
   button to select the active midi file."
   show_message_page $msg word
   return ""
   }
 }


 proc parse_midi_info {midi_info} {
 global ntrks
 variable trkinfo
 global ppqn
 global npulses
 variable channel_activity
 global midierror
 global useflats
 array unset trkinfo
 set midierror ""
 set ntrks 0
 set npulses 0
 foreach line [split $midi_info '\n'] {
   #puts $line
   set trk 0
   #remove any embedded double quotes and braces if present
   set line [string map {\" {} \{ {} \} {}} $line]
   set info_id [lindex $line 0] 
   switch $info_id {
     ntrks {set ntrks [lindex $line 1]}
     ppqn {set ppqn [lindex $line 1]}
     npulses {set npulses [lindex $line 1]}
     tsignature {set tsignature [lindex $line 1]}
     trk {set t [lindex $line 1]
          set trkinfo($t) ""}
     progcolor {set cprogcolor [lrange $line 1 end]
                set cprogcolor [normalize_vectorlist $cprogcolor]
               }
     pitchact {set pitchcl [lrange $line 1 end]
               set pitchcl [normalize_vectorlist $pitchcl]
               }
     chnact   {set channel_activity [lrange $line 1 end]}
     progs {set cprogs [lrange $line 1 end]}
     progsact {set cprogsact [lrange $line 1 end]}
     Error: {set problem [lrange $line 1 end]
             set midierror  "defective file : $problem\t"
            }
     activetrack {set ntrks [lindex $line 1]
                  append midierror "only $ntrks valid tracks"}
     default {if {[info exist t]} {lappend trkinfo($t) $line }}
     }
  }
  set flats [expr [lindex $pitchcl 3] + [lindex $pitchcl 10]]
  set sharps [expr [lindex $pitchcl 1] + [lindex $pitchcl 6]]
  set useflats 0
  if {$flats > $sharps} {set useflats 1}
  set cprogsact [normalize_activity $cprogsact]
  return 0
 }




 proc get_trkinfo {channel nnotes nharmony pmean duration token} {
  global ppqn
  upvar 1 $channel c
  upvar 1 $nnotes n
  upvar 1 $nharmony h
  upvar 1 $pmean pavg
  upvar 1 $duration dur
  set c [lindex $token 1]
  set n [lindex $token 3]
  set h [lindex $token 4]
  set pavg [lindex $token 5]
  set pavg [expr $pavg/($n +$h)]
  set dur [lindex $token 6]
  set dur [expr $dur / ($n + $h)]
  set dur [expr double($dur) / $ppqn]
  set dur [format %5.3f $dur]
 }



 proc midi_type0_table {} {
 variable trkinfo
 global mlist
 global midi
 variable channel2program
 global xchannel2program
 variable channel_activity

 set w .msummary.data
 $w.tree delete [$w.tree children {}]
 set trknum 1

 set nlines 0
 foreach token $trkinfo(1) {
   if {[lindex $token 0] == "trkinfo"} {
     get_trkinfo channel nnotes nharmony pmean duration $token
     set totalnotes [expr $nnotes+$nharmony]
#    set channel2program($channel) $xchannel2program($channel)
     set chan_action [lindex $channel_activity [expr $channel -1]]
     if {$channel == 10} {
       set prog [list drum channel]
     } else {
       set prog $xchannel2program($channel)
       set prog [lindex $mlist $prog]
     }
     set outline "$trknum $channel [list $prog ]"
     append outline " $totalnotes/$nnotes $chan_action $pmean $duration"
     set id [$w.tree insert {} end -values $outline -tag fnt]
     incr nlines
     }
   }
   $w.tree configure -height $nlines
 }

 proc midi_type1_table {} {
 variable trkinfo
 global mlist
 global midi
 variable channel2program
 global xchannel2program
 variable channel_activity
 global ntrks
 set w .msummary.data
 $w.tree delete [$w.tree children {}]
 
 set nlines 0
 for {set i 1} {$i <= $ntrks} {incr i} {
   foreach token $trkinfo($i) {
     if {[lindex $token 0] == "trkinfo"} {
       get_trkinfo channel nnotes nharmony pmean duration $token
       set totalnotes [expr $nnotes+$nharmony]
       set chan_action [lindex $channel_activity [expr $channel -1]]
       set channel2program($channel) $xchannel2program($channel)
       if {$channel == 10} {
         set prog "drum channel"
       } else {
         set prog $xchannel2program($channel)
         set prog [lindex $mlist $prog]
       }
        set outline "$i $channel [list $prog ]"
       append outline " $totalnotes/$nnotes $chan_action $pmean $duration"
       set id [$w.tree insert {} end -values $outline -tag fnt]
       incr nlines
       }
    }
   }
 $w.tree configure -height $nlines
 }
} 
#end of namespace midisummary

# Part 43.0               Notegram


set gramwidth 500


proc best_grid_spacing {x} {
# Given the scale range, x, it returns
# the grid spacing to get 8 to 4 tick marks.
 set divlist {2 2 1.25 2}
 set i 0
 set n 1
 while {$i < 20} {
   incr i
   set j [expr $i % 4] 
   set d [lindex $divlist $j]
   set n [expr $n * $d]
   set q [expr $x/$n]
   if {$q <8} break
   if {$q <4} break
   }
 return $n
}

proc notegram_plot {} {
   global gramwidth
   global midi
   global df
   if {![winfo exist .notegram]} {
     toplevel .notegram
     position_window .notegram
     frame .notegram.head
     radiobutton .notegram.head.1 -text sequential -variable midi(notegram) -value seq -font $df -command compute_notegram
     radiobutton .notegram.head.2 -text "circle of fifths" -variable midi(notegram) -value fifths -font $df -command compute_notegram
     pack  .notegram.head.1 .notegram.head.2 -side left -anchor w
     pack  .notegram.head -side top -anchor w 
     set c .notegram.can
     canvas $c -width $gramwidth -height 250 -border 3 -relief sunken
     pack $c
     }
   if {[winfo exist .piano]} {compute_piano_notegram
   } else {
   compute_notegram
   }
}


proc compute_notegram {} {
   global gramwidth
   global pianoresult
   global lastbeat
   set sharpnoteslist  {C C# D D# E F F# G G# A A# B}
   set flatnoteslist   {C Db D Eb E F Gb G Ab A Bb B}
   set sharpnotes5list {C G D A E B F# C# G# D# A# F}
   set flatnotes5list  {C G D A E B Gb Db Ab Eb Bb F}
   global ppqn
   global midi
   global fbeat
   global tbeat
   set permut5th {0 7 2 9 4 11 6 1 8 3 10 5}
   array set pitchcount {0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0}
   copy_midi_to_tmp 1
   set cmd "exec [list $midi(path_midi2abc)] tmp.mid -midigram"
   catch {eval $cmd} pianoresult
   set exec_out [append exec_out "notegram:\n\n$cmd\n\n $pianoresult"]
   # useflats is set by plot_pitch_class_histogram
   set xrbx [expr $gramwidth - 3]
   set xlbx  40
   set ytbx 20
   set ybbx 220 
   set c .notegram.can
   $c delete all
   set start 0
   if {$tbeat == 0} {set tbeat $lastbeat}
   $c create rectangle $xlbx $ybbx $xrbx $ytbx -outline black -width 2 -fill lightgrey 
   Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx $fbeat $tbeat 0.0 200.0 
   foreach line [split $pianoresult \n] {
     if {[llength $line] != 6} continue
     set begin [lindex $line 0]
     set end [lindex $line 1]
     set t [lindex $line 2]
     set channel [lindex $line 3]
     if {$channel == 10} continue
     set note [lindex $line 4]
     set note [expr $note % 12]
     incr pitchcount($note)
     if {$midi(notegram) == "fifths"} {
        set loc [lindex $permut5th $note]
     } else {set loc $note}
     set ix [Graph::ixpos [expr $fbeat + double($begin)/$ppqn]]
     set iy [Graph::iypos [expr double($loc*16) + 7 ]]
     set iy1 [expr $iy - 3]
     set iy2 [expr $iy + 3]
     set ix1 [expr $ix - 3]
     set ix2 [expr $ix + 3]
     $c create oval $ix1 $iy1 $ix2 $iy2 -fill black
     }
  set flats [expr $pitchcount(3) + $pitchcount(10)]
  set sharps [expr $pitchcount(1) + $pitchcount(6)]
  set useflats 0
  if {$flats > $sharps} {set useflats 1}
  set i 0
  set ix 15 
  if {$midi(notegram) == "fifths"} {
    if {$useflats} {
      foreach name $flatnotes5list {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      } else {
      foreach name $sharpnotes5list {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
     }
   } else {
    if {$useflats} {
      foreach name $flatnoteslist {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      } else {
      foreach name $sharpnoteslist {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      }
   }
    set start5 0
    if {$fbeat != 0} {set start5 [expr (1 + int($fbeat)/5)*5.0]}
    set spacing [best_grid_spacing [expr ($tbeat - $fbeat)]]
    Graph::draw_x_grid $c $start5 $tbeat $spacing 1  0 %5.0f
}

proc compute_piano_notegram {} {
   global gramwidth
   global pianoresult
   global lastbeat
   global trksel
   global ppqn
   global midi
   set sharpnoteslist  {C C# D D# E F F# G G# A A# B}
   set flatnoteslist   {C Db D Eb E F Gb G Ab A Bb B}
   set sharpnotes5list {C G D A E B F# C# G# D# A# F}
   set flatnotes5list  {C G D A E B Gb Db Ab Eb Bb F}
   set permut5th {0 7 2 9 4 11 6 1 8 3 10 5}
   array set pitchcount {0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0}
   set limits [midi_limits]
   set start [expr [lindex $limits 0]/$ppqn]
   set stop  [expr [lindex $limits 1]/$ppqn]
   set tsel [count_selected_midi_tracks]
   #puts "compute_piano_notegram:"

   set xrbx [expr $gramwidth - 3]
   set xlbx  40
   set ytbx 20
   set ybbx 220 
   set c .notegram.can
   $c delete all
   $c create rectangle $xlbx $ybbx $xrbx $ytbx -outline black -width 2 -fill lightgrey 
   Graph::alter_transformation $xlbx $xrbx $ybbx $ytbx $start $stop 0.0 200.0 
   foreach line [split $pianoresult \n] {
     if {[llength $line] != 6} continue
     set begin [expr [lindex $line 0]/$ppqn]
     if {[string is double $begin] != 1} continue
     if {$begin < $start} continue
     set end [expr [lindex $line 1]/$ppqn]
     if {$end > $stop} continue
     set t [lindex $line 2]
     set channel [lindex $line 3]
     if {$midi(midishow_sep) == "track"} {set sep $t} else {set sep $channel}
     if {$tsel != 0 && $trksel($sep) == 0} continue
     if {$channel == 10} continue

     set note [lindex $line 4]
     set note [expr $note % 12]
     incr pitchcount($note)
     if {$midi(notegram) == "fifths"} {
        set loc [lindex $permut5th $note]
     } else {set loc $note}
     set ix [Graph::ixpos $begin]
     set iy [Graph::iypos [expr double($loc*16) + 7 ]]
     set iy1 [expr $iy - 3]
     set iy2 [expr $iy + 3]
     set ix1 [expr $ix - 3]
     set ix2 [expr $ix + 3]
     $c create oval $ix1 $iy1 $ix2 $iy2 -fill black
     }
  set flats [expr $pitchcount(3) + $pitchcount(10)]
  set sharps [expr $pitchcount(1) + $pitchcount(6)]
  set useflats 0
  if {$flats > $sharps} {set useflats 1}
  set i 0
  set ix 15 
  if {$midi(notegram) == "fifths"} {
    if {$useflats} {
      foreach name $flatnotes5list {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      } else {
      foreach name $sharpnotes5list {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
     }
   } else {
    if {$useflats} {
      foreach name $flatnoteslist {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      } else {
      foreach name $sharpnoteslist {
         set iy [Graph::iypos [expr double($i * 16)]] 
         set iy [expr $iy - 5]
         $c create text $ix $iy -text $name 
         incr i
         }
      }
   }
    set start5 0
    if {$start != 0} {set start5 [expr (1 + int($start)/5)*5.0]}
    set spacing [best_grid_spacing [expr ($stop - $start)]]
    Graph::draw_x_grid $c $start5 $stop $spacing 1  0 %5.0f
}

# end of Notegram


# Part 44.0               Midistructure

set hlp_midistructure "Different voices in the midi file tend\
to enter or leave at times when the melody changes in the song. This\
diagram plots the position of the notes in each track (or channel)\
color coded by the type of musical instrument. For example\
the keyboard instruments like the piano and harpsicord are represented\
in blue, the electric guitar are shown in orange, the brass instruments\
are shown in yellow and etc. The 128 music instruments (MIDI programs)\
are grouped into 16 classes. When a group of notes are close together in\
time, they will appear as a horizontal bar. \n\n\

Positioning the mouse pointer in one of the bars will cause it\
to be highlighted in red. A line in the lower part of the plot\
will indicate the channel number and the mapping to the MIDI program.\
Like the piano roll, you can designate an area in time for future\
study by sweeping the mouse pointer inside the diagram while\
holding the left mouse button down. This is similar to a drag\
and drop operation. The selected area will be shown with a yellow\
stipple. Double clicking on a particular spot will clear this\
designated area. If you click on one of the play buttons on top\
then only that specific region will be played. You can also\
select particular channels or tracks using the radio buttons\
on the left column. If none are selected, then all channels\
or tracks are assumed.\n\n\

The three play buttons in the top menu bar, provide different\
ways of playing the midi file. If specific channels or tracks\
are checked, then the play button will play the midi file or\
specified part of the midi file with those channels (tracks)\
enhanced relative to the other channels. If the splay button\
is pressed, then only the specified channels will be played.\
If the xplay button is pressed, then all the channels except for\
the checked channels will be played. The speed slider allows\
you to speed up or slow down the music in the playback.\n\n\

The program actually creates a temporary midi file with a\
random 8 letter name beginning with x containing the desired\
music. This file is automatically deleted during cleanup.\
Clicking the save button allows you to copy this file for\
future analysis and give it a more meaningful name.
"



set midistructurewidth 400

proc midi_structure_display {} {
   load_midifile
   midi_structure_window 
}

proc mstruct_update_displayed_pdf_windows {} {
channelstracks_to_midi
if {[winfo exists .pitchpdf]} {
   midi_statistics pitch
   plotmidi_pitch_pdf
   }
if {[winfo exists .pitchclass]} {
   midi_statistics pitch
   show_note_distribution
   }
if {[winfo exists .velocitypdf]} {
   midi_statistics velocity
   plotmidi_velocity_pdf
   }
if {[winfo exists .onsetpdf]} {
   midi_statistics onset
   plotmidi_onset_pdf
   }
if {[winfo exists .durpdf]} {
   midi_statistics duration
   plotmidi_duration_pdf
   }
if {[winfo exists .midivelocity]} {
   plot_velocity_map
   }
if {[winfo exists .pgram]} {
   pgram_window 
   }
}


proc set_preferences {} {
global df
global midi
set w .preferences
if {[winfo exist $w]} {
  raise $w .
  return
  }
toplevel $w
position_window $w
label $w.lab5 -text "attenuation" -font $df
entry $w.attent -width 2 -textvariable midi(attenuation) -font $df
grid $w.lab5 $w.attent 
radiobutton $w.trk -text "separate by track" -font $df\
          -value track -variable midi(midishow_sep) -value track\
          -command show_prog_structure
grid $w.trk  -sticky nw
radiobutton $w.chn -text "separate by channel" -font $df\
          -value chan -variable midi(midishow_sep) -value channel\
          -command show_prog_structure
grid $w.chn  -sticky nw

}

proc midi_structure_window {} {
  global ntrk df
  global midi
  global midichannels
  global miditracks
  global highlighted_segment
  global chosen_segment
  global midistructurewidth
  global xstrpick ystrpick
  global midispeed

  set w .midistructure
  if {[winfo exist $w]} {
    raise $w .
    show_prog_structure
    return
    }
  toplevel $w
  position_window $w
  set entrywidth [expr int(800/double($midi(font_size)))]
  set wm $w.menuline
  frame $wm


  button $wm.config -text config -font $df -width 7 -relief flat \
   -command {set_preferences}
  tooltip::tooltip $wm.config "Separate by tracks or channels and adjust attenuation"

  button $wm.play -text play -font $df -command focus_and_play
  tooltip::tooltip $wm.play "If any channels or tracks are checked\n on the left,\
 they will be accentuated by\n attenuating the remaining channels or\n tracks when\
 played." 
  button $wm.plays -text splay -font $df -command play_selected_lines
  tooltip::tooltip $wm.plays "Only the specified channels or\n tracks checked on \
the left\n will be played. If nothing is\n checked, everything is played."

  button $wm.playx -text xplay -font $df -command play_and_exclude_selected_lines
  tooltip::tooltip $wm.playx "The specified channels or tracks\n are not played.\
 If nothing is checked,\neverything is played" 
  label $wm.speedlabel -text speed -font $df
  scale $wm.speed -length 140 -from 0.1 -to 4.0 -orient horizontal\
     -resolution 0.05 -width 10 -variable midispeed -font $df
  set midispeed 1.0

  button $wm.save -text save -font $df -command save_temporary_midi_file
  tooltip::tooltip $wm.save "Save the last temporary\n midi file you created"

  button $wm.help -text help -font $df -command {show_message_page $hlp_midistructure word}

  entry $w.fileinent -width $entrywidth -textvariable midi(midifilein) -font $df\
    -state readonly 
  label $w.txt -text ""
  label $w.beat -text beat -font $df
  $w.fileinent xview moveto 1.0
  bind $w.fileinent <Return> {focus .midistructure.file}
  grid $w.fileinent -columnspan 2
  pack  $wm.config $wm.play $wm.plays $wm.playx $wm.speedlabel $wm.speed $wm.save $wm.help -side left
  grid $wm -columnspan 2 -sticky nw
    

  set f [frame $w.leftbuttons -bd 3 -relief sunken]
  for {set i 2} {$i <40} {incr i} {
    checkbutton .midistructure.leftbuttons.$i -text "trk$i" -variable miditracks($i) -font $df -command mstruct_update_displayed_pdf_windows
    }
  for {set i 0} {$i <17} {incr i} {
    checkbutton .midistructure.leftbuttons.c$i -text "chan$i" -variable midichannels($i) -font $df -command mstruct_update_displayed_pdf_windows
    }
  set yspacing [winfo reqheight .midistructure.leftbuttons.2]
  canvas $w.can -width $midistructurewidth -height 200 -border 3 -relief sunken
  canvas $w.canx -width $midistructurewidth -height 20  -border 3 -relief sunken
  grid $w.leftbuttons $w.can -sticky news
  grid $w.beat $w.canx -sticky news
  grid $w.txt -column 1


    bind .midistructure.can <ButtonPress-1> {mstruct_Button1Press %x %y}
    bind .midistructure.can <ButtonRelease-1> {mstruct_Button1Release}
    bind .midistructure.can <Double-Button-1> mstruct_ClearMark


   show_prog_structure
}



proc mstruct_Button1Press {x y} {
    global midistructureheight
    set xc [.midistructure.can canvasx $x]
    .midistructure.can raise mark
    .midistructure.can coords mark $xc 0 $xc $midistructureheight
    bind .midistructure.can <Motion> { mstruct_Button1Motion %x }
}

proc mstruct_Button1Motion {x} {
    global midistructureheight
    set xc [.midistructure.can canvasx $x]
    #puts "mstruct_Button1Motion $xc"
    if {$xc < 0} { set xc 0 }
    set co [.midistructure.can coords mark]
    .midistructure.can coords mark [lindex $co 0] 0 $xc $midistructureheight
}

proc mstruct_Button1Release {} {
    bind .midistructure.can <Motion> {}
    set co [.midistructure.can coords mark]
    mstruct_update_displayed_pdf_windows
    midistruct_limits .midistructure.can
    }

proc mstruct_ClearMark {} {
    .midistructure.can coords mark -1 -1 -1 -1
    midistruct_limits .midistructure.can
}

proc midistruct_limits {can} {
# limits of selected region in midistructure
    global pixels_per_beat
    global midi
    global lastbeat
    set co [$can coords mark]
    #   is there a marked region of reasonable extent ?
    set extent [expr [lindex $co 2] - [lindex $co 0]]
    if {$extent > 5} {
        set xleft [expr [lindex $co 0]/$pixels_per_beat]
        set xright [expr [lindex $co 2]/$pixels_per_beat]
	set midi(beat1) $xleft
	set midi(beat2) $xright
        #puts "midistruct_limits: $xleft $xright beats"
	return "$xleft $xright"
    } else {
        set midi(beat1) 0
        set midi(beat2) $lastbeat
        #puts "midistruct_limits: none"
        return none}
}


set progmapper {
 0  0  0  0  0  0  0  0 
 0  1  1  1  1  1  1  2
 3  3  3  3  3  3  3  3
 2  2  4  4  4  4  4  2 
 5  5  5  5  5  5  5  5 
 6  6  6  6  6  2  7 10 
 7  7  7  7  8  8  8  8 
 9  9  9  9  9  9  9  9 
11 11 11 11 11 11 11 11
12 12 12 12 12 12 12 12
13 13 13 13 13 13 13 13
14 14 14 14 14 14 14 14 
15 15 15 15 15 15 15 15 
 2  2  2  2  2 12  6 12 
 1  1 10 10 10 10 10  1 
16 16 16 16 16 16 16 16 
}


set groupcolors {{medium blue}
                 Dodgerblue4
                 orange3
                 {chartreuse}
                 {orange red}
                 {indian red}
                 {blue violet}
                 magenta4
                 {deep pink}
                 yellow
                 gray30
                 green4
                 turquoise
                 firebrick
                 sienna4
                 maroon
                 {dodger blue}
                 {slate gray}
                 }


set groupnames { "piano keyboard"
                 "xylophone category"
                 "acoustic guitar category"
                 "organ class"
                 "electric guitar set"
                 "electric bass set"
                 "solo strings (eg. violin)"
                 "string ensembles"
                 "choir"
                 "brass"
                 "drum class"
                 "woodwind"
                 "flute category"
                 "lead class"
                 "pad class"
                 "FX class"
                 "Banjo class"
                 "electronic synthesizer"
                }


proc show_prog_structure {} {
  global midi
  global lastbeat
  global midistructurewidth
  global midistructureheight
  global chanprog
  global xchannel2program
  global track2program
  global pixels_per_beat
  global yspacing
  global progmapper
  global groupcolors
  global df
  global pianoresult
  global chn2prg
  global lastbeat
  global ntrks

  if {![winfo exist .midistructure]} return


  set cmd "exec [list $midi(path_midi2abc)] [list $midi(midifilein)] -midigram"
  catch {eval $cmd} pianoresult
  set pianoresult  [split $pianoresult \n]
  scan [lindex $pianoresult 0] "Header %d %d %d" miditype ntrks ppqn

  set nrec [llength $pianoresult]
  set midilength [lindex $pianoresult [expr $nrec -1]]
  set lastbeat [expr $midilength/$ppqn]
  set sorted_pianoresult [lsort -command compare_onset $pianoresult]

  if {$midi(midishow_sep) == "track" && $ntrks == 1} {
     .midistructure.txt configure -text "Type 0 midi file. Cannot separate by track" -foreground red
     set midi(midishow_sep) "channel"
     }

  if {[array exist track2channel]} {unset track2channel}
  if [info exist activechan] { unset activechan }
  if [info exist activetrk] {unset activetrk}
  foreach line $sorted_pianoresult {
      if {[llength $line] != 6} continue
      set t [lindex $line 2]
      set c [lindex $line 3]
      set track2channel($t) $c
      set activetrk($t) 1
      set activechan($c) 1
      }

  set nbut 0
  .midistructure.can delete all
  .midistructure.canx delete all
  for {set i 2} {$i < 32} {incr i} {pack forget .midistructure.leftbuttons.$i}
  for {set i 1} {$i < 17} {incr i} {pack forget .midistructure.leftbuttons.c$i}
  if {$midi(midishow_sep) == "track"} {
    for {set i 2} {$i < 32} {incr i} {
       if {[info exist activetrk($i)]} {
         pack .midistructure.leftbuttons.$i -side top
         # ct2band maps track/channel to button band
         incr nbut
         set ct2band($i) $nbut
         }
       }
  } else {
    for {set i 0} {$i < 17} {incr i} {
       if {[info exist activechan($i)]} {
         pack .midistructure.leftbuttons.c$i -side top
	 if {![info exist ct2band($i)]} {
           incr nbut
           set ct2band($i) $nbut
           }
       }
    }
  }
  set yspacing [winfo reqheight .midistructure.leftbuttons.2]
  .midistructure.can create rect -1 -1 -1 -1 -tags mark -fill yellow -stipple gray25


  set yspacing [winfo reqheight .midistructure.leftbuttons.2]
  set midistructureheight [expr $nbut * $yspacing + 3]
  .midistructure.can configure -height [expr $nbut * $yspacing]
  for {set i 1} {$i <  $nbut } {incr i} {
    set y [expr $yspacing*$i]
    .midistructure.can create line 1 $y 399 $y -dash {1 2}
    }


  set pixels_per_beat [expr double($midistructurewidth)/$lastbeat]
  set xspacing [best_grid_spacing $lastbeat]
  set x  0
  while {$x < $lastbeat} {
    set x  [expr $x + $xspacing]
    set x1 [expr $x * $pixels_per_beat]
    .midistructure.can create line $x1 0 $x1 [expr $nbut*$yspacing] -dash {1 2}
    .midistructure.canx create text $x1 15 -text $x -font $df
    }

  set taglist {}

  foreach line $sorted_pianoresult {
     set begin [lindex $line 0]
     set end [lindex $line 1]
     if {[llength $line] == 6} {
       set begin [expr $begin/$ppqn]
       set end [expr [lindex $line 1]/$ppqn]
       set t [lindex $line 2]
       set c [lindex $line 3]
       if {$c == 10} {
         set kolor black
       } else {
         if {[info exist chn2prg($c)]} {
            set p $chn2prg($c)
         } else {
            set p 0
         }
         set g [lindex $progmapper $p]
         set kolor [lindex $groupcolors $g]
       }
       set x1 [expr $begin*$pixels_per_beat]
       set x2 [expr $end*$pixels_per_beat]
       if {$midi(midishow_sep) == "track"} {
         set y [expr $ct2band($t) *$yspacing  - 14]
         } else {
         set y [expr $ct2band($c) *$yspacing  - 14]
         }
      set x1 [expr round($x1)-1]
      set x2 [expr round($x2) +1]
      set y [expr round($y)]
      if {$c != 10} {
        set tagname p$p
        set tagname c$c$tagname
        if {[lsearch $taglist $tagname] < 0} {lappend taglist $tagname}
        .midistructure.can create line $x1 $y $x2 $y -width 13 -tag $tagname -fill $kolor -activefill red
        } else {
	set tagname c$c
        if {[lsearch $taglist $tagname] < 0} {lappend taglist $tagname}
        .midistructure.can create line $x1 $y $x2 $y -width 13 -tag $tagname -fill $kolor
        }

      }
      if {$end == "Program"} {
	     set c [lindex $line 2]
	     set p [lindex $line 3]
             set chn2prg($c) $p 
	     set g [lindex $progmapper $p]
             }
    }
    #puts $taglist
    bind_midistructure_tags $taglist 
  }


proc bind_midistructure_tags {taglist} {
global mlist
foreach tagelem $taglist {
 scan $tagelem "c%dp%d" c p
 if {[info exist p]} {
   set msg "channel $c -> [lindex $mlist $p]"
   } else {
   set msg "channel $c -> percussion channel"
   }

 .midistructure.can bind $tagelem <Enter> "highlight_midistructure $tagelem %x %y"
# .midistructure.can bind $tagelem <Leave> "unhighlight_midistructure $tagelem %x %y"
 } 
}

proc highlight_midistructure {tag x y} {
global df
global mlist
scan $tag "c%dp%d" c p
if {$c != 10} {
     set msg "channel $c -> [lindex $mlist $p]"
    .midistructure.txt configure -text $msg -font $df -fg black
    #.midistructure.can itemconfigure $tag -fill red
    } else {
    .midistructure.txt configure -text "percussion channel" -font $df -fg black
    }
} 

proc unhighlight_midistructure {tag x y} {
global chn2prg
global progmapper
global groupcolors
global df
.midistructure.txt configure -text "" -font $df
scan $tag "c%dp%d" c p
if {$c == 10} return
set p $chn2prg($c)
set g [lindex $progmapper $p]
set kolor [lindex $groupcolors $g]
.midistructure.can itemconfigure $tag -fill $kolor
}

proc focus_and_play {} {
global trksel
global midi
global miditracks
global midichannels
global ntrks
global midispeed
global exec_out
set trkchn ""
set option ""
if {$midi(midishow_sep) == "track"} {
  for {set i 0} {$i <= $ntrks} {incr i} {
     if {$miditracks($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-attenuation $midi(attenuation) -focusontracks $trkchn"
         set option [string range $option 0 end-1]
         }
  } else {
  for {set i 0} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-attenuation $midi(attenuation) -focusonchannels $trkchn"}
         set option [string range $option 0 end-1]
  }
set limits [midistruct_limits .midistructure.can]
  if {$limits != "none"} {
         set fbeat [lindex $limits 0]
         set tbeat [lindex $limits 1]
         append option " -frombeat $fbeat -tobeat $tbeat"
    }

if {$midispeed != 1.00} {append option " -speed $midispeed"}
# We first delete the old temporary midi file
# in case windows is still playing it.
set cmd "file delete tmp.mid"
catch {eval $cmd} done
# create temporary file
if {[string length $option] > 0} {
  set cmd "exec [list $midi(path_midicopy)]  $option"
  lappend cmd  $midi(midifilein) tmp.mid
  catch {eval $cmd} miditime
  set exec_out focus_and_play:\n$cmd\n\n$miditime
  } else {
  set cmd "file copy $midi(midifilein) tmp.mid"
  file copy $midi(midifilein) tmp.mid
  set exec_out focus_and_play:\n$cmd\n
  }
play_midi_file tmp.mid
update_console_page
}

proc play_selected_lines {} {
global midi
copy_midi_to_tmp_for_midistruct
play_midi_file tmp.mid
update_console_page
}


proc channelstracks_to_midi {} {
global miditracks
global midichannels
global midi
global ntrks
if {$midi(midishow_sep) == "track" && $ntrks == 1} {
  set trkchn ""
  for {set i 0} {$i <= $ntrks} {incr i} {
     if {$miditracks($i)} {append trkchn "$i,"}
     }
  set midi(miditracks) $trkchn
  set midi(trk_method) 2
  } else {
  set trkchn ""
  for {set i 1} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  set midi(midichannels) $trkchn
  set midi(chan_method) 2
  }
}


proc copy_midi_to_tmp_for_midistruct {} {
global midi
global midichannels
global miditracks
global ntrks
global exec_out
global midispeed
global fbeat
global tbeat
set limits "none"
set tbeat 0
set fbeat 0
if {[winfo exist .midistructure]} {
    set limits [midistruct_limits .midistructure.can]
    if {$limits != "none"} {
	    set fbeat [lindex $limits 0]
	    set tbeat [lindex $limits 1]
    }
}
set trkchn ""
set option ""
if {$midi(midishow_sep) == "track"} {
  for {set i 0} {$i <= $ntrks} {incr i} {
     if {$miditracks($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-trks $trkchn"
         set option [string range $option 0 end-1]
         }
  } else {
  for {set i 1} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-chns $trkchn"}
         set option [string range $option 0 end-1]
  }
if {$midispeed != 1.00} {append option " -speed $midispeed"}
if {$limits != "none"} {
	append option " -frombeat $fbeat -tobeat $tbeat "
        }
# We first delete the old temporary midi file
# in case windows is still playing it.
set cmd "file delete -force -- tmp.mid"
catch {eval $cmd} done
#set midi(outfilename) [tmpname]
# create temporary file
if {[string length $option] > 0} {
  set cmd "exec [list $midi(path_midicopy)]  $option"
  lappend cmd  $midi(midifilein) tmp.mid
  catch {eval $cmd} miditime
  set exec_out play_selected_lines:\n$cmd\n\n$miditime
  } else {
  set cmd "file copy $midi(midifilein) tmp.mid"
  file copy $midi(midifilein) tmp.mid 
  set exec_out copy_midi_to_tmp_for_midistruct:\n$cmd\n
  }
update_console_page
}

proc play_and_exclude_selected_lines {} {
global trksel
global midi
global miditracks
global midichannels
global ntrks
global midispeed
global exec_out
set trkchn ""
set option ""
if {$midi(midishow_sep) == "track"} {
  for {set i 0} {$i <= $ntrks} {incr i} {
     if {$miditracks($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-xtrks $trkchn"
         set option [string range $option 0 end-1]
         }
  } else {
  for {set i 1} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         set option "-xchns $trkchn"}
         set option [string range $option 0 end-1]
  }
if {$midispeed != 1.00} {append option " -speed $midispeed"}
# We first delete the old temporary midi file
# in case windows is still playing it.
set cmd "file delete -force -- tmp.mid"
catch {eval $cmd} done
#set midi(outfilename) [tmpname]
# create temporary file
if {[string length $option] > 0} {
  set cmd "exec [list $midi(path_midicopy)]  $option"
  lappend cmd  $midi(midifilein) tmp.mid
  catch {eval $cmd} miditime
  set exec_out play_selected_lines:\n$cmd\n\n$miditime
  } else {
  set cmd "file copy $midi(midifilein) tmp.mid"
  file copy $midi(midifilein) tmp.mid
  set exec_out play_selected_lines:\n$cmd\n
  }
play_midi_file tmp.mid
update_console_page
}


proc save_temporary_midi_file {} {
global midi
set miditype {{{midi files} {*.mid *.MID *.midi *.kar *.KAR}}}
set filename [tk_getSaveFile -filetypes $miditype]
file rename -force $midi(outfilename) $filename
}

# Part 45.0               big abc editor
#
#
#
set hlp_big_abc_editor "Abc Editor\n\n\
This editor is designed to handle the large abc notated text\
produced by midiexplorer. Each of the voices, indicated in blue,\
are elided. To expose the voice content, click on the blue voice\
label. Click again, to elide this voice.\n\n\
The body of the abc file contains one measure per line of text.\
The bar number is indicated in the adjoining text window on the\
left and is there for information only. It is not used by the\
software. If you edit the abc text and introduce or remove a bar\
the indicated bar number on the left may be incorrect. To fix\
this problem click the recalc button.\n\n\
The play function will copy the existing abc notation to a file\
called X.tmp in the midiexplorer_home folder and then convert it into\
a midi file  X1.mid using the executable abc2midi. The midi file X1.mid\
will be forwarded to your designated midi player.\n\n\
The display function will also copy the existing abc notation to a file\
called X.tmp and then convert it to a PostScript file called\
Out.ps. Then Out.ps will be forwarded to a program that you designate\
to display this file.\n\n\  
Midiexplorer requires, abc2midi, abcm2ps, ghostscript, and a PostScript\
file viewer in order for these functions to work.
"


proc big_create_abc_file {} {
global midi
global exec_out
global midi2abc_options
set title [file root [file tail $midi(midifilein)]]
copy_midi_to_tmp 1
# exclude -bpl option
set err [check_midi2abc_options tmp.mid 1]
set cmd "exec [list $midi(path_midi2abc)] $midi2abc_options -title [list $title]" 
catch {eval $cmd} result
set exec_out $exec_out\n$cmd
set shortresult [string range $result 0 50]
set shortresult $shortresult...
set exec_out $exec_out\n$shortresult
#update_console_page
# do not update console page as it will obscure error
# messages returned by check_midi2abc_options.
big_edit_abc_output $result
}

proc big_edit_abc_output {output} {
global midi
global df
global elidevoice
set f .abcoutput
set dots "..."
set pat {V:([0-9]+)}
if {![winfo exist .abcoutput]} {
  toplevel .abcoutput
  frame $f.1
  button $f.1.display -text display -font $df -command big_display_abc_file
  tooltip::tooltip $f.1.display  "Convert the abc notation to a\nPostScript file and display."
  button $f.1.play -text play -font $df -command big_play_abc_file
  tooltip::tooltip $f.1.play  "Convert the abc notation to\na midi file and play."
  button $f.1.save -text save -font $df -command big_save_abc_file
  tooltip::tooltip $f.1.save  "Save the edited abc notation to\na file of your choice."
  button $f.1.recalc -text "recalc" -font $df\
     -command recalculate_bar_numbers
  tooltip::tooltip $f.1.recalc  "Recalculate the bar numbers."
  button $f.1.help -text help -font $df -command {show_message_page $hlp_abc_editor word}
  pack $f.1
  pack $f.1.display $f.1.play $f.1.save $f.1.recalc $f.1.help -side left
  frame $f.2
  text $f.2.txt -yscrollcommand {.abcoutput.2.scroll set} -width 80 -font $df -wrap none
  text $f.2.bar -yscrollcommand {.abcoutput.2.scroll set} -width 4 -font $df
  scrollbar $f.2.scroll -orient vertical -command [list BindYview [list .abcoutput.2.txt .abcoutput.2.bar]]
  pack $f.2.scroll -side right -fill y
  pack $f.2.bar -fill y -side left
  pack $f.2.txt  -side left -fill both -expand 1
  pack $f.2 -fill both -expand 1
  }
  $f.2.txt delete 1.0 end
  $f.2.bar delete 1.0 end
  set voiceno 0
  foreach line [split $output \n]  {
    if {[regexp $pat $line result voiceno]} {
       $f.2.txt tag configure vo$voiceno -foreground blue
       $f.2.txt tag bind vo$voiceno <1> "elide_reveal_voice $voiceno"
       $f.2.txt insert end $line\n vo$voiceno
       $f.2.bar insert end $dots\n 
       set elidevoice($voiceno) 0
       elide_reveal_voice $voiceno
       set barno 0
    } else {
       $f.2.txt insert end $line\n v$voiceno
       set first [string index $line 0]
       if {$voiceno != 0 && $first != "%"} {
	   incr barno
	   $f.2.bar insert end $barno\n b$voiceno
          } else {
           $f.2.bar insert end $dots\n b$voiceno
           }
    }
  }
}

proc recalculate_bar_numbers {} {
set f .abcoutput
$f.2.bar delete 1.0 end
set voiceno 0
set dots "..."
set pat {V:([0-9]+)}
set output [.abcoutput.2.txt get 1.0 end]
foreach line [split $output \n]  {
  if {[regexp $pat $line result voiceno]} {
     $f.2.bar insert end $dots\n 
     set barno 0
     } else {

       set initial [string index $line 0]
       set next [string index $line 1]
       if {[string first $initial ABCDEFGHIKLMNOPQRSTUVWwXZ]
        >= 0 && $next == ":" } {
		set field 1
        } else {set field 0}

       if {$voiceno != 0 && $initial != "%" && $field == 0} {
       incr barno
       $f.2.bar insert end $barno\n b$voiceno
       } else {
      $f.2.bar insert end $dots\n b$voiceno
      }
    }
  }
}

proc BindYview {lists args} {
# see Practical Programming in Tcl and Tk page 686
    foreach l $lists {
	    eval {$l yview} $args
    }
}

proc elide_reveal_voice no {
global elidevoice
set elidevoice($no) [expr 1 - $elidevoice($no)]
.abcoutput.2.txt tag configure v$no -elide $elidevoice($no)
.abcoutput.2.bar tag configure b$no -elide $elidevoice($no)
}

proc big_save_abc_file {} {
set abcfilename [tk_getSaveFile ]
set abcdata [.abcoutput.2.txt get 1.0 end]
set outhandle [open $abcfilename w]
puts $outhandle $abcdata
close $outhandle
}

proc big_play_abc_file {} {
global midi
global exec_out
if {![file exist $midi(path_abc2midi)]} {
  set msg "To use this function you require the executable abc2midi. Place it\
  in the directory midiexplorer_home."
  tk_messageBox -message $msg  -type ok
  return
  }
set ext ".abc"
set abcdata [.abcoutput.2.txt get 1.0 end]
set outhandle [open X.tmp w]
puts $outhandle $abcdata
close $outhandle
set cmd "exec $midi(path_abc2midi) X.tmp"
catch {eval $cmd} exec_out
set exec_out $cmd\n\n$exec_out
#puts $exec_out
play_midi_file X1.mid
}

proc big_display_abc_file {} {
global midi
global exec_out
global ps_numb_start
set ps_numb_start 0
set ext ".abc"
if {![file exist $midi(path_abcm2ps)]} {
  set msg "To use this function you require the executable abcm2ps. Place it\
  in the directory midiexplorer_home."
  tk_messageBox -message $msg  -type ok
  return
  }
set abcdata [.abcoutput.2.txt get 1.0 end]
set outhandle [open X.tmp w]
puts $outhandle $abcdata
close $outhandle
append exec_out "display_tunes X.tmp\n"
display_tunes X.tmp
#set cmd "exec $midi(path_abcm2ps) -j 1 X.tmp"
#catch {eval $cmd} exec_out
#set exec_out $cmd\n\n$exec_out
#set cmd "exec [list $midi(path_gv)] Out.ps &"
catch {eval $cmd} result
append exec_out \n$result
}



# Part 46.0               pgram

set hlp_pgram "Pgram\n\n\
The pgram provides a different way of visualizing a midi file.\
The plot is similar to the piano roll representation, except the temporal\
detail is reduced in order to yield a big picture. The different\
instruments (programs) are color coded like in midi structure. (Keyboard\
instruments are in dark blue, string instruments in purple, and etc.)\
The higher pitches appear at higher elevations.\n\n\
Moving the mouse pointer on any of the notes will highlight all the\
notes belonging to the same midi channel and indicate in the status\
line below the name of the instrument. Moving the mouse pointer over\
any of the channel check buttons below, will also highlight the notes belonging\
to that channel. In case the highlighting does not work for that\
channel, it is likely that there is another channel which displayed\
the same pitches.\n\n\
The abc button will generate an abc file and open an editor to this\
file. You can select a time interval by sweeping the mouse\
pointer from left to right over the region of interest while holding\
down the left mouse button. You can also specify the midi channels\
of interest by checking the appropriate check buttons.\n\n\
This representation is still somewhat experimental. The configuration menu,\
allows you to change some the way it is displayed.

"

proc p_highlight {c} {
global mlist
global last_high
global xchannel2program
set last_high $c
.pgram.c itemconfigure c$c -fill white 
set program [lindex $mlist $xchannel2program($c)]
.pgram.stat configure -text "channel $c --> $program"
}

proc p_unhighlight {c} {
global last_high
global progmapper
global groupcolors
global xchannel2program
if {$last_high < 0} return
set p $xchannel2program($last_high)
set g [lindex $progmapper $p]
set kolor [lindex $groupcolors $g]
.pgram.stat configure -text ""
.pgram.c itemconfigure c$c -fill $kolor 
set last_high -1
}


proc pgram_window {} {
global df
global hlp_pgram
global midi
global midichannels
global xchannel2program
if {![winfo exist .pgram]} {
  toplevel .pgram
  position_window .pgram
  frame .pgram.hdr
  pack .pgram.hdr -anchor w
  button .pgram.hdr.cfg -text configure -font $df -command pgram_cfg
  button .pgram.hdr.play -text play -font $df -command pgram_play
  button .pgram.hdr.abc -text abc -font $df -command pgram_abc
  button .pgram.hdr.hlp -text help -font $df -command {show_message_page $hlp_pgram word}
  label .pgram.hdr.file -text "" -font $df -width 45 
  pack .pgram.hdr.cfg .pgram.hdr.play .pgram.hdr.abc .pgram.hdr.hlp .pgram.hdr.file -side left -anchor w
  set pgraph .pgram.c
  canvas $pgraph -width $midi(pgramwidth) -height $midi(pgramheight) -border 3 
  pack $pgraph
  bind_pgram_tags
  frame .pgram.chn
  pack .pgram.chn
  label .pgram.chn.txt -text "channels: " -font $df
  pack .pgram.chn.txt -side left
  label .pgram.stat -text "" -font $df
  pack .pgram.stat
  for {set i 1} {$i < 17} {incr i} {
	  checkbutton .pgram.chn.$i -text $i -font $df -relief ridge -bd 2 -padx 1 -variable midichannels($i)
	  pack .pgram.chn.$i -side left
	  bind .pgram.chn.$i <Enter> "p_highlight $i"
	  bind .pgram.chn.$i  <Leave> "p_unhighlight $i"
          }
  bind $pgraph <ButtonPress-1> {pgram_Button1Press %x %y}
  bind $pgraph <ButtonRelease-1> {pgram_Button1Release}
  bind $pgraph <Double-Button-1> pgram_ClearMark
  }
compute_pgram

}

proc pgram_cfg {} {
global midi
global df
if {![winfo exist .pgramcfg]} {
  set p .pgramcfg
  toplevel $p
  frame $p.mode
  pack $p.mode -anchor w 
  radiobutton $p.mode.c -text "chord mode" -font $df -variable midi(pgrammode) -value chord
  radiobutton $p.mode.p -text "no chord mode" -font $df -variable midi(pgrammode) -value nochord
  pack $p.mode.c $p.mode.p -side left -anchor w
  frame $p.width
  pack $p.width -anchor w
  label $p.width.txt -text "plot width" -font $df
  entry $p.width.ent -textvariable midi(pgramwidth) -font $df
  pack $p.width.txt $p.width.ent -side left -anchor w
  frame $p.height
  pack $p.height
  label $p.height.txt -text "plot height" -font $df
  entry $p.height.ent -textvariable midi(pgramheight) -font $df
  pack $p.height.txt $p.height.ent -side left -anchor w
  button $p.reset -text reset -font $df -command pgram_reset
  frame $p.linewidth
  pack $p.linewidth
  label $p.linewidth.txt -text "line thickness" -font $df
  entry $p.linewidth.ent -textvariable midi(pgramthick) -font $df
  pack $p.linewidth.txt $p.linewidth.ent -side left -anchor w
  pack $p.reset -anchor w
  }
}

proc pgram_reset {} {
global midi
set midi(pgrammode) nochord
set midi(pgramwidth) 500
set midi(pgramheight) 350
set midi(pgramthick) 2
}



proc bind_pgram_tags {} {
set pgraph .pgram.c
for {set i 0} {$i < 17} {incr i} {
        $pgraph bind c$i <Enter> "p_highlight $i"
        $pgraph bind c$i <Leave> "p_unhighlight $i"
    }
}

#        Support functions

proc pgram_Button1Press {x y} {
    global midi
    global pxlbx pxrbx
    set xc [.pgram.c canvasx $x]
    if {$xc < $pxlbx} {set xc $pxlbx}
    .pgram.c raise mark
    .pgram.c coords mark $xc 21 $xc $midi(pgramheight)
    bind .pgram.c <Motion> { pgram_Button1Motion %x }
}

proc pgram_Button1Motion {x} {
    global midi
    global pxlbx pxrbx
    set xc [.pgram.c canvasx $x]
    if {$xc < $pxlbx} { set xc $pxlbx }
    if {$xc > $pxrbx} { set xc $pxrbx}
    set co [.pgram.c coords mark]
    .pgram.c coords mark [lindex $co 0] 21 $xc $midi(pgramheight)
}

proc pgram_Button1Release {} {
    bind .pgram.c <Motion> {}
    set co [.pgram.c coords mark]
}

proc pgram_ClearMark {} {
    .pgram.c coords mark -1 -1 -1 -1
}



proc reset_pitch_bands {} {
global bminpitch
global bmaxpitch
# reset
for {set i 0} {$i < 32} {incr i} {
  set bminpitch($i) 128
  set bmaxpitch($i) 0
  }
}

proc vbuildpgram {} {
global sorted_pianoresult
global ppqn
global bminpitch
global bmaxpitch
global activechan
set lastbegin 0
reset_pitch_bands
if [info exist activechan] {
  unset activechan
  }
foreach line $sorted_pianoresult {
     set begin [lindex $line 0]
     set end [lindex $line 1]
     if {[llength $line] == 6} {
       set begin [expr $begin/$ppqn]
       if {$begin > $lastbegin} {output_pitch_bands $lastbegin
	                         set lastbegin $begin}
       set end [expr [lindex $line 1]/$ppqn]
       set t [lindex $line 2]
       set c [lindex $line 3]
       set activechan($c) 1
       set pitch [lindex $line 4]        
       if {$pitch > $bmaxpitch($c)} {set bmaxpitch($c) $pitch}
       if {$pitch < $bminpitch($c)} {set bminpitch($c) $pitch}
       }
      }
}


proc hbuildpgram {} {
# We draw the notes horizontally, grouping all the
# notes of the same pitch in the same beat location.
# We can have several pitches (chord) occurring in the
# same beat and same channel. Therefore we separate by
# pitch rather than by channel. It is possible that two
# different channels produces the same pitched note, but
# we assume it does not happen too frequently.
global sorted_pianoresult
global ppqn
global activechan
global endpitchstrip
set lastbegin 0;
reset_endpitchstrip
if [info exist activechan] {
  unset activechan
  }
foreach line $sorted_pianoresult {
     if {[llength $line] == 6} {
       set begin [expr [lindex $line 0]/$ppqn]
       if {$begin > $lastbegin} {output_pstrip $lastbegin
	                         set lastbegin $begin}
       set t [lindex $line 2]
       set c [lindex $line 3]
       if {$c == 10} continue
       set activechan($c) 1
       set end [expr [lindex $line 1]/$ppqn]
       set pitch [lindex $line 4]        
       set endpitchstrip($pitch) [list $end $c]
       }
      }
}

proc reset_endpitchstrip {} {
global endpitchstrip
for {set i 1} {$i < 128} {incr i} {
  set endpitchstrip($i) 0
  }
}



proc compute_pgram {} {
global midi
global ppqn
global chn2prg
global exec_out
global sorted_pianoresult
global beats_per_pixel
global pxlbx pxrbx
global activechan

set pgraph .pgram.c
set infile $midi(midifilein)
set infilelength [string length $infile]
if {$infilelength > 42} {
  set infile [string range $infile [expr $infilelength -45] end]
  set infile "...$infile"
}
.pgram.hdr.file configure -text $infile
$pgraph delete all
.pgram.c create rect -1 -1 -1 -1 -tags mark -fill grey30 -stipple gray25
set pgraphwidth $midi(pgramwidth)
set pxrbx [expr $pgraphwidth - 3]
set pxlbx  40
set ytbx 20
set ybbx [expr $midi(pgramheight) + 20]

$pgraph create rectangle $pxlbx $ytbx $pxrbx $ybbx -outline white\
            -width 2 -fill grey5

incr pxlbx 3
incr pxrbx -3

set exec_options "[list $midi(midifilein)] -midigram"
set cmd "exec [list $midi(path_midi2abc)] $exec_options"
catch {eval $cmd} pianoresult
 if {[string first "no such" $pianoresult] >= 0} {abcmidi_no_such_error $midi(path_midi2abc)}
set pianoresult [split $pianoresult \n]
set sorted_pianoresult [lsort -command compare_onset $pianoresult]
set nrec [llength $pianoresult]
set midilength [lindex $pianoresult [expr $nrec -1]]
if {![string is integer $midilength]} {
	set msg "$midilength for file $midi(midifilein)"
	show_error_message $msg
	return
     }
set nbeats [expr $midilength/$ppqn]
set exec_out compute_pgram:\n$cmd\n\n$pianoresult

Graph::alter_transformation $pxlbx $pxrbx $ybbx $ytbx 0.0 $nbeats 0.0 110.0 
set beats_per_pixel [expr $nbeats/double($pxrbx - $pxlbx)]
pgram_vscale

if {$midi(pgrammode) == "chord"} {
  vbuildpgram
  } else {
  hbuildpgram
  }

p_reveal_buttons 
update_console_page
}

proc pgram_vscale {} {
global df
set pgraph .pgram.c
for {set i 1} {$i < 10} {incr i} {
  set oct C$i
  set p [expr $i*12 + 12]
  set iy [Graph::iypos $p]
  $pgraph create text 20 $iy -text $oct -font $df
  }
}

proc p_reveal_buttons {} {
global activechan
set butlist [lsort -integer [array names activechan]]
for {set i 1} {$i < 17} {incr i} {
   pack forget .pgram.chn.$i 
   }
foreach but $butlist {
   if {$but == 10} continue
   pack .pgram.chn.$but -side left
   }
}

proc output_pitch_bands {beat} {
global bminpitch
global bmaxpitch
global xchannel2program
global progmapper
global groupcolors
global midi
set pgraph .pgram.c
set thickness $midi(pgramthick)
set ix [Graph::ixpos $beat]
set ix2 [expr $ix+2]
for {set i 0} {$i < 16} {incr i} {
  if {$i == 10} continue
  if {$bminpitch($i) < 128} {
	  set iy1 [Graph::iypos $bminpitch($i)]
	  set iy2 [Graph::iypos $bmaxpitch($i)]
          set p $xchannel2program($i)
          set g [lindex $progmapper $p]
          set kolor [lindex $groupcolors $g]
	  set w [expr $iy1 - $iy2]
	  #puts "i = $i p = $p g = $g kolor = $kolor"
	  if {$w < 3} {set iy1 [expr $iy2+2]}
	  if {$w > 10} {set pat {1 6}
	  } elseif {$w > 5} {set pat {1 3}
          } else {set pat {1 1}}
	  #if {$i == 7} {puts "chn7 : $w $ix $iy1 $ix2 $iy2 $kolor $pat"}
          $pgraph create line $ix $iy1  $ix $iy2\
	      -fill $kolor -dash $pat -tag c$i -width $thickness
          }
  }
reset_pitch_bands
}

proc output_pstrip {beat} {
# create rectangle does not work well here because
# they all have outlines which are not optional.
global endpitchstrip
global xchannel2program
global progmapper
global groupcolors
global midi
set pgraph .pgram.c
set thickness $midi(pgramthick)
set ix [Graph::ixpos $beat]
for {set i 1} {$i < 128} {incr i} {
  if {[llength $endpitchstrip($i)] == 2 } {
	  set iy [Graph::iypos $i]
	  set end [lindex $endpitchstrip($i) 0]
	  set c [lindex $endpitchstrip($i) 1]
          set p $xchannel2program($c)
          set g [lindex $progmapper $p]
          set kolor [lindex $groupcolors $g]
	  set ix2 [expr [Graph::ixpos $end] +3]
          $pgraph create line $ix $iy  $ix2 $iy\
	      -fill $kolor -width $thickness -tag c$c
          }
  }
reset_endpitchstrip
}

proc pgram_limits {can} {
# limits of selected region in midistructure
    global beats_per_pixel
    set co [$can coords mark]
    #   is there a marked region of reasonable extent ?
    set extent [expr [lindex $co 2] - [lindex $co 0]]
    if {$extent > 5} {
        set xleft [expr ([lindex $co 0]-42)*$beats_per_pixel]
        set xright [expr ([lindex $co 2]-42)*$beats_per_pixel]
	set xleft [expr floor($xleft)]
	set xright [expr floor($xright)]
        #puts "midistruct_limits: $xleft $xright beats"
	return "$xleft $xright"
    } else {
        #puts "midistruct_limits: none"
        return none}
}

proc pgram_abc {} {
global midi
global midichannels
global exec_out
set exec_out ""
set limits  [pgram_limits .pgram.c]
set options ""
if {[llength $limits] > 1} {
  set fbeat [lindex $limits 0]
  set tbeat [lindex $limits 1]
  append option " -frombeat $fbeat -tobeat $tbeat "
  } 
  set trkchn ""
  for {set i 1} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         append option "-chns $trkchn"}
  set cmd "exec [list $midi(path_midicopy)]  $option"
  lappend cmd  $midi(midifilein) tmp.mid
  catch {eval $cmd} miditime
  append exec_out "$cmd\n\$miditime"

  set title [file root [file tail $midi(midifilein)]]
  set options ""
  if {$midi(midirest) > 0} {set options [concat $options "-sr $midi(midirest)"]}
  set cmd "exec [list $midi(path_midi2abc)] tmp.mid $options -noly -title [list $title]" 
  catch {eval $cmd} result
  append exec_out "\n$cmd"
  edit_abc_output $result
}

proc pgram_play {} {
global midi
global midichannels
global exec_out
set exec_out ""
set limits  [pgram_limits .pgram.c]
set options ""
if {[llength $limits] > 1} {
  set fbeat [lindex $limits 0]
  set tbeat [lindex $limits 1]
  append options " -frombeat $fbeat -tobeat $tbeat "
  } 
  set trkchn ""
  for {set i 1} {$i < 17} {incr i} {
     if {$midichannels($i)} {append trkchn "$i,"}
     }
  if {[string length $trkchn] > 0} {
         append options "-chns $trkchn"}
  set cmd "exec [list $midi(path_midicopy)]  $options"
  lappend cmd  $midi(midifilein) tmp.mid
  catch {eval $cmd} miditime
  append exec_out "$cmd\n\$miditime"

  play_midi_file tmp.mid 
}

               

proc get_geometry_of_all_toplevels {} {
  global midi
  set toplevellist {"." ".msg" ".greetings" ".error_msg" "abc.copy"
               ".abcedit" ".gracecfg" ".tmpfile" ".summary"
               ".notice" ".data_info" ".drumkit" ".dk" ".abcsearch"
               ".matcher" ".matchcfg" ".msummary" ".grouper" ".piano"
               ".ppqn" ".drumroll" ".drumrollconfig" ".pitchpdf"
               ".velocitypdf" ".onsetpdf" ".pitchclass" ".midivelocity"
               ".durpdf" ".assoc" ".mftext" ".beatgraph" ".chordstats"
               ".drumtool" "cfg.drumtool" "headers" "pitchinterval"
               ".histmatches" ".m2ps" ".live" ".preferred_chords"
               ".notegram" ".preferences" ".midistructure" ".pgram" }
  foreach top $toplevellist {
    if {[winfo exist $top]} {
      set g [wm geometry $top]
      scan $g "%dx%d+%d+%d" w h x y
      #puts "$top $x $y"
      set midi($top) +$x+$y
      }
   }
  }




proc load_extension {} {
global df midi
set types {{{tcl files} {*.tcl}}}
set extension [tk_getOpenFile -filetypes $types]
source $extension
}

# main program starts here


set tmp_clock [clock seconds]
global tmp_clock ;# this variable is used to determine whether .tmpfile
#needs to be refreshed.


if {[info exists abc_open]} {set midi(abc_open) $abc_open}

set midi(loadtime) [expr [clock clicks -milliseconds] - $startload]

# open last used file
if {[file exists $midi(abc_open)] && [file isfile $midi(abc_open)]} {
    load_whole_file $midi(abc_open)
    title_index $midi(abc_open)
    # fix   set titles_size [.abc.titles.t index end]
    #   puts $titles_size
    update_history $midi(abc_open)
    show_titles_page
}

set result [check_midi2abc_and_midicopy_versions]


switch_ps_button
focus .abc

startup_progress "runabc"

wm title . $runabc_title
