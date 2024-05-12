--------------------------------------------------------------------------------------------------------
--    Hero: Outworld Devourer
--    Perk: Astral Imprisonment steals 7 intelligence for 60 seconds when cast by Outworld Devourer.
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", "abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", "abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_npc_dota_hero_obsidian_destroyer_perk = modifier_npc_dota_hero_obsidian_destroyer_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:OnCreated(keys)
	self:GetCaster().intelligenceSteal = 7
	self:GetCaster().duration = 60
end

function modifier_npc_dota_hero_obsidian_destroyer_perk:GetTexture()
	return "custom/npc_dota_hero_obsidian_destroyer_perk"
end

--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_obsidian_destroyer_perk_buff = modifier_npc_dota_hero_obsidian_destroyer_perk_buff or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetTexture()
	return "obsidian_destroyer_astral_imprisonment"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetModifierBonusStats_Intellect()
	return self:GetCaster().intelligenceSteal
end
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_obsidian_destroyer_perk_debuff = modifier_npc_dota_hero_obsidian_destroyer_perk_debuff or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:IsDebuff()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:IsPurgable()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetTexture()
	return "obsidian_destroyer_astral_imprisonment"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetModifierBonusStats_Intellect()
	return 0 - math.abs(self:GetCaster().intelligenceSteal)
end
--------------------------------------------------------------------------------------------------------
function perkOD(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
	local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	if not parent_index or not caster_index or not ability_index then
		return true
	end
	local parent = EntIndexToHScript( parent_index )
	local caster = EntIndexToHScript( caster_index )
	local ability = EntIndexToHScript( ability_index )
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_obsidian_destroyer_perk") then
			if string.find(ability:GetName(), "astral_imprisonment") and parent:IsHero() and parent:GetTeam() ~= caster:GetTeam() then
				caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", {duration = caster.duration})
				-- Debuff cannot be applied while target is invulnerable, so this must be done.
				Timers:CreateTimer(function()
					if parent and caster and not parent:IsNull() and not caster:IsNull() then
						parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", {duration = caster.duration - 4.1})
					end
					return
				end, DoUniqueString("applyIntSteal"), 4.1)
			end
		end
	end
end
