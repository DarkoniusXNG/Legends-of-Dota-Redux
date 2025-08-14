modifier_light_blade_fade = class ({})

function modifier_light_blade_fade:IsDebuff()
	return false
end

function modifier_light_blade_fade:IsHidden()
	return true
end

function modifier_light_blade_fade:IsPurgable()
	return false
end

function modifier_light_blade_fade:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
