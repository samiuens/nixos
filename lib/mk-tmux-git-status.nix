_:

# Status-line helper that prints the current branch of a directory, suffixed
# with an asterisk when the worktree is dirty. Shared by every tmux theme.
pkgs:
pkgs.writeShellApplication {
  name = "tmux-git-status";
  runtimeInputs = [ pkgs.git ];
  text = ''
    directory="''${1:-}"

    if ! git -C "$directory" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exit 0
    fi

    branch=$(
      git -C "$directory" symbolic-ref --quiet --short HEAD 2>/dev/null \
        || git -C "$directory" rev-parse --short HEAD 2>/dev/null
    ) || exit 0

    if test -n "$(git -C "$directory" status --porcelain=v1 2>/dev/null)"; then
      printf ' %s *' "$branch"
    else
      printf ' %s' "$branch"
    fi
  '';
}
