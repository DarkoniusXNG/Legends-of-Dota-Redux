function Transmute( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	if not caster or not target or not ability then
		return
	end

	local hp_to_gold_percent = event.health_to_gold / 100
	local target_health = target:GetHealth()

	if target_health < 1 then
		return
	end

	-- If cast through non-normal means
	if target:IsRealHero() then
		return
	end

	local gold_reward = hp_to_gold_percent*target_health

	-- Sound
	target:EmitSound("DOTA_Item.Hand_Of_Midas")

	local particle_gold = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(particle_gold, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_gold, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_gold)

	caster:ModifyGold(gold_reward, true, DOTA_ModifyGold_Unspecified)

	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	ApplyDamage({ victim = target, attacker = caster, damage = target_health+1, damage_type = DAMAGE_TYPE_PURE, ability = ability })

	-- Message Particle, has a bunch of options
	local symbol = 0 -- "+" presymbol
	local color = Vector(255, 200, 33) -- Gold color
	local lifetime = 2
	local digits = string.len(gold_reward) + 1
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
	local particle_message = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle_message, 1, Vector(symbol, gold_reward, symbol))
	ParticleManager:SetParticleControl(particle_message, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(particle_message, 3, color)
	ParticleManager:ReleaseParticleIndex(particle_message)
end
