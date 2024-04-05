"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4463],{17862:e=>{e.exports=JSON.parse('{"functions":[{"name":"Setup","desc":"Sets up the PluginFacade module.\\nAlthough not a traditional \\"constructor\\" that most Object Classes have in OOP, it sets up the rest of the module.\\n\\n:::warning\\nCall this before any other methods! Otherwise, undefined or erroneous behaviour might occur.\\n:::","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"settings","desc":"","lua_type":"PluginFacadeSetupSettings"}],"returns":[],"function_type":"static","tags":["methods","constructor"],"since":"v0.1.0","source":{"line":188,"path":"src/PluginFacade.luau"}},{"name":"CreateToolbar","desc":"Hot-reload-safe wrapper for [Plugin:CreateToolbar].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"PluginToolbar\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":203,"path":"src/PluginFacade.luau"}},{"name":"CreateButton","desc":"Hot-reload-safe wrapper for [PluginToolbar:CreateButton].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"toolbar","desc":"","lua_type":"PluginToolbar"},{"name":"name","desc":"","lua_type":"string"},{"name":"tooltip","desc":"","lua_type":"string"},{"name":"icon","desc":"","lua_type":"string"},{"name":"text","desc":"","lua_type":"string?\\r\\n"}],"returns":[{"desc":"","lua_type":"PluginToolbarButton\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":220,"path":"src/PluginFacade.luau"}},{"name":"CreateDockWidgetPluginGui","desc":"Hot-reload-safe wrapper around [Plugin:CreateDockWidgetPluginGui].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"name","desc":"","lua_type":"string"},{"name":"info","desc":"","lua_type":"DockWidgetPluginGuiInfo\\r\\n"}],"returns":[{"desc":"","lua_type":"DockWidgetPluginGui\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":253,"path":"src/PluginFacade.luau"}},{"name":"GetMouse","desc":"Hot-reload-safe wrapper around [Plugin:GetMouse].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"}],"returns":[{"desc":"","lua_type":"PluginMouse\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":274,"path":"src/PluginFacade.luau"}},{"name":"CreatePluginAction","desc":"Hot-reload-safe wrapper around [Plugin:CreatePluginAction].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"actionId","desc":"","lua_type":"string"},{"name":"text","desc":"","lua_type":"string"},{"name":"statusTip","desc":"","lua_type":"string"},{"name":"iconName","desc":"","lua_type":"string"},{"name":"allowBinding","desc":"","lua_type":"boolean\\r\\n"}],"returns":[{"desc":"","lua_type":"PluginAction\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.3.0","source":{"line":284,"path":"src/PluginFacade.luau"}},{"name":"CreatePluginMenu","desc":"Hot-reload-safe wrapper around [Plugin:CreatePluginMenu].","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"id","desc":"","lua_type":"string"},{"name":"title","desc":"","lua_type":"string"},{"name":"icon","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"PluginMenu\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.3.0","source":{"line":308,"path":"src/PluginFacade.luau"}},{"name":"RegisterPreUnloadHook","desc":"Sets the method to call the next time the plugin tries to hot-reload.","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"callback","desc":"","lua_type":"(...any) -> ...any"}],"returns":[],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":325,"path":"src/PluginFacade.luau"}},{"name":"LoadPlugin","desc":"Loads the entire plugin.\\n\\n:::warning\\nWill fail to run if `root.Plugin.Main` is not a [ModuleScript] that returns a `function`.\\n:::","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"savedState","desc":"","lua_type":"SavedState"}],"returns":[],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":339,"path":"src/PluginFacade.luau"}},{"name":"UnloadPlugin","desc":"Unloads the entire plugin.","params":[{"name":"self","desc":"","lua_type":"PluginFacade"}],"returns":[{"desc":"","lua_type":"SavedState?\\r\\n"}],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":367,"path":"src/PluginFacade.luau"}},{"name":"HotReloadPlugin","desc":"Reloads the entire plugin. Used in hot-reloading.","params":[{"name":"self","desc":"","lua_type":"PluginFacade"}],"returns":[],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":395,"path":"src/PluginFacade.luau"}},{"name":"WatchInstanceForChanges","desc":"Watch for changes to the given instance and its children, and then hot-reload the entire plugin to reflect those changes.\\n\\n:::note\\nRecursive. Should be called on the root instance _once_, and it\'ll watch all descendant instances.\\n:::","params":[{"name":"self","desc":"","lua_type":"PluginFacade"},{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[],"function_type":"static","tags":["methods"],"since":"v0.1.0","source":{"line":412,"path":"src/PluginFacade.luau"}}],"properties":[{"name":"DevelopmentMode","desc":"Whether the plugin\'s execution is currently in \\"developer mode\\".\\nCan be used as a flag for having debug-specific features turned on.\\nAlso a proxy for whether Hot-Reloading is turned on.","lua_type":"boolean","since":"v0.1.0","readonly":true,"source":{"line":88,"path":"src/PluginFacade.luau"}},{"name":"PluginObject","desc":"Reference to the running plugin instance, from which native ROBLOX calls can be made.\\nSince the [Plugin] instance is only accessible from the top-level execution [Script] that ROBLOX Studio executes the plugin with,\\na reference to it is stored in here for when native [Plugin] interfaces are required in other files.","lua_type":"Plugin","since":"v0.1.0","readonly":true,"source":{"line":98,"path":"src/PluginFacade.luau"}},{"name":"CurrentRoot","desc":"A reference to the top-level root of the plugin, wherever it might be. ALL REQUIRES SHOULD BE DIRECTED FROM HERE","lua_type":"Instance","since":"v0.1.0","readonly":true,"source":{"line":106,"path":"src/PluginFacade.luau"}}],"types":[{"name":"PluginFacadeSetupSettings","desc":"","fields":[{"name":"DevelopmentMode","lua_type":"boolean","desc":"Whether to turn on development mode."},{"name":"currentRoot","lua_type":"Instance","desc":"The root [Instance] where the plugin is stored in."},{"name":"source","lua_type":"Instance","desc":"The root [Instance] from which the module \\"clones\\" itself for hot-reloading."},{"name":"pluginReference","lua_type":"Plugin","desc":"A reference to the [Plugin] object available in the plugin calling script."}],"source":{"line":64,"path":"src/PluginFacade.luau"}},{"name":"SavedState","desc":"","lua_type":"any","source":{"line":76,"path":"src/PluginFacade.luau"}},{"name":"PluginFacade","desc":"","fields":[{"name":"DevelopmentMode","lua_type":"boolean","desc":""},{"name":"PluginObject","lua_type":"Plugin","desc":""},{"name":"CurrentRoot","lua_type":"Instance","desc":""}],"source":{"line":113,"path":"src/PluginFacade.luau"}}],"name":"PluginFacade","desc":"Main Plugin manager and executor.\\nControls main plugin execution, and Hot-Reloading the plugin during development.\\nAlso acts as an interface and wrapper between the regular ROBLOX [Plugin] object and some of its methods.\\n\\nOriginal credit to the _concept and design_ of this module goes to Tiffany352 and Kampfkarren from (Original code copied from [Kampfkarren\'s Hoarcekat plugin Loader](https://github.com/Kampfkarren/hoarcekat/blob/master/src/Loader.server.lua))\\nAlthough, I ([ShadowEngineer](https://github.com/ShadowEngineer)) spent a lot of hours refactoring and rewriting the module into 2 files (this one and [Loader]) alongside implementing some more custom behaviour, and properly documenting it.\\n\\n:::warning\\nCaveats:\\n1. Although it is fine to relatively or absolutely `require` this, it is **NOT** fine to directly use it form the `require` source.\\n\\t- This is because in development mode when hot reloading is turned on, the development source will be different from the original plugin invocation source, and that will cause erroneous behaviour.\\n\\t- It is best to **pass around a reference to the original [PluginFacade] instance**.\\n\\t- [PluginSubModule]s have this behaviour built in so you don\'t need to explicitly do it there.\\n\\t- If you need to write any new architectural code, keep this in mind.\\n2. By virtue of what it is, you cannot work on this module itself (or [Loader]) for that matter with hot-reloading.\\n\\t- You must follow the traditional approach of rojo-syncing in the new code, and then right-click > Save Local Plugin on the top-level `TKGSuite` instance.\\n:::\\n\\nIntended setup usage:\\n```lua\\nlocal shouldUseDevelopmentSource = true\\nlocal developmentSource = ServerStorage:FindFirstChild(Config.Name.PluginRoot)\\n\\n-- assumes top-level plugin [Folder] is 2 parents up.\\nlocal builtInSource = script.Parent.Parent\\n\\n-- `source` is where we should watch for changes.\\n-- `currentRoot` is the clone we make of source to avoid require()\\n-- returning stale values.\\nlocal mainPluginExecutionSource = builtInSource\\nlocal currentRoot = mainPluginExecutionSource\\n\\nif shouldUseDevelopmentSource then\\n\\tif developmentSource ~= nil then\\n\\t\\tmainPluginExecutionSource = developmentSource\\n\\t\\tcurrentRoot = mainPluginExecutionSource\\n\\telse\\n\\t\\twarn(`{Config.Name.PluginRoot} development source is not present, running using built-in source.`)\\n\\tend\\nend\\n\\nPluginFacade:Setup({\\n\\tDevelopmentMode = shouldUseDevelopmentSource and developmentSource ~= nil,\\n\\tcurrentRoot = currentRoot,\\n\\tsource = mainPluginExecutionSource,\\n\\tpluginReference = plugin,\\n})\\nPluginFacade:LoadPlugin()\\nPluginFacade:WatchInstanceForChanges(mainPluginExecutionSource)\\n```","source":{"line":55,"path":"src/PluginFacade.luau"}}')}}]);