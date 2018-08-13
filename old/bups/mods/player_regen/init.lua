local timer = 0
REGEN_CONST=5
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= REGEN_CONST then
		for _,player in pairs(minetest.get_connected_players()) do
			player:set_hp(math.min(player:get_hp()+(player:get_attribute("regen") or 1),(player:get_attribute("maxhp") or 20)))
		end
		timer=0
	end
end)