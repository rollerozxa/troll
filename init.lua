--[[]
 _________   ______        ______       __           __
/________/\ /_____/\      /_____/\     /_/\         /_/\
\__.::.__\/ \:::_ \ \     \:::_ \ \    \:\ \        \:\ \
   \::\ \    \:(_) ) )_    \:\ \ \ \    \:\ \        \:\ \
    \::\ \    \: __ `\ \    \:\ \ \ \    \:\ \____    \:\ \____
     \::\ \    \ \ `\ \ \    \:\_\ \ \    \:\/___/\    \:\/___/\
      \__\/     \_\/ \_\/     \_____\/     \_____\/     \_____\/
]]

minetest.register_privilege("troll", "Player can do basic trolling")

local function register_troll(name, def)
	def.privs = def.privs or {troll=true}

	-- Most commands only take one argument which is the player
	def.params = def.params or "<player>"

	minetest.register_chatcommand(name, def)
end

-- Check for troll commands that require things found in primarily MTG
local function has_default()
	return minetest.global_exists("default")
end

register_troll("t-ban", {
	description = "Fake ban a player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.ban_player(player:get_player_name())
		minetest.after(0.5, function() minetest.unban_player_or_ip(player:get_player_name()) end)
	end
})

if minetest.settings:get_bool("enable_damage", false) then
	register_troll("t-hp", {
		description = "Remove 2 HP from a player",
		func = function(_, player, amount)
			local player = minetest.get_player_by_name(params)
			if not player then
				return
			end
			player:set_hp(player:get_hp() - 2)
		end
	})
end

register_troll("t-error", {
	description = "Kick the player with an error message",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.disconnect_player(player:get_player_name())
	end
})

register_troll("t-black", {
	description = "Black out the player's screen for 30 seconds",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local idx = player:hud_add({
			hud_elem_type = "image",
			position      = { x = 0.5, y = 0.5 },
			offset        = { x = 0, y = 0 },
			text          = "black.png",
			alignment     = { x = 0, y = 0 },
			scale         = { x = 4000, y = 2000 },
			number        = 0xD61818,
		})

		minetest.after(30, function() player:hud_remove(idx) end)
	end
})

register_troll("t-freeze", {
	description = "Freeze the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 0,
			jump = 0,
			gravity = 0})
	end,
})

register_troll("t-unfreeze", {
	description = "Unfreeze the player or disable /t-nogravity",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 1,
			jump = 1,
			gravity = 1})
	end,
})

register_troll("t-nogravity", {
	description = "Give the player low gravity",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 1,
			jump = 5.0,
			gravity = 0.05})
	end,
})

register_troll("t-teleport", {
	description = "Teleport the player somewhere randomly in the nearby area",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local newpos = player:get_pos()
		newpos.x = newpos.x + math.random(-20, 20)
		newpos.z = newpos.z + math.random(-20, 20)
		player:set_pos(newpos)
	end,
})

register_troll("t-mob", {
	params = "<player> <mob> <amount>",
	description = "Spawns a given amount of mobs at the player's position",
	func = function(name, params)
		local player, mob, amount = unpack(params:split(" "))
		if not player then
			minetest.chat_send_player(name, "Please type in a player name")
			return
		end

		if not amount then
			minetest.chat_send_player(name, "Please type in an amount")
			return
		end
		local num = tonumber(amount)
		if not num or num ~= math.floor(num) then
			minetest.chat_send_player(name, "Please type in an valid amount")
			return
		end

		if not mob then
			minetest.chat_send_player(name, "Please type in an entity")
			return
		end

		local ref = minetest.get_player_by_name(params)
		if ref then
			for i = amount,1,-1 do
				local pos = ref:get_pos()
				minetest.add_entity(pos, mob)
			end
		end
	end
})

register_troll("t-hole", {
	description = "Make a 10 node deep hole the player falls into",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local newpos = vector.round(player:get_pos())
		for i = 1, 10 do
			newpos.y = newpos.y - 1
			minetest.set_node(newpos, { name="air" })
		end
	end,
})

