--------------------------------------------------------------------------------------------------------
--    Hero: Alchemist
--    Perk: Greevils Greed free level + 50% refund for consuming an item
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_alchemist_perk = modifier_npc_dota_hero_alchemist_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:GetTexture()
  return "custom/npc_dota_hero_alchemist_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_alchemist_perk:OnCreated()
    
end

function modifier_npc_dota_hero_alchemist_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_alchemist_perk:OnAbilityFullyCast(event)
		local parent = self:GetParent()
		if event.unit ~= parent then
			return
		end
		local ability = event.ability
		if not ability or ability:IsNull() then
			return
		end
		local items = {
			item_tpscroll = true,
			item_faerie_fire = true,
			item_flask = true,
			item_clarity = true,
			item_enchanted_mango = true,
			item_tango = false, -- item cost is pretty high for the number of charges
			item_tango_single = true,
			item_bottle = false, -- can be used infinitely in fountain
			item_tome_of_knowledge = true,
			item_famango = 100,
			item_great_famango = 300, -- 3 x item_famango
			item_greater_famango = 600, -- 2 x item_great_famango
			item_royale_with_cheese = 2800, -- 3 x item_greater_famango + 1 x item_cheese
			item_cheese = true,
			item_refresher_shard = true,
			item_royal_jelly = false, -- item cost is pretty high and infinite charges
			item_elixer = 100,
			item_greater_faerie_fire = 100,
			item_tome_of_aghanim = 300,
			item_fusion_rune = 600,
			item_ultimate_scepter = true,
			--item_ultimate_scepter_2 = true, -- doesn't work
			item_ultimate_scepter_roshan = true,
			item_moon_shard = true,
			--item_aghanims_shard = true, -- handled with OnModifierAdded
			--item_aghanims_shard_roshan = true, -- handled with OnModifierAdded
		}

		if ability:IsItem() then
			local name = ability:GetAbilityName()
			local cost = 0
			if items[name] then
				cost = GetItemCost(name)
				if cost < 10 and items[name] ~= true and type(items[name]) == "number" then
					cost = items[name]
				end
			elseif string.find(name, "consumable") then
				cost = ability:GetGoldCost(-1)
			end

			-- Add half of the gold cost
			parent:ModifyGold(cost * 0.5, true, DOTA_ModifyGold_Unspecified)
			
			local value = cost * 0.5
			local symbol = 0 -- "+" presymbol
			local color = Vector(255, 200, 33) -- Gold
			local lifetime = 2.0
			local digits = string.len(value) + 1
			local player = PlayerResource:GetPlayer(parent:GetPlayerID())
			local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
			local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_ABSORIGIN, parent, player)
			ParticleManager:SetParticleControl(particle, 1, Vector(symbol, value, symbol))
			ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
			ParticleManager:SetParticleControl(particle, 3, color)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end

	function modifier_npc_dota_hero_alchemist_perk:OnModifierAdded(event)
		local parent = self:GetParent()
		if event.unit ~= parent then
			return
		end
		local mod = event.added_buff
		if not mod then
			return
		end
		if mod:GetName() == "modifier_item_aghanims_shard" then
			local cost = GetItemCost("item_aghanims_shard")

			-- Add half of the gold cost
			parent:ModifyGold(cost * 0.5, true, DOTA_ModifyGold_Unspecified)
			
			local value = cost * 0.5
			local symbol = 0 -- "+" presymbol
			local color = Vector(255, 200, 33) -- Gold
			local lifetime = 2.0
			local digits = string.len(value) + 1
			local player = PlayerResource:GetPlayer(parent:GetPlayerID())
			local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
			local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_ABSORIGIN, parent, player)
			ParticleManager:SetParticleControl(particle, 1, Vector(symbol, value, symbol))
			ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
			ParticleManager:SetParticleControl(particle, 3, color)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
end
