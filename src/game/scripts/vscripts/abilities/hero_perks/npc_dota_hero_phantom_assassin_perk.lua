--------------------------------------------------------------------------------------------------------
--		Hero: Phantom Assassin
--		Perk: Dagger abilities cast by Phantom Assassin will have reduced mana cost. Phantom Assassin will gain a stackable Agility buff for a few seconds every time she evades an attack.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_phantom_assassin_perk = modifier_npc_dota_hero_phantom_assassin_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_phantom_assassin_perk:GetTexture()
	return "custom/npc_dota_hero_phantom_assassin_perk"
end

function modifier_npc_dota_hero_phantom_assassin_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
	}
end

function modifier_npc_dota_hero_phantom_assassin_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("dagger") then
			return 50
		end
	end
	return 0
end

if IsServer() then
	function modifier_npc_dota_hero_phantom_assassin_perk:OnAttackFail(event)
		local parent = self:GetParent()
		if event.target == parent and event.fail_type == DOTA_ATTACK_RECORD_FAIL_TARGET_EVADED then
			parent:AddNewModifier(parent, nil, "modifier_npc_dota_hero_phantom_assassin_perk_buff", {duration = 10})
		end
	end
end

--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_perk_buff", "abilities/hero_perks/npc_dota_hero_phantom_assassin_perk.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_phantom_assassin_perk_buff = modifier_npc_dota_hero_phantom_assassin_perk_buff or class({})

function modifier_npc_dota_hero_phantom_assassin_perk_buff:IsHidden()
	return true
end

function modifier_npc_dota_hero_phantom_assassin_perk_buff:IsDebuff()
	return false
end

function modifier_npc_dota_hero_phantom_assassin_perk_buff:IsPurgable()
	return false
end

function modifier_npc_dota_hero_phantom_assassin_perk_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_npc_dota_hero_phantom_assassin_perk_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_npc_dota_hero_phantom_assassin_perk_buff:GetModifierBonusStats_Agility()
	return 1
end
