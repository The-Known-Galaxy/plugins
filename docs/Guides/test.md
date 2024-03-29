---
sidebar_position: 1
---

# Development Rules
If you are developing tools for the plugin, then when writing code, you must adhere to the following rules for things to work properly:

1. Whenever `require`-ing any modules, ensure that the requires are **absolute**, otherwise the [PluginFacade] hot-reloading will not work.
