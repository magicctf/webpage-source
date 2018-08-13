ITEMS={}
ITEMS["default:dirt"]={0.3,5,10}
--ITEMS["default:sword_diamond"]=0.1
--ITEMS["default:sword_mese"]=0.2
--ITEMS["default:sword_steel"]=0.5
--ITEMS["default:sword_bronze"]=0.2
minetest.register_node("treasure_spawners:treasure_spawner", {
	description = "Treasure Spawner",
	tiles = {"treasure_spawners_enchantment_top.png",  "treasure_spawners_enchantment_bottom.png",
		 "treasure_spawners_enchantment_side.png", "treasure_spawners_enchantment_side.png",
		 "treasure_spawners_enchantment_side.png", "treasure_spawners_enchantment_side.png"},
	light_source = 6,
	--on_rotate = screwdriver.rotate_simple,
	can_dig = false,
	on_blast=false,
	allow_metadata_inventory_move = function() return 0 end
})
spawn_item_chance=function(pos)
    for item, chance in pairs(ITEMS) do
        local rnd=math.random()
    	if not (rnd == 0) and (rnd < chance[1]) then
    		local amount=1
    		if not minetest.registered_tools[item] then
    			amount=chance[2]+math.ceil(rnd/chance[1]*(chance[3]-chance[2]))
    		end
    		for i=1,amount do
                 minetest.spawn_item({x=pos.x,y=pos.y+1, z=pos.z},item)
            end
            minetest.add_particlespawner( {amount = 50,time = 3,
	        minvel = {x=-0.5, y=0.1, z=-0.5},
	        maxvel = {x=0.5, y=0.5, z=0.5},
			minacc = {x=-0.05, y=0.1, z=-0.05},
			maxacc = {x=0.05, y=0.05, z=0.05},
			minexptime = 2,
			maxexptime = 6,
			minsize = 0.2,
			maxsize = 1,
			collisiondetection = false,
			vertical = false,texture="treasure_spawners_particle_green.png",minpos=pos,maxpos=pos})
        end
    end
end

minetest.register_abm({
	name = "treasure_spawners:spawn_treasure",
	nodenames = {"treasure_spawners:treasure_spawner"},
    interval = 1,
    chanche = 1,
    catch_up=true,
	action = function(pos)
    spawn_item_chance(pos)
    end,
})