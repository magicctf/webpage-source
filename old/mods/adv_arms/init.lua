--[[ACTIVE_BULLETS={}
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.5 then
		local lenval=0
		for i=#ACTIVE_BULLETS,1,-1 do ertzuioyxcvbnm,.jklöfgfgfghjklö567
			bullet=ACTIVE_BULLETS[i]
			 lenval=lenval+1
			 local move=vector.multiply(bullet["velocity"],{x=timer,y=timer,z=timer})
             local newpos=vector.add(bullet["pos"],move)
             local steps=math.ceil(vector.length(move)*3)
             local step=vector.multiply(vector.normalize(move),{x=1/3,y=1/3,z=1/3})
             local actpos=bullet["pos"]
             for i=0,steps do
                 actpos=vector.add(actpos,step)
                 local name=minetest.get_node({x=math.ceil(actpos.x-0.5),y=math.ceil(actpos.y-0.5),z=math.ceil(actpos.z-0.5)})["name"]
                 if not (name == "air") then
                 	table.remove(ACTIVE_BULLETS,i)
                 	minetest.chat_send_all("Remove Bullet")
                    --minetest.chat_send_all(minetest.get_node({x=math.ceil(actpos.x-0.5),y=math.ceil(actpos.y-0.5),z=math.ceil(actpos.z-0.5)})["name"])
                 end
             end
		end
		minetest.chat_send_all(tostring(lenval))
		timer = 0
	end
end)]]
RELOADING_PLAYERS={}
REGISTERED_BULLETS={}
REGISTERED_WEAPONS={}
ARROW_CRAFT_AMOUNT=16
STEPS=4
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.5 then
		for player, weapon in pairs(RELOADING_PLAYERS) do
			local stack=player:get_inventory():get_stack("main", player:get_wield_index())
            if stack:get_name()==weapon then
                stack:set_wear(math.max(0,stack:get_wear()-stack:get_definition()["reload_factor"]))
                if (stack:get_wear() == 0) then
                	RELOADING_PLAYERS[player]=nil
                end
                player:get_inventory():set_stack("main",player:get_wield_index(),stack)
            else
            	--stack:set_wear(65533)
            	--player:get_inventory():set_stack("main",player:get_wield_index(),stack)
            	--[[if (player:get_inventory():room_for_item("main",weapon[2])) then
            	    player:get_inventory():add_item("main",weapon[2])
                else
                    minetest.spawn_item(player:getpos(),weapon[2])
                end]]
            	RELOADING_PLAYERS[player]=nil
            end
		end
	end
end)
function collidepoint(rect, point)
	if (rect.x > point.x or rect.y > point.y or rect.x+rect.w < point.x or rect.y+rect.h < point.y) then
		return false
	end
	return true
end
function pointingat(cube, camera, offset)
    local b = false
    local surface = {x=cube.pos.x, y=cube.pos.z, w=cube.dim.x, h=cube.dim.z}
    local side = {x=cube.pos.x, y=cube.pos.y, w=cube.dim.x, h=cube.dim.y}
    local front = {x=cube.pos.y, y=cube.pos.z, w=cube.dim.y, h=cube.dim.z}
    local side_z = cube.pos.z-camera.position.z+offset*cube.dim.z
    local side_point = vector.add(vector.multiply({x=side_z,y=side_z,z=0},camera.friction_z),{x=camera.position.x, y=camera.position.y, z=0})
    local surface_y = cube.pos.y-camera.position.y+offset*cube.dim.y
    local surface_point = vector.add(vector.multiply({x=surface_y,y=surface_y,z=0},camera.friction_y),{x=camera.position.x, y=camera.position.z, z=0})
    local front_x = cube.pos.x-camera.position.x+offset*cube.dim.x
    local front_point = vector.add(vector.multiply({x=front_x,y=front_x,z=0},camera.friction_x),{x=camera.position.y, y=camera.position.z, z=0})
    if (collidepoint(surface,surface_point)) then
    	return vector.subtract({x=surface_point.x,y=cube.pos.y+offset*cube.dim.y,z=surface_point.y},camera.position)
	end
	if (collidepoint(side,side_point)) then
		return vector.subtract({x=side_point.x,y=side_point.y,z=cube.pos.z+offset*cube.dim.z},camera.position)
	end
	if (collidepoint(front,front_point)) then
		return vector.subtract({x=cube.pos.x+offset*cube.dim.x,y=front_point.x,z=front_point.y},camera.position)
	end
