alias mp3send {
  if ($1) && (http://* !iswm $swamp(trackfilename)) dc $+ $chr(99) $chr(115) $+ e $+ $chr(110) $+ d $1 $swamp(trackfilename)
  else n.echo info -atg Usage: /sendsong <nick>
}
alias np {
  if (%tmp.sa.spam != 1) {
    set -u1 %tmp.sa.spam 1
    var %x = $n.songannounce
    if (%x) $iif(c isincs $gettok($chan($active).mode,1,32),$strip(%x),%x)
  }
}
alias mp3 np
alias sa dlg mp3s
alias mp3say dlg mp3s
alias n.songannounce {
  %wa.in = $ncfg(mp3s)
  if ($ncfg(itunes) == 1) {
    n.getitunes
    if (%it.title) {
      if ([type] isin %wa.in) var %type = $lower($replace(%it.type,mpeg audio file,mp3))
      var %wa.out = $replace(%wa.in,[mp3],%it.artist - %it.title,[artist],%it.artist,[title],%it.title,[album],%it.album,[time],$dur2(%it.ttime),[etime],$dur2(%it.etime),[kbps],%it.bitrate kbps,[type],%type)
      unset %it.*    
    }
    else n.echo other -atg iTunes is not running, stopped or other error.
  }
  else {
    if ($swamp(trackfilename) == $!null) || (!$swamp(trackfilename)) { n.echo other -atg Error: Winamp is not running/stopped | return }
    if ([stopped] isin $dll(scripts\dll\winamp.dll,song,_)) { n.echo other -atg Error: Winamp must not be stopped | return }
    if ([paused] isin $dll(scripts\dll\winamp.dll,song,_)) { n.echo other -atg Error: Winamp must not be paused | return }
    var %x = $swamp(trackfilename), %wa.old = $removecs($dll(scripts\dll\winamp.dll,song,_),[paused],[stopped])
    if ([size] isin %wa.in) var %wa.size = $round($calc($file(%x).size /1024/1024),2) MB
    if ([filename] isin %wa.in) var %wa.file = $nopath(%x)
    if ([path] isin %wa.in) var %wa.path = $nofile(%x)
    if ([folder] isin %wa.in) var %wa.folder = $gettok(%x,-2,92)
    if ([artist] isin %wa.in) var %wa.artist = $qwa(artist)
    if ([title] isin %wa.in) var %wa.title = $qwa(title)
    if ([type] isin %wa.in) var %wa.type = $iif(/ isin $gettok(%x,-1,46),stream,$gettok(%x,-1,46)))
    if ([kbps] isin %wa.in) var %wa.bitrate = $swamp(bitrate)
    if ([album] isin %wa.in) var %wa.album  = $qwa(album)
    var %wa.out = $replace(%wa.in,âbåld,,âcålår,,âånderlajn,,âcläör,,[random],$read(config\mp3.txt), $& 
      [artist],%wa.artist,[title],%wa.title,[mp3],%wa.old,[type],%wa.type,[etime],$dll(scripts\dll\winamp.dll,position,_), $&
      [time],$replace($dll(scripts\dll\winamp.dll,songlength,_),00:-1,stream),[folder],%wa.folder, $& 
      [kbps],%wa.bitrate kbps,[album],%wa.album,[size],%wa.size,[filename],%wa.file,[path],%wa.path)
    if ($hget(nbs,mp3serv) == 1) { hadd -u300 temp mp3serv.file $cit(%x) | unset %mp3serv.* }
  }
  return $replacecs(%wa.out,$false,none)
}
alias n.servemp3 {
  inc -u20 %mp3serv.prot 1
  if ($hget(temp,mp3serv.file)) && (%mp3serv.prot < 4) && (!%mp3serv. [ $+ [ $1 ] ]) {
    set -u10 %mp3serv. $+ $1 1
    if (http://* !iswm $hget(temp,mp3serv.file)) {
      .dcc maxcps $calc($iif($ncfg(mp3maxcps) == o,0,$ncfg(mp3maxcps)) * 1024)
      dc $+ $chr(99) $chr(115) $+ e $+ $chr(110) $+ d $1 $hget(temp,mp3serv.file)
    }
    else echo $color(info) -stge Error: could not send $hget(temp,mp3serv.file)
  }
}
dialog mp3s {
  title "Song announce (/sa, /np)"
  size -1 -1 203 165
  option dbu
  icon $scriptdirdll\i.dll, 17
  tab "Winamp/MM", 20, 3 0 197 150
  box "Serving (max 3 sends)", 12, 8 97 188 32, tab 20
  box "Usage", 7, 8 51 188 45, tab 20
  text "", 6, 13 59 79 34, tab 20
  text "", 10, 94 59 100 34, tab 20
  check "Send file on request (5 min timeout)", 13, 13 105 98 10, tab 20
  edit "", 14, 151 105 42 11, tab 20 autohs
  edit "", 17, 151 116 42 11, tab 20 autohs
  text "Trigger:", 15, 130 106 21 9, tab 20 right
  text "Limit upload speed (KB/s, 0 = unlimited): ~", 16, 37 117 114 8, tab 20 right
  text "* Uses wa_link.dll wich may crash mIRC on some systems", 18, 10 132 145 8, tab 20
  text "** Does not work with MediaMonkey", 25, 10 140 141 8, tab 20
  tab "iTunes", 21
  box "Usage", 19, 8 51 188 39, tab 21
  text "", 23, 13 59 79 28, tab 21
  text "", 24, 94 59 100 28, tab 21
  check "Enable iTunes support instead of Winamp", 22, 9 93 150 10, tab 21
  button "OK", 3, 163 153 37 11, ok
  radio "/say", 5, 14 37 24 10
  radio "/me", 4, 38 37 23 10
  edit "", 1, 12 24 181 11, autohs
  button "Edit random", 11, 87 37 37 11
  button "Default", 9, 125 37 33 11
  button "Preview", 8, 159 37 33 11
  box "Display", 2, 8 16 188 35
}
On *:dialog:mp3s:init:0:{
  if ($ncfg(mp3s)) {
    if ($gettOK($ncfg(mp3s),1,32) == say) { 
      did -c mp3s 5
      did -a mp3s 1 $replace($right($ncfg(mp3s),-3),âbåld,,âcålår,,âånderlajn,,âcläör,)
    }
    else {
      did -c mp3s 4
      did -a mp3s 1 $replace($right($ncfg(mp3s),-2),âbåld,,âcålår,,âånderlajn,,âcläör,)
    }    
  }
  if ($ncfg(mp3getcmd)) did -ar mp3s 14 $ifmatch
  if ($ncfg(mp3maxcps)) did -ar mp3s 17 $replace($ifmatch,o,0)
  n.ds cr 13 mp3serv
  n.ds cr 22 itunes
  did -a mp3s 6 [artist]*, [title]* and [album]* $crlf $+ [etime] (elapsed time) $crlf $+ [time] (total time) $crlf $+ [kbps] (bitrate, eg: 192 kbps) $crlf $+ [size] (eg: 4.7 MB)
  did -a mp3s 10 [random] (random line, edit above) $crlf $+ [type] (filetype, eg: mp3) $crlf $+ [filename] (eg: asd.mp3) $crlf $+ [path]/[folder] (eg: c:\music\) $crlf $+ [mp3]** (as shown on winamp's titlebar)
  did -a mp3s 23 [artist], [title] and [album] $crlf $+ [etime] (elapsed time) $crlf $+ [time] (total time) $crlf $+ [kbps] (bitrate, eg: 192 kbps)
  did -a mp3s 24 [random] (random line, edit above) $crlf $+ [type] (filetype, eg: mp3) $crlf $+ [mp3] (artist - title)
  if ($ncfg(itunes) == 1) .timer -m 1 10 did -f mp3s 21
}
On *:dialog:mp3s:sclick:11:txt config\mp3.txt
On *:dialog:mp3s:sclick:9:{
  did -ar mp3s 1 $iif($ncfg(itunes) == 1,iTunes,winamp) » [mp3] :: [time]
  did -c mp3s 5
  did -u mp3s 4
}
On *:dialog:mp3s:sclick,edit:8,1:{
  if ($did(mp3s,1).text) { 
    var %temp = $did(mp3s,1).text 
    n.preview mp3s $replace(%temp,[mp3],Artist - Song title,[type],mp3,[artist],Artist,[title],Song title,[album],Album,[time],3:12,[etime],1:54,[kbps],192 kbps,[size],4.7MB,[filename],04-artist-the_song.mp3,[path],$mircdir,[folder],folder name,[random],random line)
  }
}
On *:dialog:mp3s:sclick:22:{
  n.ds cw 22 itunes
  if ($did(mp3s,22).state == 1) did -ar mp3s 1 $replace($did(mp3s,1),winamp,iTunes)
  else did -ar mp3s 1 $replace($did(mp3s,1),iTunes,winamp)
}
On *:dialog:mp3s:sclick:3:{
  if ($did(mp3s,13).state == 1) w_ncfg mp3serv 1
  else w_ncfg mp3serv o
  if ($did(mp3s,17).text) { w_ncfg mp3maxcps $ifmatch | .dcc maxcps $calc($iif($ncfg(mp3maxcps) == o,0,$ncfg(mp3maxcps)) * 1024) }
  else w_ncfg mp3maxcps o
  if ($did(mp3s,14).text) w_ncfg mp3getcmd $ifmatch
  else w_ncfg mp3getcmd none
  if ($did(mp3s,5).state == 1) var %temp = say
  else var %temp = me
  if ($did(mp3s,1).text) var %temp2 = $ifmatch
  w_ncfg mp3s %temp $replace(%temp2,,âbåld,,âcålår,,âånderlajn,,âcläör)
}