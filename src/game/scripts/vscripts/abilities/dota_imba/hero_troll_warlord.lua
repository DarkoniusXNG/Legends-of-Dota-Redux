-- Copyright (C) 2018  The Dota IMBA Development Team
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Editors:
--     Firetoad
--     AtroCty, 09.04.2017
--     suthernfriend, 03.02.2018
--     Elfansoer, 17.08.2019

if IsClient() then
    require('lib/util_imba_client')
end

--CreateEmptyTalents("troll_warlord")

-------------------------------------------
--			  BESERKERS RAGE
-------------------------------------------
LinkLuaModifier("modifier_imba_berserkers_rage_ranged", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_berserkers_rage_slow", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_berserkers_rage_melee", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_berserkers_rage_ensnare", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

imba_troll_warlord_berserkers_rage = imba_troll_warlord_berserkers_rage or class({})
function imba_troll_warlord_berserkers_rage:IsHiddenWhenStolen() return false end
function imba_troll_warlord_berserkers_rage:IsRefreshable() return true end
function imba_troll_warlord_berserkers_rage:IsStealable() return false end
function imba_troll_warlord_berserkers_rage:IsNetherWardStealable() return false end
function imba_troll_warlord_berserkers_rage:ResetToggleOnRespawn() return true end

-- Always have one of the buffs
function imba_troll_warlord_berserkers_rage:OnUpgrade()
	if IsServer() then
		local caster = self:GetCaster()
		if not (caster:HasModifier("modifier_imba_berserkers_rage_ranged") or caster:HasModifier("modifier_imba_berserkers_rage_melee")) then
			if self:GetToggleState() then
				caster:AddNewModifier(caster, self, "modifier_imba_berserkers_rage_melee", {})
			else
				caster:AddNewModifier(caster, self, "modifier_imba_berserkers_rage_ranged", {})
			end
		end
	end
end

function imba_troll_warlord_berserkers_rage:OnOwnerSpawned()
	if self.mode == 1 then
		self:ToggleAbility()
		self:ToggleAbility()
		self:ToggleAbility()
		-- Yeah, volvo.
	end
end

function imba_troll_warlord_berserkers_rage:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()
		caster:EmitSound("Hero_TrollWarlord.BerserkersRage.Toggle")
		-- Randomly play a cast line
		if RollPercentage(25) and (caster:GetName() == "npc_dota_hero_troll_warlord") and not caster.beserk_sound then
			caster:EmitSound("troll_warlord_troll_beserker_0"..math.random(1,4))
			caster.beserk_sound = true
			Timers:CreateTimer( 10, function()
				caster.beserk_sound = nil
			end)
		end
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

		-- elfansoer: automatically add melee whirling axes if missing
		local whirling_range = caster:FindAbilityByName( "imba_troll_warlord_whirling_axes_ranged" )
		local whirling_melee = caster:FindAbilityByName( "imba_troll_warlord_whirling_axes_melee" )
		if whirling_range and not whirling_melee then
			local ability = caster:AddAbility( "imba_troll_warlord_whirling_axes_melee" )
			ability:SetLevel( whirling_range:GetLevel() )
		elseif whirling_melee and not whirling_range then
			local ability = caster:AddAbility( "imba_troll_warlord_whirling_axes_ranged" )
			ability:SetLevel( whirling_melee:GetLevel() )
		end

		if caster:HasModifier("modifier_imba_berserkers_rage_ranged") and self:GetToggleState() then
			caster:RemoveModifierByName("modifier_imba_berserkers_rage_ranged")
			caster:AddNewModifier(caster, self, "modifier_imba_berserkers_rage_melee", {})
			caster:SwapAbilities("imba_troll_warlord_whirling_axes_ranged", "imba_troll_warlord_whirling_axes_melee", false, true)
			caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
			self.mode = 2
		else
			caster:RemoveModifierByName("modifier_imba_berserkers_rage_melee")
			caster:AddNewModifier(caster, self, "modifier_imba_berserkers_rage_ranged", {})
			caster:SwapAbilities("imba_troll_warlord_whirling_axes_ranged", "imba_troll_warlord_whirling_axes_melee", true, false)
			caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
			self.mode = 1
		end
	end
end

function imba_troll_warlord_berserkers_rage:GetAbilityTextureName()
	-- blah blah client/server side
	-- if self.mode == 1 then
	if self:GetCaster():HasModifier("modifier_imba_berserkers_rage_melee") then
		return "troll_warlord_berserkers_rage_active"
	else
		return "troll_warlord_berserkers_rage"
	end
end

function imba_troll_warlord_berserkers_rage:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end

	local ensnare_duration	= self:GetSpecialValueFor("ensnare_duration")

	if hTarget then
		hTarget:EmitSound("n_creep_TrollWarlord.Ensnare")

		if hTarget:IsAlive() then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_imba_berserkers_rage_ensnare", {duration = ensnare_duration}):SetDuration(ensnare_duration * (1 - hTarget:GetStatusResistance()), true)
		end
	end
end


----
-- Mini section for the ensnare before going into melee modifier
----

modifier_imba_berserkers_rage_ensnare	= class({})

function modifier_imba_berserkers_rage_ensnare:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net.vpcf"
end

function modifier_imba_berserkers_rage_ensnare:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

-------------------------------------------
modifier_imba_berserkers_rage_melee = modifier_imba_berserkers_rage_melee or class({})
function modifier_imba_berserkers_rage_melee:AllowIllusionDuplicate() return true end
function modifier_imba_berserkers_rage_melee:IsDebuff() return false end
function modifier_imba_berserkers_rage_melee:IsHidden() return true end
function modifier_imba_berserkers_rage_melee:IsPurgable() return false end
function modifier_imba_berserkers_rage_melee:IsPurgeException() return false end
function modifier_imba_berserkers_rage_melee:IsStunDebuff() return false end
function modifier_imba_berserkers_rage_melee:RemoveOnDeath() return false end
-------------------------------------------

-- elfansoer: fix attack range bonus larger than 150 for ranged heroes with high attack range
function modifier_imba_berserkers_rage_melee:OnCreated( kv )
	local range = self:GetParent():Script_GetAttackRange()
	if range > 150 then
		self.reduction = 150 - range
	else
		self.reduction = 0
	end
end

function modifier_imba_berserkers_rage_melee:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
		}
	return decFuns
