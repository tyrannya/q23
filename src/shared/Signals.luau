local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = script.Parent
local remotesFolder = sharedFolder:FindFirstChild("Remotes")

if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = sharedFolder
end

local Signals = {}

function Signals.getRemoteEvent(name: string): RemoteEvent
	local remote = remotesFolder:FindFirstChild(name)

	if remote then
		assert(remote:IsA("RemoteEvent"), (`{name} exists but is not a RemoteEvent`))
		return remote
	end

	remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

function Signals.waitForRemoteEvent(name: string): RemoteEvent
	local remote = remotesFolder:WaitForChild(name)
	assert(remote:IsA("RemoteEvent"), (`{name} exists but is not a RemoteEvent`))
	return remote
end

return Signals
