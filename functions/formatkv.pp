#
## Helper function that turns a section + key-value hash into
## systemd.unit section directives.
##
## Notes:
##   The section header is included in the output
##   Empty values are filtered out
##   Values of type ARRAY are converted to a space-separated string
##   If the first value presented for a directive is an empty string or the special string '__RESET__'
##   then the directive is reset by producing output of the form "Directive=". This syntax
##   is interpreted by systemd to reset the accumulation of values for this directive,
##   if applicable.
#
function systemd::formatkv($section,$h) {

  #
  ## Output section header and append one directive for each KV pair in
  ## the hash. Note: if hash is empty, no output is produced
  #
  $directives = $h.reduce([]) |$memo,$v| {
    $_v = [$v[1]].flatten
    $resetkey = (! empty($_v) and ($_v[0] == '' or $_v[0] == '__RESET__')) ? {
      true    => ["${v[0]}="],
      default => []
    }

    $s = $_v.filter |$a| { !empty($a) and $a != '__RESET__' }.join(' ')
    empty($s) ? { false => $memo + $resetkey + ["${v[0]}=${s}"], true => $memo + $resetkey}
  }

  if empty($directives) { return('') }

  ([ "[${section}]" ] + $directives).join("\n")

}
