--------------------------------------------------------------------------------------------------------
--
--		Hero: Enigma
--		Perk: Black Hole kills reduce Enigma's remaining cooldowns by 50%, or 30 seconds if they're over 2 minutes.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_enigma_perk ~= "" then modifier_npc_dota_hero_enigma_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_HERO_KILLED  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = keys.inflictor
		local target = keys.target
		local attacker = keys.attacker
		if attacker == caster then
			if ability then 
				self.ability = ability -- Killing ability
			else
				self.ability = nil
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:OnHeroKilled(keys)
	if IsServer() then
		local caster = self:GetCaster() 
		local target = keys.target
		local attacker = keys.attacker

		if attacker == caster and self.ability then
			if string.find(self.ability:GetName(), "black_hole") then
				-- Reduces remaining cooldown by 50%
				local cooldownReduction = 50
				for i = 0, caster:GetAbilityCount() - 1 do
					local ability = caster:GetAbilityByIndex(i)
					if ability and not ability:IsCooldownReady() then
						local cooldown = ability:GetCooldownTimeRemaining() * cooldownReduction * 0.01
						if cooldown > 120 then cooldown = ability:GetCooldownTimeRemaining() - 30 end
						ability:EndCooldown()
						ability:StartCooldown(cooldown)
					end
				end
			end
		end
	end
end

