--------------------------------------------------------------------------------------------------------
--
--		Hero: Dark Seer
--		Perk: Dark Seer self-casts Surge and Ion Shell when casting them on allies.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dark_seer_perk ~= "" then modifier_npc_dota_hero_dark_seer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_dark_seer_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_dark_seer_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "dark_seer_surge" then
			local surge = params.ability
			local duration = surge:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), surge, "modifier_dark_seer_surge", {duration = duration})
		end
		if params.ability:GetName() == "dark_seer_ion_shell" then
			local shell = params.ability
			local duration = shell:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), shell, "modifier_dark_seer_ion_shell", {duration = duration})
		end
	end
end

function modifier_angel_arena_archmage_anomaly_thinker:OnAbilityFullyCast(params)
	if params.unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() and IsServer() and params.ability ~= self:GetAbility() then
		local abName = params.ability:GetName()
		if params.unit:HasAbility(abName) and not self.blackList[abName] then -- check if caster owns ability and it's unit target
			self.AlreadyHit = {}
			if params.target then self.AlreadyHit[params.target] = true else return end
			local enemies = FindUnitsInRadius(params.target:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aura_radius * 2, DOTA_UNIT_TARGET_TEAM_FRIENDLY, self.auraTargetType, self.auraTargetFlags, FIND_ANY_ORDER, false)
			for _,enemy in pairs(enemies) do
				if enemy:HasModifier("modifier_archmage_anomaly") then
					if params.ability:GetCursorTarget() and not self.AlreadyHit[enemy] and UF_SUCCESS == UnitFilter( enemy, params.ability:GetAbilityTargetTeam(), params.ability:GetAbilityTargetType(), params.ability:GetAbilityTargetFlags(), params.unit:GetTeam() ) then
						params.unit:SetCursorCastTarget(enemy)
						params.ability:OnSpellStart()
						self.AlreadyHit[enemy] = true
					-- elseif not self.AlreadyHit[enemy] and params.ability:GetCursorPosition() and (params.ability:GetCursorPosition() - self:GetParent():GetAbsOrigin()):Length2D() < self.aura_radius then -- I DEEM THIS TOO OP
						-- params.unit: SetCursorPosition(enemy:GetAbsOrigin())
						-- params.ability:OnSpellStart()
						-- self.AlreadyHit[enemy] = true
					end
				end
			end
		end
	end
end
