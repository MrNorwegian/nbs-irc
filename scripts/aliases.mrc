alias ip {
  if ($ip) $iif($1 == -e,n.echo normal -atg,say) ip: $ip
  else n.echo normal -atg no ip found
}

alias whois2 do_whois $1
alias whois {
  if ($chr(42) isin $1) || ($chr(63) isin $1) do_whois $1
  else do_whois $1 $1
}

alias do_whois {
  if ($ncfg(whois) == @whois) { 
    set %w-dest @whois ( $+ $cid $+ )
    if (!$window(%w-dest)) {
      if ($ncfg(whois_inside) == 1)  window -k0n %w-dest 
      else window -k0dn %w-dest 200 200 600 200 nbs.ico
    }
    if ($ncfg(whois_inside) != 1) iline $color(info) %w-dest 1 $timestamp $pre waiting for reply $par($1)
    if ($appactive) && (!%whois.window.passive) window -a %w-dest
  }
  !whois $1-
}
alias idle {
  if (!$isid) && ($1) {
    set -u5 %whois.idle 1
    !whois $1 $1
  }
}
alias host2nick {
  if ($1) {
    set %dns2nick.host $1
    echo $color(other) -atg $npre Searching for user(s) with host: %dns2nick.host
    who %dns2nick.host
  }
  else n.echo other -atg Usage: /host2nick <hostname>
}
alias dns2nick host2nick $1-
alias ip2nick {
  if ($1) {
    set %tmp.i2n 1
    dns $1
  }
  else n.echo other -atg Usage: /ip2nick <ip>
}
alias join {
  if ($numtok($1,44) < 2) && (-* !iswm $1) {
    if ($left($1,1) == $chr(35)) || ($left($1,1) == &) var %c = $1
    else var %c = $chr(35) $+ $1
    if (!$2) && ($chankey(%c)) join %c $v1
    else { 
      if ($2) set %pw. [ $+ [ %c ] ] $2
      !join %c $2
    }
  }
  else !join $1-
}

alias kick {
  var %r = $read(config\kicks.txt)
  if ($1 ischan) kick $1 $2 $iif(!$3,%r,$3-)
  else kick $active $1 $iif(!$2,%r,$2-)
}

alias hevents {
  set %he.chan $1
  dlg hevent
}

alias addedit {
  if ($1) set %addedit $1-
  dlg addedit
}
alias bpre return $remove($strip($pre),$chr(160),$chr(32))
alias quitmsg {
  if (!$read(config\quits.txt)) { return - $strip($n.name) $n.version - www.nbs-irc.net - }
  else return $read(config\quits.txt)
}
alias bncwin {
  return @ $+ $1 ( $+ $2 $+ )
}
alias hidchans {
  var %tmp = 0, %i = 1
  while (%i <= $chan(0)) {
    if ($window($chan(%i)).state != hidden) inc %tmp
    inc %i
  }
  return %tmp
}
alias n.cbgn {
  var %i = 1, %e = $did($1,$2).lines
  while (%i <= %e) {
    if ($did($1,$2,%i) == $3) return %i
    inc %i
  }
}
alias amsg {
  if ($chan(0) == 0) { echo $color(info) -at $npre /amsg: you're not on a channel | return }
  if (!$1) { echo $color(info) -at $npre /amsg: insufficient parameters | return }
  .!amsg $1-
  var %i = 1, %t = $chan(0)
  while (%i <= %t) {
    echo $color(own) -qmnt $chan(%i) $replace($me.style,<mode>,$cmode($me,$chan(%i),o),<nick>,$me) $+  $1-
    inc %i 1
  }
}
alias amsg2 {
  if (!$1) {
    echo $color(info) -atg $npre /amsg2: lets you exclude channels from 'amsg'
    echo $color(info) -atg $npre Usage: /amsg2 setlist to view ignored channels, /amsg2 setlist <channels> to set ignored channels $par(seperated with space) $+ , /amsg2 message
  }
  elseif ($1 == setlist) && ($2) { 
    w_ncfg amsg_ignore $2- 
    n.echo info -atg Channels to not msg: $2- $par($numtok($2-,32))
  }
  elseif ($1 == setlist) && (!$2) echo $color(info) -atg $npre Current channels to ignore: $iif($ncfg(amsg_ignore),$ifmatch $par($numtok($ifmatch,32)),none)
  else {
    var %i = 1, %t = $chan(0), %amsg.ignore = $ncfg(amsg_ignore), %amsg.chans
    while (%i <= %t) {
      if (!$istok(%amsg.ignore,$chan(%i),32)) {
        var %amsg.chans = $addtok(%amsg.chans,$chan(%i),44)
        echo $color(own) -qmnt $chan(%i) $replace($me.style,<mode>,$cmode($me,$chan(%i),o),<nick>,$me) $+  $1-
      }
      inc %i 1
    }
    .raw PRIVMSG %amsg.chans : $+ $1-
  }
}
alias notice {
  if ($isid) return
  if ($2) {
    echo $color(notice) -atgq $pre $kl:(notice: $1) $2-
    !.notice $1-
  }
  else n.echo info -atg usage: /notice nick message
}
alias ctcp {
  if ($isid) return
  if ($2 == ping) set %ctcp.ping.ticks $ticks
  n.echo ctcp -atgq $kl:(CTCP to $1) $upper($2)) $3-
  !.ctcp $1-
}
alias dcc {
  if ($isid) return
  .write $cit($logdir $+ -dcc.log) $date $time - Send to $2 $+ : $3- ( $+ $round($calc($file($3).size /1024/1024),2) MB)
  !dcc $1-
}
alias msg {
  if ($isid) || ($0 < 2) return
  if (!$window($1)) echo -atqg $npre $kl:(msg: $1) $2-
  else echo $color(own) -qnmti4 $1 $replace($me.style,<mode>,$cmode($me,$1,o),<nick>,$me) $+  $2-
  !.msg $1-
}
alias pastemsg {
  if ($isid) || ($0 < 2) return
  else echo $color(own) -nmti4 $1 $replace($me.style,<mode>,$cmode($me,$1,o),<nick>,$me) $+  $2-
  !.msg $1-
}
alias say {
  if ($active === Status Window) { n.echo info -atg Error: can't use command here }
  else msg $active $1-
}
alias sendcb {
  if (!$1) { n.echo info -atg Usage /sendcb <nick> [filename] | return }
  if (!$cb) { n.echo info -atg No text in clipboard | return }
  if (!$2) { var %c = 1, %r = $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z) $+ $r(a,z)
    while (%c <= $cb(0)) {
      write clip- $+ %r $+ .txt $cb(%c)
      inc %c
    }
    dcc send $1 clip- $+ %r $+ .txt
    .timer 1 60 .remove clips- $+ %r $+ .txt
  }
  if ($2) { 
    var %c = 1
    while (%c <= $cb(0)) {
      write $2 $+ .txt $cb(%c)
      inc %c
    }
    dcc send $1 $2 $+ .txt
    .timer 1 60 .remove $2 $+ .txt
  }
}
alias n.bnc {
  if (!$window($bncwin($1,$cid))) {
    window -k0ne $bncwin($1,$cid)
    echo -te $bncwin($1,$cid) $npre $1 window, right click for options.
  }
  else window -g1 $bncwin($1,$cid)
  if ($2) {
    .!msg - $+ $1-
    echo $color(notice) -t $bncwin($1,$cid) - $2-
  }
}
alias nickserv_ghost {
  if ($lines(config\nickserv- $+ $network $+ .txt) > 0) {
    var %a = $read(config\nickserv- $+ $network $+ .txt), %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
    while (%k > 1) {
      var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
      inc %i 1
    }
    set %tmp.ghost $gettok(%a,1,44)
    nickserv ghost $gettok(%a,1,44) %r
  }
}

