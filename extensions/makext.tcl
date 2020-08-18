#makext.tcl

#This extension is designed to handle Turkish Makams.
#The extension replaces title_index procedure in runabc.tcl and adds more
#columns to the TOC in order to handle Turkish Makam abc tunes.
#To load this extension in runabc.tcl, go to the Options menu and
#click on "load runabc extension", select this file.


##.abc.titles.t delete [.abc.titles.t children {}]
destroy .abc.titles.t
ttk::treeview .abc.titles.t -columns {refno makam key usul meter form title}  -height 15\
        -show headings  \
        -selectmode extended -yscrollcommand {.abc.titles.ysbar set}
update
#.abc.titles.t configure -columns {refno makam key usul meter form title}
foreach col {refno makam key usul meter form title}  name {refnumb makam key usul meter form title}  {
    .abc.titles.t heading $col -text $col
    .abc.titles.t heading $col -command [list SortBy $col 0]
    .abc.titles.t column $col -width [expr [font measure $df $name] +3]
     }
.abc.titles.t column refno -width [expr [font measure $df $name] +10]
.abc.titles.t column makam -width [expr [font measure $df $name] +50]
.abc.titles.t column key -width [expr [font measure $df $name] +50]
.abc.titles.t column usul -width [expr [font measure $df $name] +40]
.abc.titles.t column meter -width [expr [font measure $df $name] +20]
.abc.titles.t column form -width [expr [font measure $df $name] +50]
.abc.titles.t column title -width [expr [font measure $df $name] +120]
.abc.titles.t column title -width [font measure $df "WWWWWWWWWWWWWWWWWWWWWWWW"]
pack .abc.titles.t  -expand y -fill both
bind .abc.titles.t <<TreeviewSelect>> {extract_tune_info}


update

proc title_index {abcfile} {
    global fileseek midi
    global abc_file_mod
    global item_id
    global index_done
    global df
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
    update
    set titlehandle [open $abcfile r]
    #fconfigure $titlehandle -encoding iso8859-9
     fconfigure $titlehandle -encoding utf-8
    set filepos 0
    set meter 4/4
    set i 1
    .abc.titles.t tag configure tune -font $df
    while {[gets $titlehandle line] >= 0} {
        if {!$midi(blank_lines) && [string length $line] < 1} {set srch X}
        if {[string index $line 0] == "M"} {
            set meter [string range $line 2 end]
            set meter [string trim $meter]
        }
        switch --  $srch {
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
                    set srch N
                }
            }

            N { if {[string index $line 0] == "N"} {
                 set noteline [string range $line 2 end]
                 set ntypelist [split $noteline]
                 set ntype [lindex $ntypelist 1]
                 set ntypeval [lindex $ntypelist 2]
                 #puts "ntypelist $ntypelist"
                 switch  $ntype {
		    makam= {set makamtype $ntypeval}
                    form= {set formtype $ntypeval}
                    usul= {set usultype $ntypeval
                         set srch K}
                 }
               }
            }
            K {
                if {[string index $line 0] == "K"} {
                    set keysig [string range $line 4 end]
                    set keysig [string trim $keysig]
                    set keysig [string range $keysig 0 15]
                    set outline [format "%4s %10s %-5s %10s %s %s %s" $number $makamtype  [list $keysig] $usultype $meter $formtype [list $name]]
                    #puts "outline = $outline"
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
    if {$i == 0} {show_error_message "corrupted file $midi(abc_open)\nno K:,X:,T: found in file."
        return}
    if {$i < 15} {
        .abc.titles.t configure -height [expr $i + 1]
        set midi(abc_save) $midi(abc_open)
    } else {
        .abc.titles.t configure -height 15
        set midi(abc_save) edit.abc
    }
    #puts "item id for $itemposition = $item_id($itemposition)"
    if {[info exist itemposition]} {
        .abc.titles.t selection set $item_id($itemposition)
        .abc.titles.t see $item_id($itemposition)
    }
#    extract_tune_info
    update
}

title_index $midi(abc_open)

