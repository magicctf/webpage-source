--Basic Lib

function tablecopy(T)
  local t={}
  for key,val in pairs(T) do t[key]=val end
  return t
end

MAX_POTIONS=3 --How much potions at the same time ?
MAX_LVL=3 --Max potion level = Potion duration * 5 sec
MAX_TIER=3 --Max potion tier = Potion strength
POTIONS={}
local timer=0

--Updates hud + purges effects if it's time to

function maintain_potion(potions,timer,player)
	if not potions then return end
	local yshift=0
	for i,potion in pairs(potions) do
        local name=potion[1]
        local time=potion[2]
        time=time-timer
        if (time < 0) then
        	player:hud_remove(potion[3])
        	player:hud_remove(potion[4])
        	player:hud_remove(potion[6])
        	yshift=yshift+20
        	POTIONS[player][i]=nil
        	if (potion[8]) then
        		potion[8](player,potion[9])
        	end
        else
            POTIONS[player][i][2]=time
            player:hud_change(potion[6],"text",name.." : "..tostring(math.floor(time+0.5)).." s")
            player:hud_change(potion[4],"number",time/potion[5]*160)
            if not (yshift == 0) then
            	local o1={x=0,y=yshift+potion[7]}
            	POTIONS[player][i][7]=o1.y
            	player:hud_change(potion[6],"offset",o1)
            	player:hud_change(potion[4],"offset",o1)
            	player:hud_change(potion[3],"offset",{x=o1.x+1,y=o1.y-1})
            end
        end
    end
end

--Remove hud elements & globalsteps if the potions run out

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
        for player, potions in pairs(POTIONS) do
        	maintain_potion(potions, timer, player)
        end
        timer=0
	end
end)

--Registers a potion. Arguments : potion name, item def, potion color, effect function, remove effect function

function register_potion(name,defv,color,effect,deleteeffect)
	local descri=defv.description
	for t=1,MAX_TIER do
		for i=1,MAX_LVL do
			local def=tablecopy(defv)
			def.description=descri.." Tier "..tostring(t)..", Level "..tostring(i)
			def.on_use=function(stack,player)
			    if (effect) then
			    	effect(player,t)
			    else
	                minetest.log("Potions Mod Warning - No Effect Potion")
	            end
				local max_stat=i*5
				local offset=0
				if POTIONS[player] then
					offset=tablelength(POTIONS[player])
					if (offset==MAX_POTIONS) then
						return nil
					end
					offset=offset*-20
				end
				local pos=vector.add(player:getpos(),{x=0,y=1.3,z=0})
				minetest.add_particlespawner( {amount = 50,
					time = 2,
					minvel = {x=-0.5, y=0.1, z=-0.5},
					maxvel = {x=0.5, y=0.5, z=0.5},
					minacc = {x=-0.05, y=0.1, z=-0.05},
					maxacc = {x=0.05, y=0.05, z=0.05},
					minexptime = 2,
					maxexptime = 6,
					minsize = 0.2,
					maxsize = 1,
					collisiondetection = false,
					vertical = false,texture="potions_particle_white.png^[colorize:"..color,minpos=pos,maxpos=pos
				})
				local bg_id=player:hud_add({
	    			hud_elem_type = "statbar",
	    			position = {x=0.1,y=0.9},
	    			size = "",
	    			text = "hudbars_bar_background.png",
	    			number = 2,
	    			alignment = {x=1,y=1},
	   				offset = {x=0, y=offset},
				})
				local bar_id = player:hud_add({
	    			hud_elem_type = "statbar",
	    			position = {x=0.1,y=0.9},
	    			size = "",
	    			text = "potions_bar_timeout.png^[colorize:"..color,
	    			number = 160,
	    			alignment = {x=1,y=1},
	    			offset = {x=1, y=offset+1},
				})
				local text_id = player:hud_add({
	    			hud_elem_type = "text",
	    			position = {x=0.1,y=0.9},
	    			size = "",
	    			text = descri.."("..tostring(t)..") : "..max_stat.." s",
	    			number = 0xFFFFFF,
	    			alignment = {x=1,y=1},
	    			offset = {x=1, y=offset},
				})
			    if not POTIONS[player] then
			        POTIONS[player]={{descri.." ("..tostring(t)..")",max_stat,bg_id,bar_id,max_stat,text_id,offset,deleteeffect,t}}
			    else
	                table.insert(POTIONS[player],{descri.." ("..tostring(t)..")",max_stat,bg_id,bar_id,max_stat,text_id,offset,deleteeffect,t})
			    end
	            stack:take_item()
	            return stack
		    end
		    def.wield_image="potions_liquid.png^[colorize:"..color.."^potions_vessel.png"
		    def.inventory_image=def.wield_image.."^(potions_tier_"..tostring(t)..".png^[transformFY)^(potions_lvl_"..tostring(i)..".png^[transformFY)"
	        minetest.register_craftitem("potions:"..name.."_lev_"..tostring(i).."_tier_"..tostring(t), def)
	    end
	end
end

function register_physics_potion(name,defv,color,attrib,process, antiprocess)
	register_potion(name, defv, color, function(player,tier) 
	local physics=player:get_physics_override()
	physics[attrib]=(process and process(physics[attrib],tier)) or physics[attrib]*math.sqrt(tier*2+1)
	player:set_physics_override(physics)
	end,
	function(player,tier) 
	local physics=player:get_physics_override()
	physics[attrib]=(antiprocess and antiprocess(physics[attrib],tier)) or physics[attrib]/math.sqrt(tier*2+1)
	player:set_physics_override(physics) end)
end

--Delete potions if player dies

minetest.register_on_dieplayer(function(player)
maintain_potion(POTIONS[player],100000,player)
POTIONS[player] = nil
end)

--Register normal potions

--Regeneration potion - green
register_potion("regen_potion", { 
	description = "Regen Potion",
},"#00FF00",function(player,tier) player:set_attribute("regen",(player:get_attribute("regen") or 1)+tier) end,function(player,tier) player:set_attribute("regen",player:get_attribute("regen")-tier) end)

--Register player physics potions

--Speed potion - yellow
register_physics_potion("speed_potion", {
	description = "Speed Potion",
},"#FFFF00","speed")

--Jump potion - orange
register_physics_potion("jump_potion", {
	description = "Jump Potion",
},"#FFFFDD","jump")

--Antigravity potion - dark grey
register_physics_potion("antigravity_potion", {
	description = "Antigravity",
},"#555555","gravity",function(value,tier) return value/math.sqrt(tier*2+1) end,function(value,tier) return value*math.sqrt(tier*2+1) end)