alias echoall {
  if (!$1) { return }
  var %i = 1  
  while (%i <= $chan(0)) {
    echo -g $chan(%i) $1-
    inc %i
  }
  unset %i 
}
alias topicall {
  var %i = 1 
  while (%i <= $chan(0)) {
    if ($chan(%i).topic) echo $color(topic) -tgi4 $chan(%i) - Topic: $chan(%i).topic
    inc %i
  }
  unset %i 
}
alias whochan {
  if (!$1) return
  var %c = $1
  if (!%whos) || (%whos > 180) set -u120 %whos 5
  else inc %whos 10
  if ($nick(%c,0) < 150) && ($nick(%c,0) > 1) && (!$chan(%c).ial) .timerwho. [ $+ [ $cid ] $+ ] . [ $+ [ %c ] ] 1 [ %whos ] !who %c
}
alias topicchan {
  if (!$1) return
  if ($chan($1).topic) .write -il1 $+(scripts\temp\topic\,$md5($1),â,$cid) $chan($1).topic
}
alias authedited {
  if ($ncfg(authnick) != nick) && ($ncfg(authpass) != pass) return $true
}
alias qwa {
  if ($isid) return $dll(scripts\dll\wa_link.dll,WA_Link_Raw_Stats,$1-)
}
alias swamp {
  if ($isid) return $dll(scripts\dll\swamp.dll,WinAmpGet,$1-)
}
alias winamp.tid {
  var %s = $1, %a = $asctime($qwa(%s),nn:ss)
  if ($asctime($qwa(%s),HH) > 1) var %a = $calc($gettok(%a,1,58) + ($ifmatch -1) *60) $+ : $+ $gettok(%a,2,58)
  return %a
}
alias n.capss {
  if ($len($3-) > 9) {
    if ($calc(100- $len($removecs($strip($3-),A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,Å,Ä,Ö,Ü,Ë,É,Ø)) / $len($strip($3-)) *100) >= $hget(prot,$+($1,caps.maxpercent))) {
      kick $1-2 $iif($hget(prot,$+($1,caps.kickmsg)),$ifmatch,excess caps)
    }
  }
}
alias n.floods {
  hadd -m temp flood $dll(scripts\dll\aircdll.dll, Flood, $+($1,$chr(44),$wildsite) 1 $hget(prot,$+($1,flood.lines)) $hget(prot,$+($1,flood.seconds)))
  if (+FLOOD* iswm $hget(temp,flood)) { 
    if ($hget(prot,$+($1,flood.ban)) == 1) ban $iif($hget(prot,$+($1,bantime)) isnum 1-,-u $+ $calc($ifmatch *60)) $1-2 $ncfg(ban_mask)
    kick $1-2 $iif($hget(prot,$+($1,flood.kickmsg)),$ifmatch,no flooding)
  }
}
alias n.repeats {  
  hinc -mu10 temp $+($1,$2,$strip($3-)) 1
  if ($hget(temp,$+($1,$2, $strip($3-))) >= $hget(prot,$+($1,repeat.max))) {
    hdel temp $+($1,$2,$strip($3-))
    if ($hget(prot,$+($1,repeat.ban)) == 1) ban $iif($hget(prot,$+($1,bantime)) isnum 1-,-u $+ $calc($ifmatch *60)) $1-2 $ncfg(ban_mask)
    kick $1-2 $iif($hget(prot,$+($1,repeat.kickmsg)),$ifmatch,no repeating)
  }
}
alias n.spams {
  if ($hget(prot,$+($1,advertising.type)) == 1) && (*#?* iswm $3-) {
    if ($hget(prot,$+($1,advertising.ban)) == 1) ban $iif($hget(prot,$+($1,bantime)) isnum 1-,-u $+ $calc($ifmatch *60)) $1-2 $ncfg(ban_mask)
    kick $1-2 $iif($hget(prot,$+($1,advertising.kickmsg)),$ifmatch,no advertising)
  }
  elseif ($hget(prot,$+($1,advertising.type)) == 1) && (*join*#?* iswm $3-) || */j*#?* iswm $3-) {
    if ($hget(prot,$+($1,advertising.ban)) == 1) ban $iif($hget(prot,$+($1,bantime)) isnum 1-,-u $+ $calc($ifmatch *60)) $1-2 $ncfg(ban_mask)
    kick $1-2 $iif($hget(prot,$+($1,advertising.kickmsg)),$ifmatch,no advertising)
  }
}
alias clonescan {
  if (!$1) var %ch = $active
  else var %ch = $1
  if (%ch !ischan) { echo $color(info) -atg $npre Usage: /clonescan [#channel] | return }
  if ($me !ison %ch) return
  var %i = 1, %w, %b
  if (!$chan(%ch).ial) {
    if ($nick(%ch,0) > 350) {
      var %b = $n.input(This is a very large channel $+ $c44 scanning it might result in being disconnected. Do you want to scan it anyway?,y/n)
      if (%b) {
        echo $color(info) -agt $npre updating ial for %ch $+ , please wait.
        set %csial %ch
        !who %ch
        return
      }
    }
    else {
      echo $color(info) -agt $npre updating ial for %ch $+ , please wait.
      set %csial %ch
      !who %ch
      return
    }
  }
  if ($hget(clones)) hfree clones
  hmake clones 1
  var %antal = $nick(%ch,0), %antalk
  while (%i <= %antal) {
    var %w = $address($nick(%ch,%i),2)
    if ($nick(%ch,%i)) hadd clones %w $hget(clones,%w) $clr(inf,$cmode($nick(%ch,%i),%ch,a)) $+ $nick(%ch,%i)
    inc %i
  }
  window -nk0 @clones
  echo @clones $chr(160)  
  echo @clones $chr(160)
  echo @clones Clones in %ch $+ :
  echo @clones $chr(160)
  var %i = 1
  while (%i <= %antal) {
    var %k = 1
    if ($numtok($hget(clones,%i).data,32) > 1) {
      var %k = $ifmatch, %w = $hget(clones,%i).data
      echo -i2 @clones $kl($hget(clones,%i).item)
      echo -i2 @clones $chr(160) %k $+ : $replace(%w,$chr(32),$str($chr(160),3))
      echo @clones $chr(160)
      inc %antalk %k
    }
    inc %i
  }
  var %unik = $calc(%antal - %antalk)
  echo @clones $npre Unique hosts: %unik $+ / $+ %antal $par($perc(%unik,%antal))
  window -a @clones
  hfree clones
  unset %csial
}
alias awaysys {
  if ($away) n.echo normal -atg you are already marked away: $awaymsg
  else dlg way
}
alias lame power $1-
alias power {
  var %i = 1, %op = 0, %s = 0, %alla = 0
  while (%i <= $chan(0)) {
    if ($me isop $chan(%i)) {
      inc %op 1 
      inc %s $nick($chan(%i),0)
    }
    inc %alla $nick($chan(%i),0)
    inc %i 1
  }
  $iif($1 == -e,echo -agt $npre you are,me is) oped in $+(%op,/,$chan(0)) channels on $+($network,.) (in control of $+(%s,/,%alla) people)
}
alias dns {
  if (!$1) { dns | return }
  echo $color(other) -atq $npre Looking up $n.quote($1)
  .!dns $1-
}
alias fasttitle {
  if ($appstate == tray) !flash $strip($remove($1-,$,%,|))
  else !dll scripts\dll\aircdll.dll SetMircTitle $strip($eval($1-,1))
  .!timertitlebar off
}
alias n.history { 
  if ($read($1,w,$2-)) { 
    write -dl $+ $readn $1
  }
  write -il0 $1-
  while ($lines($1) > 20) {
    write -dl $+ $lines($1) $1
  }
}

alias titleupdate {
  if ($appstate != minimized) && ($appstate != tray) {
    if (!$timer(titlebar)) .timertitlebar -i 0 10 titleupdate
    if ($status == connected) { 
      if (!$hget(temp,clag.block)) && ($hget(nbs,check_lag) == 1) {
        hadd -mu29 temp clag.block 1
        .notice $me lag437289 $ticks
      }
      if ($dialog(tb)) {
        did -ac tb 1 $+($network,:) $+($server,:,$port)
        var %lag = $iif(%lag. [ $+ [ $cid ] ],$ifmatch ms, --)
        if ($away) { did -ar tb 2 connected: $dur($uptime(server,3),2) $+ $iif($hget(nbs,check_lag) == 1,$c44 lag: %lag) $+ , away: $dur($awaytime,2) ( $+ $awaymsg $+ ) }
        elseif ($idle > 60) { did -ac tb 2 idle: $dur($idle,2) $+ , connected: $dur($uptime(server,3),2) $+ $iif($hget(nbs,check_lag) == 1,$c44 lag: %lag) }
        else { did -ac tb 2 connected: $dur($uptime(server,3),2) $+ $iif($hget(nbs,check_lag) == 1,$c44 lag: %lag) }
      }
    }
    elseif ($dialog(tb)) { 
      did -ac tb 1 nbs-irc $n.version - nbs-irc.net
      did -ac tb 2 Use F2 to configure nbs-irc
    }
  }
  .titlebar $iif($hget(nbs,titlebar_version) == 1,$version - $strip($n.name $n.version)) $iif($hget(nbs,titlebar_lag) == 1, $iif(%lag. [ $+ [ $cid ] ],- $ifmatch ms))
  if ($time(H) == 23) && ($time(n) == 59) .timerdaychange -o 0:00 1 0 scon -at1 n.daychange
  if ($ncfg(ci-check) == 1) { 
    if (%cicheck > 6) {
      set %cicheck 0
      ci-check
    }
    else inc %cicheck 1
  }
}
alias n.daychange {
  if ($ncfg(show_daychanged) == 1) {
    var %i = 1, %msg = Day changed to $day $par($date(d mmm yyyy)) 
    while (%i <= $chan(0)) {
      n.echo info -t $chan(%i) %msg
      inc %i
    }
    var %i = 1
    while (%i <= $query(0)) {
      n.echo info -t $query(%i) %msg
      inc %i
    }
    n.echo info -st %msg
  }
}

; Lag check
alias clag {
  set %lc 1
  .notice $me lag437289 $ticks
}
alias n.ds {
  if (!$3) return
  elseif ($1 == cw) {
    if ($did($dname,$2).state == 1) w_ncfg $3 1
    else w_ncfg $3 o
  }
  elseif ($1 == cr) {
    if ($ncfg($3) == 1) did -c $dname $2
    else did -u $dname $2
  }
}

alias n.preview {
  if ($dialog($1)) && ($2) {
    if (!$window(@previewx)) {
      window -hodfnp +dL @previewx 99 $calc($dialog($1).y -60) $calc($window(-1).w -198) 52
      drawrect @previewx $color(normal) 0 0 0 $calc($window(-1).w -198) 52
      drawtext -o @previewx $color(highlight) tahoma 10 4 2 $iif($dialog(cc),Topic preview for %ccc $+ :,Preview - right click to close)
      window -o @previewx 
    }
    if (!$window(@preview)) {
      window -dhk0 +dL @preview 100 $calc($dialog($1).y -40) $calc($window(-1).w -200) 31
    }
    clear @preview
    echo $iif($dialog(cc),$color(topic),$color(normal)) @preview $2-
    window -o @preview
  }
  elseif ($window(@preview)) close -@ @preview*
}

on *:dialog:*:close:0:{
  if ($window(@preview)) close -@ @preview*
}

alias setver {
  var %date = $iif($1,$1,$date(yy-mm-dd))
  write -c scripts\other\version %date
  n.echo info -atg Version: $n.version ( $+ %date $+ )
}

alias n.url {
  var %f = $+(scripts\temp\url_,$r(a,z),$r(a,z),$r(a,z),$r(a,z),.url)
  write -c %f [InternetShortcut]
  write %f URL= $+ $1-
  .run %f
  .timer 1 3 .remove %f
}

alias n.toolbar {
  toolbar -r
  toolbar -d sep1
  toolbar -d sep2
  toolbar -d sep3
  toolbar -d sep4
  toolbar -d sep5
  toolbar -d sep6
  toolbar -d sep7
  toolbar -d chanlist
  toolbar -d addrbook
  toolbar -d timer
  toolbar -d send
  toolbar -d chat
  toolbar -d dccopts
  toolbar -d rcvdfiles
  toolbar -d logfiles
  toolbar -d notify
  toolbar -d notify2
  toolbar -d urls
  toolbar -d urls2
  toolbar -d about
  toolbar -m 8 6
  toolbar -m 6 7
  toolbar -iz1n7 3 ac "Auto connect settings" scripts\dll\tb.dll /autocon @tb.ac
  toolbar -is 5 s1
  toolbar -is 10 s2
  toolbar -iz1n0 11 nbs-setup "nbs options" scripts\dll\tb.dll /setup @tb.setup
  toolbar -iz1n2 12 nbs-theme "Theme/font setup" scripts\dll\tb.dll /theme @tb.theme
  toolbar -iz1n3 13 nbs-alarm "Alarm timer" scripts\dll\tb.dll /alarm @tb.alarm
  toolbar -iz1n1 14 nbs-lv "Logviewer" scripts\dll\tb.dll /logg @tb.lv
  if ($ncfg(toolbar_disable_winamp) != 1) {
    toolbar -is 15 s3
    toolbar -iz1n4 16 nbs-waprev "Previous track (Winamp)" scripts\dll\tb.dll "/dll scripts\dll\winamp.dll prevsong"
    toolbar -iz1n5 17 nbs-waplaypause "Play/pause (Winamp)" scripts\dll\tb.dll "/dll scripts\dll\winamp.dll playpause"
    toolbar -iz1n6 18 nbs-wanext "Next track (Winamp)" scripts\dll\tb.dll "/dll scripts\dll\winamp.dll nextsong"
  }
  if ($dialog(tb)) dialog -x tb
  dlg tb
  showmirc -s
}

alias n.ptext {
  if ($hget(nbs,popup_mode) == 2) && ($appactive) return
  elseif ($hget(nbs,popup_mode) == 4) return
  if ($hget(nbs,popup_away) == 1) && ($away) return
  n.ptext2 $1-
}
alias n.ptext2 {
  if ($chr(1) isin $2-) {
    hadd -m temp lastpop $1-
    if ($window(@n.popup)) close -@ @n.popup
    var %1 = $gettok($1-,2,1), %2 = $gettok($1-,3-,1)
    if ($gettok($1-,1,1)) set %popup.window $ifmatch
    else unset %popup.window
    var %font = $window(status window).font, %fontsize = $window(status window).fontsize
    var %h = $calc($height(l,%font,%fontsize) +25)
    if ($width(%2,%font,%fontsize) > 250) && ($width(%2,%font,%fontsize) <= 750) {
      var %w = $calc($width(%2,%font,%fontsize) + $width(Mia,%font,%fontsize))
    }
    elseif ($width(%2,%font,%fontsize) <= 250) {
      var %w = $calc($width(%2,%font,%fontsize) + (250 - $width(%2,%font,%fontsize)))
    }
    else {
      while ($width(%2,%font,%fontsize) > 1000) var %2 = $left(%2,$calc($len(%2) -30))
      while ($width(%2,%font,%fontsize) > 750) var %2 = $left(%2,$calc($len(%2) -10))
      var %2 = $left(%2,$calc($len(%2) -3)) $+ ...
      var %w = $calc($width(%2,%font,%fontsize) + $width(...,%font,%fontsize))
    }
    if ($chr(45) isin $hget(nbs,popup_posx)) && ($hget(nbs,popup_centerx) != 1) { var %x = $calc( [ $window(-1).w ] - (%w + $remove($hget(nbs,popup_posx),-))) }
    elseif ($chr(45) !isin $hget(nbs,popup_posx)) && ($hget(nbs,popup_centerx) != 1) { var %x = $$hget(nbs,popup_posx) } 
    elseif ($hget(nbs,popup_centerx) == 1) { var %x = $calc($window(-1).w /2- (%w /2)) }
    if ($chr(45) isin $hget(nbs,popup_posy)) && ($hget(nbs,popup_centery) != 1)  { var %y = $calc( [ $window(-1).h ] - $remove($hget(nbs,popup_posy),-) ) }
    elseif ($chr(45) !isin $hget(nbs,popup_posy)) && ($hget(nbs,popup_centery) != 1) { var %y = $hget(nbs,popup_posy) }
    elseif ($hget(nbs,popup_centery) == 1) { var %y = $calc($window(-1).h /2- 19) }
    window -hodfnp +dL @n.popup %x %y %w %h
    drawfill @n.popup $color(background) 0 1 1
    drawtext -o @n.popup $color(highlight) tahoma 10 4 2 %1
    drawtext -o @n.popup $color(info) tahoma 10 $calc(%w -51) 2 $time
    drawtext -p @n.popup $color(normal) $cit(%font) %fontsize 4 20 %2
    drawrect @n.popup $color(normal) 0 0 0 %w %h
    if ($timerncpopup) .timerncpopup off
    .timerncpopup -oi 1 $iif($hget(nbs,popup_timeout),$ifmatch,7) close -@ @n.popup
    window -o @n.popup
  }
}
alias n.aj.edit {
  if (!$1) return
  var %a = config\autojoin- $+ $network $+ .txt
  if ($read(%a,w,$1*)) {
    write -dl $+ $readn %a
    n.echo info -atg Removed $1 from autojoin $iif($ncfg(autojoin) != 1,$par(autojoin is off))
  }
  else {
    if (k isin $chan($1).mode) && (!$chankey($1)) var %k = $n.input(Enter channel key:)
    else var %k = $chankey($1)
    write %a $1 %k
    n.echo info -atg Added $1 $iif(%k,$par(key: %k)) to autojoin $iif($ncfg(autojoin) != 1,$par(note: autojoin is off))
  }
}
alias invite {
  if (!$2) && (#) !invite $1 #
  else !invite $1-
}
alias away {
  unset %n.away.*
  !away $1-
}
alias lastpop {
  n.ptext2 $hget(temp,lastpop)
}
alias logg {
  if ($window(@logviewer)) && (!$n.input(Clear logviewer and load $window($active).logfile $+ ?,y/n)) return
  close -@ @logviewer
  lv $iif($1,$1,$active)
}
alias lv logviewer $1-
alias logviewer {
  if ($window(@logviewer)) {
    window -a @logviewer
    return
  }
  set %lv.dir $logdir
  if ($1) {
    if ($window($1)) {
      set %lv.dir $nofile($window($1).logfile)
      var %load = $n.log($1)
    }
    elseif ($exists($logdir $+ $network $+ \ $+ $1 $+ .log)) {
      set %lv.dir $logdir $+ $network $+ \
      var %load = %lv.dir $+ $1 $+ .log
    }
  }
  window -l25eazk0 @Logviewer
  if (%load) aline -l @logviewer $chr(91) .. $chr(93)
  var %a = $finddir(%lv.dir,*,0,1,aline -l @logviewer $chr(91) $nopath($1-) $chr(93))
  var %b = $findfile(%lv.dir,*.log,0,1,aline -l @logviewer $nopath($1-))
  if (%load) {
    if ($file(%load).size > 10000000) {
      if (!$n.input(This is a very large log file ( $+ $round($calc($file(%load).size /1024/1024),2) MB) $+ $c44 loading will take some time. Do you want to continue?,y/n)) return
    }
    echo @logviewer $npre loading %load $+ ... 
    loadbuf -pi4 @logviewer $+(",%load,")
    echo @logviewer $npre $kl:($nopath(%load)) $lines(%load) lines, $round($calc($file(%load).size /1024),2) KB
  }
  ;%b log files and %a folders found in %lv.dir
}
alias slog {
  if ($1) {
    var %s.file = $n.log($active)
    if (!$isfile(%s.file)) n.echo other -atg /slog: no log file found for $active
    else {
      var %s.win = @search:  $+ $nopath(%s.file), %t = $ticks
      if ($file(%s.file).size > 10000000) {
        if (!$n.input(This is a very large log file ( $+ $round($calc($file(%s.file).size /1024/1024),2) MB) $+ $c44 searching it will take some time. Do you want to continue?,y/n)) return
      }
      if (!$window(%s.win)) window -k0n %s.win
      clear %s.win
      echo -t %s.win $npre searching for $n.quote($1-) in %s.file
      echo %s.win 
      window -a %s.win
      filter -fwpb $+(",%s.file,") %s.win * $+ $1- $+ *
      if ($filtered) {
        echo %s.win 
        echo -t %s.win $npre found $filtered matches in %s.file $par($round($calc(($ticks - %t)/1000),1) $+ s)
      }
      else echo -t %s.win $npre no matches were found for $n.quote($1-) in %s.file
    }
  }
  else n.echo info -atg usage: /slog <query>
}
alias n.echo {
  if ($window($3)) && (a !isin $2) && (s !isin $2) echo $color($1) $2 $+ i4 $3 $npre $4-
  elseif ($cid != $activecid) {
    scid $cid
    echo $color($1) $replace($2,a,s) $+ i4 $npre $3-
    scid -r
  }
  elseif (t isin $2) echo $color($1) $2 $+ i4 $npre $3-
  else echo $color($1) $2 $+ i4 $3-
}
alias month {
  if ($1 isnum 1-12) {
    var %d = $calc($1 +1), %days = $iif($1 == 12,31,$gettok($asctime($calc($ctime(1/ $+ %d $+ /2008 00:00) - 86400)),3,32))
    n.echo info -atg Month $1 $+ : $clr(norm,$date($ctime(08- $+ $1 $+ -01),mmmm)) $par(%days days)
  }
  else n.echo info -atg Usage: /month <1-12>
}

alias channel {
  if (% [ $+ [ # ] $+ ] .disabled == 1) && (!$chan(#).mode) {
    n.echo other -atg $kl:(channel central) please wait...
    return
  }
  if ($ncfg(newcc) == 1) cc #
  else !channel
}
alias auth { 
  if ($n.qnet) {
    if ($2) {
      .raw auth $1-
      var %a = auth $par($1)
    }
    elseif ($ncfg(use_challengeauth) == 1) && ($authedited) {
      .msg Q@CServe.quakenet.org challenge
      var %a = auth challenge $par($ncfg(authnick))
    }
    elseif ($authedited) {
      var %q = $ncfg(authpass), %k = $calc($len(%q) +1), %x = 1, %r
      while (%k > 1) {
        var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
        inc %x 1
      }
      .raw auth $ncfg(authnick) %r
      var %a = auth $par($ncfg(authnick))
    }
    if (%a) n.echo notice -agqt sending %a
  }
  elseif ($n.unet) {
    if ($2) {
      .msg x@channels.undernet.org login $1-
      var %a = auth $par($1)
    }
    elseif ($ncfg(undernet_authnick)) {
      var %q = $ncfg(undernet_authpass), %k = $calc($len(%q) +1), %x = 1, %r
      while (%k > 1) {
        var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid(%q,%k,3) + %x))
        inc %x 1
      }
      .msg x@channels.undernet.org login $ncfg(undernet_authnick) %r
      var %a = auth $par($ncfg(undernet_authnick))
    }
    if (%a) n.echo notice -agqt sending %a
  }
}

alias exportlog {
  if ($1) var %f = $1-, %a
  elseif (!$1) var %f = $sfile($logdir *.*,Please select log file to export)
  if ($file(%f).size > 10000000) && (!$n.input(This may take some time. $crlf $crlf $+ Do you want to continue?,y/n)) return
  var %o = $sfile($replace($nopath(%f),.log,.txt),Please select destination file,Create)
  if (%o) write -c $cit(%o)
  if ($exists(%f)) && ($exists(%o)) {
    dialog -md exportlog exportlog
    if ($file(%f).size > 1000000) {
      showmirc -t
      var %m = m
    }
    var %i = 1, %t = $lines(%f), %tid = $ticks
    did -ar exportlog 1 Opening files
    .fopen i $cit(%f)
    .fopen -no o $cit(%o)
    while (!$fopen(i).eof) {
      if ($fread(i)) .fwrite -n o $strip($ifmatch)
      else .fwrite o $crlf
      if (9 isin %i) did -ar exportlog 1 Exporting: $round($calc(%i / %t *100),0) $+ %
      inc %i 1
    }
    .fclose i
    .fclose o
    n.echo other -atg log export finished in $round($calc(($ticks - %tid)/1000),1) $+ s $par(output: %o)
    if (%m) showmirc -s
    dialog -x exportlog
    .timer 1 0 if ($n.input(Do you want to open $nopath(%o) $+ ?,y/n)) run $cit(%o)
  }
  else n.echo other -atg /exportlog: file error
}
alias query {
  if (!$1) return
  if ($query($1)) { !query $1- | return }
  !query $1
  n.query.stats $1 $ial($1).addr
  if ($2) msg $1-
}
alias n.query.stats {
  w_ncfg query_total $calc($ncfg(query_total) +1)
  echo $color(info) -tg $1 $npre Query with $1 $par($2)
  if ($comchan($1,0) > 0) { 
    var %i = 1
    while (%i <= $comchan($1,0)) {
      var %comchans = %comchans $cmode($1,$comchan($1,%i),a) $+ $comchan($1,%i)
      inc %i
    }
    echo $color(info) -tg $1 $npre Common channels: $replace(%comchans,$chr(32),$chr(44) $+ $chr(32)) $par($comchan($1,0))
  }
  echo $color(info) -tg $1 $npre Total querys: $ncfg(query_total) $par(~ $+ $avgpd($ncfg(query_total)) per day)
}

alias n.netsplitquit {
  var %i = 1
  while (%i <= $chan(0)) {
    if ($hget(temp,netsplit.tq. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ]) > 0) {
      if ($hget(temp,netsplit.quit.f. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ]) != 1) {
        hadd -m temp nstemp $hget(temp,netsplit.quit. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ])
        n.echo quit -ti4 $chan(%i) Netsplit $par($1 - $2) $numtok($hget(temp,nstemp),44) quits: $left($hget(temp,nstemp),-1)
      }
      else {
        n.echo quit -ti4 $chan(%i) Netsplit $par($1 - $2) $hget(temp,netsplit.tq. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ]) quits
      }
    }
    hdel -w temp netsplit.*. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ]
    hdel temp nstemp
    inc %i
  }
}
alias n.netsplitjoin {
  if ($1) && ($hget(temp,netsplit.tj. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ]) > 0) {
    if ($hget(temp,netsplit.join.f. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ]) != 1) {
      if ($hget(temp,netsplit.join. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ])) hadd -m temp nstemp $ifmatch
      if ($numtok($hget(temp,nstemp),44) > 1) n.echo join -ti4 $1 Join: $left($hget(temp,nstemp),-1) $par($numtok($hget(temp,nstemp),44))
      else n.echo join -ti4 $1 Join: $left($hget(temp,nstemp),-1) $par($right($address($left($hget(temp,nstemp),-1),1),-3))
    }
    else {
      n.echo join -ti4 $1 Join: $hget(temp,netsplit.tj. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ]) nicks have joined $1
    }
    hdel -w temp netsplit.*. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ]
    hdel temp nstemp
  }
}

