alias sys {
  $iif($1 == -e,n.echo normal -atg,say) OS: $n.osinfo  –  CPU: $n.cpuinfo  –  Memory usage: $+($dedll(usedphysicalmem),/,$dedll(totalphysicalmem)) MB ( $+ $dedll(memoryload) $+ )   –   Graphics: $dedll(videocard) ( $+ $replacecs($dedll(res),bpp,bit) $+ )
}
alias os {
  cuptime
  var %x = $n.osinfo
  $iif($1 == -e,n.echo normal -atg,say) os: %x $iif(xp isin %x,(installed on $gettok($dedll(installdate),2-,44) $+ ))   –   uptime: $dur($calc($ticks / 1000))
}
alias uptime {
  cuptime
  $iif($1 == -e,n.echo normal -atg,say) uptime: $dur($calc($ticks / 1000)) $iif($ticks < $ncfg(ruptime),  –   record: $dur($calc($ncfg(ruptime) / 1000)))
}
alias cuptime { 
  if (!$ncfg(ruptime)) { w_ncfg ruptime $ticks }
  if ($ticks > $ncfg(ruptime)) { w_ncfg ruptime $ticks } 
}
alias uptimefake say Win95 uptime: $r(3,51) $+ w $r(1,6) $+ d $r(1,23) $+ h $r(1,59) $+ s
alias mem $iif($1 == -e,n.echo normal -atg,say) memory usage: $+($dedll(usedphysicalmem),/,$dedll(totalphysicalmem)) MB ( $+ $dedll(memoryload) $+ )
alias cpu $iif($1 == -e,n.echo normal -atg,say) cpu: $n.cpuinfo
alias gfx $iif($1 == -e,n.echo normal -atg,say) graphics card: $dedll(videocard) ( $+ $replacecs($dedll(res),bpp,bit) $+ )
alias net $iif($1 == -e,n.echo normal -atg,say) nic: $dedll(conn)
alias snd $iif($1 == -e,n.echo normal -atg,say) sound card: $dedll(soundcard)
alias bw {
  var %d = $dedll(banddown), %u = $dedll(bandup)
  if (%u > 1023) var %u = $round($calc(%u /1024),2) MB/s
  else var %u = $round(%u,1) kB/s
  if (%d > 1023) var %d = $round($calc(%d /1024),2) MB/s
  else var %d = $round(%d,1) kB/s
  $iif($1 == -e,n.echo normal -atg,say) download: %d  –  upload: %u
}
alias hdd hd $1-
alias hd {
  ghds fixed
  $iif($1 == -e,echo -a $pre,say) free space: %thdf $+ / $+ %thds GB ( $+ $perc(%thdfree,%thdsize) $+ )
}
alias hdds hds $1-
alias hds {
  unset %?
  if (l isin $1-) var %labels = 1
  if (e isin $1-) var %hd.echo = 1
  if (m isin $1-) var %type = remote
  else var %type = fixed
  var %ii = 99
  while (%ii < 123) {
    if ($disk($chr(%ii)).type == %type) var % [ $+ [ $chr(%ii) ] ] $iif(%labels == 1 && $disk($chr(%ii)).label,( $+ $disk($chr(%ii)).label $+ )) $round($calc($calc($disk($chr(%ii)).free / 1024 / 1024) /1024),2) $+ / $+ $round($calc($calc($disk($chr(%ii)).size / 1024 / 1024) / 1024),2)
    inc %ii
  }
  var %ii = 99, %hdsay
  while (%ii < 123) { 
    var %tmp.v = $chr(37) $+ $chr(%ii)
    if ($eval(%tmp.v,2)) var %hdsay = %hdsay ( $+ $upper($right(%tmp.v,-1)) $+ :) $eval(%tmp.v,2)  - 
    inc %ii
  }
  ghds %type
  if (%thds > 1) $iif(%hd.echo == 1,n.echo normal -atg,say) free space: %hdsay (total: %thdf $+ / $+ %thds GB)
  else n.echo info -atg /hds: no %type drives found
}
alias ghds {
  if ($1) var %type = $1
  unset %thdfree %thdsize
  set %ii 99
  while (%ii < 123) {
    if ($disk($chr(%ii)).type == %type) inc %thdfree $disk($chr(%ii)).free
    inc %ii
  }
  set %ii 99
  while (%ii < 123) {
    if ($disk($chr(%ii)).type == %type) inc %thdsize $disk($chr(%ii)).size
    inc %ii
  }
  set %thdf $round($calc($calc(%thdfree /1024/1024) /1024),2)
  set %thds $round($calc($calc(%thdsize /1024/1024) /1024),2)
}
alias n.osinfo {
  return $remove($getsys(Win32_OperatingSystem).Caption,Microsoft,(r),(tm),®,,â,Â,,¢) $+ $iif($replace($getsys(Win32_OperatingSystem).CSDVersion,service pack $+ $chr(32),SP),$c44 $ifmatch)
}
alias n.cpuinfo {
  var %x = $getsys(Win32_Processor).Name
  if (unknown isin %x) var %x = $dedll(cpuinfo)
  return $removecs($remove(%x,cpu,(r),(tm),®,,â,Â,@,,¢),Dual Core Processor) (at $getsys(Win32_Processor).CurrentClockSpeed MHz)
}
