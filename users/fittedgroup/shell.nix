{
  smi.system.users.users.fittedgroup.programs.shell = {
    eza.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      plugins = {
        autopair.enable = true;
        bang-bang.enable = true;
        done.enable = true;
        fzf.enable = true;
        sponge.enable = true;
      };
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$username$hostname$directory$git_branch$git_status$character";
        right_format = "$cmd_duration$nix_shell$nodejs$python$rust$golang$zig";
        username = {
          format = "[$user]($style)@";
          style_root = "bold red";
          style_user = "blue";
        };

        hostname = {
          format = "[$hostname]($style) ";
          ssh_only = true;
          style = "blue";
        };

        directory = {
          format = "[$path]($style) ";
          style = "bold blue";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
          style = "purple";
          symbol = " ";
        };

        git_status = {
          ahead = "↡";
          behind = "↣";
          conflicted = "=";
          deleted = "-";
          diverged = "⇕";
          format = "[($all_status$ahead_behind)]($style) ";
          modified = "~";
          renamed = "»";
          staged = "+";
          stashed = "*";
          style = "yellow";
          untracked = "?";
        };

        character = {
          error_symbol = "[❯](bold red) ";
          success_symbol = "[❯](bold green) ";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          min_time = 2000;
          style = "muted";
        };

        nix_shell = {
          format = "[$symbol$state]($style) ";
          style = "blue";
          symbol = " ";
        };

        nodejs = {
          format = "[$symbol$version]($style) ";
          style = "green";
          symbol = " ";
        };

        python = {
          format = "[$symbol$version]($style) ";
          style = "yellow";
          symbol = " ";
        };

        rust = {
          format = "[$symbol$version]($style) ";
          style = "red";
          symbol = " ";
        };

        golang = {
          format = "[$symbol$version]($style) ";
          style = "blue";
          symbol = " ";
        };

        zig = {
          format = "[$symbol$version]($style) ";
          style = "yellow";
          symbol = " ";
        };
      };
    };

    tmux = {
      enable = true;
      autoAttach = true;
      defaultSession = "main";
      keyMode = "vi";
      prefix = "C-b";
      statusPosition = "bottom";
      plugins = {
        continuum.enable = true;
        resurrect.enable = true;
        sessionx.enable = true;
      };
    };
  };
}
