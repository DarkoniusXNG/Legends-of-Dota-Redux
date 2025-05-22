lysander_grapeshot = class({})

LinkLuaModifier("modifier_grapeshot_scepter","abilities/dusk/lysander_grapeshot",LUA_MODIFIER_MOTION_NONE)

function lysander_grapeshot:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	if t:TriggerSpellAbsorb(self) then return end

	if t then
		local base_dmg = self:GetSpecialValueFor("base_damage")
		local sound = "Hero_Kunkka.InverseBayonet"
		local sound2 = ""
		local particle = "particles/units/heroes/hero_lysander/grapeshot.vpcf"
		local mult = self:GetSpecialValueFor("multiplier")
		local stun = self:GetSpecialValueFor("stun")
		local stun_range = self:GetSpecialValueFor("range_ministun")
		local crit_mult = self:GetSpecialValueFor("crit_multiplier")
		local cc_mult = self:GetSpecialValueFor("captains_compass_increase")/100
		local crit = self:GetSpecialValueFor("crit") -- crit chance

		local r = RandomInt(1,100)

		if t:HasModifier("modifier_captains_compass") then
			crit = 999 -- guaranteed crit
			stun = stun * (1+cc_mult)
			t:RemoveModifierByName("modifier_captains_compass")
		end

		local should_stun = false
		if c:GetRangeToUnit(t) < stun_range then
			should_stun = true
		end

		local isCrit = r <= crit

		t:EmitSound(sound)

		if isCrit then
			mult = crit_mult
			sound2 = "Hero_Silencer.LastWord.Damage"
			particle = "particles/units/heroes/hero_lysander/grapeshot_crit.vpcf"
			should_stun = true
		end

		-- Stun
		if should_stun then
			t:AddNewModifier(c, self, "modifier_stunned", {duration=stun})
		end

		local dmg = mult * (c:GetAverageTrueAttackDamage(c)+base_dmg)

		InflictDamage(t,c,self,dmg,DAMAGE_TYPE_PHYSICAL)

		if sound2 ~= "" then t:EmitSound(sound2) end

		local p = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, t)
		ParticleManager:SetParticleControlEnt(p,0,t,PATTACH_POINT_FOLLOW,"attach_hitloc",t:GetCenter(),true)
		ParticleManager:ReleaseParticleIndex(p)

		if isCrit then
			local cd_after = self:GetCooldownTimeRemaining()/2
			self:EndCooldown()
			self:StartCooldown(cd_after)
			self:RefundManaCost()
		end
	end
end

function lysander_grapeshot:GetIntrinsicModifierName()
	return "modifier_grapeshot_scepter"
end

modifier_grapeshot_scepter = class({})

function modifier_grapeshot_scepter:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_grapeshot_scepter:OnAttackLanded(event)
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end
		
		-- Check if attacker is an illusion or dead
		if attacker:IsIllusion() or not attacker:IsAlive() then
			return
		end
		
		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check if attacked entity is an item, rune or something weird
		if target.GetUnitName == nil then
			return
		end

		-- Check if parent has aghanim scepter
		if not parent:HasScepter() then
			return
		end

		local chance = ability:GetSpecialValueFor("scepter_chance")
		local radius = ability:GetSpecialValueFor("scepter_radius")
		local r = RandomInt(1,100)
		local hit = r <= chance

		if hit then
			local enemies = FindUnitsInRadius(
				parent:GetTeam(),
				parent:GetAbsOrigin(),
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false
			)

			local rr = RandomInt(1, #enemies)
			local random_enemy = enemies[rr]

			if random_enemy and not random_enemy:IsNull() and random_enemy ~= target then
				local sound = "Hero_Kunkka.InverseBayonet"
				local sound2 = ""
				local particle = "particles/units/heroes/hero_lysander/grapeshot.vpcf"
				local base_dmg = ability:GetSpecialValueFor("base_damage")
				local mult = ability:GetSpecialValueFor("multiplier")
				local crit_mult = ability:GetSpecialValueFor("crit_multiplier")
				local crit = ability:GetSpecialValueFor("crit") -- crit chance

				local r2 = RandomInt(1,100)

				if random_enemy:HasModifier("modifier_captains_compass") then
					crit = 999 -- guaranteed crit
					random_enemy:RemoveModifierByName("modifier_captains_compass")
				end

				local isCrit = r2 <= crit

				random_enemy:EmitSound(sound)

				if isCrit then
					mult = crit_mult
					sound2 = "Hero_Silencer.LastWord.Damage"
					particle = "particles/units/heroes/hero_lysander/grapeshot_crit.vpcf"
				end

				local dmg = mult * (parent:GetAverageTrueAttackDamage(parent)+base_dmg)

				InflictDamage(random_enemy,parent,ability,dmg,DAMAGE_TYPE_PHYSICAL)

				if sound2 ~= "" then random_enemy:EmitSound(sound2) end

				local p = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, random_enemy)
				ParticleManager:SetParticleControlEnt(p,0,random_enemy,PATTACH_POINT_FOLLOW,"attach_hitloc",random_enemy:GetCenter(),true)
				ParticleManager:ReleaseParticleIndex(p)
			end
		end
	end
end

function modifier_grapeshot_scepter:AllowIllusionDuplicate()
	return false
end

function modifier_grapeshot_scepter:IsHidden()
	local parent = self:GetParent()
	if parent:HasScepter() then
		return false
	end
	return true
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end
