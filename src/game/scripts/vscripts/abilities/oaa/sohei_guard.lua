sohei_guard = class({})

LinkLuaModifier( "modifier_sohei_guard_reflect", "abilities/oaa/sohei_guard.lua", LUA_MODIFIER_MOTION_NONE ) -- needs tooltip

function sohei_guard:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster

	-- Hard Dispel
	target:Purge( false, true, false, true, true )

	-- Start an animation
	caster:StartGestureWithPlaybackRate( ACT_DOTA_OVERRIDE_ABILITY_2 , 1)

	-- Play guard sound
	target:EmitSound( "Sohei.Guard" )

	--Apply Linken's + Lotus Orb + Attack reflect modifier for 2 seconds
	local duration = self:GetSpecialValueFor("guard_duration")
	target:AddNewModifier(caster, self, "modifier_sohei_guard_reflect", { duration = duration })
	-- Built-in modifier (Lotus Orb Echo Shell)
	target:AddNewModifier(caster, self, "modifier_item_lotus_orb_active", {duration = duration})

	-- Stop the animation when it's done
	Timers:CreateTimer(duration, function()
		caster:FadeGesture( ACT_DOTA_OVERRIDE_ABILITY_2 )
	end)
end

function sohei_guard:OnProjectileHit_ExtraData( target, location, extra_data )
	target:EmitSound( "Sohei.GuardHit" )
	ApplyDamage( {
		victim = target,
		attacker = self:GetCaster(),
		damage = extra_data.damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
		ability = self
	} )
end

--------------------------------------------------------------------------------

-- Guard projectile reflect modifier
modifier_sohei_guard_reflect = class({})

function modifier_sohei_guard_reflect:IsDebuff()
	return false
end

function modifier_sohei_guard_reflect:IsHidden()
	return false
end

function modifier_sohei_guard_reflect:IsPurgable()
	return false
end

function modifier_sohei_guard_reflect:GetEffectName()
	return "particles/hero/sohei/guard.vpcf"
end

function modifier_sohei_guard_reflect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sohei_guard_reflect:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_AVOID_DAMAGE,
    MODIFIER_PROPERTY_ABSORB_SPELL,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
end

if IsServer() then
	function modifier_sohei_guard_reflect:GetModifierAvoidDamage( event )
		if event.ranged_attack == true and event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			return 1
		end

		return 0
	end

--------------------------------------------------------------------------------

	function modifier_sohei_guard_reflect:GetAbsorbSpell( event )
		local caster = event.ability:GetCaster()
		local casterIsAlly = caster:GetTeamNumber() == self:GetParent():GetTeamNumber()
		if casterIsAlly then
			return 0
		end
		return 1
	end

	function modifier_sohei_guard_reflect:OnAttackLanded( event )
		if event.target == self:GetParent() then
			if event.ranged_attack == true then
				-- Pre-heal for the damage done
				local parent = self:GetParent()

				-- Send the target's projectile back to them
				ProjectileManager:CreateTrackingProjectile( {
					Target = event.attacker,
					Source = parent,
					Ability = self:GetAbility(),
					EffectName = event.attacker:GetRangedProjectileName(),
					iMoveSpeed = event.attacker:GetProjectileSpeed(),
					vSpawnOrigin = parent:GetAbsOrigin(),
					bDodgeable = true,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

					ExtraData = {
						damage = event.damage
					}
				} )

				parent:EmitSound( "Sohei.GuardProc" )
			end
		end
	end
end
