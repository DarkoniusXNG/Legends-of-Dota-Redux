--------------------------------------------------------------------------------------------------------
--
--		Hero: Kunkka
--		Perk: When Kunkka casts a Water spell he has a 50 percent chance to refill his bottle.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_kunkka_perk ~= "" then modifier_npc_dota_hero_kunkka_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_kunkka_perk:GetTexture()
	return "custom/npc_dota_hero_kunkka_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:OnCreated()
	self.chance = 75
	self.increase = 1
end

function modifier_npc_dota_hero_kunkka_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end


function modifier_npc_dota_hero_kunkka_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() and IsServer() then
		if params.ability:HasAbilityFlag("water") and RollPercentage(self.chance) then
			local bottle = self:GetParent():FindItemByName("item_bottle")
			if bottle and bottle:GetCurrentCharges() < bottle:GetInitialCharges() then
				bottle:SetCurrentCharges(bottle:GetCurrentCharges()+self.increase)
			end
		end
	end
end
