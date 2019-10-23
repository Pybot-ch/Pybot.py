----------------------
-- In The Name Of GOD |
----------------------
config = require "data/config"
utils = require "bot/utils"
tdbot = require "libs/tdbot"
serpent = require "serpent"

redis = require('redis')
db = redis.connect('127.0.0.1', 6379)


function vardump_text(text)
	local serpent_text = serpent.block(text, {comment=false})
	local text = string.gsub(serpent_text, "\n", "\n\r\n")
	return text
end

function sleep(n)
	os.execute("sleep "..n)
end

function dl_cb(arg, data)
end

function action_by_reply(arg, data)
		cmd = arg.cmd
		msg = arg.msg
		chat_id = msg.chat_id
		user_id = data.sender_user_id

		if cmd == "setowner" then
				setOwner(msg, user_id)
		elseif cmd == "promote" then
				promote(msg, user_id)
		elseif cmd == "demote" then
				demote(msg, user_id)
		elseif cmd == "silent" then
				silent(msg, user_id)
		elseif cmd == "unsilent" then
				unsilent(msg, user_id)
		elseif cmd == "kick" then
				kick(msg, user_id)
		elseif cmd == "id" then
				tdbot.sendText(chat_id, msg.id, "`" .. user_id .. "`", 0, 1, nil, 1, 'md', 0)
		elseif cmd == "ban" then
				ban(msg, user_id)
		elseif cmd == "unban" then
				unban(msg, user_id)
		elseif cmd == "delall" then
				delall(msg, user_id)
		elseif cmd == "warn" then
				warn(msg, user_id)
		elseif cmd == "unwarn" then
				unwarn(msg, user_id)
		elseif cmd == "reswarn" then
				resetWarns(msg, user_id)
		elseif cmd == "gban" then
				gban(msg, user_id)
		elseif cmd == "ungban" then
				ungban(msg, user_id)
		elseif cmd == "addadmin" then
				addAdmin(msg, user_id)
		elseif cmd == "remadmin" then
				remAdmin(msg, user_id)
		end
end

