if eat_tree_eldri == nil then
	eat_tree_eldri = class({})
end
LinkLuaModifier("eat_tree_eldri_mod", "abilities/overflow/eat_tree_eldri/modifier.lua", LUA_MODIFIER_MOTION_NONE)

function eat_tree_eldri:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function eat_tree_eldri:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local location
	if not target or target:IsNull() then
		location = self:GetCursorPosition()
	else
		location = target:GetAbsOrigin()
	end
	local treeMod = caster:FindModifierByName("eat_tree_eldri_mod")
	if treeMod then
		local stacks = treeMod:GetStackCount()
		local cost = stacks * self:GetSpecialValueFor("mana_cost_per_stack")
		local caster_mana = caster:GetMana()
		if caster_mana < cost then
			return
		end
		caster:SpendMana(cost, self)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, caster, cost, nil)
	end

	local tree = GridNav:GetAllTreesAroundPoint(location, 1, true)[1]
	if tree then
		tree:CutDown(caster:GetTeamNumber())
	end

	EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Omniknight.GuardianAngel", caster)
	caster:AddNewModifier(caster, self, "eat_tree_eldri_mod", {duration = self:GetSpecialValueFor("duration") , stack = 1})
	caster:CalculateStatBonus(true)
end
