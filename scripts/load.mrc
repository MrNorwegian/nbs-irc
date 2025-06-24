on *:load: { 
  n.checkfiles
}

alias n.checkfiles {
  set %f bug
  set %debug 1
  if ( %n.debug == 1 ) echo 7 -atg * Debug: n.checkfiles started

  ; Disabling some really old scripts.
  if ($script(blandat.nbs)) .unload -rs blandat.nbs
  if ($script(jpqosv.nbs)) .unload -rs jpqosv.nbs
  if ($script(raw.nbs)) .unload -rs raw.nbs
  if ($script(tema.nbs)) .unload -rs tema.nbs
  if ($script(dialog.nbs)) .unload -rs dialog.nbs
  if ($script(popups1.nbs)) .unload -rs popups1.nbs

  ; Disabling some aliases that are not used anymore.
  if ($alias(alias1.nbs)) { .unload -a alias1.nbs | echo -qg * Unloading alias1.nbs - all the aliases are moved to other files. }
  if ($alias(alias2.nbs)) { .unload -a alias2.nbs | echo -qg * Unloading alias2.nbs - all the aliases are moved to other files. }
  if ($alias(alias3.nbs)) { .unload -a alias3.nbs | echo -qg * Unloading alias3.nbs - all the aliases are moved to other files. }
  if ($script(main.nbs)) { .unload -rs main.nbs | echo -qg * Unloading main.nbs - the content is moved to other files. }

  ; This is just temporary, remove later :)
  if ($alias(alias1.mrc)) { .unload -a alias1.mrc | echo -qg * Unloading alias1.mrc - all the aliases are moved to other files. }
  if ($alias(alias2.mrc)) { .unload -a alias2.mrc | echo -qg * Unloading alias2.mrc - all the aliases are moved to other files. }
  if ($alias(alias3.mrc)) { .unload -a alias3.mrc | echo -qg * Unloading alias3.mrc - all the aliases are moved to other files. }

  n.checkscript aliases_divs.mrc -rs
  n.checkscript aliases.mrc -rs
  n.checkscript div_tools.mrc -rs
  n.checkscript main.mrc -rs
  n.checkscript popups.mrc -rs
  n.checkscript theme.mrc -rs
  n.checkscript system.mrc -rs
  n.checkscript raws.mrc -rs
  n.checkscript channelcentral.mrc -rs

  n.checkscript media.mrc -rs
  n.checkscript sysinfo.mrc -rs
  
  if (!$exists(scripts\ownstuff.mrc)) {
    .write scripts\ownstuff.mrc $chr(59) you can put your own scripts here, this file will not be overwritten when updating nbs-irc.
    .load -rs1 scripts\ownstuff.mrc
  }

  if (!$tname) .theme cold
}

alias -l n.checkscript {
  if ( %n.debug == 1 ) { echo 7 -atg * Debug: n.checkscript started File: $1- Arg: $2 }
  ; Check if the script is loaded, if not load it.
  if ($2 == -a) && (!$alias($1)) || ($2 == -rs) && (!$script($1)) {
    if ($exists(scripts\ $+ $1)) {
      if ( %n.debug == 1 ) echo 7 -atg * Debug: n.checkscript loading $1 Arg: $2
      .load [ $2 ] scripts\ $+ $1
    }
    else {
      if ($dialog(strt)) dialog -x strt
      set %f 1
      var %a = -age 4,4 $str(W,54)
      echo %a
      echo -ag * Error: file $mircdirscripts\ $+ $1 is missing, Replace the file and restart nbs or reinstall an update/full version.
      echo -ag * Note: installing updates will keep all settings, full reinstall will only keep nbs settings.
      echo %a
    }
  }
}

; Redo this, check github for updates

alias n.version return 2.43
alias n.version.date if ($read(scripts\other\version,1)) return $ifmatch

alias checkforupdates {
  set %nbs_vcheck 10
  unset %nbs_vcheck_date
  n.versioncheck
}
alias n.versioncheck {
  if ($ncfg(version_check) == 1) {
    %file = scripts\temp\v.txt
    if ($exists(%file)) && ($read(%file,1) > $n.version) .timer 1 30 n.versioncheck2
    elseif (%nbs_vcheck_date != $date) {
      if (%nbs_vcheck == 10) {
        n.download http://version.nbs-irc.net/v.txt
        .timer 1 30 n.versioncheck2
        set %nbs_vcheck_date $date
        unset %nbs_vcheck
      }
      else inc %nbs_vcheck 1
    }
  }
}
alias n.versioncheck2 {
  var %x = scripts\temp\v.txt
  if ($read(%x,3) == $md5(nbs)) && ($read(%x,1) isnum) && ($read(%x,1) > $n.version) {
    echo -ag 
    n.echo normal -ag A newer version of nbs-irc is available.
    if ($read(%x,2)) n.echo info -ag $ifmatch
    echo -ag 
  }
  else .remove %x
}
; End redo this