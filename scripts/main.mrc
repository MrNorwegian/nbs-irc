; Vote stuff, todo to be removed
alias vote {
  if (%vote) { n.echo info -atg there is already an vote in progress | return }
  if (!$server) { n.echo info -atg not connected | return }
  if ($active !ischan) { n.echo info -atg not on a channel | return }
  set %vchan #
  set %vote $$n.input(Enter topic (yes/no))
  set %ja 0
  set %nej 0
  msg %vchan %vote (vote with !yes or !no)
  .enable #röstning
}
alias voteoff {
  .disable #röstning
  msg %vchan result: %vote (yes: %ja - no: %nej $+ )
  if (%r.nicks) msg %vchan voted: $ifmatch
  unset %vote %ja %nej %röstat %r.nicks
}
#röstning off
ON *:TEXT:!yes:#: {
  if (# == %vchan) && ($address($nick,1) !isin %röstat) {
    set %röstat %röstat $address($nick,1)
    set %r.nicks %r.nicks $nick (y)
    inc %ja 1
  }
}
ON *:TEXT:!no:#: {
  if (# == %vchan) && ($address($nick,1) !isin %röstat) {
    set %röstat %röstat $address($nick,1)
    set %r.nicks %r.nicks $nick (n)
    inc %nej 1
  }
}
#röstning end
on ^*:HOTLINK:*.*.*.*:*:{ if ($remove($1,.) !isnum) { halt } }
on *:HOTLINK:*.*.*.*:*:{
  set %hlip $remove($1,],[,$chr(40),$chr(41),@,/,\)
  if (*:?* !iswm %hlip) { 
    if ($ncfg(defgame) == hl) set %hlip %hlip $+ :27015
    if ($ncfg(defgame) == bf) set %hlip %hlip $+ :14567
  }
  set %autoscan 1  
  g-join
}

alias dlg {
  if (!$1) return
  if (!$dialog($1)) dialog -m $1 $1
}

alias ehide { return $istok($hget(temp,$1),$2,44) }
alias hideshow.event {
  if ($2) {
    if ($ehide($2,$1)) hadd -m temp $2 $remtok($hget(temp,$2),$1,44)
    else hadd -m temp $2 $addtok($hget(temp,$2),$1,44) 
    if ($hget(temp,$2)) w_ncfg hide_ $+ $2 $hget(temp,$2)
    else w_ncfg hide_ $+ $2 o
  }
}
alias n.saveconfig {
  hsave -i nbs config\config.ini nbs-irc
}

dialog paste {
  title "Paste"
  size -1 -1 219 155
  option dbu
  icon scripts\dll\i.dll, 17
  text "", 1, 2 2 166 8
  edit "", 2, 2 11 215 130, multi return autohs vsbar
  check "Delay lines (seconds):", 3, 3 143 63 10
  edit "1", 7, 66 143 19 11, autohs
  button "Paste", 4, 142 143 37 11, ok
  button "Cancel", 5, 180 143 37 11, cancel
}
on *:dialog:paste:init:0:{
  did -a paste 1 Are you sure you want to paste $cb(0) lines of text into this window?
  dialog -t paste Paste to %paste.target
  var %i = 1
  while (%i <= $cb(0)) {
    did -a paste 2 $cb(%i) $+ $crlf
    inc %i
  }
  if ($cb(7)) did -c paste 3
  if ($cb(12)) did -ar paste 7 2
  if ($cb(20)) did -ar paste 7 3
  did -f paste 4
}
on *:dialog:paste:sclick:4:{
  if (%paste.target) {
    var %x = scripts\temp\paste_ $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z)
    savebuf -o paste 2 %x
    if ($did(paste,2,1) isnum) .write -il1 %x $crlf
    if ($did(paste,3).state == 1) && ($did(paste,7) isnum 1-) .play -a pastemsg %paste.target %x $did(paste,7) $+ 000
    else .play -a pastemsg %paste.target %x 0
  }
  unset %paste.target
  .timer 1 600 .remove %x
}

dialog strt {
  title ""
  size -1 -1 66 3
  option dbu
  text "", 1, 3 3 60 6
}
on *:dialog:strt:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetDialog $dname style dlgframe
  n.mdx SetControlMDX $dname 1 progressbar smooth > scripts\dll\mdx\ctl_gen.mdx
  did -a strt 1 0 0 10
}

; Control Panel
alias setup dlg cp
dialog cp {
  title "Control Panel (/setup)"
  size -1 -1 244 191
  option dbu
  icon scripts\dll\i.dll, 17
  list 1, -1 -1 246 176, size extsel
  button "Close", 2, 205 178 37 11, ok
  text "", 100, 3 180 165 8
}
on *:dialog:cp:sclick:2:dialog -x cp
on *:dialog:cp:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetControlMDX cp 1 ListView icon sortascending > scripts\dll\mdx\views.mdx
  did -i cp 1 1 iconsize 32 32 
  did -i cp 1 1 seticon list 2, $+ $scriptdirdll\i.dll
  did -a cp 1 0 1 Misc settings
  did -i cp 1 1 seticon list 0, $+ $scriptdirdll\i.dll
  did -a cp 1 0 2 Theme/font
  did -i cp 1 1 seticon list 5, $+ $scriptdirdll\i.dll
  did -a cp 1 0 3 Sound/highlight
  did -i cp 1 1 seticon list 6, $+ $scriptdirdll\i.dll
  did -a cp 1 0 4 Song announce
  did -i cp 1 1 seticon list 9, $+ $scriptdirdll\i.dll
  did -a cp 1 0 5 Protections
  did -i cp 1 1 seticon list 12, $+ $scriptdirdll\i.dll
  did -a cp 1 0 6 Auto connect
  did -i cp 1 1 seticon list 19, $+ $scriptdirdll\i.dll
  did -a cp 1 0 7 Autojoin
  did -i cp 1 1 seticon list 8, $+ $scriptdirdll\i.dll
  did -a cp 1 0 8 QuakeNet
  did -i cp 1 1 seticon list 23, $+ $scriptdirdll\i.dll
  did -a cp 1 0 9 UnderNet
  did -i cp 1 1 seticon list 20, $+ $scriptdirdll\i.dll
  did -a cp 1 0 10 NickServ
  did -i cp 1 1 seticon list 18, $+ $scriptdirdll\i.dll
  did -a cp 1 0 11 Notifications
  did -i cp 1 1 seticon list 11, $+ $scriptdirdll\i.dll
  did -a cp 1 0 12 F-key bindings 
  did -i cp 1 1 seticon list 3, $+ $scriptdirdll\i.dll 
  did -a cp 1 0 13 Logviewer
  did -i cp 1 1 seticon list 1, $+ $scriptdirdll\i.dll
  did -a cp 1 0 14 Game launcher
  did -i cp 1 1 seticon list 15, $+ $scriptdirdll\i.dll
  did -a cp 1 0 15 Blacklist
  did -i cp 1 1 seticon list 21, $+ $scriptdirdll\i.dll
  did -a cp 1 0 16 Alarm timer
  did -i cp 1 1 seticon list 10, $+ $scriptdirdll\i.dll
  did -a cp 1 0 17 Commands
  did -i cp 1 1 seticon list 0, $+ $mircdirnbs.ico
  did -a cp 1 0 18 About
  n.showversion 100
}
on *:dialog:cp:dclick:1:{
  var %a = $gettok($did($dname,1).seltext,6-,32)
  if (mi isin %a) misc
  elseif (th isin %a) theme
  elseif (sou isin %a) nq
  elseif (son isin %a) mp3say
  elseif (pr isin %a) prot
  elseif (auto c isin %a) autocon
  elseif (autoj isin %a) caj
  elseif (qu isin %a) quakenet
  elseif (und isin %a) undernet
  elseif (ni isin %a) cns
  elseif (no isin %a) popups
  elseif (f- isin %a) fkeys
  elseif (lo isin %a) logviewer
  elseif (ga isin %a) g-join
  elseif (bl isin %a) blist
  elseif (al isin %a) alarm
  elseif (co isin %a) cf1
  elseif (ab isin %a) aboutnbs
}

; Servicebot control
alias botcontrol {
  unset %bc.*
  if ($2) set %bc.nick $2
  if ($1) set %bc.chan $1
  elseif ($active ischan) set %bc.chan $active
  if (q ison %bc.chan) set %bc.bot Q
  elseif (l ison %bc.chan) set %bc.bot L
  if (%bc.chan) && (%bc.bot) && (%bc.nick) dlg botctrl
}
dialog botctrl {
  title "-"
  size -1 -1 94 42
  option dbu
  icon $scriptdirdll\i.dll, 17
  text "Set:", 2, 2 14 13 8
  text "Current:", 150, 2 3 23 8
  button "Set", 8, 25 29 33 11, default ok
  button "Cancel", 9, 59 29 33 11, cancel
  combo 98, 30 13 62 91, edit drop
  text "", 99, 35 3 56 8, right
}
on *:dialog:botctrl:init:0:{
  did -f botctrl 98
  if (%bc.chan) && (%bc.bot) && (%bc.nick) {
    dialog -t botctrl Chanlev: %bc.nick
    set %bc.getmode 1
    .msg %bc.bot chanlev %bc.chan %bc.nick
    did -a botctrl 99 getting...
    did -c botctrl 99 1
    did -a botctrl 98 +gv (auto-voice)
    did -a botctrl 98 -gv
    did -a botctrl 98 $chr(32)
    did -a botctrl 98 +ao (auto-op)
    did -a botctrl 98 -ao
    did -a botctrl 98 $chr(32)
    did -a botctrl 98 +k (known)
    did -a botctrl 98 -k
    did -a botctrl 98 $chr(32)  
    did -a botctrl 98 +p (protect)
    did -a botctrl 98 -p
    did -a botctrl 98 $chr(32)  
    did -a botctrl 98 +m (master)
    did -a botctrl 98 -m
    did -a botctrl 98 $chr(32) 
    did -a botctrl 98 +d (prevent op)
    did -a botctrl 98 -d
    did -a botctrl 98 $chr(32) 
    did -a botctrl 98 +q (prevent voice)
    did -a botctrl 98 -q
    did -a botctrl 98 $chr(32)
    did -a botctrl 98 +j (auto invite)
    did -a botctrl 98 -j
  }
}

on *:dialog:botctrl:sclick:8:{
  if (%bc.chan) && (%bc.bot) && (%bc.nick) {
    if ($did(botctrl,98)) msg %bc.bot chanlev %bc.chan %bc.nick $gettok($ifmatch,1,32)
    else msg %bc.bot removeuser %bc.chan %bc.nick
  }
}

