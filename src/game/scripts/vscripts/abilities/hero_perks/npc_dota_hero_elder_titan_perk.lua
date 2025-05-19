--------------------------------------------------------------------------------------------------------
--      Hero: Elder Titan
--      Perk: Increased movement speed by 5% for every aura Elder Titan is carrying.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_elder_titan_perk = modifier_npc_dota_hero_elder_titan_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_elder_titan_perk:GetTexture()
	return "custom/npc_dota_hero_elder_titan_perk"
end

function modifier_npc_dota_hero_elder_titan_perk:OnCreated()
	self.bonusPerAura = 5
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_npc_dota_hero_elder_titan_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability_auras = 0
		local item_auras = {}

		for i = 0, caster:GetAbilityCount() - 1 do 
			local ability = caster:GetAbilityByIndex(i)
			if ability and ability:HasAbilityFlag("aura") and ability:GetLevel() > 0 then
				ability_auras = ability_auras + 1
			end
		end

		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do 
			local item = caster:GetItemInSlot(i)
			local addItem = true
			if item and item:HasAbilityFlag("aura") then
				for _, v in ipairs(item_auras) do 
					if v == item:GetName() then
						addItem = false
						break
					end
				end

				if addItem then
					table.insert(item_auras, item:GetName())
				end
			end
		end

		local stacks = (ability_auras + #item_auras) * self.bonusPerAura
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_elder_titan_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_elder_titan_perk:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount()
end
