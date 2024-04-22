function SetCastRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abLvl = ability:GetLevel()
	if abLvl <= 0 then return end
	-- Refresh cast range
	caster:RemoveModifierByName("modifier_spell_aether_lens_lod_global")
	caster:AddNewModifier(caster,ability,"modifier_spell_aether_lens_lod_global",{})
end

LinkLuaModifier("modifier_spell_aether_lens_lod_global","abilities/aether_range_lod_global.lua",LUA_MODIFIER_MOTION_NONE)

modifier_spell_aether_lens_lod_global = class({})

function modifier_spell_aether_lens_lod_global:IsPermanent()
	return true
end
function modifier_spell_aether_lens_lod_global:IsHidden()
  return true
end

function modifier_spell_aether_lens_lod_global:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end

function modifier_spell_aether_lens_lod_global:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
	end
end
