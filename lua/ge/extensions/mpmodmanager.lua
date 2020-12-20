--====================================================================================
-- All work by Titch2000 and jojos38.
-- You have no permission to edit, redistribute or upload. Contact us for more info!
--====================================================================================



local M = {}
print("MPModManager initialising...")



local timer = 0
local serverMods = {}
local mods = {"multiplayerbeammp", "beammp"}



-- TRY CATCH FROM: https://gist.github.com/cwarden/1207556/a3c7caa194cad0c22871ac650159b40a88ecd702
function catch(what)
   return what[1]
end



function try(what)
	local status, result = pcall(what[1])
	if not status then
		what[2](result)
	end
	return result
end



local function IsModAllowed(n)
	for k,v in pairs(mods) do
		if string.lower(v) == string.lower(n) then
			return true
		end
	end
	for k,v in pairs(serverMods) do
		if string.lower(v) == string.lower(n) then
			return true
		end
	end
end



local function cleanUpSessionMods()
	for k,v in pairs(serverMods) do
		core_modmanager.deactivateMod(string.lower(v))
    if string.match(string.lower(v), 'multiplayer') then
		  core_modmanager.deleteMod(string.lower(v))
    end
	end
	Lua:requestReload() -- reload Lua to make sure we don't have any leftover GE files
end



local function onUpdate(dt)
  if timer >= 8 and MPCoreNetwork.isGoingMPSession() then -- Checking mods every 8 seconds
    timer = 0
    --print("Checking Mods...")
    if not core_modmanager.getModList then
		print("Mod managed was not loaded, reloading Lua")
		Lua:requestReload()
	end
	for modname,mdata in pairs(core_modmanager.getModList()) do
		if mdata.active then
			if not IsModAllowed(modname) then -- This mod is not allowed to be running
				print("This mod should not be running: "..modname)
				core_modmanager.deactivateMod(modname)
	if string.match(string.lower(modname), 'multiplayer') then
		  core_modmanager.deleteMod(string.lower(modname))
	end
			end
		else -- The mod is not active but lets check if it should be
			if IsModAllowed(modname) then
				print("Inactive Mod but Should be Active: "..modname)
				core_modmanager.activateMod(string.lower(modname))--'/mods/'..string.lower(v)..'.zip')
				MPCoreNetwork.modLoaded(modname)
			end
		end
	end
  end
  timer = timer + dt
end



local function setServerMods(mods)
  print("Server Mods Set:")
  dump(mods)
  serverMods = mods
	for k,v in pairs(serverMods) do
		serverMods[k] = 'multiplayer'..v
	end

	print("Converted Server Mods Set:")
	dump(serverMods)

	--for modname,mdata in pairs(core_modmanager.getModList())
		--if not mdata.active then
		--end
	--end
end



local function showServerMods()
  print(serverMods)
  dump(serverMods)
end



M.onUpdate = onUpdate
M.cleanUpSessionMods = cleanUpSessionMods
M.showServerMods = showServerMods
M.setServerMods = setServerMods



return M
