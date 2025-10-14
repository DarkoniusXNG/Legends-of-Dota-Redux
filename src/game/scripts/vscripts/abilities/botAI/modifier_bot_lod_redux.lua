modifier_bot_lod_redux = modifier_bot_lod_redux or class({})

function modifier_bot_lod_redux:IsHidden()
	return true
end

function modifier_bot_lod_redux:RemoveOnDeath()
	return false
end

function modifier_bot_lod_redux:IsPermanent()
	return true
end

function modifier_bot_lod_redux:IsPurgable()
	return false
end

function modifier_bot_lod_redux:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local team = parent:GetTeam()
		self.difficulty = 1
		if team == DOTA_TEAM_GOODGUYS then
			self.difficulty = OptionManager:GetOption('radiantBotDiff')
		elseif team == DOTA_TEAM_BADGUYS then
			self.difficulty = OptionManager:GetOption('direBotDiff')
		end
		self:OnIntervalThink()
		self:StartIntervalThink(30)
	end
end

local item_builds = {
	npc_dota_hero_axe = {
		"item_bracer",
		"item_phase_boots",
		"item_vanguard",
		"item_blade_mail",
		"item_blink",
		"item_black_king_bar",
		"item_lotus_orb",
		"item_ultimate_scepter",
	},
	npc_dota_hero_bane = {
		"item_bracer",
		"item_wraith_band",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_phylactery",
		"item_ultimate_scepter",
		"item_platemail",
		"item_soul_booster",
		"item_mystic_staff",
	},
	npc_dota_hero_bloodseeker = {
		"item_wraith_band",
		"item_phase_boots",
		"item_maelstrom",
		"item_sange",
		"item_black_king_bar",
		"item_lesser_crit",
		"item_demon_edge",
		"item_ultimate_scepter",
	},
	npc_dota_hero_bounty_hunter = {
		"item_arcane_boots",
		"item_urn_of_shadows",
		"item_force_staff",
		"item_pavise",
		"item_orchid",
		"item_lotus_orb",
		"item_ultimate_scepter",
	},
	npc_dota_hero_bristleback = {
		"item_bracer",
		"item_soul_ring",
		"item_power_treads",
		"item_vanguard",
		"item_blade_mail",
		"item_reaver",
		"item_hyperstone",
		"item_black_king_bar",
	},
	npc_dota_hero_chaos_knight = {
		"item_bracer",
		"item_power_treads",
		"item_armlet",
		"item_yasha",
		"item_orchid",
		"item_blink",
		"item_reaver",
		"item_ultimate_scepter",
	},
	npc_dota_hero_crystal_maiden = {
		"item_bracer",
		"item_tranquil_boots",
		--"item_glimmer_cape",
		"item_ghost",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_rod_of_atos",
		"item_sphere",
		"item_mystic_staff",
	},
	npc_dota_hero_dazzle = {
		"item_bracer",
		"item_wraith_band",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_magic_wand",
		"item_force_staff",
		"item_soul_booster",
		"item_ultimate_scepter",
		"item_mystic_staff",
	},
	npc_dota_hero_death_prophet = {
		"item_bracer",
		"item_wraith_band",
		"item_power_treads",
		"item_cyclone",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_veil_of_discord",
		--"item_hyperstone",
		"item_pipe",
	},
	npc_dota_hero_dragon_knight = {
		"item_bracer",
		"item_soul_ring",
		"item_power_treads",
		"item_maelstrom",
		"item_mage_slayer",
		"item_blink",
		"item_black_king_bar",
		"item_orchid",
		"item_ultimate_scepter",
	},
	npc_dota_hero_drow_ranger = {
		"item_wraith_band",
		"item_orb_of_corrosion",
		"item_power_treads",
		"item_dragon_lance",
		"item_yasha",
		"item_eagle",
		"item_lesser_crit",
		"item_black_king_bar",
		"item_ultimate_scepter",
	},
	npc_dota_hero_earthshaker = {
		"item_bracer",
		"item_arcane_boots",
		"item_blink",
		"item_cyclone",
		"item_kaya",
		"item_black_king_bar",
		"item_rod_of_atos",
	},
	npc_dota_hero_jakiro = {
		"item_bracer",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_cyclone",
		"item_ultimate_scepter",
		"item_rod_of_atos",
		"item_mystic_staff",
		"item_soul_booster",
	},
	npc_dota_hero_juggernaut = {
		"item_wraith_band",
		"item_power_treads",
		"item_orb_of_corrosion",
		"item_maelstrom",
		"item_yasha",
		"item_nullifier",
		"item_demon_edge",
		"item_abyssal_blade",
	},
	npc_dota_hero_kunkka = {
		"item_bracer",
		"item_phase_boots",
		"item_blade_mail",
		"item_orchid",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_reaver",
		"item_lesser_crit",
	},
	npc_dota_hero_lich = {
		"item_bracer",
		"item_tranquil_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_force_staff",
		"item_blink",
		"item_platemail",
		"item_mystic_staff",
	},
	npc_dota_hero_lina = {
		"item_null_talisman",
		"item_phase_boots",
		"item_maelstrom",
		"item_dragon_lance",
		"item_black_king_bar",
		"item_lesser_crit",
		"item_satanic",
	},
	npc_dota_hero_lion = {
		"item_bracer",
		"item_tranquil_boots",
		"item_blink",
		"item_aether_lens",
		--"item_glimmer_cape",
		"item_force_staff",
		"item_ultimate_scepter",
		"item_lotus_orb",
		"item_mystic_staff",
	},
	npc_dota_hero_luna = {
		"item_wraith_band",
		"item_power_treads",
		"item_mask_of_madness",
		"item_yasha",
		"item_black_king_bar",
		"item_lesser_crit",
		"item_ultimate_scepter",
		"item_eagle",
	},
	npc_dota_hero_necrolyte = {
		"item_null_talisman",
		"item_arcane_boots",
		"item_reaver",
		"item_relic",
		"item_ultimate_scepter",
		"item_pipe",
		"item_sange",
		"item_black_king_bar",
	},
	npc_dota_hero_nevermore = {
		"item_wraith_band",
		"item_power_treads",
		"item_dragon_lance",
		"item_yasha",
		"item_black_king_bar",
		"item_lesser_crit",
		"item_mask_of_madness",
		"item_ultimate_scepter",
	},
	npc_dota_hero_omniknight = {
		"item_relic",
		"item_bracer",
		"item_soul_ring",
		"item_phase_boots",
		"item_aether_lens",
		"item_magic_wand",
		"item_sange",
		"item_echo_sabre",
	},
	npc_dota_hero_oracle = {
		"item_null_talisman",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_magic_wand",
		"item_aeon_disk",
		"item_mystic_staff",
		"item_ultimate_scepter",
		"item_soul_booster",
	},
	npc_dota_hero_phantom_assassin = {
		"item_wraith_band",
		"item_orb_of_corrosion",
		"item_power_treads",
		"item_bfury",
		"item_black_king_bar",
		"item_desolator",
		"item_nullifier",
		"item_satanic",
	},
	npc_dota_hero_pudge = {
		"item_bracer",
		"item_phase_boots",
		"item_vanguard",
		"item_blade_mail",
		"item_ultimate_scepter",
		"item_kaya",
		"item_black_king_bar",
		"item_bloodstone",
	},
	npc_dota_hero_sand_king = {
		"item_bracer",
		"item_wraith_band",
		"item_phase_boots",
		"item_blade_mail",
		"item_blink",
		"item_yasha_and_kaya",
		"item_ultimate_scepter",
		"item_revenants_brooch",
		"item_veil_of_discord",
	},
	npc_dota_hero_skeleton_king = {
		"item_bracer",
		"item_power_treads",
		"item_soul_ring",
		"item_armlet",
		"item_relic",
		"item_sange",
		"item_hyperstone",
		"item_ultimate_scepter",
		"item_blade_mail",
	},
	npc_dota_hero_skywrath_mage = {
		"item_null_talisman",
		"item_arcane_boots",
		"item_rod_of_atos",
		"item_aether_lens",
		"item_kaya",
		"item_ultimate_scepter",
		"item_mystic_staff",
		"item_wind_waker",
	},
	npc_dota_hero_sniper = {
		"item_wraith_band",
		"item_power_treads",
		"item_maelstrom",
		"item_dragon_lance",
		"item_lesser_crit",
		"item_demon_edge",
		"item_mask_of_madness",
		"item_ultimate_scepter",
	},
	npc_dota_hero_sven = {
		"item_bracer",
		"item_power_treads",
		"item_echo_sabre",
		"item_black_king_bar",
		"item_lesser_crit",
		"item_mask_of_madness",
		"item_abyssal_blade",
	},
	npc_dota_hero_tiny = {
		"item_bracer",
		"item_phase_boots",
		"item_echo_sabre",
		"item_blink",
		"item_black_king_bar",
		"item_hyperstone",
		"item_lesser_crit",
	},
	npc_dota_hero_vengefulspirit = {
		"item_wraith_band",
		"item_power_treads",
		"item_ultimate_scepter",
		"item_dragon_lance",
		"item_vladmir",
		"item_yasha",
		"item_eagle",
		"item_disperser",
	},
	npc_dota_hero_viper = {
		"item_wraith_band",
		"item_null_talisman",
		"item_orb_of_corrosion",
		"item_power_treads",
		"item_dragon_lance",
		"item_yasha_and_kaya",
		"item_skadi",
		"item_veil_of_discord",
		"item_witch_blade",
	},
	npc_dota_hero_warlock = {
		"item_null_talisman",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_aether_lens",
		"item_magic_wand",
		"item_ultimate_scepter",
		"item_refresher",
		"item_wind_waker",
		"item_mystic_staff",
	},
	npc_dota_hero_windrunner = {
		"item_wraith_band",
		"item_bracer",
		"item_power_treads",
		"item_maelstrom",
		"item_black_king_bar",
		"item_demon_edge",
		"item_lesser_crit",
		"item_satanic",
		"item_ultimate_scepter",
	},
	npc_dota_hero_witch_doctor = {
		"item_magic_wand",
		"item_arcane_boots",
		--"item_glimmer_cape",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_platemail",
		"item_aeon_disk",
		"item_ghost",
	},
	npc_dota_hero_zuus = {
		"item_null_talisman",
		"item_arcane_boots",
		"item_kaya",
		"item_phylactery",
		"item_aether_lens",
		"item_soul_booster",
		"item_refresher",
	},
}

