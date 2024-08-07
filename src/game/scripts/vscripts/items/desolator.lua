LinkLuaModifier("modifier_item_desolator_lod_passive", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE) -- hidden
LinkLuaModifier("modifier_item_desolator_lod_consumed", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE) -- visible
LinkLuaModifier("modifier_item_desolator_lod_debuff", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE) -- visible

item_desolator_consumable = item_desolator_consumable or class({})

function item_desolator_consumable:GetIntrinsicModifierName()
	return "modifier_item_desolator_lod_passive"
end

function item_desolator_consumable:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Prevent Tempest Double abuse
	if caster:IsTempestDouble() or target:IsTempestDouble() then
		return
	end

	-- Stats for consumed item
	local damage = self:GetSpecialValueFor("bonus_damage") + self:GetSpecialValueFor("max_damage")
	local armor_reduction = self:GetSpecialValueFor("corruption_armor")
	local debuff_duration = self:GetSpecialValueFor("corruption_duration")

	local table_to_send = {
		dmg = damage,
		armor = armor_reduction,
		dur = debuff_duration,
	}

	if caster == target and not caster:HasModifier("modifier_item_desolator_lod_consumed") then
		caster:AddNewModifier(caster, self, "modifier_item_desolator_lod_consumed", table_to_send)
		caster:EmitSound("DOTA_Item.IronTalon.Activate")
		caster.desolator_stacks_lod = nil -- since we gave max stacks when consumed, remove the counter
		self:SpendCharge(0.1)
	end
end

function item_desolator_consumable:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	-- Check if its the caster thats targetted
	if caster ~= target then
		return UF_FAIL_CUSTOM
	end

	-- Check if already consumed
	if caster:HasModifier("modifier_item_desolator_lod_consumed") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function item_desolator_consumable:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster ~= target then
		return "#consumable_items_only_self"
	end

	if caster:HasModifier("modifier_item_desolator_lod_consumed") then
		return "#consumable_items_already_consumed"
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_passive = modifier_item_desolator_lod_passive or class({})

function modifier_item_desolator_lod_passive:IsHidden()
	return true
end

function modifier_item_desolator_lod_passive:IsDebuff()
	return false
end

function modifier_item_desolator_lod_passive:IsPurgable()
	return false
end

function modifier_item_desolator_lod_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_desolator_lod_passive:IsFirstItemInInventory()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:IsNull() or ability:IsNull() then
		return false
	end

	if not IsServer() then
		print("IsFirstItemInInventory will not return the correct result on the client!")
		return
	end

	return parent:FindAllModifiersByName(self:GetName())[1] == self
end

function modifier_item_desolator_lod_passive:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	end
end

modifier_item_desolator_lod_passive.OnRefresh = modifier_item_desolator_lod_passive.OnCreated

function modifier_item_desolator_lod_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_desolator_lod_passive:GetModifierProjectileName()
	if self:IsFirstItemInInventory() then
		return "particles/items_fx/desolator_projectile.vpcf"
	end
end

function modifier_item_desolator_lod_passive:GetModifierPreAttack_BonusDamage()
	local parent = self:GetParent()
	if not parent.desolator_stacks_lod then
		parent.desolator_stacks_lod = 0
	end
	return self.bonus_damage + parent.desolator_stacks_lod
end

if IsServer() then
	function modifier_item_desolator_lod_passive:OnAttackLanded(event)
		if not self:IsFirstItemInInventory() then
			return
		end

		local parent = self:GetParent()
		local ability = self:GetAbility()
		local target = event.target

		if parent ~= event.attacker then
			return
		end

		-- Desolator doesnt work on illusions
		if parent:IsIllusion() then
			return
		end

		-- To prevent crashes:
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Doesn't work when attacking allies
		if target:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		-- Doesn't work when attacking wards
		if target:IsOther() then
			return
		end

		-- Calculate duration of the debuff
		local armor_reduction_duration = ability:GetSpecialValueFor("corruption_duration")
		-- Calculate duration while keeping status resistance in mind
		--local armor_reduction_duration = target:GetValueChangedByStatusResistance(armor_reduction_duration)
		-- Apply passive debuff
		target:AddNewModifier(parent, ability, "modifier_item_desolator_lod_debuff", {duration = armor_reduction_duration})
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_debuff = modifier_item_desolator_lod_debuff or class({})

function modifier_item_desolator_lod_debuff:IsHidden()
	return false
end

function modifier_item_desolator_lod_debuff:IsDebuff()
	return true
end

function modifier_item_desolator_lod_debuff:IsPurgable()
	return true
end

