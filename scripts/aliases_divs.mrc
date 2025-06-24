alias op mode # + $+ $str(o,$modespl) $$1 $2-
alias dop mode # - $+ $str(o,$modespl) $$1 $2-
alias voice mode # + $+ $str(v,$modespl) $$1 $2-
alias dvoice mode # - $+ $str(v,$modespl) $$1 $2-
alias k kick $$1 $2-
alias kb if ($2) !raw -q KICK $1-2 : $+ $3- $+ $crlf $+ MODE $1 +b $address($2,$ncfg(ban_mask))
alias bk if ($2) !raw -q MODE $1 -o+b $2 $address($2,$ncfg(ban_mask)) $+ $crlf $+ KICK $1-2 : $+ $3-
alias j join $$1-
alias q query $$1-
alias p part # $1-
alias n names #$$1
alias w whois $$1
alias ws whois2 $$1
alias f2 setup
alias f3 n.fkey F3
alias f4 n.fkey F4
alias f5 n.fkey F5
alias f6 if ($me ison %banchan) && (%banchan == $active) && (%banmode) && (%banmask) mode %banchan %banmode %banmask
alias f7 n.fkey F7
alias f8 n.fkey F8
alias f9 n.fkey F9
alias f10 n.fkey F10
alias f11 n.fkey F11
alias f12 n.fkey F12
alias qw if ($n.qnet) msg Q whois $$1
alias t topic $iif($chr(35) !isin $1,$active) $1-
alias n.checkkey if ($chan($1).key) set %pw. [ $+ [ $1 ] ] $chan($1).key
alias q query $$1 $2-
alias send dcc send $$1 $2
alias chat dcc chat $$1
alias ping ctcp $$1 ping
alias about aboutnbs
alias aboutnbs dlg om
alias autocon dlg autocon
alias quakenet dlg qnet
alias undernet dlg unet
alias misc gen
alias gen dlg misc
alias seekcw dlg pcw
alias prot dlg skydd
alias cns dlg ns
alias paste { set %paste.target $active | dlg paste }
alias gl g-join $1-
alias faq n.url http://www.nbs-irc.net/faq
alias back if ($away) dlg back
alias n.rejoin if ($me !ison $1) join -n $1-
alias ad { me is using $strip($n.name) $n.version (theme: $tname $+ ) - www.nbs-irc.net }
alias n.mdx dll $cit(scripts\dll\mdx\mdx.dll) $1-
alias n.mdxv return scripts\dll\mdx\views.mdx
alias clr return $+(,$color($1),$2,)
alias leet { say $replace($1-,a,4,e,3,i,1,s,5,g,6,t,7,o,00,ä,'a',ö,'o') }
alias psljud { splay $+(",$mircdirscripts\qry.wav,") }
alias sendsong mp3send $1-
alias wsend mp3send $1-
alias n.name return nbs-irc