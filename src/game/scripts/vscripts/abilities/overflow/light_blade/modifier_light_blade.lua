modifier_light_blade = class ({})

--------------------------------------------------------------------------------

function modifier_light_blade:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_light_blade:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_light_blade:IsPurgable()
	return false
end

function modifier_light_blade:OnDestroy()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local parent = self:GetParent()

		local nFireDamage = hAbility:GetSpecialValueFor( "damage" )
		local nScepterBonus = hAbility:GetSpecialValueFor( "bonus_scepter" )
		local day = GameRules:IsDaytime()

		if hCaster:HasScepter() and day then
			nFireDamage = nFireDamage + nScepterBonus
		end

		if not parent or parent:IsNull() then
			return
		end

		if not parent:IsAlive() then
			return
		end

		-- Fire Damage
		parent:AddNewModifier(hCaster, hAbility, "element_fire", {stacks = nFireDamage})

		local chain_fade = hAbility:GetSpecialValueFor( "chain_fade" )
		local damage_delay = hAbility:GetSpecialValueFor( "damage_delay" )
		local nRange = hAbility:GetSpecialValueFor("aoe_range")

		if hCaster:HasScepter() then
			chain_fade = hAbility:GetSpecialValueFor( "fade_scepter" )
		end

		if not parent or parent:IsNull() then
			return
		end

		if not parent:IsAlive() then
			return
		end

		-- Apply Bounce Immunity
		parent:AddNewModifier( hCaster, hAbility, "modifier_light_blade_fade", { duration = chain_fade } )

		local nFlag = hAbility:GetAbilityTargetFlags() or DOTA_UNIT_TARGET_FLAG_NONE
		local nTeam = hAbility:GetAbilityTargetTeam() or DOTA_UNIT_TARGET_TEAM_BOTH
		local nType = hAbility:GetAbilityTargetType() or DOTA_UNIT_TARGET_ALL

		if nTeam == DOTA_UNIT_TARGET_TEAM_CUSTOM then
			nTeam = DOTA_UNIT_TARGET_TEAM_BOTH
		end
		if nType == DOTA_UNIT_TARGET_CUSTOM then
			nType = DOTA_UNIT_TARGET_ALL
		end

		local tTargets = FindUnitsInRadius(
			hCaster:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			nRange,
			nTeam,
			nType,
			nFlag,
			FIND_ANY_ORDER,
			false
		)

		-- Find the bounce target
		local hTarget
		for _, v in pairs(tTargets) do
			if v and not v:IsNull() then
				if v ~= parent and not v:HasModifier("modifier_light_blade_fade") then
					hTarget = v
					break
				end
			end
		end
		if hTarget ~= nil then
			hTarget:AddNewModifier( hCaster, hAbility, "modifier_light_blade", { duration = damage_delay } )
			EmitSoundOnLocationWithCaster(parent:GetOrigin(), "Hero_Phoenix.FireSpirits.Launch", hCaster)

			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin() + Vector( 0, 0, 96 ), true )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
			ParticleManager:SetParticleControl( nFXIndex, 15, Vector(255, 150, 50) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

function modifier_light_blade:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
