--------------------------------------------------------------------------------------------------------
--
--		Hero: Walock
--		Perk: Warlock starts the game with a Necronomicon
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_warlock_perk ~= "" then modifier_npc_dota_hero_warlock_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_warlock_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_warlock_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_warlock_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_warlock_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_warlock_perk:GetTexture()
	return "custom/npc_dota_hero_warlock_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
function modifier_npc_dota_hero_warlock_perk:OnCreated(keys)
	if IsServer() then
		if not util:isPlayerBot(self:GetParent():GetPlayerID()) then
			local caster = self:GetCaster()

			Timers:CreateTimer(function()
		      caster:AddItemByName('item_necronomicon_perk')
		      return
		    end, DoUniqueString('give_necronomicon'), .5)
		end
	end
end
