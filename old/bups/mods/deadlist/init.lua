--Minetest Mod deadlist by LMD : 
-- -displays kill history
-- -includes elo system
KILL_KILLERS={}
KILL_VICTIMS={}
KILL_ITEMS={}

msg_amount_max=10
RATIO=640/480

minetest.register_entity("deadlist:mover",{
    hp_max = 1,
    physical = false,
    weight = 0,
    timer=0,
    on_step=function(self,dtime)
        self.timer=self.timer+dtime
        if (self.timer > 1) then
            self.object:remove()
        end
    end,
    collisionbox = {0,0,0,0,0,0},
    visual = "sprite",
    visual_size = {x=0, y=0,z=0},
    textures = {},
    colors = {},
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false
})

--Modifies a file : changes vars given in table
function modify_file(guy,prop,change,functions)
    local load=io.open(minetest.get_worldpath().."/"..guy.."_"..prop..".json","r")
    local content={}
    if load then
       content=minetest.parse_json(load:read("*a"))
       load:close()
    end
    for key,val in pairs(change) do
        if (content[key]) then
            if (functions) then
                content[key]=val(content[key])
            else
                content[key]=content[key]+val
            end
        else
            content[key]=val
        end
    end
    local write=minetest.write_json(content)
    local file=io.open(minetest.get_worldpath().."/"..guy.."_"..prop..".json","w")
    file:write(write)
    file:close()
end

--Gets a file
function obtain_file(guy,prop)
    local load=io.open(minetest.get_worldpath().."/"..guy.."_"..prop..".json","r")
    local retval= (not load and nil) or minetest.parse_json(load:read("*a"))
    if load then
        load:close()
    end
    return retval
end

function add_kill_message(killer, item, victim)
    local victim_elo=obtain_file(victim,"stats").elo
    local killer_elo=obtain_file(killer,"stats").elo
    local diff=math.pow(math.max(0,victim_elo/(victim_elo-killer_elo)),4)
    modify_file(killer:get_player_name(),"stats",{k=1,elo=1+diff})
    modify_file(victim:get_player_name(),"stats",{elo=-diff})
    --modify_file(victim:get_player_name(),"stats",{d=1}) Not relevant - on_dieplayer does this
	local n1=get_color_int(killer:get_attribute("team"))
	local n2=get_color_int(victim:get_attribute("team"))
    add_kill_msg(killer:get_player_name(),KILL_KILLERS,{hud_elem_type="text",position={x=0.75,y=1},scale={x=100,y=100}, number=n1, alignment = {x=-1,y=0}},-20)
    add_kill_msg(victim:get_player_name(),KILL_VICTIMS,{hud_elem_type="text",position={x=0.75,y=1},number=n2,alignment = {x=1,y=0}},20)
    add_kill_msg(item["inventory_image"] or "wieldhand.png", KILL_ITEMS,{hud_elem_type="image",position={x=0.75,y=1},scale={x=-2,y=-2*RATIO}, alignment = {x=0,y=0}},0)
end
function add_kill_msg(msg, t, def, xw)
	for _,carrier in pairs(minetest.get_connected_players()) do
  	  local yw=-122
		local te=t[carrier:get_player_name()]
		local i=0
		while (true) do
 	      i=i+1
 	      if not t[carrier:get_player_name()] then
	       	te={}
 	      	   break
		   end
	       if not t[carrier:get_player_name()][i] then
	       	   break
	       end
		end
		if (i > msg_amount_max) then
			i=msg_amount_max+1
			local to_add={}
			carrier:hud_remove(te[1])
			for j=2,i do
				if te[j] then
					if carrier:hud_get(te[j]) then
				       to_add[j]=carrier:hud_get(te[j])["text"]
				    end
				    carrier:hud_remove(te[j])
			    end
			end
            t[carrier:get_player_name()]=nil
			for _,text in pairs(to_add) do
                add_kill_msg(text,t,def,x)
			end
            i=i-1
		end
		yw=yw-i*20
		def.offset={x=xw,y=yw}
		def.text=msg
		table.insert(te,carrier:hud_add(def))
	   t[carrier:get_player_name()]=te
    end
end

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not is_friend(player, hitter) then
        local mult=vector.multiply(hitter:get_look_dir(),5)
        mult=vector.add(player:get_player_velocity(),mult)
        local emp = minetest.add_entity( player:getpos(), 'deadlist:mover' )
		obj:set_attach(emp, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		emp:setvelocity({x=mult.x, y=mult.y, z=mult.z})
       --table.insert(PUNCHBACK_REMOVE[player],{vector.multiply(hitter:get_look_dir(),5),minetest.get_us_time()})
       if (newhp == 0) then
           add_kill_message(hitter,hitter:get_inventory():get_stack("main",hitter:get_wield_index()):get_definition(),player)
       end
    end

end)

minetest.register_chatcommand("rankings",{
	description="Shows your rankings.",
	func = function(name,param)
	minetest.chat_send_player(name,"Your rankings : ".."K/D : "..obtain_file(name,"kd"))
	end,
})

minetest.register_on_dieplayer(function(player)
	modify_file(player:get_player_name(),"stats",{d=1,elo=-1})
end)