end

function modifier_imba_berserkers_rage_melee:GetAttackSound()
	return "Hero_TrollWarlord.ProjectileImpact"
end

function modifier_imba_berserkers_rage_melee:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end

function modifier_imba_berserkers_rage_melee:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_imba_berserkers_rage_melee:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("base_attack_time")
end

function modifier_imba_berserkers_rage_melee:OnAttackLanded( params )
	if IsServer() then
		if params.attacker:PassivesDisabled() then
			return nil
		end
		local parent = self:GetParent()
		if (parent == params.attacker) and (parent:IsRealHero() or parent:IsClone()) and params.attacker:GetTeam() ~= params.target:GetTeam() and not params.target:IsOther() and not params.target:IsBuilding() then
			local ability = self:GetAbility()

			-- Bash is now a talent, get bent lul
			if parent:HasTalent("special_bonus_imba_troll_warlord_9") then

				-- Add Troll Warlord to Skull Basher restriction since he has this talent now
				if not self.bash_talent then
					table.insert(IMBA_DISABLED_SKULL_BASHER, "npc_dota_hero_troll_warlord")

					self.bash_talent = true
				end

				if RollPseudoRandom(ability:GetSpecialValueFor("ensnare_chance"), ability) then
					local bash_damage = ability:GetSpecialValueFor("bash_damage")
					local ensnare_duration = ability:GetSpecialValueFor("ensnare_duration")
					ApplyDamage({victim = params.target, attacker = parent, ability = ability, damage = bash_damage, damage_type = DAMAGE_TYPE_MAGICAL})
					local bash_modifier = params.target:AddNewModifier(parent, ability, "modifier_stunned", {duration = ensnare_duration})

					if bash_modifier then
						bash_modifier:SetDuration(ensnare_duration * (1 - params.target:GetStatusResistance()), true)
					end

					params.target:EmitSound("DOTA_Item.SkullBasher")
				end
			else
				if not params.target:IsMagicImmune() and RollPseudoRandom(ability:GetSpecialValueFor("ensnare_chance"), ability) then
					local net =
					{
						Target = params.target,
						Source = parent,
						Ability = self:GetAbility(),
						bDodgeable = false,
						EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_projectile.vpcf",
						iMoveSpeed = 1500, -- IDK how fast this is supposed to be...
						flExpireTime = GameRules:GetGameTime() + 10
					}

					ProjectileManager:CreateTrackingProjectile(net)
				end
			end
		end
	end
end

function modifier_imba_berserkers_rage_melee:GetActivityTranslationModifiers()
	if self:GetParent():GetName() == "npc_dota_hero_troll_warlord" then
		return "melee"
	end
	return 0
end

-- Note: This is for BAT-modifying, since only troll modify BAT of others and himself
function modifier_imba_berserkers_rage_melee:GetPriority()
	return 1
end

function modifier_imba_berserkers_rage_melee:GetModifierAttackRangeBonus()
	-- elfansoer: fix attack range bonus larger than 150 for ranged heroes with high attack range
	-- return -350
	return self.reduction
end

function modifier_imba_berserkers_rage_melee:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_berserk_buff.vpcf"
end

function modifier_imba_berserkers_rage_melee:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
-------------------------------------------
modifier_imba_berserkers_rage_ranged = modifier_imba_berserkers_rage_ranged or class({})
function modifier_imba_berserkers_rage_ranged:AllowIllusionDuplicate() return true end
function modifier_imba_berserkers_rage_ranged:IsDebuff() return false end
function modifier_imba_berserkers_rage_ranged:IsHidden() return true end
function modifier_imba_berserkers_rage_ranged:IsPurgable() return false end
function modifier_imba_berserkers_rage_ranged:IsPurgeException() return false end
function modifier_imba_berserkers_rage_ranged:IsStunDebuff() return false end
function modifier_imba_berserkers_rage_ranged:RemoveOnDeath() return false end
-------------------------------------------

function modifier_imba_berserkers_rage_ranged:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
		}
	return decFuns
end

function modifier_imba_berserkers_rage_ranged:GetModifierMoveSpeedBonus_Constant()
	return self:GetCaster():FindTalentValue("special_bonus_imba_troll_warlord_1", "movespeed_pct")
end

function modifier_imba_berserkers_rage_ranged:GetModifierPhysicalArmorBonus()
	return self:GetCaster():FindTalentValue("special_bonus_imba_troll_warlord_1", "armor")
end

function modifier_imba_berserkers_rage_ranged:GetModifierBaseAttackTimeConstant()
	return self:GetCaster():FindTalentValue("special_bonus_imba_troll_warlord_1", "bat")
end

