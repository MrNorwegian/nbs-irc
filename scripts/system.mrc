on *:start:{
  if ($version < 7) {
    if ($n.input(Error: your mIRC version is $version $+ $c44 nbs-irc needs mIRC 7 or higher. $crlf $crlf $+ Would you like to go the mIRC download site?,y/n)) n.url http://www.mirc.com/get.html
    exit
  }
  if ($uptime(mirc) < 10000) n.checkfiles
  dll scripts\dll\dcx.dll WindowProps $window(-2).hwnd +i 0 nbs.ico
  .echo -qg $findfile(scripts\temp\topic\,*,0,.remove $1-)
  .echo -qg $findfile(scripts\temp\,paste_*,0,.remove $1-)
  .echo -qg $findfile(scripts\temp\,url_*,0,.remove $1-)
  hmake temp 5
  n.checkini
  n.reloadconfig
  n.updateevents
  if ($ncfg(exttb) == 1) n.toolbar
  background -ux
  if ($dialog(strt)) did -a strt 1 3
  if ($os == 2k) || ($os == 98) || ($os == 95) || ($os == nt) tray -i17 scripts\dll\i.dll
  else tray -i18 scripts\dll\i.dll
  .timertitlebar -i 0 10 titleupdate
  .timestamp -f $n.timestamp
  .disable #röstning
  hmake prot 10
  hload -i prot config\config.ini protections
  if ($dialog(strt)) did -a strt 1 7
  if (!$tname) {
    echo $color(info) -a - No theme loaded, loading default theme.
    echo -a 
    theme cold
  }
  cnicks
  unset %txtload %wa.in %tedit* %n.connecting* %lag.* %temp %tmp* %ban* %oldnick.* %sbnc.* %psybnc.* %maxbans.* %topiclen.* %dns2nick* %addedit
  ;if ($exists(scripts\r-own.nbs)) .load -rs1 scripts\r-own.nbs
  if ($ncfg(updated) != 1) {
    if ($script(misc.ini)) .unload -rs scripts\misc.ini
    if ($exists(scripts\misc.ini)) .remove scripts\misc.ini
    w_ncfg updated 1
  }
  if ($exists(fix.ini)) .timer 1 1 .remove fix.ini
  if (!$insttime) {
    dlg 1st
    set %nbs_vcheck 10
  }
  n.start.echo
  autoconnect_connectnow
}
on *:LOGON:*:set %n.connecting. [ $+ [ $cid ] ] 1
on *:CONNECT:{
  if ($n.qnet) {
    if ($ncfg(autoauth) == 1) && ($ncfg(authnick)) && ($ncfg(authpass)) auth
    if ($ncfg(mode+x) == 1) mode $me +x
  }
  elseif ($n.unet) {
    if ($ncfg(undernet_autoauth) == 1) && ($ncfg(undernet_authnick)) && ($ncfg(undernet_authpass)) auth
    if ($ncfg(undernet_mode+x) == 1) mode $me +x
  }
  if ($status == connected) echo -se $npre $kl:(Network) $network $kl:(Server) $server $par($port)
  titleupdate
  if ($ncfg(autojoin) == 1) && ($ncfg(autojoin_disable_ $+ $network) != 1) .timer 1 3 aj
  cl_showall
  if (!%n.quakenet) && (!$authedited) && ($n.qnet) {
    .timer 1 1 if ($n.input(Do you want to configure your QuakeNet settings now?,y/n)) quakenet
    set %n.quakenet 1
  }
  if (!%n.undernet) && (!$ncfg(undernet_authnick)) && ($n.unet) {
    .timer 1 1 if ($n.input(Do you want to configure your UnderNet settings now?,y/n)) undernet
    set %n.undernet 1
  }
  .timer 1 20 unset %n.connecting. [ $+ [ $cid ] ]
  hadd -mu59 temp clag.block 1
  if ($hget(nbs,popup_discon) == 1) n.ptext - $chr(1) $network $+ : Connected $chr(1) $npre Connected to $+($server,$clr(info,:),$port)
  if ($cid == 1) n.versioncheck
}
on *:DISCONNECT:{
  cuptime
  hdel -w nbs ci. [ $+ [ $cid ] $+ ] .*
  .timerwho. [ $+ [ $cid ] $+ ] .* off
  cl_showall
  titleupdate
  if ($hget(netsplit)) hdel -w netsplit $cid $+ .*
  hadd -mu600 temp disconnect. [ $+ [ $cid ] ] $me $address($me,1)
  if ($hget(nbs,popup_discon) == 1) n.ptext - $chr(1) $network $+ : disconnected $chr(1) $npre Disconnected from $+($server,$clr(info,:),$port)
}
on ^*:QUIT:{
  haltdef  
  if ($query($nick)) echo $color(quit) -t $nick $npre Quit $par($1-)
  var %i = 1
  while (%i <= $comchan($nick,0)) {
    if (!$ehide(quits,$comchan($nick,%i))) {
      if (!$3) && (quit !isin $1) && (. isin $1) && (. isin $2) {
        if (!$hget(netsplit)) hmake netsplit 30
        hadd -u1800 netsplit [ [ $cid ] $+ ] . [ $+ [ $nick ] ] 1
        hinc -m temp netsplit.tq. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ]
        if ($hget(temp,netsplit.quit.f. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ]) != 1) {
          if ($len($hget(temp,netsplit.quit. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ]) $nick) < 500) hadd -m temp netsplit.quit. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ] $hget(temp,netsplit.quit. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ]) $nick $+ $chr(44)
          else hadd temp netsplit.quit.f. [ $+ [ $cid ] $+ ] . [ $+ [ $comchan($nick,%i) ] ] 1
        }
        .timersnetsplitquit 1 1 n.netsplitquit $1-
      }
      else n.echo quit -ti4 $comchan($nick,%i) Quit: $cmode($nick,$comchan($nick,%i)) $par($address) $par($1-)
    }
    inc %i
  }
  if ($hget(nbs,reclaim_nick) == 1) {
    if ($address($me,1) == $gettok($hget(temp,disconnect. [ $+ [ $cid ] ]),2,32)) && ($nick == $gettok($hget(temp,disconnect. [ $+ [ $cid ] ]),1,32)) nick $nick
  }
}
on *:EXIT:{
  scon -a clearall
  close -@
  cuptime
}
on *:INPUT:*:{
  if ($active === Status Window) || ($left($1,1) == /) && (!$ctrlenter) return
  if ($left($target,1) == @) && ($window($target)) return
  if ($target ischan) {
    hadd -m temp ci. [ $+ [ $cid ] $+ ] . [ $+ [ $chan ] ] $ticks
    if ($window($chan).state == hidden) window -w $chan 
  }
  if ($inpaste) && ($left($target,1) != =) {
    if ($cb(0) > 1) {
      set %paste.target $target
      if (!%tmp.paste) dlg paste
      set -u1 %tmp.paste 1
    }
    else editbox -a $1-
  }
  elseif (!$halted) msg $target $1-
  haltdef
}
on *:INPUT:@psyBNC (*):{
  if (($left($1,1) == /) && (!$ctrlenter)) { return }  
  .!msg -psybnc $1-
  echo $color(notice) -at - $1-
}
on *:INPUT:@sBNC (*):{
  if (($left($1,1) == /) && (!$ctrlenter)) { return }  
  .!msg -sBNC $1-
  echo $color(notice) -at - $1-
}

