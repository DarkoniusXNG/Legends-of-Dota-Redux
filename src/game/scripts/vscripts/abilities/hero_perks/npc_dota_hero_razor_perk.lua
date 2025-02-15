--------------------------------------------------------------------------------------------------------
--		Hero: Razor
--		Perk: Storm Surge free ability and reduces the manacost and cooldown of all abilities by 25% when Razor is Static Linked to an enemy.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_razor_perk = modifier_npc_dota_hero_razor_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_razor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_razor_perk:GetTexture()
	return "custom/npc_dota_hero_razor_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_razor_perk:OnCreated()
		self.reduction = 25
	    local caster = self:GetCaster()
	    local bonus_ability = caster:FindAbilityByName("razor_storm_surge")
	    if bonus_ability then
	        bonus_ability:UpgradeAbility(false)
	    else
	        bonus_ability = caster:AddAbility("razor_storm_surge")
	        --bonus_ability:SetStolen(true)
	        bonus_ability:SetActivated(true)
	        bonus_ability:SetLevel(1)
	    end
	end
	function modifier_npc_dota_hero_razor_perk:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		}
	end
	--------------------------------------------------------------------------------------------------------
	function modifier_npc_dota_hero_razor_perk:OnAbilityFullyCast(params)
		if params.unit == self:GetParent() and self:GetParent():HasModifier("modifier_razor_static_link") then
			local cooldown = params.ability:GetCooldownTimeRemaining() * (100 - self.reduction)/100
			params.ability:EndCooldown()
			params.ability:StartCooldown(cooldown)
			local cost = params.ability:GetManaCost(-1) * (self.reduction)/100
			self:GetParent():GiveMana(cost)
		end
	end
end