alias n.log {
  var %x = $mid($window($1).logfile,1,-5) $+ log
  if ($exists(%x)) return %x
  else return $window($1).logfile
}

alias defbrowserfix {
  if ($?!="This will change CLASSES_ROOT\htmlfile\shell\open\command in the windows registry. Use only if you are not using IE as your default browser. $crlf $crlf $+ Continue?") {
    var %newbrowser = $$sfile(c:\*.exe,Choose browser)
    if (%newbrowser) {
      write -c temp.reg REGEDIT4
      write temp.reg [HKEY_CLASSES_ROOT\htmlfile\shell\open\command]
      write temp.reg @="\" $+ $replace(%newbrowser,\,\\) $+ \""
      run regedit /s temp.reg
      .timer 1 2 .remove temp.reg
      .echo -qg $n.input(Browser changed to: %newbrowser $+ .,info)
    }
  }
}
alias notifyer {
  if ($notify($1)) { notify -r $1 }
  else notify $1
}

alias n.blscan {
  if ($1 !ischan) || ($hget(nbs,blacklist) != 1) return
  if ($me isop $1) || ($me ishop $1) {
    if ($chan($1).ial) && (!$timer(blscan. [ $+ [ $1 ] ])) {
      var %i = 1, %e = $lines(config\blacklist.txt), %bl.nicks, %bl.bans, %bl.reasons
      hadd -m temp blchan $1
      while (%i <= %e) {
        if (!$n.bluser($address($me,5))) {
          hadd -m temp bladdr $gettok($read(config\blacklist.txt,%i),1,44)
          if ($gettok($read(config\blacklist.txt,%i),2,44)) hadd -m temp blreason $gettok($read(config\blacklist.txt,%i),2-,44)
          else hadd -m temp blreason Blacklisted
          if ($ialchan($hget(temp,bladdr),$hget(temp,blchan),0) > 0) {
            var %in = 1
            while (%in <= $ialchan($hget(temp,bladdr),$hget(temp,blchan),0)) {
              var %bl.nicks = $+(%bl.nicks,â,$ialchan($hget(temp,bladdr),$hget(temp,blchan),%in).nick)
              var %bl.bans = $+(%bl.bans,â,$hget(temp,bladdr))
              var %bl.reasons = $+(%bl.reasons,â,$hget(temp,blreason))
              inc %in
            }
          }
        }
        inc %i  
      }
      if ($numtok(%bl.nicks,266) < 6) && ($numtok(%bl.nicks,266) > 0) {
        var %i = 1, %e = $numtok(%bl.nicks,226)
        while (%i <= %e) {
          !raw -q mode $hget(temp,blchan) -o+b $gettok(%bl.nicks,%i,226) $gettok(%bl.bans,%i,226) $+ $crlf $+ KICK $hget(temp,blchan) $gettok(%bl.nicks,%i,226) : $+ $gettok(%bl.reasons,%i,226)
          inc %i
        }
      }
    }
    elseif ($nick($1,0) < 150) .timerblscan. [ $+ [ $1 ] ] 1 20 .timer 1 1 n.blscan $1
  }
}
alias n.bluser {
  if ((!$1) || ($lines(config\blacklist.txt) < 1)) return
  unset %bltmp
  var %user = $1, %i = 1, %e = $lines(config\blacklist.txt)
  while (%i <= %e) {
    if ($remove($gettok($read(config\blacklist.txt,%i),1,44),$chr(32)) iswm %user) set -u10 %bltmp $read(config\blacklist.txt,%i)
    inc %i
  }
  if (%bltmp) return 1
}
alias aj {
  var %a = config\autojoin- $+ $network $+ .txt
  if ($lines(%a) == 0) { return }
  if ($read(%a,1) == #channel1) && ($read(%a,2) == #channel2 key) && (!$read(%a,3)) {
    n.echo other -stge ignoring autojoin $par(no channels added)
    return
  }
  var %i = 1, %newchans = 0, %end = $lines(%a)
  while (%i <= %end) {
    if ($me !ison $gettok($read(%a,%i),1,32)) { 
      if ($gettok($read(%a,%i),2,32)) { 
        var %joincpw = %joincpw $gettok($read(%a,%i),1,32) $+ $chr(32)
        var %joinpwds = %joinpwds $gettok($read(%a,%i),2,32) $+ $chr(32)        
      }     
      else var %joinchans = %joinchans $gettok($read(%a,%i),1,32)) $+ $chr(32)
      inc %newchans
    }
    inc %i
  }
  if (%newchans > 0) {
    echo $color(other) -st $npre joining %newchans channel $+ $iif(%newchans > 1,s)
    if (%joinchans) !join $iif($ncfg(autojoin_minimize) == 1,-n) $replace(%joinchans,$chr(32),$chr(44)) 
    if (%joincpw) !join $iif($ncfg(autojoin_minimize) == 1,-n) $replace(%joincpw,$chr(32),$chr(44)) $replace(%joinpwds,$chr(32),$chr(44))
  }
  else n.echo other -atg already on all channels in autojoin
}
alias emode {
  if ($2) {
    var %m = $1, %t = $2, %i = 1, %x
    tokenize 44 $snicks
    while (%i <= $0) {
      if ($numtok(%x,32) == $modespl) {
        mode # %m $+ $str(%t,$numtok(%x,32)) %x
        dec %i
        unset %x
      }
      else var %x = %x [ $chr(36) $+ [ %i ] ]
      inc %i
    }
    mode # %m $+ $str(%t,$numtok(%x,32)) %x
  }
}
alias ci {
  if (!$1) return
  return $round($calc($calc($calc($ticks - $hget(temp,ci. [ $+ [ $cid ] $+ ] . [ $+ [ $1 ] ])) / 1000) / 60),0)
}

