class "SpawnSystem"
local msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "warn" ] = Color ( 255, 100, 0 )
	}

function SpawnSystem:__init ( )
	self.cameraData =
		{
			position = Vector3 ( -6739.90, 291.37, -3596.52 ),
			angle = Angle ( 1.4, -0.4, 0.0 )
		}
	self.weaponNames =
		{
			[ 2 ] = "Pistol",
			[ 4 ] = "Revolver",
			[ 5 ] = "SMG",
			[ 6 ] = "Sawed off shotgun",
			[ 11 ] = "Assault rifle",
			[ 13 ] = "Pump action shotgun",
			[ 14 ] = "Sniper rifle",
			[ 16 ] = "Rocket launcher",
			[ 28 ] = "Machine gun",
			[ 66 ] = "Panay's rocket launcher"
		}
	local weaponNames = { }
	table.insert ( weaponNames, "None" )
	for _, name in pairs ( self.weaponNames ) do
		table.insert ( weaponNames, name )
	end
	self.weaponIDs =
		{
			[ "Pistol" ] = 2,
			[ "Revolver" ] = 4,
			[ "SMG" ] = 5,
			[ "Sawed off shotgun" ] = 6,
			[ "Assault rifle" ] = 11,
			[ "Pump action shotgun" ] = 13,
			[ "Sniper rifle" ] = 14,
			[ "Rocket launcher" ] = 16,
			[ "Machine gun" ] = 28,
			[ "Panay's rocket launcher" ] = 66
		}
	self.modelNames =
		{
            [ 2 ] = "Roaches > Razak Razman",
            [ 5 ] = "Roaches > Elite",
            [ 32 ] = "Roaches > Technician",
            [ 85 ] = "Roaches > Soldier 1",
            [ 59 ] = "Roaches > Soldier 2",
			[ 38 ] = "Ular Boys > Sri Irawan",
			[ 87 ] = "Ular Boys > Elite",
            [ 22 ] = "Ular Boys > Technician",
            [ 27 ] = "Ular Boys > Soldier 1",
            [ 103 ] = "Ular Boys > Soldier 2",
            [ 90 ] = "Reapers > Bolo Santosi",
            [ 63 ] = "Reapers > Elite",
            [ 8 ] = "Reapers > Technician" ,
            [ 12 ] = "Reapers > Soldier 1",
            [ 58 ] = "Reapers > Soldier 2",
            [ 74 ] = "Government > Baby Panay" ,
            [ 67 ] = "Government > Burned Baby Panay",
            [ 101 ] = "Government > Colonel",
			[ 3 ] = "Government > Demo Expert",
            [ 98 ] = "Government > Pilot",
            [ 42 ] = "Government > Black Hand",
            [ 44 ] = "Government > Ninja",
            [ 23 ] = "Government > Scientist",
            [ 52 ] = "Government > Soldier 1",
            [ 66 ] =  "Government > Soldier 2", 
            [ 9 ] = "Agency > Karl Blaine",
            [ 65 ] = "Agency > Jade Tan",
            [ 25 ] = "Agency > Maria Kane",
            [ 30 ] = "Agency > Marshall",
            [ 34 ] = "Agency > Tom Sheldon",
            [ 100 ] = "Agency > Black Market Dealer",
            [ 83 ] = "Agency > White Tiger",
            [ 51 ] = "Agency > Rico Rodriguez",
            [ 70 ] = "Misc > General Masayo",
            [ 11 ] = "Misc > Zhang Sun",
            [ 84 ] = "Misc > Alexander Mirikov",
            [ 19 ] = "Misc > Chinese Businessman",
            [ 36 ] = "Misc > Politician",
            [ 78 ] = "Misc > Thug Boss",
            [ 71 ] = "Misc > Saul Sukarno",
            [ 79 ] = "Misc > Japanese Veteran",
            [ 96 ] = "Misc > Bodyguard",
            [ 80 ] = "Misc > Suited Guest 1",
            [ 95 ] = "Misc > Suited Guest 2",
            [ 60 ] = "Misc > Race Challenge Girl",
            [ 15 ] = "Misc > Male Stripper 1",
            [ 17 ] = "Misc > Male Stripper 2",
            [ 86 ] = "Misc > Female Stripper",
            [ 16 ] = "Misc > Panau Police",
            [ 18 ] = "Misc > Hacker",
            [ 64 ] = "Misc > Bom Bom Bohilano",
            [ 40 ] = "Misc > Factory Boss",
            [ 1 ] = "Misc > Thug 1",
            [ 39 ] = "Misc > Thug 2",
            [ 61 ] = "Misc > Soldier",
            [ 26 ] = "Misc > Boat Captain",
            [ 21 ] = "Misc > Paparazzi",
			[ 6 ] = "Misc > Chinese Bodyguard"
		}
	self.spawns = { }
	self.character = { }
	self.modelsInList = { }
	self.currentSkin = 1

	self.spawn = { }
	self.spawn.window = GUI:Window ( "Castillo's Spawn System - Selector", Vector2 ( 0.01, 0.33 ), Vector2 ( 0.3, 0.7 ) )
	self.spawn.window:SetVisible ( false )
	self.spawn.window:SetClosable ( false )
	self.spawn.window:Subscribe ( "Resize", function ( ) self.spawn.window:SetSizeRel ( Vector2 ( 0.3, 0.7 ) ) end )
	self.spawn.location = GUI:ListBox ( Vector2 ( 0.0, 0.03 ), Vector2 ( 0.5, 0.4 ), self.spawn.window, "Location" )
	self.spawn.location:Subscribe ( "RowSelected", self, self.locationSelect )
	self.spawn.class = GUI:ListBox ( Vector2 ( 0.0, 0.47 ), Vector2 ( 0.5, 0.5 ), self.spawn.window, "Class" )
	self.spawn.class:Subscribe ( "RowSelected", self, self.classSelect )
	self.spawn.character = GUI:ListBox ( Vector2 ( 0.51, 0.03 ), Vector2 ( 0.5, 0.4 ), self.spawn.window, "Character" )
	self.spawn.character:Subscribe ( "RowSelected", self, self.characterSelect )
	self.spawn.descScroll = GUI:ScrollControl ( Vector2 ( 0.52, 0.48 ), Vector2 ( 0.44, 0.25 ), self.spawn.window )
	self.spawn.description = GUI:Label ( "", Vector2 ( 0.1, 0.01 ), Vector2 ( 0.80, 0.3 ), self.spawn.descScroll )
	self.spawn.description:SetWrap ( true )
	self.spawn.description:SizeToContents ( )
	self.spawn.skinLabel = GUI:Label ( "Select character model:", Vector2 ( 0.60, 0.78 ), Vector2 ( 0.46, 0.3 ), self.spawn.window )
	self.spawn.skinLeft = GUI:Button ( "<<", Vector2 ( 0.60, 0.81 ), Vector2 ( 0.07, 0.05 ), self.spawn.window )
	self.spawn.skinLeft:Subscribe ( "Press", self, self.previousSkin )
	self.spawn.skinRight = GUI:Button ( ">>", Vector2 ( 0.84, 0.81 ), Vector2 ( 0.07, 0.05 ), self.spawn.window )
	self.spawn.skinRight:Subscribe ( "Press", self, self.nextSkin )
	self.spawn.skinID = GUI:Label ( "1", Vector2 ( 0.68, 0.825 ), Vector2 ( 0.15, 0.05 ), self.spawn.window )
	self.spawn.skinID:SetAlignment ( 64 )
	self.spawn.proceed = GUI:Button ( "Spawn", Vector2 ( 0.60, 0.87 ), Vector2 ( 0.31, 0.05 ), self.spawn.window )
	self.spawn.proceed:Subscribe ( "Press", self, self.spawnPlayer )

	self.spawn.passwordWindow = GUI:Window ( "Introduce password", Vector2 ( 0.5, 0.5 ) - Vector2 ( 0.18, 0.2 ) / 2, Vector2 ( 0.18, 0.2 ) )
	self.spawn.passwordWindow:SetVisible ( false )
	self.spawn.passwordBox = GUI:TextBox ( "", Vector2 ( 0.0, 0.05 ), Vector2 ( 0.95, 0.27 ), "text", self.spawn.passwordWindow )
	self.spawn.passwordLabel = GUI:Label ( "", Vector2 ( 0.25, 0.4 ), Vector2 ( 0.0, 0.0 ), self.spawn.passwordWindow )
	self.spawn.passwordLabel:SetTextColor ( Color ( 255, 0, 0 ) )
	self.spawn.passwordOK = GUI:Button ( "Spawn", Vector2 ( 0.0, 0.55 ), Vector2 ( 0.95, 0.22 ), self.spawn.passwordWindow )
	self.spawn.passwordOK:Subscribe ( "Press", self, self.checkPassword )

	self.manager = { }
	self.manager.locations = { }
	self.manager.window = GUI:Window ( "Castillo's Spawn System - Manager", Vector2 ( 0.5, 0.5 ) - Vector2 ( 0.52, 0.61 ) / 2, Vector2 ( 0.52, 0.61 ) )
	self.manager.window:SetVisible ( false )
	self.manager.window:Subscribe ( "WindowClosed", function ( ) if ( not self.spawn.window:GetVisible ( ) ) then Mouse:SetVisible ( false ) end end )
	self.manager.tabPanel, self.manager.tabs = GUI:TabControl ( { "Locations", "Classes", "Characters" }, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.5, 0.6 ), self.manager.window ) 
	self.manager.tabPanel:SetDock ( GwenPosition.Fill )
	self.manager.locations.list = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.77 ), self.manager.tabs [ "Locations" ].base, { { name = "Name" } } )
	self.manager.locations.list:Subscribe ( "RowSelected", self, self.fillLocationBoxes )
	self.manager.locations.refresh = GUI:Button ( "Refresh", Vector2 ( 0.0, 0.78 ), Vector2 ( 0.3, 0.07 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.refresh:Subscribe ( "Press", self, self.reloadLocations )
	self.manager.locations.nameLabel = GUI:Label ( "Location name:", Vector2 ( 0.32, 0.01 ), Vector2 ( 0.2, 0.2 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.nameBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.06 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camPosLabel = GUI:Label ( "Camera position:", Vector2 ( 0.32, 0.15 ), Vector2 ( 0.5, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camPosBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.20 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camPosGet = GUI:Button ( "Obtain", Vector2 ( 0.83, 0.20 ), Vector2 ( 0.13, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camPosGet:Subscribe ( "Press", self, self.getCamPosition )
	self.manager.locations.camAngleLabel = GUI:Label ( "Camera angle:", Vector2 ( 0.32, 0.29 ), Vector2 ( 0.5, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camAngleBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.34 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camAngleGet = GUI:Button ( "Obtain", Vector2 ( 0.83, 0.34 ), Vector2 ( 0.13, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.camAngleGet:Subscribe ( "Press", self, self.getCamAngle )
	self.manager.locations.addLocation = GUI:Button ( "Add location", Vector2 ( 0.32, 0.42 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.addLocation:Subscribe ( "Press", self, self.addLocation )
	self.manager.locations.updateLocation = GUI:Button ( "Update location", Vector2 ( 0.49, 0.42 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.updateLocation:Subscribe ( "Press", self, self.updateLocation )
	self.manager.locations.removeLocation = GUI:Button ( "Remove location", Vector2 ( 0.67, 0.42 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Locations" ].base )
	self.manager.locations.removeLocation:Subscribe ( "Press", self, self.removeLocation )

	self.manager.classes = { }
	self.manager.classes.list = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.77 ), self.manager.tabs [ "Classes" ].base, { { name = "Location" }, { name = "Name" } } )
	self.manager.classes.list:Subscribe ( "RowSelected", self, self.fillClassBoxes )
	self.manager.classes.refresh = GUI:Button ( "Refresh", Vector2 ( 0.0, 0.78 ), Vector2 ( 0.3, 0.07 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.refresh:Subscribe ( "Press", self, self.reloadClasses )
	self.manager.classes.locLabel = GUI:Label ( "Location name:", Vector2 ( 0.32, 0.01 ), Vector2 ( 0.2, 0.2 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.locBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.06 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Classes" ].base )
	self.manager.classes.nameLabel = GUI:Label ( "Class name:", Vector2 ( 0.32, 0.15 ), Vector2 ( 0.2, 0.2 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.nameBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.20 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Classes" ].base )
	self.manager.classes.passLabel = GUI:Label ( "Class password:", Vector2 ( 0.32, 0.29 ), Vector2 ( 0.2, 0.2 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.passBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.34 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Classes" ].base )
	self.manager.classes.colorLabel = GUI:Label ( "Class colour:", Vector2 ( 0.32, 0.43 ), Vector2 ( 0.2, 0.2 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.colorBox = GUI:TextBox ( "", Vector2 ( 0.32, 0.48 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.tabs [ "Classes" ].base )
	self.manager.classes.colorGet = GUI:Button ( "Picker", Vector2 ( 0.83, 0.48 ), Vector2 ( 0.13, 0.06 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.colorGet:Subscribe ( "Press", self, self.openColorPicker )
	self.manager.classes.addClass = GUI:Button ( "Add class", Vector2 ( 0.32, 0.56 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.addClass:Subscribe ( "Press", self, self.addClass )
	self.manager.classes.updateClass = GUI:Button ( "Update class", Vector2 ( 0.49, 0.56 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.updateClass:Subscribe ( "Press", self, self.updateClass )
	self.manager.classes.removeClass = GUI:Button ( "Remove class", Vector2 ( 0.67, 0.56 ), Vector2 ( 0.15, 0.06 ), self.manager.tabs [ "Classes" ].base )
	self.manager.classes.removeClass:Subscribe ( "Press", self, self.removeClass )

	self.manager.classes.pickerWin = GUI:Window ( "Class colour", Vector2 ( 0.5, 0.5 ) - Vector2 ( 0.2, 0.4 ) / 2, Vector2 ( 0.2, 0.4 ) )
	self.manager.classes.pickerWin:SetVisible ( false )
	self.manager.classes.picker = GUI:ColorPicker ( true, Vector2 ( 0, 0 ), Vector2 ( 1.06, 0.8 ), self.manager.classes.pickerWin )
	self.manager.classes.pickerSet = GUI:Button ( "Use colour", Vector2 ( 0.0, 0.82 ), Vector2 ( 0.95, 0.070 ), self.manager.classes.pickerWin )
	self.manager.classes.pickerSet:Subscribe ( "Press", self, self.setColourField )

	self.manager.characters = { }
	self.manager.characters.list = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.77 ), self.manager.tabs [ "Characters" ].base, { { name = "Location" }, { name = "Class" }, { name = "Name" } } )
	self.manager.characters.list:Subscribe ( "RowSelected", self, self.fillCharacterBoxes )
	self.manager.characters.refresh = GUI:Button ( "Refresh", Vector2 ( 0.0, 0.78 ), Vector2 ( 0.3, 0.07 ), self.manager.tabs [ "Characters" ].base )
	self.manager.characters.refresh:Subscribe ( "Press", self, self.reloadCharacters )
	self.manager.characters.scroll = GUI:ScrollControl ( Vector2 ( 0.3, 0.0 ), Vector2 ( 0.7, 0.85 ), self.manager.tabs [ "Characters" ].base )
	self.manager.characters.locLabel = GUI:Label ( "Location name:", Vector2 ( 0.029, 0.013 ), Vector2 ( 0.2, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.locBox = GUI:TextBox ( "", Vector2 ( 0.029, 0.06 ), Vector2 ( 0.7, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.classLabel = GUI:Label ( "Class name:", Vector2 ( 0.029, 0.15 ), Vector2 ( 0.2, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.classBox = GUI:TextBox ( "", Vector2 ( 0.029, 0.20 ), Vector2 ( 0.7, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.nameLabel = GUI:Label ( "Character name:", Vector2 ( 0.029, 0.29 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.nameBox = GUI:TextBox ( "", Vector2 ( 0.029, 0.34 ), Vector2 ( 0.7, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.posLabel = GUI:Label ( "Character position:", Vector2 ( 0.029, 0.43 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.posBox = GUI:TextBox ( "", Vector2 ( 0.029, 0.48 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.posGet = GUI:Button ( "Obtain", Vector2 ( 0.54, 0.48 ), Vector2 ( 0.19, 0.065 ), self.manager.characters.scroll )
	self.manager.characters.posGet:Subscribe ( "Press", self, self.getPosition )
	self.manager.characters.angleLabel = GUI:Label ( "Character angle:", Vector2 ( 0.029, 0.57 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.angleBox = GUI:TextBox ( "", Vector2 ( 0.029, 0.62 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.angleGet = GUI:Button ( "Obtain", Vector2 ( 0.54, 0.62 ), Vector2 ( 0.19, 0.065 ), self.manager.characters.scroll )
	self.manager.characters.angleGet:Subscribe ( "Press", self, self.getAngle )
	self.manager.characters.modelsLabel = GUI:Label ( "Character models:", Vector2 ( 0.029, 0.71 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.modelsList = GUI:SortedList ( Vector2 ( 0.021, 0.75 ), Vector2 ( 0.72, 0.4 ), self.manager.characters.scroll, { { name = "ID" }, { name = "Name" } } )
	self.manager.characters.modelsBox = GUI:TextBox ( "0", Vector2 ( 0.029, 1.16 ), Vector2 ( 0.23, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.modelsAdd = GUI:Button ( "Add", Vector2 ( 0.30, 1.156 ), Vector2 ( 0.21, 0.07 ), self.manager.characters.scroll )
	self.manager.characters.modelsAdd:Subscribe ( "Press", self, self.addCharacterModel )
	self.manager.characters.modelsRemove = GUI:Button ( "Remove", Vector2 ( 0.53, 1.156 ), Vector2 ( 0.21, 0.07 ), self.manager.characters.scroll )
	self.manager.characters.modelsRemove:Subscribe ( "Press", self, self.removeCharacterModel )
	self.manager.characters.weaponsLabel = GUI:Label ( "Character weapons: ( Slot, Weapon, Clip Ammo, Extra Ammo )", Vector2 ( 0.029, 1.25 ), Vector2 ( 0.7, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.wPrimaryLabel = GUI:Label ( "Primary:", Vector2 ( 0.029, 1.31 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.wPrimaryMenu, self.manager.characters.wPrimaryItems = GUI:ComboBox ( Vector2 ( 0.17, 1.30 ), Vector2 ( 0.32, 0.06 ), self.manager.characters.scroll, weaponNames )
	self.manager.characters.wPrimaryClip = GUI:TextBox ( "0", Vector2 ( 0.5, 1.30 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.wPrimaryExtra = GUI:TextBox ( "0", Vector2 ( 0.63, 1.30 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.wLeftLabel = GUI:Label ( "Left hand:", Vector2 ( 0.029, 1.40 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.wLeftMenu, self.manager.characters.wLeftItems = GUI:ComboBox ( Vector2 ( 0.17, 1.39 ), Vector2 ( 0.32, 0.06 ), self.manager.characters.scroll, weaponNames )
	self.manager.characters.wLeftClip = GUI:TextBox ( "0", Vector2 ( 0.5, 1.39 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.wLeftExtra = GUI:TextBox ( "0", Vector2 ( 0.63, 1.39 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.wRightLabel = GUI:Label ( "Right hand:", Vector2 ( 0.029, 1.49 ), Vector2 ( 0.4, 0.2 ), self.manager.characters.scroll )
	self.manager.characters.wRightMenu, self.manager.characters.wRightItems = GUI:ComboBox ( Vector2 ( 0.17, 1.48 ), Vector2 ( 0.32, 0.06 ), self.manager.characters.scroll, weaponNames )
	self.manager.characters.wRightClip = GUI:TextBox ( "0", Vector2 ( 0.5, 1.48 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.wRightExtra = GUI:TextBox ( "0", Vector2 ( 0.63, 1.48 ), Vector2 ( 0.11, 0.06 ), "numeric", self.manager.characters.scroll )
	self.manager.characters.camLabel = GUI:Label ( "Character camera:", Vector2 ( 0.029, 1.58 ), Vector2 ( 0.5, 0.43 ), self.manager.characters.scroll )
	self.manager.characters.camBox = GUI:TextBox ( "", Vector2 ( 0.029, 1.63 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.camPosGet = GUI:Button ( "Obtain", Vector2 ( 0.54, 1.63 ), Vector2 ( 0.2, 0.065 ), self.manager.characters.scroll )
	self.manager.characters.camPosGet:Subscribe ( "Press", self, self.getCamPosition )
	self.manager.characters.camAngleLabel = GUI:Label ( "Character angle:", Vector2 ( 0.029, 1.72 ), Vector2 ( 0.5, 0.43 ), self.manager.characters.scroll )
	self.manager.characters.camAngleBox = GUI:TextBox ( "", Vector2 ( 0.029, 1.77 ), Vector2 ( 0.5, 0.06 ), "text", self.manager.characters.scroll )
	self.manager.characters.camAngleGet = GUI:Button ( "Obtain", Vector2 ( 0.54, 1.77 ), Vector2 ( 0.2, 0.065 ), self.manager.characters.scroll )
	self.manager.characters.camAngleGet:Subscribe ( "Press", self, self.getCamAngle )
	self.manager.characters.descLabel = GUI:Label ( "Character description:", Vector2 ( 0.029, 1.86 ), Vector2 ( 0.5, 0.43 ), self.manager.characters.scroll )
	self.manager.characters.descBox = GUI:TextBox ( "", Vector2 ( 0.029, 1.91 ), Vector2 ( 0.71, 0.4 ), "multiline", self.manager.characters.scroll )
	self.manager.characters.addCharacter = GUI:Button ( "Add character", Vector2 ( 0.029, 2.33 ), Vector2 ( 0.2, 0.06 ), self.manager.characters.scroll )
	self.manager.characters.addCharacter:Subscribe ( "Press", self, self.addCharacter )
	self.manager.characters.updateCharacter = GUI:Button ( "Update character", Vector2 ( 0.232, 2.33 ), Vector2 ( 0.25, 0.06 ), self.manager.characters.scroll )
	self.manager.characters.updateCharacter:Subscribe ( "Press", self, self.updateCharacter )
	self.manager.characters.removeCharacter = GUI:Button ( "Remove character", Vector2 ( 0.488, 2.33 ), Vector2 ( 0.25, 0.06 ), self.manager.characters.scroll )
	self.manager.characters.removeCharacter:Subscribe ( "Press", self, self.removeCharacter )

	Network:Subscribe ( "SpawnSystem:receiveSpawns", self, self.receiveSpawns )
	Network:Subscribe ( "SpawnSystem:spawnManager", self, self.showSpawnManager )
	Network:Subscribe ( "SpawnSystem:loadManagerList", self, self.loadManagerList )
	Events:Subscribe ( "LocalPlayerInput", self, self.localPlayerInput )
end

function SpawnSystem:receiveSpawns ( data )
	self.spawns = data.spawns
	if ( data.menu ) then
		self.spawn.window:SetVisible ( true )
		Mouse:SetVisible ( true )
		self.spawn.location:Clear ( )
		self.spawn.class:Clear ( )
		self.spawn.character:Clear ( )
		for location in pairs ( self.spawns ) do
			local item = self.spawn.location:AddItem ( tostring ( location ) )
			item:SetDataString ( "name", location )
		end
		self.currentSkin = 1
		self.cameraEvent = Events:Subscribe ( "CalcView", self, self.cameraMove )
	end
end

function SpawnSystem:localPlayerInput ( )
	if ( self.spawn.window:GetVisible ( ) or self.manager.window:GetVisible ( ) and Game:GetState ( ) == GUIState.Game ) then
		return false
	end
end

function SpawnSystem:locationSelect ( )
	local row = self.spawn.location:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetDataString ( "name" )
		if ( self.spawns [ name ] ) then
			self.spawn.class:Clear ( )
			self.spawn.character:Clear ( )
			local data = self:getLocationData ( name )
			if ( data ) then
				for name, class in pairs ( data.classes ) do
					local item = self.spawn.class:AddItem ( tostring ( name ) )
					item:SetDataString ( "location", class.location )
					item:SetDataString ( "class", name )
				end
				self.cameraData =
					{
						position = data.camera,
						angle = data.cameraAngle
					}
			end
			self.character = { }
			self.currentSkin = 1
			self.spawn.skinID:SetText ( "1" )
		end
	end
end

function SpawnSystem:classSelect ( )
	local row = self.spawn.class:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local name = row:GetDataString ( "class" )
		local data = self:getClassData ( location, name )
		if ( data ) then
			self.spawn.character:Clear ( )
			for name, char in pairs ( data.characters ) do
				local item = self.spawn.character:AddItem ( tostring ( name ) )
				item:SetDataString ( "location", char.location )
				item:SetDataString ( "class", char.class )
				item:SetDataString ( "character", name )
			end
			self.character = { }
			self.currentSkin = 1
			self.spawn.skinID:SetText ( "1" )
		end
	end
end

function SpawnSystem:characterSelect ( )
	local row = self.spawn.character:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local class = row:GetDataString ( "class" )
		local name = row:GetDataString ( "character" )
		local data = self:getCharacterData ( location, class, name )
		if ( data ) then
			self.cameraData =
				{
					position = data.camera,
					angle = data.cameraAngle
				}
			self.character = data
			self.currentSkin = 1
			self.spawn.description:SetText ( tostring ( data.description ) )
			self.spawn.description:SizeToContents ( )
			self.spawn.skinID:SetText ( "1" )
			self.spawn.skinLeft:SetEnabled ( #self.character.models > 1 )
			self.spawn.skinRight:SetEnabled ( #self.character.models > 1 )
		end
	end
end

function SpawnSystem:cameraMove ( )
	Camera:SetPosition ( self.cameraData.position )
	Camera:SetAngle ( self.cameraData.angle )
end

function SpawnSystem:previousSkin ( )
	if ( self.currentSkin == 1 ) then
		self.currentSkin = #self.character.models
	else
		self.currentSkin = ( self.currentSkin - 1 )
	end
	self.spawn.skinID:SetText ( tostring ( self.currentSkin ) )
end

function SpawnSystem:nextSkin ( )
	if ( self.currentSkin == #self.character.models ) then
		self.currentSkin = 1
	else
		self.currentSkin = ( self.currentSkin + 1 )
	end
	self.spawn.skinID:SetText ( tostring ( self.currentSkin ) )
end

function SpawnSystem:spawnPlayer ( )
	if ( self.character.location and self.character.class ) then
		local password = self:getClassData ( self.character.location, self.character.class, "password" )
		if ( password ) then
			if ( password ~= "" ) then
				self.spawn.passwordWindow:SetVisible ( true )
			else
				Network:Send ( "SpawnSystem:spawnPlayer", { data = self.character, skin = self.currentSkin } )
				self.spawn.passwordWindow:SetVisible ( false )
				self.spawn.passwordLabel:SetText ( "" )
				self.spawn.window:SetVisible ( false )
				Mouse:SetVisible ( false )
				Events:Unsubscribe ( self.cameraEvent )
			end
		end
	end
end

function SpawnSystem:checkPassword ( )
	if ( self.character.location and self.character.class ) then
		local password = self:getClassData ( self.character.location, self.character.class, "password" )
		if ( password ) then
			if ( password ~= self.spawn.passwordBox:GetText ( ) ) then
				self.spawn.passwordLabel:SetText ( "Wrong password!" )
				self.spawn.passwordLabel:SizeToContents ( )
			else
				Network:Send ( "SpawnSystem:spawnPlayer", { data = self.character, skin = self.currentSkin } )
				self.spawn.passwordWindow:SetVisible ( false )
				self.spawn.passwordLabel:SetText ( "" )
				self.spawn.window:SetVisible ( false )
				Mouse:SetVisible ( false )
				Events:Unsubscribe ( self.cameraEvent )
			end
		end
	end
end

function SpawnSystem:showSpawnManager ( spawns )
	self.manager.window:SetVisible ( true )
	Mouse:SetVisible ( true )
	self.manager.locations.list:Clear ( )
	self.manager.classes.list:Clear ( )
	self.manager.characters.list:Clear ( )
	for location, data in pairs ( spawns ) do
		local item = self.manager.locations.list:AddItem ( tostring ( location ) )
		item:SetDataString ( "name", location )
		for _, class in pairs ( data.classes ) do
			local item = self.manager.classes.list:AddItem ( tostring ( class.location ) )
			item:SetCellText ( 1, tostring ( class.name ) )
			item:SetDataString ( "location", class.location )
			item:SetDataString ( "name", class.name )
			for _, char in pairs ( class.characters ) do
				local item = self.manager.characters.list:AddItem ( tostring ( char.location ) )
				item:SetCellText ( 1, tostring ( char.class ) )
				item:SetCellText ( 2, tostring ( char.name ) )
				item:SetDataString ( "location", char.location )
				item:SetDataString ( "class", char.class )
				item:SetDataString ( "name", char.name )
			end
		end
	end
end

function SpawnSystem:loadManagerList ( args )
	local name = args [ 1 ]
	local data = args [ 2 ]
	self.manager [ name ].list:Clear ( )
	if ( name == "locations" ) then
		for _, loc in ipairs ( data ) do
			local item = self.manager.locations.list:AddItem ( tostring ( loc.name ) )
			item:SetDataString ( "name", loc.name )
		end
	elseif ( name == "classes" ) then
		for _, class in ipairs ( data ) do
			local item = self.manager.classes.list:AddItem ( tostring ( class.location ) )
			item:SetCellText ( 1, tostring ( class.name ) )
			item:SetDataString ( "location", class.location )
			item:SetDataString ( "name", class.name )
		end
	elseif ( name == "characters" ) then
		for _, char in ipairs ( data ) do
			local item = self.manager.characters.list:AddItem ( tostring ( char.location ) )
			item:SetCellText ( 1, tostring ( char.class ) )
			item:SetCellText ( 2, tostring ( char.name ) )
			item:SetDataString ( "location", char.location )
			item:SetDataString ( "class", char.class )
			item:SetDataString ( "name", char.name )
		end
	end
end

function SpawnSystem:getCamPosition ( )
	local tab = self.manager.tabPanel:GetCurrentTab ( )
	if ( tab:GetText ( ) == "Locations" ) then
		self.manager.locations.camPosBox:SetText ( tostring ( Camera:GetPosition ( ) ) )
	elseif ( tab:GetText ( ) == "Characters" ) then
		self.manager.characters.camBox:SetText ( tostring ( Camera:GetPosition ( ) ) )
	end
end

function SpawnSystem:getCamAngle ( )
	local tab = self.manager.tabPanel:GetCurrentTab ( )
	if ( tab:GetText ( ) == "Locations" ) then
		self.manager.locations.camAngleBox:SetText ( tostring ( Camera:GetAngle ( ) ) )
	elseif ( tab:GetText ( ) == "Characters" ) then
		self.manager.characters.camAngleBox:SetText ( tostring ( Camera:GetAngle ( ) ) )
	end
end

function SpawnSystem:fillLocationBoxes ( )
	local row = self.manager.locations.list:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetDataString ( "name" )
		local data = self:getLocationData ( name )
		if ( data ) then
			self.manager.locations.nameBox:SetText ( tostring ( name ) )
			self.manager.locations.camPosBox:SetText ( tostring ( data.camera ) )
			self.manager.locations.camAngleBox:SetText ( tostring ( data.cameraAngle ) )
		end
	end
end

function SpawnSystem:addLocation ( )
	local name = self.manager.locations.nameBox:GetText ( )
	local pos = self.manager.locations.camPosBox:GetText ( )
	local angle = self.manager.locations.camAngleBox:GetText ( )
	if ( name ~= "" and pos ~= "" and angle ~= "" ) then
		if ( not self.spawns [ name ] ) then
			Network:Send ( "SpawnSystem:addLocation", { name = name, camera = pos:split ( "," ), cameraAngle = angle:split ( "," ) } )
		else
			sendMessage ( "A location with this name already exists.", "err" )
		end
	else
		sendMessage ( "One or more fields must be filled.", "err" )
	end
end

function SpawnSystem:updateLocation ( )
	local row = self.manager.locations.list:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetDataString ( "name" )
		local pos = self.manager.locations.camPosBox:GetText ( )
		local angle = self.manager.locations.camAngleBox:GetText ( )
		if ( name ~= "" and pos ~= "" and angle ~= "" ) then
			Network:Send ( "SpawnSystem:updateLocation", { name = name, camera = pos:split ( "," ), cameraAngle = angle:split ( "," ) } )
		else
			sendMessage ( "One or more fields must be filled.", "err" )
		end
	else
		sendMessage ( "You must select a location to update.", "err" )
	end
end

function SpawnSystem:removeLocation ( )
	local row = self.manager.locations.list:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetDataString ( "name" )
		Network:Send ( "SpawnSystem:removeLocation", { name = name } )
	else
		sendMessage ( "You must select a location to remove.", "err" )
	end
end

function SpawnSystem:reloadLocations ( )
	Network:Send ( "SpawnSystem:reloadManagerList", "locations" )
end

function SpawnSystem:fillClassBoxes ( )
	local row = self.manager.classes.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local name = row:GetDataString ( "name" )
		local data = self:getClassData ( location, name )
		if ( data ) then
			self.manager.classes.locBox:SetText ( tostring ( location ) )
			self.manager.classes.nameBox:SetText ( tostring ( name ) )
			self.manager.classes.passBox:SetText ( ( not data.password and "" or tostring ( data.password ) ) )
			self.manager.classes.colorBox:SetText ( tostring ( data.colour ) )
		end
	end
end

function SpawnSystem:reloadClasses ( )
	Network:Send ( "SpawnSystem:reloadManagerList", "classes" )
end

function SpawnSystem:openColorPicker ( )
	self.manager.classes.pickerWin:SetVisible ( true )
end

function SpawnSystem:setColourField ( )
	local color = self.manager.classes.picker:GetColor ( )
	self.manager.classes.colorBox:SetText ( tostring ( color ) )
	self.manager.classes.pickerWin:SetVisible ( false )
end

function SpawnSystem:addClass ( )
	local location = self.manager.classes.locBox:GetText ( )
	local name = self.manager.classes.nameBox:GetText ( )
	local password = self.manager.classes.passBox:GetText ( )
	local colour = self.manager.classes.colorBox:GetText ( )
	if ( location ~= "" and name ~= "" ) then
		if ( not self.spawns [ location ] ) then
			sendMessage ( "There's no location with this name.", "err" )
			return false
		end

		if ( not self.spawns [ location ] [ "classes" ] [ name ] ) then
			Network:Send ( "SpawnSystem:addClass", { location = location, name = name, password = password, colour = colour } )
		else
			sendMessage ( "A class with this name already exists on that location.", "err" )
		end
	else
		sendMessage ( "One or more fields must be filled.", "err" )
	end
end

function SpawnSystem:updateClass ( )
	local row = self.manager.classes.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local name = row:GetDataString ( "name" )
		local password = self.manager.classes.passBox:GetText ( )
		local colour = self.manager.classes.colorBox:GetText ( )
		if ( location ~= "" and name ~= "" ) then
			Network:Send ( "SpawnSystem:updateClass", { location = location, name = name, password = password, colour = colour } )
		else
			sendMessage ( "One or more fields must be filled.", "err" )
		end
	else
		sendMessage ( "You must select a class to update.", "err" )
	end
end

function SpawnSystem:removeClass ( )
	local row = self.manager.classes.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local name = row:GetDataString ( "name" )
		Network:Send ( "SpawnSystem:removeClass", { location = location, name = name } )
	else
		sendMessage ( "You must select a class to remove.", "err" )
	end
end

function SpawnSystem:fillCharacterBoxes ( )
	local row = self.manager.characters.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local class = row:GetDataString ( "class" )
		local name = row:GetDataString ( "name" )
		local data = self:getCharacterData ( location, class, name )
		if ( data ) then
			self.manager.characters.locBox:SetText ( tostring ( location ) )
			self.manager.characters.classBox:SetText ( tostring ( class ) )
			self.manager.characters.nameBox:SetText ( tostring ( name ) )
			self.manager.characters.posBox:SetText ( tostring ( data.position ) )
			self.manager.characters.angleBox:SetText ( tostring ( data.angle ) )
			self.manager.characters.modelsList:Clear ( )
			self.modelsInList = { }
			if ( type ( data.models ) == "table" ) then
				for index, model in ipairs ( data.models ) do
					self:addCharacterModel ( model, true )
				end
			end
			if ( type ( data.weapons ) == "table" ) then
				if ( type ( data.weapons [ "Primary" ] ) == "table" ) then
					self.manager.characters.wPrimaryMenu:SelectItem ( self.manager.characters.wPrimaryItems [ self.weaponNames [ tonumber ( data.weapons [ "Primary" ] [ 1 ] ) ] or "None" ] )
					self.manager.characters.wPrimaryClip:SetText ( tostring ( data.weapons [ "Primary" ] [ 2 ] ) or "0" )
					self.manager.characters.wPrimaryExtra:SetText ( tostring ( data.weapons [ "Primary" ] [ 3 ] ) or "0" )
				end
				if ( type ( data.weapons [ "Left" ] ) == "table" ) then
					self.manager.characters.wLeftMenu:SelectItem ( self.manager.characters.wLeftItems [ self.weaponNames [ tonumber ( data.weapons [ "Left" ] [ 1 ] ) ] or "None" ] )
					self.manager.characters.wLeftClip:SetText ( tostring ( data.weapons [ "Left" ] [ 2 ] ) or "0" )
					self.manager.characters.wLeftExtra:SetText ( tostring ( data.weapons [ "Left" ] [ 3 ] ) or "0" )
				end
				if ( type ( data.weapons [ "Right" ] ) == "table" ) then
					self.manager.characters.wRightMenu:SelectItem ( self.manager.characters.wRightItems [ self.weaponNames [ tonumber ( data.weapons [ "Right" ] [ 1 ] ) ] or "None" ] )
					self.manager.characters.wRightClip:SetText ( tostring ( data.weapons [ "Right" ] [ 2 ] ) or "0" )
					self.manager.characters.wRightExtra:SetText ( tostring ( data.weapons [ "Right" ] [ 3 ] ) or "0" )
				end
			end
			self.manager.characters.camBox:SetText ( tostring ( data.camera ) )
			self.manager.characters.camAngleBox:SetText ( tostring ( data.cameraAngle ) )
			self.manager.characters.descBox:SetText ( tostring ( data.description or "" ) )
		end
	end
end

function SpawnSystem:reloadCharacters ( )
	Network:Send ( "SpawnSystem:reloadManagerList", "characters" )
end

function SpawnSystem:addCharacter ( )
	local location = self.manager.characters.locBox:GetText ( )
	local class = self.manager.characters.classBox:GetText ( )
	local name = self.manager.characters.nameBox:GetText ( )
	local position = self.manager.characters.posBox:GetText ( )
	local angle = self.manager.characters.angleBox:GetText ( )
	local models = self:getModelsInList ( )
	local weapons =
		{
			[ "Primary" ] = { },
			[ "Left" ] = { },
			[ "Right" ] = { }
		}
	local primaryName = self.manager.characters.wPrimaryMenu:GetSelectedItem ( ):GetText ( )
	local primaryClip = tonumber ( self.manager.characters.wPrimaryClip:GetText ( ) ) or 0
	local primaryExtra = tonumber ( self.manager.characters.wPrimaryExtra:GetText ( ) ) or 0
	if ( primaryName ~= "None" ) then
		weapons [ "Primary" ] = { self.weaponIDs [ primaryName ], primaryClip, primaryExtra }
	end
	local leftName = self.manager.characters.wLeftMenu:GetSelectedItem ( ):GetText ( )
	local leftClip = tonumber ( self.manager.characters.wLeftClip:GetText ( ) ) or 0
	local leftExtra = tonumber ( self.manager.characters.wLeftExtra:GetText ( ) ) or 0
	if ( leftName ~= "None" ) then
		weapons [ "Left" ] = { self.weaponIDs [ leftName ], leftClip, leftExtra }
	end
	local rightName = self.manager.characters.wRightMenu:GetSelectedItem ( ):GetText ( )
	local rightClip = tonumber ( self.manager.characters.wRightClip:GetText ( ) ) or 0
	local rightExtra = tonumber ( self.manager.characters.wRightExtra:GetText ( ) ) or 0
	if ( rightName ~= "None" ) then
		weapons [ "Right" ] = { self.weaponIDs [ rightName ], rightClip, rightExtra }
	end
	local camPos = self.manager.characters.camBox:GetText ( )
	local camAngle = self.manager.characters.camAngleBox:GetText ( )
	local description = self.manager.characters.descBox:GetText ( )
	if ( location ~= "" and class ~= "" and name ~= "" and position ~= "" and angle ~= "" and camPos ~= "" and camAngle ~= "" ) then
		if ( #models > 0 ) then
			if ( not self.spawns [ location ] ) then
				sendMessage ( "There's no location with this name.", "err" )
				return false
			end

			if ( not self.spawns [ location ] [ "classes" ] [ class ] ) then
				sendMessage ( "There's no class with this name in this location.", "err" )
				return false
			end

			if ( not self.spawns [ location ] [ "classes" ] [ class ] [ "characters" ] [ name ] ) then
				Network:Send ( "SpawnSystem:addCharacter", { location = location, class = class, name = name, position = position, angle = angle, models = models, weapons = weapons, camera = camPos, cameraAngle = camAngle, description = description } )
			else
				sendMessage ( "A character with this name already exists on that location and class.", "err" )
			end
		else
			sendMessage ( "You must add at least one model.", "err" )
		end
	else
		sendMessage ( "One or more required fields must be filled.", "err" )
	end
end

function SpawnSystem:updateCharacter ( )
	local row = self.manager.characters.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local class = row:GetDataString ( "class" )
		local name = row:GetDataString ( "name" )
		local position = self.manager.characters.posBox:GetText ( )
		local angle = self.manager.characters.angleBox:GetText ( )
		local models = self:getModelsInList ( )
		local weapons =
			{
				[ "Primary" ] = { },
				[ "Left" ] = { },
				[ "Right" ] = { }
			}
		local primaryName = self.manager.characters.wPrimaryMenu:GetSelectedItem ( ):GetText ( )
		local primaryClip = tonumber ( self.manager.characters.wPrimaryClip:GetText ( ) ) or 0
		local primaryExtra = tonumber ( self.manager.characters.wPrimaryExtra:GetText ( ) ) or 0
		if ( primaryName ~= "None" ) then
			weapons [ "Primary" ] = { self.weaponIDs [ primaryName ], primaryClip, primaryExtra }
		end
		local leftName = self.manager.characters.wLeftMenu:GetSelectedItem ( ):GetText ( )
		local leftClip = tonumber ( self.manager.characters.wLeftClip:GetText ( ) ) or 0
		local leftExtra = tonumber ( self.manager.characters.wLeftExtra:GetText ( ) ) or 0
		if ( leftName ~= "None" ) then
			weapons [ "Left" ] = { self.weaponIDs [ leftName ], leftClip, leftExtra }
		end
		local rightName = self.manager.characters.wRightMenu:GetSelectedItem ( ):GetText ( )
		local rightClip = tonumber ( self.manager.characters.wRightClip:GetText ( ) ) or 0
		local rightExtra = tonumber ( self.manager.characters.wRightExtra:GetText ( ) ) or 0
		if ( rightName ~= "None" ) then
			weapons [ "Right" ] = { self.weaponIDs [ rightName ], rightClip, rightExtra }
		end
		local camPos = self.manager.characters.camBox:GetText ( )
		local camAngle = self.manager.characters.camAngleBox:GetText ( )
		local description = self.manager.characters.descBox:GetText ( )
		if ( location ~= "" and class ~= "" and name ~= "" and position ~= "" and angle ~= "" and camPos ~= "" and camAngle ~= "" ) then
			if ( #models > 0 ) then
				if ( not self.spawns [ location ] ) then
					sendMessage ( "There's no location with this name.", "err" )
					return false
				end

				if ( not self.spawns [ location ] [ "classes" ] [ class ] ) then
					sendMessage ( "There's no class with this name in this location.", "err" )
					return false
				end

				Network:Send ( "SpawnSystem:updateCharacter", { location = location, class = class, name = name, position = position, angle = angle, models = models, weapons = weapons, camera = camPos, cameraAngle = camAngle, description = description } )
			else
				sendMessage ( "You must add at least one model.", "err" )
			end
		else
			sendMessage ( "One or more required fields must be filled.", "err" )
		end
	else
		sendMessage ( "You must select a character to update.", "err" )
	end
end

function SpawnSystem:removeCharacter ( )
	local row = self.manager.characters.list:GetSelectedRow ( )
	if ( row ) then
		local location = row:GetDataString ( "location" )
		local class = row:GetDataString ( "class" )
		local name = row:GetDataString ( "name" )
		Network:Send ( "SpawnSystem:removeCharacter", { location = location, class = class, name = name } )
	else
		sendMessage ( "You must select a character to remove.", "err" )
	end
end

function SpawnSystem:addCharacterModel ( model_, msg )
	local model = tonumber ( ( type ( model_ ) == "number" and model_ ) or self.manager.characters.modelsBox:GetText ( ) )
	if ( self.modelNames [ model ] ) then
		if ( not self.modelsInList [ model ] ) then
			local item = self.manager.characters.modelsList:AddItem ( tostring ( model ) )
			local modelName = ( self.modelNames [ model ] and self.modelNames [ model ] or "Unknown" )
			item:SetCellText ( 1, tostring ( modelName ) )
			item:SetDataNumber ( "model", model )
			self.modelsInList [ model ] = true
		end
	else
		if ( not msg ) then
			sendMessage ( "Invalid model", "err" )
		end
	end
end

function SpawnSystem:removeCharacterModel ( )
	local row = self.manager.characters.modelsList:GetSelectedRow ( )
	if ( row ) then
		local model = row:GetDataNumber ( "model" )
		self.manager.characters.modelsList:RemoveItem ( row )
		self.modelsInList [ model ] = nil
	end
end

function SpawnSystem:getPosition ( )
	self.manager.characters.posBox:SetText ( tostring ( LocalPlayer:GetPosition ( ) ) )
end

function SpawnSystem:getAngle ( )
	self.manager.characters.angleBox:SetText ( tostring ( LocalPlayer:GetAngle ( ) ) )
end

function SpawnSystem:getLocationData ( location, data )
	if ( self.spawns [ location ] ) then
		if ( data ) then
			return self.spawns [ location ] [ data ]
		else
			return self.spawns [ location ]
		end
	else
		return false
	end
end

function SpawnSystem:getClassData ( location, class, data )
	if ( self.spawns [ location ] ) then
		if ( self.spawns [ location ] [ "classes" ] [ class ] ) then
			if ( data ) then
				return self.spawns [ location ] [ "classes" ] [ class ] [ data ]
			else
				return self.spawns [ location ] [ "classes" ] [ class ]
			end
		else
			return false
		end
	else
		return false
	end
end

function SpawnSystem:getCharacterData ( location, class, char, data )
	if ( self.spawns [ location ] ) then
		if ( self.spawns [ location ] [ "classes" ] [ class ] ) then
			if ( self.spawns [ location ] [ "classes" ] [ class ] [ "characters" ] [ char ] ) then
				if ( data ) then
					return self.spawns [ location ] [ "classes" ] [ class ] [ "characters" ] [ char ] [ data ]
				else
					return self.spawns [ location ] [ "classes" ] [ class ] [ "characters" ] [ char ]
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function SpawnSystem:getModelsInList ( )
	local models = { }
	for model in pairs ( self.modelsInList ) do
		table.insert ( models, model )
	end

	return models
end

function sendMessage ( text, color )
	Chat:Print ( tostring ( text ), msgColors [ color or "info" ] )
end

spawnSystem = SpawnSystem ( )