on ^*:JOIN:#:{
  haltdef
  if ($nick == $me) {
    hadd -m temp ci. [ $+ [ $cid ] $+ ] . [ $+ [ $chan ] ] $ticks 
    .timer 1 9 topicchan #
    set -u7 % [ $+ [ # ] $+ ] .disabled 1
    return
  }
  if ($query($nick)) && ($comchan($nick,0) == 1) { 
    if ($ncfg(query_show_online) == 1) echo $color(join) -t $nick $npre Online $par(joined $chan)
  }
  if ($hget(nbs,blacklist) == 1) {
    if ($hget(nbs,blacklist_custom_channels) != 1) || ($istok($hget(nbs,blacklist_channels),$chan,32)) {
      if ($me isop #) || ($me ishop #) {
        if ($n.bluser($address($nick,5)) == 1) !raw -q mode # +b $gettok(%bltmp,1,44) $+ $crlf $+ KICK # $nick : $+ $gettok(%bltmp,2-,44)
      }
    }
  }
  if (!$ehide(joins,#)) {
    if ($hget(netsplit, [ [ $cid ] $+ ] . [ $+ [ $nick ] ])) {
      hinc -m temp netsplit.tj. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ]
      if ($hget(temp,netsplit.join.f. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ]) != 1) {
        if ($len($hget(temp,netsplit.join. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ]) $nick) < 500) hadd -m temp netsplit.join. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ] $hget(temp,netsplit.join. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ]) $nick $+ $chr(44)
        else hadd temp netsplit.join.f. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ] 1
      }
      .timer 1 4 hdel netsplit [ [ $cid ] $+ ] . [ $+ [ $nick ] ]
    }
    if ($hget(temp,netsplit.tj. [ $+ [ $cid ] $+ ] . [ $+ [ # ] ])) .timernetsplitjoin [ $+ [ # ] ] 1 1 n.netsplitjoin #
    else {
      if ($ialchan($wildsite,#,0) > 1) {
        if ($ialchan($wildsite,#,0) < 9) {
          var %i = 1, %x
          while (%i <= $ialchan($wildsite,#,0)) {
            if ($nick != $ialchan($wildsite,#,%i).nick) var %x = %x $cmode($ialchan($wildsite,#,%i).nick,#) $+ $chr(44)
            inc %i
          }
          var %jklon = $par(clones with: $left(%x,-1) $iif(%i > 3,( $+ $calc(%i -2) $+ ))) 
        }
        else var %jklon = $par($calc($ialchan($wildsite,#,0) -1) clones)
      }
      echo $color(join) -ti4 $chan $npre Join: $nick $par($address) %jklon
    }
  }
}
on ^*:PART:#:{
  haltdef
  if ($nick == $me) {
    hdel nbs ci. [ $+ [ $cid ] $+ ] . [ $+ [ $chan ] ]
    n.echo join -t # parting channel $par($1-)
    echo #   
    return
  }
  if (!$ehide(parts,#)) echo $color(part) -ti4 $chan $npre Part: $cmode($nick,#) $par($address) $par($1-)
}
on *:DNS:{
  haltdef  
  if (!$raddress) {
    echo $color(info) -atgq $npre Unable to resolve $n.quote($dns(0).ip) 
    set %tmp.dnsresult $dns(0).ip
  }
  elseif ($dns(0) > 1) {
    var %i = 1
    set %tmp.dnsresult $dns(%i)
    while (%i <= $dns(0)) {
      echo $color(info) -tagq $npre Result %i $+ : $dns(%i).ip  $+ $par($dns(%i))
      inc %i
    }
  }
  else {
    set %tmp.dnsresult $raddress
    echo $color(info) -tagq $npre Result: $raddress  $+ $par(  $iif($naddress == $raddress,$dns(0).ip,$naddress)) $+ , Ctrl+F2: copy to clipboard 
  }
  if (%tmp.i2n == 1) {
    host2nick %tmp.dnsresult
    unset %tmp.i2n
  }
}

on ^*:KICK:#:{
  haltdef
  echo $color(kick) -ti4 $chan $npre  $+ $cmode($knick,#) was 4kicked by $nick $par($1-)
  if ($knick == $me) { 
    echo $color(info) -ste $npre kicked from $chan by $cmode($nick,#) $par($address) $par($1-) $iif($ncfg(autorejoin) == 1 && $nick != $me,rejoining in $ncfg(ar_time) $+ s $+ $chr(44) $par(Cancel with Ctrl+F5))
    if ($active != $chan) && ($active != Status Window) echo $color(mode) -atg $npre info: kicked from $chan by $nick $par($1-) $iif($cid != $activecid,$par($network))    
    if ($ncfg(autorejoin) == 1) && ($ncfg(ar_time) isnum) && ($nick != $me) .timer [ $+ [ # ] ] 1 [ $ncfg(ar_time) ] n.rejoin # $chankey(#)
    set -u [ $+ [ $ncfg(ar_time) ] ] %rejointimer #
    if ($hget(nbs,popup_other) == 1) n.ptext - $chr(1) Kicked $chr(1) $npre kicked from $chan by $cmode($nick,#) $par($1-)
    if ($hget(nbs,whois_on_kick) == 1) {
      set -u10 %whois.window.passive 1
      whois $nick
    }      
  }
}

on ^*:BAN:#:{
  haltdef 
  if ($me isop #) && ($hget(nbs,banskydd) == 1) && ($banmask iswm $address($me,5)) && ($nick != $me) {
    !raw -q mode # -ob $nick $banmask $+ $crlf $+ KICK # $nick : $+ $hget(nbs,bsmed)
  } 
}

on ^*:TOPIC:#:{ 
  if ($1) {
    echo $color(topic) -ti4 $chan - $clr(info,$nick changes topic to:) $1-
    if (!$isdir($scriptdirtemp\topic)) mkdir $scriptdirtemp\topic
    .write -il1 $+(",$scriptdirtemp\topic\,$md5(#),â,$cid,") $1-
  }
  else echo $color(topic) -ti4 $chan $npre Topic removed by $nick
  haltdef
} 
on ^*:INVITE:*:{
  haltdef
  if ($n.qnet) && ($ncfg(quakenet_bot_autojoin) == 1) && (($nick == q) || ($nick == l)) join $iif(autojoin_minimize == 1,-n) $chan
  elseif ($n.unet) && ($ncfg(undernet_bot_autojoin) == 1) && ($nick == x) join $iif(autojoin_minimize == 1,-n) $chan
  n.echo notice -atm $nick $par($address) invited you to $chan
  if ($hget(nbs,popup_other) == 1) n.ptext - $chr(1) Invite $chr(1) $bpre $nick invited you to $chan
}
on ^*:NICK:{
  haltdef
  if ($nick === $newnick) return
  if ($nick == $me) echo $color(nick) -st $npre Nick changed to: $newnick
  elseif ($query($newnick)) echo $color(nick) -t $newnick $npre $clr(highlight,$nick) is now known as $clr(highlight,$newnick)
  var %i = 1
  while (%i <= $comchan($newnick,0)) {
    if (!$ehide(nicks,$comchan($newnick,%i))) echo $color(nick) -t $comchan($newnick,%i) $npre $cmode($newnick,$comchan($newnick,%i),_) $+ $clr(highlight,$nick) is now known as $cmode($newnick,$comchan($newnick,%i),_) $+ $clr(highlight,$newnick)
    inc %i
  }
}

on ^*:CHAT:*:{ 
  if ($1 == ACTION) { echo $color(action) -t =$nick * $nick $left($2-,-1) }
  else echo $color(normal) -mtbf =$nick $replace($nick.style,<mode>,,<nick>,$nick) $+  $1-
  if ($ncfg(privpip) == 1) && ($ncfg(query_sound_onopen) != 1) && (!%tmp.query.sound.block) var %x = 1
  if ($active != =$nick) {
    if (%x == 1) $ncfg(privljud)
    set -u3 %tmp.query.sound.block 1
  }
  elseif (!$appactive) {
    if (%x == 1) $ncfg(privljud)
    set -u3 %tmp.query.sound.block 1
  }
  haltdef 
}
on ^*:TEXT:*:#:{
  if ($halted) return
  haltdef

  ; Add support for proper playback buffer timestamps which use server-time or znc.in/server-time[-iso] 
  var %timestamp = $iif($msgstamp, $msgstamp, $ctime)

  if ($hget(nbs,win_ashow) == 1) window -w $chan
  hadd -m temp ci. [ $+ [ $cid ] $+ ] . [ $+ [ $chan ] ] $ticks
  hadd -m temp text $color(normal) -mlbfi4 # $asctime(%timestamp, $n.timestamp) $replace($nick.style,<mode>,$cmode($nick,$chan,o),<nick>,$nick) $+  $1-
  ;if ($me isin $1-) {
  if ($wildtok($1-,$me $+ *,0,32) != 0) { 
    if ($hget(nbs,nickbar) == 1) echo $color(normal) -mlbfi4 # $asctime(%timestamp, $n.timestamp) $replace($nick.style,<mode>,$cmode($nick,$chan,o),<nick>, $+ $hget(nbs,highlight_nick_color) $+ $nick $+ ) $+  $1-
    else echo $hget(temp,text)
    n.highlight $1-
    if ($away && !%n.away. [ $+ [ $nick ] ]) && ($ncfg(awaynotice) != 1) {
      .notice $nick I'm away: $awaymsg
      set -u99999 %n.away. $+ $nick 1
    }
  }
  else echo $hget(temp,text)
  if ($hget(nbs,mp3serv) == 1) && ($hget(nbs,mp3getcmd) isin $1-) n.servemp3 $nick
  if ($chr(1) $+ # isin $hget(prot,chans)) && ($me isop #) || ($me ishop #) {
    if (($nick isop #) || ($nick ishop #)) && (!$hget(prot,$+(#,punishops))) return
    if ($hget(prot,$+(#,caps)) == 1) n.capss # $nick $1-
    if ($hget(prot,$+(#,repeat)) == 1) n.repeats # $nick $1-
    if ($hget(prot,$+(#,flood)) == 1) n.floods # $nick $1-
    if ($hget(prot,$+(#,advertising)) == 1) n.spams # $nick $1-
  }
}
on ^*:action:*:#:{ 
  if ($me isin $1-) {
    if ($ncfg(nickpip) == 1) && ((!%tmp.nbf) || (%tmp.nbf < 2)) {
      splay $qt($mircdirscripts\beep.wav)
      inc -u10 %tmp.nbf
    }
    if ($hget(nbs,popup_nick) == 1) n.ptext # $chr(1) Highlighted in # $chr(1) * $cmode($nick,$chan) $eval($strip($1-),1)
  }
  if ($chr(1) $+ # isin $hget(prot,chans)) && ($me isop #) || ($me ishop #) {
    if (($nick isop #) || ($nick ishop #)) && (!$hget(prot,$+(#,punishops))) return
    if ($hget(prot,$+(#,caps)) == 1) n.capss # $nick $1-
    if ($hget(prot,$+(#,repeat)) == 1) n.repeats # $nick $1-
    if ($hget(prot,$+(#,flood)) == 1) n.floods # $nick $1-
    if ($hget(prot,$+(#,advertising)) == 1) n.spams # $nick $1-
  }
}
on ^*:TEXT:*:?:{
  if ($halted) return
  haltdef

  ; Add support for proper playback buffer timestamps which use server-time or znc.in/server-time[-iso] 
  var %timestamp = $iif($msgstamp, $msgstamp, $ctime)

  if ($nick == -psyBNC) {  
    if ($window(-psyBNC).state != hidden) window -h -psyBNC    
    n.bnc psyBNC
    echo -tmi4 $bncwin(psyBNC,$cid) - $1- 
  }
  elseif ($nick == -sBNC) {  
    if ($window(-sBNC).state != hidden) window -h -sBNC    
    n.bnc sBNC
    echo -tmi4 $bncwin(sBNC,$cid) - $1-
    if ($ncfg(sbnc_autoread) == 1) {
      if ($1-4 == You have new messages.) {
        set %sbnc. [ $+ [ $cid ] $+ ] .msglog 1
        .!msg -sbnc read
      }
      elseif ($1-4 == End of LOG. Use) {
        unset %sbnc. [ $+ [ $cid ] $+ ] .* 
        .!msg -sbnc erase
      }
      elseif (%sbnc. [ $+ [ $cid ] $+ ] .msglog == 1) && ($numtok($1-,58) > 2) {
        var %nick = $gettok($gettok($1-,2,58),1,32)
        if (@ !isin %nick) && (%nick !isnum) {
          if (!$window(%nick)) query %nick
          set %sbnc. [ $+ [ $cid ] $+ ] .host1. [ $+ [ %nick ] ] $mid($gettok($gettok($1-,2,58),2,32),2,-1)
          if (%sbnc. [ $+ [ $cid ] $+ ] .host1. [ $+ [ %nick ] ] != %sbnc. [ $+ [ $cid ] $+ ] .host2. [ $+ [ %nick ] ]) echo $color(info) -ti4 %nick $pre Offline messages from $gettok($gettok($1-,2,58),1,32) $par($mid($gettok($gettok($1-,2,58),2,32),2,-1)) $+ :
          set %sbnc. [ $+ [ $cid ] $+ ] .host2. [ $+ [ %nick ] ] %sbnc. [ $+ [ $cid ] $+ ] .host1. [ $+ [ %nick ] ]
          if ($gettok($gettok($1-,3,58),1,32) == ++c) {
            var %cryptmsg = $gettok($gettok($1-,3-,58),2-,32), %crypthost = *!* $+ $remove($mid($gettok($gettok($1-,2,58),2,32),2,-1),~)
            var %msg = (c) $n.crypt(%cryptmsg,d,%nick,%crypthost)
          }
          else var %msg = $gettok($1-,3-,58)
          echo $color(normal) -mi4 %nick $gettok($1-,1,58) $event.msg(%nick,%nick,%msg)
        } 
      }
    }
  }
  else {
    echo $color(normal) -mlbfi4 $nick $asctime(%timestamp, $n.timestamp) $replace($nick.style,<mode>,,<nick>,$nick) $+  $1- 
    if ($hget(nbs,mp3serv) == 1) && ($hget(nbs,mp3getcmd) isin $1-) n.servemp3 $nick
    if ($hget(nbs,privpip) == 1) && ($hget(nbs,query_sound_onopen) != 1) && (!%tmp.query.sound.block) var %x = 1
    if (!$appactive) fasttitle $nick $+ : $eval($1-,1) 
    if ($active != $nick) {
      if (%x == 1) $hget(nbs,privljud)
      set -u3 %tmp.query.sound.block 1
    }
    elseif (!$appactive) {
      if (%x == 1) $ncfg(privljud)
      set -u3 %tmp.query.sound.block 1
    }
    if ($hget(nbs,popup_query) == 1) && ($hget(nbs,popup_query_always) == 1) {
      if ($appactive) && ($active != $nick) var %x = 1
      elseif (!$appactive) var %x = 1
      if (%x == 1) n.ptext $nick $chr(1) msg from $nick $chr(1) $replace($nick.style,<mode>,$null,<nick>,$nick)  $+ $eval($1-,1)
    }
  }
}
on ^*:snotice:*:{
  haltdef

  var %timestamp = $iif($msgstamp, $msgstamp, $ctime)

  if ($nick == irc.psychoid.net) { 
    n.bnc psyBNC
    echo -tm $bncwin(psyBNC,$cid) - $1-
  }
  elseif ($nick == shroudbnc.info) set %sbnc. [ $+ [ $cid ] ] 1
  else echo $color(notice) -sq $asctime(%timestamp, $n.timestamp) $npre $par($nick) $1-
}

on ^*:notice:*:*:{
  haltdef

  var %timestamp = $iif($msgstamp, $msgstamp, $ctime)

  if ($target ischan) {
    echo $color(notice) -gm $target $asctime(%timestamp, $n.timestamp) $pre $par($+($cmode($nick,$target),:,$target)) $1-
    if ($chr(1) $+ # isin $hget(prot,chans)) && ($me isop $target) || ($me ishop $target) {
      if (($nick isop #) || ($nick ishop #)) && (!$hget(prot,$+(#,punishops))) return
      if ($hget(prot,$+(#,caps)) == 1) n.capss $target $nick $1-
      if ($hget(prot,$+(#,repeat)) == 1) n.repeats $target $nick $1-
      if ($hget(prot,$+(#,flood)) == 1) n.floods $target $nick $1-
      if ($hget(prot,$+(#,advertising)) == 1) n.spams $target $nick $1-
    }
  }
  elseif ($address === psyBNC@lam3rz.de) && ($nick === Welcome) || ($nick === Wilkommen) set %psybnc. [ $+ [ $cid ] ] 1
  elseif ($nick == -psyBNC) {
    n.bnc psyBNC
    echo -tmi4 $bncwin(psybnc,$cid) - $1-
  }
  elseif ($nick == -sBNC) {  
    n.bnc sBNC
    echo -tmi4 $bncwin(sBNC,$cid) - $1-
  }
  elseif ($nick == $me) && ($1 == lag437289) { 
    set %lag. $+ $cid $calc($ticks - $2) 
    if (%lc == 1) n.echo other -atg latency to $server $+ : %lag. [ $+ [ $cid ] ] ms
    unset %lc
    titleupdate
  }
  elseif ($n.qnet) && ($len($nick) == 1) {
    if ($dialog(botctrl)) && (%bc.getmode) {
      if ($1-7 == chanlev is only available to authed users.) {
        did -ar botctrl 99 You are not authed 
        did -b botctrl 98,8 
      }
      if ($1-2 == Can't find) || ($3- ==  is not authed.) {
        did -ar botctrl 99 (not authed) 
        did -b botctrl 98,8 
      }
      elseif ($1-6 == user %bc.nick is not known on) did -ar botctrl 99 (none)
      elseif (flags for %bc.nick on isin $1-) did -ar botctrl 99 $6
      elseif (!$3) && ($2) did -ar botctrl 99 + $+ $2
      did -c botctrl 99 1
    }
    elseif ($1 == CHALLENGE) && ($nick === Q) {
      if (LEGACY-MD5 isin $3-) {
        var %k = $calc($len($ncfg(authpass)) +1), %i = 1
        while (%k > 1) {
          var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($ncfg(authpass),%k,3) + %i))
          inc %i 1
        }
        n.echo notice -agqt received key, sending auth.
        .msg q@cserve.quakenet.org challengeauth $ncfg(authnick) $md5($left(%r,10) $2) LEGACY-MD5
      }
      else n.echo info -atg Error: LEGACY-MD5 seems to be removed, disable challengeauth to auth.
    }
    elseif ($mid($1,2,-1) ischan) n.echo notice -t $mid($1,2,-1) $kl($nick) $1- 
    else n.echo notice -atgi4 $kl:($nick) $1-
  }
  elseif ($n.unet) && ($nick == x) {
    if ($mid($1,2,-1) ischan) n.echo notice -t $mid($1,2,-1) $kl($nick) $1- 
    else n.echo notice -agi4 $asctime(%timestamp, $n.timestamp) $npre $kl:($nick) $1-
  }
  elseif ($nick === ChanServ) && ($mid($1,2,-1) ischan) n.echo notice -t $mid($1,2,-1) $kl($nick) $1-
  elseif ($1-2 === DCC Send) && ($3) {
    n.echo notice -sei4 $asctime(%timestamp, $n.timestamp) $npre $kl:(DCC Send from $nick) $deltok($3-,-1,32) $par($mid($gettok($3-,-1,32),2,-1))
  }
  else {
    n.echo notice -ami4 $asctime(%timestamp, $n.timestamp) $npre $kl:(notice from $nick) $1-
  }
  if ($nick === NickServ) && ($ncfg(nickserv_on) == 1) {
    if (nickname is registered isin $1-) && ($exists(config\nickserv- $+ $network $+ .txt)) {
      var %a = $read(config\nickserv- $+ $network $+ .txt)
      if ($me == $gettok(%a,1,44)) {
        var %k = $calc($len($gettok(%a,2-,44)) +1), %i = 1
        while (%k > 1) {
          var %k = $calc(%k -3), %r = %r $+ $chr($calc($mid($gettok(%a,2-,44),%k,3) + %i))
          inc %i 1
        }
        $ncfg(nickserv_prefix) %r
      }
    }
    elseif (ghost with your nick has been killed isin $1-) { nick %tmp.ghost }
  }
}
on *:OPEN:?:*:{
  if ($halted) return
  if ($nick == -psyBNC) n.bnc psyBNC
  elseif ($nick == -sBNC) n.bnc sBNC
  else {
    n.query.stats $nick $address
    if ($ncfg(privpip) == 1) && ($ncfg(query_sound_onopen == 1)) $ncfg(privljud)
    if ($n.bluser($fulladdress)) echo $color(info) -t $nick $npre User is blacklisted $par($gettok(%bltmp,2-,44)))
    if ($hget(nbs,popup_query) == 1) && ($ncfg(popup_query_always) != 1) n.ptext $nick $chr(1) msg from $nick $chr(1) $replace($nick.style,<mode>,$null,<nick>,$nick)  $+ $eval($1-,1)
  }
}
on *:ACTIVE:*:if ($activecid != $lactivecid) titleupdate
on *:APPACTIVE:titleupdate
on ^*:CLOSE:@psyBNC (*):if ($window(-psybnc)) close -m -psyBNC
on ^*:CLOSE:@sBNC (*):if ($window(-sbnc)) close -m -sBNC

on ^*:RAWMODE:#:{
  if ($halted) { return }
  haltdef
  if ($1 == +b) || ($1 == -o+b) { 
    if ($me isop #) || ($me ishop #) {
      var %o = 1
      set -u900 %banmode -b | set -u900 %banchan # | set -u900 %banmask $iif($1 == -o+b,$3,$2)
    }
    echo $color(mode) -ti4 # $npre $+  $nick $par($replace($1,+b,4+b)) $2- $iif(%o == 1,$par(F6: unban))
  }
  elseif ($1 == -b) { 
    if ($me isop #) || ($me ishop #) {
      var %o = 1
      set -u900 %banmode +b | set -u900 %banchan # | set -u900 %banmask $2
    }
    echo $color(mode) -ti4 # $npre $+  $nick $par(4 $+ $1) $2- $iif(%o == 1,$par(F6: ban))
  }
  else {
    ; Disabled $iif, dunno why this stopped working after "The big move update"
    ; $iif($hget(netsplit, [ [ $cid ] $+ ] . [ $+ [ $2 ] ]),.timer -m 1 1900 
    echo $color(mode) -ti4 # $npre $+  $nick $par($1) $iif($2,$2-,#)
  }
  if ($me isin $2) && ($hget(nbs,popup_other) == 1) {
    n.ptext # $chr(1) Channel mode: # $chr(1) $npre $+  $nick $par($1) $replace($2-,$me, $+ $me $+ ) $iif($cid != $activecid,$par($network))
  }
}
on ^*:DEOP:#:{
  if ($opnick == $me) {
    if ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: -o in $chan by $nick $iif($cid != $activecid,$par($network))
  }
}
on ^*:OP:#:{
  if ($opnick == $me) {
    if ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: +o in $chan by $nick $iif($cid != $activecid,$par($network))
    if ($hget(nbs,blacklist) == 1) .timer 1 1 n.blscan #
    .timer 1 10 n.checkkey #
  }
}
on ^*:SERVEROP:#:if ($opnick == $me) && ($hget(nbs,blacklist) == 1) .timer 1 2 n.blscan #
on ^*:VOICE:#:{
  if ($vnick == $me) && ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: +v in $chan by $nick $iif($cid != $activecid,$par($network))
}
on ^*:DEVOICE:#:{
  if ($vnick == $me) && ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: -v in $chan by $nick $iif($cid != $activecid,$par($network))
}
on ^*:HELP:#:{
  if ($hnick == $me) {
    if ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: +h in $chan by $nick $iif($cid != $activecid,$par($network))
    if ($hget(nbs,blacklist) == 1) n.blscan #  
  }
}
on ^*:DEHELP:#:{
  if ($hnick == $me) {
    if ($active != $chan) && (!%n.connecting. [ $+ [ $cid ] ]) echo $color(mode) -atg $npre $+  info: -h in $chan by $nick $iif($cid != $activecid,$par($network)) 
  }
}
on *:CTCPREPLY:*:{
  n.echo ctcp -at $kl:(CTCP $1 reply from $nick) $iif($1 == ping,reply took $calc(($ticks - %ctcp.ping.ticks)/1000) $+ s,$2-)
  unset %ctcp.ping.ticks
  haltdef
}
ctcp ^*:*:*:{
  if ($1 == dcc) {
    if ($hget(nbs,popup_dcc) == 1) n.ptext - $chr(1) DCC from $nick $chr(1) $npre $eval($strip($3),1) ( $+ $round($calc($6 /1024/1024),2) MB)
    .write $cit($logdir $+ -dcc.log) $date $time - Send from $nick $+ : $3 ( $+ $round($calc($6 /1024/1024),2) MB)
    if (!$appactive) && ($ncfg(dcc_sound) == 1) splay $qt($mircdirscripts\beep.wav)
  }
  elseif ($1 != sound) {
    haltdef
    if (%tmp.ctcp > 4) {
      .ignore -tu60 *!*@*
      n.echo ctcp -stge CTCP protection: ignoring CTCPs for 60 seconds
      return
    }
    inc -u15 %tmp.ctcp 1
    if ($1 == ping) {
      if ((%tmp.ctcp < 4) || (!%tmp.ctcp)) .ctcpreply $nick PING $2-
      n.echo ctcp -stme $kl(CTCP/PING) from $nick $par($address) $iif(%tmp.ctcp > 3,$par(Ignored))
      if ($hget(nbs,popup_other) == 1) n.ptext - $chr(1) CTCP $chr(1) $npre CTCP/PING) from $nick

    }
    elseif ($1 == version) {
      if ($nick isin %ctcp.ignore) { echo $color(ctcp) -stm $npre  $+ $kl(CTCP/VERSION) from $nick $par($address) $par(Ignored) | return }
      if ((%tmp.ctcp < 4) || (!%tmp.ctcp)) .ctcpreply $nick VERSION $strip($n.name $n.version) - $strip(www.nbs-irc.net) 
      n.echo ctcp -stme $kl(CTCP/VERSION) from $nick $par($address) $iif(%tmp.ctcp > 3,$par(Ignored))
      if ($hget(nbs,popup_other) == 1) n.ptext - $chr(1) CTCP $chr(1) $npre CTCP/VERSION) from $nick
    }
    else n.echo ctcp -stme $kl(CTCP/ $+ $1 $+ ) from $nick $par($address) $iif(%tmp.ctcp > 3,$par(Ignored))
    if ($hget(nbs,popup_other) == 1) n.ptext - $chr(1) CTCP $chr(1) $npre CTCP/ $+ $eval($1,1) from $nick
  }
}

on ^*:USERMODE:{
  echo $color(mode) -ste $npre $+  $nick sets mode: $1-
  haltdef
}

; Find some other logical place for this cfg stuff
alias ncfg {
  if ($1) && ($hget(nbs,$1)) return $ifmatch
}
alias w_ncfg { 
  if ($2) {
    hadd -m nbs $1-
    .writeini config\config.ini nbs-irc $1-
  }
}

alias n.checkini {
  if ($isdir(txt)) && (!$isdir(config)) .rename txt config
  if (!$isdir(config)) .mkdir config
  if (!$isdir(logs)) .mkdir logs
  if (!$isdir(download)) .mkdir download
  if (!$isdir(scripts\temp)) .mkdir scripts\temp
  if (!$isdir(scripts\temp\topic)) .mkdir scripts\temp\topic
  if (!$exists(config\slaps.txt)) write config\slaps.txt slaps [nick] around a bit with a large trout
  if (!$exists(config\kor.txt)) write config\kor.txt $+(cmd,$crlf,notepad,$crlf,calc,$crlf,regedit,$crlf,www.nbs-irc.net,$crlf,www.nbs-irc.net/forum,$crlf,www.google.com)
  if ($exists(config\autojoin.txt)) .rename config\autojoin.txt config\autojoin-QuakeNet.txt
  if (!$exists(config\autojoin-quakenet.txt)) { write -c config\autojoin-QuakeNet.txt }
  if (!$exists(config\hl-servers.txt)) { write config\hl-servers.txt 130.243.72.27:27015 }
  if (!$exists(config\kicks.txt)) { write config\kicks.txt bye }
  if (!$exists(config\quits.txt)) { write -c config\quits.txt }
  if (!$exists(config\mp3.txt)) write config\mp3.txt winamp » [mp3] :: [time] $crlf $+ np: [mp3] :: [time]
  if (!$exists(config\games.txt)) {
    write config\games.txt CS 1.6 $chr(124) c:\program\steam\steam.exe -applaunch 10 +connect [adr] +password [pass]
    write config\games.txt CS:Source $chr(124) c:\program\steam\steam.exe -applaunch 240 +connect [adr] +password [pass]
    write config\games.txt UT2004 $chr(124) C:\UT2004\system\ut2004.exe [adr] [pass]
    write config\games.txt Call of Duty 2 $chr(124) c:\program\activision\call of duty 2\cod2mp_s.exe +password [pass] +connect [adr]
  }
  if (!$exists(config\awaymsg.txt)) write -c config\awaymsg.txt away
  if (!$exists(config\awaynick.txt)) write -c config\awaynick.txt [nick]\away

  if (!$exists(scripts\ownstuff.mrc)) {
    .write scripts\ownstuff.mrc $chr(59) you can put your own scripts here, this file will not be overwritten when updating nbs-irc
    .load -rs1 scripts\ownstuff.mrc
  }
  ncfgc installtime $ctime
  ncfgc whois @whois
  ncfgc whois_inside 1
  ncfgc query_show_online 1
  ncfgc modeprefix 1
  ncfgc highlight_nick_color 8
  ncfgc nickwin 1
  ncfgc ar_time 3
  ncfgc newcc 1
  ncfgc exttb 1
  ncfgc smsg say
  ncfgc skanaler #chan1 #chan2 (# = all channels)
  ncfgc mp3s say winamp » [mp3] :: [time]
  ncfgc mp3getcmd !get $+ $r(1,9)
  ncfgc authnick nick
  ncfgc authpass pass
  ncfgc nickserv_on 1
  ncfgc nickserv_prefix nickserv identify
  ncfgc awaynick [nick]\away
  ncfgc awaymed away
  ncfgc wapath c:\program\winamp\winamp.exe
  ncfgc nickpip 1
  ncfgc nickbar 1
  ncfgc privpip 1
  ncfgc privljud psljud
  ncfgc autojoin_minimize 1
  ncfgc autorejoin 1
  ncfgc cic-time 10
  ncfgc blacklist 1
  ncfgc dcc_sound 1
  ncfgc ban_mask 1
  ncfgc quakenet_bot_autojoin 1
  ncfgc undernet_bot_autojoin 1
  ncfgc titlebar_version 1
  ncfgc reclaim_nick 1
  ncfgc nicklist_use_themed_colors 1
  ncfgc use_theme_fonts 1
  ncfgc version_check 1
  ncfgc check_lag 1
  ncfgc no_highlight off
  ncfgc show_daychanged 1
  ncfgc fkey_f1 /help  
  ncfgc fkey_f3 /awaysys
  ncfgc fkey_f4 /back
  ncfgc fkey_f5 /lastpop
  ncfgc fkey_f7 /topic $eval(#,0)
  ncfgc fkey_f8 /np
  ncfgc fkey_f9 /logviewer
  ncfgc fkey_f10 /g-join
  ncfgc fkey_f11 /blist
  ncfgc fkey_f12 /aboutnbs
  ncfgc tb_skin nbs.png
  ncfgc popup_query_always o
  ncfgc popup_nick 1
  ncfgc popup_query 1
  ncfgc popup_discon 1
  ncfgc popup_dcc 1
  ncfgc popup_other 1
  ncfgc popup_mode 2
  ncfgc popup_timeout 6
  if ($os == 7) {
    ncfgc popup_posx -5
    ncfgc popup_posy -83
  }
  else {
    ncfgc popup_posx -7
    ncfgc popup_posy -75
  }
  ncfgc popup_centerx o
  ncfgc popup_centery o
  ncfgc popup_away o
  ncfgc auto_connect_1_server irc.example.org (Example)
}
alias ncfgc {
  if (!$readini(config\config.ini,nbs-irc,$1)) writeini config\config.ini nbs-irc $1-
}
alias n.reloadconfig {
  if ($hget(nbs)) hfree nbs
  hmake nbs 20
  hload -i nbs config\config.ini nbs-irc
}
alias n.updateevents {
  hadd -m temp joins $ncfg(hide_joins)
  hadd -m temp parts $ncfg(hide_parts)
  hadd -m temp quits $ncfg(hide_quits)
  hadd -m temp nicks $ncfg(hide_nicks)
}