function modifier_item_desolator_lod_debuff:OnCreated(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("corruption_armor")
	else
		if IsServer() then
			self.armor_reduction = event.armor
			self:SetHasCustomTransmitterData(true)
		end
	end
end

function modifier_item_desolator_lod_debuff:OnRefresh(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("corruption_armor")
	else
		if IsServer() then
			self.armor_reduction = self.armor_reduction or event.armor
			self:SendBuffRefreshToClients()
		end
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_desolator_lod_debuff:AddCustomTransmitterData()
    return {
        armor_reduction = self.armor_reduction,
    }
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_desolator_lod_debuff:HandleCustomTransmitterData(data)
    self.armor_reduction = data.armor_reduction
end

function modifier_item_desolator_lod_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_item_desolator_lod_debuff:GetModifierPhysicalArmorBonus()
	return 0 - math.abs(self.armor_reduction)
end

if IsServer() then
	function modifier_item_desolator_lod_debuff:OnDeath(event)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local killer = event.attacker
		local dead = event.unit
		
		-- Check if the dead has this debuff
		if dead ~= parent then
			return
		end
		
		-- Check for existence of GetUnitName method to determine if dead unit isn't something weird (an item, rune etc.)
		if parent.GetUnitName == nil then
			return
		end

		-- Don't continue when killing a buildings, wards or illusions
		if parent:IsTower() or parent:IsBarracks() or parent:IsBuilding() or parent:IsOther() or parent:IsIllusion() then
			return
		end

		-- Don't continue when killing creeps, Tempest Doubles, Meepo Clones, Spirit Bears or reincarnating heroes
		if not parent:IsHero() or parent:IsTempestDouble() or parent:IsClone() or parent:IsSpiritBearCustom() or parent:IsReincarnating() then
			return
		end
		
		-- Check if caster exists
		if not caster or caster:IsNull() then
			return
		end

		-- Desolator does not grant charges to illusions or if caster is dead 
		if caster:IsIllusion() or not caster:IsAlive() then
			return
		end
		
		-- Desolator does not grant charges to Tempest Doubles and Monkey King clones
		if IsMonkeyKingCloneCustom(caster) or caster:IsTempestDouble() then
			return
		end

		-- Don't continue if the killer doesn't exist
		if not killer or killer:IsNull() then
			return
		end

		local ability = self:GetAbility()
		if not ability or ability:IsNull() then
			return
		end

		local stacks_per_kill = ability:GetSpecialValueFor("bonus_damage_per_kill")
		local stacks_per_assist = ability:GetSpecialValueFor("bonus_damage_per_assist")
		local max_stacks = ability:GetSpecialValueFor("max_damage")
		
		local deso_passives = caster:FindAllModifiersByName("modifier_item_desolator_lod_passive")
		if not deso_passives then
			return
		end
		
		local deso_modifier = deso_passives[1]
		if not deso_modifier then
			return
		end
		
		if not caster.desolator_stacks_lod then
			caster.desolator_stacks_lod = 0
		end

		-- Check if caster has max stacks or already consumed Desolator -> prevents getting stacks over max
		if caster.desolator_stacks_lod == max_stacks or caster:HasModifier("modifier_item_desolator_lod_consumed") then
			return
		end
		
		local stacks_increase = 0
		if killer == caster then
			stacks_increase = stacks_per_kill
		elseif killer:GetTeamNumber() == caster:GetTeamNumber() then
			stacks_increase = stacks_per_assist
		end
		
		caster.desolator_stacks_lod = math.min(caster.desolator_stacks_lod + stacks_increase, max_stacks)
	end
end

function modifier_item_desolator_lod_debuff:GetTexture()
	return "item_desolator"
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_consumed = modifier_item_desolator_lod_consumed or class({})

function modifier_item_desolator_lod_consumed:IsHidden()
	return false
end

function modifier_item_desolator_lod_consumed:IsPurgable()
	return false
end

function modifier_item_desolator_lod_consumed:IsDebuff()
	return false
end

function modifier_item_desolator_lod_consumed:RemoveOnDeath()
	return false
end

function modifier_item_desolator_lod_consumed:GetTexture()
	return "item_desolator"
end

function modifier_item_desolator_lod_consumed:OnCreated(event)
	if IsServer() then
		self:SetStackCount(0 - event.dmg)
		self.armor = event.armor
		self.dur = event.dur
	end
end

function modifier_item_desolator_lod_consumed:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_desolator_lod_consumed:GetModifierProjectileName()
	if not self:GetParent():HasModifier("modifier_item_desolator_lod_passive") then
		return "particles/items_fx/desolator_projectile.vpcf"
	end
end

function modifier_item_desolator_lod_consumed:GetModifierPreAttack_BonusDamage()
	return math.abs(self:GetStackCount())
end

if IsServer() then
	function modifier_item_desolator_lod_consumed:OnAttackLanded(event)
		local parent = self:GetParent()

		if parent:HasModifier("modifier_item_desolator_lod_passive") then
			return
		end

		local target = event.target

		if parent ~= event.attacker then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- To prevent crashes:
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Doesn't work when attacking allies
		if target:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		-- Doesn't work when attacking wards
		if target:IsOther() then
			return
		end

		-- Calculate duration of the debuff
		local armor_reduction_duration = self.dur
		-- Calculate duration while keeping status resistance in mind
		--local armor_reduction_duration = target:GetValueChangedByStatusResistance(armor_reduction_duration)
		-- Apply passive debuff
		target:AddNewModifier(parent, nil, "modifier_item_desolator_lod_debuff", {duration = armor_reduction_duration, armor = self.armor})
	end
end
