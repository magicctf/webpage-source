function register_skill(name, descri, img)
minetest.register_craftitem("skills:skill_"..name, {
	description = descri,
	inventory_image = "skills_skill_"..name..".png",
})
end
register_skill("speed","Skill of speed")
register_skill("sprint","Skill of sprinting")
register_skill("regen","Skill of regeneration")
register_skill("areaheal","Skill areahealing")
register_skill("morehp","Skill of strength")
register_skill("lifesteal","Skill of vampirism")
register_skill("damage","Skill of damage")
register_skill("manaregen","Skill of mana regeneration")
register_skill("burn","Skill of burning")
register_skill("iceprison","Skill iceprison")
register_skill("invisibility","Skill of invisibility")
register_skill("shapeshifting","Skill of shapeshifting")
register_skill("freeze","Skill of freezing")
register_skill("blast","Skill of blasting")
register_skill("protect","Skill of protecting")
register_skill("break","Skill of breaking enemies protection")
register_skill("poison","Skill of poisoning")