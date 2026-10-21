# Seeds declared OpenChamber settings into its data directory without taking
# the files over: a key the user's files already hold is left as it is.
#
# Usage: seed-settings <data-dir> <defaults.json>
# defaults.json: { profileKeys, profile, surfaces, instance }

dir=$1
defaults=$2
settings=$dir/settings.json
prefs=$dir/preferences.json

umask 077
mkdir -p "$dir"

settingsDoc='{}'
if [[ -e $settings ]] && ! settingsDoc=$(jq -ce 'if type == "object" then . else error end' "$settings" 2>/dev/null); then
  echo "openchamber: $settings is not a JSON object, not seeding it" >&2
  exit 0
fi

if [[ -e $prefs ]]; then
  if ! prefsDoc=$(jq -ce 'if type == "object" and .version == 1 and (.fields | type) == "object" then . else error end' "$prefs" 2>/dev/null); then
    echo "openchamber: $prefs is not a version-1 preferences document, not seeding it" >&2
    exit 0
  fi
else
  # Without preferences.json the server would seed it from the profile keys in
  # settings.json; creating it here has to carry those over the same way.
  prefsDoc=$(jq -cn --argjson s "$settingsDoc" --slurpfile d "$defaults" '
    (now * 1000 | floor) as $now
    | {
        version: 1,
        fields: ($s | with_entries(select(.key as $k | $d[0].profileKeys | index($k)))
          | map_values({ value: ., updatedAt: $now }))
      }')
fi

# A field the file already has, base or per-surface, wins as a whole.
newPrefs=$(jq --slurpfile d "$defaults" '
  (now * 1000 | floor) as $now
  | $d[0] as $d
  | ($d.profile | map_values({ value: ., updatedAt: $now })) as $base
  | (reduce ($d.surfaces | to_entries[]) as $s ({};
      reduce ($s.value | to_entries[]) as $f (.;
        .[$f.key].surfaces[$s.key] = { value: $f.value, updatedAt: $now }))) as $surfaces
  | .fields = (($base * $surfaces | map_values(.updatedAt //= 0)) + .fields)' <<<"$prefsDoc")

newSettings=$(jq --slurpfile d "$defaults" '$d[0].instance + .' <<<"$settingsDoc")

# Written next to the target and renamed, as OpenChamber itself does.
write_if_changed() {
  local file=$1 old=$2 new=$3
  if [[ -e $file ]] && [[ "$(jq -Sc . <<<"$old")" == "$(jq -Sc . <<<"$new")" ]]; then
    return
  fi
  printf '%s\n' "$new" >"$file.tmp-home-manager"
  mv "$file.tmp-home-manager" "$file"
}

write_if_changed "$settings" "$settingsDoc" "$newSettings"
write_if_changed "$prefs" "$prefsDoc" "$newPrefs"