alias ci-check {
  if ($ncfg(cic-time) < 1) return
  if ($scon(0) == 1) { 
    if ($status == connected) {
      var %i = 1
      while (%i <= $chan(0)) {
        if (($ci($chan(%i)) >= $ncfg(cic-time)) && ($nohide($chan(%i)) != 1)) { if (($window($chan(%i)).state != hidden) && ($chan(%i) != $active)) window -h $chan(%i) }
        inc %i
      }
    }
  }
  elseif ($scon(0) > 1) {
    set %ii 1
    while (%ii <= $scon(0)) {
      scon -t1 %ii
      if ($status == connected) {      
        set %i 1
        while (%i <= $chan(0)) {
          if (($ci($chan(%i)) >= $ncfg(cic-time)) && ($nohide($chan(%i)) != 1)) { if (($window($chan(%i)).state != hidden) && ($chan(%i) != $active)) window -h $chan(%i) }
          inc %i
        }
      }
      scon -r
      inc %ii    
    }
  }
}

alias modent {
  var %cmodes
  if (N isincs $chanmodes) var %cmodes = C
  if (C isincs $chanmodes) var %cmodes = %cmodes $+ N
  .timer 1 10 if ($nick(%jkanal,0) == 1) mode %jkanal +nt $+ %cmodes
}
alias n.blscanall {
  if ($status != connected) || ($chan(0) == 0) || ($ncfg(blacklist) != 1) return
  var %i = 1
  while (%i <= $chan(0)) {
    if (($me isop $chan(%i)) || ($me ishop $chan(%i))) && (($hget(nbs,blacklist_custom_channels) != 1) || ($istok($hget(nbs,blacklist_channels),$chan(%i),32))) { .timerbls. [ $+ [ $cid ] $+ ] . [ $+ [ $chan(%i) ] ] 1 [ %i ] n.blscan $chan(%i) }
    inc %i
  }
}
alias n.start.echo {
  echo $color(info) -s - $clr(normal,$strip($n.name $n.version)) $iif($insttime > 86400,installed for $clr(normal, $+ $dur($insttime,2))) using theme $clr(normal,$tname)
  echo $color(info) -s - $clr(normal,Ctrl+F1:) Commands $+ , $clr(normal,F2:) configuration
  if ($lines(scripts\txt\tips.txt) > 0) {
    echo -s $chr(160)
    echo -s - tip: $read(scripts\txt\tips.txt)
  }
  titleupdate
}
alias who {
  set %n.whosvar 1
  !who $1-
}
alias names {
  set %show.names 1
  !names $1-
}
alias n.getitunes {
  .comopen itunes iTunes.application
  if (!$comerr) {
    .echo -qg $com(itunes,PlayerState,3)
    if ($com(itunes).result == 1) {
      .echo -qg $com(itunes,CurrentTrack,3,dispatch* itrack)
      .echo -qg $com(itunes,CurrentStreamTitle,3)
      .echo -qg $com(itrack,Name,3)
      set %it.title $com(itrack).result
      .echo -qg $com(itrack,Artist,3)
      set %it.artist $com(itrack).result
      .echo -qg $com(itrack,Album,3)
      set %it.album $com(itrack).result
      .echo -qg $com(itrack,BitRate,3)
      set %it.bitrate $com(itrack).result
      .echo -qg $com(itrack,Duration,3)
      set %it.ttime $com(itrack).result
      .echo -qg $com(itunes,PlayerPosition,3)
      set %it.etime $com(itunes).result
      .echo -qg $com(itrack,KindAsString,3)
      set %it.type $com(itrack).result
    }
  }
  if ($com(itrack)) .comclose itrack
  if ($com(itunes)) .comclose itunes
}