-- Note: This is for BAT-modifying, since only troll modify BAT of others and himself
function modifier_imba_berserkers_rage_ranged:GetPriority()
	return 1
end

function modifier_imba_berserkers_rage_ranged:OnAttackLanded( params )
	if IsServer() then
		local parent = self:GetParent()
		if params.attacker:PassivesDisabled() then
			return nil
		end
		if (parent == params.attacker) and (parent:IsRealHero() or parent:IsClone()) then
			local ability = self:GetAbility()
			if RollPseudoRandom(ability:GetSpecialValueFor("ensnare_chance"), ability) then
				local hamstring_duration = ability:GetSpecialValueFor("hamstring_duration")
				params.target:AddNewModifier(parent, ability, "modifier_imba_berserkers_rage_slow", {duration = hamstring_duration})
				params.target:EmitSound("DOTA_Item.Daedelus.Crit")
			end
		end
	end
end

-------------------------------------------
modifier_imba_berserkers_rage_slow = modifier_imba_berserkers_rage_slow or class({})
function modifier_imba_berserkers_rage_slow:IsDebuff() return true end
function modifier_imba_berserkers_rage_slow:IsHidden() return false end
function modifier_imba_berserkers_rage_slow:IsPurgable() return true end
function modifier_imba_berserkers_rage_slow:IsStunDebuff() return false end
function modifier_imba_berserkers_rage_slow:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_berserkers_rage_slow:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		}
	return decFuns
end

function modifier_imba_berserkers_rage_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("hamstring_slow_pct") * (-1)
end

function modifier_imba_berserkers_rage_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

-------------------------------------------
--		  WHIRLING AXES (RANGED)
-------------------------------------------
LinkLuaModifier("modifier_imba_whirling_axes_ranged", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

imba_troll_warlord_whirling_axes_ranged = imba_troll_warlord_whirling_axes_ranged or class({})
function imba_troll_warlord_whirling_axes_ranged:IsHiddenWhenStolen() return false end
function imba_troll_warlord_whirling_axes_ranged:IsRefreshable() return true end
function imba_troll_warlord_whirling_axes_ranged:IsStealable() return true end
function imba_troll_warlord_whirling_axes_ranged:IsNetherWardStealable() return true end

function imba_troll_warlord_whirling_axes_ranged:GetAbilityTextureName()
	return "troll_warlord_whirling_axes_ranged"
end
-------------------------------------------

function imba_troll_warlord_whirling_axes_ranged:GetCooldown( nLevel )
	return self.BaseClass.GetCooldown( self, nLevel ) - self:GetCaster():FindTalentValue("special_bonus_imba_troll_warlord_5")
end

function imba_troll_warlord_whirling_axes_ranged:OnUpgrade()
	if IsServer() then
		local ability_melee = self:GetCaster():FindAbilityByName("imba_troll_warlord_whirling_axes_melee")
		local level = self:GetLevel()
		if ability_melee then
			if ability_melee:GetLevel() < level then
				ability_melee:SetLevel(level)
			end
		end
	end
end

function imba_troll_warlord_whirling_axes_ranged:OnAbilityPhaseStart()
	if self:GetCaster():HasModifier("modifier_imba_battle_trance_720") then
		self:SetOverrideCastPoint(0)
	else
		self:SetOverrideCastPoint(0.2) -- Hard-coded...but yeah
	end

	return true
end

function imba_troll_warlord_whirling_axes_ranged:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		local caster_loc = caster:GetAbsOrigin()

		-- Parameters
		local axe_width = self:GetSpecialValueFor("axe_width")
		local axe_speed = self:GetSpecialValueFor("axe_speed")
		local axe_range = self:GetSpecialValueFor("axe_range") + GetCastRangeIncrease(caster)
		local axe_damage = self:GetSpecialValueFor("axe_damage")
		local duration = self:GetSpecialValueFor("duration")
		local axe_spread = self:GetSpecialValueFor("axe_spread")
		local axe_count = self:GetSpecialValueFor("axe_count")
		local on_hit_pct = self:GetSpecialValueFor("on_hit_pct")
		local direction
		if target_loc == caster_loc then
			direction = caster:GetForwardVector()
		else
			direction = (target_loc - caster_loc):Normalized()
		end

		-- #7 Talent: Ranged Whirling Axe axes count
		axe_count = axe_count + caster:FindTalentValue("special_bonus_imba_troll_warlord_7", "axe_count_increase")
		axe_spread = axe_spread + caster:FindTalentValue("special_bonus_imba_troll_warlord_7", "axe_spread_increase")

		-- Emit sounds
		caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Ranged")
		-- Randomly play a cast line
		if (math.random(1,100) <= 25) and (caster:GetName() == "npc_dota_hero_troll_warlord") then
			caster:EmitSound("troll_warlord_troll_whirlingaxes_0"..math.random(1,6))
		end
		-- Create a unique table with stored hit enemies
		local index = DoUniqueString("index")
		self[index] = {}
		-- Dynamic projectile spawning via angles
		local start_angle
		local interval_angle = 0
		if axe_count == 1 then
			start_angle = 0
		else
			start_angle = axe_spread / 2 * (-1)
			interval_angle = axe_spread / (axe_count - 1)
		end
		for i = 1, axe_count, 1 do
			local angle = start_angle + (i-1) * interval_angle
			local velocity = RotateVector2D(direction,angle,true) * axe_speed

			local projectile =
				{
					Ability				= self,
					EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
					vSpawnOrigin		= caster_loc,
					fDistance			= axe_range,
					fStartRadius		= axe_width,
					fEndRadius			= axe_width,
					Source				= caster,
					bHasFrontalCone		= false,
					bReplaceExisting	= false,
					iUnitTargetTeam		= self:GetAbilityTargetTeam(),
					iUnitTargetFlags	= self:GetAbilityTargetFlags(),
					iUnitTargetType		= self:GetAbilityTargetType(),
					fExpireTime 		= GameRules:GetGameTime() + 10.0,
					bDeleteOnHit		= false,
					vVelocity			= Vector(velocity.x,velocity.y,0),
					bProvidesVision		= false,
					ExtraData			= {index = index, damage = axe_damage, duration = duration, axe_count = axe_count, on_hit_pct = on_hit_pct}
				}
			ProjectileManager:CreateLinearProjectile(projectile)
		end
	end
end

function imba_troll_warlord_whirling_axes_ranged:OnProjectileHit_ExtraData(target, location, ExtraData)
	local caster = self:GetCaster()
	if target then
		local was_hit = false
		for _, stored_target in ipairs(self[ExtraData.index]) do
			if target == stored_target then
				was_hit = true
				break
			end
		end
		if was_hit then
			return nil
		end
		table.insert(self[ExtraData.index],target)
		ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
		if RollPseudoRandom(ExtraData.on_hit_pct, self) then
			caster:PerformAttack(target, true, true, true, true, false, true, true)
		end
		target:AddNewModifier(caster, self, "modifier_imba_whirling_axes_ranged", {duration = ExtraData.duration})
		target:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
	else
		self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
		self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
		if self[ExtraData.index]["count"] == ExtraData.axe_count then
			self[ExtraData.index] = nil
		end
	end
end

-------------------------------------------
modifier_imba_whirling_axes_ranged = modifier_imba_whirling_axes_ranged or class({})
function modifier_imba_whirling_axes_ranged:IsDebuff() return true end
function modifier_imba_whirling_axes_ranged:IsHidden() return false end
function modifier_imba_whirling_axes_ranged:IsPurgable() return true end
function modifier_imba_whirling_axes_ranged:IsPurgeException() return false end
function modifier_imba_whirling_axes_ranged:IsStunDebuff() return false end
function modifier_imba_whirling_axes_ranged:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_whirling_axes_ranged:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		}
	return decFuns
