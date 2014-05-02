class "SpawnSystem"

local msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "warn" ] = Color ( 255, 100, 0 )
	}

function SpawnSystem:__init ( )
	self.allowedSteamIDs = -- Place here all the persons allowed to use the spawn manager.
		{
			[ "STEAM_0:0:41980773" ] = true
		}
	self.commandName = "spawnmanager" -- The spawn manager command.

	Events:Subscribe ( "ModuleLoad", self, self.onLoad )
	Events:Subscribe ( "ClientModuleLoad", self, self.onClientLoad )
	Events:Subscribe ( "PlayerChat", self, self.playerChat )
	Events:Subscribe ( "PlayerSpawn", self, self.playerSpawn )
	Network:Subscribe ( "SpawnSystem:spawnPlayer", self, self.spawnPlayer )
	Network:Subscribe ( "SpawnSystem:addLocation", self, self.addLocation )
	Network:Subscribe ( "SpawnSystem:updateLocation", self, self.updateLocation )
	Network:Subscribe ( "SpawnSystem:removeLocation", self, self.removeLocation )
	Network:Subscribe ( "SpawnSystem:addClass", self, self.addClass )
	Network:Subscribe ( "SpawnSystem:updateClass", self, self.updateClass )
	Network:Subscribe ( "SpawnSystem:removeClass", self, self.removeClass )
	Network:Subscribe ( "SpawnSystem:addCharacter", self, self.addCharacter )
	Network:Subscribe ( "SpawnSystem:updateCharacter", self, self.updateCharacter )
	Network:Subscribe ( "SpawnSystem:removeCharacter", self, self.removeCharacter )
	Network:Subscribe ( "SpawnSystem:reloadManagerList", self, self.reloadManagerList )

	json = require "JSON"
end

