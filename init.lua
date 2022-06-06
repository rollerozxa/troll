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

register_troll("t-smoke", {
	description = "Spawns much of smoke arround the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local pos1 = player:get_pos()
		minetest.add_particlespawner({
			amount = 60000,
			time = 30,
			minpos = { x = pos1.x - 10, y = pos1.y - 10, z = pos1.z - 10 },
			maxpos = { x = pos1.x + 10, y = pos1.y + 10, z = pos1.z + 10 },
			minvel = { x = 0.2, y = 0.2, z = 0.2 },
			maxvel = { x = 0.4, y = 0.8, z = 0.4 },
			minacc = { x = -0.2, y = 0, z = -0.2 },
			maxacc = { x = 0.2, y = 0.1, z = 0.2 },
			minexptime = 6,
			maxexptime = 8,
			minsize = 10,
			maxsize = 12,
			collisiondetection = false,
			vertical = false,
			texture = "tnt_smoke.png",
			playername = player,
		})
	end
})

register_troll("t-blackparticles", {
	description = "Spawns much of black falling particles",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local pos1 = player:get_pos()
		minetest.add_particlespawner({
			amount = 10000,
			time = 60,
			minpos = { x = pos1.x + 5, y = pos1.y, z = pos1.z + 5 },
			maxpos = { x = pos1.x - 5, y = pos1.y, z = pos1.z - 5 },
			minvel = { x = -0, y = 0, z = -0 },
			maxvel = { x = 1, y = 1, z = 1 },
			minacc = { x = 1, y = 1, z = 1 },
			maxacc = { x = -1, y = -1, z = -1 },
			minexptime = 10,
			maxexptime = 20,
			minsize = 7,
			maxsize = 16,
			texture = "black.png",
			collisiondetection = true
		})
	end
})

register_troll("t-ban", {
	description = "Let the player think that he is banned",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.ban_player(player:get_player_name())
		minetest.after(0.5, function() minetest.unban_player_or_ip(player:get_player_name()) end)
	end
})

register_troll("t-hp", {
	description = "remove 2 hp from a player",
	func = function(_, player, amount)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_hp(player:get_hp() - 2)
	end
})

register_troll("t-error", {
	description = "Send an Error message to the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		minetest.kick_player(player:get_player_name(), "There was an error with your Client. Please reconnect.")
	end
})

register_troll("t-black", {
	description = "The player see 20 seconds only black",
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
			alignment     = { x = 0, y = 0 }, -- center aligned
			scale         = { x = 4000, y = 2000 }, -- covered late
			number        = 0xD61818,
		})

		minetest.after(20, function() player:hud_remove(idx) end)
	end
})

register_troll("t-freeze", {
	description = "the player is freezed",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 0,
			jump = 5.0,
			gravity = 0
		})
	end,
})

register_troll("t-unfreeze", {
	description = "unfreeze a player or stop t-nogravity",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 1,
			jump = 1,
			gravity = 1
		})
	end,
})

register_troll("t-nogravity", {
	description = "the player has low gravity",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		player:set_physics_override({
			speed = 1,
			jump = 5.0,
			gravity = 0.05
		})
	end,
})

register_troll("t-teleport", {
	description = "the player got a random teleport",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local newpos = player:get_pos()
		newpos.x = newpos.x + math.random(10, 20)
		newpos.z = newpos.z + math.random(10, 20)
		player:set_pos(newpos)
	end,
})