; Notification popups
alias popups dlg popups
dialog popups {
  title "Notification popups (/popups)"
  size -1 -1 138 189
  option dbu
  icon $scriptdirdll\i.dll, 17
  tab "General", 15, 3 1 131 170
  box "Show notification popups:", 50, 9 18 119 64, tab 15
  box "Show notification popups for these events:", 51, 9 86 119 79, tab 15
  radio "When mIRC is not the active window", 6, 14 27 103 10, tab 15 group 
  radio "Always show notifications", 7, 14 36 100 10, tab 15 
  radio "Disable notifications", 8, 14 45 57 10, tab 15 
  check "Don't show notifications while away", 4, 15 56 100 10, tab 15 
  edit "", 9, 47 67 14 11, tab 15 autohs center
  text "seconds", 5, 63 69 25 8, tab 15
  text "Display time:", 1, 15 69 32 8, tab 15
  check "Highlights", 10, 16 95 50 11, tab 15 
  check "Querys", 11, 16 104 50 11, tab 15 
  radio "Only on first message", 2, 19 114 82 10, group tab 15 
  radio "Always", 3, 19 123 36 10, tab 15 
  check "DCCs", 12, 16 133 50 11, tab 15 
  check "Connects/disconnects", 13, 16 142 70 11, tab 15 
  check "Other events", 14, 16 151 56 11, tab 15 
  tab "Positioning", 16
  combo 17, 17 29 104 100, tab 16 drop
  text "Width (x):", 304, 24 64 26 8, tab 16
  edit "", 40, 51 62 25 11, tab 16 center
  edit "", 41, 51 74 25 11, tab 16 center
  check "Center", 250, 81 63 30 10, tab 16 
  check "Center", 251, 81 75 29 10, tab 16 
  text "Negative value for right side of the screen. Positive value for left side of the screen.", 302, 14 107 110 15, tab 16
  text "Height (y):", 305, 22 76 28 7, tab 16
  button "Preview", 206, 92 131 37 11, tab 16
  box "Position:", 18, 8 50 121 43, tab 16
  box "Usage:", 53, 8 97 121 31, tab 16
  box "Presets:", 52, 8 19 121 27, tab 16
  button "OK", 100, 60 175 37 11, default ok
  button "Cancel", 101, 98 175 37 11, cancel
}
on *:dialog:popups:init:0:{
  if ($ncfg(popup_nick) == 1) did -c popups 10
  if ($ncfg(popup_query) == 1) did -c popups 11
  if ($ncfg(popup_dcc) == 1) did -c popups 12
  if ($ncfg(popup_discon) == 1) did -c popups 13
  if ($ncfg(popup_other) == 1) did -c popups 14
  if ($ncfg(popup_query_always) == 1) did -c popups 3
  else did -c popups 2
  if (!$ncfg(popup_query_always)) { 
    w_ncfg popup_query_always 1
    did -c popups 2
  }
  if (!$ncfg(popup_mode)) { 
    w_ncfg popup_mode 2
    did -c popups 6
  }
  elseif ($ncfg(popup_mode) == 2) did -c popups 6
  elseif ($ncfg(popup_mode) == 3) did -c popups 7
  elseif ($ncfg(popup_mode) == 4) did -c popups 8
  if ($ncfg(popup_timeout) !isnum 1-60) w_ncfg popup_timeout 7
  else did -a popups 9 $ncfg(popup_timeout)
  if (!$ncfg(popup_posx)) w_ncfg popup_posx -2
  else did -a popups 40 $ncfg(popup_posx)
  if (!$ncfg(popup_posy)) w_ncfg popup_posy -120
  else did -a popups 41 $ncfg(popup_posy)
  if (!$ncfg(popup_centerx)) w_ncfg popup_centerx o
  if (!$ncfg(popup_centery)) w_ncfg popup_centery o
  if ($ncfg(popup_centerx) == 1) { did -b popups 40 | did -c popups 250 }
  if ($ncfg(popup_centery) == 1) { did -b popups 41 | did -c popups 251 }
  did -a popups 17 Bottom left
  did -a popups 17 Bottom right (default)
  did -a popups 17 Top left
  did -a popups 17 Top right
}
on *:dialog:popups:sclick:100:{
  if ($did(popups,10).state == 1) w_ncfg popup_nick 1
  else w_ncfg popup_nick o
  if ($did(popups,11).state == 1) w_ncfg popup_query 1
  else w_ncfg popup_query o
  if ($did(popups,12).state == 1) w_ncfg popup_dcc 1
  else w_ncfg popup_dcc o
  if ($did(popups,13).state == 1) w_ncfg popup_discon 1
  else w_ncfg popup_discon o
  if ($did(popups,14).state == 1) w_ncfg popup_other 1
  else w_ncfg popup_other o
  if ($did(popups,3).state == 1) w_ncfg popup_query_always 1 
  else w_ncfg popup_query_always o 
  if ($did(popups,6).state == 1) w_ncfg popup_mode 2
  elseif ($did(popups,7).state == 1) w_ncfg popup_mode 3 
  elseif ($did(popups,8).state == 1) w_ncfg popup_mode 4
  if ($did(popups,4).state == 1) w_ncfg popup_away 1
  else w_ncfg popup_away o
  if ($did(popups,9) !isnum 1-60) { .echo -qg $n.input(Enter a valid number between 1 and 60.,info) | did -f popups 9 | halt }
  w_ncfg popup_timeout $did(popups,9)
  if ($did(popups,250).state == 1) w_ncfg popup_centerx 1
  else w_ncfg popup_centerx o
  if ($did(popups,251).state == 1) w_ncfg popup_centery 1
  else w_ncfg popup_centery o
  if ($remove($did(popups,40),$chr(45),$chr(32)) !isnum) && ($did(popups,250).state != 1) { .echo -qg $n.input(Please enter a valid number value.,info) | did -f popups 40 | halt }
  if ($remove($did(popups,41),$chr(45),$chr(32)) !isnum) && ($did(popups,251).state != 1) { .echo -qg $n.input(Please enter a valid number value.,info) | did -f popups 41 | halt }
  elseif ($remove($did(popups,40),$chr(45),$chr(32)) !isnum) return
  elseif ($remove($did(popups,41),$chr(45),$chr(32)) !isnum) return
  w_ncfg popup_posx $remove($did(popups,40),$chr(32))
  w_ncfg popup_posy $remove($did(popups,41),$chr(32))

}
on *:dialog:popups:sclick:17:{
  if (bottom r isin $did(popups,17).seltext) {
    did -ra popups 40 -5
    did -ra popups 41 -83
    did -eeuu popups 40,41,250,251
  }
  elseif (top r isin $did(popups,17).seltext) {
    did -ra popups 40 -5
    did -ra popups 41 5
    did -eeuu popups 40,41,250,251
  }
  elseif (bottom l isin $did(popups,17).seltext) {
    did -ra popups 40 5
    did -ra popups 41 -83
  }
  elseif (top l isin $did(popups,17).seltext) {
    did -ra popups 40 5
    did -ra popups 41 5
  }
}
on *:dialog:popups:sclick:206:{
  var %text = Preview notification at $iif($did(popups,250).state == 1,(center),$did(popups,40)) $+ x $+ $iif($did(popups,251).state == 1,(center),$did(popups,41))
  var %h = $calc($height(l,$window(status window).font,$window(status window).fontsize) +25), %w = 250
  if ($window(@n.popup)) close -@ @n.popup
  if ($chr(45) isin $did(popups,40)) && ($did(popups,250).state == 0) { var %x = $calc($window(-1).w - (%w + $remove($did(popups,40),-))) }
  elseif ($chr(45) !isin $did(popups,40)) && ($did(popups,250).state == 0) { var %x = $did(popups,40) } 
  elseif ($did(popups,250).state == 1) { var %x = $calc($window(-1).w / 2 - (%w /2)) }
  if ($chr(45) isin $did(popups,41)) && ($did(popups,251).state == 0)  { var %y = $calc($window(-1).h - $remove($did(popups,41),-) ) }
  elseif ($chr(45) !isin $did(popups,41)) && ($did(popups,251).state == 0) { var %y = $did(popups,41) }
  elseif ($did(popups,251).state == 1) { var %y = $calc($window(-1).h / 2 - (25+ %h)) }
  window -hdfonp +dL @n.popup %x %y %w %h
  window -o @n.popup
  drawfill @n.popup $color(background) 0 1 1
  drawtext -o @n.popup $color(highlight) tahoma 10 4 2 Preview
  drawtext -o @n.popup $color(info) tahoma 10 $calc(%w -51) 2 $time
  drawtext @n.popup $color(normal) $window(status window).font $window(status window).fontsize 4 20 %text 
  drawrect @n.popup $color(normal) 0 0 0 %w %h
  if ($timerncpopup) .timerncpopup off
  .timerncpopup -oi 1 $iif($ncfg(popup_timeout),$ifmatch,6) close -@ @n.popup
}
on *:dialog:popups:sclick:250:{
  if ($did(popups,250).state == 1) did -b popups 40 
  else did -e popups 40
}
on *:dialog:popups:sclick:251:{
  if ($did(popups,251).state == 1) did -b popups 41 
  else did -e popups 41
}

dialog exportlog {
  title "Saving log..."
  icon $scriptdiri.dll,18
  size -1 -1 50 10
  option dbu
  text "", 1, 1 6 50 7, center
  button "-", 2, 300 300 30 10, disable ok
}
On *:DIALOG:exportlog:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetDialog $dname style dlgframe
}

; Theme management dialog
alias theme {
  if ($1) {
    if ($1 == -r) {
      set %poaksdfopka 1
      byt-tema $left($nopath($isalias(tname).fname),-4)
    }
    else byt-tema $1-
  }
  else dlg tema
}
dialog tema {
  title "Theme (/theme)"
  size -1 -1 197 151
  option dbu
  icon $scriptdirdll\i.dll, 17
  icon 2, 1 22 193 105,  $scriptdirtema\blank.png, 0
  combo 4, 1 9 83 117, sort size drop
  button "Change", 3, 164 8 30 11
  button "Edit theme", 12, 1 139 45 11
  button "Settings", 11, 82 139 37 11
  button "OK", 5, 120 139 37 11, ok
  button "Close", 6, 158 139 37 11, cancel
  text "Theme:", 9, 1 1 25 8
  text "Font:", 10, 165 1 25 7
  text "", 13, 2 129 139 9
  text "", 1, 148 129 45 9, right
}
on *:dialog:tema:init:0:{
  did -ar tema 13 $findfile($scriptdirtema,*.tem,0,1,did -a tema 4 $replace($left($nopath($1-),-4),-,: $chr(32))  ) themes available
  var %x = $left($nopath($isalias(tname).fname),-4)
  did -c tema 4 $n.cbgn(tema,4,$replace(%x,-,: $+ $chr(32)))
  if ($exists($+(",$scriptdirtema\,%x,.bmp,"))) did -g tema 2 $+(",$mircdirscripts\tema\,%x,.bmp,")
  elseif ($exists($+(",$scriptdirtema\,%x,.png,"))) did -g tema 2 $+(",$mircdirscripts\tema\,%x,.png,")
  did -a tema 1 $round($calc($file($qt($mircdirscripts\tema\ $+ %x $+ .tem)).size /1024),2) KB
}
on *:dialog:tema:sclick:11:dlg tsettings
on *:dialog:tema:sclick:12:tedit $replace($did(tema,4).seltext,: $+ $chr(32),-)
on *:dialog:tema:sclick:4:{
  var %x = $replace($did(tema,4).seltext,: $+ $chr(32),-)
  if ($exists($+(",$mircdirscripts\tema\,%x,.bmp,"))) did -g tema 2 $+(",$scriptdirtema\,%x,.bmp,")
  elseif ($exists($+(",$scriptdirtema\,%x,.png,"))) did -g tema 2 $+(",$scriptdirtema\,%x,.png,")
  else did -g tema 2 $qt($scriptdirtema\blank.png)
  did -a tema 13 $right($read($qt($scriptdirtema\ $+ %x $+ .tem),1),-1)
  did -a tema 1 $round($calc($file($qt($scriptdirtema\ $+ %x $+ .tem)).size /1024),2) KB
}
on *:dialog:tema:sclick:5:{
  if ($did(tema,4).seltext) .timer -m 1 300 byt-tema $replace($did(tema,4).seltext,: $+ $chr(32),-)
}
dialog tsettings {
  title "Theme settings"
  size -1 -1 89 37
  option dbu
  icon $scriptdirdll\i.dll, 22
  check "Apply theme colors for nick list", 1, 2 2 84 10, 
  check "Apply theme fonts", 2, 2 12 62 10, 
  button "OK", 100, 51 25 37 11, ok
}
on *:dialog:tsettings:init:0:{
  n.ds cr 1 nicklist_use_themed_colors
  n.ds cr 2 use_theme_fonts
}
on *:dialog:tsettings:sclick:1:n.ds cw 1 nicklist_use_themed_colors
on *:dialog:tsettings:sclick:2:n.ds cw 2 use_theme_fonts
dialog tedit {
  title "tedit"
  size -1 -1 169 228
  option dbu
  icon $scriptdirdll\i.dll,16
  box "Colors", 76, 3 25 163 129
  box "Style", 75, 3 155 163 58
  box "Basics", 77, 3 1 163 22
  edit "", 1, 24 8 50 11, autohs
  edit "", 2, 93 8 67 11, autohs
  edit "", 3, 7 43 155 95, multi return autovs vsbar
  button "Get current colors", 6, 87 139 75 11
  edit "", 4, 8 178 153 11, autohs
  text "Name:", 12, 7 10 17 8
  text "Info:", 13, 79 10 13 8
  combo 5, 71 163 90 60, drop
  text "Select item:", 7, 7 165 31 8
  text "", 8, 9 192 152 17
  button "Save as", 11, 91 216 37 11
  button "Cancel", 10, 129 216 37 11, cancel
  text "Tip: setup colors using mIRC's color dialog (Alt+k)", 9, 8 34 143 8
}
on *:dialog:tedit:init:0:{
  var %x = $+(",$scriptdirtema\,%tedit,.tem,"), %i = 3, %r
  if ($exists(%x)) {
    dialog -t tedit Theme editor: %tedit
    did -a tedit 1 $gettok($read(%x,nw,alias tname*),4,32)
    did -a tedit 2 $right($read(%x,1),-1)
    while (%r != $chr(125) && (%i < 100)) {
      var %r = $read(%x,n,%i)
      did -a tedit 3 %r $+ $crlf
      inc %i
    }
    did -d tedit 3 $calc($did(tedit,3).lines -1)
    did -a tedit 5 - Theme style:
    did -a tedit 5 Me style
    did -a tedit 5 Nick style
    did -a tedit 5 Bracket style 1
    did -a tedit 5 Bracket style 2
    did -a tedit 5 Quote style
    did -a tedit 5 Prefix
    did -a tedit 5 Timestamp
    did -a tedit 5 Font
    did -a tedit 5 - Nicklist colors:
    did -a tedit 5 Me color
    did -a tedit 5 Op color
    did -a tedit 5 Voice color
    did -a tedit 5 Regular color
    set %tedit.me.style $gettok($read(%x,nw,*me.style*),4-,32)
    set %tedit.nick.style $gettok($read(%x,nw,*nick.style*),4-,32)
    set %tedit.par.style $gettok($read(%x,nw,*par.style*),4-,32)
    set %tedit.bracket.style $gettok($read(%x,nw,*bracket.style*),4-,32)
    set %tedit.pre $gettok($read(%x,nw,*pre*),4-,32)
    set %tedit.quote.style $gettok($read(%x,nw,*quote.style*),4-,32)
    set %tedit.ttimestamp $gettok($read(%x,nw,*ttimestamp*),4-,32)
    set %tedit.tfont $gettok($read(%x,nw,*tfont*),4-,32)
    set %tedit.me.clr $gettok($read(%x,nw,*me.clr*),4-,32)
    set %tedit.op.clr $gettok($read(%x,nw,*op.clr*),4-,32)
    set %tedit.voice.clr $gettok($read(%x,nw,*voice.clr*),4-,32)
    set %tedit.normal.clr $gettok($read(%x,nw,*normal.clr*),4-,32)
  }
}
on *:dialog:tedit:sclick:5:{
  if ($did(tedit,5)) {
    var %x = $replace($replace($did(tedit,5),bracket style 1,par.style,bracket style 2,bracket.style,prefix,pre,timestamp,ttimestamp,font,tfont,me color,me.clr,op color,op.clr,voice color,voice.clr,regular color,normal.clr),$chr(32),.)
    var %f = $+($scriptdirtema\,%tedit,.tem)
    did -ar tedit 4 %tedit. [ $+ [ %x ] ]
    did -ar tedit 8 $gettok($read($scriptdirtxt\tedit.txt,nw,%x $+ *),2-,44)
  }
}
on *:dialog:tedit:edit:4:{
  if ($did(tedit,4)) && (- !isin $did(tedit,5)) && (- !isin $did(tedit,5)) {
    var %x = $replace($replace($did(tedit,5),bracket style 1,par.style,bracket style 2,bracket.style,prefix,pre,timestamp,ttimestamp,font,tfont,me color,me.clr,op color,op.clr,voice color,voice.clr,regular color,normal.clr),$chr(32),.)
    set %tedit. [ $+ [ %x ] ] $did(tedit,4)
  }
}
on *:dialog:tedit:sclick:6:{
  did -r tedit 3
  color_gen
}
on *:dialog:tedit:sclick:11:{
  if (!$did(tedit,1)) return
  var %x = $n.input(Enter theme filename:,$replace($did(tedit,1),/,-) $+ .tem)
  if (%x) {
    var %x = $qt($scriptdirtema\ $+ %x $+ $iif($right(%x,4) != .tem,.tem)), %i = 1
    if ($exists(%x)) && (!$n.input(Overwrite $nopath(%x) $+ ?,y/n)) return
    write -c %x $chr(59) $+ $did(tedit,2)
    write %x alias tclr $chr(123)
    while (%i <= $did(tedit,3).lines) {
      write %x $did(tedit,3,%i)
      inc %i
    }
    write %x $chr(125)
    write %x alias tname return $did(tedit,1)
    write %x alias nick.style return %tedit.nick.style
    write %x alias me.style return %tedit.me.style
    write %x alias par.style return %tedit.par.style
    write %x alias bracket.style return %tedit.bracket.style
    if (%tedit.quote.style) write %x alias quote.style return %tedit.quote.style
    write %x alias pre return %tedit.pre
    write %x alias ttimestamp return %tedit.ttimestamp
    if (%tedit.tfont) write %x alias tfont return %tedit.tfont
    write %x alias me.clr return $replace(%tedit.me.clr,z,$chr(48))
    write %x alias op.clr return $replace(%tedit.op.clr,z,$chr(48))
    write %x alias voice.clr return $replace(%tedit.voice.clr,z,$chr(48))
    write %x alias normal.clr return $replace(%tedit.normal.clr,z,$chr(48))
    if ($n.input(Theme saved as $nopath(%x) $+ . $crlf $crlf $+ Do you want to $iif($nopath($isalias(tname).fname) == $nopath(%x),reload,load) the theme now?,y/n)) {
      set %generatepreview 1
      if ($nopath(%x) == $nopath($isalias(tname).fname)) theme -r
      else theme $left($nopath(%x),-4)
      if ($dialog(tema)) dialog -x tema
    }
    dialog -x tedit
  }
}

