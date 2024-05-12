--------------------------------------------------------------------------------------------------------
--
--		Hero: Lone Druid
--		Perk: Lone Druid transfers 50% of damage taken to his Spirit Bear if he has one and its within 1100 range.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lone_druid_perk ~= "" then modifier_npc_dota_hero_lone_druid_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_lone_druid_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lone_druid_perk:GetTexture()
	return "custom/npc_dota_hero_lone_druid_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsHidden()
	if IsClient() then
		if not self.check then
			local netTable = CustomNetTables:GetTableValue( "heroes", self:GetParent():GetName().."_perk"..self:GetParent():GetPlayerOwnerID() )
			if netTable then
				self.bear = netTable.hasValidAbility
			end
			self.check = true
		end
		if self.bear == 0 then return true else return false end
	end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_lone_druid_perk:OnCreated()
		self.bear = self:GetCaster():FindAbilityByName("lone_druid_spirit_bear")
		
		CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk"..self:GetParent():GetPlayerID(), { hasValidAbility = self.bear or false} )
		
		self.damageTaken = 0.5
		self.damageRedirect = 1 - self.damageTaken
		self.suicide = {item_bloodstone = true,
						techies_suicide = true}
		self.leash = 1800
	end

	function modifier_npc_dota_hero_lone_druid_perk:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
		return funcs
	end

	function modifier_npc_dota_hero_lone_druid_perk:OnTakeDamage(params)
		if params.unit == self:GetParent() then
			if params.inflictor and self.suicide[params.inflictor:GetName()] then return end
			if self.bear then
				for _,bear in pairs ( Entities:FindAllByName( "npc_dota_lone_druid_bear*")) do
					if bear:GetOwnerEntity() == self:GetParent() and bear:IsAlive() then
						local distance = (bear:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
						if distance < self.leash then
							local damage = params.damage
							if damage > self:GetParent():GetHealth() then damage = self:GetParent():GetHealth() end -- cap overkill damage
							if bear:GetHealth() > damage*self.damageRedirect then
								self:GetParent():SetHealth( self:GetParent():GetHealth() + damage*self.damageTaken )
								bear:SetHealth( bear:GetHealth() - damage*self.damageRedirect )
							else
								self:GetParent():SetHealth( self:GetParent():GetHealth() + bear:GetHealth() - 1 )
								bear:SetHealth(1)
							end
						end
					end
				end
			end
		end
	end
end
