modifier_movespeed_cap = class({})

function modifier_movespeed_cap:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }
end

function modifier_movespeed_cap:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_movespeed_cap:IsPurgable()
    return false
end

function modifier_movespeed_cap:IsHidden()
    return true
end

function modifier_movespeed_cap:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
	end
end