; Font settings dialog
alias fc {
  if ($2) {
    font -z $1-
  }
  else dlg font font
}
dialog font {
  title "Font settings (/fc)"
  size -1 -1 103 91
  option dbu
  icon $scriptdirdll\i.dll,16
  text "Font:", 2, 2 2 14 8
  text "Size:", 3, 65 2 23 8
  combo 1, 1 10 61 68, edit
  combo 4, 65 10 24 54, edit
  check "Bold", 7, 65 64 24 11, push
  button "?", 8, 90 10 12 11
  button "Set", 5, 41 79 30 11, ok
  button "Cancel", 6, 72 79 30 11, cancel
  button "Default", 9, 1 79 31 11
}
on *:dialog:tema:sclick:3:fc
on *:dialog:font:init:0:{
  if ($window(status window).font) did -a font 1 $ifmatch
  if ($window(status window).fontbold) did -c font 7
  if ($window(status window).fontsize) did -a font 4 $ifmatch
  did -c font 4 1
  did -c font 1 1
  did -a font 1 Verdana
  did -a font 1 Fixedsys
  did -a font 1 Tahoma
  did -a font 1 Arial
  did -a font 1 Courier New
  did -a font 1 Trebuchet MS
  did -a font 1 Terminal
  did -a font 4 9
  did -a font 4 10
  did -a font 4 11
  did -a font 4 12
  did -a font 4 -8
}
on *:dialog:font:sclick:9:{
  did -c font 1 4
  did -c font 4 4
}
on *:dialog:font:sclick:8:.echo -qg $n.input(Use negative size values (eg: -8) to match default font sizes (pt) instead of px.,info)
on *:dialog:font:sclick:5:{
  if ($did(font,7).state == 1) var %p = -zb
  else var %p = -z
  font %p $did(4).text $did(1).text
}

; /nq dialog
alias nq dlg np
dialog np {
  title "Sound/highlight settings (/nq)"
  size -1 -1 149 119
  option dbu
  icon $scriptdirdll\i.dll, 22
  box "On nick", 1, 2 2 145 36
  check "Enable 'beep' sound", 3, 8 11 61 10
  check "Highlight nick matches with color:", 2, 8 23 89 10
  combo 9, 99 22 21 110, limit 2 drop
  button "Show", 14, 122 22 20 11
  box "On query/msg", 4, 2 40 145 64
  check "Enable Sound", 5, 8 48 49 10
  radio "Default", 6, 12 58 35 10
  radio "Internal mIRC beep", 7, 12 69 63 10
  radio "Custom:", 8, 12 80 30 10
  edit "", 10, 43 79 100 11, read autohs
  button "...", 11, 117 91 25 10
  check "Only play sound when query opens", 13, 8 92 101 10
  button "Exclude...", 15, 72 107 37 11
  button "OK", 12, 110 107 37 11, ok
}
On *:DIALOG:np:init:0:{
  if ($ncfg(query_sound_onopen) == 1) { did -c np 13 }
  if ($ncfg(nickpip) == 1) { did -c np 3 }
  if ($ncfg(nickbar) == 1) { did -c np 2 }
  if ($ncfg(privpip) == 1) { did -c np 5 }
  if ($ncfg(highlight_nick_color)) { did -a np 9 $ncfg(highlight_nick_color) }  
  if ($ncfg(privljud) == beep) { did -c np 7 }
  elseif ($ncfg(privljud) == psljud) { did -c np 6 }
  else { did -c np 8 }
  did -a np 10 $right($ncfg(privljud),-6)
  did -a np 9 -
  var %i = 0
  while (%i < 16) {
    did -a np 9 %i
    inc %i
  }
  did -c np 9 1
}
on *:dialog:np:sclick:14:n.preview np 1,0 0 0,1 1 0,2 2 0,3 3 0,4 4 0,5 5 0,6 6 0,7 7 1,8 8 1,9 9 0,10 10 1,11 11 0,12 12 0,13 13 0,14 14 1,15 15 $+ $chr(160)
on *:dialog:np:sclick:15:{
  if ($n.input(Disable highlight for these addresses/nicks $+ $c44 separate with comma ( $+ $c44 $+ ) (type off to disable): $crlf $crlf $+ Example: *bot.com $+ $c44 *!*@address.net $+ $c44 nick!*,$ncfg(no_highlight))) w_ncfg no_highlight $ifmatch
}
on *:dialog:np:sclick:12:{
  if ($did(np,3).state == 1) w_ncfg nickpip 1
  else { w_ncfg nickpip o }
  if ($did(np,2).state == 1) w_ncfg nickbar 1
  else { w_ncfg nickbar o }
  if ($did(np,13).state == 1) w_ncfg query_sound_onopen 1
  else { w_ncfg query_sound_onopen o }
  if ($did(np,5).state == 1) w_ncfg privpip 1
  else { w_ncfg privpip o }
  if ($did(np,6).state == 1) w_ncfg privljud psljud
  if ($did(np,7).state == 1) w_ncfg privljud beep
  if ($did(np,9).text isnum 0-16) w_ncfg highlight_nick_color $did(np,9).text

}
On *:DIALOG:np:sclick:11:{
  if ($sfile(*.wav,Select sound file)) {
    w_ncfg privljud splay $ifmatch
    did -c np 8
    did -u np 6,7
    did -ar np 10 $remove($ncfg(privljud),splay)
  }
}


dialog way {
  title "Away"
  size -1 -1 115 53
  option dbu
  icon $scriptdirdll\i.dll, 17
  text "Msg:", 1, 1 17 11 8
  text "Nick:", 5, 1 5 12 8
  combo 10, 15 3 70 100, edit drop
  button "?", 3, 87 3 13 10
  button ">", 4, 102 3 12 10
  combo 11, 15 15 85 100, edit drop
  button ">", 6, 102 15 12 10
  check "Set away on all servers", 12, 3 27 71 11, 
  check "Change nick", 2, 74 27 40 11, 
  button "Set away", 100, 39 41 37 11, ok
  button "Close", 101, 77 41 37 11, cancel

}
On *:DIALOG:way:init:0:{
  if ($ncfg(awaynbyte) == 1) { did -c way 2 }
  if ($scon(0) < 2) { did -b way 12 }
  if ($ncfg(awayallanets) == 1) { did -c way 12 }
  loadbuf -o way 10 config\awaynick.txt
  loadbuf -o way 11 config\awaymsg.txt 
  did -c way 10 1
  did -c way 11 1
}
On *:DIALOG:way:sclick:3:.echo -qg $n.input(If you use [nick] it will be replaced with your nickname when going away. $crlf $crlf $+ eg: [nick]|away would result in $me $+ |away,info)
On *:DIALOG:way:sclick:4:{ txt config\awaynick.txt | set %txtload loadbuf -o way 10 config\awaynick.txt }
On *:DIALOG:way:sclick:6:{ txt config\awaymsg.txt | set %txtload loadbuf -o way 11 config\awaymsg.txt }
On *:DIALOG:way:sclick:100:{
  if ($did(way,2).state == 1) { 
    w_ncfg awaynbyte 1
    var %x = n
  }
  else {
    var %x = x
    w_ncfg awaynbyte o
  }
  if ($did(way,12).state == 1) { 
    w_ncfg awayallanets 1
    var %c = scon -at1 _away
  }
  else { 
    w_ncfg awayallanets o
    var %c = _away
  }
  if ($did(way,10).text) {
    n.history config\awaynick.txt $did(way,10).text
    var %nick = $replace($did(way,10).text,[nick],$me)
  }
  if ($did(way,11).text) {
    n.history config\awaymsg.txt $did(way,11).text
    var %msg = $did(way,11).text
  }
  %c %x %nick %msg
}
alias _away {
  if (!$2) return 
  if ($1 == n) {
    set %oldnick. [ $+ [ $cid ] ] $me
    tnick $2
  }
  if ($3) away $3-
}
alias _back {
  if (%oldnick. [ $+ [ $cid ] ] ) tnick %oldnick. [ $+ [ $cid ] ] 
  unset %oldnick. [ $+ [ $cid ] ] 
  away
}
dialog back {
  title "Back"
  size -1 -1 77 45
  option dbu
  icon $scriptdirdll\i.dll, 17
  check "Don't change nick", 1, 2 1 90 10, 
  check "All networks", 5, 2 11 47 10, 
  button "Back", 3, 1 33 37 11, ok
  button "Cancel", 4, 39 33 37 11, cancel
}
on *:DIALOG:back:init:0:{
  if ($ncfg(awaynbyte) == 1) {
    if ($awaynet < 2) if (%oldnick. [ $+ [ $cid ] ] ) did -a back 1 Don't change nick to %oldnick. [ $+ [ $cid ] ]
    else did -a back 1 Don't change nicks
  }
  else did -b back 1
  if ($ncfg(awayallanets) == 1) did -c back 5
}
on *:DIALOG:back:sclick:3:{
  if ($did(back,1).state == 1) unset %oldnick.*
  $iif($did(back,5).state == 1,scon -at1) _back
}
dialog 1st {
  title "Minimize"
  size -1 -1 125 67
  option dbu
  icon $scriptdirdll\i.dll, 17
  radio "Taskbar:", 2, 7 15 31 10, 
  radio "Tray:", 3, 7 34 27 10, 
  icon 4, 40 12 78 16,  $scriptdirimg\taskbar.png, 0, noborder
  icon 5, 40 31 78 16,  $scriptdirimg\tray.png, 0, noborder
  button "OK", 6, 85 54 37 11, ok
  box "Minimize mIRC/nbs-irc to:", 7, 3 2 119 49
}
On *:dialog:1st:init:0:did -c 1st 2
On *:dialog:1st:sclick:6:{
  if ($did(1st,2).state == 1) tray -t0
  else tray -t1
}
dialog unet {
  title "UnderNet setup (/undernet)"
  size -1 -1 107 81
  option dbu
  icon $scriptdirdll\i.dll, 17
  box "X Auth (/auth)", 1, 2 2 103 65
  edit "", 5, 36 10 64 11, autohs
  edit "", 6, 36 22 64 11, pass autohs
  check "Auth automatically on connect", 4, 6 36 88 9, 
  check "Hide host (mode +x)", 11, 6 45 67 10, 
  check "Auto join channel if invited by X", 15, 6 54 92 10, 
  text "Auth nick:", 7, 6 12 28 8
  text "Password:", 9, 6 23 27 8
  button "Auth now", 10, 29 69 37 11
  button "OK", 3, 68 69 37 11, ok
}
On *:dialog:unet:init:0:{
  var %q = $ncfg(undernet_authpass), %k = $calc($len(%q) +1), %x = 1, %r
  while (%k > 1) {
    var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
    inc %x 1
  }
  n.ds cr 15 undernet_bot_autojoin
  if ($ncfg(undernet_authnick)) did -a unet 5 $ifmatch
  if ($ncfg(undernet_authpass)) did -a unet 6 %r
  n.ds cr 4 undernet_autoauth
  n.ds cr 11 undernet_mode+x
}
On *:dialog:unet:sclick:10:if (($did(unet,5).text) && ($did(unet,6).text)) { .msg x@channels.undernet.org login $did(unet,5).text $did(unet,6).text | n.echo normal -atg sending auth $par($did(unet,5).text) }
On *:dialog:unet:sclick:3:{
  if ($did(unet,5).text) w_ncfg undernet_authnick $ifmatch
  if ($did(unet,6).text) w_ncfg undernet_authpass $bfe($ifmatch)
  n.ds cw 4 undernet_autoauth
  n.ds cw 11 undernet_mode+x 1
  n.ds cw 15 undernet_bot_autojoin
}

