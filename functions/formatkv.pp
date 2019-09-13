#
## Helper function that turns a section + key-value hash into
## systemd.unit section directives.
##
## Notes:
##   The section header is included in the output
##   Empty values are filtered out
##   Values of type ARRAY are converted to a space-separated string
#
function systemd::formatkv($section,$h) {

  #
  ## Output section header and append one directive for each KV pair in
  ## the hash. Note: if hash is empty, no output is produced
  #
  $directives = $h.reduce('') |$memo,$v| {
    $s = [$v[1]].flatten.filter |$a| { !empty($a) }.join(' ')
    empty($s) ? { false => "${memo}\n${v[0]}=${s}", true => $memo }
  }

  if empty($directives) { return('') }

  "[${section}]${directives}"

}
