#-----------------------------------------------------
# gofer.tcl: additional tcl scripts 
#    are loaded by primitive `init_tcl'
#-----------------------------------------------------

# ----------------------------------------------------
# -- User events, eliminate additional arguments...
# ----------------------------------------------------
 
proc doEvent {eventid args} {   
  toGofer $eventid
}

# ----------------------------------------------------
# -- Windows with Predefined Title
# ----------------------------------------------------

proc window {a} {
  toplevel $a
  wm title $a "TkGofer"
 } 
 
# ----------------------------------------------------
# -- Menus     : addmenu returns index of item in menu
# ----------------------------------------------------

 
proc menu0 {str} {
  global $str
  menu $str -tearoff 0
  
  set $str -1 
} 
 
proc addmenu {str cmd} { 
  global $str 
  eval $cmd
  incr $str
  set $str
}

# ----------------------------------------------------
# -- dirlist   : modified ls
# ----------------------------------------------------

proc dirlist {pattern} {
 set a [catch {eval exec ls -aLF [glob $pattern]} msg]
 if {$a} {return ""} else {return $msg}
}

# ----------------------------------------------------
# -- internalError : call bgerror or tkerror
# ----------------------------------------------------

proc internalError {args} {
  global tk_version
  
  if {"$tk_version" == "4.1" } {bgerror $args} else {tkerror $args}
}


# EventHandling: Joachim Schmid
 
# ----------------------------------------------------
# --- extractEventID
#       Extract event-id from string and return integer
# ----------------------------------------------------
proc extractEventID {str} {
  set len [string length $str]
  return [lindex [string range $str 7 $len] 0]
}

# -----------------------------------------------------
# --- deleteCommand
#        delete the command (if set) and return the
#        event-id
# -----------------------------------------------------
proc deleteCommand {window_name} {
  set event [$window_name cget -command]
  $window_name configure -command {}
  if {"$event"==""} {return ""} else {
   set id [extractEventID $event]
   return $id
  }
}

# -----------------------------------------------------
# --- deleteEvent
#        delete the specified event and return its id
# -----------------------------------------------------
proc deleteEvent {window_name ev_name} {
  set event [bind $window_name $ev_name]
  bind $window_name $ev_name {}
  if {"$event"==""} {return ""} else {
   set id [extractEventID $event]
   return $id
  }
}

# -----------------------------------------------------
# --- deleteCanvasEvent
#        delete the specified event and return its id
# -----------------------------------------------------
proc deleteCanvasEvent {window_name item ev_name} {
  set event [$window_name bind $item $ev_name]
  $window_name bind $item $ev_name {}
  if {"$event"==""} {return ""} else {
   set id [extractEventID $event]
   return $id
  }
}
 
# ----------------------------------------------------
# --- deleteEvents
#       delete all events of the widget
# ----------------------------------------------------
proc deleteEvents {window_name} {
  set events [bind $window_name]
  foreach event $events {
    bind $window_name $event {}
  }
}   
 
# ---------------------------------------------------
# --- deleteCanvasEvents
#        delete all Events on one canvas-item
# ---------------------------------------------------
proc deleteCanvasEvents {window_name item} {
  set events [$window_name bind $item]
  foreach event $events {
    $window_name bind $item $event {}
  }
}   

# ----------------------------------------------------
# -- No standard error dialogs
# ----------------------------------------------------

proc tkerror {args} {}

# ----------------------------------------------------------
# gofer.fileevents: additional tcl-script for
#     using fileevents in Gofer
# ----------------------------------------------------------

# ----------------------------------------------------------
# -- nop: do nothing
# ----------------------------------------------------------

proc nop {} {}

# ----------------------------------------------------------
# -- fileReadable
#       is called when a fileevent readable appears, 
#       deletes the fileevent and execute action
# ----------------------------------------------------------

proc fileReadable {file action} {
  fileevent $file readable {}
  eval $action
}

# ----------------------------------------------------------
# -- fileWritable
#       is called when a fileevent writable appears,
#       deletes the fileevent and execute action
# ----------------------------------------------------------

proc fileWritable {file action} {
  fileevent $file writable {}
  eval $action
}

# ----------------------------------------------------------
# -- readFile
#        readFile read all available characters from the 
#        file. If not the end of file is reached, 
#        readFile reset the fileevent
# ----------------------------------------------------------

proc readFile {file action} {
  set erg [read $file]
  set e [eof $file]
  set help "{$action}"
  set act "fileReadable $file $help"
  if {$e==0} {fileevent $file readable $act} {}
  return $erg
}

# -----------------------------------------------------------
# -- writeFile
#        writes str to the file and set the fileevent to
#        action
# -----------------------------------------------------------

proc writeFile {file str action} {
  puts -nonewline $file $str
  flush $file
  set help "{$action}"
  set act "fileWritable $file $help"
  fileevent $file writable $act
}

# ----------------------------------------------------
# -- insWithTag
# ----------------------------------------------------

proc insTag {w x t} {  
  set p0 [$w index insert] 
  insTagAt $p0 $w $x $t
}

proc insTagAt {p0 w x t} {  
  $w mark set mx $p0        
  $w insert $p0 $x           
  set p1 [$w index mx]       
  $w tag add $t $p0 $p1       
} 

# ----------------------------------------------------
# -- pack and raise
# ----------------------------------------------------

proc praise {p0 args} {
  eval "pack $p0 -in $args"
  raise $p0
}

# ----------------------------------------------------
# -- Optimizations for Jbook
# ----------------------------------------------------

# save widget name in global variable
proc jSW {widget} {
  global jBookWidget
  set jBookWidget $widget
}

# configure background of saved widget name
proc jCTB {tag color} { 
  global jBookWidget
  eval $jBookWidget tag configure $tag -background "$color"  
}

# insert Tag
proc jIT {tag} {
  global jBookWidget
  global tmp
  insTag $jBookWidget $tmp $tag
}

# set click command of tag
proc jSC {tag event} {
  global jBookWidget
  eval $jBookWidget tag bind "$tag" <ButtonPress-1> "{ doEvent \" $event \" }"
}

# ----------------------------------------------------
# -- Start Up
# ----------------------------------------------------


wm withdraw .