dialog qnet {
  title "QuakeNet setup (/quakenet)"
  size -1 -1 107 90
  option dbu
  icon $scriptdirdll\i.dll, 17
  box "Q Auth (/auth)", 1, 2 2 103 74
  edit "", 5, 36 10 64 11, autohs
  edit "", 6, 36 22 64 11, pass autohs
  check "Auth automatically on connect", 4, 6 36 88 9, 
  check "Hide host (mode +x)", 11, 6 45 67 10, 
  check "Use challenge auth (more secure)", 14, 6 54 94 10, 
  check "Auto join channel if invited by Q/L", 15, 6 63 94 10, 
  text "Auth nick:", 7, 6 12 28 8
  text "Password:", 9, 6 23 27 8
  button "Auth now", 10, 29 78 37 11
  button "OK", 3, 68 78 37 11, ok
}
On *:dialog:qnet:init:0:{
  var %q = $ncfg(authpass), %k = $calc($len(%q) +1), %x = 1, %r
  while (%k > 1) {
    var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
    inc %x 1
  }
  n.ds cr 14 use_challengeauth
  n.ds cr 15 quakenet_bot_autojoin
  if ($ncfg(authnick)) did -a qnet 5 $ifmatch
  if ($ncfg(authpass)) did -a qnet 6 %r
  n.ds cr 4 autoauth
  n.ds cr 11 mode+x
}
On *:dialog:qnet:sclick:10:if (($did(qnet,5).text) && ($did(qnet,6).text)) { .msg Q@CServe.quakenet.org auth $did(qnet,5).text $did(qnet,6).text | n.echo normal -atg sending auth $par($did(qnet,5).text) }
On *:dialog:qnet:sclick:3:{
  if ($did(qnet,5).text) { w_ncfg authnick $ifmatch }
  if ($did(qnet,6).text) { w_ncfg authpass $bfe($ifmatch) }
  if ($did(qnet,4).state == 1) { w_ncfg autoauth 1 }
  else { w_ncfg  autoauth o }
  if ($did(qnet,11).state == 1) { w_ncfg mode+x 1 }
  else { w_ncfg mode+x o }
  n.ds cw 14 use_challengeauth
  n.ds cw 15 quakenet_bot_autojoin
}
dialog misc {
  title "Miscellaneous settings (/misc)"
  size -1 -1 232 154
  option dbu
  icon $scriptdirdll\i.dll, 22
  box "Titlebar", 22, 3 119 110 21
  box "Ban mask", 19, 116 42 114 35
  box "Minimize", 13, 116 110 114 30
  box "Functionality", 27, 3 42 110 75
  box "When kicked", 28, 116 1 114 39
  box "Edit messages", 6, 116 78 114 30
  box "General", 16, 3 1 110 39
  check "Always show mode prefix (@%+ etc)", 15, 7 9 100 10
  check "Reclaim nick after dis/reconnect", 12, 7 18 102 10
  check "Check for new versions", 25, 7 27 100 10
  check "Use own window for whois replys", 18, 7 50 99 10
  check "Open whois window inside mIRC", 17, 7 59 99 10
  check "Use own window for highlights", 21, 7 68 97 10
  check "Enable extended toolbar", 5, 7 77 79 10
  check "Enable extended channel central", 8, 7 86 99 10
  check "Enable automatic lag check", 29, 7 95 97 10
  check "Show 'day changed' at 0:00", 30, 7 104 82 10
  check "Show version", 23, 7 127 54 10
  check "Show lag", 24, 67 127 36 10
  check "Auto whois the 'kicker'", 26, 121 9 92 10
  check "Auto rejoin channel, wait", 1, 121 18 90 10
  edit "", 9, 129 28 15 10, autohs
  text "seconds", 10, 145 29 23 8
  button "?", 11, 214 26 13 11
  combo 20, 122 61 102 83, drop
  button "Quit msgs", 2, 120 89 34 11
  button "Kick msgs", 4, 156 89 34 11
  button "Slaps", 3, 192 89 34 11
  button "Change minimize settings", 14, 120 122 106 11
  button "OK", 7, 193 142 37 11, ok
  text "Use this mask when banning:", 31, 121 52 76 8
}
on *:dialog:misc:init:0:{
  if ($ncfg(ar_time) isnum) did -a misc 9 $ncfg(ar_time) 
  if ($ncfg(whois) == @whois) did -c misc 18
  did -a misc 20 *!ident@host.com $str( ,99) z
  did -a misc 20 *!*ident@host.com (default) $str( ,99) 1
  did -a misc 20 *!*@host.com $str( ,99) 2
  did -a misc 20 *!*ident@*.com $str( ,99) 3
  did -a misc 20 *!*@*.com $str( ,99) 4
  did -a misc 20 nick!ident@host.com $str( ,99) 5
  did -a misc 20 nick!*ident@host.com $str( ,99) 6
  did -a misc 20 nick!*@host.com $str( ,99) 7
  did -a misc 20 nick!*ident@*.com $str( ,99) 8
  did -a misc 20 nick!*@*.com $str( ,99) 9
  if ($ncfg(ban_mask) isnum) did -c misc 20 $calc($ifmatch +1)
  elseif ($ncfg(ban_mask) == z) did -c misc 20 1
  n.ds cr 26 whois_on_kick
  n.ds cr 1 autorejoin
  n.ds cr 21 nickwin
  n.ds cr 8 newcc
  n.ds cr 5 exttb
  n.ds cr 15 modeprefix
  n.ds cr 17 whois_inside
  n.ds cr 23 titlebar_version
  n.ds cr 24 titlebar_lag
  n.ds cr 12 reclaim_nick
  n.ds cr 25 version_check
  n.ds cr 29 check_lag
  n.ds cr 30 show_daychanged
  if ($group(#url) == on) did -c misc 32
}
On *:dialog:misc:sclick:14:dlg 1st
On *:dialog:misc:sclick:11:var %x = $n.input(mIRC's built in auto-rejoin must be disabled for this to work properly: $crlf $crlf $+ Options (Alt+o) -> IRC -> uncheck "Rejoin channel when kicked",info)
On *:dialog:misc:sclick:33:var %x = $n.input(Enable this if URLs don't load in your default browser. $crlf $crlf $+ Note: this may not work with URLs containing international characters $+ $c44 eg: å ä ö.,info)
On *:dialog:misc:sclick:2:unset %txtload | txt config\quits.txt
On *:dialog:misc:sclick:3:unset %txtload | txt config\slaps.txt
On *:dialog:misc:sclick:4:unset %txtload | txt config\kicks.txt
On *:dialog:misc:sclick:7:{
  n.ds cw 1 autorejoin
  n.ds cw 8 newcc
  n.ds cw 15 modeprefix 
  n.ds cw 17 whois_inside 
  n.ds cw 21 nickwin 
  n.ds cw 23 titlebar_version
  n.ds cw 24 titlebar_lag
  n.ds cw 12 reclaim_nick
  n.ds cw 25 version_check
  n.ds cw 26 whois_on_kick
  n.ds cw 29 check_lag
  n.ds cw 30 show_daychanged
  if ($did(misc,29).state == 0) unset %lag.*
  if ($gettok($did(misc,20),-1,160)) w_ncfg ban_mask $ifmatch
  if ($did(misc,9).text isnum) w_ncfg ar_time $did(misc,9).text
  if ($did(misc,18).state == 1) w_ncfg whois @whois
  else w_ncfg whois -a
  titleupdate
}
on *:dialog:misc:sclick:5:{
  if ($did(misc,5).state == 1) { 
    w_ncfg exttb 1
    n.toolbar
  }
  else { 
    w_ncfg exttb o
    toolbar -r
    if ($dialog(tb)) dialog -x tb
  }
}

dialog hevent {
  title "Hide events"
  size -1 -1 77 47
  option dbu
  icon $scriptdirdll\i.dll, 17
  check "Joins", 1, 3 11 26 10, 
  check "Parts", 2, 3 20 26 10, 
  check "Quits", 3, 31 11 26 10, 
  check "Nick changes", 4, 31 20 45 10, 
  text "Hide these events:", 5, 2 2 54 8
  button "OK", 6, 38 35 37 11, ok
}
on *:dialog:hevent:init:0:{
  if ($ehide(joins,%he.chan)) did -c hevent 1
  if ($ehide(parts,%he.chan)) did -c hevent 2
  if ($ehide(quits,%he.chan)) did -c hevent 3
  if ($ehide(nicks,%he.chan)) did -c hevent 4
  dialog -t hevent %he.chan
}
on *:dialog:hevent:sclick:*:{
  if ($did isnum 1-4) {
    var %x = $replace($did,1,joins,2,parts,3,quits,4,nicks)
    hideshow.event %he.chan %x
    if ($ehide(%x,%he.chan)) did -c hevent $did
    else did -u hevent $did
  }
  elseif ($did == 6) unset %he.chan
}
dialog input {
  title "nbs-irc"
  size -1 -1 129 65
  option dbu
  icon $scriptdirdll\i.dll, 17
  edit "", 1, 2 39 125 11, result autohs
  box "", 2, 2 0 125 36
  box "", 6, 2 0 125 50
  button "OK", 3, 53 53 37 11, ok
  button "Cancel", 5, 91 53 37 11, cancel
  text "", 4, 5 6 119 27
  text "", 10, 5 6 119 41
}
on *:dialog:input:init:0:{
  did -a input 1 %n.input2
  if (%n.input2 == y/n) {
    did -ar input 3 Yes
    did -ar input 5 No
    did -h input 1,2
    did -a input 10 %n.input1
  }
  elseif (%n.input2 == info) {
    did -ar input 5 OK
    did -h input 1,2,3
    did -a input 10 %n.input1
  }
  else {
    did -h input 6,10
    did -a input 4 %n.input1
    did -c input 1 1 1 999
  }
  unset %n.input?
}
dialog tb {
  title "tåålbar"
  size 1 1 700 0
  option pixels
  button "", 1, 235 0 500 14
  button "", 2, 235 13 500 14
  combo 3, 0 2 183 290, size edit drop
  icon 4, 187 4 16 16, $scriptdirdll\i.dll, 13, noborder
  icon 5, 207 4 16 16, $scriptdirdll\i.dll, 14, noborder
  button "", 6, 226 18 5 5, hide ok
}
on *:dialog:tb:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetDialog $dname style
  dll $cit(scripts\dll\mdock61.dll) DockToolbar $dialog(tb).hwnd
  dialog -s tb $iif($ncfg(toolbar_disable_winamp) == 1,361,439) 0 700 0
  n.mdx SetControlMDX tb 1 Text noPrefix > scripts\dll\mdx\ctl_gen.mdx
  n.mdx SetControlMDX tb 2 Text noPrefix > scripts\dll\mdx\ctl_gen.mdx
  n.mdx SetFont tb 1 11 400 tahoma
  n.mdx SetFont tb 2 11 400 tahoma
  titleupdate
  loadbuf -o tb 3 config\kor.txt
}
on *:dialog:tb:sclick:3,4,6:{
  n.tb.enter
  haltdef
}
alias n.tb.enter {
  if ($did(tb,3)) {
    if ($exists($did(tb,3)) || $isfile($did(tb,3) $+ .exe) || (*.exe iswm $did(tb,3)) || ($read($scriptdirtxt\runex.txt,w, * $+ $did(tb,3) $+ *))) run -p $did(tb,3)
    else n.url $did(tb,3)
    n.history config\kor.txt $did(tb,3)
    loadbuf -ro tb 3 config\kor.txt
  }
  did -c tb 3 0
}
on *:dialog:tb:close:0:.timer -m 1 0 dlg tb
on *:dialog:tb:sclick:5:{
  set %txtload loadbuf -o tb 3 config\kor.txt
  set -u10 %tmp.txtfile 1
  txt config\kor.txt
}
dialog skydd {
  title "Protections (/prot)"
  size -1 -1 203 117
  option dbu
  icon $scriptdirdll\i.dll, 22
  tab "Channel", 5, 2 -1 198 103
  combo 1, 50 16 83 66, tab 5 size drop
  text "Channel:", 2, 8 18 25 8, tab 5
  button "Add", 29, 135 16 30 10, tab 5
  button "Remove", 30, 166 16 30 10, tab 5
  check "Flood:", 8, 8 32 27 10, tab 5 
  edit "", 9, 62 31 14 11, tab 5
  edit "", 11, 100 31 13 11, tab 5
  check "Ban", 22, 141 32 21 10, tab 5 
  button "Kick msg", 40, 166 31 30 11, tab 5
  check "Repeat:", 14, 8 45 32 10, tab 5 
  edit "", 16, 62 44 14 11, tab 5
  check "Ban", 23, 141 45 24 10, tab 5 
  button "Kick msg", 41, 166 44 30 11, tab 5
  check "Caps:", 24, 8 59 34 9, tab 5 
  edit "", 25, 62 58 14 11, tab 5
  button "Kick msg", 42, 166 57 30 11, tab 5
  check "Advertising:", 28, 8 72 40 10, tab 5 
  radio "#text", 34, 50 72 26 11, tab 5 
  radio "/j #text, join #text", 35, 77 72 58 11, tab 5 
  check "Ban", 32, 141 72 24 10, tab 5 
  button "Kick msg", 43, 166 70 30 11, tab 5
  check "Punish ops/half-ops", 20, 8 87 66 11, tab 5 
  edit "", 37, 113 87 17 11, tab 5
  text "lines in", 10, 78 33 21 8, tab 5
  text "seconds", 12, 115 33 20 8, tab 5
  text "max", 13, 50 33 12 8, tab 5
  text "max", 15, 50 46 12 8, tab 5
  text "repeats in 10 seconds", 17, 78 46 62 8, tab 5
  text "% caps (minimum 10 chars)", 26, 77 60 79 8, tab 5
  text "max", 27, 50 60 12 8, tab 5
  text "Ban for", 36, 94 89 19 8, tab 5
  text "minutes (0 = permanent)", 33, 132 89 63 8, tab 5
  tab "Personal", 7
  check "Enable ban protection", 3, 7 17 66 10, tab 7 
  edit "", 4, 56 27 100 11, tab 7 autohs
  text "Kick message:", 21, 17 28 37 8, tab 7
  text "Note: CTCP and highlight/query sound flood protection is always enabled.", 31, 7 48 94 14, tab 7
  text "", 99, 200 200 1 1
  button "OK", 6, 163 105 37 11, ok
}
On *:dialog:skydd:init:0:{
  prot.chanlist
  n.ds cr 3 banskydd
  if ($ncfg(bsmed)) did -a skydd 4 $ifmatch
}
On *:dialog:skydd:sclick:40-43:{
  var %x = $replace($did,40,flood,41,repeat,42,caps,43,advertising)
  hadd prot $did(skydd,99) $+ %x $+ .kickmsg $$n.input(Enter kick message for %x violation:,$hget(prot,$+($did(skydd,99),%x,.kickmsg)))
}
On *:dialog:skydd:sclick:29:{
  var %x = $n.input(Enter channel to add:,$iif($active ischan,$active,$chr(35)))
  if ($chr(35) isin %x) || ($chr(38) isin %x) {
    prot.save
    did -ar skydd 99 %x
    did -i skydd 1 1 %x
    hadd -m prot chans $hget(prot,chans) $chr(1) $+ %x
    did -c skydd 1 1
    did -e skydd 8,14,24,28,9,11,22,16,23,25,32,34,35,37,20,40-43
    did -ar skydd 9 10
    did -ar skydd 11 5
    did -ar skydd 16 3
    did -ar skydd 25 70
    did -ar skydd 37 15
    did -c skydd 34
    did -u skydd 8,14,24,28,22,23,32,34,35,20
  }
  elseif (!%x) return
  else .echo -qg $n.input(Error: enter a valid channel.,info)
}
On *:dialog:skydd:sclick:30:{
  if ($did(skydd,1)) && ($n.input(Do you want to remove all settings for $did(skydd,1).seltext $+ ?,y/n)) {
    did -r skydd 99
    if ($numtok($hget(prot,chans),32) == 1) hdel prot chans
    hadd -m prot chans $remove($hget(prot,chans),$chr(1) $+ $did(skydd,1))
    hdel -w prot $did(skydd,1) $+ *
    prot.chanlist
  }
}

On *:dialog:skydd:sclick:1:{
  if ($did(skydd,1)) {
    prot.save
    var %x = $did(skydd,1)
    did -ar skydd 99 $did(skydd,1)
    did -e skydd 8,14,24,28,9,11,22,16,23,25,32,34,35,37,20,40-43
    did -r skydd 9,11,16,25,37
    did -u skydd 8,14,24,28,22,23,32,34,35,20
    if ($hget(prot,$+(%x,flood)) == 1) did -c skydd 8
    if ($hget(prot,$+(%x,flood.lines)) isnum) did -ar skydd 9 $ifmatch
    if ($hget(prot,$+(%x,flood.seconds)) isnum) did -ar skydd 11 $ifmatch
    if ($hget(prot,$+(%x,flood.ban)) == 1) did -c skydd 22
    if ($hget(prot,$+(%x,repeat)) == 1) did -c skydd 14
    if ($hget(prot,$+(%x,repeat.max)) isnum) did -ar skydd 16 $ifmatch
    if ($hget(prot,$+(%x,repeat.ban)) == 1) did -c skydd 23
    if ($hget(prot,$+(%x,caps)) == 1) did -c skydd 24
    if ($hget(prot,$+(%x,caps.maxpercent)) isnum) did -ar skydd 25 $ifmatch
    if ($hget(prot,$+(%x,advertising)) == 1) did -c skydd 28
    if ($hget(prot,$+(%x,advertising.type)) == 1) did -c skydd 34
    else did -c skydd 35
    if ($hget(prot,$+(%x,advertising.ban)) == 1) did -c skydd 32
    if ($hget(prot,$+(%x,punishops)) == 1) did -c skydd 20
    if ($hget(prot,$+(%x,bantime)) isnum) did -ar skydd 37 $ifmatch
  }
}
alias -l prot.save {
  if ($did(skydd,99)) {
    var %x = $ifmatch
    if ($did(skydd,8).state == 1) hadd prot $+(%x,flood) 1
    else hdel prot $+(%x,flood)
    if ($did(skydd,9).text isnum) hadd prot $+(%x,flood.lines) $ifmatch
    else hdel prot $+(%x,flood.lines)
    if ($did(skydd,11).text isnum) hadd prot $+(%x,flood.seconds) $ifmatch
    else hdel prot $+(%x,flood.seconds)
    if ($did(skydd,22).state == 1) hadd prot $+(%x,flood.ban) 1
    else hdel prot $+(%x,flood.ban)
    if ($did(skydd,14).state == 1) hadd prot $+(%x,repeat) 1
    else hdel prot $+(%x,repeat)
    if ($did(skydd,16).text isnum) hadd prot $+(%x,repeat.max) $ifmatch
    else hdel prot $+(%x,repeat.max)
    if ($did(skydd,23).state == 1) hadd prot $+(%x,repeat.ban) 1
    else hdel prot $+(%x,repeat.ban)
    if ($did(skydd,24).state == 1) hadd prot $+(%x,caps) 1
    else hdel prot $+(%x,caps)
    if ($did(skydd,25).text isnum) hadd prot $+(%x,caps.maxpercent) $ifmatch
    else hdel prot $+(%x,caps.maxpercent)
    if ($did(skydd,28).state == 1) hadd prot $+(%x,advertising) 1
    else hdel prot $+(%x,advertising)
    if ($did(skydd,34).state == 1) hadd prot $+(%x,advertising.type) 1
    else hadd prot $+(%x,advertising.type) 2
    if ($did(skydd,32).state == 1) hadd prot $+(%x,advertising.ban) 1
    else hdel prot $+(%x,advertising.ban)
    if ($did(skydd,20).state == 1) hadd prot $+(%x,punishops) 1
    else hdel prot $+(%x,punishops)
    if ($did(skydd,37).text isnum) hadd prot $+(%x,bantime) $ifmatch
    else hdel prot $+(%x,bantime)
  }
}
alias -l prot.chanlist {
  did -b skydd 8,14,24,28,9,11,22,16,23,25,32,34,35,37,20,40-43
  did -r skydd 1
  if ($hget(prot,chans)) {
    tokenize 1 $ifmatch
    var %i = 1
    while (%i <= $0) {
      did -a skydd 1 [ $chr(36) $+ [ %i ] ]
      inc %i
    }
  }
}

on *:dialog:skydd:sclick:6:{
  prot.save
  hsave -i prot config\config.ini protections
  if ($did(skydd,4)) w_ncfg bsmed $did(skydd,4).text
  n.ds cw 3 banskydd 1

}

dialog pcw {
  title "Seek cw/pcw"
  size -1 -1 207 36
  option dbu
  combo 2, 30 11 30 50, size edit drop
  combo 3, 2 11 25 50, size edit drop
  combo 5, 64 11 43 50, size edit drop
  button "Close", 7, 176 25 30 10, ok
  combo 8, 110 11 70 50, size edit drop
  button "Seek", 9, 145 25 30 10
  text "players:", 10, 35 2 22 8
  text "pcw/cb:", 11, 2 2 19 8
  text "server:", 13, 65 2 20 8
  text "other:", 14, 111 2 25 8
  text "seperator:", 15, 176 2 27 8
  combo 16, 186 11 20 50, size edit drop
  radio "say", 20, 68 26 20 10, 
  radio "amsg", 21, 89 26 24 10, 
  ;radio "amsg2", 1, 115 26 28 10, 
}

On *:dialog:pcw:init:0:{
  did -a pcw 2 5on5
  did -a pcw 2 4on4
  did -a pcw 2 3on3  
  did -a pcw 2 2on2
  did -c pcw 2 1
  did -a pcw 3 pcw
  did -a pcw 3 cb
  did -c pcw 3 1
  did -a pcw 5 our server
  did -a pcw 5 your server  
  did -a pcw 5 vår server
  did -a pcw 5 er server
  did -c pcw 5 1
  did -a pcw 8 1 map
  did -a pcw 8 /msg $me
  did -a pcw 8 time:
  did -a pcw 8 points:
  did -a pcw 16 .
  did -a pcw 16 -
  did -a pcw 16 _
  did -a pcw 16 $chr(124)
  did -c pcw 16 1
  if ($ncfg(smsg) == amsg) { w_ncfg smsg amsg | did -c pcw 21 }
  else { w_ncfg smsg say | did -c pcw 20 }
}
On *:dialog:pcw:sclick:9:{
  $ncfg(smsg) $did(pcw,3).text $did(pcw,16).text $did(pcw,2).text $did(pcw,16).text $did(pcw,5).text $iif($did(pcw,8).text,$did(pcw,16).text) $did(pcw,8).text
}
on *:dialog:pcw:sclick:21:{
  if ($did(pcw,21).state == 1) { w_ncfg smsg amsg }
  else { w_ncfg smsg say }
}
on *:dialog:pcw:sclick:20:{
  if ($did(pcw,20).state == 1) { w_ncfg smsg say }
  else { w_ncfg smsg amsg }
}

dialog om {
  title "About"
  size -1 -1 149 116
  option dbu
  icon nbs.ico, 0
  text "", 20, 10 15 89 16
  text "", 30, 10 47 98 16
  icon 4, 125 9 16 16,  nbs.ico, 0, noborder
  link "nbs-irc.net", 2, 6 81 35 8
  link "github.com/ElectronicWar/nbs-irc", 3, 6 88 150 8
  link "#nbs-irc", 5, 6 70 21 8
  text "on QuakeNet", 6, 28 70 38 8
  button "Close", 1, 110 103 37 11, ok
  text "", 10, 7 7 80 8
  text "Thanks to:", 7, 7 39 75 8
  text "", 100, 6 105 99 8
}
on *:dialog:om:init:0:{
  set -u1 %tmp.aboutblock 1
  did -a om 10 nbs-irc $n.version for mIRC 7.33+
  did -a om 20 Created by Dibbe && haxninja, maintained by H4ndy @ GitHub
  did -a om 30 Annorax, Maverick, Specter2, Leech, slanne, uK and Dozer
  n.showversion 100
  did -f om 10
}

alias n.showversion {
  did -a $dname $1  Version: $n.version $iif($n.version.date, ( $+ $remove($ifmatch,-) $+ ))
}

on *:dialog:om:sclick:2:if (!%tmp.aboutblock) n.url http://nbs-irc.net
on *:dialog:om:sclick:3:if (!%tmp.aboutblock) n.url https://github.com/MrNorwegian/nbs-irc
on *:dialog:om:sclick:4:{
  set %about.icon 16
  .timer -m 20 70 about.iconchanger
}
alias about.iconchanger {
  if ($dialog(om)) did -g om 4 %about.icon scripts\dll\i.dll
  inc %about.icon
  if (%about.icon == 18) set %about.icon 16
}
on *:dialog:om:sclick:5:{
  if (!%tmp.aboutblock) {
    if ($n.qnet) {
      if ($n.input(join #nbs-irc now?,y/n)) join #nbs-irc
    }
    elseif ($n.input(Connect to irc.quakenet.org and join #nbs-irc now? $crlf $crlf $+ Note: this will open a new server window.,y/n)) server -m irc.quakenet.org -j #nbs-irc
  }
}

dialog autocon {
  title "Auto connect"
  size -1 -1 146 138
  option dbu
  icon $scriptdirdll\i.dll, 17
  combo 2, 6 10 99 100, drop
  check "Enabled", 17, 109 10 33 10, disable 
  edit "", 7, 44 38 96 11, disable autohs
  edit "", 8, 44 50 96 11, disable pass autohs
  text "Nickname:", 1, 6 64 25 8
  edit "", 9, 44 62 96 11, disable autohs
  text "Alt. nickname:", 32, 6 75 34 8
  edit "", 10, 44 74 96 11, disable autohs
  text "Ident/mail:", 25, 6 87 31 8
  edit "", 11, 44 86 96 11, disable autohs
  text "Name:", 23, 6 99 25 8
  edit "", 12, 44 98 96 11, disable autohs
  text "Password:", 15, 6 52 33 8
  box "Server", 4, 2 1 142 25
  box "Connect using:", 14, 2 29 142 95
  text "", 99, 200 200 1 1
  text "Server(:port):", 6, 6 39 35 8
  button "Clear", 5, 110 110 30 11, disable
  text "(leave blank for default values)", 3, 6 112 80 8
  button "Connect", 16, 2 126 37 11, disable
  button "?", 18, 39 126 10 11
  button "Connect to all", 13, 60 126 46 11
  button "OK", 100, 107 126 37 11, ok
}
On *:dialog:autocon:init:0:{
  var %i = 1
  while (%i < 11) {
    var %a = $ncfg(auto_connect_ [ $+ [ %i  ] $+ ] _server)
    if (%a) && (%a != ânoneâ) did -a autocon 2 %i $+ : %a
    else did -a autocon 2 %i $+ : (none)
    inc %i 1
  }
}
on *:dialog:autocon:sclick:18:.echo -qg $n.input(Connects to the currently selected server. $crlf $crlf $+ Note: This will automatically create a new server window if the current one is in use.,info)
on *:dialog:autocon:sclick:5:{
  if ($n.input(Do you want to remove all settings for $did(autocon,2).seltext $+ ?,y/n)) {
    did -r autocon 7-12
    did -u autocon 17
  }
}
on *:dialog:autocon:sclick:2:{
  auto_connect_save
  if ($did(autocon,2).seltext) did -e autocon 7-12,17,5,16
  did -r autocon 7-12
  did -u autocon 17
  var %a = auto_connect_ $+ $gettok($did(autocon,2),1,58)
  did -ar autocon 99 $gettok($did(autocon,2),1,58)
  if ($ncfg( %a $+ _pass)) && ($ifmatch != ânoneâ) {
    var %q = $ifmatch, %k = $calc($len(%q) +1), %x = 1, %r
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
      inc %x 1
    }
    did -a autocon 8 %r
  }
  if ($ncfg( %a $+ _server)) && ($ifmatch != ânoneâ) did -a autocon 7 $ifmatch
  if ($ncfg( %a $+ _nick)) && ($ifmatch != ânoneâ) did -a autocon 9 $ifmatch
  if ($ncfg( %a $+ _anick)) && ($ifmatch != ânoneâ) did -a autocon 10 $ifmatch
  if ($ncfg( %a $+ _ident)) && ($ifmatch != ânoneâ) did -a autocon 11 $ifmatch
  if ($ncfg( %a $+ _name)) && ($ifmatch != ânoneâ) did -a autocon 12 $ifmatch
  n.ds cr 17 %a $+ _on
  did -r autocon 2
  var %i = 1
  while (%i < 11) {
    var %a = $ncfg(auto_connect_ [ $+ [ %i  ] $+ ] _server)
    if (%a) && (%a != ânoneâ) did -a autocon 2 %i $+ : %a
    else did -a autocon 2 %i $+ : (none)
    inc %i 1
  }
  did -c autocon 2 $did(autocon,99)
}
on *:dialog:autocon:sclick:100:auto_connect_save
alias -l auto_connect_save {
  if ($did(autocon,99)) {
    var %a = auto_connect_ $+ $did(autocon,99)
    if ($did(autocon,7)) w_ncfg %a $+ _server $ifmatch
    else w_ncfg %a $+ _server ânoneâ    
    if ($did(autocon,8)) w_ncfg %a $+ _pass $bfe($ifmatch)
    else w_ncfg %a $+ _pass ânoneâ
    if ($did(autocon,9)) w_ncfg %a $+ _nick $ifmatch
    else w_ncfg %a $+ _nick ânoneâ
    if ($did(autocon,10)) w_ncfg %a $+ _anick $ifmatch
    else w_ncfg %a $+ _anick ânoneâ
    if ($did(autocon,11)) w_ncfg %a $+ _ident $ifmatch
    else w_ncfg %a $+ _ident ânoneâ
    if ($did(autocon,12)) w_ncfg %a $+ _name $ifmatch
    else w_ncfg %a $+ _name ânoneâ
    n.ds cw 17 %a $+ _on
  }
}
on *:dialog:autocon:sclick:13:{
  auto_connect_save
  autoconnect_connectnow
}
on *:dialog:autocon:sclick:16:{
  if ($did(autocon,7)) {
    if ($did(autocon,9)) var %nick = $ifmatch
    else var %nick = $readini(mirc.ini,mirc,nick)
    if ($did(autocon,10)) var %anick = $ifmatch
    else var %anick = $readini(mirc.ini,mirc,anick)
    if ($did(autocon,11)) var %ident = $ifmatch
    else var %ident = $readini(mirc.ini,mirc,email)
    if ($did(autocon,12)) var %name = $ifmatch
    else var %name = $readini(mirc.ini,mirc,user)
    server $iif(connect* iswm $status,-m) $gettok($did(autocon,7),1,32) $did(autocon,8) -i %nick %anick %ident %name
  }
}
alias autoconnect_connectnow {
  var %i = 1
  while (%i < 11) {
    if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _on) == 1) {
      var %r
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _pass)) && ($ifmatch != ânoneâ) {
        var %q = $ifmatch, %k = $calc($len(%q) +1), %x = 1, %r
        while (%k > 1) {
          var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
          inc %x 1
        }
      }
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _nick)) && ($ifmatch != ânoneâ) var %nick = $ifmatch
      else var %nick = $readini(mirc.ini,mirc,nick)
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _anick)) && ($ifmatch != ânoneâ) var %anick = $ifmatch
      else var %anick = $readini(mirc.ini,mirc,anick)
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _ident)) && ($ifmatch != ânoneâ) var %ident = $ifmatch
      else var %ident = $readini(mirc.ini,mirc,email)
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _name)) && ($ifmatch != ânoneâ) var %name = $ifmatch
      else var %name = $readini(mirc.ini,mirc,user)
      if ($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _server)) && ($ifmatch != ânoneâ) server $iif(connect* iswm $status,-m) $gettok($ncfg(auto_connect_ [ $+ [ %i ] $+ ] _server),1,32) [ %r ] -i %nick %anick %ident %name
    }    
    inc %i 1
  }
}
dialog as {
  title "AuthServ (/cas)"
  icon $scriptdirdll\i.dll, 22
  size -1 -1 145 121
  option dbu
  box "Options", 15, 2 68 141 39
  combo 2, 6 10 70 100, drop
  button "Add", 5, 78 10 30 11
  button "Remove", 6, 109 10 30 11
  edit "", 8, 44 37 95 11
  text "Nickname:", 1, 6 38 25 8
  edit "", 9, 44 49 95 11, pass
  text "Password:", 11, 6 50 25 8
  check "Automatically identify on request", 7, 6 75 97 10
  check "Use ghost command if nick is in use", 3, 6 85 102 10
  check "On authorized, set nick to +x", 16, 6 95 102 8
  box "Network", 4, 2 1 141 24
  box "Identify", 14, 2 28 141 36
  button "OK", 10, 105 108 37 11, ok
  text "", 99, 200 200 1 1
}
On *:dialog:as:init:0:{
  var %a = $findfile(config\,authserv-*.txt,0,1,did -a as 2 $mid($nopath($1-),10,-4))
  n.ds cr 7 authserv_on
  n.ds cr 3 authserv_ghost
  n.ds cr 16 authserv_hidemask
}
on *:dialog:as:sclick:7:n.ds cw 7 authserv_on
on *:dialog:as:sclick:3:n.ds cw 3 authserv_ghost
on *:dialog:as:sclick:16:n.ds cw 16 authserv_hidemask
on *:dialog:as:sclick:2:{
  authserv_save
  did -ar as 99 $did(as,2)
  var %a = config\authserv- $+ $did(as,2) $+ .txt
  if ($exists(%a)) {
    var %a = $read(config\authserv- $+ $did(as,2) $+ .txt), %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
      inc %i 1
    }
    did -ar as 8 $gettok(%a,1,44)
    did -ar as 9 %r
  }
}
on *:dialog:as:sclick:5:{
  var %t = $n.input(Enter network name:,$network)
  if (%t) {
    authserv_save
    did -ar as 99 %t
    write -c config\authserv- $+ %t $+ .txt
    did -i as 2 1 %t
    did -c as 2 1
    did -r as 8,9
  }
}
on *:dialog:as:sclick:6:{
  if ($?!="Remove settings for $did(as,2) $+ ?") {
    var %n = config\authserv- $+ $did(as,2) $+ .txt
    if ($exists(%n)) .remove %n
    did -r as 8,9,2
    var %a = $findfile(config\,authserv-*.txt,0,1,did -a as 2 $mid($nopath($1-),10,-4))
  }
}
on *:dialog:as:sclick:10:{
  authserv_save
}
alias -l authserv_save {
  if ($did(as,99)) {
    var %n = config\authserv- $+ $did(as,99) $+ .txt
    if ($did(as,8)) && ($did(as,9)) write -c %n $did(as,8) $+ , $+ $bfe($did(as,9))
  }
}
alias authserv_connect {
  if ($lines(config\authserv- $+ $network $+ .txt) > 0) {
    var %a = $read(config\authserv- $+ $network $+ .txt), %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
      inc %i 1
    }
    as auth $gettok(%a,1,44) %r
    if ($ncfg(authserv_hidemask) == 1) mode $me +x
  }
}
alias authserv_ghost {
  if ($lines(config\authserv- $+ $network $+ .txt) > 0) {
    var %a = $read(config\authserv- $+ $network $+ .txt), %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
      inc %i 1
    }
    set %tmp.ghost $gettok(%a,1,44)
    authserv ghost $gettok(%a,1,44) %r
  }
}
dialog ns {
  title "NickServ (/cns)"
  size -1 -1 145 126
  option dbu
  icon nbs.ico, 0
  combo 2, 6 10 70 100, drop
  button "Add", 5, 78 10 30 11
  button "Remove", 6, 109 10 30 11
  edit "", 8, 44 37 95 11, autohs
  text "Nickname:", 1, 6 38 25 8
  edit "", 9, 44 49 95 11, pass autohs
  text "Password:", 11, 6 50 25 8
  text "Identify with:", 12, 6 79 36 8
  edit "", 13, 44 77 95 11, autohs
  check "Automatically identify on request", 7, 6 90 97 10,  
  check "Use ghost command if nick is in use", 3, 6 100 102 10, 
  box "Network", 4, 2 1 141 24
  box "Identify", 14, 2 28 141 36
  box "Options", 15, 2 68 141 44
  button "OK", 10, 106 114 37 11, ok
  text "", 99, 200 200 1 1
}
On *:dialog:ns:init:0:{
  var %a = $findfile(config\,nickserv-*.txt,0,1,did -a ns 2 $mid($nopath($1-),10,-4))
  n.ds cr 7 nickserv_on
  n.ds cr 3 nickserv_ghost
  if ($ncfg(nickserv_prefix)) did -ar ns 13 $ifmatch
}
on *:dialog:ns:sclick:7:n.ds cw 7 nickserv_on
on *:dialog:ns:sclick:3:n.ds cw 3 nickserv_ghost
on *:dialog:ns:sclick:2:{
  nickserv_save
  did -ar ns 99 $did(ns,2)
  var %a = config\nickserv- $+ $did(ns,2) $+ .txt
  if ($exists(%a)) {
    var %a = $read(config\nickserv- $+ $did(ns,2) $+ .txt), %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
      inc %i 1
    }
    did -ar ns 8 $gettok(%a,1,44)
    did -ar ns 9 %r
  }
}
on *:dialog:ns:sclick:5:{
  var %t = $n.input(Enter network name:,$network)
  if (%t) {
    nickserv_save
    did -ar ns 99 %t
    write -c config\nickserv- $+ %t $+ .txt
    did -i ns 2 1 %t
    did -c ns 2 1
    did -r ns 8,9
  }
}
on *:dialog:ns:sclick:6:{
  if ($?!="Remove settings for $did(ns,2) $+ ?") {
    var %n = config\nickserv- $+ $did(ns,2) $+ .txt
    if ($exists(%n)) .remove %n
    did -r ns 8,9,2
    var %a = $findfile(config\,nickserv-*.txt,0,1,did -a ns 2 $mid($nopath($1-),10,-4))
  }
}
on *:dialog:ns:sclick:10:{
  if ($did(ns,13)) w_ncfg nickserv_prefix $ifmatch
  nickserv_save
}
alias -l nickserv_save {
  if ($did(ns,99)) {
    var %n = config\nickserv- $+ $did(ns,99) $+ .txt
    if ($did(ns,8)) && ($did(ns,9)) write -c %n $did(ns,8) $+ , $+ $bfe($did(ns,9))
  }
}

