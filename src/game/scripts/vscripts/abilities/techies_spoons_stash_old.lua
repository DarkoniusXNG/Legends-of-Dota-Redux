LinkLuaModifier("modifier_spoons_stash_oaa", "abilities/techies_spoons_stash_old.lua", LUA_MODIFIER_MOTION_NONE)

techies_spoons_stash_old = class({})

function techies_spoons_stash_old:GetIntrinsicModifierName()
	return "modifier_spoons_stash_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_spoons_stash_oaa = class({})

function modifier_spoons_stash_oaa:IsHidden()
  return true
end

function modifier_spoons_stash_oaa:IsDebuff()
  return false
end

function modifier_spoons_stash_oaa:IsPurgable()
  return false
end

function modifier_spoons_stash_oaa:RemoveOnDeath()
  return false
end

function modifier_spoons_stash_oaa:CheckState()
  return {
    [MODIFIER_STATE_CAN_USE_BACKPACK_ITEMS] = true,
  }
end
