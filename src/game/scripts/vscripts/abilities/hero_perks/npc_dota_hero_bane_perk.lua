--------------------------------------------------------------------------------------------------------
--		Hero: Bane
--		Perk: Bane heals for 200% of all damage he deals to sleeping units.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_bane_perk = modifier_npc_dota_hero_bane_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bane_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bane_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bane_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bane_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_bane_perk:GetTexture()
	return "custom/npc_dota_hero_bane_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
--local timers = require('easytimers')

function PerkBane(filterTable)
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index or not ability_index then
        return true
    end
    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
    local ability = EntIndexToHScript( ability_index )

	if attacker:GetUnitName() == "npc_dota_hero_bane" then
		-- util function to check if victim has a sleep modifier
		if victim:IsSleeping() then
			local heal_amount = 2 * filterTable["damage"]
			local healer = attacker
			if ability then
				healer = ability
			end
			attacker:Heal(heal_amount, healer)
			SendOverheadEventMessage(attacker,OVERHEAD_ALERT_HEAL,attacker,heal_amount,nil)
	        local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	        ParticleManager:SetParticleControl(healParticle, 1, Vector(322, 322, 322))
			ParticleManager:ReleaseParticleIndex(healParticle)
		end
	end
end