function SpawnSystem:onLoad ( )
	self.spawns = { }
	self.playerWorlds = { }
	self.validWeapons =
		{
			[ 2 ] = true,
			[ 4 ] = true,
			[ 5 ] = true,
			[ 6 ] = true,
			[ 11 ] = true,
			[ 13 ] = true,
			[ 14 ] = true,
			[ 16 ] = true,
			[ 28 ] = true,
			[ 66 ] = true
		}

	SQL:Execute ( "CREATE TABLE IF NOT EXISTS spawn_locations ( name VARCHAR, camera VARCHAR, cameraAngle VARCHAR )" )
	SQL:Execute ( "CREATE TABLE IF NOT EXISTS spawn_classes ( name VARCHAR, location VARCHAR, password VARCHAR, colour VARCHAR )" )
	SQL:Execute ( "CREATE TABLE IF NOT EXISTS spawn_characters ( name VARCHAR, location VARCHAR, class VARCHAR, position VARCHAR, angle VARCHAR, models VARCHAR, weapons VARCHAR, camera VARCHAR, cameraAngle VARCHAR, description VARCHAR )" )

	local query = SQL:Query ( "SELECT * FROM spawn_locations" )
	local data = query:Execute ( )
	if ( #data > 0 ) then
		for _, loc in ipairs ( data ) do
			self:registerLocation ( loc )
			local query2 = SQL:Query ( "SELECT * FROM spawn_classes WHERE location = ?" )
			query2:Bind ( 1, loc.name )
			local data2 = query2:Execute ( )
			if ( #data2 > 0 ) then
				for _, class in ipairs ( data2 ) do
					self:registerClass ( class )
					local query3 = SQL:Query ( "SELECT * FROM spawn_characters WHERE location = ? AND class = ?" )
					query3:Bind ( 1, class.location )
					query3:Bind ( 2, class.name )
					local data3 = query3:Execute ( )
					if ( #data3 > 0 ) then
						for _, char in ipairs ( data3 ) do
							self:registerCharacter ( char )
						end
					end
				end
			end
		end
	end
	print ( "Loaded ".. tostring ( #data ) .." spawns!" )
end

function SpawnSystem:playerSpawn ( args )
	args.player:SetPosition ( Vector3 ( -6550, 209, -3290 ) )
	args.player:SetWorld ( self.playerWorlds [ args.player:GetId ( ) ] )
	self:sendSpawns ( args.player, true )
	args.player:SetNetworkValue ( "spawn:location", nil )
	args.player:SetNetworkValue ( "spawn:class", nil )
	args.player:SetNetworkValue ( "spawn:character", nil )

	return false
end

function SpawnSystem:onClientLoad ( args )
	local world = World.Create ( )
	self.playerWorlds [ args.player:GetId ( ) ] = world
	if ( not args.player:GetValue ( "spawn:location" ) ) then
		args.player:SetWorld ( world )
	else
		self:sendSpawns ( args.player, false )
	end
end

function SpawnSystem:sendSpawns ( player, menu )
	if ( type ( player ) == "userdata" ) then
		Network:Send ( player, "SpawnSystem:receiveSpawns", { menu = menu, spawns = self.spawns } )
	end
end

function SpawnSystem:updatePlayerSpawns ( )
	Network:Broadcast ( "SpawnSystem:receiveSpawns", { menu = false, spawns = self.spawns } )
end

function SpawnSystem:spawnPlayer ( args, player )
	local data = args.data
	local skin = args.skin
	if ( data and skin ) then
		if ( data.models [ skin ] ) then
			player:SetModelId ( tonumber ( data.models [ skin ] ) )
		end
		player:SetWorld ( DefaultWorld )
		player:SetPosition ( data.position )
		player:SetAngle ( data.angle )
		player:ClearInventory ( )
		if ( type ( data.weapons ) == "table" ) then
			for slot, weap in pairs ( data.weapons ) do
				if ( WeaponSlot [ slot ] ) then
					if ( self.validWeapons [ tonumber ( weap [ 1 ] ) ] ) then
						player:GiveWeapon ( WeaponSlot [ slot ], Weapon ( tonumber ( weap [ 1 ] ), tonumber ( weap [ 2 ] ), tonumber ( weap [ 3 ] ) ) )
					end
				end
			end
		end
		player:SetNetworkValue ( "spawn:location", data.location )
		player:SetNetworkValue ( "spawn:class", data.class )
		player:SetNetworkValue ( "spawn:character", data.name )
	else
		player:SendMessage ( "An error has occurred, contact an Admin.", "err" )
	end
end

function SpawnSystem:playerChat ( args )
    local msg = args.text
    if msg:sub ( 1, 1 ) ~= "/" then
        return true
    end

    local msg = msg:sub ( 2 )
    local cmd_args = msg:split ( " " )
    local cmd_name = cmd_args [ 1 ]:lower ( )
    table.remove ( cmd_args, 1 )

	if ( cmd_name == self.commandName ) then
		if ( self.allowedSteamIDs [ tostring ( args.player:GetSteamId ( ) ) ] ) then
			Network:Send ( args.player, "SpawnSystem:spawnManager", self.spawns )
		else
			args.player:sendMessage ( "You don't have access to this command.", "err" )
		end
	end
end

function SpawnSystem:reloadManagerList ( name, player )
	local query = SQL:Query ( "SELECT * FROM spawn_".. tostring ( name ) )
	local data = query:Execute ( )
	if ( #data ) then
		Network:Send ( player, "SpawnSystem:loadManagerList", { name, data } )
	end
end

function SpawnSystem:addLocation ( args, player )
	args.camera = json.encode ( args.camera )
	args.cameraAngle = json.encode ( args.cameraAngle )
	args.sql = true
	if self:registerLocation ( args ) then
		player:sendMessage ( "Successfully added location: ".. tostring ( args.name ) ..".", "info" )
		self:reloadManagerList ( "locations", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to add new location.", "err" )
	end
end

function SpawnSystem:updateLocation ( args, player )
	args.camera = json.encode ( args.camera )
	args.cameraAngle = json.encode ( args.cameraAngle )
	local transaction = SQL:Transaction ( )
	local query = SQL:Command ( "UPDATE spawn_locations SET camera = ?, cameraAngle = ? WHERE name = ?" )
	query:Bind ( 1, args.camera )
	query:Bind ( 2, args.cameraAngle )
	query:Bind ( 3, args.name )
	query:Execute ( )
	if transaction:Commit ( ) then
		player:sendMessage ( "Successfully updated location: ".. tostring ( args.name ) ..".", "info" )
		self.spawns [ args.name ].camera = args.camera
		self.spawns [ args.name ].cameraAngle = args.cameraAngle
		self:reloadManagerList ( "locations", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to update location: ".. tostring ( args.name ) ..".", "err" )
	end
end

function SpawnSystem:removeLocation ( args, player )
	if ( self.spawns [ args.name ] ) then
		local cmd = SQL:Command ( "DELETE FROM spawn_locations WHERE name = ?" )
		cmd:Bind ( 1, args.name )
		cmd:Execute ( )
		local cmd = SQL:Command ( "DELETE FROM spawn_classes WHERE location = ?" )
		cmd:Bind ( 1, args.name )
		cmd:Execute ( )
		local cmd = SQL:Command ( "DELETE FROM spawn_characters WHERE location = ?" )
		cmd:Bind ( 1, args.name )
		cmd:Execute ( )
		self.spawns [ args.name ] = nil
		player:sendMessage ( "Successfully removed the location ".. tostring ( args.name ) ..".", "info" )
		self:reloadManagerList ( "locations", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "No location found with this name.", "err" )
	end
end

function SpawnSystem:addClass ( args, player )
	args.colour = json.encode ( args.colour:split ( ", " ) )
	args.sql = true
	if self:registerClass ( args ) then
		player:sendMessage ( "Successfully added class: ".. tostring ( args.name ) ..".", "info" )
		self:reloadManagerList ( "classes", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to add new class.", "err" )
	end
end

function SpawnSystem:updateClass ( args, player )
	args.colour = json.encode ( args.colour:split ( ", " ) )
	local transaction = SQL:Transaction ( )
	local query = SQL:Command ( "UPDATE spawn_classes SET password = ?, colour = ? WHERE location = ? AND name = ?" )
	query:Bind ( 1, args.password )
	query:Bind ( 2, args.colour )
	query:Bind ( 3, args.location )
	query:Bind ( 4, args.name )
	query:Execute ( )
	if transaction:Commit ( ) then
		player:sendMessage ( "Successfully updated class: ".. tostring ( args.name ) ..".", "info" )
		if ( self.spawns [ args.location ] and self.spawns [ args.location ] [ "classes" ] [ args.name ] ) then
			local colour = json.decode ( args.colour )
			self.spawns [ args.location ] [ "classes" ] [ args.name ].password = args.password
			self.spawns [ args.location ] [ "classes" ] [ args.name ].colour = Color ( tonumber ( colour [ 1 ] ) or 0, tonumber ( colour [ 2 ] ) or 0, tonumber ( colour [ 3 ] ) or 0 )
		end
		self:reloadManagerList ( "classes", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to update class: ".. tostring ( args.name ) ..".", "err" )
	end
end

function SpawnSystem:removeClass ( args, player )
	if ( self.spawns [ args.location ] ) then
		if ( self.spawns [ args.location ] [ "classes" ] [ args.name ] ) then
			local cmd = SQL:Command ( "DELETE FROM spawn_classes WHERE location = ? AND name = ?" )
			cmd:Bind ( 1, args.location )
			cmd:Bind ( 2, args.name )
			cmd:Execute ( )
			self.spawns [ args.location ] [ "classes" ] [ args.name ] = nil
			player:sendMessage ( "Successfully removed the class ".. tostring ( args.name ) ..".", "info" )
			self:reloadManagerList ( "classes", player )
			self:updatePlayerSpawns ( )
		else
			player:sendMessage ( "No class found with this name.", "err" )
		end
	else
		player:sendMessage ( "No class found with this location.", "err" )
	end
end

function SpawnSystem:addCharacter ( args, player )
	args.weapons = json.encode ( args.weapons )
	args.models = json.encode ( args.models )
	args.position = json.encode ( args.position:split ( "," ) )
	args.angle = json.encode ( args.angle:split ( "," ) )
	args.camera = json.encode ( args.camera:split ( "," ) )
	args.cameraAngle = json.encode ( args.cameraAngle:split ( "," ) )
	args.sql = true
	if self:registerCharacter ( args ) then
		player:sendMessage ( "Successfully added character: ".. tostring ( args.name ) ..".", "info" )
		self:reloadManagerList ( "characters", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to add new character.", "err" )
	end
end

function SpawnSystem:updateCharacter ( args, player )
	args.weapons = json.encode ( args.weapons )
	args.models = json.encode ( args.models )
	args.position = json.encode ( args.position:split ( "," ) )
	args.angle = json.encode ( args.angle:split ( "," ) )
	args.camera = json.encode ( args.camera:split ( "," ) )
	args.cameraAngle = json.encode ( args.cameraAngle:split ( "," ) )
	local transaction = SQL:Transaction ( )
	local query = SQL:Command ( "UPDATE spawn_characters SET position = ?, angle = ?, models = ?, weapons = ?, camera = ?, cameraAngle = ?, description = ? WHERE location = ? AND class = ? AND name = ?" )
	query:Bind ( 1, args.position )
	query:Bind ( 2, args.angle )
	query:Bind ( 3, args.models )
	query:Bind ( 4, args.weapons )
	query:Bind ( 5, args.camera )
	query:Bind ( 6, args.cameraAngle )
	query:Bind ( 7, args.description )
	query:Bind ( 8, args.location )
	query:Bind ( 9, args.class )
	query:Bind ( 10, args.name )
	query:Execute ( )
	if transaction:Commit ( ) then
		player:sendMessage ( "Successfully updated character: ".. tostring ( args.name ) ..".", "info" )
		if ( self.spawns [ args.location ] and self.spawns [ args.location ] [ "classes" ] [ args.class ] and self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ] ) then
			local pos = json.decode ( args.position )
			local angle = json.decode ( args.angle )
			local camera = json.decode ( args.camera )
			local cameraAngle = json.decode ( args.cameraAngle )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].position = Vector3 ( tonumber ( pos [ 1 ] ), tonumber ( pos [ 2 ] ), tonumber ( pos [ 3 ] ) )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].angle = Angle ( tonumber ( angle [ 1 ] ), tonumber ( angle [ 2 ] ), tonumber ( angle [ 3 ] ) )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].models = json.decode ( args.models )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].weapons = json.decode ( args.weapons )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].camera = Vector3 ( tonumber ( camera [ 1 ] ), tonumber ( camera [ 2 ] ), tonumber ( camera [ 3 ] ) )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].cameraAngle = Angle ( tonumber ( cameraAngle [ 1 ] ), tonumber ( cameraAngle [ 2 ] ), tonumber ( cameraAngle [ 3 ] ) )
			self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ].description = args.description
		end
		self:reloadManagerList ( "characters", player )
		self:updatePlayerSpawns ( )
	else
		player:sendMessage ( "Failed to update character: ".. tostring ( args.name ) ..".", "err" )
	end
end

function SpawnSystem:removeCharacter ( args, player )
	if ( self.spawns [ args.location ] ) then
		if ( self.spawns [ args.location ] [ "classes" ] [ args.class ] ) then
			if ( self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ] ) then
				local cmd = SQL:Command ( "DELETE FROM spawn_characters WHERE location = ? AND class = ? AND name = ?" )
				cmd:Bind ( 1, args.location )
				cmd:Bind ( 2, args.class )
				cmd:Bind ( 3, args.name )
				cmd:Execute ( )
				self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ] = nil
				player:sendMessage ( "Successfully removed the character ".. tostring ( args.name ) ..".", "info" )
				self:reloadManagerList ( "characters", player )
				self:updatePlayerSpawns ( )
			else
				player:sendMessage ( "No character found with this name.", "err" )
			end
		else
			player:sendMessage ( "No character found with this class.", "err" )
		end
	else
		player:sendMessage ( "No character found with this location.", "err" )
	end
end

function SpawnSystem:registerLocation ( args )
	if ( type ( args ) == "table" ) then
		local camera = json.decode ( args.camera )
		local cameraAngle = json.decode ( args.cameraAngle )
		self.spawns [ args.name ] =
		{
			name = args.name,
			camera = Vector3 ( tonumber ( camera [ 1 ] ), tonumber ( camera [ 2 ] ), tonumber ( camera [ 3 ] ) ),
			cameraAngle = Angle ( tonumber ( cameraAngle [ 1 ] ), tonumber ( cameraAngle [ 2 ] ), tonumber ( cameraAngle [ 3 ] ) ),
			classes = { }
		}
		if ( args.sql ) then
			local cmd = SQL:Command ( "INSERT INTO spawn_locations ( name, camera, cameraAngle ) VALUES ( ?, ?, ? )" )
			cmd:Bind ( 1, args.name )
			cmd:Bind ( 2, args.camera )
			cmd:Bind ( 3, args.cameraAngle )
			cmd:Execute ( )
		end

		return true
	else
		return false
	end
end

function SpawnSystem:registerClass ( args )
	if ( type ( args ) == "table" ) then
		local colour = json.decode ( args.colour )
		self.spawns [ args.location ] [ "classes" ] [ args.name ] =
		{
			name = args.name,
			location = args.location,
			password = args.password,
			colour = Color ( tonumber ( colour [ 1 ] ) or 0, tonumber ( colour [ 2 ] ) or 0, tonumber ( colour [ 3 ] ) or 0 ),
			characters = { }
		}
		if ( args.sql ) then
			local cmd = SQL:Command ( "INSERT INTO spawn_classes ( name, location, password, colour ) VALUES ( ?, ?, ?, ? )" )
			cmd:Bind ( 1, args.name )
			cmd:Bind ( 2, args.location )
			cmd:Bind ( 3, args.password )
			cmd:Bind ( 4, args.colour )
			cmd:Execute ( )
		end

		return true
	else
		return false
	end
end

function SpawnSystem:registerCharacter ( args )
	if ( type ( args ) == "table" ) then
		local pos = json.decode ( args.position )
		local angle = json.decode ( args.angle )
		local camera = json.decode ( args.camera )
		local cameraAngle = json.decode ( args.cameraAngle )
		self.spawns [ args.location ] [ "classes" ] [ args.class ] [ "characters" ] [ args.name ] =
		{
			location = args.location,
			class = args.class,
			name = args.name,
			position = Vector3 ( tonumber ( pos [ 1 ] ), tonumber ( pos [ 2 ] ), tonumber ( pos [ 3 ] ) ),
			angle = Angle ( tonumber ( angle [ 1 ] ), tonumber ( angle [ 2 ] ), tonumber ( angle [ 3 ] ) ),
			models = json.decode ( args.models ),
			weapons = json.decode ( args.weapons ),
			camera = Vector3 ( tonumber ( camera [ 1 ] ), tonumber ( camera [ 2 ] ), tonumber ( camera [ 3 ] ) ),
			cameraAngle = Angle ( tonumber ( cameraAngle [ 1 ] ), tonumber ( cameraAngle [ 2 ] ), tonumber ( cameraAngle [ 3 ] ) ),
			description = args.description
		}
		if ( args.sql ) then
			local cmd = SQL:Command ( "INSERT INTO spawn_characters ( name, location, class, position, angle, models, weapons, camera, cameraAngle, description ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )" )
			cmd:Bind ( 1, args.name )
			cmd:Bind ( 2, args.location )
			cmd:Bind ( 3, args.class )
			cmd:Bind ( 4, args.position )
			cmd:Bind ( 5, args.angle )
			cmd:Bind ( 6, args.models )
			cmd:Bind ( 7, args.weapons )
			cmd:Bind ( 8, args.camera )
			cmd:Bind ( 9, args.cameraAngle )
			cmd:Bind ( 10, args.description )
			cmd:Execute ( )
		end

		return true
	else
		return false
	end
end

function Player:sendMessage ( text, color )
	self:SendChatMessage ( tostring ( text ), msgColors [ color ] )
end

spawnSystem = SpawnSystem ( )