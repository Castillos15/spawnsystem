class "GUI"

local textBoxTypes =
	{
		[ "text" ] = TextBox,
		[ "numeric" ] = TextBoxNumeric,
		[ "multiline" ] = TextBoxMultiline,
		[ "password" ] = PasswordTextBox
	}

function GUI:Window ( title, pos, size )
	local window = Window.Create ( )
	window:SetTitle ( title )
	window:SetPositionRel ( pos )
	window:SetSizeRel ( size )

	return window
end

function GUI:Button ( text, pos, size, parent )
	local button = Button.Create ( )
	button:SetText ( text )
	if ( parent ) then
		button:SetParent ( parent )
	end
	button:SetPositionRel ( pos )
	button:SetSizeRel ( size )

	return button
end

function GUI:Label ( text, pos, size, parent )
	local label = Label.Create ( )
	label:SetText ( text )
	if ( parent ) then
		label:SetParent ( parent )
	end
	label:SetPositionRel ( pos )
	label:SetSizeRel ( size )

	return label
end

function GUI:SortedList ( pos, size, parent, columns )
	local list = SortedList.Create ( )
	if ( parent ) then
		list:SetParent ( parent )
	end
	list:SetPositionRel ( pos )
	list:SetSizeRel ( size )
	if ( type ( columns ) == "table" and #columns > 0 ) then
		for _, col in ipairs ( columns ) do
			if tonumber ( col.width ) then
				list:AddColumn ( tostring ( col.name ), tonumber ( col.width ) )
			else
				list:AddColumn ( tostring ( col.name ) )
			end
		end
	end

	return list
end

function GUI:TextBox ( text, pos, size, type, parent )
	local func = textBoxTypes [ type ]
	if ( func ) then
		local textBox = func.Create ( )
		if ( parent ) then
			textBox:SetParent ( parent )
		end
		textBox:SetText ( text )
		textBox:SetPositionRel ( pos )
		textBox:SetSizeRel ( size )

		return textBox
	else
		return false
	end
end

function GUI:ComboBox ( pos, size, parent, items )
	local menuItems = { }
	local comboBox = ComboBox.Create ( )
	if ( parent ) then
		comboBox:SetParent ( parent )
	end
	comboBox:SetPositionRel ( pos )
	comboBox:SetSizeRel ( size )
	if ( type ( items ) == "table" and #items > 0 ) then
		for index, item in ipairs ( items ) do
			menuItems [ item ] = comboBox:AddItem ( item )
		end
	end

	return comboBox, menuItems
end

function GUI:ListBox ( pos, size, parent, label )
	local list = ListBox.Create ( )
	if ( parent ) then
		list:SetParent ( parent )
	end
	list:SetPositionRel ( pos )
	list:SetSizeRel ( size )
	if ( label ) then
		tLabel = Label.Create ( )
		if ( parent ) then
			tLabel:SetParent ( parent )
		end
		tLabel:SetText ( label )
		tLabel:SetPositionRel ( Vector2 ( pos.x, pos.y - 0.031 ) )
		tLabel:SetSizeRel ( size )
		tLabel:SetAlignment ( 64 )
	end

	return list, tLabel
end

function GUI:CollapsibleList ( pos, size, parent, categories )
	local cats = { }
	local list = CollapsibleList.Create ( )
	if ( parent ) then
		list:SetParent ( parent )
	end
	list:SetPositionRel ( pos )
	list:SetSizeRel ( size )
	if ( type ( categories ) == "table" and #categories > 0 ) then
		for _, cat in ipairs ( categories ) do
			table.insert ( cats, list:Add ( tostring ( cat ) ) )
		end
	end

	return list, cats
end

function GUI:ScrollControl ( pos, size, parent )
	local scroll = ScrollControl.Create ( )
	if ( parent ) then
		scroll:SetParent ( parent )
	end
	scroll:SetPositionRel ( pos )
	scroll:SetSizeRel ( size )

	return scroll
end

function GUI:TabControl ( tabs, pos, size, parent )
	local addedTabs = { }
	local tabControl = TabControl.Create ( )
	if ( parent ) then
		tabControl:SetParent ( parent )
	end
	tabControl:SetPositionRel ( pos )
	tabControl:SetSizeRel ( size )
	if ( tabs and #tabs > 0 ) then
		for _, tab in ipairs ( tabs ) do
			addedTabs [ tab ] = { }
			addedTabs [ tab ].base = BaseWindow.Create ( )
			addedTabs [ tab ].base:SetPositionRel ( pos )
			addedTabs [ tab ].base:SetSizeRel ( size )
			if ( parent ) then
				addedTabs [ tab ].base:SetParent ( parent )
			end
			addedTabs [ tab ].page = tabControl:AddPage ( tab, addedTabs [ tab ].base )
		end
	end

	return tabControl, addedTabs
end

function GUI:ColorPicker ( isHSV, pos, size, parent )
	local func = ( isHSV and HSVColorPicker or ColorPicker )
	local picker = func.Create ( )
	if ( parent ) then
		picker:SetParent ( parent )
	end
	picker:SetPositionRel ( pos )
	picker:SetSizeRel ( size )

	return picker
end