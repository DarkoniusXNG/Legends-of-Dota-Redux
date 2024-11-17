LinkLuaModifier("modifier_dark_ranger_black_arrow_lod", "abilities/life_in_arena/blackarrow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dark_ranger_black_arrow_debuff", "abilities/life_in_arena/blackarrow.lua", LUA_MODIFIER_MOTION_NONE)

dark_ranger_black_arrow = dark_ranger_black_arrow or class({})

function dark_ranger_black_arrow:GetIntrinsicModifierName()
	return "modifier_dark_ranger_black_arrow_lod"
end

function dark_ranger_black_arrow:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function dark_ranger_black_arrow:IsStealable()
	return false
end

function dark_ranger_black_arrow:ShouldUseResources()
	return true
end

function dark_ranger_black_arrow:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_dark_ranger_black_arrow_lod = modifier_dark_ranger_black_arrow_lod or class({})

function modifier_dark_ranger_black_arrow_lod:IsHidden()
	return true
end

function modifier_dark_ranger_black_arrow_lod:IsDebuff()
	return false
end

function modifier_dark_ranger_black_arrow_lod:IsPurgable()
	return false
end

function modifier_dark_ranger_black_arrow_lod:RemoveOnDeath()
	return false
end

function modifier_dark_ranger_black_arrow_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_dark_ranger_black_arrow_lod.OnRefresh = modifier_dark_ranger_black_arrow_lod.OnCreated

function modifier_dark_ranger_black_arrow_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_dark_ranger_black_arrow_lod:GetModifierProjectileName()
	if not IsServer() then return end
	if self.orb_attack then
		return "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf"
	end
end

if IsServer() then
	function modifier_dark_ranger_black_arrow_lod:OnAttackStart(event)
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

		if parent:IsIllusion() then
			return
		end

		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		self.orb_attack = false

		-- Don't affect buildings and wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				-- Attack projectile change goes here
				self.orb_attack = true
			end
		end
	end

	function modifier_dark_ranger_black_arrow_lod:OnAttack(event)
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

		if parent:IsIllusion() then
			return
		end

		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Don't affect buildings and wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				--The Attack while Autocast is ON or or manually casted (current active ability)

				-- Enable proc for this attack record number (event.record is the same for OnAttackLanded)
				self.procRecords[event.record] = true

				if self.trigger_essence_aura then
					-- Using attack modifier abilities doesn't actually fire any cast events so we need to do it manually
					-- Using CastAbility (ability needs to have OnSpellStart()) to trigger Essence Aura
					ability:CastAbility()
				else
					-- Use mana and trigger cd while respecting reductions
					-- Using attack modifier abilities doesn't actually fire any cast events so we need to use resources here
					ability:UseResources(true, false, false, true)
				end

				-- Attack sound goes here
				parent:EmitSound("Hero_DrowRanger.FrostArrows")
			end
		end
	end

	function modifier_dark_ranger_black_arrow_lod:OnAttackLanded(event)
		local parent = self:GetParent()
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

		if parent:IsIllusion() then
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

		if self.procRecords[event.record] then
			self:SpellEffect(event)
		end
	end

	function modifier_dark_ranger_black_arrow_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_dark_ranger_black_arrow_lod:SpellEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()

			-- Don't affect buildings, wards, and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
				return
			end

			-- Sound when attack lands
			target:EmitSound("Hero_Medusa.MysticSnake.Target")

			-- Apply the debuff
			target:AddNewModifier(attacker, ability, "modifier_dark_ranger_black_arrow_debuff", {duration = ability:GetSpecialValueFor("duration")})

			local damage_table = {
				victim = target,
				attacker = attacker,
				damage = ability:GetSpecialValueFor("damage"),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK,
				ability = ability,
			}

			ApplyDamage(damage_table)

			self.procRecords[event.record] = nil
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_dark_ranger_black_arrow_debuff = class({})

function modifier_dark_ranger_black_arrow_debuff:IsHidden()
	return true
end

function modifier_dark_ranger_black_arrow_debuff:IsDebuff()
	return true
end

function modifier_dark_ranger_black_arrow_debuff:IsPurgable()
	return false
end

function modifier_dark_ranger_black_arrow_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end

if IsServer() then
	function modifier_dark_ranger_black_arrow_debuff:OnDeath(event)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local killer = event.attacker
		local dead = event.unit

		-- Check if killer exists
		if not killer or killer:IsNull() then
			return
		end

		-- Check if dead unit has this modifier
		if dead ~= parent then
			return
		end

		-- Check for reincarnations
		if parent:IsReincarnating() then
			return
		end

		-- Check if caster exists
		if not caster or caster:IsNull() then
			return
		end

		-- Check if ability exists
		if not ability or ability:IsNull() then
			return
		end

		local duration = ability:GetSpecialValueFor("lifetime")
		local outgoing_damage = ability:GetSpecialValueFor("outgoing_damage")
		local incoming_damage = ability:GetSpecialValueFor("incoming_damage")
		local point = parent:GetAbsOrigin()
		local padding = parent:GetHullRadius()
		local name = parent:GetUnitName()

		local spawn
		if parent:IsHero() then
			local illu_table = {
				outgoing_damage = outgoing_damage,
				incoming_damage = incoming_damage,
				bounty_base = 0,
				bounty_growth = 0,
				outgoing_damage_structure = outgoing_damage,
				outgoing_damage_roshan = outgoing_damage,
				duration = duration,
			}
			local illusions = CreateIllusions(caster, parent, illu_table, 1, padding, false, false)
			spawn = illusions[1]
			spawn:SetHealth(spawn:GetMaxHealth())
			spawn:SetMana(spawn:GetMaxMana())
		else
			spawn = CreateUnitByName(name, point, true, caster, caster, caster:GetTeamNumber())
			spawn:SetOwner(caster:GetOwner())
			spawn:SetControllableByPlayer(caster:GetPlayerID(), true)
			spawn:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
			spawn:AddNewModifier(caster, ability, "modifier_illusion", {duration = duration, outgoing_damage = outgoing_damage, incoming_damage = incoming_damage})
			spawn:MakeIllusion()
		end

		FindClearSpaceForUnit(spawn, point, false)
		spawn:SetRenderColor(249, 127, 127)

		-- Spawn sound
		spawn:EmitSound("Hero_Medusa.MysticSnake.Return")
	end
end
