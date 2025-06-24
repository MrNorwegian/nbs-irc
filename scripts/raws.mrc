alias cbinfo if (%n.connecting. [ $+ [ $cid ] ]) haltdef
raw 366:*:{
  if (!$chan($2).ial) .timer 1 1 whochan $2
  set %jkanal $2
  set -u15 %ctcp.ignore $2
  if (%show.names == 1) {
    n.echo notice -sgm $clr(norm,$+(,$2,:)) $3-
    echo $color(info) -sg -
    window -g2 "status window"
    haltdef
  }
  else n.echo info -t $2 $n.chanstats($2)
  unset %show.names
}
raw 352:*:{
  if (%dns2nick.host) {
    inc %dns2nick.times
    if (%dns2nick.times == 1) set %dns2nick.users $6
    else set %dns2nick.users %dns2nick.users $+ , $6
    haltdef
  } 
  if (%n.whosvar != 1) { haltdef }
}
raw 315:*:{ 
  if (%dns2nick.host) {
    if (!%dns2nick.times) echo $color(info) -atg $npre Couldn't find any user with that host
    elseif (%dns2nick.times == 1) echo $color(info) -atg $npre User found: %dns2nick.users
    else echo $color(info) -at $npre %dns2nick.times users found: %dns2nick.users
    unset %dns2nick* 
    haltdef
  } 
  if ($2 == %csial) clonescan $2
  if (%n.whosvar != 1) { haltdef }
  unset %csial %n.whosvar
}
raw 332:*:{ 
  haltdef   
  if ($2 ischan) echo $color(topic) -ti5 $2 - Topic: $3- 
  else echo $color(topic) -atgi5 - Topic in $2 $+ : $3- 
}
raw 333:*:{
  haltdef
  if ($2 ischan) echo $color(info) -ti4 $2 - Set by $clr(topic,$3) on $date($4, dd/mm/yyyy - HH:nn:ss) $par($dur($calc($ctime - $4),2) ago)
  else echo $color(info) -atgi4 - Set by $clr(topic,$3) on $date($4, dd/mm/yyyy - HH:nn:ss) $par($dur($calc($ctime - $4),2) ago)
}
raw 479:*:n.echo info -atg Unable to join $2 $par($3-) | haltdef
raw 406:*:n.echo info -atg $3- $par($2) | haltdef
raw 401:*:n.echo info -atg $3- $par($2) | haltdef
raw 403:*:n.echo info -atg $3- $par($2) | haltdef
raw 005:*:{
  if ($wildtok($1-,topiclen=*,1,32)) set %topiclen. [ $+ [ $cid ] ] $right($ifmatch,-9)
  if ($wildtok($1-,maxbans=*,1,32)) set %maxbans. [ $+ [ $cid ] ] $right($ifmatch,-8)
  cbinfo
}
raw 329:*:{
  if ($2 !isin %körv) {
    if ($calc($ctime - $3) > 60) n.echo info -t $2 Channel created: $date($3,HH:nn:ss - dd/mm/yyyy) $par($dur($calc($ctime - $3),2) ago) 
    else n.echo info -t $2 Channel created
    set -u30 %körv %körv $2
  }
}
raw 331:*:{
  if ($me ison $2) echo $color(topic) -t $2 $npre No topic set
  else echo $color(topic) -atg $npre No topic set on $2
  haltdef
}
raw 001:*:cbinfo
raw 002:*:cbinfo
raw 003:*:cbinfo
raw 004:*:cbinfo
raw 251:*:cbinfo
raw 252:*:cbinfo
raw 253:*:cbinfo
raw 254:*:cbinfo
raw 255:*:cbinfo
raw 375:*:cbinfo
raw 376:*:cbinfo
raw 472:*:n.echo info -atg $n.quote($2) $3-
raw 477:*:n.echo info -atg Unable to join $2 $par($3-) | haltdef
raw 473:*:n.echo info -atg Unable to join $2 $par(invite only) | haltdef
raw 474:*:n.echo info -atg Unable to join $2 $par(you are banned) | haltdef
raw 404:*:n.echo info -atg $3- $par($2) | haltdef
raw 405:*:n.echo info -stge $2- | haltdef
raw 402:*:n.echo info -atg No such nick/server $par($2) | haltdef
raw 432:*:n.echo info -atg $3- $n.quote($2) | haltdef
raw 499:*:n.echo info -atg $3- $par($2)
raw 433:*:{
  haltdef
  n.echo info -atg Nickname $n.quote($2) is already in use
  if ($ncfg(nickserv_on) == 1) && ($ncfg(nickserv_ghost) == 1) .timer 1 3 nickserv_ghost
}
raw 467:*:echo $color(info) -tg $2 $npre $3- | haltdef
raw 438:*:echo $color(info) -atg $npre $3- | haltdef
raw 441:*:echo $color(info) -stge $npre $2- | haltdef
raw 396:*:echo $color(info) -stge $npre $clr(high,$2) $3- | haltdef
raw 442:*:n.echo info -atg You are not on that channel $par($2) | haltdef
raw 461:*:n.echo info -atg $3- $par($lower($2)) | haltdef
raw 471:*:n.echo info -atg Unable to join $2 $par(channel is full) | haltdef
raw 486:*:n.echo info -atg $3- $par($2) | haltdef
raw 475:*:n.echo info -atg Unable to join $2 $par(need correct key) | haltdef
raw 481:*:n.echo info -atg $2- | haltdef
raw 482:*:echo $color(info) -tg $2 $npre $2 $+ : $3- | haltdef
raw 478:*:n.echo info -atg $4- $par($3) | haltdef
raw 443:*:n.echo info -atg $2 is already on $3 | haltdef
raw 341:*:n.echo info -atg Invited $2 to $3 | haltdef
raw 305:*:{
  var %x = $2- $par($iif($awaytime,away for $dur($awaytime)))
  n.echo notice -stge %x
  if ($active != status window) n.echo notice -atg %x
  titleupdate 
  haltdef
}
raw 306:*:{
  var %x = $2- $par($awaymsg)
  n.echo notice -stge %x
  if ($active != status window) n.echo notice -atg %x
  titleupdate 
  haltdef
}
raw 311:*:{ 
  unset %w-*
  if (%whois.idle != 1) {
    if ($ncfg(whois) == @whois) { 
      set %w-dest @whois ( $+ $cid $+ )
      if (!$window(%w-dest)) {
        if ($ncfg(whois_inside) == 1) { 
          window -k0n %w-dest 
          if ($appactive) && ($activecid == $cid) window -a %w-dest
        }
        else window -k0d $+ $iif(%whois.window.passive,n) %w-west 200 200 600 200
      }
      else {
        if ($ncfg(whois_inside) != 1) dline %w-dest 1
        if (%whois.idle != 1) window -g1 %w-dest
      }
    }
    else set %w-dest $ncfg(whois)
  }
  set %whois 1
  set %w-nick $2
  set %w-address echo $color(whois) %w-dest $chr(160) $+  address: $3 $+ $clr(highlight,@) $+ $4 
  set %w-name echo $color(whois) %w-dest $chr(160) $+  name: $6-
  haltdef
}
raw 312:*:set %w-server echo $color(whois) %w-dest $chr(160) $+  server: $3 $par($4-) | haltdef
raw 313:*:set %w-ircop echo $color(whois) %w-dest $chr(160) $+  irc operator | haltdef
raw 301:*:{
  haltdef
  if (%whois == 1) set %w-away echo $color(whois) %w-dest $chr(160) $+  away: $3- 
  elseif (!%waway. [ $+ [ $2 ] ]) {
    echo $color(info) -tg $2 $npre $2 is away $par($3-)
    set -u3600 %waway. [ $+ [ $2 ] ] 1
  }
}
raw 317:*:{
  if ($calc($ctime - $4) > 1) var %s = $dur($ifmatch) ago
  set %w-time echo $color(whois) %w-dest $chr(160) $+  idle: $dur($3) $+ , signed on: $date($4,HH:nn:ss - dd/mm/yyyy) $par(%s) 
  if (%whois.idle) n.echo info -atg $2 has been idle for $dur($3)
  haltdef
}
raw 353:*:{
  if (%show.names == 1) {
    n.echo norm -gs $3 $+ : $replace($4-,@,$clr(notice,@),+,$clr(notice,+),%,$clr(notice,%),~,$clr(notice,~),&,$clr(notice,&))
    haltdef
  }
}
raw 330:*:if (%whois == 1) { set %w-auth echo $color(whois) %w-dest $chr(160) $+  auth: $3 | haltdef } | else { haltdef }
raw 307:*:if (%whois == 1) { set %w-registered 1 | haltdef }
raw 338:*:{
  haltdef
  if (%whois == 1) {
    if ($n.qnet) { set %w-realip echo $color(whois) %w-dest $chr(160) $+  user@host: $3 $par($4) }
    else set %w-realip echo $color(whois) %w-dest $chr(160) $+  user@host: $3-
  }
}
raw 318:*:{
  if (%whois.idle != 1) {
    if (%w-name) echo $color(whois) %w-dest $chr(160)
    if (%w-nick) echo $color(high) %w-dest $kl(whois: %w-nick) $par($iif(%w-registered == 1,registered nick))
    if (%w-name) $ifmatch
    if (%w-address) $ifmatch
    if (%w-chans) $ifmatch
    if (%w-ircop) $ifmatch
    if (%w-auth) $ifmatch
    if (%w-realip) $ifmatch
    if (%w-away) $ifmatch
    var %i = 1
    while (%i <= %w-other-count) {
      echo $color(whois) %w-dest %w-other [ $+ [ %i ] ]
      inc %i
    }
    if (%w-server) $ifmatch
    if (%w-time) $ifmatch
    if (%whois == 1) {
      echo $color(high) %w-dest $kl(/whois: $time(HH:nn)) 
      echo $color(whois) %w-dest $chr(160)
    }
  }
  unset %whois* %w-*
  haltdef
}
raw 319:*:{
  var %c = $3-
  if ($2 != $me) { 
    var %i = 1
    while (%i <= $comchan($2,0)) {
      var %x = $comchan($2,%i), %c = $reptok(%c,$cmode($2,%x,_) $+ %x,$cmode($2,%x,_) $+  $+ %x $+ ,1,32)
      inc %i
    }
  }
  set %w-chans echo $color(whois) %w-dest $chr(160) $+  channels: %c $par($calc($0 - 2))
  haltdef
}
raw 314:*:{
  unset %w-*
  if (%whois.idle != 1) {
    if ($ncfg(whois) == @whois) { 
      set %w-dest @whois ( $+ $cid $+ )
      if (!$window(%w-dest)) {
        if ($ncfg(whois_inside) == 1) { 
          window -k0n %w-dest 
          if ($appactive) && ($activecid == $cid) window -a %w-dest
        }
        else window -k0d $+ $iif(%whois.window.passive,n) %w-west 200 200 600 200
      }
      else {
        if ($ncfg(whois_inside) != 1) dline %w-dest 1
        if (%whois.idle != 1) window -g1 %w-dest
      }
    }
    else set %w-dest $ncfg(whois)
  }
  set %whois 1
  set %w-nick $2
  set %w-address echo $color(whois) %w-dest $chr(160) $+  address: $3 $+ $clr(highlight,@) $+ $4 
  set %w-name echo $color(whois) %w-dest $chr(160) $+  name: $6-
  echo $color(whois) %w-dest $chr(160)
  haltdef
}
raw 369:*:{
  if (%w-name) echo $color(whois) %w-dest $chr(160)
  if (%w-nick) echo $color(high) %w-dest $kl(whowas: %w-nick)
  if (%w-name) $ifmatch
  if (%w-address) $ifmatch
  if (%w-chans) $ifmatch
  if (%w-ircop) $ifmatch
  if (%w-auth) $ifmatch
  if (%w-realip) $ifmatch
  if (%w-away) $ifmatch
  var %i = 1
  while (%i <= %w-other-count) {
    echo $color(whois) %w-dest %w-other [ $+ [ %i ] ]
    inc %i
  }
  if (%w-server) $ifmatch
  if (%w-time) $ifmatch
  if (%whois == 1) {
    echo $color(high) %w-dest $kl(/whowas: $time(HH:nn)) 
    echo $color(whois) %w-dest $chr(160)
  }
  if ($window(%w-dest)) window -a %w-dest
  unset %whois* %w-*
  haltdef
}
raw 367:*:{
  haltdef
  if (%unba == 1) {
    inc %totbans1
    set %ban $+ %totbans1 $3
  }
  elseif ($dialog(cc)) {
    did -a cc 2 $3 $chr(9) $+ $iif($4 === $server,(server),$4) $chr(9) $+ $date($5,HH:nn - dd/mm/yy)
    inc %totbans
  }
  elseif (%ccc.banget) haltdef
  else echo $color(info) -smtg $npre $kl($clr(normal,$3)) Set by $4 on $date($5,HH:nn - dd/mm/yy) $par($dur($calc($ctime - $5)) ago)
}
raw 368:*:{
  haltdef
  if ($dialog(cc)) {
    if (%totbans > 0) did -ra cc 4 Bans ( $+ %totbans $+ / $+ $n.maxbans $+ )
    else did -ra cc 4 Bans (0/ $+ $n.maxbans $+ )
    unset %totbans 
    if (%adopgk == 1) {
      did -r cc 2
      did -ra cc 4 Bans
    }
  }
  elseif (%ccc.banget) { haltdef | unset %ccc.banget }
  else echo $color(info) -stge $npre $kl($clr(normal,$2)) $3-
}
raw 346:*:{
  haltdef
  if ($dialog(cc)) {
    did -i cc 2 2 $3 $chr(9) $+ $4 $chr(9) $+ $date($5,HH:nn - dd/mm/yy)
    inc %totbans
  }
  elseif (%ccc.banget) haltdef
  else echo $color(info) -stge $npre $kl($clr(normal,$3))
}
raw 347:*:{
  haltdef
  if ($dialog(cc)) {
    if (%totbans > 0) did -ra cc 4 Invites ( $+ %totbans $+ )
    else did -ra cc 4 Invites (none)
    unset %totbans 
  }
  elseif (%ccc.banget) { haltdef | unset %ccc.banget }
  else echo $color(info) -stge $npre $kl($clr(normal,$2)) $3-
}
raw 348:*:{
  haltdef
  if ($dialog(cc)) {
    did -i cc 2 2 $3 $chr(9) $+ $4 $chr(9) $+ $date($5,HH:nn - dd/mm/yy)
    inc %totbans
  }
  elseif (%ccc.banget) haltdef
  else echo $color(info) -stge $npre $kl($clr(normal,$3))
}
raw 349:*:{
  haltdef
  if ($dialog(cc)) {
    if (%totbans > 0) did -ra cc 4 Excepts ( $+ %totbans $+ )
    else did -ra cc 4 Excepts (none)
    unset %totbans 
  }
  elseif (%ccc.banget) { haltdef | unset %ccc.banget }
  else echo $color(info) -stge $npre $kl($clr(normal,$2)) $3-
}
;raw 324:*:return
;raw 372:*:return
;raw 422:*:return
;raw 303:*:return
raw *:*:{
  if (%whois == 1) {
    haltdef
    inc %w-other-count
    set %w-other $+ %w-other-count $chr(160) $+  $2 $+  $3-
  }
  ;else n.echo info -atgm $2-
}