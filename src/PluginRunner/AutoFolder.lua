local PLUGIN_NAME = script.Name
local Janitor = require(script.Parent.Parent.Packages.Janitor)
local janitor = Janitor.new()

local State = {
	CurrentParent = workspace,
	CurrentSelectedFolder = nil,
}

local Plugin = plugin or getfenv().PluginManager():CreatePlugin() -- bad code
local PluginMenu = Plugin:CreatePluginMenu(math.random(), PLUGIN_NAME, "")
local ParentAction = Plugin:CreatePluginAction(
	"ParentAction",
	"Set foldering parent...",
	"Sets the target parent every new object should have.",
	"",
	true
)

ParentAction.Triggered:Connect(function()
	print("action triggered")
	State.CurrentParent = State.CurrentSelectedFolder or workspace
end)
PluginMenu:AddAction(ParentAction)

game.Selection.SelectionChanged:Connect(function()
	print("selection changed")
	local firstObject = game.Selection:Get()[1]
	if firstObject and firstObject:IsA("Folder") then
		print("assigned first object")
		State.CurrentSelectedFolder = firstObject
	else
		print("unassigned first object")
		State.CurrentSelectedFolder = nil
	end
end)

local function setupFolder(folderInstance: Folder)
	folderInstance:SetAttribute("Parentable", true)
	janitor:Add(
		folderInstance:GetAttributeChangedSignal("Parentable"):Connect(function()
			folderInstance:SetAttribute("Parentable", true)
			PluginMenu:ShowAsync()
		end),
		nil,
		folderInstance:GetDebugId() .. ""
	)
end

for _, descendant in pairs(game:GetDescendants()) do
	if descendant:IsA("Folder") then
		setupFolder(descendant)
	end
end

game.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Folder") then
		setupFolder(descendant)
	end
end)
game.DescendantRemoving:Connect(function(descendant)
	if descendant:IsA("Folder") then
		janitor:Remove(descendant:GetDebugId() .. "")
	end
end)

workspace.ChildAdded:Connect(function(child)
	if child:IsA("BasePart") or child:IsA("Model") then
		print("child reparented")
		child.Parent = State.CurrentParent
	end
end)

return {
	hasButton = false,
	hasWidget = false,
	rootGuiObject = nil,
	buttonInfo = {},
	widgetInfo = {},
}
