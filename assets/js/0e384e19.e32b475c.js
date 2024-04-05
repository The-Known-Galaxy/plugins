"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9671],{3905:(e,t,n)=>{n.d(t,{Zo:()=>d,kt:()=>g});var o=n(67294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);t&&(o=o.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,o)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,o,r=function(e,t){if(null==e)return{};var n,o,r={},a=Object.keys(e);for(o=0;o<a.length;o++)n=a[o],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(o=0;o<a.length;o++)n=a[o],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var u=o.createContext({}),s=function(e){var t=o.useContext(u),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},d=function(e){var t=s(e.components);return o.createElement(u.Provider,{value:t},e.children)},p="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return o.createElement(o.Fragment,{},t)}},m=o.forwardRef((function(e,t){var n=e.components,r=e.mdxType,a=e.originalType,u=e.parentName,d=l(e,["components","mdxType","originalType","parentName"]),p=s(n),m=r,g=p["".concat(u,".").concat(m)]||p[m]||c[m]||a;return n?o.createElement(g,i(i({ref:t},d),{},{components:n})):o.createElement(g,i({ref:t},d))}));function g(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var a=n.length,i=new Array(a);i[0]=m;var l={};for(var u in t)hasOwnProperty.call(t,u)&&(l[u]=t[u]);l.originalType=e,l[p]="string"==typeof e?e:r,i[1]=l;for(var s=2;s<a;s++)i[s]=n[s];return o.createElement.apply(null,i)}return o.createElement.apply(null,n)}m.displayName="MDXCreateElement"},59881:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>u,contentTitle:()=>i,default:()=>c,frontMatter:()=>a,metadata:()=>l,toc:()=>s});var o=n(87462),r=(n(67294),n(3905));const a={sidebar_position:1},i="Introduction",l={unversionedId:"intro",id:"intro",title:"Introduction",description:"Welcome!",source:"@site/docs/intro.md",sourceDirName:".",slug:"/intro",permalink:"/plugins/docs/intro",draft:!1,editUrl:"https://github.com/The-Known-Galaxy/plugins/edit/main/docs/intro.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",next:{title:"Hilt Set Processor",permalink:"/plugins/docs/Guides/for-plugin-users/hilt-set-processor"}},u={},s=[{value:"Running the Project",id:"running-the-project",level:2},{value:"Development Workflow",id:"development-workflow",level:2},{value:"Creating New Modules",id:"creating-new-modules",level:2}],d={toc:s},p="wrapper";function c(e){let{components:t,...n}=e;return(0,r.kt)(p,(0,o.Z)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"introduction"},"Introduction"),(0,r.kt)("p",null,"Welcome!"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},"If you are reading this guide with the intent of developing plugins for The Known Galaxy, continue reading."),(0,r.kt)("li",{parentName:"ol"},"If you are reading this guide with the goal of understanding ",(0,r.kt)("em",{parentName:"li"},"how to use a specific plugin"),", refer to the ",(0,r.kt)("inlineCode",{parentName:"li"},"Guides > For Plugin Users")," section and all its docs within.")),(0,r.kt)("h2",{id:"running-the-project"},"Running the Project"),(0,r.kt)("p",null,"Basically everything you could need to do is achieved through a ",(0,r.kt)("a",{parentName:"p",href:"https://lune-org.github.io/docs"},"Lune")," Module.\nThere are 2 ways to run it:"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},"Run ",(0,r.kt)("inlineCode",{parentName:"li"},"source .commands.sh")," to get a terminal function setup that runs the module with the alias ",(0,r.kt)("inlineCode",{parentName:"li"},"plugins"),". E.g.:")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"> source .commands.sh\n> plugins\n")),(0,r.kt)("ol",{start:2},(0,r.kt)("li",{parentName:"ol"},"Just run ",(0,r.kt)("inlineCode",{parentName:"li"},"lune run main")," every time you want to use. The above is faster for repeat usages. This one is faster for one off usages. E.g.:")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"> lune run main\n")),(0,r.kt)("p",null,"Inside there are self-explanatory interactive options for:"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},"Running unit tests"),(0,r.kt)("li",{parentName:"ol"},"Running static analysis"),(0,r.kt)("li",{parentName:"ol"},"Building the Studio testing place and the plugin itself (optionally to your local Studio plugin folder on your computer)."),(0,r.kt)("li",{parentName:"ol"},"Automatically uploading any images the plugin uses to ROBLOX."),(0,r.kt)("li",{parentName:"ol"},"Deploying the plugin to the ",(0,r.kt)("a",{parentName:"li",href:"https://create.roblox.com/store/asset/16915363791/TKG-The-Known-Tools"},"Roblox Marketplace"),".")),(0,r.kt)("h2",{id:"development-workflow"},"Development Workflow"),(0,r.kt)("p",null,"Once you have started the studio (achieved by running ",(0,r.kt)("inlineCode",{parentName:"p"},"start build/place.rbxl"),") and you are ready to work, go through the following steps:"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},"Start the doc-site (if you haven't already) with ",(0,r.kt)("inlineCode",{parentName:"li"},"docsite")," from ",(0,r.kt)("inlineCode",{parentName:"li"},"source .commands.sh"),"."),(0,r.kt)("li",{parentName:"ol"},"Ensure ",(0,r.kt)("inlineCode",{parentName:"li"},"Config.DevelopmentMode")," is turned on inside ",(0,r.kt)("inlineCode",{parentName:"li"},"src/Config.luau")," so that you get ",(0,r.kt)("strong",{parentName:"li"},"hot reloading"),", which ensures you don't have to constantly rebuild the Studio or manually save the files as a local plugin to see changes."),(0,r.kt)("li",{parentName:"ol"},"Start the rojo service with ",(0,r.kt)("inlineCode",{parentName:"li"},"rojo serve place.project.json")," and connect to it from Studio.")),(0,r.kt)("h2",{id:"creating-new-modules"},"Creating New Modules"),(0,r.kt)("p",null,"Now that you have your development environment setup and the plugin hot-reloading, you're ready to create a new module!\nNew modules are stored inside ",(0,r.kt)("inlineCode",{parentName:"p"},"src/PluginModules")," as files with the name ",(0,r.kt)("inlineCode",{parentName:"p"},"YourSubModule.module.luau"),".\nThat ",(0,r.kt)("inlineCode",{parentName:"p"},".module")," suffix is especially important since that's how the system detects that file as a possible submodule that it should try to load.\nOnce inside, use this snippet to create all the boilerplate for the new submodule:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-json"},'"Plugin SubModule": {\n    "prefix": [\n        "pluginsubmodule",\n        "plugin",\n        "submodule"\n    ],\n    "body": [\n        "--!strict",\n        "local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)",\n        "local PluginFacade = require(script.Parent.Parent.PluginFacade)",\n        "",\n        "local ${TM_FILENAME_BASE/.module//g} = PluginSubModule.new({",\n        "\\tButtonIcon = nil,",\n        "\\tDisplayName = \\"Name\\",",\n        "\\tTooltip = \\"Tooltip\\",",\n        "\\tActiveByDefault = false,",\n        "\\tOneClickExecution = false,",\n        "\\tDevelopmentModule = false,",\n        "})",\n        "",\n        "${TM_FILENAME_BASE/.module//g}:OnPreLoad(function(_pluginFacade: PluginFacade.PluginFacade)",\n        "\\treturn true",\n        "end)",\n        "",\n        "${TM_FILENAME_BASE/.module//g}:OnPostLoad(function(_pluginFacade: PluginFacade.PluginFacade)",\n        "\\treturn true",\n        "end)",\n        "",\n        "${TM_FILENAME_BASE/.module//g}:OnActivate(function(_pluginFacade: PluginFacade.PluginFacade)",\n        "\\treturn true",\n        "end)",\n        "",\n        "${TM_FILENAME_BASE/.module//g}:OnDeactivate(function(_pluginFacade: PluginFacade.PluginFacade)",\n        "\\treturn true",\n        "end)",\n        "",\n        "${TM_FILENAME_BASE/.module//g}:OnPreUnload(function(_pluginFacade: PluginFacade.PluginFacade)",\n        "\\treturn true",\n        "end)",\n        "",\n        "return ${TM_FILENAME_BASE/.module//g}",\n    ],\n},\n')),(0,r.kt)("p",null,"When working, make sure you pay attention to ",(0,r.kt)("a",{parentName:"p",href:"Guides/for-developers/development-rules"},"Development Rules"),"."),(0,r.kt)("p",null,"Thanks for working towards making the lives of TKG developers just that little bit better..."),(0,r.kt)("blockquote",null,(0,r.kt)("p",{parentName:"blockquote"},"plugins Creator and Architect, ",(0,r.kt)("a",{parentName:"p",href:"https://github.com/ShadowEngineer"},"ShadowEngineer"))))}c.isMDXComponent=!0}}]);