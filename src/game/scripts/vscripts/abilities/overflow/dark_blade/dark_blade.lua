dark_blade = class({})
LinkLuaModifier( "modifier_dark_blade", "abilities/overflow/dark_blade/modifier_dark_blade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_blade_fade", "abilities/overflow/dark_blade/modifier_dark_blade_fade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_blade_curse", "abilities/overflow/dark_blade/modifier_dark_blade_curse.lua", LUA_MODIFIER_MOTION_NONE )

function dark_blade:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local caster = self:GetCaster()

	if not hTarget or hTarget:IsNull() then
		return
	end

	if hTarget:TriggerSpellAbsorb(self) then
		return
	end

	local damage_delay = self:GetSpecialValueFor( "damage_delay" )

	hTarget:AddNewModifier( self:GetCaster(), self, "modifier_dark_blade", { duration = damage_delay } )

	hTarget:EmitSound("Hero_Nightstalker.Void.Nihility")

	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin() + Vector( 0, 0, 96 ), true )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )

	local Colour = {150,50,150}
	if hTarget:HasModifier("modifier_dark_blade_curse") then
		local hMod = hTarget:FindModifierByName("modifier_dark_blade_curse")
		local nStack = hMod:GetStackCount()
		Colour[1] = Colour[1]/(nStack/2) + 50
		Colour[2] = Colour[2]/nStack + 25
	end
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

function dark_blade:GetAOERadius()
	return self:GetSpecialValueFor("aoe_range")
end
