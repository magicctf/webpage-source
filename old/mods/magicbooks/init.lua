--Declare global vars
reds=0
blues=0
messages={}
STARTITEMS={"default:sword_diamond"}
LUCKITEMS={}
LUCKITEMS["default:dirt"]={0.3,0.4,5,10}
INITIAL_STUFF={"default:stone_sword"}
book_carrier_blue=nil
book_carrier_red=nil
table_red_pos={x=0,y=100,z=0}
table_blue_pos={x=0,y=100,z=0}
blue_msgs={}
red_msgs={}
HINTS={"Bring the enemy flag home successfully by always knowing how to get back fast.","Make sure to weaken the enemies enough before attempting to steal their flag.",
"You have to support your teammates. Nobody can win without support.","Never ever kill teammates.","Use firearms to kill enemies from far away.",
"Shield skill makes you resistant to magic.","Magic ignores walls and physical armor.","Poison inflicts anybody who comes close to a poisoned person.",
"Big parasites kill instantly. Use traps to kill them.","Manadrain stave works well to weaken an enemy before killing it.","Spawners supply you with the items needed.",
"At the start of a game, loot the treasure chests.","Teamwork is essential;magic skills go well together, for example, heal and shield.",
"The more allies you are able to reach with your heal spell, the more it heals yourself."}
local timer = 0

minetest.register_node("magicbooks:magic_air",{drawtype="airlike",sunlight_propagates=true,pointable=false})

local c_air = minetest.get_content_id("magicbooks:magic_air")

minetest.register_chatcommand("rtp",{
	description="Marks a map as ready-to-play. Syntax : rtp <author> <title>.",
	func = function(name,param)
		local p={}
		for _,player in pairs(minetest.get_connected_players()) do
			if (player:get_player_name() == name) then
				p=player
				break
			end
		end
		local d=vector.divide(p:getpos(),{x=80,y=80,z=160})
		d.x=math.floor(d.x+0.5)
		d.y=math.floor(d.y+0.5)
		d.z=math.floor(d.z+0.5)
		minetest.chat_send_all("A new map was just created at "..minetest.pos_to_string(d))
	end,
})

