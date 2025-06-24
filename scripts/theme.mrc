; Edit theme
alias tedit {
  if ($1) set %tedit $1-
  else set %tedit $left($nopath($isalias(ttimestamp).fname),-4)
  dlg tedit
}

alias n.color.reset {
  if ($color(0) != 16777215) { color -r 0 }
  if ($color(1) != 0) { color -r 1 }
  if ($color(2) != 8323072) { color -r 2 }
  if ($color(3) != 37632) { color -r 3 }
  if ($color(4) != 255) { color -r 4 }
  if ($color(5) != 127) { color -r 5 }
  if ($color(6) != 10223772) { color -r 6 }
  if ($color(7) != 32764) { color -r 7 }
  if ($color(8) != 65535) { color -r 8 }
  if ($color(9) != 64512) { color -r 9 }
  if ($color(10) != 9671424) { color -r 10 }
  if ($color(11) != 16776960) { color -r 11 }
  if ($color(12) != 16515072) { color -r 12 }
  if ($color(13) != 16711935) { color -r 13 }
  if ($color(14) != 8355711) { color -r 14 }
  if ($color(15) != 13816530) { color -r 15 }
}

alias byt-tema {
  if (!$1) || (($nopath($isalias(ttimestamp).fname) == $1 $+ .tem) && (!%poaksdfopka)) { return }
  if (!$exists($cit($scriptdirtema\ $+ $1- $+ .tem))) { n.echo normal -atg $scriptdirtema\ $+ $1- $+ .tem does not exist | return }  
  if (!$dialog(bt)) { dialog -m bt bt | did -a bt 1 Loading theme }  
  if (!$exists($cit($isalias(ttimestamp).fname))) { 
    dialog -x bt
    return
  }
  var %ticks $ticks
  if ($isalias(tname).fname) .unload -rs $cit($isalias(tname).fname)
  .load -rs $cit($scriptdirtema\ $+ $1- $+ .tem)
  .timestamp -f $n.timestamp
  cnicks
  n.color.reset
  tclr
  color treebar $color(background)
  if ($ncfg(use_theme_fonts) == 1) {
    if ($tfont) fc $tfont
    else fc 11 tahoma
  }
  dialog -x bt
  if (!%poaksdfopka) n.echo normal -atgq Theme: $tname loaded $par(Ctrl+F12: clear all windows) $iif(%ticks,$par($calc(($ticks - %ticks) / 1000) $+ s))
  if (%generatepreview) {
    .remove $scriptdirtema\$1 $+ . *
    n.genpreview $1
  }
  elseif (!$exists($+(",$scriptdirtema\,$1,.png,"))) && (!$exists($+(",$scriptdirtema\,$1,.bmp,"))) n.genpreview $1
  unset %generatepreview %poaksdfopka
}
alias theme.finished return
alias theme.reset return
dialog bt {
  title "nbs-irc"
  size -1 -1 50 10
  option dbu
  text "", 1, 1 6 50 7, center
  button "-", 2, 300 300 30 10, disable ok
}
On *:dialog:bt:init:0:{
  n.mdx SetMircVersion $version
  n.mdx MarkDialog $dname
  n.mdx SetDialog $dname style dlgframe
}
alias cnicks {
  if ($ncfg(nicklist_use_themed_colors) != 1) return
  .cnick -r * @
  .cnick -r * +
  .cnick -nr *
  .cnick -m2 $!me $me.clr
  .cnick -m2 * $op.clr @
  .cnick -m2 * $voice.clr +
  .cnick -nm2 * $normal.clr
}
alias n.quote {
  if ($1) {
    if ($quote.style) return $replace($quote.style,<text>,$1- $+ ) $+ 
    else return ' $+ $1- $+ '
  }
}