end
function pointing_at(cube, camera)
    for o=0.5,-0.5,1 do
		local pa = pointingat(cube,camera,o)
		if pa then
        	return pa
        end
    end
end
local factor=1000;
function register_bullet(name,size,dmg, weight, color, lifetime)
minetest.register_entity("adv_arms:"..name,{
    hp_max = 1,
    physical = true,
    weight = weight,
    immortal=1,
    lt=lifetime,
    selectionbox = {0,0,0,0,0,0},
    collisionbox = {-size,-size,-size, size,size,size},
    visual = "cube",
    damage=dmg,
    visual_size = {x=size*2, y=size*2, z=size*2},
    textures = {"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color}, -- number of required textures depends on visual
    is_visible = true,
    on_activate=function (self,shit)
        self["origin"]={x=self.object:getpos().x,y=self.object:getpos().y,z=self.object:getpos().z}
        self["timer"]=0
        self.object:setacceleration({x=0,y=-weight,z=0})
    end,
    on_step=function(self,dtime)
        if not self.vl then
        	self.object:remove()
        	return
        end
        self["timer"]=self["timer"]+dtime
        if (self["timer"] > lifetime) then
        	self.object:remove()
        	return
        end
        local v2=vector.length(self.object:getvelocity())
        if not (math.floor(v2*factor+0.5)/factor==math.floor(vector.length(vector.add(self["vl"],vector.multiply(self.object:getacceleration(),self["timer"])))*factor+0.5)/factor) then
	        self.object:remove()
	    end
        --[[local v=vector.divide(vector.subtract(self["origin"],self.object:getpos()),vector.multiply(vector.add(self.object:getvelocity(),0.00000001),{x=1,y=1,z=1}))
        --local v2=vector.length(vector.divide(vector.subtract(self["origin"],self.object:getpos()),vector.multiply(self.object:getvelocity(),self["timer"])))
        --minetest.chat_send_all(minetest.write_json(v))
        local floor={x=math.floor(v.x*factor+0.5)/factor,y=math.floor(v.y*factor+0.5)/factor,z=math.floor(v.z*factor+0.5)/factor}
        if not (((floor.x == floor.y) and (floor.x == floor.z) and (floor.y == floor.z))--[[or math.floor(v2*factor+0.5)/factor==math.floor(self["vl"]*factor+0.5)/factor) then
        	minetest.chat_send_all(minetest.write_json(v))
        	self.object:remove()
        end]]
		local v=self.object:getpos()
        local n=vector.normalize(self.object:getvelocity())
        for i=1,vector.length(self.object:getvelocity()) do
        	local floor={x=math.floor(v.x*factor+0.5)/factor,y=math.floor(v.y*factor+0.5)/factor,z=math.floor(v.z*factor+0.5)/factor}
        	for _,player in pairs(minetest.get_connected_players()) do
                local min=vector.add(player:getpos(),{x=-0.5,y=0,z=-0.5})
                local max=vector.add(player:getpos(),{x=0.5,y=2,z=0.5})
                if (v.x >= min.x) and (v.y >= min.y) and (v.z >= min.z) and (v.x <= max.x) and (v.y <= max.y) and (v.z <= max.z) then
                	if not self.on_hit then
                    	local val=player:get_hp()-self["damage"]
                    	if (val <= 0) then
                    		add_kill_message(self["owner"]:get_player_name(),self["source"],player:get_player_name())
                    	    val=0
                    	end
                    	player:set_hp(val)
                   	    self.object:remove()
                    else
                    	self.on_hit(self,floor,true)
                    end
                end
        	end
        	if not (minetest.get_node(floor).name == "air") then
        		if not self.on_hit then
        			if ((self["damage"] >= (minetest.get_node_group(minetest.get_node(floor).name,"crumbly")) and (minetest.get_node_group(minetest.get_node(floor).name,"crumbly") > 0))) then
        				self["damage"]=self["damage"]-minetest.get_node_group(minetest.get_node((floor)).name,"crumbly")
        				minetest.remove_node(floor)
                	else
        	        	self.object:remove()
        	    	end
        	    else
                    self.on_hit(self,floor)
                end
        	    break
        	end
			v=vector.add(v,n)
        	n=vector.normalize(vector.add(self.object:getvelocity(),vector.divide(self.object:getacceleration(),vector.length(self.object:getvelocity()))))
        end
    end,
    makes_footstep_sound = false,
    automatic_rotate = true,
})
end

local function get_animation_frame(dir)
	local angle = math.atan(dir.y)
	local frame = 90 - math.floor(angle * 360 / math.pi)
	if frame < 1 then
		frame = 1
	elseif frame > 180 then
		frame = 180
	end
	return frame
end

function register_arrow(name,size,dmg, weight, color, lifetime, breaking_chance,img)
minetest.register_entity("adv_arms:"..name,{
    hp_max = 1,
    physical = true,
    weight = weight,
    immortal=1,
    lt=lifetime,
    selectionbox = {0,0,0,0,0,0},
    collisionbox = {-size,-size,-size, size,size,size},
	visual = "mesh",
	mesh = "shooter_arrow.b3d",
    spritediv = {x = 1, y = 1},
    damage=dmg,
    visual_size = {x=size*2, y=size*2, z=size*2},
    textures={"adv_arms_arrow_bg.png^(shooter_arrow_uv_bg.png^[colorize:"..color..")^shooter_arrow_uv.png"},
    --textures = {"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color,"adv_arms_bullet.png^[colorize:"..color}, -- number of required textures depends on visual
    is_visible = true,
	on_activate=function (self,shit)
        self["origin"]={x=self.object:getpos().x,y=self.object:getpos().y,z=self.object:getpos().z}
        self["timer"]=0
        self.object:setacceleration({x=0,y=-weight,z=0})
    end,
    on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        local itemname="default:dirt"
        for bullet,item in pairs(REGISTERED_BULLETS) do
            if (item == name) then
                itemname=bullet
                break
            end
        end
        if puncher:get_inventory():room_for_item("main",itemname) then
        	puncher:get_inventory():add_item("main",itemname)
        else
            minetest.spawn_item(puncher:getpos(),itemname)
        end
    end,
	on_step=function(self,dtime)
        if not self.vl then
        	self.object:remove()
        	return
        end
        self["timer"]=self["timer"]+dtime
        if (self["timer"] > lifetime) then
        	self.object:remove()
        	return
        end
        local v2=vector.length(self.object:getvelocity())
		if not (self["damage"] == 0) then
			local frame=get_animation_frame(vector.normalize(self.object:getvelocity()))
	        if not (math.floor(v2*factor+0.5)/factor==math.floor(vector.length(vector.add(self["vl"],vector.multiply(self.object:getacceleration(),self["timer"])))*factor+0.5)/factor) then
		        self.object:setvelocity(vector.new(0,0,0))
				self["damage"]=0
				self.object:set_properties({
					selectionbox={-size,-size,-size, size,size,size}
				})
				self.object:setacceleration(vector.multiply(self.object:getacceleration(),6))
		        if (math.random() > breaking_chance) then
		        	self.object:remove()
				end
			else
				self.object:set_animation({x=frame, y=frame}, 0)
			end
			--self.object:setyaw(vector.normalize(self.object:getvelocity()).x)
	        local v=self.object:getpos()
	        local n=vector.normalize(self.object:getvelocity())
	        for i=1,vector.length(self.object:getvelocity()) do
	        	local floor={x=math.floor(v.x*factor+0.5)/factor,y=math.floor(v.y*factor+0.5)/factor,z=math.floor(v.z*factor+0.5)/factor}
	        	for _,player in pairs(minetest.get_connected_players()) do
	                local min=vector.add(player:getpos(),{x=-0.5,y=0,z=-0.5})
	                local max=vector.add(player:getpos(),{x=0.5,y=2,z=0.5})
	                if (v.x >= min.x) and (v.y >= min.y) and (v.z >= min.z) and (v.x <= max.x) and (v.y <= max.y) and (v.z <= max.z) then
	                    local val=player:get_hp()-self["damage"]
	                    if (val <= 0) then
	                    	add_kill_message(self["owner"]:get_player_name(),self["source"],player:get_player_name())
	                        val=0
	                    end
	                    player:set_hp(val)
	                    self["damage"]=0
	                end
	        	end
	        	v=vector.add(v,n)
	        	n=vector.normalize(vector.add(self.object:getvelocity(),vector.divide(self.object:getacceleration(),vector.length(self.object:getvelocity()))))
	        end
        end
    end,
    makes_footstep_sound = false,
    automatic_rotate = true,
})
end
function register_weapon(name, reload, spread, speed, amount, salve,ammo, am,def)
    local on_use=function(stack,clicker, pointin_at)
    local step=65535/salve
    local microsec=reload or 1
    --add_kill_message(tostring(TIMER), clicker:get_inventory():get_stack("main",clicker:get_wield_index()):get_definition(),"victim")
    --minetest.chat_send_all(tostring(stack:get_wear()))
    if not (stack:get_wear() == 0) then
        if (stack:get_meta():get_string("reloading")=="true") then
        	--stack:get_meta():set_string("reloading","false")
            stack:set_wear(65533)
            RELOADING_PLAYERS[clicker]="adv_arms:"..name
            return stack
        end
    else 
    	stack:get_meta():set_string("reloading","false")
    	stack:get_meta():set_float("last_shot", minetest.get_us_time()/1000000.0-microsec)
        --stack:set_wear(65533)
    end
    if not stack:get_meta():get_float("last_shot") or (minetest.get_us_time()/1000000.0 - stack:get_meta():get_float("last_shot") > microsec) then
    if (stack:get_wear()+step > 65535) then
    	local s=" "..salve*am
    	if (clicker:get_inventory():contains_item("main",ammo..s)) then
    		stack:get_meta():set_string("reloading","true")
    		clicker:get_inventory():remove_item("main",ammo..s)
    	stack:set_wear(65533)
    	RELOADING_PLAYERS[clicker]="adv_arms:"..name
        end
    	return stack
    else
    	stack:get_meta():set_float("last_shot",minetest.get_us_time()/1000000.0)
        stack:add_wear(step)
    end
else
	return stack
end
    ---clicker:get_inventory():set_stack("items", clicker:get_wield_index(), stack)
    for i=1,amount do
    local obj = minetest.add_entity(vector.add(vector.add(clicker:getpos(),{x=0,y=1.6,z=0}),vector.multiply(clicker:get_look_dir(),1.1)), REGISTERED_BULLETS[ammo])
    if obj then
    	local spreadv=vector.add({x=-spread/2,y=-spread/2,z=-spread/2}, vector.multiply({x=math.random(),y=math.random(),z=math.random()},spread) )
    obj:setvelocity(vector.add(vector.multiply(clicker:get_look_dir(),{x=speed,y=speed,z=speed}),spreadv))
    obj:get_luaentity()["vl"]={x=obj:getvelocity().x,y=obj:getvelocity().y,z=obj:getvelocity().z}
    obj:get_luaentity()["owner"]=clicker
    obj:get_luaentity()["source"]=name
     end
    end
     return stack
    end
	def.on_use=on_use
	def.on_place=function(stack, clicker, poinzing)
        if not (stack:get_wear() == 0) then
        if (stack:get_meta():get_string("reloading")=="true") then
            stack:get_meta():set_string("reloading","false")
            stack:set_wear(65533)
            local s=" "..salve*amadv_arms
    		if (clicker:get_inventory():room_for_item("main",ammo..s)) then
    			clicker:get_inventory():add_item("main",ammo..s)
            else
                minetest.spawn_item(clicker:getpos(),ammo..s)
            end
            RELOADING_PLAYERS[clicker]=nil
            return stack
        end
        end
    end
    def.on_secondary_use = def.on_place
    minetest.register_tool("adv_arms:"..name, def)
end

function register_bow(name, reload, spread, speed, amount, salve,ammo, am,def)
    local on_use=function(stack,clicker, pointin_at)
	    local step=65535/salve
	    local microsec=reload or 1
	    --add_kill_message(tostring(TIMER), clicker:get_inventory():get_stack("main",clicker:get_wield_index()):get_definition(),"victim")
	    --minetest.chat_send_all(tostring(stack:get_wear()))
	    if not (stack:get_wear() == 0) then
	        if (stack:get_meta():get_string("reloading")=="true") then
	        	--stack:get_meta():set_string("reloading","false")
	            stack:set_wear(65533)
	            RELOADING_PLAYERS[clicker]=name
	            return stack
	        end
	    else 
	    	stack:get_meta():set_string("reloading","false")
	    	stack:get_meta():set_float("last_shot", minetest.get_us_time()/1000000.0-microsec)
	        --stack:set_wear(65533)
	    end
	    if not stack:get_meta():get_float("last_shot") or (minetest.get_us_time()/1000000.0 - stack:get_meta():get_float("last_shot") > microsec) then --Has the weapon yet reloaded ?
		    if (stack:get_wear()+step > 65535) then --Time to reload !
		    	stack:set_wear(65533)
		    	local s=" "..salve*am
		    	local wip=clicker:get_wield_index()+1
		    	if (wip == 9) then
		    		return nil
		    	end
			    local stackthere=clicker:get_inventory():get_stack("main", wip)
			    local breakit=true
			    local i=1
			    for j,name in pairs(ammo) do
			        if (stackthere:get_name() == name and stackthere:get_count() >= salve*am) then
			          	i=j
			            breakit=false
			            break
			        end
			    end
			    if breakit then
			    	return nil
			    end
			    stackthere:take_item(salve*am)
			    clicker:get_inventory():set_stack("main", wip, stackthere)
		    	stack:get_meta():set_string("reloading","true")
		    	stack:get_meta():set_int("loaded_with",i)
		    	RELOADING_PLAYERS[clicker]="adv_arms:"..name
		    	return stack
		    else
		    	stack:get_meta():set_float("last_shot",minetest.get_us_time()/1000000.0)
		        stack:add_wear(step)
		    end
	    else
	    	return nil
	    end
	    
	    --[[if stack:get_meta():get_float("last_shot") and (minetest.get_us_time()/1000000.0 - stack:get_meta():get_float("last_shot") < microsec) then
			return stack
		end]]
    ---clicker:get_inventory():set_stack("items", clicker:get_wield_index(), stack)
        --Shoot actually
        --minetest.chat_send_all("SHOOTING")
    	for i=1,amount do
    		--error(tostring(stack:get_meta():get_int("loaded_with")))
    		--error(ammo[stack:get_meta():get_int("loaded_with") or 1])
    		--stack:get_meta():get_int("loaded_with") or 1
    		--error(ammo[1])
    		--return nil
		    local obj = minetest.add_entity(vector.add(vector.add(clicker:getpos(),{x=0,y=1.6,z=0}),vector.multiply(clicker:get_look_dir(),1.1)), REGISTERED_BULLETS[ammo[1]])
		    if obj then
		    	local spreadv=vector.add({x=-spread/2,y=-spread/2,z=-spread/2}, vector.multiply({x=math.random(),y=math.random(),z=math.random()},spread) )
		    	obj:setvelocity(vector.add(vector.multiply(clicker:get_look_dir(),{x=speed,y=speed,z=speed}),spreadv))
		    	obj:get_luaentity()["vl"]={x=obj:getvelocity().x,y=obj:getvelocity().y,z=obj:getvelocity().z}
		    	obj:get_luaentity()["owner"]=clicker
				obj:get_luaentity()["source"]=name
				obj:setyaw(clicker:get_look_horizontal()-math.pi/2)
		    end
		end
		return stack
	end
				def.on_use=on_use
				def.on_place=function(stack, clicker, poinzing)
					if not (stack:get_wear() == 0) then
						if (stack:get_meta():get_string("reloading")=="true") then
							stack:get_meta():set_string("reloading","false")
							stack:set_wear(65533)
							local s=" "..salve*am
							if (clicker:get_inventory():room_for_item("main",ammo..s)) then
								clicker:get_inventory():add_item("main",ammo..s)
							else
								minetest.spawn_item(clicker:getpos(),ammo..s)
							end
							RELOADING_PLAYERS[clicker]=nil
							return stack
						end
					end
					stack:get_meta():set_float("last_shot", minetest.get_us_time()/1000000.0-microsec)
				end
				def.on_secondary_use = def.on_place
				minetest.register_tool("adv_arms:"..name, def)
			end

function register_ammo(name, def, bullet)
	REGISTERED_BULLETS["adv_arms:"..name]=bullet
    minetest.register_craftitem("adv_arms:"..name,def)
end

function register_arrow_adv(material, craftitem, damage, inv_img)
	local bulletname=string.lower(material).."_arrow"
	register_arrow(bulletname,0.2, damage, 0.01, "#000000",1000,0.25/damage,--[[inv_img or ]]"adv_arms:"..bulletname)
	register_ammo(bulletname, {description = material.." Arrow",inventory_image = inv_img or "adv_arms_ammo_arrow_"..string.lower(material)..".png"}, "adv_arms:"..bulletname)
    minetest.register_craft({
	output = bulletname..ARROW_CRAFT_AMOUNT,
	recipe = {
		{craftitem, "", ""},
		{"", "default:stick", ""},
		{"", "", "default:stick"}
	}
})
end

function register_basic_weapon(name,def,damage,spread,amount,size,range,color,damageval)
	local on_use=function(stack,clicker, pointin_at)
	    local step=65535/salve
	    local microsec=reload or 1
	    --add_kill_message(tostring(TIMER), clicker:get_inventory():get_stack("main",clicker:get_wield_index()):get_definition(),"victim")
	    --minetest.chat_send_all(tostring(stack:get_wear()))
	    if not (stack:get_wear() == 0) then
	        if (stack:get_meta():get_string("reloading")=="true") then
	        	--stack:get_meta():set_string("reloading","false")
	            stack:set_wear(65533)
	            RELOADING_PLAYERS[clicker]="adv_arms:"..name
	            return stack
	        end
	    else 
	    	stack:get_meta():set_string("reloading","false")
	    	stack:get_meta():set_float("last_shot", minetest.get_us_time()/1000000.0-microsec)
	        --stack:set_wear(65533)
	    end
	    if not stack:get_meta():get_float("last_shot") or (minetest.get_us_time()/1000000.0 - stack:get_meta():get_float("last_shot") > microsec) then
		    if (stack:get_wear()+step > 65535) then
		    	local s=" "..salve*am
		    	if (clicker:get_inventory():contains_item("main",ammo..s)) then
		    		stack:get_meta():set_string("reloading","true")
		    		clicker:get_inventory():remove_item("main",ammo..s)
		    		stack:set_wear(65533)
		    		RELOADING_PLAYERS[clicker]="adv_arms:"..name
		        end
		    	return stack
		    else
		    	stack:get_meta():set_float("last_shot",minetest.get_us_time()/1000000.0)
		        stack:add_wear(step)
		    end
		else
			return stack
		end
	    ---clicker:get_inventory():set_stack("items", clicker:get_wield_index(), stack)
	    for i=1,amount do
		    --local obj = minetest.add_entity(vector.add(vector.add(clicker:getpos(),{x=0,y=1.6,z=0}),vector.multiply(clicker:get_look_dir(),1.1)), REGISTERED_BULLETS[ammo])
		    --Gotta simulate here

		    local spreadv=vector.add({x=-spread/2,y=-spread/2,z=-spread/2}, vector.multiply({x=math.random(),y=math.random(),z=math.random()},spread) )
		    local velo=vector.divide(vector.normalize(vector.add(clicker:get_look_dir(),spreadv)),STEPS)
		    minetest.add_particle({
				pos = {x=0, y=0, z=0},
				velocity = vector.multiply(velo,STEPS*STEPS),
				acceleration = {x=0, y=0, z=0},
				expirationtime = 10,
				size = 0.1,
				collisiondetection = true,
				collison_removal=true,
				vertical = false,
				texture = "adv_arms_bullet.png^[colorize:"..color,
			})
			local v=vector.add(clicker:getpos(),vector.multiply(clicker:get_look_dir(),{x=x,y=y,z=0}))
			local oldv=v
			local checked_nodes={}
			local collision=false
			local friction_x={x=y/x,y=z/x}
			local friction_y={x=x/y,y=z/y}
			local friction_z={x=x/z,y=y/z}
			local colliding_players={} --player - collidepoint
			local damage=damageval --DAMAGE
			--DAMAGE
			--DAMAGE
			for _,player in pairs(minetest.get_connected_players()) do
				local min=vector.add(player:getpos(),{x=-0.5,y=0,z=-0.5})
				local max={x=1,y=2,z=1}
				local x=(clicker:get_look_dir().x and not clicker:get_look_dir().x == 0) or clicker:get_look_dir().x+0.000001
				local y=(clicker:get_look_dir().y and not clicker:get_look_dir().y == 0) or clicker:get_look_dir().y+0.000001
				local z=(clicker:get_look_dir().z and not clicker:get_look_dir().z == 0) or clicker:get_look_dir().z+0.000001
				local cp=pointing_at({pos=min,dim=max},{pos=v,friction_x=friction_x, friction_y=friction_y, friction_z=friction_z})
				if cp then
					local hp=player:get_hp()
					damage=damage-hp
					if (damage == 0) then
						goto skip1
					end
					collision=true
					colliding_players[vector.subtract(cp,v)]=player
				end
			end
			table.sort(colliding_players, function(a,b) return vector.length(a)<vector.length(b) end)
			::skip1::
			if not collision then return end
		    for x=-1/STEPS,1/STEPS,1/STEPS do
			    for y=-1/STEPS,1/STEPS,1/STEPS do
				    for z=-1/STEPS,1/STEPS,1/STEPS do
					    for i=1,math.ceil(range*STEPS) do
							local floor={x=math.floor(v.x*factor+0.5)/factor,y=math.floor(v.y*factor+0.5)/factor,z=math.floor(v.z*factor+0.5)/factor}
							if not checked_nodes[floor] then
								checked_nodes[floor]=true
								if not (minetest.get_node(floor).name == "default:air") then
									local hp=minetest.get_node_group(minetest.get_node(floor).name,"crumbly") or 10
									damage=damage-hp
									if (damage == 0) then
										goto skip --Remove bullet
									end
								end
								v.add(velo)
								for cp,player in pairs(colliding_players) do
									if (vector.length(v) > vector.length(vector.add(cp,oldv))) then
										local hp=player:get_hp()
										player:set_hp(math.max(0,hp-damage))
										damage=damage-hp
										if (damage == 0) then
											goto skip
										end
									end
								end
							end
					    end
					end
				end
			end
			::skip::
		    --obj:setvelocity(vector.add(vector.multiply(clicker:get_look_dir(),{x=speed,y=speed,z=speed}),spreadv))
		    --obj:get_luaentity()["vl"]={x=obj:getvelocity().x,y=obj:getvelocity().y,z=obj:getvelocity().z}
		    --obj:get_luaentity()["owner"]=clicker
		    --obj:get_luaentity()["source"]=name
			def.on_use=on_use
		end
	end
	def.on_place=function(stack, clicker, poinzing)
		if not (stack:get_wear() == 0) then
		    if (stack:get_meta():get_string("reloading")=="true") then
		        stack:get_meta():set_string("reloading","false")
		        stack:set_wear(65533)
		        local s=" "..salve*am
		        if (clicker:get_inventory():room_for_item("main",ammo..s)) then
		    		clicker:get_inventory():add_item("main",ammo..s)
		        else
		            minetest.spawn_item(clicker:getpos(),ammo..s)
		        end
		        RELOADING_PLAYERS[clicker]=nil
		        return stack
		    end
	    end
	end
	def.on_secondary_use = def.on_place
	minetest.register_tool("adv_arms:"..name, def)
end


register_arrow_adv("Wooden","default:wood",1)
register_arrow_adv("Stone","default:cobblestone",1)
register_arrow_adv("Steel","default:steel_ingot",1)
register_arrow_adv("Bronze","default:bronze_ingot",1)
register_arrow_adv("Mese","default:mese",1)
register_arrow_adv("Diamond","default:diamond",1)

--Register Bullets : function register_bullet(name,size,dmg, weight, color, lifetime)

register_bullet("bullet",0.1, 8, 0.05, "#FF00FF",10)

register_arrow("sniper_bullet",0.025, 10, 0.01, "#000000",20,0.1)

register_ammo("mg_ammo", {
	description = "Minigun Ammunition",
	inventory_image = "adv_arms_ammo_mg.png",
}, "adv_arms:bullet")

register_ammo("sniper_ammo", {
	description = "Sniper Ammunition",
	inventory_image = "adv_arms_ammo_sniper.png",
}, "adv_arms:sniper_bullet")

register_weapon("minigun",1.0,1.0,5.0,1,12,"adv_arms:mg_ammo",1/12, {
	description = "Minigun",
	reload_factor=300,
	inventory_image = "adv_arms_weapon_minigun.png",
})

register_bow("sniper",3,0.05,2.0,1,4,{"adv_arms:wooden_arrow","adv_arms:stone_arrow","adv_arms:steel_arrow","adv_arms:bronze_arrow","adv_arms:mese_arrow","adv_arms:diamond_arrow"},1/4, {
	description = "Sniper Rifle",
	reload_factor=500,
	inventory_image = "adv_arms_weapon_sniper.png",
})