end

function modifier_imba_whirling_axes_ranged:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("movement_speed") * (-1)
end

function modifier_imba_whirling_axes_ranged:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
-------------------------------------------
--		  WHIRLING AXES (MELEE)
-------------------------------------------
LinkLuaModifier("modifier_imba_whirling_axes_melee", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

imba_troll_warlord_whirling_axes_melee = imba_troll_warlord_whirling_axes_melee or class({})
function imba_troll_warlord_whirling_axes_melee:IsHiddenWhenStolen() return false end
function imba_troll_warlord_whirling_axes_melee:IsRefreshable() return true end
function imba_troll_warlord_whirling_axes_melee:IsStealable() return true end
function imba_troll_warlord_whirling_axes_melee:IsNetherWardStealable() return true end

function imba_troll_warlord_whirling_axes_melee:GetAbilityTextureName()
	return "troll_warlord_whirling_axes_melee"
end
-------------------------------------------

function imba_troll_warlord_whirling_axes_melee:GetCooldown( nLevel )
	return self.BaseClass.GetCooldown( self, nLevel ) - self:GetCaster():FindTalentValue("special_bonus_imba_troll_warlord_5")
end

function imba_troll_warlord_whirling_axes_melee:OnUpgrade()
	if IsServer() then
		local ability_ranged = self:GetCaster():FindAbilityByName("imba_troll_warlord_whirling_axes_ranged")
		local level = self:GetLevel()
		if ability_ranged then
			if ability_ranged:GetLevel() < level then
				ability_ranged:SetLevel(level)
			end
		end
	end
end

function imba_troll_warlord_whirling_axes_melee:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_loc = caster:GetAbsOrigin()

		-- Parameters
		local axe_radius = self:GetSpecialValueFor("axe_radius")
		local max_range = self:GetSpecialValueFor("max_range")
		local axe_movement_speed = self:GetSpecialValueFor("axe_movement_speed")
		local whirl_duration = self:GetSpecialValueFor("whirl_duration")
		local direction = caster:GetForwardVector()
		-- Emit sounds
		caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Melee")
		if (math.random(1,100) <= 25) and (caster:GetName() == "npc_dota_hero_troll_warlord") then
			caster:EmitSound("troll_warlord_troll_whirlingaxes_0"..math.random(1,6))
		end
		-- Create a unique table with stored hit enemies
		local index = DoUniqueString("index")
		self[index] = {}
		-- Set the particle
		local axe_pfx = {}
		local axe_loc = {}
		local axe_random = {}
		for i=1, 10, 1 do
			table.insert(axe_pfx, ParticleManager:CreateParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster))
			ParticleManager:SetParticleControl(axe_pfx[i], 1, caster_loc)
			ParticleManager:SetParticleControl(axe_pfx[i], 4, Vector(whirl_duration,0,0))
			table.insert(axe_random, math.random()*0.9+1.8)
		end
		local counter = 0
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
		-- Projectile logic
		-- Note: Most of it is purely cosmetical, it's basicly just checking if new units are in the increasing range
		-- Why? Because trollolololo
		Timers:CreateTimer(FrameTime(), function()
			counter = counter + FrameTime()
			caster_loc = caster:GetAbsOrigin()
			if counter <= (whirl_duration / 2) then
				for i=1, 10, 1 do
					axe_loc[i] = counter * (max_range - axe_radius) * RotateVector2D(direction,36*i + counter*axe_movement_speed,true):Normalized()
					self:DoAxeStuff(index,counter * (max_range-axe_radius)+axe_radius,caster_loc)
				end
			else
				for i=1, 10, 1 do
					axe_loc[i] = (whirl_duration - counter/2) * (max_range - axe_radius) * RotateVector2D(direction,36*i + counter*axe_movement_speed*axe_random[i],true):Normalized()
					self:DoAxeStuff(index,(whirl_duration - counter/2) * (max_range-axe_radius)+axe_radius,caster_loc)
				end
			end
			for i=1, 10, 1 do
				ParticleManager:SetParticleControl(axe_pfx[i], 1, caster_loc + axe_loc[i] + Vector(0,0,40))
			end
			if counter <= whirl_duration then
				return FrameTime()
			else
				for i=1, 10, 1 do
					ParticleManager:DestroyParticle(axe_pfx[i], false)
					ParticleManager:ReleaseParticleIndex(axe_pfx[i])
				end
			end
		end)
	end