local upgrade_map = {
	item_aether_lens = "item_ethereal_blade",
	item_arcane_boots = "item_guardian_greaves",
	item_bfury = "item_rapier",
	item_blink = "item_overwhelming_blink",
	item_cyclone = "item_wind_waker",
	item_demon_edge = "item_monkey_king_bar",
	item_dragon_lance = "item_hurricane_pike",
	item_eagle = "item_butterfly",
	item_echo_sabre = "item_harpoon",
	item_ghost = "item_ethereal_blade",
	item_hyperstone = "item_assault",
	item_kaya = "item_kaya_and_sange",
	item_lesser_crit = "item_greater_crit",
	item_maelstrom = "item_mjollnir",
	item_magic_wand = "item_holy_locket",
	item_mask_of_madness = "item_satanic",
	item_mystic_staff = "item_sheepstick",
	item_orchid = "item_bloodthorn",
	item_pavise = "item_solar_crest",
	--item_phase_boots = "item_travel_boots_2",
	item_phylactery = "item_angels_demise",
	item_platemail = "item_shivas_guard",
	--item_power_treads = "item_travel_boots_2",
	item_reaver = "item_heart",
	item_relic = "item_radiance",
	item_rod_of_atos = "item_gungir",
	item_sange = "item_sange_and_yasha",
	item_soul_booster = "item_octarine_core",
	item_tranquil_boots = "item_boots_of_bearing",
	item_urn_of_shadows = "item_spirit_vessel",
	item_vanguard = "item_crimson_guard",
	item_veil_of_discord = "item_shivas_guard",
	item_witch_blade = "item_devastator",
	item_yasha = "item_manta",
}