alias par if ($1) return $replace($par.style,<text>,$1- $+ ) $+ 
alias kl if ($1) return $replace($bracket.style,<text>,$1- $+ ) $+ 
alias kl: if ($1) return $replace($bracket.style,<text>,$1- $+ ) $+ :
alias n.timestamp return $ttimestamp $+ $iif($right($ttimestamp,1) != ,)
alias npre return $pre $+ 
alias color_gen {
  if (!$1) {
    var %f = temp.txt
    .write -c temp.txt
  }
  if ($color(0) != 16777215) .write %f color 0 $color(0)
  if ($color(1) != 0) .write %f color 1 $color(1)
  if ($color(2) != 8323072) .write %f color 2 $color(2)
  if ($color(3) != 37632) .write %f color 3 $color(3)
  if ($color(4) != 255) .write %f color 4 $color(4)
  if ($color(5) != 127) .write %f color 5 $color(5)
  if ($color(6) != 10223772) .write color 6 %f $color(6)
  if ($color(7) != 32764) .write %f color 7 $color(7)
  if ($color(8) != 65535) .write %f color 8 $color(8)
  if ($color(9) != 64512) .write %f color 9 $color(9)
  if ($color(10) != 9671424) .write %f color 10 $color(10)
  if ($color(11) != 16776960) .write %f color 11 $color(11)
  if ($color(12) != 16515072) .write %f color 12 $color(12)
  if ($color(13) != 16711935) .write %f color 13 $color(13)
  if ($color(14) != 8355711) .write %f color 14 $color(14)
  if ($color(15) != 13816530) .write %f color 15 $color(15)
  .write %f color action text $color(action)
  .write %f color ctcp text $color(ctcp)
  .write %f color info text $color(info)
  .write %f color info2 text $color(info2)
  .write %f color highlight text $color(highlight)
  .write %f color invite text $color(invite)
  .write %f color join text $color(join)
  .write %f color kick text $color(kick)
  .write %f color mode text $color(mode)
  .write %f color nick text $color(nick)
  .write %f color normal text $color(normal)
  .write %f color notice text $color(notice)
  .write %f color notify text $color(notify)
  .write %f color other text $color(info)
  .write %f color own text $color(own)
  .write %f color part text $color(part)
  .write %f color quit text $color(quit)
  .write %f color topic text $color(topic)
  .write %f color wallops text $color(wallops)
  .write %f color whois text $color(whois)
  .write %f color listbox $color(listbox)
  .write %f color listbox text $color(listbox text)
  .write %f color title text $color(title)
  .write %f color editbox text $color(editbox text)
  .write %f color inactive $color(inactive)
  .write %f color background $color(background)
  .write %f color editbox $color(editbox)
  .write %f color treebar text $color(treebar text)
  if (%f == temp.txt) {
    if ($dialog(tedit)) loadbuf -o tedit 3 temp.txt
    else run %f
    .timer 1 1 .remove %f
  }
}
alias pretimestamp {
  return $replace($ttimestamp,HH,$1,nn,$2,ss,$3)
}
alias n.genpreview {
  var %font = $window(status window).font, %size = $window(status window).fontsize
  window -k0dnhp +dl @tp -1 -1 386 210
  drawtext -p @tp $color(join) %font %size 3 0 $pretimestamp($time(HH),$time(nn),10) $npre Join: elof $par(~mjo@h10v2ftb31p876.com)
  drawtext -p @tp $color(mode) %font %size 3 14 $pretimestamp($time(HH),$time(nn),10) $npre Q $par(+v) elof
  drawtext -p @tp $color(own) %font %size 3 28 $pretimestamp($time(HH),$time(nn),13) $replace($me.style,<mode>,@,<nick>,Yngve) $+  hello
  drawtext -p @tp $color(normal) %font %size 3 42 $pretimestamp($time(HH),$time(nn),15) $replace($nick.style,<mode>,+,<nick>,elof) $+  hi
  drawtext -p @tp $color(nick) %font %size 3 56 $pretimestamp($time(HH),$time(nn),17) $npre $clr(high,nick) is now known as $clr(high,nick-afk)
  drawtext -p @tp $color(normal) %font %size 3 70 $pretimestamp($time(HH),$time(nn),20) $replace($nick.style,<mode>,+,<nick>,elof) $+  where's albin?
  drawtext -p @tp $color(normal) %font %size 3 84 $pretimestamp($time(HH),$time(nn),23) $replace($nick.style,<mode>,,<nick>,albin) $+  here
  drawtext -p @tp $color(normal) %font %size 3 98 $pretimestamp($time(HH),$time(nn),25) $replace($nick.style,<mode>,+,<nick>,elof) $+  ok, pm
  drawtext -p @tp $color(normal) %font %size 3 112 $pretimestamp($time(HH),$time(nn),26) $replace($nick.style,<mode>,@,<nick>,karl-bertil) $+  bla bla
  drawtext -p @tp $color(part) %font %size 3 126 $pretimestamp($time(HH),$time(nn),30) $npre Part: ingvar $par(id@h140z26ls35a876.net)
  drawtext -p @tp $color(topic) %font %size 3 140 $pretimestamp($time(HH),$time(nn),33) $npre Yngve changes topic to: Preview
  drawtext -p @tp $color(join) %font %size 3 154 $pretimestamp($time(HH),$time(nn),35) $npre Join: billythekid $par(~lame@455-b17ch.cbh.com)
  drawtext -p @tp $color(normal) %font %size 3 168 $pretimestamp($time(HH),$time(nn),39) $replace($nick.style,<mode>,,<nick>,billythekid) $+  Hello, is this the preview channel?
  drawtext -p @tp $color(own) %font %size 3 182 $pretimestamp($time(HH),$time(nn),42) $replace($me.style,<mode>,@,<nick>,Yngve) $+  Yes it is.
  drawtext -p @tp $color(quit) %font %size 3 196 $pretimestamp($time(HH),$time(nn),44) $npre Quit: Random $par(id@c-d7bd70d5.com) $par(Signed off)
  drawsave -b24 @tp $qt($scriptdirtema\ $+ $left($nopath($isalias(tname).fname),-4) $+ .bmp)
  close -@ @tp
  n.echo other -stge Preview for $tname generated
}
