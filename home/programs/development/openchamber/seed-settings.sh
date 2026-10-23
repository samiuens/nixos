# Seeds declared OpenChamber settings into its data directory without taking
# the files over: a key the user's files already hold is left as it is. The
# `override` keys are the exception and replace whatever the user picked.
#
# Usage: seed-settings <data-dir> <defaults.json>
# defaults.json: { profileKeys, profile, surfaces, instance,
#                  override: { profile, surfaces, instance } }

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

# Overrides win over the user's choice. A forced base also drops the user's
# per-surface values, which would beat it on that surface, unless one is
# declared too. Timestamps move only with a value, so a rerun changes nothing.
newPrefs=$(jq --slurpfile d "$defaults" '
  (now * 1000 | floor) as $now
  | $d[0].override as $o
  | (reduce ($o.surfaces | to_entries[]) as $s ({};
      reduce ($s.value | to_entries[]) as $f (.; .[$f.key][$s.key] = $f.value))) as $forced
  | reduce ($o.profile | to_entries[]) as $f (.;
      .fields[$f.key] |= (
        (if . != null and has("value") and .value == $f.value then .
         else (. // {}) + { value: $f.value, updatedAt: $now } end)
        | if .surfaces == null then .
          else .surfaces |= with_entries(select(.key as $s | ($forced[$f.key] // {}) | has($s)))
            | if .surfaces == {} then del(.surfaces) else . end
          end))
  | reduce ($forced | to_entries[]) as $k (.;
      reduce ($k.value | to_entries[]) as $s (.;
        .fields[$k.key].surfaces[$s.key] as $cur
        | if $cur != null and $cur.value == $s.value then .
          else .fields[$k.key].surfaces[$s.key] = { value: $s.value, updatedAt: $now } end))
  | .fields |= map_values(.updatedAt //= 0)' <<<"$newPrefs")

newSettings=$(jq --slurpfile d "$defaults" '$d[0].instance + . + $d[0].override.instance' <<<"$settingsDoc")

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
