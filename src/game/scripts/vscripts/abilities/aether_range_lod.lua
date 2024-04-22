function SetCastRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abLvl = ability:GetLevel()
	if abLvl <= 0 then return end
	-- Refresh cast range
	caster:RemoveModifierByName("modifier_spell_aether_lens_lod")
	caster:AddNewModifier(caster,ability,"modifier_spell_aether_lens_lod",{})
end

LinkLuaModifier("modifier_spell_aether_lens_lod","abilities/aether_range_lod.lua",LUA_MODIFIER_MOTION_NONE)

modifier_spell_aether_lens_lod = class({})

function modifier_spell_aether_lens_lod:IsPermanent()
	return true
end

function modifier_spell_aether_lens_lod:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end

function modifier_spell_aether_lens_lod:GetModifierCastRangeBonusStacking()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end
