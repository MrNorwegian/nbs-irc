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