function action_by_user_id(arg, data)
		cmd = arg.cmd
		msg = arg.msg
		chat_id = msg.chat_id
		user_id = arg.id
		if not data.id then
				local text = getText(chat_id, "user_not_found")
				local text = text:format(user_id)
				return tdbot.sendText(chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
		end

		if cmd == "setowner" then
				setOwner(msg, user_id)
		elseif cmd == "promote" then
				promote(msg, user_id)
		elseif cmd == "demote" then
				demote(msg, user_id)
		elseif cmd == "silent" then
				silent(msg, user_id)
		elseif cmd == "unsilent" then
				unsilent(msg, user_id)
		elseif cmd == "kick" then
				kick(msg, user_id)
		elseif cmd == "whois" then
				whois(msg, data)
		elseif cmd == "ban" then
				ban(msg, user_id)
		elseif cmd == "unban" then
				unban(msg, user_id)
		elseif cmd == "delall" then
				delall(msg, user_id)
		elseif cmd == "warn" then
				warn(msg, user_id)
		elseif cmd == "unwarn" then
				unwarn(msg, user_id)
		elseif cmd == "reswarn" then
				resetWarns(msg, user_id)
		elseif cmd == "gban" then
				gban(msg, user_id)
		elseif cmd == "ungban" then
				ungban(msg, user_id)
		elseif cmd == "addadmin" then
				addAdmin(msg, user_id)
		elseif cmd == "remadmin" then
				remAdmin(msg, user_id)
		end

end

function action_by_username(arg, data)
		cmd = arg.cmd
		msg = arg.msg
		chat_id = msg.chat_id
		username = arg.username

		if not data.id then
				local text = getText(chat_id, "user_not_found")
				local text = text:format("@" .. username)
				return tdbot.sendText(chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
		end
		user_id = data.id

		if cmd == "setowner" then
				setOwner(msg, user_id)
		elseif cmd == "promote" then
				promote(msg, user_id)
		elseif cmd == "demote" then
				demote(msg, user_id)
		elseif cmd == "silent" then
				silent(msg, user_id)
		elseif cmd == "unsilent" then
				unsilent(msg, user_id)
		elseif cmd == "kick" then
				kick(msg, user_id)
		elseif cmd == "res" then
				res(msg, data)
		elseif cmd == "ban" then
				ban(msg, user_id)
		elseif cmd == "unban" then
				unban(msg, user_id)
		elseif cmd == "delall" then
				delall(msg, user_id)
		elseif cmd == "warn" then
				warn(msg, user_id)
		elseif cmd == "unwarn" then
				unwarn(msg, user_id)
		elseif cmd == "reswarn" then
				resetWarns(msg, user_id)
		elseif cmd == "gban" then
				gban(msg, user_id)
		elseif cmd == "ungban" then
				ungban(msg, user_id)
		elseif cmd == "addadmin" then
				addAdmin(msg, user_id)
		elseif cmd == "remadmin" then
				remAdmin(msg, user_id)
		end
end


tdbot.getMe(function (arg, data)
							bot = data
						end)

tdbot.searchPublicChat(config.api_username, function (arg, data)
																								if not data.id then
																										os.exit()
																								end
																								api = data
																								tdbot.sendBotStartMessage(api.id, api.id, 'start')
																						end)

function onUpdate(data)
	if (data._ == "updateNewMessage") then
		msg = data.message
		if msg.date < os.time() - 60 then -- Old Message
				return false
		end

		if msg.sender_user_id == bot.id then
				return false
		end

		db:incr(hash .. ":user_msgs:" .. msg.chat_id .. ":user:" .. msg.sender_user_id)
		db:incr(hash .. ":chat_msgs:" .. msg.chat_id)
		db:incr(hash .. ":bot_msgs")

		msg.chat_type = getChatType(msg.chat_id)
		if msg.chat_type == "pv" then

				if isGBanned(msg.sender_user_id) then
						tdbot.blockUser(msg.sender_user_id)
				end
				-- Start AntiFlood Pv
				h = hash .. ":msgs:pv:" .. msg.sender_user_id
				msgs = tonumber(db:get(h) or 0)
				max_num = 5
				time_check = 5
				if msgs > max_num then
						blockUser(msg.sender_user_id)
						local text = getText(msg.chat_id, 'flooder_banned')
						tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						db:del(h)
						return deleteMsg(msg.chat_id, msg.id)
				else
						db:setex(h, time_check, msgs + 1)
				end
				-- End AntiFlood PV
		else

				-- Start MsgCheck

				-- Check If Is Bot's Group
				if not db:sismember(hash .. ":groups", msg.chat_id) then
						if isAdmin(msg.sender_user_id) then
								db:del(hash .. ":expire_warn:" .. msg.chat_id)
								if not (isCmd(msg.content.text or "", "add") or text == "افزودن") then
										tdbot.sendText(msg.chat_id, msg.id, "Please Add Group First.", 0, 1, nil, 1, 'md', 0)
								end
						else
								tdbot.sendText(msg.chat_id, msg.id, "There Is Not One Of My Groups.", 0, 1, nil, 1, 'md', 0)
								leaveChat(msg.chat_id)
						end
				end

				-- Check Group Expire
				if not db:get(hash .. ":expire:" .. msg.chat_id) then
						if not isChargeCmd(msg) and not botAdded(msg) then
								if not db:get(hash .. ":expire_warn:" .. msg.chat_id) then
										db:set(hash .. ":expire_warn:" .. msg.chat_id, true)
										text = getText(msg.chat_id, "expire_1")
										text2 = getText(msg.chat_id, "expire_2")
										text2 = text2:format(msg.chat_id, msg.chat_id, msg.chat_id)
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
										tdbot.sendText(config.owner, msg.id, text2, 0, 1, nil, 1, 'md', 0)
										return false
								end
						end
				else
						if tonumber(db:ttl(hash .. ":expire:" .. msg.chat_id)) / 86400 < 1 then
								if not db:get(hash .. ":expire_warn:" .. msg.chat_id) then
										local text = getText(msg.chat_id, "expire_3")
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
										db:setex(hash .. ":expire_warn:" .. msg.chat_id, 3600, true)
								end
						end
				end

				if msg.content._ == "messageChatAddMembers" or msg.content._ == "messageChatJoinByLink" then
						if isLock(msg.chat_id, "gp_send_welc") and db:get(hash .. ":gp_welcome_text:" .. msg.chat_id) then
								sendWelcMsg(msg)
						end
				end

				if not isMod(msg.chat_id, msg.sender_user_id) then

						if isBanned(msg.chat_id, msg.sender_user_id) or isGBanned(msg.sender_user_id) then
								kickChatMember(msg.chat_id, msg.sender_user_id)
						end

						-- Check Is Mute
						if isSilent(msg.chat_id, msg.sender_user_id) then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- AntiFlood
						h = hash .. ":msgs:" .. msg.chat_id .. ":" .. msg.sender_user_id
						msgs = tonumber(db:get(h) or 0)
						max_num = tonumber(db:get(hash .. ":flood_num:" .. msg.chat_id) or 5)
						time_check = tonumber(db:get(hash .. ":flood_time:" .. msg.chat_id) or 2)
						if msgs > max_num then
								kickChatMember(msg.chat_id, msg.sender_user_id)
								db:sadd(hash ..":banneds:" .. msg.chat_id, msg.sender_user_id)
								local text = getText(msg.chat_id, 'flooder_kicked')
								text = text:format(msg.sender_user_id)
								sendMention(msg.chat_id, msg.id, text, msg.sender_user_id)
								db:del(h)
						else
								db:setex(h, time_check, msgs + 1)
						end

						text = (msg.content.text or msg.content.caption or ""):lower()

						if isLock(msg.chat_id, "auto_lock") then
							local sv = {hour=tonumber(os.date("%H")), minute=tonumber(os.date("%M"))}
							local al = {
									start = {
											hour = tonumber(getAutoLock(msg.chat_id, "start_hour")),
											minute = tonumber(getAutoLock(msg.chat_id, "start_minute"))
									},
									end_ = {
											hour = tonumber(getAutoLock(msg.chat_id, "end_hour")),
											minute = tonumber(getAutoLock(msg.chat_id, "end_hour"))
									}
							}
							-- start = 12, end = 7, time = 6
							if sv.hour >= al.start.hour and sv.minute <= al.end_.hour then
									if sv.minute >= al.start.minute and sv.minute <= al.end_.minute then
											deleteMsg(msg.chat_id, msg.id)
									end
							end
						end


						-- MuteAll
						if isLock(msg.chat_id, "all") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock Inline [Via Bot]
						if msg.via_bot_user_id ~= 0 and isLock(msg.chat_id, "inline") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Sticker
						if msg.content._ == "messageSticker" and isLock(msg.chat_id, "sticker") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock Game
						if msg.content._ == "messageGame" and isLock(msg.chat_id, "game") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Gif
						if msg.content._ == "messageAnimation" and isLock(msg.chat_id, "gif") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Contact
						if msg.content._ == "messageContact" and isLock(msg.chat_id, "contact") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Location
						if msg.content._ == "messageLocation" and isLock(msg.chat_id, "location") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Photo
						if msg.content._ == "messagePhoto" and isLock(msg.chat_id, "photo") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Audio
						if msg.content._ == "messageAudio" and isLock(msg.chat_id, "audio") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Voice
						if msg.content._ == "messageVoice" and isLock(msg.chat_id, "voice") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Video
						if msg.content._ == "messageVideo" and isLock(msg.chat_id, "video") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute VideoNote
						if msg.content._ == "messageVideoNote" and isLock(msg.chat_id, "video_note") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Document
						if msg.content._ == "messageDocument" and isLock(msg.chat_id, "document") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Mute Text
						if msg.content._ == "messageText" and isLock(msg.chat_id, "text") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock Forward
						if msg.forward_info and isLock(msg.chat_id, "forward") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock Bots
						if msg.content._ == "messageChatAddMembers" and isLock(msg.chat_id, 'bots') then
								for k, v in pairs(msg.content.member_user_ids) do
										tdbot.getUser(v, function (arg, data)
																				if ((data.type._ == "userTypeBot" and isLock(msg.chat_id, 'bots'))
																				 		or (isBanned(msg.chat_id, v) or isGBanned(v))) and not isMod(msg.chat_id, msg.sender_user_id) then
																							kickChatMember(msg.chat_id, v)
																				end
																		 end)
								end
						end
						-- Lock Service
						if isLock(msg.chat_id, "service") then
								if msg.content._ == "messageChatDeleteMember" or msg.content._ == "messageChatAddMembers" or msg.content._ == "messageChatJoinByLink" then
											return deleteMsg(msg.chat_id, msg.id)
								end
						end

						text = (msg.content.text or msg.content.caption or ""):lower()

						-- Lock Tag [@]
						if text:match("@") and isLock(msg.chat_id, "tag") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock HashTag [#]
						if text:match("#") and isLock(msg.chat_id, "htag") then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Lock Telegram Link
						if text:match("telegram.me") or text:match("t.me") or text:match("t.dog")
							 and isLock(msg.chat_id, "tg_link") then
									return deleteMsg(msg.chat_id, msg.id)
						end

						if text:match('[a-z]') and isLock(msg.chat_id, 'english') then
								return deleteMsg(msg.chat_id, msg.id)
						end

						-- Check Filtered Words
						fw = db:smembers(hash .. ":filters:" .. msg.chat_id)
						for k, v in pairs(fw) do
								if text:find(v) then
										return deleteMsg(msg.chat_id, msg.id)
								end
						end

				end
				-- End MsgCheck
		end
		if msg.content._ == "messageText" then
				text = msg.content.text
				text_ = text:lower()
				cl = getChatCmdLang(msg.chat_id)
				if ((isCmd(text, "ping") and cl == "en") or (text == "ربات" and cl == "fa")) then
						local text = getText(msg.chat_id, "ping")
						tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
				end

				-- Start Join
				if (text_:match("^[#/!]?join (.*)$") or text:match("^جوین شو (.*)$")) and isAdmin(msg.sender_user_id) then
						local link = text_:match("^[#/!]?join (.*)$") or text:match("^جوین شو (.*)$")
						local is_link = (link:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or
											 			 link:match("^([https?://w]*.?t.me/joinchat/%S+)$"))
						if is_link then
								tdbot.importChatInviteLink(link)
						end
				end
				-- End Join

				-- Start JoinTo
				if text_:match("^[#/!]?jointo (-%d+)$") and isOwner(msg.sender_user_id) then
						local chat_id = tonumber(text_:match("^[#/!]?jointo (-%d+)$"))
						tdbot.addChatMember(chat_id, msg.sender_user_id, 0)
				end
				-- End JoinTo

				-- Start Leave2
				if text_:match("^[#/!]?leave (-%d+)$") and isAdmin(msg.sender_user_id) then
						local chat_id = tonumber(text_:match("^[#/!]?leave (-%d+)$"))
						leaveChat(chat_id)
				end
				-- End Leave2

				-- Start GBan
				if (isCmd(text, "gban") or text == "مسدود همگانی"  and cl == "fa")
						and isAdmin(msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
							tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="gban"})
				end

				if (text_:match("^[#/!]?gban (%d+)$") or text:match("^مسدود همگانی (%d+)$"))
					 and isAdmin(msg.sender_user_id) then
								id = text:match("^[#/!]?gban (%d+)$") or text_:match("^مسدود همگانی (%d+)$")
								tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="gban"})
				end

				if (text_:match("^[#/!]?gban @(.*)$") or text:match("^مسدود همگانی @(.*)$"))
				 	 and isAdmin(msg.sender_user_id) then
								username = text_:match("^[#/!]?gban @(.*)$") or text:match("^مسدود همگانی @(.*)$")
								tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="gban"})
				end
				-- End GBan

				-- Start UnGBan
				if (isCmd(text, "ungban") or text == "حذف مسدود همگانی") and isAdmin(msg.sender_user_id)
				   and msg.reply_to_message_id ~= 0 then
							tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="ungban"})
				end

				if (text_:match("^[#/!]?ungban (%d+)$") or text:match("^حذف مسدود همگانی (%d+)$"))
					 and isAdmin(msg.sender_user_id) then
								id = text:match("^[#/!]?ungban (%d+)$") or text_:match("^حذف مسدود همگانی (%d+)$")
								tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="ungban"})
				end

				if (text_:match("^[#/!]?ungban @(.*)$") or text:match("^حذف مسدود همگانی @(.*)"))
				 	 and isAdmin(msg.sender_user_id) then
								username = text_:match("^[#/!]?ungban @(.*)$") or text:match("^حذف مسدود همگانی @(.*)")
								tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="ungban"})
				end
				-- End UnGBan

				-- Start AddAdmin
				if (isCmd(text, "addadmin") or text == "ادمین") and isSudo(msg.sender_user_id)
				 	 and msg.reply_to_message_id ~= 0 then
							tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="addadmin"})
				end

				if (text_:match("^[#/!]?addadmin (%d+)$") or text:match("^ادمین (%d+)$"))
					 and isSudo(msg.sender_user_id) then
								id = text:match("^[#/!]?addadmin (%d+)$") or text_:match("^ادمین (%d+)$")
								tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="addadmin"})
				end

				if (text_:match("^[#/!]?addadmin @(.*)$") or text:match("^ادمین @(.*)$"))
				   and isSudo(msg.sender_user_id) then
								username = text_:match("^[#/!]?addadmin @(.*)$") or text:match("^ادمین @(.*)$")
								tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="addadmin"})
				end
				-- End AddAdmin

				-- Start RemAdmin
				if (isCmd(text, "remadmin") or text == "حذف ادمین") and isSudo(msg.sender_user_id)
					 and msg.reply_to_message_id ~= 0 then
							tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="remadmin"})
				end

				if (text_:match("^[#/!]?remadmin (%d+)$") or text:match("^حذف ادمین (%d+)$"))
					 and isSudo(msg.sender_user_id) then
								id = text:match("^[#/!]?remadmin (%d+)$") or text_:match("^حذف ادمین (%d+)$")
								tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="remadmin"})
				end

				if (text_:match("^[#/!]?remadmin @(.*)$") or text:match("^حذف ادمین @(.*)$"))
				 	 and isSudo(msg.sender_user_id) then
								username = text_:match("^[#/!]?remadmin @(.*)$") or text:match("^حذف ادمین @(.*)$")
								tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="remadmin"})
				end
				-- End RemAdmin

				-- Start AdminsList
				if (isCmd(text, "admins list") or text == "لیست ادمین ها") and isAdmin(msg.sender_user_id) then
						list = db:smembers(hash .. ":admins")
						if #list < 1 then
								text = getText(msg.chat_id, "al_empty")
						else
								text = getText(msg.chat_id, "admins_list")
								for k, v in pairs(list) do
										text = text .. string.format("\n*%d*. `%d`", k, v)
								end
						end
						tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
				end
				-- End AdminsList

				-- Start GBansList
				if (isCmd(text, "gbans list") or text == "کاربران مسدود همگانی") and isAdmin(msg.sender_user_id) then
						list = db:smembers(hash .. ":gbans")
						if #list < 1 then
								text = getText(msg.chat_id, "gbl_empty")
						else
								text = getText(msg.chat_id, "gbans_list")
								for k, v in pairs(list) do
										text = text .. string.format("\n*%d*. `%d`", k, v)
								end
						end
						tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
				end
				-- End GBansList

				-- If Is Group/SuperGroup # Start chat_type
				if msg.chat_type == "sgp" or msg.chat_type == "gp" then

						-- Start Add
						if (isCmd(text, "add") or text == "افزودن") and isAdmin(msg.sender_user_id) then
								if db:sismember(hash .. ":groups", msg.chat_id) then
									 	text = getText(msg.chat_id, "is_added")
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
								else
										db:sadd(hash .. ":groups", msg.chat_id)
										db:set(hash .. ":owner:" .. msg.chat_id, msg.sender_user_id)
										text = getText(msg.chat_id, "add")
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
										db:setex(hash .. ":expire:" .. msg.chat_id, 180, true)
										function checkExpire()
										    if not db:get(hash .. ":expire:" .. msg.chat_id) then
										        leaveChat(msg.chat_id)
										    end
										end
										tdbot.setAlarm(181, checkExpire)
								end
						end
						-- End Add

						-- Start Rem
						if (isCmd(text, "rem") or text == "حذف گروه") and isAdmin(msg.sender_user_id) then
								if db:sismember(hash .. ":groups", msg.chat_id) then
										db:srem(hash .. ":groups", msg.chat_id)
										db:del(hash .. ":expire:" .. msg.chat_id)
										text = getText(msg.chat_id, "rem")
								else
										text = getText(msg.chat_id, "not_added")
								end
								tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						end
						-- End Rem

						-- Start SetOwner
						if ((isCmd(text, "setowner") and cl == "en") or (text == "تنظیم مالک"  and cl == "fa"))
						 			and isAdmin(msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
										tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="setowner"})
						end

						if ((text_:match("^[#/!]?setowner (%d+)$") and cl =="en")
						 		or (text:match("^تنظیم مالک (%d+)$") and cl == "fa")) and isAdmin(msg.sender_user_id) then
										id = text_:match("^[#/!]?setowner (%d+)$") or text:match("^تنظیم مالک (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="setowner"})
						end

						if ((text_:match("^[#/!]?setowner @(.*)$") and cl =="en")
								or (text:match("^تنظیم مالک @(.*)$") and cl == "fa")) and isAdmin(msg.sender_user_id) then
										username = text_:match("^[#/!]?setowner @(.*)$") or text:match("^تنظیم مالک @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="setowner"})
						end
						-- End SetOwner

						-- Start Promote
						if ((isCmd(text, "promote") and cl == "en") or (text == "مدیر"  and cl == "fa"))
						 		and isOwner(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="promote"})
						end

						if ((text_:match("^[#/!]?promote (%d+)$") and cl =="en")
						 		or (text:match("^مدیر (%d+)$") and cl == "fa"))
							 and isOwner(msg.chat_id, msg.sender_user_id) then
										id = text:match("^مدیر (%d+)$") or text_:match("^[#/!]?promote (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="promote"})
						end

						if ((text_:match("^[#/!]?promote @(.*)$") and cl =="en")
								or (text:match("^مدیر @(.*)$") and cl == "fa")) and isOwner(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?promote @(.*)$") or text:match("^مدیر @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="promote"})
						end
						-- End Promote

						-- Start Demote
						if ((isCmd(text, "demote") and cl == "en") or (text == "حذف مدیر"  and cl == "fa"))
								and isOwner(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="demote"})
						end

						if ((text_:match("^[#/!]?demote (%d+)$") and cl =="en")
								or (text:match("^حذف مدیر (%d+)$") and cl == "fa"))
							 and isOwner(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?demote (%d+)$") or text:match("^حذف مدیر (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="demote"})
						end

						if ((text_:match("^[#/!]?demote @(.*)$") and cl =="en")
							 or (text:match("^حذف مدیر @(.*)$") and cl == "fa"))
							 and isOwner(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?demote @(.*)$") or text:match("^حذف مدیر @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="demote"})
						end
						-- End Demote

						-- Start Pin/Unpin
						if ((isCmd(text, "pin") and cl == "en") or (text == "سنجاق" and cl == "fa"))
						 	 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0
							 and msg.chat_type == "sgp" then
									tdbot.pinChannelMessage(msg.chat_id, msg.reply_to_message_id)
						end

						if ((isCmd(text, "unpin") and cl == "en") or (text == "حذف سنجاق" and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.chat_type == "sgp" then
									tdbot.unpinChannelMessage(msg.chat_id)
						end
						-- End Pin/Unpin

						-- Start Silen
						if ((isCmd(text, "silent") and cl == "en") or (text == "سکوت"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="silent"})
						end

						if ((text_:match("^[#/!]?silent (%d+)$") and cl =="en")
								or (text:match("^سکوت (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?silent (%d+)$") or text:match("^سکوت (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="silent"})
						end

						if ((text_:match("^[#/!]?silent @(.*)$") and cl =="en")
								or (text:match("^سکوت @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?silent @(.*)$") or text:match("^سکوت @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="silent"})
						end
						-- End Silet

						-- Start UnSilent
						if ((isCmd(text, "unsilent") and cl == "en") or (text == "حذف سکوت"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="unsilent"})
						end

						if ((text_:match("^[#/!]?unsilent (%d+)$") and cl =="en")
								or (text:match("^حذف سکوت (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?unsilent (%d+)$") or text:match("^حذف سکوت (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="unsilent"})
						end

						if ((text_:match("^[#/!]?unsilent @(.*)$") and cl =="en")
								or (text:match("^حذف سکوت @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?unsilent @(.*)$") or text:match("^حذف سکوت @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="unsilent"})
						end
						-- End UnSilent

						-- Start Kick
						if ((isCmd(text, "kick") and cl == "en") or (text == "اخراج"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="kick"})
						end

						if ((text_:match("^[#/!]?kick (%d+)$") and cl =="en")
								or (text:match("^اخراج (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?kick (%d+)$") or text:match("^اخراج (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="kick"})
						end

						if ((text_:match("^[#/!]?kick @(.*)$") and cl =="en")
								or (text:match("^اخراج @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?kick @(.*)$") or text:match("^اخراج @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="kick"})
						end
						-- End Kick

						-- Start Ban
						if ((isCmd(text, "ban") and cl == "en") or (text == "مسدود"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="ban"})
						end

						if ((text_:match("^[#/!]?ban (%d+)$") and cl =="en")
								or (text:match("^مسدود (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?ban (%d+)$") or text:match("^مسدود (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="ban"})
						end

						if ((text_:match("^[#/!]?ban @(.*)$") and cl =="en")
								or (text:match("^مسدود @(.*)$") and cl == "fa")) and
							 isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?ban @(.*)$") or text:match("^مسدود @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="ban"})
						end
						-- End Ban

						-- Start Unban
						if ((isCmd(text, "unban") and cl == "en") or (text == "حذف مسدودیت"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="unban"})
						end

						if ((text_:match("^[#/!]?unban (%d+)$") and cl =="en")
								or (text:match("^حذف مسدودیت (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?unban (%d+)$") or text:match("^حذف مسدودیت (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="unban"})
						end

						if ((text_:match("^[#/!]?unban @(.*)$") and cl =="en")
								or (text:match("^حذف مسدودیت @(.*)$") and cl == "fa")) and
							 isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?unban @(.*)$") or text:match("^حذف مسدودیت @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="unban"})
						end
						-- End Unban

						-- Start res
						if ((text_:match("^[#/!]?res @(.*)$") and cl =="en")
								or (text:match("^کاربری @(.*)$") and cl == "fa")) and
							 isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?res @(.*)$") or text:match("^کاربری @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="res"})
						end
						-- End res

						-- Start ID
						if ((isCmd(text, "id") and cl == "en") or (text == "آیدی"  and cl == "fa"))
							 and msg.reply_to_message_id == 0 then
									function getPro(arg, data)
											msgs = db:get(hash .. ":user_msgs:" .. msg.chat_id .. ":user:" .. msg.sender_user_id)
											local text = getText(msg.chat_id, "id")
											local text = text:format(msg.sender_user_id, msg.chat_id, msgs)
											if data.total_count > 1 then
													tdbot.sendPhoto(msg.chat_id, msg.id, data.photos[0].sizes[1].photo.persistent_id,
													 								nil, nil, 0, 0, text, 0, 0, 1, nil)
											else
													tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
											end
									end
									tdbot.getUserProfilePhotos(msg.sender_user_id, 0, 1, getPro)
						end
						-- End ID

						-- Start ID [reply]
						if ((isCmd(text, "id") and cl == "en") or (text == "آیدی"  and cl == "fa"))
							 and msg.reply_to_message_id ~= 0 then
										tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="id"})
						end
						-- End ID [reply]

						-- Start Whois
						if ((text_:match("^[#/!]?whois (%d+)$") and cl =="en")
								or (text:match("^شناسه (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?whois (%d+)$") or text:match("^شناسه (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="whois"})
						end
						-- End Whois

						-- Start GP Info
						if ((isCmd(text, "gpinfo") and cl == "en") or (text == "اطلاعات گروه"  and cl == "fa"))
						 	 and isMod(msg.chat_id, msg.sender_user_id) and msg.chat_type == "sgp" then
								function gpinfo(arg, data)
										local text = getText(msg.chat_id, "gpinfo")
										text = text:format(data.administrator_count, data.member_count, data.restricted_count, data.banned_count)
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
								end

								tdbot.getChannelFull(msg.chat_id, gpinfo)
						end
						-- End Gp Info

						-- Start Setlink
						if ((isCmd(text, "setlink") and cl == "en") or (text == "تنظیم لینک" and cl == "fa"))
						 	 and isMod(msg.chat_id, msg.sender_user_id) then
									db:set(hash .. ":wait_link:" .. msg.chat_id, true)
									local text = getText(msg.chat_id, "wait_link")
									tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						end
						if db:get(hash .. ":wait_link:" .. msg.chat_id) and isMod(msg.chat_id, msg.sender_user_id) then
								local is_link = (text_:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or
								 					 text_:match("^([https?://w]*.?t.me/joinchat/%S+)$"))
								if is_link then
										db:del(hash .. ":wait_link:" .. msg.chat_id)
										saveLink(msg, text)
								end
						end
						-- End Setlink

						-- Start GetLink
						if ((isCmd(text, "link") and cl == "en") or (text == "لینک" and cl == "fa")) then
								link = getLink(msg.chat_id)
								linkt = getText(msg.chat_id, "ns_link")
								if link ~= "" then
										linkt = getText(msg.chat_id, "link")
										linkt = linkt:format(link)
								end
								tdbot.sendText(msg.chat_id, msg.id, linkt, 0, 1, nil, 1, 'md', 0)
						end
						-- End GetLink

						-- Start SetRules
						if ((text:match("^[#/!]?[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)") and cl == "en")
						 		or (text:match("^تنظیم قوانین (.*)") and cl == "fa"))
 							 and isMod(msg.chat_id, msg.sender_user_id) then
									m = text:match("^[#/!]?[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)") or text:match("^تنظیم قوانین (.*)")
									saveRules(msg, m)
						end
						-- End SetRules

						-- Start SetWelcome
						if ((text:match("^[#/!]?[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)") and cl == "en")
							  or (text:match("^تنظیم خوش آمد گویی (.*)") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
									m = text:match("^[#/!]?[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)") or text:match("^تنظیم خوش آمد گویی (.*)")
									setWelcome(msg, m)
						end
						-- End SetWelcome

						-- Start GetRules
						if ((isCmd(text, "rules") and cl == "en") or (text == "قوانین" and cl == "fa")) then
								rules = getRules(msg.chat_id)
								r = getText(msg.chat_id, "ns_rules")
								if rules ~= "" then
										r = getText(msg.chat_id, "rules")
										r = r:format(rules)
								end
								tdbot.sendText(msg.chat_id, msg.id, r, 0, 1, nil, 1, 'html', 0)
						end
						-- End GetRules

						-- Start Filter
						if ((text_:match("^[#/!]?filter (.*)$") and cl =="en")
							  or (text:match("^فیلتر (.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										fw = text_:match("^[#/!]?filter (.*)$") or text:match("^فیلتر (.*)$")
										filter(msg.chat_id, fw)
						end
						-- End Filter

						-- Start UnFilter
						if ((text_:match("^[#/!]?unfilter (.*)$") and cl =="en")
								or (text:match("^حذف فیلتر (.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										fw = text_:match("^[#/!]?unfilter (.*)$") or text:match("^حذف فیلتر (.*)$")
										unfilter(msg.chat_id, fw)
						end
						-- End UnFilter

						-- Start Warn
						if ((isCmd(text, "warn") and cl == "en") or (text == "اخطار"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="warn"})
						end

						if ((text_:match("^[#/!]?warn (%d+)$") and cl =="en")
								or (text:match("^اخطار (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?warn (%d+)$") or text:match("^اخطار (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="warn"})
						end

						if ((text_:match("^[#/!]?warn @(.*)$") and cl =="en")
								or (text:match("^اخطار @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?warn @(.*)$") or text:match("^اخطار @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="warn"})
						end
						-- End Warn

						-- Start UnWarn
						if ((isCmd(text, "unwarn") and cl == "en") or (text == "حذف اخطار"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="unwarn"})
						end

						if ((text_:match("^[#/!]?unwarn (%d+)$") and cl =="en")
								or (text:match("^حذف اخطار (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?unwarn (%d+)$") or text:match("^حذف اخطار (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="unwarn"})
						end

						if ((text_:match("^[#/!]?unwarn @(.*)$") and cl =="en")
								or (text:match("^حذف اخطار @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?unwarn @(.*)$") or text:match("^حذف اخطار @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="unwarn"})
						end
						-- End UnWarn

						-- Start ResWarn
						if ((isCmd(text, "reset warn") and cl == "en") or (text == "بازنشانی اخطار"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="reswarn"})
						end

						if ((text_:match("^[#/!]?reset warn (%d+)$") and cl =="en")
								or (text:match("^بازنشانی اخطار (%d+)$") and cl == "fa"))
							and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?reset warn (%d+)$") or text:match("^بازنشانی اخطار (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="reswarn"})
						end

						if ((text_:match("^[#/!]?reset warn @(.*)$") and cl =="en")
								or (text:match("^بازنشانی اخطار @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?reset warn @(.*)$") or text:match("^بازنشانی اخطار @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="reswarn"})
						end
						-- End ResWarn

						-- Start Charge
						if ((text_:match("^[#/!]?charge (%d+)$") and cl == "en") or (text:match("^شارژ (%d+)$") and cl =="fa"))
						 		and isAdmin(msg.sender_user_id) then
									db:del(hash .. ":expire_warn:" .. msg.chat_id)
									m = text_:match("^[#/!]?charge (%d+)$") or text:match("^شارژ (%d+)$")
									db:setex(hash .. ":expire:" .. msg.chat_id, tonumber(m) * 86400, true)
									ex = getText(msg.chat_id, "charge")
									ex = ex:format(m)
									tdbot.sendText(msg.chat_id, msg.id, ex, 0, 1, nil, 1, 'md', 0)
						end
						-- End Charge

						-- Start Charge

						-- Start DelAll
						if ((isCmd(text, "delall") and cl == "en") or (text == "حذف پیام ها"  and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.reply_to_message_id ~= 0 then
									tdbot.getMessage(msg.chat_id, msg.reply_to_message_id, action_by_reply, {msg=msg, cmd="delall"})
						end

						if ((text_:match("^[#/!]?delall (%d+)$") and cl =="en")
								or (text:match("^حذف پیام ها (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										id = text_:match("^[#/!]?delall (%d+)$") or text:match("^حذف پیام ها (%d+)$")
										tdbot.getUser(id, action_by_user_id, {msg=msg, id=id, cmd="delall"})
						end

						if ((text_:match("^[#/!]?delall @(.*)$") and cl =="en")
								or (text:match("^حذف پیام ها @(.*)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										username = text_:match("^[#/!]?delall @(.*)$") or text:match("^حذف پیام ها @(.*)$")
										tdbot.searchPublicChat(username, action_by_username, {msg=msg, username=username, cmd="delall"})
						end
						-- End DellAll

						-- Start DelMyPms
						if ((isCmd(text, "delmypms") and cl == "en") or (text == "حذف پیام های من" and cl == "fa")) then
								tdbot.deleteMessagesFromUser(msg.chat_id, msg.sender_user_id)
								local text = getText(msg.chat_id, "delpms")
								tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						end
						-- End DelMyPms

						-- Start SetLang
						if ((text_:match("^[#/!]?setlang (.*)$") or text:match("^تنظیم زبان (.*)$"))
						 		and isMod(msg.chat_id, msg.sender_user_id)) then
									me = text_:match("^[#/!]?setlang (.*)$")
									mf = text:match("^تنظیم زبان (.*)$")
									if (me and me == "en") or (mf and mf == "انگلیسی") then
											setLang(msg, "en")
									elseif (me and me == "fa") or (mf and mf == "فارسی") then
											setLang(msg, "fa")
									end
						end
						-- End SetLang

						-- Start SetCmdLang
						if ((text_:match("^[#/!]?setcmdlang (.*)$") or text:match("^تنظیم زبان دستورات (.*)$"))
								and isMod(msg.chat_id, msg.sender_user_id)) then
									me = text_:match("^[#/!]?setcmdlang (.*)$")
									mf = text:match("^تنظیم زبان دستورات (.*)$")
									if (me and me == "en") or (mf and mf == "انگلیسی") then
											setCmdLang(msg, "en")
									elseif (me and me == "fa") or (mf and mf == "فارسی") then
											setCmdLang(msg, "fa")
									end
						end
						-- End SetCmdLang

						-- Start SetFloodTime
						if ((text_:match("^[#/!]?setfloodtime (%d+)$") and cl == "en") or
						 		(text:match("^تنظیم زمان رگباری (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
									m = text_:match("^[#/!]?setfloodtime (%d+)$") or text:match("^تنظیم زمان رگباری (%d+)$")
									m = tonumber(m)
									if m < 2 or m > 999 then
											text = getText(msg.chat_id, "ft_range")
									else
											db:set(hash .. ":flood_time:" .. msg.chat_id, m)
											text = getText(msg.chat_id, "floodtime")
											text = text:format(m)
									end
								tdbot.sendText(msg.chat_id, 0, text, 0, 1, nil, 1, 'md', 0)
						end
						-- End SetFloodTime

						-- Start SetFloodNum
						if ((text_:match("^[#/!]?setfloodnum (%d+)$") and cl == "en") or
								(text:match("^تنظیم مقدار رگباری (%d+)$") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
									m = text_:match("^[#/!]?setfloodnum (%d+)$") or text:match("^تنظیم مقدار رگباری (%d+)$")
									m = tonumber(m)
									if m < 2 or m > 30 then
											text = getText(msg.chat_id, "fn_range")
									else
											db:set(hash .. ":flood_num:" .. msg.chat_id, m)
											text = getText(msg.chat_id, "floodnum")
											text = text:format(m)
									end
								tdbot.sendText(msg.chat_id, 0, text, 0, 1, nil, 1, 'md', 0)
						end
						-- End SetFloodNum

						-- Start Clean [Deleted/BlockList/Bots/Members/Msgs] [BanList/Mods/Filters]
						if ((text_:match("^[#/!]?clean (.*)$") and cl == "en")
						 		or (text:match("^پاکسازی (.*)") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
								 	me = text_:match("^[#/!]?clean (.*)$")
									mf = text:match("^پاکسازی (.*)")
									if me == "deleted" or mf == "دلیت اکانت" then
											cleanDeleteds(msg)
									elseif me == "blocklist" or mf == "لیست سیاه" then
											cleanBlockList(msg)
									elseif me == "bots" or mf == "ربات ها" then
											cleanBots(msg)
									elseif me == "members" or mf == "اعضا" then
											cleanMembers(msg)
									elseif me == "msgs" or mf == "پیام ها" then
											cleanMsgs(msg)
									elseif me == "banlist" or mf == "مسدود ها" then
											db:del(hash ..":banneds:" .. msg.chat_id)
											local text = getText(msg.chat_id, "clean_banlist")
											tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
									elseif me == "mods" or mf == "مدیران" then
											db:del(hash ..":mods:" .. msg.chat_id)
											local text = getText(msg.chat_id, "clean_mods")
											tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
									elseif me == "filters" or mf == "کلمات فیلتر شده" then
											db:del(hash ..":filters:" .. msg.chat_id)
											local text = getText(msg.chat_id, "clean_banlist")
											tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
									elseif me == "silents" or mf == "کاربران ساکت" then
											db:del(hash ..":silents:" .. msg.chat_id)
											local text = getText(msg.chat_id, "clean_silents")
											tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
									elseif (me == "gbans" or mf == "کاربران مسدود همگانی") and isAdmin(msg.sender_user_id) then
											db:del(hash .. ":gbans")
											local text = getText(msg.chat_id, "clean_gbans")
											tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
									end
						end
						-- End Clean

						-- Start config
						if ((isCmd(text, "config") and cl == "en") or (text == "ارتقا ادمین ها" and cl == "fa"))
						and isOwner(msg.chat_id, msg.sender_user_id) then
								text = getText(msg.chat_id, "config")
								i = 0
								local function cfg_cb(arg, data)
										if data.members then
												for k, v in pairs(data.members) do
														i = i + 1
														text = text .. "\n*" .. i ..".* `" .. v.user_id .. "`"
														db:sadd(hash .. ":mods:" .. msg.chat_id, v.user_id)
												end
										end
										if data.total_count < 200 then
												tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
										else
												tdbot.getChannelMembers(msg.chat_id, 0, 200, "Administrators", "", cfg_cb)
										end
								end
								tdbot.getChannelMembers(msg.chat_id, 0, 200, "Administrators", "", cfg_cb)
						end
						-- End Config

						-- Start Invite Banneds
						if ((isCmd(text, "invite banneds") and cl == "en")
						 		or (text == "دعوت کاربران مسدود" and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) and msg.chat_type == "sgp" then
									inviteBanneds(msg)
						end
						-- End Invite Banneds

						-- Start SetName
						if ((text:match("^[#/!]?[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)") and cl == "en")
						 		or (text:match("^تنظیم نام (.*)") and cl == "fa"))
							 and isMod(msg.chat_id, msg.sender_user_id) then
										local title = text:match("^[#/!]?[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)")
										 							or text:match("^تنظیم نام (.*)")
										tdbot.changeChatTitle(msg.chat_id, title)
										local text = getText(msg.chat_id, "setname")
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						end
						-- End SetName

						-- Start Del
						if ((text_:match("^[#/!]?del (%d+)$") and cl == "en")
						 		or (text:match("^حذف (%d+)%") and cl == "fa"))
								and isMod(msg.chat_id, msg.sender_user_id) then
										m = text_:match("^[#/!]?del (%d+)$") or text:match("^حذف (%d+)%")
										m = tonumber(m)
										if m < 1 or m > 1000 then
												text = getText(msg.chat_id, "del_limit")
												tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
										else
												delMessages(msg, m)
										end

						end
						-- End del

						-- Start Leave
						if (isCmd(text, "leave") or text == "ترک گروه") and isAdmin(msg.sender_user_id) then
									leaveChat(msg.chat_id)
						end
						-- End Leave

						if ((text_:match("^[#/!]?autolock (%S+) (%S+) (%d+)$") and cl == "en")
						 		or (text:match("^قفل خودکار (%S+) (%S+) (%d+)$") and cl == "fa"))
						 	 and isMod(msg.chat_id, msg.sender_user_id) then
								if cl == "en" then
									 m = {text_:match("^[#/!]?autolock (%S+) (%S+) (%d+)$")}
								else
									 m = {text:match("^قفل خودکار (%S+) (%S+) (%d+)$")}
								end
								time, act, val = m[1], m[2], tonumber(m[3])
								if time == "start" or time == "شروع" then
										h = "start_%s"
								elseif time == "end" or time == "پایان" then
										h = "end_%s"
								else return false
								end
								if act == "hour" or act == "ساعت" then
										if val > 23 or val < 0 then
												return tdbot.sendText(msg.chat_id, msg.id, getText(msg.chat_id, "al_hour_range"), 0, 1, nil, 1, 'md', 0)
										end
										h = h:format("hour")
								elseif act == "minute" or act == "دقیقه" then
										if val > 59 or val < 0 then
												return tdbot.sendText(msg.chat_id, msg.id, getText(msg.chat_id, "al_min_range"), 0, 1, nil, 1, 'md', 0)
										end
										h = h:format("minute")
								else return false
								end
								setAutoLock(msg.chat_id, h, val)
								tdbot.sendText(msg.chat_id, msg.id, "✔️", 0, 1, nil, 1, 'md', 0)
						end

						-- AutoLock
						if ((isCmd(text, "autolock") and cl == "en") or (text == "قفل خودکار" and cl == "fa"))
						 	 and isMod(msg.chat_id, msg.sender_user_id) then
								 	text = getText(msg.chat_id, "autolock")
									status = isLock(msg.chat_id, "auto_lock") and "✔️" or "✖️"
									start = getAutoLock(msg.chat_id, "start_hour") .. ":" .. getAutoLock(msg.chat_id, "start_minute")
									end_ = getAutoLock(msg.chat_id, "end_hour") .. ":" .. getAutoLock(msg.chat_id, "end_minute")
									text = text:format(status, start, end_)
									tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
						end

						if ((isCmd(text, "help") and cl == "en") or (text == "راهنما" and cl == "fa"))
						 		and isMod(msg.chat_id, msg.sender_user_id) then
										local text = getHelpText(msg.chat_id)
										tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'html', 0)
						end

						-- Start Menu
						if ((isCmd(text, "menu") and cl == "en") or (text == "منو" and cl == "fa"))
						 		and isMod(msg.chat_id, msg.sender_user_id) then
									function menu(arg, data)
											if data.inline_query_id then
													tdbot.sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id)
											else
													local text = getText(msg.chat_id, "helper_off")
													tdbot.sendText(msg.chat_id, 0, text, 0, 1, nil, 1, 'md', 0)
											end
									end
									tdbot.getInlineQueryResults(api.id, msg.chat_id, 0, 0,
									 														"menu " .. msg.chat_id .. " " .. msg.sender_user_id, 0, menu)
						end
						-- End Menu

				end -- end chat_type

		end -- end messageText

	end -- end updateNewMessage
end

function tdbot_update_callback (data)
		--[[co = coroutine.create(function ()
															local ok, res = xpcall(onUpdate, debug.traceback, data)
															if not ok then
																	text = "*SomeThing Wrong!*\n`" .. res .. "`"
																	tdbot.sendText(config.log, 0, text, 0, 1, nil, 1, 'md', 0)
															end
													end)
		coroutine.resume(co)]]
		onUpdate(data)
end -- end update's function
