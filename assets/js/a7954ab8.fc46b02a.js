"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2505],{68986:e=>{e.exports=JSON.parse('{"functions":[{"name":"VisualiseRootsInSelection","desc":"Visualises all the roots of the models in the selection of models.","params":[{"name":"selection","desc":"","lua_type":"{ Model }"}],"returns":[],"function_type":"static","since":"v0.3.0","source":{"line":19,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"VisualiseRoots","desc":"Visualises the roots of a given lightsaber.\\nHelpful in debugging how the player might end up holding the lightsaber. \\nAssumes the given model is a well-formed lightsaber model.","params":[{"name":"model","desc":"","lua_type":"Model"}],"returns":[],"function_type":"static","since":"v0.3.0","source":{"line":31,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"VisualisationsExist","desc":"Checks whether any visualisations currently exist in the studio.","params":[],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","since":"v0.3.0","source":{"line":63,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"ClearAllVisualisations","desc":"Clears all visualisations that exist.\\nAssumes visualisations exist.\\nWhether they exist can be checked with [VisualiseHilt.VisualisationsExist].","params":[],"returns":[],"function_type":"static","since":"v0.3.0","source":{"line":81,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"_createRootPartVisual","desc":"Creates a visualisation of a given root [BasePart] - coloured in, half-transparent bounding box.","params":[{"name":"rootPart","desc":"","lua_type":"BasePart"}],"returns":[],"function_type":"static","since":"v0.3.0","private":true,"source":{"line":90,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"_getSelectionBoundingBox","desc":"Gets the bounding box of a selection by cloning the selection, putting it into a model, and getting the bounding box of that. ","params":[{"name":"selection","desc":"","lua_type":"{ BasePart }"}],"returns":[{"desc":"","lua_type":"CFrame"},{"desc":"","lua_type":"Vector3"}],"function_type":"static","since":"v0.3.0","private":true,"source":{"line":114,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}},{"name":"_getVisualisationFolder","desc":"Gets the visualisation folder from the workspace, and creates it if it doesn\'t exist.","params":[],"returns":[{"desc":"","lua_type":"Folder\\r\\n"}],"function_type":"static","since":"v0.3.0","private":true,"source":{"line":132,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}}],"properties":[],"types":[],"name":"VisualiseHilt","desc":"Provides visaulisation methods for well-formed lightsaber hilts.","source":{"line":6,"path":"src/PluginModules/HiltSetProcessor.module/VisualiseHilt.luau"}}')}}]);