; Autojoin settings
alias caj { 
  if ($1) set %n.caj $1-
  else set %n.caj $network
  dlg aj
}
dialog aj {
  title "Autojoin (/caj)"
  size -1 -1 191 173
  option dbu
  icon $scriptdirdll\i.dll, 17
  combo 2, 28 2 97 100, drop
  button "Add", 5, 128 2 30 11
  button "Remove", 6, 159 2 30 11
  edit "", 1, 1 14 189 135, multi return hsbar vsbar
  check "Enable autojoin", 8, 2 150 50 10, 
  check "", 9, 93 150 96 10, 
  check "Minimize channels on autojoin", 7, 2 160 85 10, 
  button "Join now", 3, 115 161 37 11
  button "OK", 10, 153 161 37 11, ok
  text "Network:", 4, 3 4 25 8
  text "", 99, 200 200 1 1
}
On *:dialog:aj:init:0:{
  var %a = $findfile(config\,autojoin-*.txt,0,1,did -a aj 2 $mid($nopath($1-),10,-4))
  n.ds cr 7 autojoin_minimize
  n.ds cr 8 autojoin
  if (%n.caj) {
    did -ar aj 99 %n.caj
    var %n = config\autojoin- $+ %n.caj $+ .txt
    if ($exists(%n)) loadbuf -o aj 1 %n
    did -c aj 2 $n.cbgn(aj,2,%n.caj)
  }
  unset %n.caj
  did -a aj 9 Disable autojoin for $did(aj,2)
  n.ds cr 9 autojoin_disable_ $+ $did(aj,2)
}
on *:dialog:aj:sclick:3:{
  autojoin_save
  aj
}
on *:dialog:aj:sclick:7:n.ds cw 7 autojoin_minimize
on *:dialog:aj:sclick:8:n.ds cw 8 autojoin
on *:dialog:aj:sclick:9:n.ds cw 9 autojoin_disable_ $+ $did(aj,2)
on *:dialog:aj:sclick:2:{
  autojoin_save
  did -r aj 1
  did -ar aj 99 $did(aj,2)
  var %n = config\autojoin- $+ $did(aj,2) $+ .txt
  if ($exists(%n)) loadbuf -o aj 1 %n
  did -a aj 9 Disable autojoin for $did(aj,2)
  n.ds cr 9 autojoin_disable_ $+ $did(aj,2)
}
on *:dialog:aj:sclick:5:{
  var %t = $n.input(Enter network name:,$network)
  if (%t) {
    autojoin_save
    did -ar aj 99 %t
    write -c config\autojoin- $+ %t $+ .txt
    did -i aj 2 1 %t
    did -c aj 2 1
    did -r aj 1
  }
}
on *:dialog:aj:sclick:6:{
  if ($n.input(Do you want to remove autojoin for $did(aj,2) $+ ?,y/n)) {
    var %n = config\autojoin- $+ $did(aj,2) $+ .txt
    if ($exists(%n)) .remove %n
    did -ar aj 1 Autojoin for $did(aj,2) removed.
    did -r aj 2,99
    var %a = $findfile(config\,autojoin-*.txt,0,1,did -a aj 2 $mid($nopath($1-),10,-4))
  }
}
on *:dialog:aj:sclick:10:autojoin_save
alias -l autojoin_save {
  if (!$did(aj,99)) || (!$did(aj,1).lines) return
  var %n = config\autojoin- $+ $did(aj,99) $+ .txt
  write -c %n
  var %i = 1, %e = $did(aj,1).lines
  while (%i <= %e) {
    write %n $did(aj,1,%i)
    inc %i 1
  }
}

