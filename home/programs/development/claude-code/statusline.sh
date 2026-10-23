# Claude Code status line: reads the session JSON on stdin and prints the
# model and effort, then the context fill and the plan's usage limits.
# Fields Claude Code has not sent yet are skipped.

jq -r '
  def esc(code): "\u001b[\(code)m";
  def tone(p): if p >= 80 then esc(31) elif p >= 50 then esc(33) else esc(32) end;
  def clamp: if . < 0 then 0 elif . > 100 then 100 else floor end;
  def percent(p): tone(p) + "\(p)%" + esc(0);
  def bar(p): (p / 10 | floor) as $filled
    | tone(p) + ("▓" * $filled // "") + esc(2) + ("░" * (10 - $filled) // "") + esc(0);
  def sep: esc(2) + " · " + esc(0);

  ([.model.display_name // "Claude", (.effort.level // empty)] | join(sep)),
  ([
    (.context_window.used_percentage // empty | clamp | "\(bar(.)) \(percent(.))"),
    (.rate_limits.five_hour // empty
      | (.used_percentage | clamp) as $p
      | "5h \(percent($p))"
        + (.resets_at // empty | esc(2) + " ↻ " + strflocaltime("%H:%M") + esc(0))),
    (.rate_limits.seven_day.used_percentage // empty | clamp | "7d \(percent(.))")
  ] | join(sep) | select(. != ""))
'
