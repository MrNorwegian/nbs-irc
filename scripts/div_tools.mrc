alias n.download {
  if (!$sock(n.download)) && ($1) {
    var %url = $remove($1,http://)
    var %host = $gettok(%url,1,47), %fil = / $+ $gettok(%url,2-,47)
    if ($crc(scripts\temp\ $+ $nopath(%fil)) > 0) set %crc. [ $+ [ $nopath(%fil) ] ] $ifmatch
    sockopen n.download %host 80
    sockmark n.download HEAD %host %fil
  }
}
alias n.file { return $replace($1-,?,_,/_,\_,*,_,:,_,<,_,>,_,",_,|,_) }
alias n.useragent return $+($strip($n.name),/,$n.version) (r: $n.version.date $+ , m: $version $+ , w: $os $+ , t: $tname $+ )

on *:SOCKOPEN:n.download:{
  if (!$sockerr) { 
    write -c scripts\temp\ $+ $n.file($nopath($gettok($sock($sockname).mark,3,32)))
    sockwrite -n $sockname GET $gettok($sock($sockname).mark,3,32) HTTP/1.1
    sockwrite -n $sockname HOST: $gettok($sock($sockname).mark,2,32)
    sockwrite -n $sockname User-Agent: $n.useragent
    sockwrite -n $sockname Accept: text/plain
    sockwrite -n $sockname $crlf
  }
}

on *:SOCKREAD:n.download:{
  if (!$sockerr) {
    var %head
    :start
    if ($gettok($sock($sockname).mark,1,32) == head) { sockread %head }
    else { sockread &b }
    if ($sockbr) {
      if ($gettok($sock($sockname).mark,1,32) == head) {
        if (http/?.? iswm $gettok(%head,1,32)) && ($gettok(%head,2,32) != 200) {
          return
        }
        elseif (!%head) sockmark $sockname GET $gettok($sock($sockname).mark,2-,32)
      }
      elseif ($gettok($sock($sockname).mark,1,32) == get) {
        bwrite scripts\temp\ $+ $n.file($nopath($gettok($sock($sockname).mark,3,32))) -1 &b
      }
      goto start
    }
  }
}

; Idea by AI, sockclose 