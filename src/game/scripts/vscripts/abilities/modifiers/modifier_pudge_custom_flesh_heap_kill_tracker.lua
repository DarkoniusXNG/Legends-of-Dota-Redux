local flesh_heap_modifiers = {
	"modifier_flesh_heap_agi",
	"modifier_flesh_heap_aoe",
	"modifier_flesh_heap_armor",
	"modifier_flesh_heap_attack_range",
	"modifier_flesh_heap_attack_speed",
	"modifier_flesh_heap_bonus_vision",
	"modifier_flesh_heap_cast_range",
	"modifier_flesh_heap_cooldown_reduction",
	"modifier_flesh_heap_evasion",
	"modifier_flesh_heap_heal_amp",
	"modifier_flesh_heap_health_regeneration",
	"modifier_flesh_heap_int",
	"modifier_flesh_heap_lifesteal",
	"modifier_flesh_heap_magic_resistance",
	"modifier_flesh_heap_mana_regeneration",
	"modifier_flesh_heap_minion_damage",
	"modifier_flesh_heap_move_speed",
	"modifier_flesh_heap_spell_amp",
	"modifier_flesh_heap_spell_lifesteal",
	"modifier_flesh_heap_str",
	"modifier_flesh_heap_tenacity",
	"modifier_flesh_heap_willpower",
}

---------------------------------------------------------------------------------------------------
-- Only tracks kills
modifier_pudge_custom_flesh_heap_kill_tracker = class({})

function modifier_pudge_custom_flesh_heap_kill_tracker:IsHidden()
	return true
end

function modifier_pudge_custom_flesh_heap_kill_tracker:IsDebuff()
	return false
end

function modifier_pudge_custom_flesh_heap_kill_tracker:IsPurgable()
	return false
end

function modifier_pudge_custom_flesh_heap_kill_tracker:RemoveOnDeath()
	return false
end

function modifier_pudge_custom_flesh_heap_kill_tracker:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH,
  }
end

if IsServer() then
	function modifier_pudge_custom_flesh_heap_kill_tracker:OnDeath(event)
		local parent = self:GetParent()
		local killer = event.attacker
		local dead = event.unit

		-- Flesh Heap doesn't work when Pudge is dead
		if not parent:IsAlive() then
			return
		end
		
		-- Flesh Heap doesn't work for creeps, illusions, tempest doubles and clones
		if not parent:IsRealHero() or parent:IsIllusion() or parent:IsTempestDouble() or parent:IsClone() then
			self:Destroy()
			return
		end

		-- Don't continue if the killer doesn't exist
		if not killer or killer:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if dead unit isn't something weird (an item, rune etc.)
		if dead.GetUnitName == nil then
			return
		end

		-- Don't trigger on Pudge deaths and allied deaths
		if parent == dead or dead:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		-- Flesh Heap stacks don't increase when killing a buildings, wards or illusions
		if dead:IsTower() or dead:IsBarracks() or dead:IsBuilding() or dead:IsOther() or dead:IsIllusion() then
			return
		end

		local parent_loc = parent:GetAbsOrigin()
		local dead_loc = dead:GetAbsOrigin()
		local parentToDeadVector = dead_loc - parent_loc
		local ability = self:GetAbility()
		local flesh_heap_range = 450
		if ability then
			flesh_heap_range = ability:GetSpecialValueFor("flesh_heap_range")
		end
		if flesh_heap_range == 0 then
			flesh_heap_range = 450
		end
		local isDeadInRange = parentToDeadVector:Length2D() <= flesh_heap_range

		if isDeadInRange or killer == parent then
			if dead:IsRealHero() and not dead:IsClone() and not dead:IsTempestDouble() and not dead:IsReincarnating() then
				self:IncrementStackCount()
				
				for k, v in pairs(flesh_heap_modifiers) do
					local mod = parent:FindModifierByName(v)
					if mod then
						mod:OnRefresh()
					end
				end

				local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
				ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
				ParticleManager:ReleaseParticleIndex(nFXIndex)
			end
		end
	end
end
