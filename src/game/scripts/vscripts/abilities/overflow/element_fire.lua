if element_fire == nil then
	element_fire = class({})
end

function element_fire:OnCreated( kv )
	if IsServer() then
		if kv.stacks ~= nil then
			self:SetStackCount(kv.stacks)
		else
			self:SetStackCount(1)
		end

		self:CalculateDuration()
		self:StartIntervalThink(0.5)
	end
end

function element_fire:OnRefresh( kv )
	if IsServer() then
		local stacks = self:GetStackCount() + kv.stacks
		if stacks > 999 then stacks = 999 end
		self:SetStackCount(stacks)
		self:CalculateDuration()
	end
end

function element_fire:CalculateDuration()
	self:SetDuration( self:GetStackCount()*0.5, true )
end

function element_fire:GetTexture()
	return "custom/element_fire"
end

function element_fire:OnIntervalThink()
	if IsServer() then
		local nDamageCalc = self:GetStackCount() * 2
		local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = nDamageCalc,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}

		if not self:GetParent():HasModifier("element_water") then
			ApplyDamage(damageTable)
		end

		self:DecrementStackCount()
		if self:GetParent():HasModifier("element_water") and self:GetStackCount() > 0 then
			self:DecrementStackCount()
		end
		if self:GetStackCount() < 1 then
			self:StartIntervalThink(-1)
			self:Destroy()
		end
	end
end

function element_fire:IsHidden()
	return false
end

function element_fire:IsPurgable()
	return true
end

function element_fire:RemoveOnDeath()
	return true
end

function element_fire:GetEffectName()
	return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn_creep.vpcf"
end

function element_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
