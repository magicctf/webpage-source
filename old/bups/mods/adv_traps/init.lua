CRAFT_AMOUNT=" 10"
function register_spikes(craftitem, rank, damage, groupst)
	local name="adv_traps:"..string.lower(rank).."_spikes"
	local img="adv_traps_"..string.lower(rank).."_spikes.png"
    minetest.register_node(name,{
    	drawtype="plantlike",
    	walkable=false,
    	tiles={img},
    	sunlight_propagates=true,
    	description=rank.." Spikes",
    	damage_per_second=damage,
    	inventory_image=img,
    	wallmounted=true,
    	buildable_to=false,
    	groups=groupst
    	})
        minetest.register_craft({
	output = name..CRAFT_AMOUNT,
	recipe = {
		{"", "", ""},
		{craftitem, craftitem, craftitem},
		{craftitem, craftitem, craftitem}
	}
})
end

minetest.register_abm({
	label = "adv_traps:drain_mana",
	nodenames = {"adv_traps:manadrainer"},
    interval = 1,
    chanche = 1,
    catch_up=true,
	action = function(pos, node)
		local meta=minetest.get_meta(pos)
		local team=meta:get_string("team")
		for _,player in pairs(minetest.get_connected_players()) do
			if (vector.length(vector.subtract(pos,player:getpos())) < 10) then
				if (player:get_attribute("team") == team) then
					mana.subtract(player:get_player_name(), 10)
				end
			end
		end
    end,
})

minetest.register_abm({
	label = "adv_traps:drain_hp",
	nodenames = {"adv_traps:hpdrainer"},
    interval = 1,
    chanche = 1,
    catch_up=true,
	action = function(pos, node)
		local meta=minetest.get_meta(pos)
		local team=meta:get_string("team")
		for _,player in pairs(minetest.get_connected_players()) do
			if (vector.length(vector.subtract(pos,player:getpos())) < 10) then
				if (player:get_attribute("team") == team) then
					player:set_hp(math.max(0,player:get_hp()-5))
				end
			end
		end
    end,
})


minetest.register_node("adv_traps:manadrainer",{
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local prefix="Blue"
		if placer:get_attribute("team") == "red" then
			prefix="Red"
		end
		meta:set_string("infotext", prefix.." Manadrainer")
		meta:set_string("team",string.lower(prefix))
	end,
	tiles={"adv_traps_manadrainer.png"},
	description="Manadrainer",
	groups={cracky=3}
})

minetest.register_node("adv_traps:hpdrainer",{
	drawtype="mesh",
	mesh="parasiteegg.obj",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local prefix="Blue"
		if placer:get_attribute("team") == "red" then
			prefix="Red"
		end
		meta:set_string("infotext", prefix.." HP-Drainer")
		meta:set_string("team",string.lower(prefix))
	end,
	tiles={"adv_traps_hpdrainer.png"},
	description="HP-Drainer",
	groups={cracky=3}
})

register_spikes("group:wood","Wooden",1,{choppy=1,oddly_breakable_by_hand=1})
register_spikes("default:cobblestone","Stone",2,{cracky=1})
register_spikes("default:iron_ingot","Iron",4,{cracky=2})
register_spikes("default:bronze_ingot","Bronze",5,{cracky=3})
register_spikes("default:mese","Mese",7,{cracky=3})
register_spikes("default:diamond","Diamond",9,{cracky=3})