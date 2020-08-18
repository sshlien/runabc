# This add-on replaces list_best_matches in runabc.tcl.
# This version also produces a html file bestmatches.html
# with the results of the Search Menu/histogram matcher.
# The file bestmatches.html is overwritten each time you
# select another tune. To use this add-on select this
# file when clicking on Options/load runabc extension.

namespace eval Matcher {

    proc list_best_matches {scoreresults} {
        global idtune
        global df
        global midi
        global hlp_histmatches
        set outhandle [open "bestmatches.html" w]
        puts $outhandle "<TR>"
        if {![winfo exist .histmatches]} {
          toplevel .histmatches
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
            }
          }
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
             -borderwidth 0 \
             -command "play_selected_tune_in_file $filename $refno" 
            button $h.abc$i -text display -font $df -image spellcheck-16\
             -borderwidth 0 \
             -command "show_selected_tune_in_file $filename $refno" 
            set choice 0
            grid $h.v$i $h.r$i $h.k$i $h.t$i $h.radio$i $h.play$i $h.abc$i -sticky w
            puts $outhandle "<TD> $val </TD>"
            puts $outhandle "<TD> $key </TD>"
            puts $outhandle "<TD> $title </TD>"
            puts $outhandle "</TR><TR>" 
        }
        close $outhandle
# plot results for first choice
    set result [lindex $scoreresults 0]
    set best_idnum [lindex $result 1]
    set xref [lindex $idtune($best_idnum) 0]
    Matcher::find_pdf_for $xref
    plot_pdf
    $h.radio0 invoke
    }
}
