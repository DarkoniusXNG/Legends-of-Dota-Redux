if berserker == nil then
	berserker = class({})
end

LinkLuaModifier( "berserker_mod", "abilities/overflow/berserker/p_mod.lua", LUA_MODIFIER_MOTION_NONE )

function berserker:GetIntrinsicModifierName() return "berserker_mod" end