end

function imba_troll_warlord_whirling_axes_melee:DoAxeStuff(index,range,caster_loc)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local blind_duration = self:GetSpecialValueFor("blind_duration")
	local blind_stacks = self:GetSpecialValueFor("blind_stacks")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, range, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,enemy in ipairs(enemies) do
		local was_hit = false
		for _, stored_target in ipairs(self[index]) do
			if enemy == stored_target then
				was_hit = true
				break
			end
		end
		if was_hit then
			return nil
		else
			table.insert(self[index],enemy)
		end
		ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
		-- Imbued Axes
		caster:PerformAttack(enemy, true, true, true, true, false, true, true)
		enemy:AddNewModifier(caster, self, "modifier_imba_whirling_axes_melee", {duration = blind_duration, blind_stacks = blind_stacks})
		enemy:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
	end
end

-------------------------------------------
modifier_imba_whirling_axes_melee = modifier_imba_whirling_axes_melee or class({})
function modifier_imba_whirling_axes_melee:IsDebuff() return true end
function modifier_imba_whirling_axes_melee:IsHidden() return false end
function modifier_imba_whirling_axes_melee:IsPurgable() return true end
function modifier_imba_whirling_axes_melee:IsPurgeException() return false end
function modifier_imba_whirling_axes_melee:IsStunDebuff() return false end
function modifier_imba_whirling_axes_melee:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_whirling_axes_melee:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_MISS_PERCENTAGE
		}

	return decFuns
end

function modifier_imba_whirling_axes_melee:OnCreated(params)
	self.miss_chance = self:GetAbility():GetSpecialValueFor("blind_pct")
end

function modifier_imba_whirling_axes_melee:GetModifierMiss_Percentage()
	return self.miss_chance
end

function modifier_imba_whirling_axes_melee:OnRefresh(params)
	self:OnCreated(params)
end

-------------------------------------------
--				FERVOR
-------------------------------------------
LinkLuaModifier("modifier_imba_fervor", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fervor_stacks", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

imba_troll_warlord_fervor = imba_troll_warlord_fervor or class({})
function imba_troll_warlord_fervor:IsHiddenWhenStolen() return false end
function imba_troll_warlord_fervor:IsRefreshable() return false end
function imba_troll_warlord_fervor:IsStealable() return false end
function imba_troll_warlord_fervor:IsNetherWardStealable() return false end

function imba_troll_warlord_fervor:GetAbilityTextureName()
	return "troll_warlord_fervor"
end
-------------------------------------------

function imba_troll_warlord_fervor:GetIntrinsicModifierName()
	local hCaster = self:GetCaster()
	if hCaster:IsRealHero() or hCaster:IsClone() then
		return "modifier_imba_fervor"
	end
	return nil
end

function imba_troll_warlord_fervor:OnUpgrade()
	if IsServer() then
		local caster = self:GetCaster()
		if (math.random(1,100) <= 25) and (caster:GetName() == "npc_dota_hero_troll_warlord") then
			caster:EmitSound("troll_warlord_troll_fervor_0"..math.random(1,6))
		end
	end
end

-------------------------------------------
modifier_imba_fervor = modifier_imba_fervor or class({})
function modifier_imba_fervor:IsDebuff() return false end
function modifier_imba_fervor:IsHidden() return true end
function modifier_imba_fervor:IsPurgable() return false end
function modifier_imba_fervor:IsPurgeException() return false end
function modifier_imba_fervor:IsStunDebuff() return false end
function modifier_imba_fervor:RemoveOnDeath() return false end
-------------------------------------------

-- elfansoer: fix intrinsic problem
function modifier_imba_fervor:OnCreated()
	if IsServer() and self:GetAbility():GetLevel()<1 then
		self:Destroy()
		return
	end
end

function modifier_imba_fervor:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED
		}
	return decFuns
end

function modifier_imba_fervor:OnAttackLanded(params)
	local parent = self:GetParent()

	-- params.original_damage > 0 is so the Imbued Axes IMBAfication from Whirling Axes doesn't trigger Fervor
	if (
		(params.attacker == parent) or
		((params.attacker:GetTeamNumber() == parent:GetTeamNumber()) and params.attacker:HasModifier("modifier_imba_battle_trance") and parent:HasScepter())) and (params.attacker:IsRealHero() or params.attacker:IsClone()) and params.original_damage > 0 then

		local modifier = params.attacker:FindModifierByNameAndCaster("modifier_imba_fervor_stacks",parent)
		if modifier then
			if modifier.last_target == params.target then