local sell_first = {
	item_bfury = 1,
	item_mask_of_madness = 1,
	--item_phase_boots = 1,
	--item_power_treads = 1,
}

local early_game_items = {
	item_bracer = 1,
	item_null_talisman = 1,
	item_orb_of_corrosion = 1,
	item_soul_ring = 1,
	item_wraith_band = 1,
}

local items_to_sell = {
	item_blades_of_attack = 1,
	item_blood_grenade = 1,
	item_boots = 1,
	item_branches = 1,
	item_chainmail = 1,
	item_circlet = 1,
	item_clarity = 1,
	item_crown = 1,
	item_flask = 1,
	item_gauntlets = 1,
	item_magic_stick = 1,
	item_mantle = 1,
	item_quelling_blade = 1,
	item_recipe_magic_wand = 1,
	item_ring_of_basilius = 1,
	item_ring_of_protection = 1,
	item_slippers = 1,
	item_tango = 1,
	item_tiara_of_selemene = 1,
}
function modifier_bot_lod_redux:OnIntervalThink()
  local parent = self:GetParent()
  -- local playerID
  -- if parent.GetPlayerID then
    -- playerID = parent:GetPlayerID()
  -- elseif parent.GetPlayerOwnerID then
    -- playerID = parent:GetPlayerOwnerID()
  -- end
  --local gold2 = PlayerResource:GetGold(playerID)
  --if parent:GetGold() < 200 then
    -- Bots are actually spending their gold then
    --return
  --end

  if (self.difficulty == 1 or (self.difficulty == 5 and parent:HasModifier("modifier_easybot"))) then
    self:StartIntervalThink(-1)
    self:Destroy()
    return
  end

  if (self.difficulty <= 3 or (self.difficulty == 5 and not parent:HasModifier("modifier_unfairbot"))) and not IsNearFriendlyClass(parent, 1800, "ent_dota_fountain") then
    return
  end

  if GameRules:GetGameTime() > 4*60 and not self:HasRoomForItemCustom() and IsNearFriendlyClass(parent, 1200, "ent_dota_fountain") then
    for slot = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
      local item = parent:GetItemInSlot(slot)
      if item then
        local item_name = item:GetAbilityName()
        if items_to_sell[item_name] then
          print("Removing "..tostring(item_name).." at "..tostring(GetSystemTime()).." ("..tostring(GameRules:GetGameTime())..")")
          local gold_value = math.floor(GetItemCost(item_name) / 2)
          parent:ModifyGold(gold_value, true, DOTA_ModifyGold_SellItem)
          item:RemoveSelf()
          break
        end
      end
    end
  end

  local name = parent:GetUnitName()
  local purchased = false
  for _, item_name in ipairs(item_builds[name]) do
    local item = parent:FindItemByName(item_name)
    if not item then
      -- Doesnt have the item -> purchase it if possible
      if (GameRules:GetGameTime() >= 12*60 and early_game_items[item_name]) or (item_name == "item_ultimate_scepter" and parent:HasModifier("modifier_item_ultimate_scepter_consumed")) then
        -- Do not purchase early game items after 12 min or aghs if they have the buff
      elseif upgrade_map[item_name] then
        -- Check if we have the upgraded item first
        local upgraded_item = parent:FindItemByName(upgrade_map[item_name])
        if not upgraded_item then
          -- We dont have the upgrade for this item, so purchase the item
          local gold_cost = GetItemCost(item_name)
          if parent:GetGold() >= gold_cost and self:HasRoomForItemCustom() then
            parent:ModifyGold(-gold_cost, true, DOTA_ModifyGold_PurchaseItem)
            parent:AddItemByName(item_name)
            purchased = true
          end
        end
      else
        -- We dont have the upgrade for this item, so purchase the item
        local gold_cost = GetItemCost(item_name)
        if parent:GetGold() >= gold_cost and (self:HasRoomForItemCustom() or item_name == "item_ultimate_scepter") then
          parent:ModifyGold(-gold_cost, true, DOTA_ModifyGold_PurchaseItem)
          parent:AddItemByName(item_name)
          purchased = true
        end
      end
    else
      -- Has the item
      if GameRules:GetGameTime() >= 10*60 and early_game_items[item_name] and not self:HasRoomForItemCustom() and IsNearFriendlyClass(parent, 1200, "ent_dota_fountain") then
        print("Removing "..tostring(item_name).." at "..tostring(GetSystemTime()).." ("..tostring(GameRules:GetGameTime())..")")
        -- Has the early game item, we can sell it if we dont have the free slot
        local gold_value = math.floor(GetItemCost(item_name) / 2)
        parent:ModifyGold(gold_value, true, DOTA_ModifyGold_SellItem)
        parent:RemoveItemByName(item_name)
      end
      -- if item_name == "item_magic_wand" and parent:FindItemByName("item_magic_stick") then
        -- local gold_value = math.floor(GetItemCost("item_magic_stick") / 2)
        -- parent:ModifyGold(gold_value, true, DOTA_ModifyGold_SellItem)
        -- parent:RemoveItemByName("item_magic_stick")
      -- end
      if item_name == "item_ultimate_scepter" and (GameRules:GetGameTime() > 20*60 or not self:HasRoomForItemCustom()) and IsNearFriendlyClass(parent, 1200, "ent_dota_fountain") then
        -- Consume aghs if possible after 25 min or if no room
        local recipe_name = "item_recipe_ultimate_scepter_2"
        local recipe_cost = GetItemCost(recipe_name)
        if parent:GetGold() >= recipe_cost then
          print("Removing "..tostring(item_name).." at "..tostring(GetSystemTime()).." ("..tostring(GameRules:GetGameTime())..")")
          parent:ModifyGold(-recipe_cost, true, DOTA_ModifyGold_PurchaseItem)
          --parent:AddItemByName(recipe_name) -- giving them the recipe doesnt consume the aghs, so we grant them the modifier instead
          parent:RemoveItemByName(item_name)
          parent:AddNewModifier(parent, nil, "modifier_item_ultimate_scepter_consumed", {})
          purchased = true
        end
      end
      -- Has the item, check if item has an upgrade, upgrade if possible after 10 min
      if upgrade_map[item_name] and GameRules:GetGameTime() >= 10*60 then
        local upgraded_item = parent:FindItemByName(upgrade_map[item_name])
        if not upgraded_item then
          -- We dont have the upgraded item, so simulate the purchase of other components of the upgraded item
          local gold_cost_upgrade = GetItemCost(upgrade_map[item_name])
          local gold_cost_base = GetItemCost(item_name)
          local diff = gold_cost_upgrade - gold_cost_base
          if sell_first[item_name] then
            local diff2 = gold_cost_upgrade - (gold_cost_base/2)
            if parent:GetGold() >= diff2 and GameRules:GetGameTime() > 20*60 and not self:HasRoomForItemCustom() and IsNearFriendlyClass(parent, 1200, "ent_dota_fountain") then
              print("Removing "..tostring(item_name).." at "..tostring(GetSystemTime()).." ("..tostring(GameRules:GetGameTime())..")")
              parent:ModifyGold(-diff2, true, DOTA_ModifyGold_PurchaseItem)
              parent:RemoveItemByName(item_name)
              parent:AddItemByName(upgrade_map[item_name])
              purchased = true
            end
          elseif parent:GetGold() >= diff and not self:HasRoomForItemCustom() and IsNearFriendlyClass(parent, 1200, "ent_dota_fountain") then
            print("Removing "..tostring(item_name).." at "..tostring(GetSystemTime()).." ("..tostring(GameRules:GetGameTime())..")")
            parent:ModifyGold(-diff, true, DOTA_ModifyGold_PurchaseItem)
            parent:RemoveItemByName(item_name)
            parent:AddItemByName(upgrade_map[item_name])
            purchased = true
          end
        end
      end
    end
    if purchased then
      break
    end
  end
end

function modifier_bot_lod_redux:HasRoomForItemCustom()
  local parent = self:GetParent()
  -- Iterate over item slots
  local bHasRoom = false
  -- Normal slots
  for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
    local item = parent:GetItemInSlot(i)
    if not item then
      bHasRoom = true
      break
    end
  end

  return bHasRoom
end

function modifier_bot_lod_redux:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_RESPAWN,
  }
end

if IsServer() then
  function modifier_bot_lod_redux:OnRespawn(event)
    local parent = self:GetParent()
    local unit = event.unit
    if unit ~= parent then
      return
    end
    if self.difficulty == 4 or (self.difficulty == 5 and parent:HasModifier("modifier_unfairbot")) then
      parent:ModifyGold(1000, true, DOTA_ModifyGold_SellItem)
    end
    self:OnIntervalThink()
  end
end
