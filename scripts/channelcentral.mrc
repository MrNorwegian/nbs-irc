; Channel Central
alias cc { 
  if ($status == connected) && ($1 ischan) && ($me ison $1) && (!$dialog(editban)) && (!$dialog(cc)) {
    set %ccc $1
    dlg cc
    dialog -t cc $1 - $strip($right($n.chanstats($1),-6))
  }
}

dialog cc {
  title "cc"
  size -1 -1 272 207
  option dbu
  icon $scriptdirdll\i.dll, 7
  text "Topic", 3, 2 1 66 8
  text "Bans", 4, 2 22 65 8
  combo 1, 2 9 268 100, edit drop
  check "Set with Q", 16, 232 20 37 10
  list 2, 1 30 269 98, size extsel
  button "Bans", 18, 2 129 33 11
  button "Excepts", 19, 36 129 33 11
  button "Invites", 20, 70 129 33 11
  button "Select all", 15, 168 129 33 11
  button "Edit", 100, 202 129 33 11
  button "Remove", 101, 236 129 33 11
  check "Only ops set topic (+t)", 5, 3 143 67 10
  check "No external messages (+n)", 6, 3 153 78 10
  check "Invite only (+i)", 7, 3 163 51 10
  check "Moderated (+m)", 8, 3 173 51 10
  check "Private (+p)", 14, 3 183 43 10
  check "Secret (+s)", 10, 3 193 59 10
  check "Key (+k):", 30, 83 143 33 10
  edit "", 32, 117 143 50 10, autohs
  check "Limit (+l):", 31, 83 153 34 10
  edit "", 33, 117 153 25 10, autohs
  check "Only authed/registered users (+r)", 11, 83 163 96 10
  check "No channel notices (+N)", 12, 83 173 84 10
  check "No channel CTCPs (+C)", 13, 83 183 83 10
  check "No colors (+c)", 9, 83 193 50 10
  text "Custom:", 21, 182 144 22 8
  edit "", 23, 206 143 63 10, autohs
  text "Available:", 24, 182 164 25 8
  text "", 25, 208 164 60 8, right
  text "Current:", 26, 182 155 25 8
  text "", 27, 208 155 60 8, right
  button "OK", 17, 196 195 37 11, default ok
  button "Cancel", 22, 234 195 37 11, cancel
}

on *:dialog:cc:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetControlMDX cc 2 listview report showsel > scripts\dll\mdx\views.mdx
  did -i cc 2 1 headerdims 306:1 110:2 100:3
  did -i cc 2 1 headertext Address $chr(9) $+ Set by $chr(9) $+ Set on
  unset %unban %ccc.*
  var %x = $+(",$scriptdirtemp\topic\,$md5(%ccc),â,$cid,")
  if ($exists(%x)) loadbuf -o cc 1 $qt(%x)
  else did -a cc 1 $chan(%ccc).topic
  did -ar cc 3 Topic ( $+ $len($chan(%ccc).topic) $+ / $+ $n.topiclen $+ )
  did -b cc 16,32,33 $+ $iif(e !isincs $chanmodes,$chr(44) $+ 19) $+ $iif(I !isincs $chanmodes,$chr(44) $+ 20)
  if (!$n.qnet) did -h cc 16
  if ($chan(%ccc).topic) {
    var %x = $ifmatch
    set %ccc.topic $iif($left(%x,1) == $chr(32),$right(%x,-1),%x)
    did -c cc 1 1
  }
  var %i = 5
  while (%i < 15) {
    if ($cm(%i) isincs $gettok($chan(%ccc).mode,1,32)) did -c cc %i
    inc %i
  }
  if (k isincs $gettok($chan(%ccc).mode,1,32)) && ($chankey(%ccc)) { did -c cc 30 | did -e cc 32 | did -a cc 32 $chankey(%ccc) | set %ccc.key $chankey(%ccc) }
  if (l isincs $gettok($chan(%ccc).mode,1,32)) { did -c cc 31 | did -e cc 33 | did -a cc 33 $chan(%ccc).limit | set %ccc.limit $chan(%ccc).limit }
  did -a cc 25 $iif($chanmodes,$ifmatch,unknown)
  did -a cc 27 $iif($chan(%ccc).mode,$ifmatch,none)
  mode %ccc +b
  set -u20 %ccc.banget 1
  set %ccc.list b
  did -ar cc 4 Bans (retrieving)
  did -f cc 3
  if (q ison %ccc) && ($n.qnet) did -e cc 16
}

; 
on *:dialog:cc:sclick:30,31:{
  if ($did(cc,$did).state == 1) did -e cc $calc($did +2)
  else did -b cc $calc($did +2)
}

;
on *:dialog:cc:sclick:18,19,20:{
  var %x = $replace($did,18,b,19,e,20,I)
  if (%ccc.list != %x) {
    did -ar cc 4 $replace($did,18,Bans,19,Excepts,20,Invites)    
    did -r cc 2
    set -u10 %ccc.banget 1
    set %ccc.list %x
    mode %ccc + $+ %x
  }
}