--				if modifier:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
					modifier:IncrementStackCount()
--				end
			else
				local loss_pct = 1 - (self:GetAbility():GetSpecialValueFor("switch_lose_pct") / 100)
				modifier:SetStackCount(math.max(math.floor(modifier:GetStackCount() * loss_pct),1))
				modifier.last_target = params.target
			end
		else
			modifier = params.attacker:AddNewModifier(parent, self:GetAbility(), "modifier_imba_fervor_stacks", {})
			modifier.last_target = params.target
		end
	end
end

-------------------------------------------
modifier_imba_fervor_stacks = modifier_imba_fervor_stacks or class({})
function modifier_imba_fervor_stacks:IsDebuff() return false end
function modifier_imba_fervor_stacks:IsHidden() return false end
function modifier_imba_fervor_stacks:IsPurgable() return false end
function modifier_imba_fervor_stacks:IsPurgeException() return false end
function modifier_imba_fervor_stacks:IsStunDebuff() return false end
function modifier_imba_fervor_stacks:RemoveOnDeath() return false end
-------------------------------------------

function modifier_imba_fervor_stacks:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		}
	return decFuns
end

function modifier_imba_fervor_stacks:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_imba_fervor_stacks:GetModifierAttackSpeedBonus_Constant()
	if not self:GetParent():PassivesDisabled() then
		return self:GetAbility():GetSpecialValueFor("bonus_as") * self:GetStackCount()
	end
	return 0
end

-------------------------------------------
--			  BATTLE TRANCE
-------------------------------------------
LinkLuaModifier("modifier_imba_battle_trance", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_imba_battle_trance_720", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_imba_battle_trance_vision_720", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_battle_trance_restricted", "abilities/dota_imba/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

imba_troll_warlord_battle_trance = imba_troll_warlord_battle_trance or class({})
function imba_troll_warlord_battle_trance:IsHiddenWhenStolen() return false end
function imba_troll_warlord_battle_trance:IsRefreshable() return true end
function imba_troll_warlord_battle_trance:IsStealable() return true end
function imba_troll_warlord_battle_trance:IsNetherWardStealable() return true end

function imba_troll_warlord_battle_trance:GetAbilityTextureName()
	return "troll_warlord_battle_trance"
end

function imba_troll_warlord_battle_trance:GetBehavior()
	if IsServer() and self:GetAutoCastState() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
end

function imba_troll_warlord_battle_trance:OnSpellStart()
	local caster	= self:GetCaster()

	if not self:GetAutoCastState() then
		-- The old Battle Trance
		local duration = self:GetSpecialValueFor("buff_duration")

		-- Global Sound
		EmitGlobalSound("Hero_TrollWarlord.BattleTrance.Cast.Team")

		-- Decide which cast sound to play
		local sound = "troll_warlord_troll_battletrance_0"..math.random(1,6)
		--if (math.random(1,100) <= 10) then
			--sound = "Imba.TrollAK47"
		--end
		caster:EmitSound(sound)

		-- Find allies
		local allies = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _, ally in ipairs(allies) do
			ally:AddNewModifier(caster, self, "modifier_imba_battle_trance", {duration = duration})
		end
	else
		--The new Battle Trance

		-- AbilitySpecials
		local trance_duration = self:GetSpecialValueFor("trance_duration")

		-- Emit sound
		caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")

		-- Purge debuffs
		caster:Purge(false, true, false, true, false)

		-- Apply the lifesteal/movespeed/attackspeed/min health/tracking modifier
		caster:AddNewModifier(caster, self, "modifier_imba_battle_trance_720", {duration = trance_duration})
	end

	local cast_pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc" , caster:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex(cast_pfx)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
end

-------------------------------------------
modifier_imba_battle_trance = modifier_imba_battle_trance or class({})
function modifier_imba_battle_trance:IsDebuff() return false end
function modifier_imba_battle_trance:IsHidden() return false end
function modifier_imba_battle_trance:IsPurgable() return false end
function modifier_imba_battle_trance:IsPurgeException() return false end
function modifier_imba_battle_trance:IsStunDebuff() return false end
function modifier_imba_battle_trance:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_battle_trance:DeclareFunctions()
	return	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
	}
end

function modifier_imba_battle_trance:OnCreated()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	self.bonus_as = ability:GetSpecialValueFor("bonus_as")
	self.bonus_as_for_troll = ability:GetSpecialValueFor("attack_speed")
	self.bonus_bat = min(ability:GetSpecialValueFor("bonus_bat"), parent:GetBaseAttackTime())
end

function modifier_imba_battle_trance:OnRefresh()
	self:OnCreated()
end

function modifier_imba_battle_trance:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasAbility("imba_troll_warlord_fervor") and parent:HasModifier("modifier_imba_fervor_stacks") then
			parent:RemoveModifierByName("modifier_imba_fervor_stacks")
		end
	end
end

function modifier_imba_battle_trance:GetPriority()
	return 10
end

function modifier_imba_battle_trance:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster() == self:GetParent() then
		return self.bonus_as_for_troll
	end
	return self.bonus_as
end

function modifier_imba_battle_trance:GetModifierBaseAttackTimeConstant()
	return self.bonus_bat
end

function modifier_imba_battle_trance:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_imba_battle_trance:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