alias n.alarm_action {
  if (%alarm.beep == 1) beep 10 100
  elseif ($isfile(%alarm.sound)) splay %alarm.sound
  echo $color(info) -st $npre Alarm finished $iif(%alarm.message == 1,$par($ncfg(alarm_message)))
  if (%alarm.message) n.ptext - $chr(1) Alarm $chr(1) $ncfg(alarm_message)
  if (%alarm.program.on == 1) run -p $ncfg(alarm_program)
}
alias n.highlight {
  if (!$1) return
  if ($ncfg(no_highlight) != off) && ($numtok($ncfg(no_highlight),44) > 0) {
    var %i = 1, %e = $numtok($ncfg(no_highlight),44)
    while (%i <= %e) {
      if ($gettok($ncfg(no_highlight),%i,44) iswm $address($nick,5)) return
      inc %i
    }
  }
  window -g2 #
  if ($hget(nbs,nickpip) == 1) && ((!%tmp.nbf) || (%tmp.nbf < 2)) {
    splay $qt($mircdirscripts\beep.wav)
    inc -u10 %tmp.nbf
  }
  if ($hget(nbs,nickwin) == 1) {
    if (!window(@highlights ( $+ $cid $+ )))  window -k0n @highlights ( $+ $cid $+ )
    var %echo = @highlights ( $+ $cid $+ )
  }
  else var %echo = -s
  echo $color(other) %echo _________________________________________________
  echo %echo $timestamp $replace($nick.style,<mode>,$cmode($nick,$chan,o),<nick>,$nick) $+  $replace($1-,$me, $+ $me $+ )
  echo %echo $kl(#) - $kl($date)
  echo $color(other) %echo ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  if ($hget(nbs,popup_nick) == 1) n.ptext # $chr(1) Highlighted in # $chr(1) $replace($nick.style,<mode>,$cmode($nick,$chan,o),<nick>,$nick) $+  $1-
}

alias dedll return $dll(scripts\dll\darkenginex.dll,$1,_)
alias getsys {
  if ($1) {
    .comopen sys WbemScripting.SWbemLocator
    if (!$comerr) {
      var %x = $com(sys,ConnectServer,3,dispatch* sys2), %x = $com(sys2,ExecQuery,3,bstr*,select $prop from $1,dispatch* sys3), %x = $comval(sys3,$iif($2,$2,1),$prop)
      if ($com(sys)) .comclose sys
      if ($com(sys2)) .comclose sys2
      if ($com(sys3)) .comclose sys3
      return %x
    }
  }
}
alias awaynet {
  var %i = 1, %awaytot 0
  while (%i <= $scon(0)) {
    if ($scon(%i).away) { inc %awaytot }
    inc %i
  }
  return %awaytot
}
alias perc return $round($calc(($1 / $2)*100),1) $+  %
alias dur { 
  if ($1) return $remove($duration($1,$iif(!$2,1,$2)),ks,k,ays,ay,rs,r,ins,in,ecs,ec) 
}
alias dur2 {  
  if ($1) {
    var %x = $duration($1,3)
    if ($gettok(%x,1,58) > 0) return %x
    else return $gettok(%x,2-,58)
  }
}
alias csip return $readini(scripts\qstat\cs_info.ini, cs, ip)
alias bfe {
  var %l = $len($1)
  while (%l) {
    var %c = $calc($asc($mid($1,%l,1)) - %l)
    if ($len(%c) < 2) var %c = 00 $+ %c
    elseif ($len(%c) < 3) var %c = 0 $+ %c
    var %r = %r $+ %c
    dec %l 1
  }
  return %r
}
alias n.input {
  set %n.input1 $1
  set %n.input2 $2
  set %n.input3 $3
  return $dialog(input,input,-4)
}
alias chankey {
  if ($chan($1).key) return $ifmatch
  elseif (%pw. [ $+ [ $1 ] ]) return $ifmatch
}
alias n.chanstats {
  if ($1) return Total $nick($1,0) nicks $par($+($iif($nick($1,0,o) > 0,$ifmatch ops),$iif($nick($1,0,h) > 0,$chr(44) $ifmatch halfops),$iif($nick($1,0,v) > 0,$chr(44) $ifmatch voices),$iif($nick($1,0,r) > 0,$chr(44) $ifmatch $iif($len($prefix) > 3,other,regular))))
}
alias n.par if ($1) return ( $+ $1- $+ )
alias insttime return $right($calc($ncfg(installtime) - $ctime),-1)
alias cm if ($1 isnum 5-14) return $replacecs($1,5,t,6,n,7,i,8,m,9,c,10,s,11,r,12,N,13,C,14,p)
alias cmode {
  if (!$2) return
  if ($3 == o) return $left($removecs($nick($2,$1).pnick,$1),1)
  elseif ($hget(nbs,modeprefix) == 1) {
    if ($3) return $left($removecs($nick($2,$1).pnick,$1),1)
    else return $left($removecs($nick($2,$1).pnick,$1),1) $+ $1
  }
  elseif (!$3) return $1
}
alias avgpd { 
  if ($1) {
    if ($insttime < 86401) return $1
    else return $round($calc($1 / ($insttime /86400)),1)
  }
}
alias nohide {
  if (!$1) return
  if ($istok($ncfg(nohide),$1,32)) return 1
}
alias c44 return $chr(44)
alias cit return $+(",$1-,")
alias n.qnet if ($right($server,13) == .quakenet.org) && ($network == quakenet) return $true
alias n.unet if ($right($server,13) == .undernet.org) && ($network == undernet) return $true
alias n.maxbans if (%maxbans. [ $+ [ $cid ] ]) return $ifmatch | else return ?
alias n.topiclen if (%topiclen. [ $+ [ $cid ] ]) return $ifmatch | else return ?

alias cf1 cmds
alias cf2 if (%tmp.dnsresult) clipboard $ifmatch
alias cf5 {
  if (%rejointimer) { 
    .timer [ $+ [ %rejointimer ] ] off
    echo $color(info) -atg $pre rejoin aborted $par(%rejointimer)
  }
}
alias cf12 scon -a clearall | scon -at1 topicall
alias sf1 dll scripts\dll\winamp.dll prevsong
alias sf2 dll scripts\dll\winamp.dll playsong
alias sf3 dll scripts\dll\winamp.dll playpause
alias sf4 dll scripts\dll\winamp.dll stopsong
alias sf5 dll scripts\dll\winamp.dll nextsong

alias n.fkey {
  if (!$1) return
  if ($ncfg(fkey_ [ $+ [ $1 ] ])) && ($ifmatch != �none�) $eval($ifmatch,2)
  else echo $color(other) -atg $pre Key $1 is unbound (use /fkeys to bind)
}
alias fkey n.fkey $1-
alias o {
  if ($n.qnet) {
    if (Q ison $active) { msg Q op $active }
    elseif (L ison $active) { msg L op $active } 
  }
}
alias g {
  if ($1) n.url http://www.google.com/search?q= $+ $replace($1-,$chr(32),$chr(37) $+ 20)
  else n.url http://www.google.com/
}
alias imdb {
  if ($1) n.url http://www.imdb.com/Find?for= $+ $replace($1-,$chr(32),$chr(37) $+ 20) $+ &select=All 
  else n.url http://www.imdb.com/
}
alias wiki {
  if ($1) n.url http://en.wikipedia.org/wiki/ $+ $replace($1-,$chr(32),$chr(37) $+ 20)
  else n.url http://en.wikipedia.org/
}
alias thott {
  if ($1) n.url http://www.thottbot.com/?s= $+ $replace($1-,$chr(32),$chr(37) $+ 20)
  else n.url http://www.thottbot.com/
}
alias allak {
  if ($1) n.url http://wow.allakhazam.com/search.html?q= $+ $replace($1-,$chr(32),$chr(37) $+ 20)
  else n.url http://wow.allakhazam.com/
}
alias wh {
  if ($1) n.url http://www.wowhead.com/?search= $+ $replace($1-,$chr(32),$chr(37) $+ 20)
  else n.url http://www.wowhead.com/
}

alias slap {
  if ($read(config\slaps.txt)) me $replace($read(config\slaps.txt),[nick],$$1)
  else me slaps $$1 around a bit with a large trout
}


; Do i need this stuff ?
alias wii !whois $$1 $1
alias csinfo.id { return name: $readini(scripts\qstat\cs_info.ini, cs, namn) $chr(160) $chr(160) players: $readini(scripts\qstat\cs_info.ini, cs, spelare) $chr(160) $chr(160) map: $readini(scripts\qstat\cs_info.ini, cs, map) $chr(160) $chr(160) ping: $readini(scripts\qstat\cs_info.ini, cs, ping) $chr(160) $chr(160) ip: $readini(scripts\qstat\cs_info.ini, cs, ip) }

alias wah say 8,9WAAA8,9A9,8AAAA8,9AAA9,8AAAAA8,9AAAA9,8AAAAA8,9AAAA9,8AAAAAAA8,9AAAAA9,8AAAA8,9AAAA9,8AAAAA8,9AAAA9,8AAAA8,9AAA9,8AAAA8,9AA9,8AAAA8,9AAAHH9,8HHHH8,9!!!!!!!!!!
alias :p say :PpPPppPPpPPppPppPPpPPpPPppPppPPpPPpPPppPppPPpPPpPPppPppPPpPPpPPppPppPPpPPpPPppPppPPpPPpPPppP
alias wee say 8,9WEEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9EEEE9,8EEEE8,9!!!!!!!!!!
alias bu say brain usage: 1% [4|||||||||]
alias ren {
  say 1,1@@@@@@@@0,0@1,1@@0,0@1,1@
  say 1,1@@@@@@@@0,0@1,1@@0,0@1,1@
  say 1,1@@@@@@@@@0,0@@0,01,1@@
  say 1,1@@@@@@@@0,0@@@1,1@@
  say 1,1@@@@@@@@@0,0@@1,1@@
  say 1,1@@0,0@@@@@@@@@1,1@@
  say 1,1@0,0@@@@@@@@@@1,1@@
  say 1,1@0,0@@@@@@@@@@1,1@@
  say 1,1@0,0@1,1@0,0@1,1@@@@0,0@1,1@0,0@1,1@@
  say 1,1@0,0@1,1@0,0@1,1@@@@0,0@1,1@0,0@1,1@@
  say 1,1@0,0@1,1@0,0@1,1@@@@0,0@1,1@0,0@1,1@@
}
