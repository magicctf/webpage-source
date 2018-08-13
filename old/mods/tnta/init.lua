local cid_data = {}
minetest.register_node("tnta:air", {
	drawtype = "airlike",
	tiles = {},
	light_source = 14,
	groups = {not_in_creative_inventory = 1},
	drop = '',
	walkable = false,
	buildable_to = true,
	pointable = false,
	damage_per_second = 4,
	on_blast = function() end,
	on_timer = function(pos)minetest.remove_node(pos)end
})
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		if name == "fire:basic_flame" then
			tntafire = true
		elseif name == "default:coalblock" then
			tntacoal = true
		end
		if def.groups then
		r = 1
		r=hardness(def,r,"cracky")
		r=hardness(def,r,"choppy")
		r=hardness(def,r,"crumbly")
		r=hardness(def,r,"oddly_breakable_by_hand")
		r=hardness(def,r,"snappy")
		r=hardness(def,r,"dig_immediate")
		if def.groups.level then
		if type(def.groups.level) == "number" then
			r = r/math.max(1,def.groups.level)
		end
		end
		r = (1-1/(r+1))*100
		else
		r = 0
		end
		if def.liquidtype == "source" or def.liquidtype == "flowing" then
			r = 100
		end
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drop,
			flammable = def.groups.flammable,
			hardness = r,
			igniter = def.groups.igniter,
			on_blast = def.on_blast,
			mesecon = mesecon,
			def = def
		}
	end
	cid_fire = minetest.get_content_id("fire:basic_flame")
	cid_coal = minetest.get_content_id("default:coalblock")
	cid_air = minetest.get_content_id("air")
end)
function debugger(timeout,words)
	minetest.after(timeout,function()minetest.chat_send_all(words)end)
end


minetest.register_entity("tnta:mover",{
	hp_max		= 1000000,
	physical	= true,
	collisionbox	= { -1/2, -1/2, -1/2, 1/2, 1/2, 1/2 },
	textures = {"none.png"},
	timer		= 0,
	physical_state	= true,
	on_activate = function(sf,dt)
		sf.object:set_armor_groups({immortal =1})
	end,
	on_step = function( sf, dt )
		sf.timer = sf.timer + dt
		if sf.timer > 1.5 then
			sf.object:remove()
		end
	end
})
function dir(pos,radius,dmg)
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for i, obj in ipairs(objs) do
		obj:set_hp(obj:get_hp()-dmg)
	end
end
function gass(pos,radius,textures,damage)
	minetest.add_particlespawner({
		amount = radius*radius*radius*80,
		time = 60,
		minpos = vector.subtract(pos, radius/2),
		maxpos = vector.add(pos, radius/2),
		minvel = {x=-1, y=-1, z=-1},
		maxvel = {x=1,  y=1,  z=1},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 2,
		maxexptime = 8,
		minsize = 4,
		maxsize = 6,
		texture = textures .. ".png",
	})
	for i = 0,60 do
		minetest.after(i,dir,pos,radius,damage)
	end
end
function blend(user,tges,i)
	if i == nil then i  =1 
	elseif i > 9 then return end
	local first_screen = user:hud_add({
		hud_elem_type = "image",
		position = {x=0, y=0},
		scale = {x=10000, y=10000},
		text = "fl" .. tostring(i) .. ".png",
		offset = {x=0, y=0},
	})
	minetest.after(tges/10, function()
		user:hud_remove(first_screen)
		blend(user,tges,i+1)
	end)
end
function hardness(def,n,value)
	if def.groups[value] then
		if type(def.groups[value]) == "number" then
			n = n*math.max(1,def.groups[value])
		end
	end
	return n
end
function blendex(pos,range,time)
	minetest.set_node(pos,{name="tnta:air"})minetest.get_node_timer(pos):start(1)
	local objs = minetest.get_objects_inside_radius(pos, range)
	for i, obj in ipairs(objs) do
		if obj:is_player() then
				blend(obj,time)
		end
	end
end
function colorizer(hex,a)
	return "^[colorize:#" .. hex .. ":" .. tostring(a)
