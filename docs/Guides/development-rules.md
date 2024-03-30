---
sidebar_position: 2
---

# Development Rules
If you are developing tools for the plugin, then when writing code, you must adhere to the following rules for things to work properly:

1. Whenever `require`-ing any modules, ensure that the requires are **absolute**, otherwise `PluginFacade.HotReloadPlugin()` not work (for that file anyway).
