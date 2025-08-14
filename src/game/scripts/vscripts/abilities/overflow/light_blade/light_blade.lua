light_blade = class({})
LinkLuaModifier( "modifier_light_blade", "abilities/overflow/light_blade/modifier_light_blade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_light_blade_fade", "abilities/overflow/light_blade/modifier_light_blade_fade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("element_fire", "abilities/overflow/element_fire.lua", LUA_MODIFIER_MOTION_NONE)

function light_blade:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local caster = self:GetCaster()

	if not hTarget or hTarget:IsNull() then
		return
	end

	if hTarget:TriggerSpellAbsorb(self) then
		return
	end

	local damage_delay = self:GetSpecialValueFor( "damage_delay" )

	hTarget:AddNewModifier( caster, self, "modifier_light_blade", { duration = damage_delay } )

	caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")

	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin() + Vector( 0, 0, 96 ), true )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 4, Vector(255, 150, 50) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

function light_blade:GetAOERadius()
	return self:GetSpecialValueFor("aoe_range")
end

