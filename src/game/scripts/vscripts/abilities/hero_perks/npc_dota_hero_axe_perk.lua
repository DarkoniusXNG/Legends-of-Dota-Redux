--------------------------------------------------------------------------------------------------------
--
--		Hero: Axe
--		Perk: Culling Blade kills will chop the remaining cooldown times of Axe's abilities in half, or by 30 seconds if the remaining cooldown exceeds 1 minute. 
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_axe_perk ~= "" then modifier_npc_dota_hero_axe_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_axe_perk:GetTexture()
	return "custom/npc_dota_hero_axe_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnCreated()
	self.cooldownReductionPct = 50
	self.cooldownReduction = 1 - (self.cooldownReductionPct / 100)
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_EVENT_ON_HERO_KILLED  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = keys.inflictor
		local target = keys.target
		local attacker = keys.attacker
		if attacker == caster then
			if ability then 
				self.ability = ability 
			else
				self.ability = nil
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnHeroKilled(keys)
	if IsServer() then
		local caster = self:GetCaster() 
		local target = keys.target
		local attacker = keys.attacker

		if attacker == caster and self.ability then
			local ability = caster:FindAbilityByName(self.ability:GetName())
			if ability and ability:GetName() == "axe_culling_blade" then
				for i = 0, caster:GetAbilityCount() - 1 do 
					local ab = caster:GetAbilityByIndex(i)
					if ab and not ab:IsCooldownReady() then
						local cooldown = ab:GetCooldownTimeRemaining() * self.cooldownReduction
						if cooldown > 30 then cooldown = ab:GetCooldownTimeRemaining() - 30 end
						ab:EndCooldown()
						ab:StartCooldown(cooldown)
					end
				end
			end
		end
	end
end
