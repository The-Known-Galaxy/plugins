"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[169],{90453:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructs a new [SubModuleManager].","params":[{"name":"facade","desc":"","lua_type":"PluginFacade.PluginFacade"}],"returns":[{"desc":"","lua_type":"SubModuleManager\\r\\n"}],"function_type":"static","tags":["constructor"],"since":"0.1.0","source":{"line":134,"path":"src/Modules/SubModuleManager.luau"}},{"name":"ValidPluginSubModule","desc":"Validates whether an instance is likely a valid [PluginSubModule].\\nDoes not `require` it if it is one though.","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["utility"],"since":"0.1.0","source":{"line":151,"path":"src/Modules/SubModuleManager.luau"}},{"name":"CollectModules","desc":"Finds all [ModuleScript]s that could potentially return a [PluginSubModule] and requires them.\\nA module identifiable by the manager is one where the name has `.module` at the end of it.","params":[{"name":"root","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"ModuleScriptCollection\\r\\n"}],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":161,"path":"src/Modules/SubModuleManager.luau"}},{"name":"LoadModules","desc":"Loads all the module scripts inside the collection, validating them.\\nUses [Promises](https://eryn.io/roblox-lua-promise/) internally.","params":[{"name":"moduleCollection","desc":"","lua_type":"ModuleScriptCollection"}],"returns":[{"desc":"A promise resolving with an array of module invocation results.","lua_type":"Promise<{LoadResult}>"}],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":181,"path":"src/Modules/SubModuleManager.luau"}},{"name":"RunLifeCycles","desc":"Runs all life cycle hooks on plugin sub-modules.\\nCreates activation buttons for all submodules too, in a toolbar with the given name.","params":[{"name":"pluginSubModules","desc":"","lua_type":"SubModuleCollection"},{"name":"toolbarName","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":242,"path":"src/Modules/SubModuleManager.luau"}},{"name":"UnloadAllModules","desc":"Declares all managed modules that this manager knows about as unloaded, and calls necessary life cycle hooks on them.\\nThis should be done only once.","params":[],"returns":[],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":302,"path":"src/Modules/SubModuleManager.luau"}},{"name":"InvokeLifeCycleHookIfExists","desc":"Invokes a given life cycle executor hook on a managed module.","params":[{"name":"managedModule","desc":"","lua_type":"ManagedModule"},{"name":"executorName","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":332,"path":"src/Modules/SubModuleManager.luau"}},{"name":"ToggleModuleActivation","desc":"Toggles a [PluginSubModule.Active] status whilst also validating if someone can, _and_ calls the necessary life cycle hooks.\\nOptionally can also force a module\'s activation.","params":[{"name":"managedModule","desc":"","lua_type":"ManagedModule"},{"name":"forcedState","desc":"","lua_type":"boolean?"}],"returns":[],"function_type":"method","tags":["methods"],"since":"0.1.0","source":{"line":351,"path":"src/Modules/SubModuleManager.luau"}}],"properties":[],"types":[{"name":"ModuleScriptCollection","desc":"Simply an array of [ModuleScript] objects.","lua_type":"{ ModuleScript }","source":{"line":56,"path":"src/Modules/SubModuleManager.luau"}},{"name":"SubModuleCollection","desc":"Simply an array of [PluginSubModule]s.","lua_type":"{ PluginSubModule }","source":{"line":63,"path":"src/Modules/SubModuleManager.luau"}},{"name":"LoadSuccess","desc":"An object representing a successful module load.","fields":[{"name":"Ok","lua_type":"true","desc":"Whether the load was successful."},{"name":"ModuleScript","lua_type":"ModuleScript","desc":"The module instance that was loaded."},{"name":"Module","lua_type":"PluginSubModule","desc":"The returned module after a successful load."}],"source":{"line":78,"path":"src/Modules/SubModuleManager.luau"}},{"name":"LoadFailure","desc":"An object representing an unsuccessful module load.","fields":[{"name":"Ok","lua_type":"false","desc":"Whether the load was successful."},{"name":"ModuleScript","lua_type":"ModuleScript","desc":"The module instance that was loaded."},{"name":"FailureReason","lua_type":"string","desc":"A description of why the load failed."}],"source":{"line":92,"path":"src/Modules/SubModuleManager.luau"}},{"name":"LoadResult","desc":"Indicating a generic load result - could be a success or a failure.","lua_type":"LoadSuccess | LoadFailure","source":{"line":102,"path":"src/Modules/SubModuleManager.luau"}},{"name":"ManagedModule","desc":"This is an common interfacing data structure that holds all relevant management and loading data about a given submodule.\\nIt is very useful to pass around the various management methods since each of its data are needed in their own contexts.","fields":[{"name":"Module","lua_type":"PluginSubModule","desc":"The submodule that is being managed."},{"name":"ShouldLoad","lua_type":"boolean","desc":"A flag indicating whether the module should and has actually been loaded."},{"name":"NotLoadingReason","lua_type":"string?","desc":"A written explanation that is outputted whenever the submodule is invoked, but it is not loaded."},{"name":"ToolbarButton","lua_type":"PluginToolbarButton","desc":"The button associated with this submodule."}],"source":{"line":116,"path":"src/Modules/SubModuleManager.luau"}}],"name":"SubModuleManager","desc":"Manages [PluginSubModule] instances.\\n\\nIntended usage:\\n```lua\\nlocal SubModuleManager = require(script.path.to.SubModuleManager)\\nlocal manager = SubModuleManager.new()\\n\\nlocal possibleSubModuleInstances = manager:CollectModules(script.path.to.SubModuleDirectory)\\nmanager:LoadModules(possibleSubModuleInstances):andThen(function(results)\\n    -- whatever custom code that is needed with successful and unsuccessful module loads\\n    -- ...\\n    local validModules\\n    manager:RunLifeCycles(validModules)\\nend)\\n\\n-- later, when plugin needs to switch off\\nmanager:UnloadAllModules()\\n```","source":{"line":24,"path":"src/Modules/SubModuleManager.luau"}}')}}]);