alias txt if ($exists($1)) { set %txt $1- | dlg txt }
dialog txt {
  title "nbs-irc"
  size -1 -1 298 228
  option dbu
  icon $scriptdirdll\i.dll, 17
  edit "", 1, 1 2 296 212, multi return hsbar vsbar
  button "Save", 10, 221 216 37 11, ok
  button "Cancel", 3, 259 216 37 11, cancel
  button "Add shortcut", 20, 1 216 44 11
}
On *:dialog:txt:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetFont txt 1 15 400 Courier New
  if (!%tmp.txtfile) did -h txt 20 
  unset %tmp.txtfile
  if (!$exists(%txt)) return 
  loadbuf -o txt 1 %txt
  dialog -t txt %txt
}
on *:dialog:txt:sclick:20:{
  var %x = $$sfile(*.*,Select target file) 
  if ($did(txt,1,$did(txt,1).lines)) did -a txt 1 $crlf
  did -a txt 1 %x
  did -f txt 1
}
on *:dialog:txt:sclick:10:{
  write -c %txt  
  if ($did(txt,1)) savebuf -o txt 1 %txt
  if (%txtload) { 
    if (loadbuf isin %txtload) did -r $right(%txtload,-10)
    %txtload 
  }
  unset %txtload
}

alias cl_hideall {
  if ($chan(0) < 1) return    
  var %i = 1
  while (%i <= $chan(0)) {
    if ($window($chan(%i)).state != hidden) window -h $chan(%i)
    inc %i
  }
}
alias cl_showall {
  if ($chan(0) < 1) return  
  var %i = 1
  while (%i <= $chan(0)) {
    if ($window($chan(%i)).state == hidden) window -w $chan(%i)
    hadd -m temp ci. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ] $ticks
    inc %i
  }
}
alias cl_lc {
  if (!$dialog(cl)) return 
  did -r cl 1  
  var %i = 1
  while (%i <= $chan(0)) {
    if ($window($chan(%i)).state == hidden) did -a cl 1 $chan(%i) $chr(9) $+ $dur($calc($ci($chan(%i)) * 60),2) $chr(9) $+ 
    else did -a cl 1 $chan(%i) $chr(9) $+ $dur($calc($ci($chan(%i)) * 60),2)
    inc %i
  }
}

