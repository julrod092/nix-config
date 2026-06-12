{
  pkgs,
  lib,
  ...
}: let
  skillsCliPackage = "skills@1.5.10";
  defaultSkillAgents = ["opencode"];
  defaultStrict = false;
  disableTelemetry = true;
  updateIntervalSeconds = 86400;
  skillRuntimePath = lib.makeBinPath [pkgs.git pkgs.nodejs_26];

  skillInstalls = [
    {
      source = "personamanagmentlayer/pcl";
      skills = ["scala-expert"];
    }
    {
      source = "rmyndharis/antigravity-skills";
      skills = ["scala-pro"];
    }
    {
      source = "thebushidocollective/han";
      skills = ["Scala Functional Patterns"];
    }
    {
      source = "anthropics/skills";
      skills = ["frontend-design"];
    }
    {
      source = "obra/superpowers";
      skills = [
        "brainstorming"
        "writing-plans"
        "executing-plans"
        "systematic-debugging"
        "receiving-code-review"
        "verification-before-completion"
        "dispatching-parallel-agents"
      ];
    }
    {
      source = "mattpocock/skills";
      skills = [
        "improve-codebase-architecture"
        "grill-me"
        "grill-with-docs"
        "diagnose"
        "triage"
      ];
    }
  ];

  mkSkillSyncCommand = {
    source,
    skill ? null,
    agents ? defaultSkillAgents,
    strict ? defaultStrict,
    fullDepth ? false,
  }: let
    label =
      if skill == null
      then source
      else "${source}#${skill}";
    skillArg =
      if skill == null
      then ""
      else skill;
    agentsCsv = lib.concatStringsSep "," agents;
  in ''
    sync_skill ${lib.escapeShellArg source} ${lib.escapeShellArg skillArg} ${lib.escapeShellArg agentsCsv} ${
      if fullDepth
      then "1"
      else "0"
    } ${
      if strict
      then "1"
      else "0"
    } ${lib.escapeShellArg label}
  '';

  mkSkillInstallCommands = install: let
    skills = install.skills or [];
    installWithoutSkill = builtins.removeAttrs install ["skills"];
  in
    if skills == []
    then [(mkSkillSyncCommand installWithoutSkill)]
    else map (skill: mkSkillSyncCommand (installWithoutSkill // {inherit skill;})) skills;

  opencodeSyncSkills = pkgs.writeShellApplication {
    name = "opencode-sync-skills";
    runtimeInputs = with pkgs; [coreutils findutils gawk git gnugrep gnused nodejs_26];
    text = ''
      force=0

      for arg in "$@"; do
        case "$arg" in
          --force)
            force=1
            ;;
          *)
            echo "usage: opencode-sync-skills [--force]" >&2
            exit 2
            ;;
        esac
      done

      config_home="$HOME/.config"
      if [[ -n "''${XDG_CONFIG_HOME:-}" ]]; then
        config_home="$XDG_CONFIG_HOME"
      fi

      state_dir="$config_home/opencode/skill-sync"
      skills_dir="$HOME/.agents/skills"
      skills_cli_package=${lib.escapeShellArg skillsCliPackage}
      update_interval_seconds=${toString updateIntervalSeconds}
      mkdir -p "$state_dir"

      declare -A remote_revs
      declare -A active_state_ids

      slugify() {
        printf '%s' "$1" \
          | tr '[:upper:]' '[:lower:]' \
          | sed 's/[^a-z0-9._-]\+/-/g; s/^-//; s/-$//'
      }

      skill_installed() {
        local skill="$1"
        local slug

        [[ -n "$skill" ]] || return 1
        [[ -d "$skills_dir" ]] || return 1

        slug="$(slugify "$skill")"
        [[ -f "$skills_dir/$slug/SKILL.md" ]]
      }

      get_remote_rev() {
        local source="$1"
        local rev

        if [[ -v "remote_revs[$source]" ]]; then
          printf '%s\n' "''${remote_revs[$source]}"
          [[ -n "''${remote_revs[$source]}" ]]
          return
        fi

        if rev="$(git ls-remote "https://github.com/$source.git" HEAD 2>/dev/null | awk '{print $1; exit}')" && [[ -n "$rev" ]]; then
          remote_revs[$source]="$rev"
          printf '%s\n' "$rev"
          return 0
        fi

        remote_revs[$source]=""
        return 1
      }

      save_state() {
        local state_file="$1"
        local config_signature="$2"
        local remote_rev="$3"
        local last_check="$4"
        local managed_source="$5"
        local managed_skill="$6"
        local managed_skill_slug="$7"
        local managed_label="$8"

        {
          printf 'CONFIG_SIGNATURE=%q\n' "$config_signature"
          printf 'REMOTE_REV=%q\n' "$remote_rev"
          printf 'LAST_CHECK=%q\n' "$last_check"
          printf 'MANAGED_SOURCE=%q\n' "$managed_source"
          printf 'MANAGED_SKILL=%q\n' "$managed_skill"
          printf 'MANAGED_SKILL_SLUG=%q\n' "$managed_skill_slug"
          printf 'MANAGED_LABEL=%q\n' "$managed_label"
        } > "$state_file"
      }

      install_skill() {
        local source="$1"
        local skill="$2"
        local agents_csv="$3"
        local full_depth="$4"
        local strict="$5"
        local label="$6"
        local state_file="$7"
        local config_signature="$8"
        local remote_rev="$9"
        local now="''${10}"
        local skill_slug="''${11}"
        local cmd
        local agents
        local agent

        echo "opencode skill sync: installing $label" >&2

        cmd=("${pkgs.nodejs_26}/bin/npx" --yes "$skills_cli_package" add "$source" --global --yes --copy)

        IFS=',' read -r -a agents <<< "$agents_csv"
        for agent in "''${agents[@]}"; do
          [[ -n "$agent" ]] || continue
          cmd+=(--agent "$agent")
        done

        if [[ -n "$skill" ]]; then
          cmd+=(--skill "$skill")
        fi

        if [[ "$full_depth" == "1" ]]; then
          cmd+=(--full-depth)
        fi

        if ${lib.optionalString disableTelemetry "DISABLE_TELEMETRY=1"} PATH=${lib.escapeShellArg skillRuntimePath}:$PATH "''${cmd[@]}"; then
          if [[ -z "$remote_rev" ]]; then
            remote_rev="$(get_remote_rev "$source" || true)"
          fi
          save_state "$state_file" "$config_signature" "$remote_rev" "$now" "$source" "$skill" "$skill_slug" "$label"
          return 0
        fi

        if [[ "$strict" == "1" ]]; then
          return 1
        fi

        echo "warning: failed to install opencode skill $label" >&2
        return 0
      }

      sync_skill() {
        local source="$1"
        local skill="$2"
        local agents_csv="$3"
        local full_depth="$4"
        local strict="$5"
        local label="$6"
        local config_identity
        local config_signature
        local state_key
        local state_id
        local state_file
        local skill_slug
        local now
        local remote_rev
        local last_check

        config_identity="$source|$skill|$agents_csv|$full_depth|$skills_cli_package"
        config_signature="$(printf '%s' "$config_identity" | sha256sum | awk '{print $1}')"
        if [[ -n "$skill" ]]; then
          state_key="$skill"
        else
          state_key="$source"
        fi
        state_id="$(printf '%s' "$state_key" | sha256sum | awk '{print $1}')"
        state_file="$state_dir/$state_id.env"
        skill_slug="$(slugify "$state_key")"
        active_state_ids[$state_id]=1
        now="$(date +%s)"

        CONFIG_SIGNATURE=""
        REMOTE_REV=""
        LAST_CHECK=0
        MANAGED_SOURCE=""
        MANAGED_SKILL=""
        MANAGED_SKILL_SLUG=""
        MANAGED_LABEL=""

        if [[ -f "$state_file" ]]; then
          # shellcheck disable=SC1090
          source "$state_file"
        fi

        if [[ -n "$skill" ]] && ! skill_installed "$skill"; then
          install_skill "$source" "$skill" "$agents_csv" "$full_depth" "$strict" "$label" "$state_file" "$config_signature" "$(get_remote_rev "$source" || true)" "$now" "$skill_slug"
          return
        fi

        if [[ -f "$state_file" && "$CONFIG_SIGNATURE" != "$config_signature" ]]; then
          install_skill "$source" "$skill" "$agents_csv" "$full_depth" "$strict" "$label" "$state_file" "$config_signature" "$(get_remote_rev "$source" || true)" "$now" "$skill_slug"
          return
        fi

        if [[ ! -f "$state_file" ]]; then
          save_state "$state_file" "$config_signature" "$(get_remote_rev "$source" || true)" "$now" "$source" "$skill" "$skill_slug" "$label"
          return
        fi

        if [[ "$MANAGED_SOURCE" != "$source" || "$MANAGED_SKILL" != "$skill" || "$MANAGED_SKILL_SLUG" != "$skill_slug" || "$MANAGED_LABEL" != "$label" ]]; then
          save_state "$state_file" "$config_signature" "$REMOTE_REV" "$LAST_CHECK" "$source" "$skill" "$skill_slug" "$label"
        fi

        last_check="$LAST_CHECK"
        if ! [[ "$last_check" =~ ^[0-9]+$ ]]; then
          last_check=0
        fi

        if (( force == 1 || now - last_check >= update_interval_seconds )); then
          remote_rev="$(get_remote_rev "$source" || true)"

          if [[ -z "$remote_rev" ]]; then
            echo "warning: failed to check opencode skill source $source" >&2
            save_state "$state_file" "$config_signature" "$REMOTE_REV" "$now" "$source" "$skill" "$skill_slug" "$label"
            return
          fi

          if [[ "$remote_rev" != "$REMOTE_REV" ]]; then
            install_skill "$source" "$skill" "$agents_csv" "$full_depth" "$strict" "$label" "$state_file" "$config_signature" "$remote_rev" "$now" "$skill_slug"
            return
          fi

          save_state "$state_file" "$config_signature" "$REMOTE_REV" "$now" "$source" "$skill" "$skill_slug" "$label"
        fi
      }

      prune_removed_skills() {
        local state_file
        local state_id
        local skill_path

        shopt -s nullglob
        for state_file in "$state_dir"/*.env; do
          state_id="$(basename "$state_file" .env)"

          if [[ -v "active_state_ids[$state_id]" ]]; then
            continue
          fi

          MANAGED_SOURCE=""
          MANAGED_SKILL=""
          MANAGED_SKILL_SLUG=""
          MANAGED_LABEL=""

          # shellcheck disable=SC1090
          source "$state_file"

          if [[ -z "$MANAGED_SKILL_SLUG" ]]; then
            rm -f -- "$state_file"
            continue
          fi

          skill_path="$skills_dir/$MANAGED_SKILL_SLUG"
          if [[ -d "$skill_path" ]]; then
            echo "opencode skill sync: removing unmanaged skill ''${MANAGED_LABEL:-$MANAGED_SKILL}" >&2
            rm -rf -- "$skill_path"
          fi

          rm -f -- "$state_file"
        done
        shopt -u nullglob
      }

      ${lib.concatStringsSep "\n" (lib.concatMap mkSkillInstallCommands skillInstalls)}
      prune_removed_skills
    '';
  };
in {
  home.packages = [opencodeSyncSkills];

  home.activation.initOpenCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -f "''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.jsonc"

    ${opencodeSyncSkills}/bin/opencode-sync-skills
  '';

  programs.mcp = {
    enable = true;

    servers = {
      jira = {
        url = "https://mcp.atlassian.com/v1/mcp/authv2";
      };

      chrome-devtools = {
        command = "npx";
        args = ["-y" "chrome-devtools-mcp@latest"];
      };
    };
  };

  programs.opencode = {
    enable = true;

    package = pkgs.unstable.opencode;
    enableMcpIntegration = true;

    extraPackages = [pkgs.nodejs_26];

    skills = {};

    tui = {
      theme = "tokyonight";
    };
  };
}
