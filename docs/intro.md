---
sidebar_position: 1
---

# Introduction
Welcome!
I assume you are reading this guide because you wish to develop some plugins for The Known Galaxy.
Great!
Then, let us get started.

## Running the Project
Basically everything you could need to do is achieved through a [Lune](https://lune-org.github.io/docs) Module.
There are 2 ways to run it:
1. Run `source .commands.sh` to get a terminal function setup that runs the module with the alias `plugins`. E.g.:
```
> source .commands.sh
> plugins
```
2. Just run `lune run main` every time you want to use. The above is faster for repeat usages. This one is faster for one off usages. E.g.:
```
> lune run main
```

Inside there are self-explanatory interactive options for:
1. Running unit tests
2. Running static analysis
3. Building the Studio testing place and the plugin itself (optionally to your local Studio plugin folder on your computer).
4. Automatically uploading any images the plugin uses to ROBLOX.
5. Deploying the plugin to the [Roblox Marketplace](https://create.roblox.com/store/asset/16915363791/TKG-The-Known-Tools).

## Development Workflow
Once you have started the studio (achieved by running `start build/place.rbxl`) and you are ready to work, go through the following steps:
1. Start the doc-site (if you haven't already) with `docsite` from `source .commands.sh`.
2. Ensure `Config.DevelopmentMode` is turned on inside `src/Config.luau` so that you get **hot reloading**, which ensures you don't have to constantly rebuild the Studio or manually save the files as a local plugin to see changes.
3. Start the rojo service with `rojo serve place.project.json` and connect to it from Studio.

## Creating New Modules
Now that you have your development environment setup and the plugin hot-reloading, you're ready to create a new module!
New modules are stored inside `src/PluginModules` as files with the name `YourSubModule.module.luau`.
That `.module` suffix is especially important since that's how the system detects that file as a possible submodule that it should try to load.
Once inside, use this snippet to create all the boilerplate for the new submodule:
```json
"Plugin SubModule": {
    "prefix": [
        "pluginsubmodule",
        "plugin",
        "submodule"
    ],
    "body": [
        "--!strict",
        "local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)",
        "local PluginFacade = require(script.Parent.Parent.PluginFacade)",
        "",
        "local ${TM_FILENAME_BASE/.module//g} = PluginSubModule.new({",
        "\tButtonIcon = nil,",
        "\tDisplayName = \"Name\",",
        "\tTooltip = \"Tooltip\",",
        "\tActiveByDefault = false,",
        "\tOneClickExecution = false,",
        "\tDevelopmentModule = false,",
        "})",
        "",
        "${TM_FILENAME_BASE/.module//g}:OnPreLoad(function(_pluginFacade: PluginFacade.PluginFacade)",
        "\treturn true",
        "end)",
        "",
        "${TM_FILENAME_BASE/.module//g}:OnPostLoad(function(_pluginFacade: PluginFacade.PluginFacade)",
        "\treturn true",
        "end)",
        "",
        "${TM_FILENAME_BASE/.module//g}:OnActivate(function(_pluginFacade: PluginFacade.PluginFacade)",
        "\treturn true",
        "end)",
        "",
        "${TM_FILENAME_BASE/.module//g}:OnDeactivate(function(_pluginFacade: PluginFacade.PluginFacade)",
        "\treturn true",
        "end)",
        "",
        "${TM_FILENAME_BASE/.module//g}:OnPreUnload(function(_pluginFacade: PluginFacade.PluginFacade)",
        "\treturn true",
        "end)",
        "",
        "return ${TM_FILENAME_BASE/.module//g}",
    ],
},
```
When working, make sure you pay attention to [Development Rules](Guides/development-rules).

Thanks for working towards making the lives of TKG developers just that little bit better...
> plugins Creator and Architect, [ShadowEngineer](https://github.com/ShadowEngineer)