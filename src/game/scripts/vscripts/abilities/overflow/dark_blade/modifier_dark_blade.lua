modifier_dark_blade = class ({})

--------------------------------------------------------------------------------

function modifier_dark_blade:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_dark_blade:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_dark_blade:IsPurgable()
	return false
end

function modifier_dark_blade:OnDestroy()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local parent = self:GetParent()

		local chain_fade = hAbility:GetSpecialValueFor( "chain_fade" )
		local damage_delay = hAbility:GetSpecialValueFor( "damage_delay" )
		local curse_duration = hAbility:GetSpecialValueFor( "curse_duration" )
		local nRange = hAbility:GetSpecialValueFor( "aoe_range" )
		local bounce_damage = hAbility:GetSpecialValueFor( "damage" )

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
		parent:AddNewModifier( hCaster, hAbility, "modifier_dark_blade_fade", { duration = chain_fade } )
		-- Apply Curse
		if parent:HasModifier("modifier_dark_blade_curse") then
			local hMod = parent:FindModifierByName("modifier_dark_blade_curse")
			hMod:IncrementStackCount()
			if hCaster:HasScepter() and not GameRules:IsDaytime() then
				hMod:IncrementStackCount()
			end
			hMod:SetDuration(curse_duration, true)
		else
			local hMod = parent:AddNewModifier( hCaster, hAbility, "modifier_dark_blade_curse", { duration = curse_duration } )
			if hMod then
				hMod:IncrementStackCount()
				if hCaster:HasScepter() and not GameRules:IsDaytime() then
					hMod:IncrementStackCount()
				end
			end
		end

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
			parent:GetOrigin(),
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
				if v ~= parent and not v:HasModifier("modifier_dark_blade_fade") then
					hTarget = v
					break
				end
			end
		end

		if hTarget ~= nil then
			hTarget:AddNewModifier( hCaster, hAbility, "modifier_dark_blade", { duration = damage_delay } )
			hTarget:EmitSound("Hero_Nightstalker.Void.Nihility")

			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_CUSTOMORIGIN, hCaster )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin() + Vector( 0, 0, 96 ), true )
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

		local damage_table = {
			victim = parent,
			attacker = hCaster,
			damage = bounce_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = hAbility
		}

		ApplyDamage( damage_table )
	end
end

function modifier_dark_blade:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
