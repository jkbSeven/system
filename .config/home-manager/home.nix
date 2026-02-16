{ config, pkgs, ... }:

{
	home.username = "jkb";
	home.homeDirectory = "/home/jkb";

	home.stateVersion = "25.11";

	programs.home-manager.enable = true;

	nixpkgs.config.allowUnfreePredicate = pkg:
		builtins.elem (pkgs.lib.getName pkg) [
			"obsidian"
		];

	home.packages = with pkgs; [
		git
		neovim
		zsh
		bat
		tmux
		obsidian
		fd  # for neovim plugins
		ripgrep  # for neovim plugins
		tree-sitter  # for neovim
	];

	programs.zsh = {
		enable = true;
		shellAliases = {
			hm = "home-manager switch --flake ~/.config/home-manager#jkb";
			gs = "git status";
			l = "ls -la";
			vim = "nvim";
		};
	};

	programs.zsh.oh-my-zsh = {
		enable = true;
		plugins = [ "git" ];
		theme = "robbyrussell";
	};

	programs.git = {
		enable = true;
		settings.user.name = "jkbSeven";
		settings.user.email = "Jacob202@protonmail.com";
	};

	wayland.windowManager.hyprland = {
		enable = true;
		package = null;
		portalPackage = null;

		settings = {
			"$mod" = "SUPER";

			"$terminal" = "alacritty";
			"$fileManager" = "dolphin";
			"$menu" = "wofi";

			monitor = [
				"DP-3, highrr, auto, 1" # use `hyprctl monitors` to find the display ID
				", preferred, auto, 1" # for ad-hoc monitors, preferred resolution, placed on the right side of main monitor
			];

			bind = [
				"$mod, Q, killactive"
				"$mod, T, exec, $terminal"
				"$mod, F, exec, $fileManager"
				"$mod, W, exec, firefox"
				"$mod, D, exec, wofi --show run"
			]
			++ (
			# workspaces
			# binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
			builtins.concatLists (builtins.genList (i:
				let ws = i + 1;
				in [
					"$mod, code:1${toString i}, workspace, ${toString ws}"
					"$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
				]
				)
				9)
			);

			general = {
				gaps_in = 5;
				gaps_out = 10;
				border_size = 1;
			};

			input = {
				accel_profile = "flat";
				# force_no_accel = true; # not recommended in Hyprland docs
				sensitivity = 0;
			};
		};
	};
}