end
function throwedtnt(name,tiles,time)
	minetest.register_entity("tnta:throwed" .. name,{
	hp_max	= 1000000,
	physical= true,
	visual = "cube",
	visual_size = {x=1,y=1,z=1},
	collisionbox	= { -1/2, -1/2, -1/2, 1/2, 1/2, 1/2 },
	textures = tiles,
	physical_state	= true,
	on_activate = function(sf,dt)
		sf.object:set_armor_groups({immortal =1})
	end,
	on_step = function( sf, dt )
		local pos = sf.object:getpos()
		local vel = sf.object:getvelocity()
		pos.y = pos.y -1
		if minetest.get_node(pos).name ~= "air" then
			sf.object:setvelocity({x = vel.x/2,y = vel.y,z = vel.z/2})
			if vector.distance(sf.object:getvelocity(),{x=0,y=0,z=0})<1 then
				pos.y = pos.y+1
				minetest.set_node(pos, {name = "tnta:" .. name .. "b"})
				minetest.get_node_timer(pos):start(time)
				sf.object:remove()
			end
		else
			sf.object:setvelocity({x = vel.x/1.1,y = vel.y,z = vel.z/1.1})
		end
	end,
	on_punch = function(sf,player)
		if player:get_wielded_item():get_name() == "default:torch" then
			minetest.set_node(sf.object:getpos(), {name="tnta:" .. name .. "b"})
			minetest.get_node_timer(pos):start(time)
			sf.object:remove()
		end
	end		
})
end
function throwtnt(user,name)
	local dir = user:get_look_dir()
	tnt = minetest.add_entity(vector.add(user:getpos(),vector.multiply(dir,3)),"tnta:throwed" .. name)
	tnt:setvelocity({x=dir.x*20, y=dir.y*30, z=dir.z*20})
	tnt:setacceleration({x=0, y=-5, z=0})
end
local function drop_unified_inventory(pos,drops,force)
	for _, drop in pairs(drops) do
	if type(cid_data[drop.content].name) == "string" and(type(cid_data[drop.content].drops)=="string"or cid_data[drop.content].drops == nil)then
	drop =(cid_data[drop.content].drops or cid_data[drop.content].name) .. " " .. tostring(drop.number)
	obj = minetest.add_item(pos,drop)
	if obj then
		obj:setvelocity({x=math.random(-force,force), y=math.random(0,force), z=math.random(-force,force)})
	end
	end
	end
end

