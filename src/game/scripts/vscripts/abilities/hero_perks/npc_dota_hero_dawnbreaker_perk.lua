--------------------------------------------------------------------------------------------------------
--		Hero: Dawnbreaker
--		Perk: Dawnbreaker gains all health restoration amp for every level of Light spells she has.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_dawnbreaker_perk = modifier_npc_dota_hero_dawnbreaker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:RemoveOnDeath()
	return false
end

-- function modifier_npc_dota_hero_dawnbreaker_perk:GetTexture()
	-- return "custom/npc_dota_hero_dawnbreaker_perk"
-- end

function modifier_npc_dota_hero_dawnbreaker_perk:OnCreated()
	self.bonusPerLevel = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_dawnbreaker_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("light") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_dawnbreaker_perk:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		--MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_HEALTH_GAINED,
	}
end

--function modifier_npc_dota_hero_dawnbreaker_perk:GetModifierHPRegenAmplify_Percentage()
	--return self:GetStackCount()
--end

--function modifier_npc_dota_hero_dawnbreaker_perk:GetModifierLifestealRegenAmplify_Percentage()
	--return self:GetStackCount()
--end

if IsServer() then
  function modifier_npc_dota_hero_dawnbreaker_perk:OnHealthGained(event)
    local parent = self:GetParent()
    local unit_that_gained_hp = event.unit

    -- Check if unit has this modifier
    if unit_that_gained_hp ~= parent then
      return
    end

    local gained_hp = event.gain

    -- Check if gained health is negative or 0
    if gained_hp <= 0 then
      return
    end

    -- Prevent looping
    if self.flag then
      return
    end

    local extra_health = gained_hp * self:GetStackCount() / 100

    -- Imitate heal amp and health restoration amp
    self.flag = true
    --parent:Heal(extra_health, nil)
    parent:HealWithParams(extra_health, nil, false, false, parent, false)
    self.flag = false
  end
end
