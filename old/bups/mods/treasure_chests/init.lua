GOLDEN_ITEMS={}
GOLDEN_ITEMS["default:sword_diamond"]={0.3,0.4,1,1}
IRON_ITEMS={}
IRON_ITEMS["default:dirt"]={0.3,0.4,5,10}
WOODEN_ITEMS={}
WOODEN_ITEMS["default:dirt"]={0.3,0.4,5,10}
function register_chest(name, d, info, height)
	def=table.copy(d)
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", info)
			local inv = meta:get_inventory()
			inv:set_size("main", 8*height)
		end
		def.can_dig = function(pos,player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			return inv:is_empty("main")
		end

	def.on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name() ..
			" from chest at " .. minetest.pos_to_string(pos))
	end
	def.on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "main", drops)
		drops[#drops+1] = name
		minetest.remove_node(pos)
		return drops
	end

	minetest.register_node(name, def)
end
fill_treasure_chest=function(pos,stuff)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	for _,item in pairs(stuff) do
		inv:add_item("main", ItemStack(item))
    end
end
fill_rnd_chest=function(pos, amount, t)
	ret={}
	aim=math.ceil(math.random()*amount)+1
	val=0
    while true do
    	if val == aim then
    		break
    	end
    	local rnd=math.random()
        for item, chance in pairs(t) do
    	    if rnd > chance[1] and rnd < chance[2] then
    		local amount=1
    		if not minetest.registered_tools[item] then
    			amount=chance[3]+math.ceil((rnd-chance[1])/(chance[2]-chance[1])*(chance[4]-chance[3]))
    			table.insert(ret,item.." "..tostring(amount))
    	    else
    		    table.insert(ret,item)
    		end
            val=val+1
            end
        end
    end
    fill_treasure_chest(pos,ret)
end
function register_treasure_chest(tier,height,color, filltable)
	local lower=string.lower(tier)
	--error("treasure_chests:"..lower.."_chest")
	minetest.register_node("treasure_chests:"..lower.."_chest_spawner",{description = tier.." Treasure Chest Spawner",
	tiles = {
		"treasure_chests_"..lower.."_chest_top.png",
		"treasure_chests_"..lower.."_chest_top.png",
		"treasure_chests_"..lower.."_chest_side.png",
		"treasure_chests_"..lower.."_chest_side.png",
		"treasure_chests_"..lower.."_chest_front.png",
		"treasure_chests_"..lower.."_chest_side.png"
	}, on_construct=function(pos) minetest.set_node(pos,{name="treasure_chests:"..lower.."_chest"})
	 fill_rnd_chest(pos,4,filltable) return 0 end})
    register_chest("treasure_chests:"..lower.."_chest", {
    	on_punch=function(pos) fill_rnd_chest(pos,4,filltable) return 0 end,
    	can_dig=false,
	description = tier.." Treasure Chest",
	tiles = {
		"treasure_chests_"..lower.."_chest_top.png",
		"treasure_chests_"..lower.."_chest_top.png",
		"treasure_chests_"..lower.."_chest_side.png",
		"treasure_chests_"..lower.."_chest_side.png",
		"treasure_chests_"..lower.."_chest_front.png",
		"treasure_chests_"..lower.."_chest_side.png"
	},
	on_rightclick=function(pos,shit,player) 
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local chest_fs="size[8,"..tostring(4+height+1)..";]\nbgcolor["..color..";false]\nlist[nodemeta:"..spos..";main;0,0;8,"..tostring(height)..";]\nlist[current_player;main;0,"..tostring(height+1)..";8,4;]"
    minetest.show_formspec(player:get_player_name(), "treasure_chests:chestinv", chest_fs)
    end,
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
    },tier.." Treasure Chest",height)
end

register_treasure_chest("Wooden",1,"#663300",WOODEN_ITEMS)
register_treasure_chest("Iron",2,"#E6E7E8",IRON_ITEMS)
register_treasure_chest("Golden",4,"#FFFF00",GOLDEN_ITEMS)