local F4Menu  
local F4MenuTabs
local F4Tabs
local hasReleasedF4 = false
local function ChangeJobVGUI()
	if not F4Menu or not F4Menu:IsValid() then
		F4Menu = vgui.Create("DFrame")
		F4Menu:SetSize(770, 580)
		F4Menu:Center()
		F4Menu:SetVisible( true )
		F4Menu:MakePopup( )
		F4Menu:SetTitle("Options menu")
		F4Tabs = {MoneyTab(), JobsTab(), EntitiesTab(), InventoryTab(), SkillsTab(), SkinsTab(), Help = HelpTab(F4Menu:GetWide())}
		
		--[[if LocalPlayer():IsAdmin() then
			table.insert(F4Tabs, RPAdminTab())
		end]]
		--[[if LocalPlayer():IsSuperAdmin() then
			table.insert(F4Tabs, RPLicenseWeaponsTab())
		end]]
		F4Menu:SetSkin("LiquidDRP2")
	else
		F4Menu:SetVisible(true)
		F4Menu:SetSkin("LiquidDRP2")
	end
	
	hasReleasedF4 = false
	--[[function F4Menu:Think()
		if input.IsKeyDown(KEY_F4) and hasReleasedF4 then
			self:Close()
		elseif not input.IsKeyDown(KEY_F4) then
			hasReleasedF4 = true
		end
		if (!self.Dragging) then return end 
		local x = gui.MouseX() - self.Dragging[1] 
		local y = gui.MouseY() - self.Dragging[2] 
		x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
		y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
		self:SetPos( x, y )
	end]]
	
	if not F4MenuTabs or not F4MenuTabs:IsValid() then
		F4MenuTabs = vgui.Create( "DPropertySheet", F4Menu)
		F4MenuTabs:SetPos(5, 25)
		F4MenuTabs:Dock( FILL )
		--The tabs: Look in showteamtabs.lua for more info
		F4MenuTabs:AddSheet("Money/Commands", F4Tabs[1], "icon16/money.png", false, false)
		F4MenuTabs:AddSheet("Jobs", F4Tabs[2], "icon16/group.png", false, false)
		F4MenuTabs:AddSheet("Shop", F4Tabs[3], "icon16/brick_add.png", false, false)
		F4MenuTabs:AddSheet("Inventory", F4Tabs[4], "icon16/box.png", false, false)
		F4MenuTabs:AddSheet("Skills", F4Tabs[5], "icon16/application_view_detail.png", false, false)
		F4MenuTabs:AddSheet("Themes", F4Tabs[6], "icon16/ruby.png", false, false)
		F4MenuTabs:AddSheet(F4Tabs["Help"].TabName, F4Tabs["Help"].Panel, F4Tabs["Help"].TabIcon, false, false)
		
		--Disabling admin menu: Settings are moving to config.lua (but consider re-adding the admin tab)
		--[[if LocalPlayer():IsAdmin() or LocalPlayer().DarkRPVars.Privadmin then
			print("Adminifing")
			PrintTable(F4Tabs)
			F4MenuTabs:AddSheet("Admin", F4Tabs[7], "icon16/wrench.png", false, false)
		end]]
		--[[if LocalPlayer():IsSuperAdmin() then
			F4MenuTabs:AddSheet("License weapons", F4Tabs[7], "gui/silkicons/wrench", false, false)
		end]]--
	end

	for _, panel in pairs(F4Tabs) do
		if panel.Update then
			panel:Update()
		elseif panel.Panel and panel.Panel.Update then
			panel.Panel:Update()
		end
		
		if panel.Panel then
			panel.Panel:SetSkin("LiquidDRP2")
		else
			panel:SetSkin("LiquidDRP2")
		end
	end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
		F4Menu:SetSkin("LiquidDRP2")
	end 

	F4Menu:SetSkin("LiquidDRP2")
end
usermessage.Hook("ChangeJobVGUI", ChangeJobVGUI)

local function DoLetter(msg)
	LetterWritePanel = vgui.Create("Frame")
	LetterWritePanel:SetPos(ScrW() / 2 - 75, ScrH() / 2 - 100)
	LetterWritePanel:SetSize(150, 200)
	LetterWritePanel:SetMouseInputEnabled(true)
	LetterWritePanel:SetKeyboardInputEnabled(true)
	LetterWritePanel:SetVisible(true)
end
usermessage.Hook("DoLetter", DoLetter)