function explodeadvanced(pos,radius,damage)
	debugger(0,"INIT")
	local drops = {}
	local vm = VoxelManip()
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local c_air = minetest.get_content_id("air")
    --    local metas={}
	debugger(0,tostring(c_air))
	local distsq = radius*radius
	local p = {x = 0,y = 0,z = 0}
	for z = -radius, radius do
	for y = -radius, radius do
	for x = -radius, radius do
		if (x * x) + (y * y) + (z * z) <= distsq then
			p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
			local i = a:index(p.x,p.y,p.z)
			local cid = data[i]
			if cid ~= c_air then
				--[[local meta = minetest.get_meta(p):to_table()
				if not (#meta == 0) then
                    metas[p]=meta
				end]]
				lossy = cid_data[cid].hardness
				if lossy == nil or math.random(1, 100)*vector.distance(pos, p)/radius<lossy then
					local def = cid_data[cid]
					if def and def.on_blast then
						def.on_blast(a:position(i), 1)
					elseif def and def.flammable then
						if math.random(1,5) == 1 and tntafire then
							data[i]=cid_fire
						elseif math.random(1,50) == 1 and tntacoal then
							data[i]=cid_coal
						else
							data[i]=cid_air
						end
					elseif def then
						data[i]=cid_air
					if drops[cid] then
						drops[cid]={content = cid,number=drops[cid].number+1}
					else
						drops[cid]={content = cid,number = 1}
					end
				else
					data[i]=cid_air
				end
			end
		end
	end
	end
	end
	end
	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_liquids()
	vm:update_map()
	--[[for pos, meta in pairs(metas) do
        minetest.get_meta(pos):from_table(meta)
	end]]
	minetest.sound_play("explosion", {pos = pos, gain = radius*10, max_hear_distance = radius*10})
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local obj_vel = obj:getvelocity()
		local dist = math.max(1, vector.distance(pos, obj_pos))
		if obj_vel == nil then
			obj_vel = {x = 0,y = 0,z = 0}
		end
		vel = vector.add(vector.multiply(vector.normalize(vector.direction(pos, obj_pos)), 1000/dist), obj_vel)
		if obj:is_player() == true then
			local emp = minetest.add_entity( obj_pos, 'tnta:mover' )
			obj:set_attach(emp, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
			emp:setvelocity({x=vel.x, y=vel.y, z=vel.z})
			emp:setacceleration({x=-vel.x/5, y=-10, z=-vel.z/5})
		else
			obj:setvelocity(vel)
		end
		obj:set_hp(obj:get_hp() - ((4 / dist) * radius*damage))
	end
	radius = radius / 2
	for i = 1,12 do
		minetest.add_particlespawner({
			amount = 256,
			time = 5,
			minpos = vector.subtract(pos, radius / 2),
			maxpos = vector.add(pos, radius / 2),
			minvel = {x=-20, y=-20, z=-20},
			maxvel = {x=20,  y=20,  z=20},
			minacc = vector.new(),
			maxacc = vector.new(),
			minexptime = 0.25,
			maxexptime = 0.5,
			minsize = 8,
			maxsize = 16,
			texture = tostring(i) .. ".png",
		})
	end
	drop_unified_inventory(pos,drops,radius*2)
end
function animated(name,sizeimg,t)
	return{name = name,animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = t,}}
end
function explosive(name,t1,t2,light,radius,damage,length,extrafunc,tov)
	throwedtnt(name,t1,length)
	local function throw(itemstack,user,pointed)
		if not minetest.get_pointed_thing_position(pointed) then
			itemstack:take_item()
			throwtnt(user,name)
		end
		return itemstack
	end
	local func = function(pos)  minetest.set_node(pos,{name="tnta:air"})minetest.get_node_timer(pos):start(1) explodeadvanced(pos,radius,damage)return false end
	if extrafunc then
		if tov then
			func = function(pos)minetest.remove_node(pos)extrafunc(pos,radius,damage) return false end
		else
			func = function(pos)minetest.set_node(pos,{name="tnta:air"})minetest.get_node_timer(pos):start(1)extrafunc(pos)explodeadvanced(pos,radius,damage) return false end
		end
	end
	minetest.register_node("tnta:" .. name, {
		description = name,
		tiles = t1,
		groups = {dig_immediate=2,connect_to_raillike=minetest.raillike_group("gunpowder")},
		mesecons = {effector = {action_on = function(pos)
			minetest.set_node(pos,{name="tnta:" .. name .. "b"})
			minetest.get_node_timer(pos):start(length)end}},
		on_blast = func,
		on_use = throw,
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" then
				minetest.set_node(pos, {name="tnta:" .. name .. "b"})
				minetest.get_node_timer(pos):start(length)
			end
		end,
	})
	minetest.register_node("tnta:" .. name .. "b", {
		tiles = t2,
		light_source = light,
		drop = "",
		groups = {dig_immediate=2,connect_to_raillike=minetest.raillike_group("gunpowder")},
		on_timer = func,
		on_blast = func
	})
	minetest.register_abm({
		nodenames = {"tnta:" .. name},
		neighbors = {"group:igniter"},
		interval = 0.1,
		chance = 1,
		action = function(pos)
			minetest.set_node(pos,{name="tnta:" .. name .. "b"})
			minetest.get_node_timer(pos):start(length)
	end})
	minetest.register_abm({
		nodenames = {"tnta:" .. name .. "b"},
		interval = 1,
		chance = 1,
		action = function(pos)
			minetest.sound_play("burnin", {pos = pos, gain = 1, max_hear_distance = 10})
	end})
end
function  tnt(name,radius,damage,length,sizeimg)
	local textures = {name .. "b.png",name .. "s.png",name .. "ba.png"}
	explosive(name,{textures[1] .. "^tntstring.png",textures[1],textures[2],textures[2],textures[2],textures[2]},{{name = textures[3] .. "^tntstring_top_animated" .. tostring(sizeimg) .. ".png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}},textures[1], textures[2]},5,radius,damage,length)
end
function  blender(name,radius,damage,length,sizeimg)
	local textures = {name .. "b.png",name .. "s.png",name .. "ba.png"}
	explosive(name,{textures[1] .. "^tntstring.png",textures[1],textures[2],textures[2],textures[2],textures[2]},{{name = textures[3] .. "^tntstring_top_animated" .. tostring(sizeimg) .. ".png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}},textures[1], textures[2]},5,radius,damage,length,blendex,true)
end
function  gasser(name,radius,length,sizeimg)
	local textures = {name .. "b.png",name .. "s.png",name .. "ba.png"}
	explosive(name,{textures[1] .. "^tntstring.png",textures[1],textures[2],textures[2],textures[2],textures[2]},{{name = textures[3] .. "^tntstring_top_animated" .. tostring(sizeimg) .. ".png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}}
,textures[1], textures[2],textures[2],textures[2],textures[2]},5,radius,nil
,length,function(pos)gass(pos,radius,"gas",4)end,true)
end
function  smoker(name,radius,length,sizeimg)
	local textures = {name .. "b.png",name .. "s.png",name .. "ba.png"}
	explosive(name,{textures[1] .. "^tntstring.png",textures[1],textures[2],textures[2],textures[2],textures[2]},{{name = textures[3] .. "^tntstring_top_animated" .. tostring(sizeimg) .. ".png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}}
,textures[1], textures[2],textures[2],textures[2],textures[2]},5,radius,nil
,length,function(pos)gass(pos,radius,"6",0)end,true)
end
function  bomb(name,radius,damage,length,sizeimg)
	local bombtextures = {name .. "b.png",name .. "s.png",name .. "ba.png"}
	explosive(name,{bombtextures[1] .. "^bombstring.png",bombtextures[2],bombtextures[2],bombtextures[2],bombtextures[2],bombtextures[2]},{{name = bombtextures[3] .. "^bomb_animated" .. tostring(sizeimg) .. ".png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}},bombtextures[2], bombtextures[2]},5,radius,damage,length)
end
function  nuke(name,radius,damage,length,sizeimg,extrafunc)
	local textures = {"nuket.png","nukeb.png",name .. "s.png",name .. "s.png",name .. "f.png",name .. "f.png"}explosive(name,textures,{{name = "nuke_top.png",animation = {type = "vertical_frames",aspect_w = sizeimg,aspect_h = sizeimg,length = length,}},textures[2],textures[3],textures[4],textures[5],textures[6]},5,radius,damage,length,extrafunc)
end
minetest.register_node("tnta:steelwall", {
	description = "strong barrier",
	tiles = {"steel.png"},
	groups = {cracky=1,level = 3}
})
minetest.register_node("tnta:string", {
	description = "String",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	tiles = {"sstraight.png", "scurved.png", "sjunction.png", "scross.png"},
	inventory_image = "sstraight.png",
	wield_image = "sstraight.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {dig_immediate=2,attached_node=1,connect_to_raillike=minetest.raillike_group("gunpowder")},
	
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.set_node(pos,{name = "tnta:stringb"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_blast = function(pos, intensity)
		minetest.set_node(pos,{name = "tnta:stringb"})
		minetest.get_node_timer(pos):start(5)
	end,
})
minetest.register_node("tnta:stringb",{
	description = "String",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	tiles = {"sstraightb.png", "scurvedb.png", "sjunctionb.png", "scrossb.png"},
	inventory_image = "sstraightb.png",
	wield_image = "sstraightb.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	drop = "",
	on_timer = function(pos) minetest.remove_node(pos)return false end,
	groups = {igniter = 10,dig_immediate=2,attached_node=1,connect_to_raillike=minetest.raillike_group("gunpowder")},
	-- unaffected by explosions
})
minetest.register_abm({
	nodenames = {"tnta:string"},
	interval = 0.1,
	chance = 1,
	neighbors = {"group:igniter"},
	action = function(pos)
		minetest.set_node(pos,{name="tnta:stringb"})
		minetest.get_node_timer(pos):start(5)
end})
minetest.register_abm({
	nodenames = {"tnta:stringb"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
		minetest.sound_play("burnin", {pos = pos, gain = 1, max_hear_distance = 10})
end})
function playerinrange(pos,radius)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos,radius)) do
		if obj:is_player() == true then
			return true
		end
	end
end
for i = 1,5 do
	minetest.register_abm({
		nodenames = {"group:stone"},
		interval = 10,
		chance = 25000000/(i*i),
		action = function(pos)
			if pos.y < -100 and not playerinrange(pos,10)then
				minetest.place_schematic(pos, minetest.get_modpath("tnta").."/schems/b" .. tostring(i) .. ".mts",nil,nil,true)
			end
	end})
end
minetest.register_craftitem("tnta:craftingtable", {
	description = "Craftingtable",
	inventory_image = "Output.jpg",
	on_use = function(ignore,player)
		minetest.show_formspec(player:get_player_name(), "crafts[tnta]", "size[0,0]image[-6.5,-5;17,10;Output.jpg]")
	end
})
tnta = {blend = blend,explosive = explosive,explode = explodeadvanced,cid_data = cid_data}
explosive("nitro",{"blackpowderbarrelb.png","blackpowderbarrelb.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png"},{"blackpowderbarrelb.png","blackpowderbarrelb.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png"},0,6,2,0)
explosive("blackpowderbarrel",{"blackpowderbarrel.png","blackpowderbarrelb.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png"},{"blackpowderbarrel.png","blackpowderbarrelb.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png","blackpowderbarrels.png"},0,3,0.5,0)
tnt("tnt",4,1,3,17)
tnt("dynamite",5,2,3,17)
tnt("plasticexplosive",8,3,5,16)
blender("standard_blender",20,20,3,17)
blender("meseblender",30,40,3,17)
nuke("thermonuke",50,15,20,17)
nuke("h_bomb",100,20,30,17)
nuke("neutron_bomb",50,18,20,17)
bomb("standard_bomb",5,4,3,17)
tnt("plasmabomb",3,8,3,17)
bomb("d_bomb",8,6,5,17)
gasser("gasbomb",10,3,17)
smoker("smokebomb",10,3,17)
minetest.register_craft({
	output = 'tnta:blackpowderbarrel',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:coalblock','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:craftingtable',
	recipe = {
		{'','',''},
		{'','default:paper',''},
		{'','',''},
	}
})
minetest.register_craft({
	output = 'tnta:tnt',
	recipe = {
		{'','default:wood',''},
		{'default:wood','tnta:blackpowderbarrel','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:dynamite',
	recipe = {
		{'','default:wood',''},
		{'default:wood','tnta:nitro','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:nitro',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:gravel','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:standard_blender',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:steel_ingot','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:meseblender',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:mese_crystal','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = "tnta:plasticexplosive",
	recipe = {
		{'','default:clay_lump',''},
		{'default:clay_lump','default:coalblock','default:clay_lump'},
		{'','default:clay_lump',''},
	}
})
minetest.register_craft({
	output = 'tnta:gasbomb',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:clay_lump','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:smokebomb',
	recipe = {
		{'','default:wood',''},
		{'default:wood','default:dirt','default:wood'},
		{'','default:wood',''},
	}
})
minetest.register_craft({
	output = 'tnta:plasmabomb',
	recipe = {
		{'default:bronze_ingot','default:bronze_ingot','default:bronze_ingot'},
		{'default:bronze_ingot','tnta:blackpowderbarrel','default:bronze_ingot'},
		{'default:bronze_ingot','default:bronze_ingot','default:bronze_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:d_bomb',
	recipe = {
		{'default:steel_ingot','default:diamond','default:steel_ingot'},
		{'default:diamond','tnta:blackpowderbarrel','default:diamond'},
		{'default:steel_ingot','default:diamond','default:steel_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:standard_bomb',
	recipe = {
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
		{'default:steel_ingot','tnta:blackpowderbarrel','default:steel_ingot'},
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:thermonuke',
	recipe = {
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
		{'default:steel_ingot','default:mese','default:steel_ingot'},
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:neutron_bomb',
	recipe = {
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
		{'default:steel_ingot','default:mese','default:gold_ingot'},
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:h_bomb',
	recipe = {
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
		{'default:steel_ingot','default:mese','default:goldblock'},
		{'default:steel_ingot','default:steel_ingot','default:steel_ingot'},
	}
})
minetest.register_craft({
	output = 'tnta:plasmabomb',
	recipe = {
		{'','default:copper_ingot',''},
		{'default:copper_ingot','tnta:blackpowderbarrel','default:copper_ingot'},
		{'','default:copper_ingot',''},
	}
})
minetest.register_craft({
	output = 'tnta:string',
	recipe = {
		{'','group:leaves',''},
		{'','group:leaves',''},
		{'','group:leaves',''},
	}
})