; /ch - Channel list dialog
alias ch dlg cl
dialog cl {
  title "Channel list"
  size -1 -1 251 341
  option pixels
  icon $scriptdirdll\i.dll,4  
  list 1, 2 18 246 238, size extsel
  button "Close", 2, 189 319 60 20, ok
  text "Double click to hide/show channel:", 3, 2 2 178 16
  button "Hide all", 4, 64 319 60 20
  check "Show hidden channels on activity (say)", 6, 2 280 217 19, 
  button "Show all", 7, 2 319 60 20
  check "Autohide channels after ", 5, 2 298 136 20, 
  edit "", 8, 138 298 28 20, autohs limit 2 center
  text "m of inactivity", 9, 168 300 76 16
  edit "", 10, 2 259 219 21, autohs
  button "?", 11, 223 260 24 18
}
On *:dialog:cl:init:0:{ 
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetControlMDX cl 1 ListView report single rowselect > scripts\dll\mdx\views.mdx  
  did -i cl 1 1 headerdims 130:1 70:2 20:3
  did -i cl 1 1 headertext Channel $chr(9) $+ Idle $chr(9) $+ H
  if ($network) dialog -t cl Chanlist $+([,$network,])
  if ($ncfg(win_ashow == 1)) did -c cl 6
  if ($ncfg(ci-check == 1)) did -c cl 5
  if ($ncfg(cic-time)) did -a cl 8 $ncfg(cic-time)
  if ($ncfg(nohide)) did -a cl 10 $ncfg(nohide)  
  cl_lc
}
On *:dialog:cl:sclick:2:{
  if ($did(cl,6).state == 1) { w_ncfg win_ashow 1 }
  else { w_ncfg win_ashow o }
  if ($did(cl,5).state == 1) { w_ncfg ci-check 1 }
  else { w_ncfg ci-check o }
  if ($did(cl,8).text isnum 1-240) w_ncfg cic-time $did(cl,8).text
  if ($did(cl,10).text) w_ncfg nohide $did(cl,10).text
}
On *:dialog:cl:sclick:4:{
  cl_hideall
  cl_lc
}
On *:dialog:cl:sclick:7:{
  cl_showall
  cl_lc
}
On *:dialog:cl:dclick:1:{
  tokenize 32 $did(cl,1).seltext
  if ($window($6).state == hidden) { 
    window -w $6
    hadd -m temp ci. [ $+ [ $cid ] $+ ] . [ $+ [ $6 ] ] $ticks
  }
  else window -h $6
  cl_lc
}
On *:dialog:cl:sclick:11:var %. = $n.input(Always show these channels $+ $c44 $crlf $+ seperate with space.,info)

; cmds - Commands dialog
alias cmds dlg cmds
dialog cmds {
  title "Commands (/cmds)"
  size -1 -1 295 221
  option dbu
  icon nbs.ico, 0
  button "Close", 100, 256 208 37 11, cancel

  tab "Setup", 11, 2 0 290 202
  list 1, 5 16 283 183, tab 11 size extsel
  tab "IRC", 12
  list 2, 5 16 283 183, tab 12 size extsel
  tab "Extended", 13
  list 3, 5 16 283 183, tab 13 size extsel
  tab "System info", 14
  list 4, 5 16 283 183, tab 14 size extsel
  tab "Other", 15
  list 5, 5 16 283 183, tab 15 size extsel

  text "Double-click on any command to run it now", 200, 6 209 127 8
}

on *:dialog:cmds:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  var %i = 1
  while (%i < 6) {
    n.mdx SetControlMDX cmds %i listview report rowselect > scripts\dll\mdx\views.mdx
    did -i cmds %i 1 headerdims 110:1 430:2
    did -i cmds %i 1 headertext Command $chr(9) $+ Action $chr(160) <required> / [optional]
    inc %i
  }
  var %tab = 11
  while (%tab < 16) {
    var %src = $replace(%tab,11,setup,12,irc,13,extended,14,sysinfo,15,other)
    var %src = scripts\txt\cmds_ $+ %src $+ .txt
    var %targetid = $calc(%tab - 10)
    var %i = 1, %e = $lines(%src)
    while (%i <= %e) {
      var %x = $read(%src,%i)
      if (%x) did -a cmds %targetid / $+ $gettok(%x,1,44) $chr(9) $+ $gettok(%x,2-,44)
      else did -a cmds %targetid $chr(160)
      inc %i
    }
    inc %tab
  }
  did -f cmds 1
}
on *:dialog:cmds:dclick:1-5:{
  var %x = $gettok($did($did,$did($did).sel),6,32)
  if ($left(%x,1) == /) && ($n.input(Run command %x now?,y/n)) $right(%x,-1)
}

; F-key bindings dialog
alias fkeys dlg fkeys
dialog fkeys {
  title "F-key bindings (/fkeys)"
  size -1 -1 171 90
  option dbu
  icon $scriptdirdll\i.dll, 17
  edit "", 1, 11 3 70 11, autohs
  edit "/setup", 2, 11 15 70 11, read
  edit "", 3, 11 27 70 11, autohs
  edit "", 4, 11 40 70 11, autohs
  edit "", 5, 11 52 70 11, autohs
  edit "(ban/unban latest ban)", 6, 11 64 70 11, read autohs
  edit "", 7, 99 3 70 11, autohs
  edit "", 8, 99 15 70 11, autohs
  edit "", 9, 99 27 70 11, autohs
  edit "", 10, 99 40 70 11, autohs
  edit "", 11, 99 52 70 11, autohs
  edit "", 12, 99 64 70 11, autohs
  text "F1", 20, 1 5 9 7, right
  text "F2", 39, 1 17 9 8, right
  text "F3", 98, 1 29 9 8, right
  text "F4", 58, 1 42 9 8, right
  text "F5", 74, 1 54 9 8, right
  text "F6", 78, 1 66 9 8, right
  text "F7", 77, 89 5 9 8, right
  text "F8", 67, 89 17 9 8, right
  text "F9", 57, 89 29 9 8, right
  text "F10", 83, 89 42 9 8, right
  text "F11", 32, 89 54 9 8, right
  text "F12", 54, 89 66 9 8, right
  button "Reset", 101, 1 79 37 11
  button "OK", 100, 95 79 37 11, ok
  button "Cancel", 13, 133 79 37 11, cancel
}

on *:dialog:fkeys:init:0:{
  var %i = 1
  while (%i < 13) {
    if (%i != 6) && (%i != 2) && ($ncfg(fkey_f [ $+ [ %i ] ]) != ânoneâ) did -a fkeys %i $ifmatch
    inc %i 1
  }
}
on *:dialog:fkeys:sclick:101:{
  if ($?!="Are you sure?") {
    did -ar fkeys 1 /help
    did -ar fkeys 3 /awaysys
    did -ar fkeys 4 /back
    did -ar fkeys 5 /lastpop
    did -ar fkeys 7 /topic $chr(35)
    did -ar fkeys 8 /np
    did -ar fkeys 9 /logviewer
    did -ar fkeys 10 /g-join
    did -ar fkeys 11 /blist
    did -ar fkeys 12 /aboutnbs
  }
}
on *:dialog:fkeys:sclick:100:{
  var %i = 1
  while (%i < 13) {
    if (%i != 6) && (%i != 2) {
      if ($did(fkeys,%i).text) w_ncfg fkey_f $+ %i $ifmatch
      else w_ncfg fkey_f $+ %i ânoneâ
    }
    inc %i 1
  }
}

; Missing alias ???
dialog servers {
  title "Servers"
  size -1 -1 200 124
  option dbu
  icon $scriptdirdll\i.dll,12
  list 1, 1 1 198 111, size extsel
  button "Close", 3, 169 113 30 10, cancel
  button "Edit", 4, 138 113 30 10
  check "New connection", 5, 57 113 52 10, 
  check "Show on startup", 2, 2 113 50 10, 
}
on *:dialog:servers:init:0:{ 
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetControlMDX $dname 1 ListView report single rowselect showsel > scripts\dll\mdx\views.mdx  
  did -i $dname 1 1 headerdims 90:1 180:2 40:3
  did -i $dname 1 1 headertext Name $chr(9) $+ Server:port $chr(9) $+ Pass.
  if ($status == connected) did -c servers 5
  if ($ncfg(con-on-start) == 1) did -c servers 2  
  con-update
}
on *:dialog:servers:sclick:4:{
  set %txtload con-update
  txt config\irc-servers.txt
}
alias con-update {
  if ($lines(config\irc-servers.txt) < 1) { did -ra servers 1 (empty) | return }
  set %e $lines(config\irc-servers.txt)
  var %i = 1
  did -r servers 1
  while (%i <= %e) {
    if ($gettok($read(config\irc-servers.txt,%i),3,44)) did -a servers 1 $gettOK($read(config\irc-servers.txt,%i),1,44) $chr(9) $+ $gettOK($read(config\irc-servers.txt,%i),2,44) $chr(9) $+ yes
    else did -a servers 1 $replace($read(config\irc-servers.txt,%i),$chr(44),$chr(9)) $chr(9) $+ no
    inc %i
  }
}
on *:dialog:servers:sclick:2:{
  if ($did(servers,2).state == 1) w_ncfg con-on-start 1
  else w_ncfg con-on-start o
}
on *:dialog:servers:dclick:1:{
  if ($did(servers,1).sel) {
    var %con-temp = $gettok($read(config\irc-servers.txt, $+ $calc($did(servers,1).sel -1) $+ ),2,44) $gettok($read(config\irc-servers.txt, $+ $calc($did(servers,1).sel -1) $+ ),3,44)
    if ($did(servers,5).state == 1) server -m %con-temp
    else server %con-temp
    if ($did(servers,5).state == 0) did -c servers 5
  }
}

; Blacklist dialog
alias blist dlg blist
dialog addedit {
  title "Add"
  size -1 -1 167 41
  option dbu
  icon $scriptdirdll\i.dll, 17
  text "Address:", 1, 2 5 22 8
  text "Reason:", 2, 2 17 22 8
  edit "", 3, 25 3 140 11, autohs
  edit "", 4, 25 15 140 11, autohs
  button "OK", 5, 90 29 37 11, ok
  button "Cancel", 6, 128 29 37 11, cancel
}
on *:dialog:addedit:init:0:{
  if ($gettok(%addedit,1,1)) {
    did -a addedit 3 $ifmatch
    dialog -t addedit Edit
    if ($gettok(%addedit,2-,1)) did -a addedit 4 $ifmatch
  }
  else did -a addedit 4 Blacklisted
}
on *:dialog:addedit:sclick:5:{
  if (%addedit) && $did(addedit,3) && ($read(config\blacklist.txt,w,$gettok(%addedit,1,1) $+ *)) {
    .write -dl $+ $readn config\blacklist.txt 
    var %x = $readn
  }
  if ($did(addedit,3)) .write $iif(%x,-il $+ %x) config\blacklist.txt $iif($chr(33) !isin $did(addedit,3),*!*) $+ $iif(@ !isin $did(addedit,3),@) $+ $did(addedit,3) $+ $iif($did(addedit,4),$chr(44) $+ $ifmatch)
  n.bl-update
}
on *:dialog:addedit:close:0:unset %addedit
dialog blchans {
  title "Blacklist channels"
  size -1 -1 112 146
  option dbu
  icon $scriptdirdll\i.dll, 15
  box "Enable blacklist for:", 5, 2 2 108 129
  radio "All channels", 7, 6 11 54 10, 
  radio "Specified channels:", 8, 6 20 68 10, 
  edit "", 2, 13 30 93 86, multi return autohs autovs vsbar
  button "Add current", 4, 69 117 37 11
  button "OK", 3, 73 134 37 11, ok
}
on *:dialog:blchans:init:0:{
  if ($ncfg(blacklist_custom_channels) == 1) did -c blchans 8
  else {
    did -c blchans 7 
    did -b blchans 2,4
  }
  var %i = 1, %x = $gettok($ncfg(blacklist_channels),0,32)
  if (%x) {
    while (%i <= %x) {
      did -a blchans 2 $gettok($ncfg(blacklist_channels),%i,32) $+ $crlf
      inc %i
    }
  }
  else {
    var %i = 1
    while (%i <= $chan(0)) {
      did -a blchans 2 $chan(%i) $+ $crlf
      inc %i
    }
  }
}
on *:dialog:blchans:sclick:7:did -b blchans 2,4
on *:dialog:blchans:sclick:8:did -e blchans 2,4
on *:dialog:blchans:sclick:3:{
  if ($did(blchans,8).state == 1) {
    w_ncfg blacklist_custom_channels 1
    .remini config\config.ini nbs-irc blacklist_channels
    var %i = 1, %x = $did(blchans,2).lines, %y
    if (%x) {
      while (%i <= %x) {
        var %y = %y $did(blchans,2,%i)
        inc %i
      }
      w_ncfg blacklist_channels %y
    }
  }
  else w_ncfg blacklist_custom_channels o
}
on *:dialog:blchans:sclick:4:{
  if ($did(blchans,2,$did(blchans,2).lines)) did -a blchans 2 $crlf
  if ($active ischan) did -a blchans 2 $active
}
dialog blist {
  title "Blacklist"
  size -1 -1 213 146
  option dbu
  icon $scriptdirdll\i.dll, 15
  list 1, 1 2 210 130, size extsel
  check "Enable blacklist", 2, 3 135 50 10, 
  button "Add", 5, 58 134 30 11
  button "Remove", 6, 89 134 30 11
  button "Edit", 4, 120 134 30 11
  button "Channels", 7, 151 134 30 11
  button "Close", 3, 182 134 30 11, cancel
}
on *:dialog:blist:init:0:{ 
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetControlMDX $dname 1 ListView report single rowselect showsel > scripts\dll\mdx\views.mdx  
  did -i $dname 1 1 headerdims 260:1 130:2
  did -i $dname 1 1 headertext Address $chr(9) $+ Reason
  if ($ncfg(blacklist) == 1) did -c blist 2
  n.bl-update
}
on *:dialog:blist:sclick:7:dlg blchans
on *:dialog:blist:dclick:1:bl.edit
on *:dialog:blist:sclick:4:bl.edit
alias bl.edit {
  if ($did(blist,1).seltext) {
    var %x = $replace($did(blist,1).seltext,$chr(9),$chr(32))
    addedit $+($gettok(%x,6,32),$chr(1),$gettok(%x,11-,32))
  }
}
on *:dialog:blist:sclick:2:n.ds cw 2 blacklist
on *:dialog:blist:sclick:5:addedit
on *:dialog:blist:sclick:6:{
  var %x = $gettok($replace($did(blist,1).seltext,$chr(9),$chr(32)),6,32)
  if (%x) && ($read(config\blacklist.txt,w,%x $+ *)) {
    .write -dl $+ $readn config\blacklist.txt 
    n.bl-update
  }
}
on *:dialog:blist:sclick:3:if ($did(blist,2).state == 1) scon -at1 n.blscanall
alias n.bl-update {
  if ($lines(config\blacklist.txt) < 1) did -r blist 1
  else {
    var %i = 1, %e = $lines(config\blacklist.txt)
    did -r blist 1
    while (%i <= %e) {
      did -a blist 1 $replace($read(config\blacklist.txt,%i),$chr(44),$chr(9))
      inc %i
    }
  }
}

