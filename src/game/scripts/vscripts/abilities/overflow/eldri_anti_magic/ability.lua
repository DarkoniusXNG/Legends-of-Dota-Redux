if eldri_anti_magic == nil then
	eldri_anti_magic = class({})
end

LinkLuaModifier( "anti_magic_mod", "abilities/overflow/eldri_anti_magic/modifier.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "book_eldri_modifier", "abilities/overflow/eldri_book.lua", LUA_MODIFIER_MOTION_NONE )

function eldri_anti_magic:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function eldri_anti_magic:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local location
	if not target or target:IsNull() then
		location = self:GetCursorPosition()
	else
		location = target:GetAbsOrigin()
	end
	CreateModifierThinker(caster, self, "anti_magic_mod", {duration = self:GetSpecialValueFor("duration")}, location, caster:GetTeamNumber(), true)
end

--function eldri_anti_magic:OnUpgrade()
	--self:GetCaster():AddNewModifier( self:GetCaster(), self, "book_eldri_modifier", { stacks = 1 } )
--end
