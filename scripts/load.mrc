on *:load: { 
  n.checkfiles
}

alias n.checkfiles {
  set %f bug
  if ($script(blandat.nbs)) .unload -rs blandat.nbs
  if ($script(jpqosv.nbs)) .unload -rs jpqosv.nbs
  if ($script(raw.nbs)) .unload -rs raw.nbs
  if ($script(tema.nbs)) .unload -rs tema.nbs
  if ($script(dialog.nbs)) .unload -rs dialog.nbs
  if ($script(popups1.nbs)) .unload -rs popups1.nbs

  if ($alias(scripts\alias1.nbs)) .unload -a alias1.nbs | echo -qg * Unloading alias1.nbs - updating to alias1.mrc
  if ($alias(scripts\alias2.nbs)) .unload -a alias2.nbs | echo -qg * Unloading alias2.nbs - updating to alias2.mrc
  if ($alias(scripts\alias3.nbs)) .unload -a alias3.nbs | echo -qg * Unloading alias3.nbs - updating to alias3.mrc
  if ($script(scripts\main.nbs)) .unload -rs main.nbs | echo -qg * Unloading main.nbs - updating to main.mrc

  n.checkscript alias1.mrc -a
  n.checkscript alias2.mrc -a
  n.checkscript alias3.mrc -a

  n.checkscript main.mrc -rs
  n.checkscript system.mrc -rs
  n.checkscript aliases.mrc -rs

  if (!$exists(scripts\ownstuff.mrc)) {
    .write scripts\ownstuff.mrc $chr(59) you can put your own scripts here, this file will not be overwritten when updating nbs-irc.
    .load -rs1 scripts\ownstuff.mrc
  }
  if (!$tname) .theme cold
}

alias -l n.checkscript {
  ; Check if the script is loaded, if not load it.
  if ($2 == -a) && (!$alias($1)) || ($2 == -rs) && (!$script($1)) {
    if ($exists(scripts\ $+ $1)) {
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
