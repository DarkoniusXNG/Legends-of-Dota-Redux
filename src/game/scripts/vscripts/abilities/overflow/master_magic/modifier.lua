if master_magic_mod == nil then
	master_magic_mod = class({})
end

function master_magic_mod:OnCreated( kv )	
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/master_magic.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(self.nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true) 
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
		if not kv.stacks then kv.stacks = 1 end
		self:SetStackCount(kv.stacks)
	end
end
 
function master_magic_mod:OnRefresh( kv )	
	if IsServer() then
		local old = self:GetStackCount()
		local hAbility = self:GetAbility()
		self:SetDuration(self:GetDuration()+hAbility:GetSpecialValueFor("duration"), true) 
		if not kv.stacks then kv.stacks = 1 end
		self:SetStackCount(kv.stacks + old)
	end
end

function master_magic_mod:OnDestroy()
	if IsServer() then
	end
end
 
function master_magic_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

if IsServer() then
	function master_magic_mod:OnAbilityFullyCast(params)
		local unit = params.unit
		local ability = self:GetAbility()
		local cast_ability = params.ability
		if unit == self:GetParent() and cast_ability then
			local cast_ability_name = cast_ability:GetAbilityName()
			if cast_ability == ability or cast_ability_name == "item_refresher" or cast_ability_name == "item_hand_of_midas" then
				return
			end
			local behavior_int = cast_ability:GetBehaviorInt()
			local behavior = cast_ability:GetBehavior()
			if type(behavior) == 'userdata' then
				behavior = tonumber(tostring(behavior))
			end
			if bit.band(DOTA_ABILITY_BEHAVIOR_AUTOCAST, behavior) == DOTA_ABILITY_BEHAVIOR_AUTOCAST or bit.band(DOTA_ABILITY_BEHAVIOR_AUTOCAST, behavior_int) == DOTA_ABILITY_BEHAVIOR_AUTOCAST then
				return
			end
			if bit.band(DOTA_ABILITY_BEHAVIOR_TOGGLE, behavior) == DOTA_ABILITY_BEHAVIOR_TOGGLE or bit.band(DOTA_ABILITY_BEHAVIOR_TOGGLE, behavior_int) == DOTA_ABILITY_BEHAVIOR_TOGGLE then
				return
			end

			local isUltimate = false
			local cast_ability_type = cast_ability:GetAbilityType()
			-- If its an ultimate, there needs to be two charges, if not, return
			if cast_ability_type == ABILITY_TYPE_ULTIMATE and self:GetStackCount() < 3 then
				return
			elseif cast_ability_type == ABILITY_TYPE_ULTIMATE and self:GetStackCount() >= 3 then
				isUltimate = true
			end

			cast_ability:EndCooldown()
			if unit:HasScepter() and RandomInt(1, 100) <= ability:GetSpecialValueFor("chance_scepter") then
				EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Brewmaster_Storm.DispelMagic", self:GetCaster() )
			else
				self:DecrementStackCount()
				-- If its an ultimate reduce 2 extra stack
				if isUltimate then
					self:DecrementStackCount()
					self:DecrementStackCount()
				end
			end
			if self:GetStackCount() <= 0 then
				self:Destroy()
			end
		end
	end
end

function master_magic_mod:IsHidden()
	return false
end

function master_magic_mod:IsPurgable() 
	return true
end

function master_magic_mod:IsPurgeException()
	return true
end

function master_magic_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function master_magic_mod:AllowIllusionDuplicate() 
	return false
end
