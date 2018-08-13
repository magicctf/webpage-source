points_left=30
fuel_percent=0
skills=""
selected_skill=""
selected_item=""
s=2
y=0
skills_table={}
function update_fs() 
select_skills_formspec="size[8,5;]\nimage[0,0;1,5;select_skills_bar_fg.png^[lowpart:"..(fuel_percent)..":select_skills_bar_bg.png]\nlabel[1,0;Chosen\nSkill : ]\nbutton[1,2;1,1;submitplus;+]\nbutton[1,3;1,1;submitminus;-]"..skills..selected_skill.."\nlabel[1,4;Points\nleft : "..points_left.."]"
end
minetest.after(1, function()
for n, i in pairs(core.registered_craftitems) do
    if string.find(n,"skills",1,true) and not string.find(n,"selector",1,true) then
       skills=skills.."\nitem_image_button["..s..","..y..";1,1;"..n..";"..n..";]"
       s=s+1
       if s == 8 then 
          s=2
          y=y+1
       end
       if y == 5 then
          break
       end
    end
end
update_fs()
end)
minetest.register_craftitem("select_skills:skill_selector", {
	description = "Skill selector",
	inventory_image = "select_skills_selector.png",
 
	on_use = function(itemstack, user, pointed_thing)
		minetest.show_formspec(user:get_player_name(), "select_skills:select_skills", select_skills_formspec)
		--itemstack:take_item()
		return nil
	end,
        on_drop = function(itemstack, dropper, pos)
		return itemstack
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "select_skills:select_skills" then
                found=false
                for n, i in pairs(fields) do
                        if string.find(n,"skills",1,true) and not string.find(n,"selector",1,true) then
                            found=true
                            if (skills_table[n]) then
                                fuel_percent=skills_table[n]
                            else
                                fuel_percent=0
                                skills_table[n]=fuel_percent
                            end
                            selected_skill="\nitem_image_button[1,1;1,1;"..n..";"..n..";]"
                            selected_item=n
                        end
	            end
                if selected_skill ~= "" and not found then
                   fuel_percent=skills_table[selected_item]
               	 if fields["submitplus"] then
                 	   if points_left ~= 0 then
                        points_left=points_left-1
                 	      fuel_percent=fuel_percent+1.0/0.3
                 	   end
                  elseif fields["submitminus"] then
                    if points_left ~= 30 and math.ceil(fuel_percent) ~= 0 then
                       fuel_percent=fuel_percent-1.0/0.3
                       points_left=points_left+1
                    end
                  end
                  skills_table[selected_item]=fuel_percent
                end
                update_fs()
                minetest.show_formspec(player:get_player_name(), "select_skills:select_skills", select_skills_formspec)
	end
end)
