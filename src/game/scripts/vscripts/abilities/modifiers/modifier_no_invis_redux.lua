LinkLuaModifier("modifier_truesight_aura_effect_redux", "abilities/modifiers/modifier_no_invis_redux.lua", LUA_MODIFIER_MOTION_NONE)

modifier_no_invis_redux = modifier_no_invis_redux or class({})

function modifier_no_invis_redux:IsHidden()
	return true
end

function modifier_no_invis_redux:IsDebuff()
	return false
end

function modifier_no_invis_redux:RemoveOnDeath()
	return false
end

function modifier_no_invis_redux:IsPermanent()
	return true
end

function modifier_no_invis_redux:IsPurgable()
	return false
end

function modifier_no_invis_redux:OnCreated()
	if not IsServer() then
		return
	end
	if type(OptionManager:GetOption('banInvis')) ~= 'number' then
		print("modifier_no_invis_redux: Reveal Invisibility will not work!")
		return
	end
	self:SetStackCount(OptionManager:GetOption('banInvis'))
end

function modifier_no_invis_redux:IsAura()
	return self:GetStackCount() == 3
end

function modifier_no_invis_redux:GetModifierAura()
	return "modifier_truesight_aura_effect_redux"
end

function modifier_no_invis_redux:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_no_invis_redux:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL --bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC)
end

function modifier_no_invis_redux:GetAuraSearchFlags()
	return bit.bor(DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS)
end

function modifier_no_invis_redux:GetAuraRadius()
	if self:GetStackCount() == 3 then
		return self:GetParent():GetCurrentVisionRange() or 800
	else
		return 1
	end
end

function modifier_no_invis_redux:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999
end

function modifier_no_invis_redux:CheckState()
	if self:GetStackCount() == 3 then -- True Sight, everything is revealed
		return {
			[MODIFIER_STATE_INVISIBLE] = false
		}
	elseif self:GetStackCount() == 2 then -- All invis (abilities and items) except wards are revealed
		local parent = self:GetParent()
		local ward_modifiers = {
			"modifier_item_buff_ward",
			"modifier_item_ward_true_sight",
		}

		--if parent:IsOther() then
			--return {}
		--end

		if parent.HasModifier then
			local bIsWard = false
			for _, v in pairs(ward_modifiers) do
				if parent:HasModifier(v) then
					bIsWard = true
					break
				end
			end
			if bIsWard then
				return {}
			end
		end

		return {
			[MODIFIER_STATE_INVISIBLE] = false
		}
	elseif self:GetStackCount() == 1 then -- Invis abilities are revealed (but not items and wards)
		local parent = self:GetParent()
		local invis_item_modifiers = {
			"modifier_item_invisibility_edge_windwalk",
			"modifier_item_shadow_amulet_fade",
			"modifier_item_silver_edge_windwalk",
			"modifier_rune_invis",
			"modifier_item_glimmer_cape_fade",
			"modifier_smoke_of_deceit",
			"modifier_item_buff_ward",
			"modifier_item_ward_true_sight",
		}

		--if parent:IsOther() then
			--return {}
		--end

		if parent.HasModifier then
			local bHasInvisItem = false
			for _, v in pairs(invis_item_modifiers) do
				if parent:HasModifier(v) then
					bHasInvisItem = true
					break
				end
			end
			if bHasInvisItem then
				return {}
			end
		end

		return {
			[MODIFIER_STATE_INVISIBLE] = false
		}
	else
		return {}
	end
end

---------------------------------------------------------------------------------------------------

modifier_truesight_aura_effect_redux = modifier_truesight_aura_effect_redux or class({})

function modifier_truesight_aura_effect_redux:IsHidden()
	return true
end

function modifier_truesight_aura_effect_redux:IsDebuff()
	return true
end

function modifier_truesight_aura_effect_redux:IsPurgable()
	return false
end

function modifier_truesight_aura_effect_redux:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_truesight_aura_effect_redux:CheckState()
	local caster = self:GetCaster()

	-- Check if caster exists
	if not caster or caster:IsNull() then
		return {}
	end

	return {
		[MODIFIER_STATE_INVISIBLE] = false
	}
end
