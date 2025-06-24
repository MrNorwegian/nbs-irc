
menu status {
  $iif($status == connected,Reconnect $chr(9) (/server)):server
  -
  Control Panel $chr(9) (/setup):setup
  Auto connect settings $chr(9) (/autocon):autocon
  Autojoin settings $chr(9) (/caj):caj
  NickServ settings $chr(9) (/cns):cns
  -
  $iif($status == connected,,$style(2)) Force autojoin $chr(9) (/aj):aj
  $iif($n.qnet && $status == connected,,$style(2)) Auth with Q $chr(9) (/auth):auth
  $iif($status == connected,,$style(2)) Set mode +x $chr(9) (/mode nick +x):mode $me +x
  $iif($status == connected,,$style(2)) Check lag $chr(9) (/clag):clag
  $iif($status == connected,,$style(2)) MOTD $chr(9) (/motd):motd
  -
  $iif($n.qnet && $status == connected,Q bot)
  .Auth now:auth
  .Register:msg Q hello $$n.input(Enter your mail address:) $$n.input(Enter your mail address again:)
  .-
  .Whoami:msg Q whoami
  .Whois:msg Q whois $$n.input(Enter nick name: $crlf $crlf $+ (Prefix nick with $chr(35) to use auth nick))
  .Change password:.msg Q@CServe.quakenet.org newpass $$n.input(Enter your new password:) $$n.input(Enter your new password again:)
  .Change mail:.msg Q@CServe.quakenet.org email $$n.input(Enter your auth password:) $$n.input(Enter your new mail address:) $$n.input(Enter your new mail address again:)
  .Request password:msg Q requestpassword $$n.input(Enter your mail address:)
  .Show auth history:msg Q authhistory
}

