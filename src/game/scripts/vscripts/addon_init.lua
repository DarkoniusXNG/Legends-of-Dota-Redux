-- Link modifiers that don't have an ability
require("linker")

require("baseability_extend")
require("basenpc_extend")

function IsMonkeyKingCloneCustom(entity)
	if entity.HasModifier == nil then
		return true
	end

	local monkey_king_soldier_modifiers = {
		"modifier_monkey_king_fur_army_soldier_hidden",
		"modifier_monkey_king_fur_army_soldier",
		"modifier_monkey_king_fur_army_thinker",
		"modifier_monkey_king_fur_army_soldier_inactive",
		"modifier_monkey_king_fur_army_soldier_in_position",
	}

	for _, v in pairs(monkey_king_soldier_modifiers) do
		if entity:HasModifier(v) then
			return true
		end
	end

	return false
end
