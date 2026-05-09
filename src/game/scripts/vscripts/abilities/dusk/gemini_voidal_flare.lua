gemini_voidal_flare = class({})

LinkLuaModifier("modifier_voidal_flare","abilities/dusk/gemini_voidal_flare",LUA_MODIFIER_MOTION_NONE)

function gemini_voidal_flare:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	c:EmitSound("Voidwalker.VoidalFlare")

	local info = {
		EffectName = "particles/units/heroes/hero_gemini/voidal_flare.vpcf", -- essential if you want to see the projectile
		Ability = self, -- essential if you want OnProjectileHit to work
		Source = c, -- essential
		Target = t, -- essential if you want it to travel towards the target
		bProvidesVision = false, -- essential
		iVisionRadius = 0, -- essential
		iVisionTeamNumber = c:GetTeamNumber(), -- essential
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"), -- essential because it is projectile speed
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDodgeable = true, -- essential if you want the projectile to be disjointable
		--bIsAttack = false,
		bReplaceExisting = false,
		--bIgnoreObstructions = false,
		--bSuppressTargetCheck = false,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, -- DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		--bDrawsOnMinimap = false,
		bVisibleToEnemies = true, -- essential if you want to avoid visual bugs
	}

	ProjectileManager:CreateTrackingProjectile(info)
end

function gemini_voidal_flare:OnProjectileHit(t,l)
	local caster = self:GetCaster()
	if t and not t:IsNull() then
		local duration = self:GetSpecialValueFor("duration")
		local modifier = t:FindModifierByName("modifier_voidal_flare")

		if t:IsMagicImmune() or t:IsInvulnerable() or t:TriggerSpellAbsorb( self ) then return end

		local stack = 1

		t:AddNewModifier(caster, self, "modifier_voidal_flare", {duration = duration, stack = 1})
		-- will set the stack to 1 if creating, or add when refreshing

		if modifier then
			stack = modifier:GetStackCount()
		end

		local damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_bonus") * (stack-1)
		local stun = self:GetSpecialValueFor("stun") + self:GetSpecialValueFor("stun_bonus") * (stack-1)

		InflictDamage(t,caster,self,damage,DAMAGE_TYPE_MAGICAL)

		t:AddNewModifier(caster, self, "modifier_stunned", {duration = stun})
		t:EmitSound("Voidwalker.VoidalFlareHit")
	end
	return true
end

---------------------------------------------------------------------------------------------------

modifier_voidal_flare = class({})

function modifier_voidal_flare:IsDebuff()
	return true
end

function modifier_voidal_flare:IsPurgable()
	return false
end

function modifier_voidal_flare:OnCreated(kv)
	if IsServer() then
		local stack = kv.stack

		self:SetStackCount(kv.stack)
	end
end

function modifier_voidal_flare:OnRefresh(kv)
	if IsServer() then
		local stack = kv.stack

		local max = self:GetAbility():GetSpecialValueFor("max_mult")

		if self:GetStackCount() + stack > max then return end

		self:SetStackCount(self:GetStackCount()+kv.stack)
	end
end

---------------------------------------------------------------------------------------------------

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
