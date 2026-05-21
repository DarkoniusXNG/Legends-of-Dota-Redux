if spell_lab_survivor_base_modifier == nil then
	spell_lab_survivor_base_modifier = class({})
end

function spell_lab_survivor_base_modifier:GetSurvivorBonus()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end

function spell_lab_survivor_base_modifier:OnDeath(kv)
  if IsServer() then
    if kv.unit == self:GetParent() and not kv.unit:IsReincarnating() then
      self:DeathProc()
    end
  end
end

function spell_lab_survivor_base_modifier:DeathProc()
	if self.death_proc == false then
		local bonus_per_minute = self:GetAbility():GetSpecialValueFor("bonus")
		local stacks_on_death = self.kept_stacks + (GameRules:GetGameTime() - self.lastdeath) * bonus_per_minute / 60
		self.kept_stacks = stacks_on_death / 3
    	self.lastdeath = GameRules:GetGameTime()
  		self:SetStackCount(self.kept_stacks)
		self.death_proc = true
	else
		self.lastdeath = self.lastdeath + 1
	end
end


function spell_lab_survivor_base_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_base_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_base_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_base_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		self.death_proc = false
		self.enemeyFoutain = false
		self.battleThirst = 0
		self.kept_stacks = 0
		if not self:GetParent():IsRealHero() then
			local hOwner = self:GetParent():GetOwner()
			if hOwner ~= nil then
				local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName(self:GetName())
				if hOriginModifier ~= nil then
	      			self:SetStackCount(hOriginModifier:GetStackCount())
	    		end
  			end
		else
			if self:GetParent():GetTeam() == DOTA_TEAM_GOODGUYS then
				self.enemeyFoutain = Entities:FindAllByName("ent_dota_fountain_bad")
			else
				self.enemeyFoutain = Entities:FindAllByName("ent_dota_fountain_good")
			end
		end
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_base_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsRealHero() then
			self:StartIntervalThink( -1 )
			return
		end
		if not self:GetParent():IsAlive() and not self:GetParent():IsReincarnating() then
			self:DeathProc() -- this only increases the self.lastdeath counter
			return
		end
		self.death_proc = false
  		if self:GetAbility():GetLevel() > 0 then
			self:CheckBattleThirst()
			local max = self:GetAbility():GetSpecialValueFor("max")
			local bonus_per_minute = self:GetAbility():GetSpecialValueFor("bonus")
			local old = self:GetStackCount()
			if (max ~= nil and max > 0 and old >= max) then
				self.lastdeath = self.lastdeath + 1
				return
			end
      		local stacks = self.kept_stacks + (GameRules:GetGameTime() - self.lastdeath) * bonus_per_minute / 60
  			self:SetStackCount(stacks)
			if (old ~= self:GetStackCount()) then
				self:GetParent():CalculateStatBonus(true)
			end
  		end
	end
end
function spell_lab_survivor_base_modifier:CheckBattleThirst()
	if self.enemeyFoutain then
		local bt = self:GetAbility():GetSpecialValueFor("battle_thirst")
		if (bt ~= nil and bt > 0) then
			local hParent = self:GetParent()
			local iTeam = hParent:GetTeamNumber()
			if self.enemeyFoutain[1]:CanEntityBeSeenByMyTeam(hParent) then
				self.battleThirst = 0
			else
				self.battleThirst = self.battleThirst + 1
				if self.battleThirst > bt then
					self.lastdeath = self.lastdeath + 1
					if self.battleThirst > bt + 3 then
						self.battleThirst = bt
						SendOverheadEventMessage( hParent:GetPlayerOwner(), OVERHEAD_ALERT_DENY , hParent, 1, nil )
					end
				end
			end
		end
	end
end
function spell_lab_survivor_base_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
return spell_lab_survivor_base_modifier
