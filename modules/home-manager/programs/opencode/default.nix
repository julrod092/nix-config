{
  pkgs,
  lib,
  ...
}: let
  skillsCliPackage = "skills@1.5.10";
  defaultSkillAgents = ["opencode"];
  defaultStrict = false;
  disableTelemetry = true;
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
      source = "obra/superpowers";
      skills = [
        "brainstorming"
        "writing-plans"
        "executing-plans"
        "systematic-debugging"
        "requesting-code-review"
        "receiving-code-review"
        "verification-before-completion"
        "dispatching-parallel-agents"
        "using-git-worktrees"
        "finishing-a-development-branch"
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

  mkSkillCommand = {
    source,
    skill ? null,
    agents ? defaultSkillAgents,
    strict ? defaultStrict,
    fullDepth ? false,
  }: let
    command = lib.concatStringsSep " " (
      [
        (lib.optionalString disableTelemetry "DISABLE_TELEMETRY=1")
        "PATH=${lib.escapeShellArg skillRuntimePath}:$PATH"
        "${pkgs.nodejs_26}/bin/npx"
        "--yes"
        (lib.escapeShellArg skillsCliPackage)
        "add"
        (lib.escapeShellArg source)
        "--global"
        "--yes"
        "--copy"
      ]
      ++ lib.concatMap (agent: ["--agent" (lib.escapeShellArg agent)]) agents
      ++ lib.optionals (skill != null) ["--skill" (lib.escapeShellArg skill)]
      ++ lib.optionals fullDepth ["--full-depth"]
    );
    label =
      if skill == null
      then source
      else "${source}#${skill}";
  in
    if strict
    then command
    else ''
      if ! ${command}; then
        echo "warning: failed to install opencode skill ${lib.escapeShellArg label}" >&2
      fi
    '';

  mkSkillInstallCommands = install: let
    skills = install.skills or [];
    installWithoutSkill = builtins.removeAttrs install ["skills"];
  in
    if skills == []
    then [(mkSkillCommand installWithoutSkill)]
    else map (skill: mkSkillCommand (installWithoutSkill // {inherit skill;})) skills;
in {
  home.packages = with pkgs; [
    nodejs_26
    git
  ];

  home.activation.initOpenCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -f "''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.jsonc"

    ${lib.concatStringsSep "\n" (lib.concatMap mkSkillInstallCommands skillInstalls)}
  '';

  xdg.configFile."opencode/opencode.json".text = ''
    {"$schema":"https://opencode.ai/config.json"}
  '';

  programs.opencode = {
    enable = true;

    package = pkgs.unstable.opencode;

    skills = {
      sdd-ddd-architecture = ./skills/sdd-ddd-architecture;
    };

    tui = {
      theme = "tokyonight";
    };
  };
}