register_troll("t-msg", {
	params = "<from> <to> <msg>",
	description = "Fake a PM from another player",
	func = function(name, params)
		local from, to, msg = params:match("^(%S+)%s(%S+)%s(.+)$")
		if not msg then return "syntax error.  usage: /t-msg <from> <to> <msg>" end
		minetest.chat_send_player(to, "PM from " .. from .. ": " .. msg)
	end,
})

register_troll("t-chat", {
	params = "<from> <msg>",
	description = "Impersonate someone and send a message as them (also works with made-up players)",
	func = function(name, params)
		local from, msg = params:match("^(%S+)%s(.+)$")
		if not msg then return "syntax error.  usage: /t-msg <from> <to> <msg>" end
		minetest.chat_send_all("<"..from.."> "..msg)
	end,
})

register_troll("t-grant", {
	params = "<from> <to> <priv>",
	description = "Fake giving a player privileges",
	func = function(name, params)
		local from, to, priv = params:match("^(%S+)%s(%S+)%s(.+)$")
		if not priv or not to or not from then return "syntax error.  usage: /t-grant <from> <to> <priv>" end
		minetest.chat_send_player(to, from.." granted you privileges: "..priv)
	end,
})

-- Spawn schematics at player position, requires default

if has_default() then
register_troll("t-jail", {
	description = "Build a jail at the player's position",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.place_schematic(player:get_pos(), minetest.get_modpath("troll") .. "/schems/jail.mts", "random", nil, false)

		local newpos = player:get_pos()
		newpos.x = newpos.x + 1
		newpos.z = newpos.z + 1
		newpos.y = newpos.y + 1
		player:set_pos(newpos)
	end,
})

register_troll("t-lava", {
	description = "Put the player inside of lava",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.place_schematic(player:get_pos(), minetest.get_modpath("troll") .. "/schems/lava.mts", "random", nil, false)

		local newpos = player:get_pos()
		newpos.x = newpos.x + 1
		newpos.z = newpos.z + 1
		newpos.y = newpos.y + 0.5
		player:set_pos(newpos)
	end,
})
end

-- Epic trolling commands that spawn particles.

local function troll_particlespawner(type, pos, texture, playername)
	local def = {
		amount = 2000,
		time = 30,
		minvel = { x = 0.2, y = 0.2, z = 0.2 },
		maxvel = { x = 0.4, y = 0.8, z = 0.4 },
		minacc = { x = -0.2, y = 0, z = -0.2 },
		maxacc = { x = 0.2, y = 0.1, z = 0.2 },
		minexptime = 6,
		maxexptime = 8,
		minsize = 10,
		maxsize = 10,
	}

	def.minpos = { x = pos.x - 10, y = pos.y, z = pos.z - 10 }
	def.maxpos = { x = pos.x + 10, y = pos.y, z = pos.z + 10 }

	def.texture = texture
	if playername then def.playername = playername end

	return def
end

if has_default() then
	register_troll("t-diamond", {
		description = "Spawns lots of diamonds around the player",
		func = function(_, params)
			local player = minetest.get_player_by_name(params)
			if not player then
				return
			end

			local pos = player:get_pos()
			minetest.add_particlespawner(troll_particlespawner(1, pos, "default_diamond.png", params))
		end
	})
end

register_troll("t-shit", {
	description = "Spawns lots of shit around the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local pos = player:get_pos()
		minetest.add_particlespawner(troll_particlespawner(1, pos, "troll_shit.png", params))
	end
})

register_troll("t-eyes", {
	description = "Spawns lots of eyes around the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local pos = player:get_pos()
		minetest.add_particlespawner(troll_particlespawner(1, pos, "troll_eye.png", params))
	end
})

register_troll("t-smoke", {
	description = "Spawns lots of smoke around the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local pos = player:get_pos()
		minetest.add_particlespawner(troll_particlespawner(1, pos, "troll_smoke.png", params))
	end
})

register_troll("t-blackparticles", {
	description = "Spawns lots of black particles around the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local pos = player:get_pos()
		minetest.add_particlespawner(troll_particlespawner(1, pos, "troll_black.png", params))
	end
})
