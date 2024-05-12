--------------------------------------------------------------------------------------------------------
--
--		Hero: Timbersaw
--		Perk: Timbersaw gains 3% health, mana whenever a nearby tree (700 radius) is cut down. 
--
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_shredder_perk = modifier_npc_dota_hero_shredder_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_shredder_perk:GetTexture()
	return "custom/npc_dota_hero_shredder_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:OnCreated()
	ListenToGameEvent("tree_cut", function(keys)
		local caster = self:GetCaster()
		local treeX = keys.tree_x
		local treeY = keys.tree_y
		local treeVector = Vector(treeX, treeY, 0)

		local HPamount = caster:GetMaxHealth() * .03
		local MPamount = caster:GetMaxMana() * .03

		if caster and (caster:GetAbsOrigin() - treeVector):Length2D() <= 700 then
			caster:Heal(HPamount, nil)
			caster:GiveMana(MPamount)
		end
	end, nil)
end
