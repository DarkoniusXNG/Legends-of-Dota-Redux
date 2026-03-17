bash_reflect=class({})
bash_reflect_op = class({})
modifier_bash_reflect = class({})
LinkLuaModifier("modifier_bash_reflect","abilities/bash_reflect.lua",LUA_MODIFIER_MOTION_NONE)

function bash_reflect:CastFilterResultTarget(target)
  if self:GetCaster() == target then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end
function bash_reflect:GetCustomCastErrorTarget(target)
  if self:GetCaster() == target then
    return "#cant_target_self"
  end
end
function bash_reflect_op:CastFilterResultTarget(target)
  if self:GetCaster() == target then
     return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end
function bash_reflect_op:GetCustomCastErrorTarget(target)
  if self:GetCaster() == target then
    return "#cant_target_self"
  end
end
function bash_reflect:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_bash_reflect")
  self:GetCursorTarget():AddNewModifier(self:GetCaster(),self,"modifier_bash_reflect",{duration = self:GetSpecialValueFor("duration")})
  self:GetCursorTarget():EmitSound("DOTA_Item.LinkensSphere.Target")
end

function bash_reflect_op:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_bash_reflect")
  self:GetCursorTarget():AddNewModifier(self:GetCaster(),self,"modifier_bash_reflect",{duration = self:GetSpecialValueFor("duration")})
  self:GetCursorTarget():EmitSound("DOTA_Item.LinkensSphere.Target")
end

function bash_reflect:GetIntrinsicModifierName()
  return "modifier_bash_reflect"
end
function bash_reflect_op:GetIntrinsicModifierName()
  return "modifier_bash_reflect"
end

---------------------------------------------------------------------------------------------------

function modifier_bash_reflect:IsPurgable()
  return self:GetParent() ~= self:GetCaster()
end
function modifier_bash_reflect:IsHidden()
  return false
end

function modifier_bash_reflect:OnRemoved()
  if IsServer() then
    if self:GetParent() ~= self:GetCaster() then
      self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_bash_reflect",{})
    end
  end
end

function modifier_bash_reflect:GetEffectName()
  if self:GetParent() ~= self:GetCaster() then
    return "particles/bash_reflect_shield.vpcf"
  end
end
function modifier_bash_reflect:GetEffectAttachType()
  if self:GetParent() ~= self:GetCaster() then
    return PATTACH_ABSORIGIN_FOLLOW
  end
end

---------------------------------------------------------------------------------------------------

function ReflectBashes(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  local modifierName = filterTable["name_const"]
  local modifierDuration = filterTable["duration"]
  if parent:IsIllusion() then return end
  if modifierDuration <= 0 then return end
  local anti_stun_mod = parent:FindModifierByName("modifier_bash_reflect")
  if not anti_stun_mod or anti_stun_mod:IsNull() then return end
  if caster:GetTeamNumber() == parent:GetTeamNumber() then return end
  if ability:GetAbilityName() == "bash_reflect_op" or ability:GetAbilityName() == "bash_reflect" then return end
  if anti_stun_mod:GetCaster() == parent and parent:PassivesDisabled() then return end

  Timers:CreateTimer(function ()
    if not parent or parent:IsNull() then return end
    local anti_stun_mod = parent:FindModifierByName("modifier_bash_reflect")
    if not anti_stun_mod or anti_stun_mod:IsNull() then return end
    local modifier = parent:FindModifierByName(modifierName)
    if not modifier or modifier:IsNull() then return end
    if not modifier:IsStunDebuff() then return end
    local anti_stun_ab = anti_stun_mod:GetAbility()
    if not anti_stun_ab or anti_stun_ab:IsNull() then return end
    local duration_mult = anti_stun_ab:GetSpecialValueFor("duration_multiplier")
    if not caster or caster:IsNull() then return end
    caster:AddNewModifier(parent, anti_stun_ab, modifierName, {duration = modifierDuration * duration_mult / 100})
    parent:EmitSound("Hero_Tiny.CraggyExterior.Stun")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_hit.vpcf",PATTACH_POINT_FOLLOW,parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
  end)
end