; Alarm dialog
alias alarm dlg alarm
dialog alarm {
  title "Alarm timer (/alarm)"
  size -1 -1 106 141
  option dbu
  icon $scriptdirdll\i.dll, 17
  box "Time:", 9, 2 2 101 35
  box "Action:", 10, 2 40 101 86
  radio "Ring at:", 2, 6 10 31 10, group 
  edit "", 1, 38 10 24 11, autohs center
  radio "Ring in:", 17, 6 22 30 10
  edit "", 18, 38 22 24 11, autohs center
  radio "Beep", 3, 6 49 26 10, group 
  radio "Play sound:", 4, 6 60 40 10
  edit "", 5, 14 70 73 11, autohs
  button "...", 13, 89 71 11 9
  check "Run program:", 11, 6 81 50 10, 
  edit "", 12, 14 91 73 11, autohs
  button "...", 14, 89 92 11 9
  check "Display notification:", 15, 6 102 70 10, 
  edit "", 16, 14 112 86 11, autohs
  button "Set", 6, 2 129 33 11, ok
  button "Reset", 7, 36 129 33 11
  button "Close", 8, 70 129 33 11, cancel
  text "hh:mm (24h)", 19, 65 12 35 8
  text "minutes", 20, 65 24 22 8
}

On *:dialog:alarm:init:0:{
  did -b alarm 18
  if (%alarm_time) did -ar alarm 1 $ifmatch
  if (%alarm_etime) did -ar alarm 18 $ifmatch
  if ($timer(alarm)) {
    if ($timer(alarm).time) did -c alarm 2
    else did -c alarm 17
    did -b alarm 1,2,3,4,5,6,11,12,13,14,15,16,17
    did -f alarm 8
  }
  else did -c alarm 2
  if ($ncfg(alarm_type) == sound) && ($ncfg(alarm_sound)) {
    did -c alarm 4
    did -a alarm 5 $ifmatch
  }
  else did -c alarm 3
  if ($ncfg(alarm_program)) did -a alarm 12 $ifmatch
  if ($ncfg(alarm_message)) did -a alarm 16 $ifmatch
  if (%alarm.program == 1) did -c alarm 11
  if (%alarm.message == 1) did -c alarm 15
}
On *:dialog:alarm:sclick:2:{
  if ($did(alarm,2).state == 1) did -b alarm 18
  did -e alarm 1
}
On *:dialog:alarm:sclick:17:{
  if ($did(alarm,17).state == 1) did -b alarm 1
  did -e alarm 18
}
On *:dialog:alarm:sclick:13:{
  if ($sfile(*.wav;*.mp3,Choose sound file)) {
    did -ar alarm 5 $ifmatch
    w_ncfg alarm_sound $ifmatch
  }
}
On *:dialog:alarm:sclick:14:{
  if ($sfile(*.exe;*.com;*.lnk,Choose program)) {
    did -ar alarm 12 $ifmatch
    w_ncfg alarm_program $ifmatch
  }
}
On *:dialog:alarm:sclick:6:{
  if ($did(alarm,2).state == 1) && (?:? iswm $did(alarm,1).text) { 
    var %alarm = $remove($did(alarm,1).text,:)
    if ($len(%alarm) == 3) var %alarm = 0 $+ %alarm
    if ($mid(%alarm,1,2) !isnum 0-23) || ($mid(%alarm,3,2) !isnum 0-59) {
      echo $color(info) -atg $kl:(Alarm) invalid time
      return
    }
  }
  if ($did(alarm,17).state == 1) {
    if ($did(alarm,18).text !isnum) {
      echo $color(info) -atg $kl:(Alarm) invalid time
      return
    }
  }
  unset %alarm.*
  if ($did(alarm,3).state == 1) {
    set %alarm.beep 1
    w_ncfg alarm_type beep
  }
  elseif ($did(alarm,4).state == 1) {
    if ($isfile($did(alarm,5))) {
      set %alarm.sound $did(alarm,5)
      w_ncfg alarm_type sound
    }
    else {
      .echo -qg $n.input($did(alarm,5) does not exist.,info)
      halt
    }
  }
  if ($did(alarm,11).state == 1) {
    if ($isfile($did(alarm,12))) set %alarm.program $did(alarm,12)
    else {
      .echo -qg $n.input($did(alarm,12) does not exist.,info)
      halt
    }
    set %alarm.program.on 1
  }
  else unset %alarm.program.on
  if ($did(alarm,15).state == 1) {
    set %alarm.message 1
    w_ncfg alarm_message $did(alarm,16).text
  }

  if ($did(alarm,2).state == 1) {
    .timeralarm -oi $did(alarm,1).text 1 0 n.alarm_action
    echo $color(info) -st $npre Alarm set at $did(alarm,1).text $iif(%alarm.message == 1,$par($ncfg(alarm_message)))  
  }
  else {
    .timeralarm -o 1 $calc($did(alarm,18).text *60) n.alarm_action
    echo $color(info) -st $npre Alarm set at $did(alarm,18).text minute(s) $iif(%alarm.message == 1,$par($ncfg(alarm_message)))  
  }
}
On *:dialog:alarm:sclick:7:{
  did -e alarm 1,2,3,4,5,6,11,12,13,14,15,16,17
  did -c alarm 2
  did -u alarm 17
  .timeralarm off
  splay stop
}

; Game launcher dialog
alias g-join {
  if ($1) set %hlip $1
  dlg gl
}
dialog gl {
  title "Game launcher (F10) (/g-join)"
  size -1 -1 218 44
  option dbu
  icon nbs.ico
  combo 1, 25 3 122 100, edit drop
  check "Minimize mIRC", 33, 8 32 46 9, 
  check "Pause Winamp", 34, 57 32 49 9, 
  button "Connect", 13, 109 32 35 11, ok
  button "Rcon (cs)", 39, 145 32 35 11
  button "Close", 14, 181 32 35 11, cancel
  combo 2, 25 16 129 100, drop
  button "Reload", 3, 156 16 30 11
  button "Edit", 17, 187 16 29 11
  text "Address:", 8, 2 5 22 8
  text "Pass:", 46, 151 5 13 8
  text "Game:", 15, 2 18 17 8
  edit "", 4, 165 3 50 11
}
On *:dialog:gl:init:0:{
  n.gl.updategames
  if (%hlip) did -a gl 1 $ifmatch
  if ($lines(config\hl-servers.txt) > 0) loadbuf -o gl 1 config\hl-servers.txt
  if (%n.gl.lastpw) did -a gl 4 $ifmatch
  did -c gl 1 1
  n.ds cr 33 csminmirc
  n.ds cr 34 gl_pausewinamp
}
On *:dialog:gl:sclick:17:run config\games.txt
On *:dialog:gl:sclick:39:{
  unset %rcon.*
  var %gl.tmp = $gettok($gettok($did(gl,1).text,1,32),1,58)
  if ($gettok(%gl.tmp,1,46) isnum 1-255) set %rcon.ip %gl.tmp
  else {
    .echo -qg $n.input(Error: enter ip:port (eg: 83.126.53.32:27015) Hostnames are not supported.,info)
    return
  }
  var %gl.tmp2 = $gettok($gettok($did(gl,1).text,1,32),2,58)
  if (%gl.tmp2 isnum) set %rcon.port %gl.tmp2
  else {
    .echo -qg $n.input(Error: please enter port (eg :27015),info)
    return
  }
  rcon_win
}
alias rcon_win {
  if (!%rcon.port) return
  if (!$window(@rcon)) dlg rcon_pass
  else n.echo info -atgOnly one rcon connection supported, please close the existing rcon window.
}

dialog rcon_pass {
  title "Rcon"
  size -1 -1 83 43
  option dbu
  button "OK", 1, 52 32 30 10, default ok
  edit "", 2, 0 10 82 11, pass
  check "Save", 3, 1 22 25 10
  text "Password:", 4, 1 2 31 7
}
on *:dialog:rcon_pass:init:0:{
  if ($ncfg(rcon_password_save) == 1) { 
    did -c rcon_pass 3
    if ($ncfg(rcon_password)) did -a rcon_pass 2 $ifmatch
  }
  did -f rcon_pass 2
}

on *:udpread:rcon:{
  if ($sockerr > 0) return
  :nextread
  sockread -f %rcon
  if ($sockbr == 0) return
  if (challenge rcon isin %rcon) { 
    .timerrcon off
    set %rcon.id $gettok(%rcon,3,32)
    window -ek0d @rcon nbs.ico
    titlebar @rcon $+([,%rcon.ip,:,%rcon.port,])
    echo -t @rcon $npre connected to $+(%rcon.ip,:,%rcon.port)
  }
  if (!%rcon) { goto end }
  if ($left($remove(%rcon,ÿÿÿÿ),1) == l) var %rcon.svar = $right($remove(%rcon,ÿÿÿÿ),-1)
  else var %rcon.svar = $remove(%rcon,ÿÿÿÿ)
  echo -t @rcon <- %rcon.svar
  :end
  goto nextread
}
On *:INPUT:@rcon:{
  echo -t @rcon -> $1-
  rcon_cmd $1-
  haltdef
}
alias rcon_cmd if ($1) sockudp -k rcon 5000 %rcon.ip %rcon.port ÿÿÿÿ $+ rcon %rcon.id %rcon.pass $1- $+ $lf
On *:CLOSE:@rcon:{
  sockclose rcon*
  unset %rcon.*
}
on *:dialog:rcon_pass:sclick:1:{
  if ($did(rcon_pass,2).text) {
    set %rcon.pass $ifmatch
    if ($did(rcon_pass,3).state == 1) {
      w_ncfg rcon_password %rcon.pass
      w_ncfg rcon_password_save 1
    }
    else {
      w_ncfg rcon_password_save o
      w_ncfg rcon_password å
    }
    if (%rcon.pass) {
      sockudp -k rcon 5000 %rcon.ip %rcon.port ÿÿÿÿ $+ challenge rcon $+ $lf
      .timerrcon 1 1 sockclose rcon*
    }
  }
}


On *:dialog:gl:sclick:13:{
  if ($did(gl,2)) set %currgame $ifmatch
  else { 
    .echo -qg $n.input(Error: no game specified.,info)
    return
  }
  if ($did(gl,1)) n.history config\hl-servers.txt $ifmatch
  if ($did(gl,4)) set %n.gl.lastpw $ifmatch
  else unset %n.gl.lastpw
  if ($did(gl,2)) run -p $replace($gettok($ifmatch,2,124),[adr],$gettok($did(gl,1),1,32),[pass],$did(gl,4))
  if ($did(gl,34).state == 1) { dll scripts\dll\winamp.dll playpause | w_ncfg gl_pausewinamp 1 }
  else w_ncfg gl_pausewinamp o
  if ($did(gl,33).state == 1) { w_ncfg csminmirc 1 | showmirc -m }
  else w_ncfg csminmirc o
  unset %hlip
}

On *:dialog:gl:sclick:3:n.gl.updategames
On *:dialog:gl:sclick:14:{
  n.ds cw 34 gl_pausewinamp
  n.ds cw 33 csminmirc
  unset %hlip
}
alias -l n.gl.updategames {
  did -r gl 2
  did -a gl 2 - Current:
  did -a gl 2 %currgame
  did -a gl 2 - Available:
  if ($lines(config\games.txt) > 0) loadbuf -o gl 2 config\games.txt
  did -c gl 2 2
}

on *:udpread:hl:{
  while ($sockerr == 0) { 
    var %hl
    sockread -f %hl
    if ($gettok(%hl,4,92)) var %hlk %hl
    if ($sockbr == 0) {
      wigl namn $gettok(%hlk,20,92)
      wigl spelare $gettok(%hlk,6,92) $+ / $+ $gettok(%hlk,12,92)
      wigl game $gettok(%hlk,16,92)
      wigl map $gettok(%hlk,22,92)
      wigl hlpass $gettok(%hlk,26,92)
      wigl ip $gettok(%hlk,4,92)
      wigl vac $gettok(%hlk,29,92)
      wigl typ $replace($gettok(%hlk,24,92),d,dedi,l,listen)
      wigl ping $calc($ticks - %hl.start) 
      sockclose hl
      return
    }
  }
}

on *:filercvd:*:{
  if ($hget(nbs,popup_dcc) == 1) && ($file(" $filename ").size > 1048576) n.ptext "get $nick $nopath($filename) "  $chr(1) DCC Get finished $chr(1) $npre Get of $nopath($filename) from $nick finished.
}
on *:getfail:*:{
  if ($hget(nbs,popup_dcc) == 1) n.ptext "get $nick $nopath($filename) " $chr(1) DCC Get failed $chr(1) $npre Failed to get $nopath($filename) from $nick
}