-------------------------------------------
-- BATTLE TRANCE MODIFIER (7.20 VERSION) --
-------------------------------------------

modifier_imba_battle_trance_720 = class({})

function modifier_imba_battle_trance_720:IsDebuff() return false end
function modifier_imba_battle_trance_720:IsHidden() return false end
function modifier_imba_battle_trance_720:IsPurgable() return false end
function modifier_imba_battle_trance_720:IsPurgeException() return false end
function modifier_imba_battle_trance_720:IsStunDebuff() return false end

function modifier_imba_battle_trance_720:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_imba_battle_trance_720:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- AbilitySpecials
	self.lifesteal		= ability:GetSpecialValueFor("lifesteal")
	self.attack_speed	= ability:GetSpecialValueFor("attack_speed")
	self.movement_speed	= ability:GetSpecialValueFor("movement_speed")
	self.range			= ability:GetSpecialValueFor("range")
	self.bonus_bat 		= math.min(ability:GetSpecialValueFor("bonus_bat"), parent:GetBaseAttackTime())

	if not IsServer() then return end

	self.lifesteal_penalty_against_creeps = 40

	-- Jesus take the wheel
	self:OnIntervalThink()
	self:StartIntervalThink(0.03)
end

function modifier_imba_battle_trance_720:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if not caster or caster:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end
	if not caster:IsAlive() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end
	if self.target then --if caster:GetForceAttackTarget() then
		local old_target = self.target --caster:GetForceAttackTarget()
		if not old_target:IsAlive() then
			-- Stop caster from trying to attack the dead unit
			self.target = nil
			caster:SetForceAttackTarget(nil)
			-- We need to remove the command restricted modifier if we want to give the new attack order to the caster
			caster:RemoveModifierByName("modifier_imba_battle_trance_restricted")
			-- Find new target for caster to attack
			self:FindNewUnitToAttack(caster, ability)
		else
			if old_target:IsInvisible() or old_target:IsAttackImmune() or old_target:IsInvulnerable() or (old_target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > self.range or caster:IsDisarmed() or not caster:CanEntityBeSeenByMyTeam(old_target) then
				-- Find new target for caster to attack but remove revealed modifier from the old target first
				old_target:RemoveModifierByName("modifier_imba_battle_trance_vision_720")
				-- Stop caster from trying to attack the unit that is un-attackable or out of range
				self.target = nil
				caster:SetForceAttackTarget(nil)
				-- We need to remove the command restricted modifier if we want to give the new attack order to the caster
				caster:RemoveModifierByName("modifier_imba_battle_trance_restricted")
				-- Find a nearest attackable unit for the caster
				self:FindNewUnitToAttack(caster, ability)
			else
				-- It might not work because it is an attack order but it doesnt hurt
				local order = {
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = old_target:entindex(),
					Queue = false,
				}
				ExecuteOrderFromTable(order)
			end
		end
	else
		self.target = nil
		caster:SetForceAttackTarget(nil)
		caster:RemoveModifierByName("modifier_imba_battle_trance_restricted")
		-- Find a nearest attackable unit for the caster for the first time
		self:FindNewUnitToAttack(caster, ability)
	end
end

-- Find the nearest attackable enemy for the caster;
function modifier_imba_battle_trance_720:FindNewUnitToAttack(caster, ability)
	local caster_team = caster:GetTeamNumber()
	local caster_position = caster:GetAbsOrigin()
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
	local target

	-- Find all heroes that are attackable within range
	local enemy_heroes = FindUnitsInRadius(caster_team, caster_position, nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flags, FIND_CLOSEST, false)
	local enemy_creeps = FindUnitsInRadius(caster_team, caster_position, nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, flags, FIND_CLOSEST, false)
	local all_enemies = FindUnitsInRadius(caster_team, caster_position, nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, FIND_CLOSEST, false)

	-- Find the closest hero
	for _, hero in ipairs(enemy_heroes) do
		if hero:IsAlive() then
			target = hero
			break
		end
	end
	if not target then
		-- Find the closest creep
		for _, creep in ipairs(enemy_creeps) do
			if creep:IsAlive() and not creep:IsRoshanCustom() then
				target = creep
				break
			end
		end
		if not target then
			for _, unit in ipairs(all_enemies) do
				if unit:IsAlive() then
					target = unit
					break
				end
			end
		end
	end
	if target and not caster:IsDisarmed() then
		target:AddNewModifier(caster, ability, "modifier_imba_battle_trance_vision_720", {})
		-- Stop current orders
		caster:Stop()
		-- Executing order if its not in Fog of War, to stop other stuff like channeling etc.
		if caster:CanEntityBeSeenByMyTeam(target) then
			local order = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
				Queue = false,
			}
			ExecuteOrderFromTable(order)
		else
			local order = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = target:GetAbsOrigin(),
				Queue = false,
			}
			ExecuteOrderFromTable(order)
		end

		-- Set the force attack target to be the caster
		--caster:SetForceAttackTarget(target)
		self.target = target

		-- Applying the command restricted modifier
		caster:AddNewModifier(caster, ability, "modifier_imba_battle_trance_restricted", {})
	end
end

function modifier_imba_battle_trance_720:OnDestroy()
	local caster = self:GetParent()
	if caster and not caster:IsNull() and IsServer() then
		local target = self.target --caster:GetForceAttackTarget()
		caster:SetForceAttackTarget(nil)
		caster:RemoveModifierByName("modifier_imba_battle_trance_restricted")
		if target and not target:IsNull() then
			if target:IsAlive() then
				target:RemoveModifierByName("modifier_imba_battle_trance_vision_720")
			end
		end
	end
