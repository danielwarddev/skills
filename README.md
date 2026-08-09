# danielwarddev-skills

A collection of common .NET skills I currently use across my projects. Meant to be generalized enough to be able to drop in to any .NET project.

The skills are packaged as plugins. Since GitHub Copilot supports Claude Code conventions, they will work the same with GitHub Copilot CLI, GitHub Copilot in VS Code, and Claude Code.

## Plugins

### `dotnet-standards`

General .NET standards, meant to be generalized enough to drop in to any .NET project.

| Skill | Description |
| --- | --- |
| [csharp-standards](plugins/dotnet-standards/skills/csharp-standards/SKILL.md) | General C# standards for things like creating types, writing tests, project structure, and more. |
| [blazor-frontend](plugins/dotnet-standards/skills/blazor-frontend/SKILL.md) | Blazor Server front-end patterns, including component architecture, rendering performance, and bUnit component tests. |
| [mutation-testing](plugins/dotnet-standards/skills/mutation-testing/SKILL.md) | Runs Stryker.NET mutation tests and categorizes potential fixes into buckets based on priority. **Because xunit v3 currently does not work with Stryker, this skill will also duplicate an xunit v3 project using xunit v2 before running.** |

### `spec-workflow`

Two skills for how I do a spec-driven development workflow.

`spec-creation` creates specs that are divided up into subsections. The subsections are made with the heuristic of being able to be "completed within 5-10 minutes." I generally execute one subsection at a time, review the code and revise it as needed, then commit the changes and move on to the next subsection. 

Relatively, `spec-execution` is not extremely important, but helps to keep the AI on track with updating the spec files correctly and staying on topic.

| Skill | Description |
| --- | --- |
| [spec-creation](plugins/spec-workflow/skills/spec-creation/SKILL.md) | Creates user-story-driven feature specification markdown files. The specs are broken down into small subsections. |
| [spec-execution](plugins/spec-workflow/skills/spec-execution/SKILL.md) | Implements a subsection (or multiple subsections) of a spec file created with `spec-creation`. |

## Install

### GitHub Copilot in VS Code

Add the marketplace in `settings.json`, then browse `@agentPlugins` in the Extensions view:

```json
"chat.plugins.marketplaces": ["danielwarddev/skills"]
```

### GitHub Copilot CLI

```shell
copilot plugin marketplace add danielwarddev/skills
copilot plugin install dotnet-standards@danielwarddev-skills
copilot plugin install spec-workflow@danielwarddev-skills
```

You can do this from the CLI `/plugin marketplace add`
and `/plugin install`. VS Code also picks up plugins installed this way from
`~/.copilot/installed-plugins/`, so there's no need to install them twice.

### Claude Code

```
/plugin marketplace add danielwarddev/skills
/plugin install dotnet-standards@danielwarddev-skills
/plugin install spec-workflow@danielwarddev-skills
```

### Recommend plugins in a repo (Claude Code and Copilot in VS Code)

To have a repo recommend these plugins to anyone who opens it, add to its
`.claude/settings.json` or `.github/copilot/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "danielwarddev-skills": {
      "source": { "source": "github", "repo": "danielwarddev/skills" }
    }
  },
  "enabledPlugins": {
    "dotnet-standards@danielwarddev-skills": true,
    "spec-workflow@danielwarddev-skills": true
  }
}
```

This works with Claude Code and GitHub Copilot in VS Code. Copilot CLI can have per-repo plugins (see the [docs here](https://docs.github.com/en/copilot/concepts/agents/about-plugins#where-can-i-get-plugins)), but they do not recommend them to the user.

### Other - skill-portability-audit

There's another skill in this repo, `skill-portability-audit`, which is intentionally not included as a plugin. Its only purpose is to audit skills in this repo to make sure they're generalized (no real project/folder names, general examples instead of
project-specific ones, etc) before shipping.
