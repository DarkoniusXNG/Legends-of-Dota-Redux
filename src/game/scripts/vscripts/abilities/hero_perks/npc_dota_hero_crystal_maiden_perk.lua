--------------------------------------------------------------------------------------------------------
--
--		Hero: Crystal Maiden
--		Perk: Crystal Maiden gains 1 level of arcane aura for every ice spells she has
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_crystal_maiden_perk ~= "" then modifier_npc_dota_hero_crystal_maiden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_crystal_maiden_perk:GetTexture()
	return "custom/npc_dota_hero_crystal_maiden_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_crystal_maiden_perk:OnCreated()
	if IsClient() then return end
	local caster = self:GetParent()

	local aura = caster:FindAbilityByName("crystal_maiden_brilliance_aura")
	
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:HasAbilityFlag("ice") then
			if not aura then
				aura = caster:AddAbility("crystal_maiden_brilliance_aura")
				--aura:SetStolen(true)
			end
			aura:UpgradeAbility(false)
		end
	end
end
