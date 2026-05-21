--------------------------------------------------------------------------------------------------------
--      Hero: Visage
--      Perk: Visage gains spell amp for each level put in an Aura ability. Includes item auras.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_visage_perk = modifier_npc_dota_hero_visage_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_visage_perk:GetTexture()
	return "custom/npc_dota_hero_visage_perk"
end

function modifier_npc_dota_hero_visage_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_npc_dota_hero_visage_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability_aura_lvls = 0
		local item_auras = {}

		for i = 0, caster:GetAbilityCount() - 1 do 
			local ability = caster:GetAbilityByIndex(i)
			if ability and ability:HasAbilityFlag("aura") then
				ability_aura_lvls = ability_aura_lvls + ability:GetLevel() * self.bonusPerLevel
			end
		end

		local max_slot = DOTA_ITEM_SLOT_6
		if caster:HasModifier("modifier_spoons_stash_oaa") then
            max_slot = DOTA_ITEM_SLOT_9
        end
		for i = DOTA_ITEM_SLOT_1, max_slot do
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

		local stacks = ability_aura_lvls + #item_auras
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_visage_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_visage_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