minetest.register_on_generated(function(minp, maxp)
	-- Do nothing if the area is above 30
	--minetest.chat_send_all(minetest.pos_to_string(minp))
	if minp.y > 30 then
		return
	end
	local sides={true,true,true,true,true,true}
	if (minp.z / 16) % 2 == 0 then
		sides[3]=false
		--sides[4]=false
	else
		sides[4]=false
	end
	-- Get the vmanip mapgen object and the nodes and VoxelArea
	local vm, emin, emax = minetest.get_mapgen_object"voxelmanip"
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
 
	-- Replace air with cobble
	if (sides[1]) then
		for i in area:iter(
			minp.x, minp.y, minp.z,
			maxp.x, minp.y, maxp.z
		) do
			data[i] = c_air
		end
	end

	if (sides[2]) then
		for i in area:iter(
			minp.x, maxp.y, minp.z,
			maxp.x, maxp.y, maxp.z
		) do
			data[i] = c_air
		end
	end

	if (sides[3]) then
		for i in area:iter(
			minp.x, minp.y, minp.z,
			maxp.x, maxp.y, minp.z
		) do
			data[i] = c_air
		end
	end

	if sides[4] then
		for i in area:iter(
			minp.x, minp.y, maxp.z,
			maxp.x, maxp.y, maxp.z
		) do
			data[i] = c_air
		end
	end

	if sides[5] then
		for i in area:iter(
			minp.x, minp.y, minp.z,
			minp.x, maxp.y, maxp.z
		) do
			data[i] = c_air
		end
	end

	if sides[6] then
		for i in area:iter(
			maxp.x, minp.y, minp.z,
			maxp.x, maxp.y, maxp.z
		) do
			data[i] = c_air
		end
	end
 
	-- Return the changed nodes data, fix light and change map
	vm:set_data(data)
	vm:set_lighting{day=0, night=0}
	vm:calc_lighting()
	vm:write_to_map()
end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 30 then
		local i=1+math.floor(math.random() * (#HINTS-1)+0.5)
		minetest.chat_send_all(HINTS[i])
		timer=0
	end
end)
minetest.register_on_newplayer(function(player)
	--Disable moving
	minetest.chat_send_player(player:get_player_name(), "Welcome to Magic-CTF, "..player:get_player_name().." !")
	minetest.show_formspec(player:get_player_name(), "magicbooks:show_rules", "size[8,6;]\nbutton[4,5;4,1;decline;I decline]\nbutton_exit[0,5;4,1;procedd;I agree]\ntextlist[0,0;8,5;Rules;Rules,1. Don't hurt teammates,2. Don't insult anybody])")
end)
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "magicbooks:show_rules" and fields["procedd"] then
		minetest.show_formspec(player:get_player_name(), "magicbooks:show_rules", "size[8,6;]\nbutton[4,5;4,1;decline;I decline]\nbutton_exit[0,5;4,1;procedd;I agree]\ntextlist[0,0;8,5;Rules;Rules,1. Don't hurt teammates,2. Don't insult anybody])")
		minetest.chat_send_all("Congratulations "..player:get_player_name()..", you agreed to the rules and are now ready to play !")
	end
end)
function give_initial(player)
	for _,item in pairs(INITIAL_STUFF) do
		player:get_inventory():add_item("main",item)
	end
end
function initial(player)
	give_initial(player)
	if (player:get_attribute("team") == "red") then
		player:setpos(table_red_pos)
	else
		player:setpos(table_blue_pos)
	end
end

-- On join / respawn / leave /die

minetest.register_on_dieplayer(function (player)
    on_die(player)
end)

minetest.register_on_respawnplayer(function(player)
	initial(player)
    return true
end)

minetest.register_on_joinplayer(function (player) --On joinplayer
	--player:set_attribute("is_pro","true")
	if reds < blues then
        player:set_attribute("team","red")
        reds=reds+1
    else 
        player:set_attribute("team","blue")
        blues=blues+1
    end
	minetest.after(0, function()
		initial(player)
    player_show_both(player)
    end)
    minetest.chat_send_all(player:get_player_name().." has joined team "..get_color(player:get_attribute("team"))..player:get_attribute("team")..rcol().." !")
    minetest.after(0, function()
    player:set_properties({
		textures = {"magicbooks_sam_"..player:get_attribute("team")..".png"},
    })
    end)
end)

minetest.register_on_leaveplayer(function (player)

    if player:get_attribute("team") == "red" then
        reds=reds-1
    else
        blues=blues-1
    end
    on_die(player)
    minetest.chat_send_all(player:get_player_name().." has left team "..get_color(player:get_attribute("team"))..player:get_attribute("team")..rcol()..".")
end)



function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function show_msg(carrier, msg, color)
	local yw=-122
	local tablee=messages[carrier:get_player_name()]
	if tablee then
		yw=yw-20
	else 
		tablee={}
	end
	table.insert(tablee,carrier:hud_add({
    hud_elem_type = "text",
    position = {x=0.5,y=1},
    size = "",
    text = msg,
    number = color,
    alignment = {x=1,y=0},
    offset = {x=0-(string.len(msg)*7)/2, y=yw},
}))
	messages[carrier:get_player_name()]=tablee
end
function unshow_msg_player(carrier)
    for i,id in pairs(messages[carrier:get_player_name()]) do
    	carrier:hud_remove(id)
    	messages[carrier:get_player_name()][i]=nil
    	if tablelength(messages[carrier:get_player_name()]) == 0 then
    		messages[carrier:get_player_name()]=nil
    	end
    end
end
function unshow_msg(carrier, msg)
	if not messages[carrier:get_player_name()] then
        return 0
	end
	for i,id in pairs(messages[carrier:get_player_name()]) do
		if carrier:hud_get(id).text == msg then
    	   carrier:hud_remove(id)
    	   messages[carrier:get_player_name()][i]=nil
    	   if tablelength(messages[carrier:get_player_name()]) == 0 then
    		  messages[carrier:get_player_name()]=nil
    	   end
        end
    end
end
function unshow_msg_everybody_all()
	for i, player in pairs(minetest.get_connected_players()) do
         unshow_msg_player(player)
	end
end
function unshow_msg_everybody(msg)
	for i, player in pairs(minetest.get_connected_players()) do
         unshow_msg(player, msg)
	end
end
function show_carrier_msg(carrier) 
	show_msg(carrier,"You've got their magic book ! Run home and punch yours !",0x00FF00)
end
function show_protect_msg(team, snitcher) 
    for i,player in pairs(minetest.get_connected_players()) do
        if player:get_attribute("team") == team and not player:get_player_name() == snitcher then
            show_msg(player, snitcher.." has stolen the enemy magic book ! Protect him on his way home !",0x0000FF)
        end
    end
end
function show_kill_msg(team) 
    for i,player in pairs(minetest.get_connected_players()) do
        if player:get_attribute("team") == team then
        	local snitcher=book_carrier_blue
        	if team == "blue" then
        		snitcher=book_carrier_red
            end
            show_msg(player, snitcher:get_player_name().." has stolen your magic book ! Kill him before he returns home !",0xFF0000)
        end
    end
end
function show_both(snitchteam, snitcher) --Show messages for all players
	show_carrier_msg(snitcher)
    show_protect_msg(snitchteam, snitcher)
    local st="red"
    if (snitchteam == "red") then
    	st="blue"
    end
    show_kill_msg(st)
end
function player_show_both(player) --Show messages for a new player
	if player:get_attribute("team") == "blue" then --Is he Blue ?
        if book_carrier_blue then --protect
            show_msg(player, book_carrier_blue:get_player_name().." has stolen the enemy magic book ! Protect him on his way home !",0x0000FF)
        elseif book_carrier_red then --kill
            show_msg(player, book_carrier_red:get_player_name().." has stolen your magic book ! Kill him before he returns home !",0xFF0000)
        end
    else --Nope, red
	    if book_carrier_red then --protect
           show_msg(player, book_carrier_red:get_player_name().." has stolen the enemy magic book ! Protect him on his way home !",0x0000FF)
        elseif book_carrier_blue then --kill
           show_msg(player, book_carrier_blue:get_player_name().." has stolen your magic book ! Kill him before he returns home !",0xFF0000)
        end
    end

end
function carrier_died(team, carrier)
	unshow_msg(carrier,"You've got their magic book ! Run home and punch yours !")
	for i,player in pairs(minetest.get_connected_players()) do
        if player:get_attribute("team") == team then
           unshow_msg(player,carrier:get_player_name().." has stolen the enemy magic book ! Protect him on his way home !")
        else
           unshow_msg(player,carrier:get_player_name().." has stolen your magic book ! Kill him before he returns home !")
        end
    end
end
function show_chest_fs(player,chest,pos)
    if player:get_attribute("team") == chest then
    	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    	local proinv="\nlist[nodemeta:"..spos..";main;3,0;3,4;12]"
    	if player:get_attribute("is_pro") then
    		proinv="\nlist[nodemeta:"..spos..";main;6,0;2,4;48]"
    	end
        local chest_fs="size[8,9;]\nimage[2.9,-0.1;3.7,4.65;magicbooks_nonpro_bg.png]\nimage[5.9,-0.1;2.5,4.65;magicbooks_pro_bg.png]\nlabel[6,4;High elo]\nlabel[3,4;Low elo]]\nlabel[0,4;Shared]\nlist[nodemeta:"..spos..";main;0,0;3,4;]"..proinv.."\nlist[current_player;main;0,5;8,4;]"
        minetest.show_formspec(player:get_player_name(), "magicbooks:team_table_"..chest, chest_fs)
    end
end
function on_book_construct(pos)
	fill_treasure_chest(pos,STARTITEMS)
    fill_rnd_chest(pos,6, LUCKITEMS)
end
function register_magicbook(name, d)
	def=table.copy(d)
	def.allow_metadata_inventory_move = function() return 9999 end
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			prefix="Blue "
			if string.find(name,"red") then
                prefix="Red "
            end
			meta:set_string("infotext", prefix.."Magic Table")
			local inv = meta:get_inventory()
			inv:set_size("main", 8*4)
			on_book_construct(pos)
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

	def.mesh = nil
	def.drawtype = nil
	def.on_blast=function() return 0 end

	minetest.register_node(name, def)
end
register_magicbook("magicbooks:magic_table_withbook_red", {
	description = "Magic Table with book",
	tiles = {"magicbooks_enchantment_top_book_red.png",  "magicbooks_enchantment_bottom.png",
		 "magicbooks_enchantment_side_red.png", "magicbooks_enchantment_side_red.png",
		 "magicbooks_enchantment_side_red.png", "magicbooks_enchantment_side_red.png"},
	groups = {cracky=1, level=1},
	light_source = 6,
on_punch = function(pos, node, player, pointed_thing)
        if (player == book_carrier_red) then
        	book_carrier_red=nil
        	minetest.chat_send_all(player:get_player_name().." brought home the blue magic book successfully and the fraction of reds won the game !")
        	unshow_msg_everybody_all()
        	minetest.swap_node(table_blue_pos, {name = "magicbooks:magic_table_withbook_blue"})
        end
        if (player:get_attribute("team") == "blue") then
        	minetest.chat_send_all("The red magic book has been stolen by "..player:get_player_name().." !")
        book_carrier_blue=player
        table_red_pos=pos
        show_both("blue",player)
        minetest.swap_node(pos, {name = "magicbooks:magic_table_nobook_red"})
        end

        end,
        on_dig = function() return 0 end,
        on_rightclick = function(pos, shit,player) show_chest_fs(player,"red",pos) end,
	on_rotate = screwdriver.rotate_simple,
	can_dig = false,
	allow_metadata_inventory_move = function() return 0 end
})

register_magicbook("magicbooks:magic_table_withbook_blue", {
	description = "Magic Table with book",
	tiles = {"magicbooks_enchantment_top_book_blue.png",  "magicbooks_enchantment_bottom.png",
		 "magicbooks_enchantment_side_blue.png", "magicbooks_enchantment_side_blue.png",
		 "magicbooks_enchantment_side_blue.png", "magicbooks_enchantment_side_blue.png"},
        on_punch = function(pos, node, player, pointed_thing)
        if (player == book_carrier_blue) then
        	book_carrier_blue=nil
        	minetest.chat_send_all(player:get_player_name().." brought home the red magic book successfully and the fraction of blues won the game !")
        	unshow_msg_everybody_all()
        	minetest.swap_node(table_red_pos, {name = "magicbooks:magic_table_withbook_red"})
        end
        if (player:get_attribute("team") == "red") then
        	minetest.chat_send_all("The blue magic book has been stolen by "..player:get_player_name().." !")
        book_carrier_red=player
        show_both("red",player)
        table_blue_pos=pos
        minetest.swap_node(pos, {name = "magicbooks:magic_table_nobook_blue"})
        end
        end,
	light_source = 6,
	on_rightclick = function(pos, shit,player) show_chest_fs(player,"blue",pos) end,
	on_dig = function() return 0 end,
	on_rotate = screwdriver.rotate_simple,
	can_dig = false,
	allow_metadata_inventory_move = function() return 0 end
})

minetest.register_node("magicbooks:magic_table_nobook_red", {
	description = "Magic Table",
	tiles = {"magicbooks_enchantment_top_nobook_red.png",  "magicbooks_enchantment_bottom.png",
		 "magicbooks_enchantment_side_red.png", "magicbooks_enchantment_side_red.png",
		 "magicbooks_enchantment_side_red.png", "magicbooks_enchantment_side_red.png"},
	light_source = 6,
	on_punch = function() return 0 end,
	on_dig = function() return 0 end,
	on_blast = function() return 0 end,
	on_rightclick = function(pos, shit,player) show_chest_fs(player,"red",pos) end,
	on_rotate = screwdriver.rotate_simple,
	can_dig = false,
	allow_metadata_inventory_move = function() return 0 end
})

minetest.register_node("magicbooks:magic_table_nobook_blue", {
	description = "Magic Table",
	tiles = {"magicbooks_enchantment_top_nobook_blue.png",  "magicbooks_enchantment_bottom.png",
		 "magicbooks_enchantment_side_blue.png", "magicbooks_enchantment_side_blue.png",
		 "magicbooks_enchantment_side_blue.png", "magicbooks_enchantment_side_blue.png"},
	light_source = 6,
	on_rightclick = function(pos, shit,player) show_chest_fs(player,"blue",pos) end,
	on_punch = function() return 0 end,
	on_dig = function() return 0 end,
	on_blast = function() return 0 end,
	on_rotate = screwdriver.rotate_simple,
	can_dig = false,
	allow_metadata_inventory_move = function() return 0 end
})

function on_die(player)
    if player == book_carrier_red then
    	book_carrier_red=nil
    	minetest.swap_node(table_blue_pos, {name = "magicbooks:magic_table_withbook_blue"})
    	minetest.chat_send_all("The red thief was too weak and the blue magic book managed to return !")
    	carrier_died("red",player)
    elseif player == book_carrier_blue then
    	book_carrier_blue=nil
    	minetest.swap_node(table_red_pos, {name = "magicbooks:magic_table_withbook_red"})
    	minetest.chat_send_all("The red thief was too weak and the blue magic book managed to return !")
    	carrier_died("blue",player)
    end
end

function get_color_int(team)
    if team=="red" then
    	return 0xFF0000
    elseif team=="blue" then
        return 0x0000FF
    end
    return 0xFFFFFF
end

function get_color(team)
    if team=="red" then
    	return minetest.get_color_escape_sequence("#FF0000")
    elseif team=="blue" then
        return minetest.get_color_escape_sequence("#0000FF")
    end
    return minetest.get_color_escape_sequence("#FFFFFF")
end

function rcol()
	return minetest.get_color_escape_sequence("#FFFFFF")
end

minetest.register_abm({
	name = "magicbooks:spawn_particles_blue",
	nodenames = {"magicbooks:magic_table_withbook_blue"},
        interval = 1,
        chanche = 1,
        catch_up=true,
	action = function(pos, node)
               minetest.add_particlespawner( {amount = 50,
	time = 3,
	minvel = {x=-0.5, y=0.1, z=-0.5},
	maxvel = {x=0.5, y=0.5, z=0.5},
	minacc = {x=-0.05, y=0.1, z=-0.05},
	maxacc = {x=0.05, y=0.05, z=0.05},
	minexptime = 2,
	maxexptime = 6,
	minsize = 0.2,
	maxsize = 1,
	collisiondetection = false,
	vertical = false,texture="magicbooks_particle_blue.png",minpos=pos,maxpos=pos})
	end,
})

minetest.register_abm({
	name = "magicbooks:spawn_particles_red",
	nodenames = {"magicbooks:magic_table_withbook_red"},
        interval = 1,
        chanche = 1,
        catch_up=true,
	action = function(pos, node)
	            minetest.chat_send_all(minetest.get_gametime())
                minetest.add_particlespawner( {amount = 50,
	time = 3,
	minvel = {x=-0.5, y=0.1, z=-0.5},
	maxvel = {x=0.5, y=0.5, z=0.5},
	minacc = {x=-0.05, y=0.1, z=-0.05},
	maxacc = {x=0.05, y=0.05, z=0.05},
	minexptime = 2,
	maxexptime = 6,
	minsize = 0.2,
	maxsize = 1,
	catch_up=true,
	collisiondetection = false,
	vertical = false,texture="magicbooks_particle_red.png",minpos=pos,maxpos=pos})
	end,
})

minetest.register_abm({
	name = "treasure_spawners:spawn_treasure",
	nodenames = {"magicbooks:magic_table_nobook_red","magicbooks:magic_table_nobook_blue","magicbooks:magic_table_withbook_red","magicbooks:magic_table_withbook_blue"},
    interval = 1,
    chanche = 1,
    catch_up=true,
	action = function(pos, node)
    spawn_item_chance(pos)
    end,
})

function is_friend(player, player2)
    if (player:get_attribute("team") == player2:get_attribute("team")) then
        return true
    end
    return false
end

function get_ti(playername)
	local playerteam="white"
	for _, player in pairs(minetest.get_connected_players()) do
        if player:get_player_name() == name then
            playerteam=player:get_attribute("team")
            break
        end
	end
	return get_color_int(playerteam)
end

function get_team_color(playername)
	local playerteam="white"
	for _, player in pairs(minetest.get_connected_players()) do
        if player:get_player_name() == name then
            playerteam=player:get_attribute("team")
            break
        end
	end
	return get_color(playerteam)
end

minetest.register_on_chat_message(function(name,message)
	local playerteam="red"
	for _, player in pairs(minetest.get_connected_players()) do
        if player:get_player_name() == name then
            playerteam=player:get_attribute("team")
            break
        end
	end
	local color=get_color(playerteam)
	local i,j=string.find(message, "@")
	if not (i == 1) then
		local stringify="<"..color..name..rcol().."@"..playerteam.." team> "..color..message
		if playerteam == "red" then
            table.insert(red_msgs,stringify)
		else 
            table.insert(blue_msgs,stringify)
		end
    for _, player in pairs(minetest.get_connected_players()) do
    	if player:get_attribute("team") == playerteam then
            minetest.chat_send_player(player:get_player_name(),stringify)
        end
	end
    elseif (string.sub(message,2,4) == "all") then
    	local stringify="<"..color..name..rcol().."@everybody> "..string.sub(message,5,string.len(message))
    	table.insert(blue_msgs,stringify)
    	table.insert(red_msgs,stringify)
    	minetest.chat_send_all(stringify)
    else 
    	local i2,j2=string.find(message," ")
        minetest.chat_send_player(string.sub(message, 2, i2-1),"<"..color..name..rcol().."@you> "..string.sub(message,i2+1,string.len(message)))
    end
	return true
end)

minetest.register_chatcommand("show_messages",{
	description="Shows message history.",
	func = function(name,param)
	local playerteam="red"
	for _, player in pairs(minetest.get_connected_players()) do
        if player:get_player_name() == name then
            playerteam=player:get_attribute("team")
            break
        end
	end
	local concat=""
	if playerteam=="red" then
        concat=table.concat(red_msgs,",")
    else
        concat=table.concat(blue_msgs,",")
    end
    concat=string.gsub(concat,";",":,")
	minetest.show_formspec(name, "magicbooks:show_msg_hist", "size[8,6;]\ntextlist[0,0;8,6;Message history;"..concat.."])")
	end,
})