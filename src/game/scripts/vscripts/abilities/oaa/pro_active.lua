LinkLuaModifier("modifier_pro_active_oaa", "abilities/oaa/pro_active.lua", LUA_MODIFIER_MOTION_NONE)

pro_active_oaa = class({})

function pro_active_oaa:GetIntrinsicModifierName()
	return "modifier_pro_active_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_pro_active_oaa = class({})

function modifier_pro_active_oaa:IsHidden()
  return true
end

function modifier_pro_active_oaa:IsDebuff()
  return false
end

function modifier_pro_active_oaa:IsPurgable()
  return false
end

function modifier_pro_active_oaa:RemoveOnDeath()
  return false
end

function modifier_pro_active_oaa:OnCreated()
  self.ignore_abilities = {
    abaddon_borrowed_time = true,                           -- invulnerability
    beastmaster_summon_razorback = true,                    -- lag
    beastmaster_summon_raptor = true,                       -- lag
    brewmaster_primal_split = true,                         -- invulnerability
    dark_willow_shadow_realm = true,                        -- untargettable
    dazzle_shallow_grave = true,                            -- invulnerability
    earth_spirit_petrify = true,                            -- invulnerability
    earth_spirit_rolling_boulder = true,                    -- invulnerability
    ember_spirit_sleight_of_fist = true,                    -- invulnerability
    enigma_demonic_conversion = true,                       -- lag
    faceless_void_time_walk = true,                         -- invulnerability
    juggernaut_swift_slash = true,                          -- invulnerability
    meepo_petrify = true,                                   -- invulnerability
    morphling_waveform = true,                              -- invulnerability
    obsidian_destroyer_astral_imprisonment = true,          -- invulnerability, banish
    oracle_false_promise = true,                            -- invulnerability
    phantom_lancer_doppelwalk = true,                       -- lag
    puck_phase_shift = true,                                -- invulnerability
    riki_tricks_of_the_trade = true,                        -- invulnerability
    shadow_demon_disruption = true,                         -- invulnerability, banish
    skeleton_king_reincarnation = true,                     -- near unkillable
    slark_depth_shroud = true,                              -- untargettable
    slark_shadow_dance = true,                              -- untargettable
    sohei_flurry_of_blows = true,                           -- invulnerability
    terrorblade_conjure_image = true,                       -- lag
    terrorblade_sunder = true,                              -- near unkillable
    tusk_snowball = true,                                   -- invulnerability
    ursa_enrage = true,                                     -- near unkillable
    venomancer_plague_ward = true,                          -- lag
    visage_gravekeepers_cloak = true,                       -- invulnerability
    void_spirit_dissimilate = true,                         -- invulnerability
    witch_doctor_voodoo_switcheroo = true,                  -- invulnerability
  }

  self.cdr_penalty = 10
  self.cdr = 50
end

function modifier_pro_active_oaa:CheckState()
  return {
    [MODIFIER_STATE_PASSIVES_DISABLED] = not self:GetParent():IsDebuffImmune(),
  }
end

function modifier_pro_active_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
  }
end

function modifier_pro_active_oaa:GetModifierPercentageCooldown(keys)
  local ability = keys.ability
  if ability and not ability:IsNull() then
	if self.ignore_abilities[ability:GetName()] or ability:IsItem() then
      return self.cdr_penalty
	end
  end
  return self.cdr
end

--function modifier_pro_active_oaa:GetTexture()
  --return "dazzle_bad_juju"
--end
