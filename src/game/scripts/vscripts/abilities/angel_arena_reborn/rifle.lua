local items = {
	["item_mjollnir"] = 1,
	["item_maelstrom"] = 1,
	--["item_basher"] = 1, -- has internal cd
	--["item_abyssal_blade"] = 1, -- has internal cd
	["item_javelin"] = 1,
	["item_monkey_king_bar"] = 1,
	--["item_revenants_brooch"] = 1, -- dmg is based on attack dmg
}

function OnIntervalThinkMachine(keys)
	local caster = keys.caster

	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
		local item = caster:GetItemInSlot(i)
		if item then
			if item:GetPurchaser() == caster and items[item:GetName()] then
				item:SetLevel(0)
			end
		end
	end
end

function OnIntervalThinkRifle(keys)
	local caster = keys.caster

	local max_slot = DOTA_ITEM_SLOT_6
	if caster:HasModifier("modifier_spoons_stash_oaa") then
		max_slot = DOTA_ITEM_SLOT_9
	end
	for i = DOTA_ITEM_SLOT_1, max_slot do
		local item = caster:GetItemInSlot(i)
		if item then
			if item:GetPurchaser() == caster and items[item:GetName()] then	
				item:SetLevel(items[item:GetName()])
			end
		end
	end

end