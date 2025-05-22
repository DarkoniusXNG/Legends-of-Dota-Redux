--------------------------------------------------------------------------------------------------------
--		Hero: Lone Druid
--		Perk: Lone Druid transfers 50% of damage taken to his Spirit Bear if he has one and its within 1800 range.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_lone_druid_perk = modifier_npc_dota_hero_lone_druid_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_lone_druid_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_lone_druid_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_lone_druid_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lone_druid_perk:GetTexture()
	return "custom/npc_dota_hero_lone_druid_perk"
end

if IsServer() then
	function modifier_npc_dota_hero_lone_druid_perk:OnCreated()
		self.bear = self:GetCaster():FindAbilityByName("lone_druid_spirit_bear")
		self.leash = 1800
	end

	function modifier_npc_dota_hero_lone_druid_perk:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
	end

	function modifier_npc_dota_hero_lone_druid_perk:GetModifierIncomingDamage_Percentage(params)
		if not self.bear then
			return 0
		end

		local parent = self:GetParent()
		local damage_after_reductions = params.damage

		if damage_after_reductions <= 0 then
			return 0
		end

		-- cap overkill damage
		if damage_after_reductions > parent:GetHealth() then
			damage_after_reductions = parent:GetHealth()
		end

		local redirect_pct = 50
		local redirect_damage = damage_after_reductions * (redirect_pct/100)

		local damage_table = {
			attacker = params.attacker,
			damage = redirect_damage,
			damage_type = params.damage_type or DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		}

		local bear_found = false
		for _, bear in pairs (Entities:FindAllByName("npc_dota_lone_druid_bear*")) do
			if bear and not bear:IsNull() then
				if bear:GetPlayerOwnerID() == parent:GetPlayerOwnerID() and bear:IsAlive() then
					local parent_loc = parent:GetAbsOrigin()
					local bear_loc = bear:GetAbsOrigin()
					local distance = (bear_loc - parent_loc):Length2D()
					if distance < self.leash then
						bear_found = true
						damage_table.victim = bear
						ApplyDamage(damage_table)
					end
				end
			end
		end

		if bear_found then
			-- Block the amount of damage on the parent
			return 0 - math.abs(redirect_pct)
		end

		return 0
	end
end
