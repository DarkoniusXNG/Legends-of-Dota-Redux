--------------------------------------------------------------------------------------------------------
--      Hero: Templar Assassin
--      Perk: Psi Blades Free Ability + Templar Assassin turns invisible when not moving for 2 seconds. Breaks upon moving, attacking or casting a spell.
--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_templar_assassin_invis_break", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_templar_assassin_invis", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua", LUA_MODIFIER_MOTION_NONE)

modifier_npc_dota_hero_templar_assassin_perk = modifier_npc_dota_hero_templar_assassin_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_templar_assassin_perk:GetTexture()
	return "custom/npc_dota_hero_templar_assassin_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnCreated(keys)
    if IsServer() then
		local caster = self:GetCaster()
        self.invisDelay = 2
        caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_templar_assassin_invis_break", {duration = self.invisDelay})

		local psi_blades = caster:FindAbilityByName("templar_assassin_psi_blades")
		if psi_blades then
			psi_blades:UpgradeAbility(false)
		else
			psi_blades = caster:AddAbility("templar_assassin_psi_blades")
			--psi_blades:SetStolen(true)
			psi_blades:SetActivated(true)
			psi_blades:SetLevel(1)
		end
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_UNIT_MOVED,
        MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_templar_assassin_perk:OnUnitMoved(keys)
		if keys.unit and self:GetCaster() == keys.unit then
			self:GetCaster():RemoveModifierByName("modifier_npc_dota_hero_templar_assassin_invis")
			self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_npc_dota_hero_templar_assassin_invis_break", {duration = self.invisDelay})
		end
	end
	--------------------------------------------------------------------------------------------------------
	function modifier_npc_dota_hero_templar_assassin_perk:OnAttack(keys)
		if keys.attacker and self:GetCaster() == keys.attacker then
			self:GetCaster():RemoveModifierByName("modifier_npc_dota_hero_templar_assassin_invis")
			self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_npc_dota_hero_templar_assassin_invis_break", {duration = self.invisDelay})
		end
	end

	function modifier_npc_dota_hero_templar_assassin_perk:OnAbilityExecuted(keys)
		if keys.unit and keys.unit == self:GetCaster() then
			self:GetCaster():RemoveModifierByName("modifier_npc_dota_hero_templar_assassin_invis")
			self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_npc_dota_hero_templar_assassin_invis_break", {duration = self.invisDelay})
		end
	end
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_invis_break
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_templar_assassin_invis_break = modifier_npc_dota_hero_templar_assassin_invis_break or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:IsHidden()
    return false
end

function modifier_npc_dota_hero_templar_assassin_invis_break:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(particle)
        self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_npc_dota_hero_templar_assassin_invis", {})
    end
end

function modifier_npc_dota_hero_templar_assassin_invis_break:GetTexture()
	return "templar_assassin_meld"
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_invis
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_templar_assassin_invis = modifier_npc_dota_hero_templar_assassin_invis or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:GetModifierInvisibilityLevel()
    return 1
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end

function modifier_npc_dota_hero_templar_assassin_invis:GetTexture()
	return "templar_assassin_meld"
end