end

function modifier_imba_battle_trance_720:CheckState()
	local caster = self:GetParent()
	local state = {}
	if caster:HasScepter() then
		state[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	end
	return state
end

function modifier_imba_battle_trance_720:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_TOOLTIP, -- for the lifesteal
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		-- elfansoer: fix lifesteal not working due to missing custom library
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
	}
end

if IsServer() then
	function modifier_imba_battle_trance_720:OnTakeDamage(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local damaged_unit = event.unit
		local damage = event.damage

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		-- Don't heal while dead
		if not attacker:IsAlive() then
			return
		end

		-- Check if damaged entity exists
		if not damaged_unit or damaged_unit:IsNull() then
			return
		end

		-- Ignore self damage
		if damaged_unit == attacker then
			return
		end

		-- Check if entity is an item, rune or something weird
		if damaged_unit.GetUnitName == nil then
			return
		end

		-- Don't affect buildings, wards and invulnerable units.
		if damaged_unit:IsTower() or damaged_unit:IsBarracks() or damaged_unit:IsBuilding() or damaged_unit:IsOther() or damaged_unit:IsInvulnerable() then
			return
		end

		-- Check damage if 0 or negative
		if damage <= 0 then
			return
		end

		-- Normal lifesteal should not work for spells and magic damage attacks
		if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK or event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.inflictor then
			return
		end

		if not self.lifesteal_penalty_against_creeps then
			self.lifesteal_penalty_against_creeps = 40
		end

		-- Calculate the lifesteal (heal) amount
		local lifesteal_amount = 0
		if damaged_unit:IsRealHero() or damaged_unit:IsStrongIllusionCustom() then
			lifesteal_amount = damage * self.lifesteal / 100
		else
			-- Illusions are treated as creeps too
			lifesteal_amount = damage * (self.lifesteal / 100) * (1 - self.lifesteal_penalty_against_creeps / 100)
		end

		if lifesteal_amount > 0 then
			-- Normal Lifesteal
			attacker:HealWithParams(lifesteal_amount, ability, true, true, attacker, false)
			local particle2 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:ReleaseParticleIndex(particle2)
		end
	end
	
	function modifier_imba_battle_trance_720:OnAbilityFullyCast(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local cast_ability = event.ability
		--local target = event.target
		local caster = event.unit
		
		if not cast_ability or cast_ability:IsNull() or not caster or caster:IsNull() then
			return
		end
		
		-- Check if caster of the ability has this modifier
		if caster ~= parent then
			return
		end

		-- Check if old target exists
		if self.target then
			-- Find new target for parent to attack but remove revealed modifier from the old target first
			self.target:RemoveModifierByName("modifier_imba_battle_trance_vision_720")
			-- Stop parent from trying to attack the unit that is un-attackable or out of range
			self.target = nil
			-- The rest will happen in the next OnIntervalThink loop
			-- Doesnt work for some spells like Faceless Void Time Walk, maybe because parent becomes invulnerable?
		end
	end
end

function modifier_imba_battle_trance_720:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_imba_battle_trance_720:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed
end

function modifier_imba_battle_trance_720:GetMinHealth()
	return 1
end

function modifier_imba_battle_trance_720:OnTooltip()
	return self.lifesteal
end

function modifier_imba_battle_trance_720:GetModifierBaseAttackTimeConstant()
	return self.bonus_bat
end

function modifier_imba_battle_trance_720:GetDisableAutoAttack()
	return 0
end

---------------------------------------------------------------------------------------------------

modifier_imba_battle_trance_restricted = class({})

function modifier_imba_battle_trance_restricted:IsHidden()
	return true
end

function modifier_imba_battle_trance_restricted:IsDebuff()
	return false
end

function modifier_imba_battle_trance_restricted:IsPurgable()
	return false
end

function modifier_imba_battle_trance_restricted:RemoveOnDeath()
	return true
end

function modifier_imba_battle_trance_restricted:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
	}
end

function modifier_imba_battle_trance_restricted:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_imba_battle_trance_restricted:GetModifierPercentageCasttime()
	return 100
end

function modifier_imba_battle_trance_restricted:CheckState()
	return {
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_IGNORING_STOP_ORDERS] = true,
		[MODIFIER_STATE_IGNORING_MOVE_ORDERS] = true,
		--[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

--------------------------------------------------
-- BATTLE TRANCE VISION MODIFIER (7.20 VERSION) --
--------------------------------------------------

modifier_imba_battle_trance_vision_720 = class({})

function modifier_imba_battle_trance_vision_720:IsHidden()
	return true
end

function modifier_imba_battle_trance_vision_720:IsDebuff()
	return true
end

function modifier_imba_battle_trance_vision_720:IsPurgable()
	return false
end

function modifier_imba_battle_trance_vision_720:OnCreated()
	if not IsServer() then return end
	self:OnIntervalThink()
	self:StartIntervalThink(0.5)
end

function modifier_imba_battle_trance_vision_720:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local caster_team = caster:GetTeamNumber()
	local parent_location = parent:GetAbsOrigin()
	AddFOWViewer(caster_team, parent_location, 50, 1.0, true)
	parent:MakeVisibleToTeam(caster_team, 1.0)
end

function modifier_imba_battle_trance_vision_720:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end

function modifier_imba_battle_trance_vision_720:GetModifierProvidesFOWVision()
	return 1
end
