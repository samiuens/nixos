{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.git or { };
  providers = cfg.providers or { };
  signingEnabled = cfg.signing.enable or false;

  gitUserName = if (cfg.userName or null) != null then cfg.userName else "";
  gitUserEmail = if (cfg.userEmail or null) != null then cfg.userEmail else "";

  normalizeUserName = builtins.replaceStrings [ "." ] [ "_" ];
  sshDirectory = "${config.home.homeDirectory}/.ssh";
  sshKeysDirectory = "${sshDirectory}/keys";

  providerKeyPath =
    providerName: provider:
    "${sshKeysDirectory}/${providerName}/id_ed25519_${providerName}_${normalizeUserName provider.userName}";

  providerEntries = lib.mapAttrsToList (providerName: provider: {
    inherit provider providerName;
    keyPath = providerKeyPath providerName provider;
  }) providers;

  providerHosts = map (entry: entry.provider.host) providerEntries;

  providerSshSettings = lib.listToAttrs (
    map (
      entry:
      lib.nameValuePair entry.provider.host {
        HostName = entry.provider.host;
        User = "git";
        IdentityFile = entry.keyPath;
        IdentitiesOnly = true;
      }
    ) providerEntries
  );

  signingKeyPath = "${sshKeysDirectory}/signing/id_ed25519_git_signing_${config.home.username}";

  baselineSettings = {
    user.useConfigOnly = true;

    alias.unstage = "reset HEAD --";
    init.defaultBranch = "main";
    color.ui = true;

    push = {
      autoSetupRemote = true;
      default = "current";
    };

    pull.rebase = true;

    rebase = {
      autoStash = true;
      autoSquash = true;
    };

    diff = {
      algorithm = "histogram";
      colorMoved = "default";
    };

    merge.conflictStyle = "zdiff3";
    fetch.prune = true;
    rerere.enabled = true;
    branch.sort = "-committerdate";

    commit.verbose = true;
    help.autocorrect = "prompt";
    column.ui = "auto";
  };

  protectedSettings =
    lib.recursiveUpdate
      {
        user = {
          name = gitUserName;
          email = gitUserEmail;
        };
      }
      (
        lib.optionalAttrs signingEnabled {
          user.signingKey = "${signingKeyPath}.pub";
          gpg = {
            format = "ssh";
            ssh.program = lib.getExe' pkgs.openssh "ssh-keygen";
          };
          commit.gpgSign = true;
          tag.gpgSign = true;
        }
      );

  managedSettings = lib.recursiveUpdate (lib.recursiveUpdate baselineSettings (
    cfg.extraConfig or { }
  )) protectedSettings;

  ensureSshKey = pkgs.writeShellScript "ensure-git-ssh-key" ''
        set -eu

        if [ "$#" -ne 3 ]; then
          echo "usage: ensure-git-ssh-key PRIVATE_KEY COMMENT SSH_DIRECTORY" >&2
          exit 2
        fi

        private_key=$1
        expected_comment=$2
        ssh_directory=$3
        ssh_keys_directory="$ssh_directory/keys"
        public_key="$private_key.pub"
        key_directory="$(${lib.getExe' pkgs.coreutils "dirname"} -- "$private_key")"

        fail() {
          echo "Git SSH key error: $1" >&2
          exit 1
        }

        case "$private_key" in
          "$ssh_keys_directory"/*) ;;
          *) fail "$private_key is outside $ssh_keys_directory" ;;
        esac

        ${lib.getExe' pkgs.coreutils "install"} -d -m 0700 -- \
          "$ssh_directory" \
          "$ssh_keys_directory" \
          "$key_directory"

        for key_file in "$private_key" "$public_key"; do
          if [ -L "$key_file" ]; then
            fail "$key_file must not be a symbolic link"
          fi

          if [ -e "$key_file" ] && [ ! -f "$key_file" ]; then
            fail "$key_file exists but is not a regular file"
          fi
        done

        if [ -e "$private_key" ]; then
          ${lib.getExe' pkgs.coreutils "chmod"} 0600 -- "$private_key"

          generated_public="$(${lib.getExe' pkgs.openssh "ssh-keygen"} -y -f "$private_key")" \
            || fail "could not read private key $private_key"
          read -r generated_type generated_blob _ <<EOF
    $generated_public
    EOF

          if [ -e "$public_key" ]; then
            ${lib.getExe' pkgs.coreutils "chmod"} 0644 -- "$public_key"
            read -r existing_type existing_blob existing_comment < "$public_key" \
              || fail "could not read public key $public_key"

            if [ "$existing_type" != "$generated_type" ] || [ "$existing_blob" != "$generated_blob" ]; then
              fail "$public_key does not match $private_key"
            fi

            if [ "$existing_comment" != "$expected_comment" ]; then
              fail "$public_key has an unexpected comment; refusing to reuse a normalized key path"
            fi
          else
            temporary_public_key="$(${lib.getExe' pkgs.coreutils "mktemp"} "$public_key.tmp.XXXXXX")"
            cleanup() {
              ${lib.getExe' pkgs.coreutils "rm"} -f -- "$temporary_public_key"
            }
            trap cleanup EXIT

            printf '%s %s %s\n' "$generated_type" "$generated_blob" "$expected_comment" \
              > "$temporary_public_key"
            ${lib.getExe' pkgs.coreutils "chmod"} 0644 -- "$temporary_public_key"
            ${lib.getExe' pkgs.coreutils "mv"} -- "$temporary_public_key" "$public_key"
            trap - EXIT
          fi
        else
          if [ -e "$public_key" ]; then
            fail "$public_key exists without its private key"
          fi

          umask 077
          ${lib.getExe' pkgs.openssh "ssh-keygen"} \
            -q \
            -t ed25519 \
            -N "" \
            -C "$expected_comment" \
            -f "$private_key"
          ${lib.getExe' pkgs.coreutils "chmod"} 0600 -- "$private_key"
          ${lib.getExe' pkgs.coreutils "chmod"} 0644 -- "$public_key"
        fi
  '';

  keySpecifications =
    map (entry: {
      path = entry.keyPath;
      comment = "git-provider:${entry.providerName}:${entry.provider.userName}";
    }) providerEntries
    ++ lib.optional signingEnabled {
      path = signingKeyPath;
      comment = "git-signing:${config.home.username}";
    };

  keyGenerationCommands = lib.concatMapStringsSep "\n" (
    key:
    "$DRY_RUN_CMD ${ensureSshKey} ${
      lib.escapeShellArgs [
        key.path
        key.comment
        sshDirectory
      ]
    }"
  ) keySpecifications;
in
{
  config = lib.mkIf (cfg.enable or false) {
    assertions = [
      {
        assertion = gitUserName != "";
        message = "Git requires a non-empty per-user userName when enabled.";
      }
      {
        assertion = gitUserEmail != "";
        message = "Git requires a non-empty per-user userEmail when enabled.";
      }
      {
        assertion = lib.all (name: builtins.match "^[A-Za-z0-9_-]+$" name != null) (
          builtins.attrNames providers
        );
        message = "Git provider identifiers may contain only letters, numbers, underscores, and hyphens.";
      }
      {
        assertion = lib.all (entry: entry.provider.host != "") providerEntries;
        message = "Git provider hosts must not be empty.";
      }
      {
        assertion = lib.all (
          entry: builtins.match "^[A-Za-z0-9._-]+$" entry.provider.userName != null
        ) providerEntries;
        message = "Git provider usernames may contain only letters, numbers, dots, underscores, and hyphens.";
      }
      {
        assertion = lib.length providerHosts == lib.length (lib.unique providerHosts);
        message = "Git provider hosts must be unique.";
      }
    ];

    programs.git = {
      enable = true;
      settings = managedSettings;
    };

    programs.ssh = lib.mkIf (providerEntries != [ ]) {
      enable = true;
      enableDefaultConfig = false;
      settings = providerSshSettings;
    };

    home.activation.generateGitSshKeys = lib.mkIf (keySpecifications != [ ]) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] keyGenerationCommands
    );
  };
}
