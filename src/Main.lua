--// Base Configuration
local Configuration = {
	UseWorkspace = false,
	NoActors = false,
	FolderName = "Sigma Spy",
	RepoUrl = "https://raw.githubusercontent.com/caelmn/Sigma-Spy/main",
	ParserUrl = "https://raw.githubusercontent.com/caelmn/Sigma-Spy/refs/heads/main/src/lib/Parser.lua"
}

print("[Sigma Spy] v12.0.1 - Config Fix Build - Loaded")

--// Load overwrites
local Parameters = {...}
local Overwrites = Parameters[1]
if typeof(Overwrites) == "table" then
	for Key, Value in Overwrites do
		Configuration[Key] = Value
	end
end

print("1")
--// Service handler
local Services = setmetatable({}, {
	__index = function(self, Name: string): Instance
		local Service = game:GetService(Name)
		return cloneref(Service)
	end,
})

print("2")
--// Files module
local Files = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Files.lua"))()
Files:PushConfig(Configuration)
Files:Init({
	Services = Services
})

print("3")
local Folder = Files.FolderName
local Scripts = {
	--// User configurations
	Config = Files:GetModule(`{Folder}/Config`, "Config"),
	ReturnSpoofs = Files:GetModule(`{Folder}/Return spoofs`, "Return Spoofs"),
	Configuration = Configuration,
	Files = Files,

	--// Libraries
	Process = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Process.lua"))(),
	Hook = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Hook.lua"))(),
	Flags = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Flags.lua"))(),
	Ui = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Ui.lua"))(),
	Generation = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Generation.lua"))(),
	Communication = loadstring(game:HttpGet("https://github.com/caelmn/Sigma-Spy/raw/refs/heads/main/src/lib/Communication.lua"))()
}

print("4")
--// Services
local Players: Players = Services.Players

--// Dependencies
local Modules = Files:LoadLibraries(Scripts)
local Process = Modules.Process
local Hook = Modules.Hook
local Ui = Modules.Ui
local Generation = Modules.Generation
local Communication = Modules.Communication
local Config = Modules.Config

print("5")
--// Use custom font (optional)
local FontContent = Files:GetAsset("ProggyClean.ttf", true)
local FontJsonFile = Files:CreateFont("ProggyClean", FontContent)
Ui:SetFontFile(FontJsonFile)

print("6a")
--// Load modules
Process:CheckConfig(Config)
print("6b")
Files:LoadModules(Modules, {
	Modules = Modules,
	Services = Services
})

print("7")
--// ReGui Create window
local Window = Ui:CreateMainWindow()

print("8")
--// Check if Sigma spy is supported
local Supported = Process:CheckIsSupported()
if not Supported then 
	Window:Close()
	return
end

print("9")
--// Create communication channel
local ChannelId, Event = Communication:CreateChannel()
Communication:AddCommCallback("QueueLog", function(...)
	Ui:QueueLog(...)
end)
Communication:AddCommCallback("Print", function(...)
	Ui:ConsoleLog(...)
end)

print("10")
--// Generation swaps
local LocalPlayer = Players.LocalPlayer
Generation:SetSwapsCallback(function(self)
	self:AddSwap(LocalPlayer, {
		String = "LocalPlayer",
	})
	self:AddSwap(LocalPlayer.Character, {
		String = "Character",
		NextParent = LocalPlayer
	})
end)

print("11")
--// Create window content
Ui:CreateWindowContent(Window)

--// Begin the Log queue 
Ui:SetCommChannel(Event)
Ui:BeginLogService()

print("12")
--// Load hooks
local ActorCode = Files:MakeActorScript(Scripts, ChannelId)
Hook:LoadHooks(ActorCode, ChannelId)

local EnablePatches = Ui:AskUser({
	Title = "Enable function patches?",
	Content = {
		"On some executors, function patches can prevent common detections that executor has",
		"By enabling this, it MAY trigger hook detections in some games, this is why you are asked.",
		"If it doesn't work, rejoin and press 'No'",
		"",
		"(This does not affect game functionality)"
	},
	Options = {"Yes", "No"}
}) == "Yes"

--// Begin hooks
Event:Fire("BeginHooks", {
	PatchFunctions = EnablePatches
})