on *:dialog:cc:sclick:100:{
  if ($did(cc,2).seltext) n.editmode $gettok($did(cc,2).seltext,6,32)
}
on *:dialog:cc:dclick:2:{
  if ($did(cc,2).seltext) n.editmode $gettok($did(cc,2).seltext,6,32)
}
on *:dialog:cc:edit:1:{
  did -ar cc 3 Topic ( $+ $len($did(cc,1,0)) $+ / $+ $n.topiclen $+ )
  if ($len($did(cc,1,0)) > $n.topiclen) n.mdx SetColor 3 textbg 255
  else n.mdx SetColor 3 textbg reset
  n.preview cc $did(cc,1,0)
}
on *:dialog:cc:sclick:1:{
  did -ar cc 3 Topic ( $+ $len($did(cc,1,0)) $+ / $+ $n.topiclen $+ )
  n.mdx SetColor 3 textbg reset
  n.preview cc $did(cc,1,0)
}
on *:dialog:cc:sclick:101:{
  if (!%ccc.list) return
  .write -c $qt($scriptdirtemp\unban)
  var %i = 2
  while (%i <= $did(cc,2).lines) {
    if (s isin $gettok($did(cc,2,%i).text,2,32)) .write $qt($scriptdirtemp\unban) $gettok($did(cc,2,%i).text,6,32)
    inc %i
  }
  if ($read($scriptdirtemp\unban)) {
    did -r cc 2
    var %x, %i = 1, %e = $lines($scriptdirtemp\unban)
    while (%i <= %e) {
      if ($numtok(%x,32) == $modespl) {
        mode %ccc - $+ $str(%ccc.list,$numtok(%x,32)) %x
        dec %i
        unset %x
      }
      else var %x = %x $read($scriptdirtemp\unban,%i)
      inc %i
    }
    mode %ccc - $+ $str(%ccc.list,$numtok(%x,32)) %x
    set -u20 %ccc.banget 1      
    mode %ccc + $+ %ccc.list
  }
}
on *:dialog:cc:sclick:15:{
  var %i = 2
  while (%i <= $did(cc,2).lines) {
    did -o cc 2 %i 0 $replace($gettok($did(cc,2,%i).text,2,32),+,+s) $gettok($did(cc,2,%i).text,3-,32)
    inc %i
  }
  did -f cc 2
}
on *:dialog:cc:sclick:17:{
  if (!$did(cc,1,0)) && (%ccc.topic) !raw -q topic %ccc :
  elseif ($did(cc,1,0) === %ccc.topic) .echo -qgs a
  else {
    if ($did(cc,16).state == 1) && ($n.qnet) && (q ison %ccc) !raw -q PRIVMSG Q :settopic %ccc $did(cc,1,0)
    else topic %ccc $did(cc,1,0)
  }
  var %i = 5, %+modes, %-modes, %+key, %-key, %cmodes = $did(cc,23)
  while (%i < 15) {
    if (($did(cc,%i).state == 1) && ($cm(%i) !isincs $gettok($chan(%ccc).mode,1,32))) var %+modes = %+modes $+ $cm(%i)
    elseif (($did(cc,%i).state == 0) && ($cm(%i) isincs $gettok($chan(%ccc).mode,1,32))) var %-modes = %-modes $+ $cm(%i)
    inc %i
  }
  if (($did(cc,30).state == 1) && ($did(cc,32).text) && (k !isincs $gettok($chan(%ccc).mode,1,32))) var %+key = +k $did(cc,32).text
  elseif (($did(cc,30).state == 1) && ($did(cc,32).text) && ($did(cc,32).text != %ccc.key) && (k isincs $gettok($chan(%ccc).mode,1,32))) { var %+key = +k $did(cc,32).text | var %-key = -k %ccc.key }
  elseif (($did(cc,30).state == 0) && (k isincs $gettok($chan(%ccc).mode,1,32))) var %-key = -k $chan(%ccc).key
  if (($did(cc,31).state == 1) && ($did(cc,33).text isnum) && ($did(cc,33).text != %ccc.limit)) var %+modes = %+modes l $did(cc,33).text
  elseif (($did(cc,31).state == 0) && (l isincs $gettok($chan(%ccc).mode,1,32))) var %-modes = %-modes $+ l
  if (%+modes) || (%-modes) mode %ccc $iif(%+modes,$+(+,$v1)) $iif(%-modes,$+(-,$v1)) 
  if (%cmodes) mode %ccc %cmodes
  if (%-key) mode %ccc %-key
  if (%+key) {
    mode %ccc %+key
    set %pw. [ $+ [ %ccc ] ] $gettok(%+key,2-,32)
  }
}
On *:dialog:editban:init:0:did -a editban 1 %oldmode
On *:dialog:editban:sclick:3:{
  if (%oldmode != $did(editban,1).text) {
    mode %ccc $+(-,%ccc.list,+,%ccc.list) %oldmode $did(editban,1).text
    if ($dialog(cc)) {
      did -r cc 2
      mode %ccc + $+ %ccc.list
    }
  }
  unset %oldmode
}
on *:dialog:cc:close:0:{
  if ($dialog(editban)) dialog -x editban
  if ($window(@topic)) close -@ @topic*
  unset %oldmode
}
alias n.editmode {
  if (!$1) return
  unset %oldmode
  set %oldmode $1-
  dlg editban
}
dialog editban {
  title "Edit"
  size -1 -1 153 35
  option dbu
  icon $scriptdirdll\i.dll, 7
  edit "", 1, 2 10 150 11, autohs
  text "Address:", 2, 2 2 74 8
  button "OK", 3, 77 23 37 11, ok
  button "Cancel", 4, 115 23 37 11, cancel
}