register_troll("t-jail", {
	description = "A jail is building at the players position",
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
	description = "the player is in a lava block",
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

register_troll("t-mob", {
	params = "<player> <mob> <amount>",
	description = "Spawns a given amount of mobs at the players position args: <player> <mob> <amount>",
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
	description = "the player go down 5 blocks in a hole",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end

		local newpos = vector.round(player:get_pos())
		for i = 1, 5 do
			newpos.y = newpos.y - 1
			minetest.set_node(newpos, { name="air" })
		end
	end,
})

register_troll("t-msg", {
	params = "<from> <to> <msg>",
	description = "Send a MSG from another player",
	func = function(name, params)
		local from, to, msg = params:match("^(%S+)%s(%S+)%s(.+)$")
		if not msg then return "syntax error.  usage: /t-msg <from> <to> <msg>" end
		minetest.chat_send_player(to, "PM from " .. from .. ": " .. msg)
	end,
})

register_troll("t-diamond", {
	description = "Spawns much of diamonds arround the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local pos1 = player:get_pos()
		minetest.add_particlespawner({
			amount = 50,
			time = 60,
			minpos = { x = pos1.x - 15, y = pos1.y, z = pos1.z - 15 },
			maxpos = { x = pos1.x + 15, y = pos1.y, z = pos1.z + 15 },
			minvel = { x = 0.2, y = 0.2, z = 0.2 },
			maxvel = { x = 0.4, y = 0.8, z = 0.4 },
			minacc = { x = -0.2, y = 0, z = -0.2 },
			maxacc = { x = 0.2, y = 0.1, z = 0.2 },
			minexptime = 6,
			maxexptime = 8,
			minsize = 10,
			maxsize = 10,
			collisiondetection = true,
			vertical = false,
			texture = "default_diamond.png",
			playername = player,
		})
	end
})

register_troll("t-shit", {
	description = "Spawns much of shit arround the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local pos1 = player:get_pos()
		minetest.add_particlespawner({
			amount = 200,
			time = 60,
			minpos = { x = pos1.x - 15, y = pos1.y, z = pos1.z - 15 },
			maxpos = { x = pos1.x + 15, y = pos1.y, z = pos1.z + 15 },
			minvel = { x = 0.2, y = 0.2, z = 0.2 },
			maxvel = { x = 0.4, y = 0.8, z = 0.4 },
			minacc = { x = -0.2, y = 0, z = -0.2 },
			maxacc = { x = 0.2, y = 0.1, z = 0.2 },
			minexptime = 6,
			maxexptime = 8,
			minsize = 10,
			maxsize = 10,
			collisiondetection = true,
			vertical = false,
			texture = "shit.png",
			playername = player,
		})
	end
})

register_troll("t-eyes", {
	description = "Spawns much of eyes arround the player",
	func = function(_, params)
		local player = minetest.get_player_by_name(params)
		if not player then
			return
		end
		local pos1 = player:get_pos()
		minetest.add_particlespawner({
			amount = 150,
			time = 60,
			minpos = { x = pos1.x - 15, y = pos1.y, z = pos1.z - 15 },
			maxpos = { x = pos1.x + 15, y = pos1.y, z = pos1.z + 15 },
			minvel = { x = 0.2, y = 0.2, z = 0.2 },
			maxvel = { x = 0.4, y = 0.8, z = 0.4 },
			minacc = { x = -0.2, y = 0, z = -0.2 },
			maxacc = { x = 0.2, y = 0.1, z = 0.2 },
			minexptime = 20,
			maxexptime = 30,
			minsize = 10,
			maxsize = 20,
			collisiondetection = true,
			vertical = false,
			texture = "eye.png",
			playername = player,
		})
	end
})

register_troll("t-chat", {
	params = "<from> <msg>",
	description = "Send a MSG from another player",
	func = function(name, params)
		local from, msg = params:match("^(%S+)%s(.+)$")
		if not msg then return "syntax error.  usage: /t-msg <from> <to> <msg>" end
		minetest.chat_send_all("<"..from.."> "..msg)
	end,
})

register_troll("t-grant", {
	params = "<from> <to> <priv>",
	description = "The player thinks, that he got privs",
	func = function(name, params)
		local from, to, priv = params:match("^(%S+)%s(%S+)%s(.+)$")
		if not priv or not to or not from then return "syntax error.  usage: /t-grant <from> <to> <priv>" end
		minetest.chat_send_player(to, from.." granted you priviliges: "..priv)
	end,
})
