LinkLuaModifier( "modifier_jingtong_cheat", "abilities/jingtong_cheat.lua" ,LUA_MODIFIER_MOTION_NONE )

jingtong_cheat = jingtong_cheat or class({})

function jingtong_cheat:GetIntrinsicModifierName()
  return "modifier_jingtong_cheat"
end

modifier_jingtong_cheat = modifier_jingtong_cheat or class({})

function modifier_jingtong_cheat:IsPassive()
  return true
end

function modifier_jingtong_cheat:IsHidden()
  return true
end

function modifier_jingtong_cheat:IsPurgable()
	return false
end

function modifier_jingtong_cheat:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
  }
end

function modifier_jingtong_cheat:GetPriority()
  return MODIFIER_PRIORITY_ULTRA
end

function modifier_jingtong_cheat:GetModifierPercentageCooldown()
  return 100
end