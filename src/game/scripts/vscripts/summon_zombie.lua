summon_zombie = class ({})
LinkLuaModifier( "summon_zombie_modifier", "summon_zombie_modifier.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function summon_zombie:GetIntrinsicModifierName()
	return "summon_zombie_modifier"
end

--------------------------------------------------------------------------------

function summon_zombie:OnSpellStart()	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not target or target:IsNull() then
		return
	end
	
	caster:EmitSound( "Hero_Pugna.Decrepify")
	
	local level = caster:GetLevel()
	
	if not target:IsInvulnerable() and not target:TriggerSpellAbsorb( self ) and not target:IsMagicImmune() then
		local zombie = CreateUnitByName("custom_creature_zombie_large", vLocation, true, caster, caster, caster:GetTeamNumber())
		zombie:SetOwner(caster:GetOwner())
		zombie:SetControllableByPlayer(caster:GetPlayerID(), true)
		zombie:CreatureLevelUp(level)
		zombie:AddNewModifier(caster, self, "modifier_phased", {duration = 0.1})
	end
end
