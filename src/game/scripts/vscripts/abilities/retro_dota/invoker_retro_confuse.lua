--[[ ============================================================================================================
	Author: Rook
	Date: February 26, 2015
	Called when Confuse is cast.
================================================================================================================= ]]
function invoker_retro_confuse_on_spell_start(keys)
	local target_point = keys.target_points[1]
	local caster = keys.caster
	local ability = caster:FindAbilityByName("invoker_retro_confuse")

	if not ability or ability:IsNull() then
		return
	end

	if ability:GetLevel() < 1 then
		return
	end

	local padding = caster:GetHullRadius()
	local caster_forward_vector = caster:GetForwardVector()

	local illusion_duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	local illusion_incoming_damage_percent = ability:GetLevelSpecialValueFor("incoming_damage_percent", ability:GetLevel() - 1)

	-- Create the illusions.
	local illu_table = {
		outgoing_damage = 0,
		incoming_damage = illusion_incoming_damage_percent,
		bounty_base = 0,
		bounty_growth = 0,
		outgoing_damage_structure = 0,
		outgoing_damage_roshan = 0,
		duration = illusion_duration,
	}

	-- Create normal illusion
	local confuse_illusion = CreateIllusions(caster, caster, illu_table, 1, padding, false, true)[1]
	FindClearSpaceForUnit(confuse_illusion, target_point, false)

	-- Create ghost illusion
	illu_table.incoming_damage = 0
	illu_table.duration = illusion_duration * 2
	local confuse_ghost = CreateIllusions(caster, caster, illu_table, 1, padding, false, false)[1]
	confuse_ghost:SetAbsOrigin(confuse_illusion:GetAbsOrigin()) -- places the ghost on top of the normal one

	-- Make it so both illusions are facing the same direction.
	confuse_ghost:SetForwardVector(caster_forward_vector)
	confuse_illusion:SetForwardVector(caster_forward_vector)

	-- Set the illusion's health and mana values to those of the real Invoker.
	local caster_health = caster:GetHealth()
	local caster_mana = caster:GetMana()
	confuse_ghost:SetHealth(caster_health)
	confuse_ghost:SetMana(caster_mana)
	confuse_illusion:SetHealth(caster_health)
	confuse_illusion:SetMana(caster_mana)

	-- Limit how the ghost and illusion can be interacted with.
	ability:ApplyDataDrivenModifier(caster, confuse_illusion, "modifier_invoker_retro_confuse_illusion", nil)
	ability:ApplyDataDrivenModifier(caster, confuse_ghost, "modifier_invoker_retro_confuse_illusion", nil)
	ability:ApplyDataDrivenModifier(caster, confuse_ghost, "modifier_invoker_retro_confuse_ghost", nil)

	-- Particle
	local particle = ParticleManager:CreateParticle("particles/generic_gameplay/illusion_created.vpcf", PATTACH_ABSORIGIN_FOLLOW, confuse_illusion)
	ParticleManager:ReleaseParticleIndex(particle)

	-- Sound
	caster:EmitSound("Hero_Terrorblade.ConjureImage")
end