menu channel {
  $left(#,12) $+ $iif($len(#) > 12,...)
  .Chan central $chr(9) (/cc #chan):channel $1-
  .Hide events $chr(9) (/hevents #chan):hevents #
  .-
  .Search log $chr(9) (/slog <text>):if ($input(Search for:,e,Search log)) slog $!
  .View log $chr(9) (/logg):logg
  .View log $chr(9) (external):{
    if ($exists($window($active).logfile)) run $window($active).logfile
    else n.echo other -at no log file found for $active
  }
  .Show topic $chr(9) (default F7):topic #
  .Clear $chr(9) (/clear):clear
  .Clonescan $chr(9) (/clonescan #chan):clonescan #
  .-
  .$iif($n.qnet,Request op $chr(9) (QuakeNet)):.msg R requestop $chan $me
  .$iif($n.qnet,Request op $chr(9) (choose nick)):.msg R requestop $chan $$n.input(Enter nick name:)
  .-
  .$iif(Q !ison # && $n.qnet,request Q):msg R requestbot #
  .-
  .$iif($me ison #,Leave $chr(9) (/part),Join $chr(9) (/join #chan)):$iif($me ison #,part #,join # $chan(#).key)
  .Rejoin $chr(9) (/hop):hop

  Autojoin
  .$iif($read(config\autojoin- [ $+ [ $network ] $+ ] .txt,w,[ $chan [ $+ ] * ]),Remove # from autojoin,Add # to autojoin):n.aj.edit #
  .Edit autojoin on $network:{
    var %a = config\autojoin- $+ $network $+ .txt
    if (!$read(%a)) write -c %a
    caj $network
  }
  .-
  .$iif($ncfg(autojoin) == 1,$style(1) Autojoin $+ $chr(58) on,Autojoin $+ $chr(58) off):{
    if ($ncfg(autojoin) == 1) w_ncfg autojoin o
    else w_ncfg autojoin 1
  }
  $iif(q ison # && $n.qnet,Q bot)  
  .Nick
  ..Auth now:auth
  ..Register:msg Q hello $$n.input(Enter your mail address:) $$n.input(Enter your mail address again:)
  ..-
  ..Whoami:msg Q whoami
  ..Whois:msg Q whois $$n.input(Enter nick name: $crlf $crlf $+ (Prefix nick with $chr(35) to use auth nick))
  ..Change password:.msg Q@CServe.quakenet.org newpass $$n.input(Enter your new password:) $$n.input(Enter your new password again:)
  ..Change mail:.msg Q@CServe.quakenet.org email $$n.input(Enter your auth password:) $$n.input(Enter your new mail address:) $$n.input(Enter your new mail address again:)
  ..Request password:msg Q requestpassword $$n.input(Enter your mail address:)
  ..Show auth history:msg Q authhistory
  .Channel
  ..Show welcome message:msg Q welcome #
  ..Show and edit welcome message:msg Q welcome # | editbox -ap /msg Q welcome # 
  ..-
  ..Show online users:msg Q users #
  ..Show all added users:msg Q chanlev #
  ..Show chanstats:msg Q chanstat #
  ..Show op history:msg Q chanophistory #
  ..Show banlist:msg Q banlist #
  ..Show autolimit:msg Q autolimit #
  ..Clear bans:msg Q banclear #
  ..Clear chanmodes:msg Q clearchan #
  ..Deop all users:msg Q deopall # 
  .Chanflags
  ..Show channel flags:msg Q chanflags #
  ..-
  ..Known only $chr(9) (+k)
  ...on:msg Q chanflags # +k
  ...off:msg Q chanflags # -k
  ..Enforce bans $chr(9) (+e)
  ...on:msg Q chanflags # +e
  ...off:msg Q chanflags # -e
  ..Voice all $chr(9) (+v)
  ...on:msg Q chanflags # +v
  ...off:msg Q chanflags # -v
  ..Bitch mode $chr(9) (+b)
  ...on:msg Q chanflags # +b
  ...off:msg Q chanflags # -b
  ..Channel-limit $chr(9) (+c)
  ...on:msg Q chanflags # +c
  ...off:msg Q chanflags # -c
  ..Force topic $chr(9) (+f)
  ...on:msg Q chanflags # +f
  ...off:msg Q chanflags # -f
  ..Force key $chr(9) (+k)
  ...on:msg Q chanflags # +k
  ...off:msg Q chanflags # -k
  ..Force limit $chr(9) (+l)
  ...on:msg Q chanflags # +l
  ...off:msg Q chanflags # -l
  ..Protect ops $chr(9) (+p)
  ...on:msg Q chanflags # +p
  ...off:msg Q chanflags # -p
  ..Topic save $chr(9) (+t)
  ...on:msg Q chanflags # +t
  ...off:msg Q chanflags # -t
  ..Welcome message $chr(9) (+w)
  ...on:msg Q chanflags # +w
  ...off:msg Q chanflags # -w
  .-
  .Show commands:msg Q showcommands
  .-
  .Request op:msg Q op #
  .Request voice:msg Q voice #
  -
  Stuff
  .Say sys info
  ..Complete $chr(9) (/sys):sys
  ..-
  ..OS $chr(9) (/os):os
  ..CPU $chr(9) (/cpu):cpu
  ..Memory usage $chr(9) (/mem):/mem
  ..Graphics card $chr(9) (/gfx):gfx
  ..Sound card $chr(9) (/snd):snd
  ..Total hdd free space $chr(9) (/hd):hd
  ..Individual free space $chr(9) (/hds):hds
  ..Ind. free space w/ labels $chr(9) (/hds -l):hds -l
  ..Ind. mapped free space $chr(9) (/hds -m):hds -m
  ..Ind. mapped free space w/ labels $chr(9) (/hds -ml):hds -ml
  ..Uptime $chr(9) (/uptime):uptime
  ..Connection $chr(9) (/net):net
  ..IP address $chr(9) (/ip):ip
  ..Bandwidth usage $chr(9) (/bw):bw
  ..Change network card used for /bw:.echo -qg $dedll(change_adapter) 
  .-
  .Voting $chr(9) (y/n)
  ..Begin $chr(9) (/vote):vote
  ..End $chr(9) (/voteoff):voteoff
  .Say power $chr(9) (/power):power 
  .Advertise script $chr(9) (/ad):ad
  .Lag-check (echo) $chr(9) (/clag):clag
  .-
  .Google search $chr(9) (/g query):editbox -p /g
  .Wikipedia search $chr(9) (/wiki query):editbox -p /wiki
  .IMDb search $chr(9) (/imdb query):editbox -p /imdb
  .-
  .Export log $chr(9) (/exportlog)
  ..This channel:exportlog $window($active).logfile
  ..Select log file:exportlog
  Configuration
  .Control Panel $chr(9) (/setup, F2):setup
  .-
  .Misc settings $chr(9) (/misc):misc
  .Theme/font settings $chr(9) (/theme):theme
  .Sound/highlight settings $chr(9) (/nq):nq
  .Song announce $chr(9) (/sa):sa
  .Protections $chr(9) (/prot):prot
  .Auto connect $chr(9) (/autocon):autocon
  .Autojoin $chr(9) (/caj):caj
  .QuakeNet setup $chr(9) (/quakenet):quakenet
  .UnderNet setup $chr(9) (/undernet):undernet
  .NickServ setup $chr(9) (/cns):cns
  .Notifications $chr(9) (/popups):popups
  .F-key bindings $chr(9) (/fkeys):fkeys
  .Logviewer $chr(9) (/lv):lv
  .Game launcher $chr(9) (/g-join):g-join
  .Blacklist $chr(9) (/blist):blist
  .Alarm timer $chr(9) (/alarm):alarm
  -
  Song announce
  .Advertise current song:np
  .Settings:mp3say
  .-
  .Winamp only $+ $chr(58):.
  .(Shift+F1) $+ $chr(58) Previous:sf1
  .(Shift+F2) $+ $chr(58) Play:sf2
  .(Shift+F3) $+ $chr(58) Pause:sf3
  .(Shift+F4) $+ $chr(58) Stop:sf4
  .(Shift+F5) $+ $chr(58) Next:sf5
  .-
  .Start Winamp:{
    if ($exists($cit($ncfg(wapath)))) { run $ncfg(wapath) }
    else {
      w_ncfg wapath $sfile(winamp.exe,Locate your winamp.exe) 
      if ($exists($cit($ncfg(wapath)))) { run $ncfg(wapath) }
    }
  }
  .Close Winamp:dll scripts\dll\winamp.dll closewinamp
  $iif(%psybnc. [ $+ [ $cid ] ],psyBNC)
  .Play private log:!raw -q playprivatelog
  .Erase private log:!raw -q eraseprivatelog
  .-
  .Play traffic log (last):!raw -q playtrafficlog last
  .Erase traffic log:!raw -q erasetrafficlog
  .-
  .Open psyBNC window:n.bnc psyBNC | window -a $bncwin(psybnc,$cid)
  $iif(%sbnc. [ $+ [ $cid ] ],sBNC)
  .Read log:n.bnc sbnc read
  .Erase log:n.bnc sbnc erase
  .-
  .Open sBNC window:n.bnc sBNC | window -a $bncwin(sbnc,$cid)
  Change nick:editbox -a /nick $me
  -
  Away
  .$iif(!$away,Set away (default F3),$style(2) Set away (default F3))):awaysys 
  .$iif($away,Return (default F4),$style(2) Return (default F4))):back
  .-
  .$iif($away,Change away msg,$style(2) Change away message):away $$n.input(Enter new away message:)
}

menu nicklist {
  Whois:whois $$1
  Idle:idle $$1
  -
  $iif($me isop #, $iif($1 isop #, - op,+ op),$style(2) +/- op):if ($1 isop #) emode - o | else emode + o
  $iif($me isop # || $me ishop # && % isin $npre, $iif($1 ishop #, - halfop,+ halfop),):if ($1 ishop #) emode - h | else emode + h
  $iif($me isop # || $me ishop #, $iif($1 isvoice #, - voice,+ voice),$style(2) +/- voice):if ($1 isvoice #) emode - v | else emode + v
  $iif($len($prefix) > 3,+/- custom):{
    var %x = $n.input(Enter custom mode (eg: +a or -a):)
    if (%x) emode $mid(%x,1,1) $mid(%x,2,1)
  }
  -
  $iif($me isop # || $me ishop #, Kick,$style(2) Kick)
  .Kick:{
    var %i = 1
    while (%i <= $snick(#,0)) {
      kick $chan $snick(#,%i) $read(config\kicks.txt)
      inc %i
    }
  } 
  .Kick $chr(9) (reason):{
    var %i = 1, %kmsg = $$n.input(Enter kick reason:)
    while (%i <= $snick(#,0)) {
      kick $chan $snick(#,%i) %kmsg
      inc %i
    }
  }
  $iif($me isop # || $me ishop #, Ban,$style(2) Ban)
  .Ban, kick:{ 
    var %i = 1
    while (%i <= $snick(#,0)) {
      bk # $snick(#,%i) $read(config\kicks.txt)
      inc %i
    }
  }
  .Ban, kick (reason):{ 
    var %kick = $$n.input(Enter kick reason:), %i = 1
    while (%i <= $snick(#,0)) {
      bk # $snick(#,%i) %kick
      inc %i
    }
  }
  .- 
  .Kick, ban:{ 
    var %i = 1
    while (%i <= $snick(#,0)) {
      kb # $snick(#,%i) $read(config\kicks.txt)
      inc %i
    }
  }
  .Kick, ban (reason):{ 
    var %kick = $$n.input(Enter kick reason:), %i = 1
    while (%i <= $snick(#,0)) {
      kb # $snick(#,%i) %kick
      inc %i
    }
  }
  .-
  .$iif($n.qnet && q ison #,Kick $+ $chr(44) Q ban auth):{ 
    var %i = 1
    while (%i <= $snick($chan,0)) {
      msg Q chanlev # $snick(#,%i) +b
      kick # $snick(#,%i) $read(config\kicks.txt)
      inc %i
    }
  }
  .$iif($n.qnet && q ison #,Kick $+ $chr(44) Q ban auth (reason)):{ 
    var %kick = $$n.input(Enter kick reason:), %i = 1
    while (%i <= $snick($chan,0)) {
      msg Q chanlev # $snick($chan,%i) +b
      kick # $snick(#,%i) %kick
      inc %i
    }
  }
  .-
  .$iif($n.qnet && q ison #,Q ban host):{
    var %i = 1
    while (%i <= $snick(#,0)) {
      msg Q ban # $address($snick($chan,%i),$ncfg(ban_mask))
      inc %i
    }
  }
  -
  Stuff
  .Blacklist
  ..$$1 (nick only):.write config\blacklist.txt $1 $+ $chr(44) $$n.input(Enter blacklist reason:,Blacklisted) | w_ncfg blacklist 1 | n.blscan # | n.blscanall
  ..$address($snicks,2):.write config\blacklist.txt $address($snicks,2) $+ $chr(44) $+ $$n.input(Enter blacklist reason:,Blacklisted) | w_ncfg blacklist 1 | n.blscan # | n.blscanall
  ..$address($snicks,1):.write config\blacklist.txt $address($snicks,1) $+ $chr(44) $+ $$n.input(Enter blacklist reason:,Blacklisted) | w_ncfg blacklist 1 | n.blscan # | n.blscanall
  ..-
  ..Edit blacklist:blist
  .Ignore
  ..$$1 (nick only):ignore $1 | .ignore on
  ..$address($snicks,2):ignore $address($snicks,2) | .ignore on
  ..$address($snicks,1):ignore $address($snicks,1) | .ignore on
  .Auto op
  ..$$1 (nick only):aop $1 # | .aop on
  ..$address($snicks,2):aop $address($snicks,2) # | .aop on
  ..$address($snicks,1):aop $address($snicks,1) # | .aop on
  .Auto voice
  ..$$1 (nick only):avoice $1 # | .avoice on
  ..$address($snicks,2):avoice $address($snicks,2) # | .avoice on
  ..$address($snicks,1):avoice $address($snicks,1) # | .avoice on

  .Edit:uwho
  .-
  .IP $chr(9) (/dns):dns $$1
  .View log $chr(9) (/logg):{
    !query -n $$1 
    if ($exists($window($1).logfile)) run $window($1).logfile
    !close -m $$1
  }
  .$iif($notify($1),Remove from notify list,Add to notify list):notifyer $1
  .Host2nick $chr(9) (/host2nick host):dns2nick $remove($address($$1,2),*!*@)
  .Request op $chr(9) (QuakeNet):msg R requestop # $$1
  .-
  Slap:slap $$1
  -
  $iif(q ison #,Q flags):botcontrol # $1
  -
  DCC/CTCP
  .[DCC]:return
  .-
  .Send:dcc send $$1
  .Chat:dcc chat $$1
  .Send current song:mp3send $$1
  .- 
  .[CTCP]:return
  .-
  .Ping:ctcp $$1 PING
  .Version:ctcp $$1 VERSION
  .Finger:ctcp $$1 FINGER
  .Time:ctcp $$1 TIME
}

menu query {
  Info
  .Whois (extended):whois $$1
  .Whois (normal):whois2 $$1
  .-  
  .Whois (Q):msg Q whois $$1
  .Whois (L):msg L whois $$1 
  .- 
  .DNS (ip):dns $$1
  .Host-2-nick:dns2nick $remove($address($$1,2),*!*@)
  -
  $iif($ncfg(privpip) == 1,$style(1) Query sound,Query sound):{
    if ($ncfg(privpip) == 1) { w_ncfg privpip o }
    else { w_ncfg privpip 1 }
  }
  -
  Ignore $1
  .$address($1,2):ignore $address($1,2) | n.echo normal -atg Note: If you have a query window open with someone, private messages from them won't be ignored even if their address matches an ignore address.
  .$address($1,1):ignore $address($1,1) | n.echo normal -atg Note: If you have a query window open with someone, private messages from them won't be ignored even if their address matches an ignore address.
  .$1 $+ *@*:ignore $1 | n.echo normal -atg Note: If you have a query window open with someone, private messages from them won't be ignored even if their address matches an ignore address.
  Edit ignore list:uwho
  -
  $iif($notify($1),Remove from notify list,Add to notify list):notifyer $1
  Open get dir:{
    if ($isdir($getdir $+ $1 $+ )) run $getdir $+ $1
    else n.echo info -atg No download dir found for $1 $par($getdir $+ $1)
  }
  Logfile
  .View log:logg
  .View log (external):run $n.log($active)
  .Search in log:slog $$n.input(Search for:))
  .Export/save log:exportlog $n.log($active)
  -
  DCC/CTCP
  .[DCC]:return
  .-
  .Send:dcc send $$1
  .Chat:dcc chat $$1
  .Send current song:mp3send $$1
  .-
  .[CTCP]:return
  .-
  .Ping:ctcp $$1 ping
  .Time:ctcp $$1 time
  .Finger:ctcp $$1 finger
  .Version:ctcp $$1 version
}
menu menubar {
  .Control Panel (F2):setup
  Windows
  .Close all windows:partall | close -icfgms@
  .Close all querys:scon -a close -m
  .-
  .Leave all channels (/partall):partall
  .Leave all channels (reason):partall $$n.input(Enter part reason:)
  .-
  Away
  .$iif(!$away,Set away (F3),$style(2) Set away (F3))):awaysys 
  .$iif($away,Return (F4),$style(2) Return (F4))):back
  .-
  .$iif($away,Change away msg,$style(2) Change away message):away $$n.input(Enter new away message:)
  -
  Alarm timer:alarm 
  Open DCC get folder:run $getdir
}
menu @preview { 
  rclick:close -@ @preview*
}
menu @previewx { 
  sclick:window -a @preview
  rclick:close -@ @preview*
}
menu @whois (*),@highlights (*) {
  dclick:{
    if ($window($active).mdi) window -n $active
    else close -@ $active
  }
  Settings:misc
}
menu @tb.setup {
  .Misc settings $chr(9) (/misc):misc
  .Theme/font settings $chr(9) (/theme):theme
  .Sound/highlight settings $chr(9) (/nq):nq
  .Song announce $chr(9) (/sa):sa
  .Protections $chr(9) (/prot):prot
  .Auto connect $chr(9) (/autocon):autocon
  .Autojoin $chr(9) (/caj):caj
  .QuakeNet setup $chr(9) (/quakenet):quakenet
  .UnderNet setup $chr(9) (/undernet):undernet
  .NickServ setup $chr(9) (/cns):cns
  .Notifications $chr(9) (/popups):popups
  .F-key bindings $chr(9) (/fkeys):fkeys
  .Logviewer $chr(9) (/lv):lv
  .Game launcher $chr(9) (/g-join):g-join
  .Blacklist $chr(9) (/blist):blist
  .Alarm timer $chr(9) (/alarm):alarm
}
menu @tb.theme {
  Reload theme $chr(9) (/theme -r):theme -r
  Edit theme $chr(9) (/tedit):tedit
}
menu @tb.alarm {
  Ring in
  .1 minute: .timeralarm 1 60 beep 10 100 | n.echo info -atg Alarm set: 1 minute
  .2 minutes: .timeralarm 1 120 beep 10 100 | n.echo info -atg Alarm set: 2 minutes
  .5 minutes: .timeralarm 1 300 beep 10 100 | n.echo info -atg Alarm set: 5 minutes
  .10 minutes: .timeralarm 1 600 beep 10 100 | n.echo info -atg Alarm set: 10 minutes
  Stop:.timeralarm off | splay stop
}
menu @psybnc (*) {
  Play private log:!raw -q PLAYPRIVATELOG
  Erase private log:!raw -q ERASEPRIVATELOG
  -
  Play traffic log (last):!raw -q playtrafficlog last
  Erase traffic log:!raw -q erasetrafficlog
  -
  Bwho (list users):!raw -q bwho
  -
  Away
  .set away-msg (setaway):echo -t $active $npre ex. setaway :offline | editbox $active /quote setaway $chr(58)
  .set public away-msg (setleavemsg):echo -t $active $npre ex. setaway :offline | editbox $active /quote setleavemsg $chr(58)
  .-
  .set away-nick (setawaynick):editbox -p $active /quote setawaynick
  Server
  .bconnect:!raw -q bconnect
  .bquit:!raw -q bquit
  .jump:!raw -q bjump
}
menu @sbnc (*) {
  Read log:n.bnc sbnc read
  Erase log:n.bnc sbnc erase
  -
  jump:n.bnc sbnc jump
  partall:n.bnc sbnc partall
  status:n.bnc sbnc status
  vhosts:n.bnc sbnc vhosts
}
menu @logviewer {
  dclick:{
    var %f = $remove($logdir,$mircdir) $+ $line(@logviewer,$1,1), %h = $nofile(%f) $+ $mid($nopath(%f),3,-2)
    if ($isdir(%h)) || ($mid($nopath(%f),3,-2) == ..) {
      if ($mid($nopath(%f),3,-2) == ..) var %h = $left(%h,-3)
      clear -l @logviewer
      clear @logviewer
      aline -l @logviewer $chr(91) .. $chr(93)
      var %a = $finddir(%h,*,0,1,aline -l @logviewer $chr(91) $nopath($1-) $chr(93))
      echo @logviewer $npre $findfile(%h,*.log,0,1,aline -l @logviewer $nopath($1-)) log files and %a folders in %h
      set %lv.dir %h $+ \
    }
    else {
      var %y = %lv.dir $+ $nopath(%f)
      if ($file(%y).size > 10000000) {
        if (!$n.input(This is a very large log file ( $+ $round($calc($file(%y).size /1024/1024),2) MB) $+ $c44 loading will take some time. Do you want to continue?,y/n)) return
      }
      clear @logviewer
      loadbuf -p @logviewer $cit(%y)
      echo @logviewer $npre $kl:($nopath(%f)) $lines(%y) lines, $round($calc($file(%y).size /1024),2) KB
    }
    titlebar @logviewer - %lv.dir
  }
  -
  $iif($sline(@logviewer,0) && $left($sline(@logviewer,1),1) != [,Rename log) { 
    var %file = $+(",%lv.dir,$sline(@logviewer,1),")
    if ($exists(%file)) {
      var %newname = $n.input(Enter new name (name.log):,$nopath(%file))"
      if (!%newname) { return }
      var %newfile = $+(",%lv.dir,$iif($right(%newname,4) == .log,%newname,$+(%newname,.log)),")
    }
    else {
      echo @logviewer $npre %file does not exist
      dline -l @logviewer $sline(@logviewer,1).ln
      return
    }
    if ($exists(%newfile)) { echo @logviewer $npre %newfile already exists | return }
    .rename %file %newfile
    if ($exists(%newfile)) {
      echo -t @logviewer $npre $nopath(%file) renamed to $nopath(%newfile)
      rline -l @logviewer $sline(@logviewer,1).ln $nopath(%newfile)
    }
  }
  $iif($sline(@logviewer,0) && $left($sline(@logviewer,1),1) != [,Delete log) {
    var %file = $+(",%lv.dir,$sline(@logviewer,1),")
    if ($exists(%file)) {
      if ($n.input(Delete $nopath(%file) $+ ?,y/n)) {
        .remove %file
        dline -l @logviewer $sline(@logviewer,1).ln
        echo -t @logviewer $npre %file deleted
      }
    }
    else {
      echo @logviewer $npre %file does not exist
      dline -l @logviewer $sline(@logviewer,1).ln
    }
  }
  -
  $iif($sline(@logviewer,0) && $left($sline(@logviewer,1),1) != [,Open selected file):run $+(",%lv.dir,$sline(@logviewer,1),")
  $iif($sline(@logviewer,0) && $left($sline(@logviewer,1),1) == [,Open selected folder):run $+(",%lv.dir,$mid($sline(@logviewer,1),3,-2),")
  Open current folder:run $+(",%lv.dir,")
}
menu @search*,@log*,@clones*,@whois (*),@psybnc (*),@sbnc (*),@highlights (*) {
  -
  Clear:clear
  Close:close -@ $active
}
menu @n.popup {
  sclick:{
    if ("*" iswm %popup.window) window -a %popup.window
    else {
      if ($appstate == minimized) || ($appstate == tray) {
        showmirc -r
      }
      showmirc -s
      if ($window(%popup.window)) window -a %popup.window
    }
  }
  rclick:close -@ @n.popup
}

menu @rcon {
  send status:rcon_cmd status
  send stats:rcon_cmd stats
  send sv_password:rcon_cmd sv_password
  -
  Close:{
    close -@ @rcon
    sockclose rcon*
    unset %rcon.*
  }
}
