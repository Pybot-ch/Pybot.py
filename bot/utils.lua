-- In The Name Of GOD
hash = "GroupHelper"

function len(text)
    return string.len(tostring(text))
end

function isCmd(text, cmd)
    text = text:lower()
		return text:match("^[#/!]?".. cmd .. "$")
end

function checkMarkdown(text)
		str = text
		if str:match('_') then
			output = str:gsub('_',[[\_]])
		elseif str:match('*') then
			output = str:gsub('*','\\*')
		elseif str:match('`') then
			output = str:gsub('`','\\`')
		else
			output = str
		end
	return output
end

function isAliF(user)
    return user == config.owner
end

function isSudo(user)
    if isAliF(user) then
        return true
    end
    for k, v in pairs(config.sudoers) do
        if v == user then
            return true
        end
    end
    return false
end

function isAdmin(user)
    if isSudo(user) then
        return true
    end

    if db:sismember(hash .. ":admins", user) then
        return true
    end

    return false
end

function isOwner(chat, id)
    get = db:get(hash .. ":owner:" .. chat)
    if isAdmin(id) then
        return true
    end
    if get and tonumber(get) == id then
        return true
    end
    return false
end

function isMod(chat, id)
    if isOwner(chat, id) then
        return true
    end
    if db:sismember(hash .. ":mods:" .. chat, id) then
        return true
    end
    return false
end

function isBanned(chat, user)
    if db:sismember(hash ..":banneds:" .. chat, user) then
        return true
    end
    return false
end

function isGBanned(user)
    if db:sismember(hash .. ":gbans", user) then
        return true
    end
    return false
end

function isSilent(chat, user)
    if db:sismember(hash .. ":silents:" .. chat, user) then
        return true
    end
    return false
end

function getChatLang(chat_id)
    h = hash .. ":lang:" .. chat_id
    h = db:get(h)
    if h then
        return h
    end
    return "en"
end

function getChatCmdLang(chat_id)
    h = hash .. ":cmd_lang:" .. chat_id
    h = db:get(h)
    if h then
        return h
    end
    return "en"
end

texts = {
    en = {
        ping = "*Pong*",
        clean_bots = "*All Group Bots Has Been Kicked.*",
        is_owner = "User %d Is Already Owner.",
        setowner = "User %d Has Been Promoted To Owner.",
        user_not_found = "*User* `%s` *Not Found.*",
        is_mod = "User %d is Already Group Admin.",
        promote = "User %d Has Been Promoted To Group Admin.",
        not_mod = "User %d Is Not Group Admin.",
        demote = "User %d Has Been Removed From Group Admins List.",
        cant_silent = "*You Can't Silent [Mods/Owners/Admins/Sudoers/Bot Owner].*",
        is_silent = "User %d Is Already Silented.",
        silent = "User %d Has Been Silented.",
        not_silent = "User %d Is Not Silent.",
        unsilent = "User %d Removed From Silent Users List",
        cm_my_self = "*I Can't Mute My Self.*",
        ck_my_self = "*I Can't Kick My Self.*",
        cant_kick = "*You Can't Kick [Mods/Owners/Admins/Sudoers/Bot Owner].*",
        kick = "User %d Has Been Successfully Kicked.",
        info = "*Name:* %s\n*UserName:* %s\n*ID:* %d",
        id = "Your ID: %d\nChat ID: %d\nTotal Messages: %d",
        gpinfo = "*Admins Count:* `%d`\n*Members Count:* `%d`\n*Restricted Users Count:* `%d`\n*Banned Users Count:* `%d`",
        is_filter = "*Word* `%s` *Is Already Filtered.*",
        filter = "`%s` *Has Been Successfully Added To Filtered Words List.*",
        not_filter = "*Word* `%s` *Is Not Filtered.*",
        unfilter = "`%s` *Has Been Successfully Removed From Filtered Words List.*",
        cb_my_self = "*I Can't Ban My Self.*",
        cant_ban = "*You Can't Ban [Mods/Owners/Admins/Sudoers/Bot Owner].*",
        is_ban = "User %d Is Already Banned.",
        ban = "User %d Has Been Successfully Banned.",
        not_ban = "User %d Is Not Banned.",
        unban = "User %d Has Been Successfully Unbaned.",
        setlink = "*New Group Link Has Been Saved:*\n`%s`",
        wait_link = "*Send New Group Link.*",
        setrules = "*New Group Rules Has Been Saved:*\n%s",
        link = "*Group Link:*\n`%s`",
        ns_link = "*Group Link Is Not Saved.*",
        rules = "*Group Rules:*\n%s",
        ns_rules = "*Group Rules In Not Saved.*",
        setlang = "*Group Lang Successfully Changed.*",
        setcmdlang = "*Group Commands Lang Successfully Changed.*",
        delpms = "*All Your Messages Has Been Successfully Deleted.*",
        cda_my_self = "*I Can't Delete My Self Messages.*",
        cant_delall = "*You Can't Delete Messages From [Mods/Owners/Admins/Sudoers/Bot Owner].*",
        delall = "All Messages From User %d Has Been Deleted.",
        setwelcome = "*New Group Welcome Text Has Been Saved.*\n%s",
        charge = "`Group Charged For` *%d* `Days.`",
        ft_range = "*Value Should be Between* `[2-999]`",
        al_hour_range = "*Value Should be Between* `[0-23]`",
        al_min_range = "*Value Should be Between* `[0-59]`",
        floodtime = "*Flood Time Has Been Seted To:* `%d`",
        fn_range = "*Value Should be Between* `[2-30]`",
        floodnum = "*Flood Number Has Been Seted To:* `%d`",
        del_limit = "*Value Should be Between* `[1-1000]`",
        del = "%d Messages Successfully Deleted.",
        helper_off = "`Helper Bot Is Offline.`",
        cw_my_self = "*I Can't Warn My Self.*",
        cant_warn = "*You Can't Warn [Mods/Owners/Admins/Sudoers/Bot Owner].*",
        warn_k = "User %d Has Been Kicked. His Warns Reached to Maximum Number !",
        warn = "User %d Has Been Warned. User Warns : [%d/%d]",
        unwarn = "User %d Has Been UnWarned. User Warns : [%d/%d]",
        n_warn = "User %d Don't Have Warn.",
        reswarn = "User %d Warns Has Been Reseted.",
        setname = "*Group Title Has Been Successfully Changed.*",
        inv_bans = "*All Banned Users Has Successfully Invited To Group.*",
        config = "*All Group Admins Has Been Successfully Added To Mods List.*\n",
        clean_deleted = "*All Deleted Account Was Cleared.*",
        clean_blocklist = "*Group BlockList Was Cleared.*",
        clean_bots = "*All Bots Was Cleared.*",
        clean_mems = "*All Group Members Was Cleared.*",
        clean_msgs = "*All Group Messages Was Cleared.*",
        clean_banlist = "*Group BanList Was Cleared.*",
        clean_silents = "*Group SilentList Was Cleared.*",
        clean_gbans = "*Bot Globally Ban List Was Cleared*",
        cant_gban = "*You Can't Globally Ban Other Bot Admins/Sudoers or Bot Owner*",
        cgb_my_self = "*I Can't Globally Ban My Self.*",
        is_gban = "User %d Is Already Globally Banned.",
        gban = "User %d Has Been Successfully Globally Banned.",
        not_gban = "User %d Is Not Globally Banned.",
        ungban = "User %d Has Been Successfully Globally Unbanned.",
        is_admin = "User %d Is Already Admin.",
        add_admin = "User %d Has Been Successfully Added To Admins List.",
        not_admin = "User %d Is Not Admin.",
        rem_admin = "User %d Has Been Successfully Removed From Admins List.",
        al_empty = "*Admins List Is Empty*",
        gbl_empty = "*Globally Bans List Is Empty*",
        admins_list = "*Admins List:*\n",
        gbans_list = "*Globally Banned Users List:*\n",
        flooder_kicked = "User %d Has Been Banned Because of Flooding!",
        flooder_banned = "You Are Banned Because of Flooding!",
        expire_1 = "*Group Expire Ended.\nBot Isn't Work on This Group.*",
        expire_2 = "*Group Expire Ended.\n\nID: %d\nUse Commands For:\nLeave:*\n`/leave %d`\n*Join To Group:*\n`/jointo %d`",
        is_added = "*Group Is Already Added*",
        add = "*Group Has Been Added*\n*Group Charged 3 Minutes For Settings*",
        rem = "*Group Has Been Removed.*",
        not_added = "*Group Is Not Added*",
        expire_3 = "*Group Charge is Less Than One Day.\nPlease Charge The Group.*",
        autolock = "*Status*: %s\n*Start*: `%s`\n*End*: `%s`",
        bot_not_admin = "Bot Isn't Admin. Please Promote Bot.",
        help = "Bot Commands Help"
    },
    fa = {
        ping = "آنلاینم",
        clean_bots = "تمامی ربات های گروه اخراج شدند.",
        is_owner = "کاربر %d از قبل صاحب گروه بود.",
        setowner = "کاربر %d به عنوان صاحب گروه ارتقاء یافت.",
        user_not_found = "کاربر `%s` یافت نشد.",
        is_mod = "کاربر %d از قبل ادمین گروه بود",
        promote = "کاربر %d به عنوان ادمین گروه ارتقاء یافت.",
        not_mod = "کاربر %d ادمین گروه نیست.",
        demote = "کاربر %d از لیست ادمین های گروه حذف شد.",
        cant_silent = "شما نمی توانید توانایی چت کردن را از ادمین ها، صاحب گروه، ادمین های ربات، سودو ها، و صاحب ربات بگیرید.",
        is_silent = "کاربر %d از قبل توانایی چت کردن را نداشت.",
        silent = "کاربر %d توانایی چت کردن را از دست داد",
        not_silent = "کاربر %d از قبل توانایی چت کردن را دارا بود.",
        unsilent = "کاربر %d توانایی چت کردن را به دست آورد",
        cm_my_self = "من نمی توانم توانایی چت کردن را از خودم بگیرم.",
        ck_my_self = "من نمی توانم خودم را از گروه اخراج کنم",
        cant_kick = "شما نمی توانید ادمین ها، صاحب گروه، ادمین های ربات، سودو ها، و صاحب ربات را اخراج نمایید.",
        kick = "کاربر %d با موفقیت از گروه اخراج شد.",
        info = "نام: %s\nیوزرنیم: %s\nآیدی: %d",
        id = "آیدی شما : %d\nآیدی گروه: %d\nتعداد پیام های شما: %d",
        gpinfo = "تعداد ادمین ها: %d\nتعداد اعضا: %d\nتعداد اعضای محدود شده: %d\nتعداد اعضای مسدود شده: %d",
        is_filter = "کلمه `%s` از قبل فیلتر بود.",
        filter = "کلمه `%s` با موفقیت به لیست کلمات فیلتر شده افزوده شد.",
        not_filter = "کلمه `%s` از قبل فیلتر نبود.",
        unfilter = "کلمه `%s` با موفقیت از لیست کلمات فیلتر شده حذف شد.",
        cb_my_self = "من نمی توانم خودم را مسدود کنم.",
        cant_ban = "شما نمی توانید ادمین ها، صاحب گروه، ادمین های ربات، سودو ها، و صاحب ربات را مسدود نمایید.",
        is_ban = "کاربر %d از قبل مسدود بود.",
        ban = "کاربر %d با موفقیت مسدود شد.",
        not_ban = "کاربر %d از قبل مسدود نبود.",
        unban = "کاربر %d با موفقیت رفع مسدودیت شد.",
        setlink = "لینک جدید گروه با موفقیت ذخیره شد:\n`%s`",
        wait_link = "لینک جدید گروه را بفرستید.",
        setrules = "قوانین جدید گروه با موفقیت ذخیره شد.\n%s",
        link = "لینک گروه :\n`%s`",
        ns_link = "لینک گروه ذخیره نشده است.",
        rules = "قوانین گروه :\n%s",
        ns_rules = "قوانین گروه ذخیره نشده است.",
        setlang = "زبان گروه با موفقیت تغییر کرد.",
        setcmdlang = "زبان دستورات گروه با موفقیت تغییر کرد.",
        delpms = "تمام پیام های شما با موفقیت حذف شد.",
        cda_my_self = "من نمی توانم پیام های خودم را حذف کنم.",
        cant_delall = "شما نمی توانید پیام های ادمین ها، صاحب گروه، ادمین های ربات و صاحب ربات را حذف نمایید.",
        delall = "تمامی پیام های ارسالی از کاربر %d حذف شد.",
        setwelcome = "متن جدید خوش آمد گویی گروه ذخیره شد.\n%s",
        charge = "گروه به مدت %d روز شارژ شد.",
        ft_range = "مقدار وارد شده میبایست بین `[2-999]`باشد",
        al_hour_range = "مقدار وارد شده میبایست `[0-23]` باشد",
        al_min_range = "مقدار وارد شده میبایست بین `[0-59]` باشد.",
        floodtime = "زمان پیام رگباری تنظیم شد به: `%d`",
        fn_range = "مقدار وارد شده میبایست بین `[2-30]` باشد",
        floodnum = "مقدار پیام رگباری تنظیم شد به: `%d`",
        del_limit = "مقدار وارد شده میبایست بین `[1-1000]`باشد",
        del = "*%d* پیام با موفقیت حذف شد.",
        helper_off = "`ربات هلپر خاموش می باشد.`",
        cw_my_self = "من نمی توانم به خودم اخطار دهم.",
        cant_warn = "شما نمی توانید به مدیر ها، صاحب گروه، ادمین های ربات و صاحب ربات اخطار دهید.",
        warn_k = "کاربر %d اخراج شد. تعداد اخطار های شخص به پایان رسیده بود.",
        warn = "کاربر %d اخطار گرفت. تعداد اخطار های کاربر: [%d/%d]",
        unwarn = "یک اخطار از اخطار های کاربر %d حذف شد. تعداد اخطار های کاربر: [%d/%d]",
        n_warn = "کاربر %d اخطاری ندارد.",
        reswarn = "اخطار های کاربر %d باز نشانی شد.",
        setname = "نام گروه با موفقیت تغییر یافت.",
        inv_bans = "تمامی کاربران مسدود شده به گروه دعوت شدند.",
        config = "تمامی ادمین های گروه به لیست مدیران گروه اضافه شدند.\n",
        clean_deleted = "تمامی کاربران حذف شده پاک شدند.",
        clean_blocklist = "لیست سیاه گروه پاکسازی شد.",
        clean_bots = "تمام ربات های گروه اخراج شدند.",
        clean_mems = "تمامی اعضای گروه اخراج شدند.",
        clean_msgs = "تمامی پیام های گروه پاکسازی شد.",
        clean_banlist = "لیست سیاه گروه با موفقیت پاکسازی شد.",
        clean_silents = "لیست کاربران ساکت شده گروه با موفقیت پاکسازی شد.",
        clean_gbans = "لیست کاربران مسدود همگانی شده ربات پاکسازی شد.",
        cant_gban = "شما نمی توانید دیگر ادمین ها/سودوها یا صاحب ربات را مسدود همگانی نمایید.",
        cgb_my_self = " من نمی توانم خودم را مسدود همگانی نمایم.",
        is_gban = "کاربر %d از قبل مسدود همگانی بود.",
        gban = "کاربر %d با موفقیت مسدود همگانی شد.",
        not_gban = "کاربر %d از قبل مسدود همگانی نبود.",
        ungban = "کاربر %d با موفقیت از لیست مسدودان همگانی حذف شد.",
        is_admin = "کاربر %d از قبل ادمین ربات بود.",
        add_admin = "کاربر %d با موفقیت به لیست ادمین های ربات افزوده شد.",
        not_admin = "کاربر %d از قبل ادمین نبود.",
        rem_admin = "کاربر %d با موفقیت از لیست ادمین های ربات حذف شد.",
        al_empty = "لیست ادمین های ربات خالی می باشد.",
        gbl_empty = "لیست کاربران مسدود همگانی شده خالی می باشد.",
        admins_list = "لیست ادمین های ربات:\n",
        gbans_list = "لیست کاربران مسدود همگانی شده:\n",
        flooder_kicked = "کاربر %d به دلیل ارسال پیام های مکرر اخراج شد.",
        flooder_banned = "شما به دلیل ارسال پیام های مکرر مسدود شدید.",
        expire_1 = "شارژ گروه به اتمام رسید.\nربات در این گروه کار نخواهد کرد.",
        expire_2 = "شارژ گروهی به اتمام رسید.\nآیدی: %d\nاز دستورات زیر استفاده کنید برای:\nترک کردن گروه:\n`/leave %d`\nعضویت در گروه\n`/jointo %d'",
        is_added = "گروه از قبل اضافه شده است.",
        add = "گروه با موفقیت افزوده شد.\nگروه به مدت 3 دقیقه برای تنظیمات تمدید شد.",
        rem = "گروه با موفقیت حذف شد.",
        not_added = "گروه از قبل اضافه نشده بود.",
        expire_3 = "مدیر گرامی، کمتر از یک روز به مدت اعتبار گروه مانده است. لطفا اقدام به تمدید فرمایید.",
        autolock = "*وضعیت*: %s\n*شروع*: `%s`\n*پایان*: `%s`",
        bot_not_admin = "ربات ادمین نیست. لطفا ربات را ادمین کنید.",
        help = "راهنمای دستورات ربات"
    }
}

function getText(chat_id, text)
    lang = getChatLang(chat_id)
    return texts[lang][text]
end

function getChatType(id)
    id = tostring(id)
    if id:match("^-") then
        if id:match("^-100") then
            return "sgp"
        end
        return "gp"
    end
    return "pv"
end

function kickChatMember(chat_id, user_id)
    tdbot.changeChatMemberStatus(chat_id, user_id, "Banned", {0})
end

function sendMention(chat_id, reply_id, text, user_id)
  a, b = text:find("%d+")
	assert (tdbot_function ({
		_ = "sendMessage",
		chat_id = chat_id,
		reply_to_message_id = reply_id,
		disable_notification = 0,
		from_background = true,
		reply_markup = nil,
		input_message_content = {
			_ = "inputMessageText",
			text = text,
			disable_web_page_preview = 1,
			clear_draft = false,
			entities = {[0] = {
				offset =  a - 1,
				length = b - a + 1,
				_ = "textEntity",
				type = {user_id = user_id, _ = "textEntityTypeMentionName"}}}
			}
	}, dl_cb, nil))
end

function setOwner(msg, user_id)
  chat_id = msg.chat_id

  h = hash .. ":owner:" .. chat_id
  g = tonumber(db:get(h))
  if g and g == user_id then
      text = getText(chat_id, "is_owner")
      text = text:format(user_id)
      sendMention(chat_id, msg.id, text, user_id)
  else
      db:set(h, user_id)
      text = getText(chat_id, "setowner")
      text = text:format(user_id)
      sendMention(chat_id, msg.id, text, user_id)
  end
end

function promote(msg, user_id)
    chat_id = msg.chat_id

    h = hash .. ":mods:" .. chat_id

    if db:sismember(h, user_id) then
        text = getText(chat_id, "is_mod")
    else
        db:sadd(h, user_id)
        text = getText(chat_id, "promote")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function demote(msg, user_id)
    chat_id = msg.chat_id

    h = hash .. ":mods:" .. chat_id

    if not db:sismember(h, user_id) then
        text = getText(chat_id, "not_mod")
    else
        db:srem(h, user_id)
        text = getText(chat_id, "demote")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function silent(msg, user_id)
    if user_id == bot.id then
        text = getText(chat_id, "cm_my_self")
        tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        return
    end
    chat_id = msg.chat_id

    h = hash .. ":silents:" .. chat_id

    if isMod(chat_id, user_id) then
        text = getText(chat_id, "cant_silent")
        tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        return
    else
        if db:sismember(h, user_id) then
            text = getText(chat_id, "is_silent")
        else
            db:sadd(h, user_id)
            text = getText(chat_id, "silent")
        end
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function unsilent(msg, user_id)
    chat_id = msg.chat_id

    h = hash .. ":silents:" .. chat_id

    if not db:sismember(h, user_id) then
        text = getText(chat_id, "not_silent")
    else
        db:srem(h, user_id)
        text = getText(chat_id, "unsilent")
    end

    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function kick(msg, user_id)
    chat_id = msg.chat_id

    if user_id == bot.id then
      text = getText(chat_id, "ck_my_self")
      tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
      return
    end

    if isMod(chat_id, user_id) then
        text = getText(chat_id, "cant_kick")
        tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        return
    end

    kickChatMember(chat_id, user_id)
    text = getText(chat_id, "kick")
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function res(msg, data)
    id = data.id
    function res_cb(a, d)
      name = d.first_name .. " " .. d.last_name
      username = d.username

      text = getText(msg.chat_id, "info")
      text = text:format(checkMarkdown(name), checkMarkdown(username), id)
      tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    tdbot.getUser(id, res_cb)
end

function whois(msg, data)
    text = getText(msg.chat_id, "info")
    name = data.first_name .. " " .. data.last_name
    username = data.username
    id = data.id
    text = text:format(checkMarkdown(name), checkMarkdown(username), id)
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function filter(chat_id, word)
    h = hash .. ":filters:" .. chat_id
    if db:sismember(h, word) then
        text = getText(chat_id, "is_filter")
    else
        db:sadd(h, word)
        text = getText(chat_id, "filter")
    end
    text = text:format(word)
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function unfilter(chat_id, word)
    h = hash .. ":filters:" .. chat_id
    if not db:sismember(h, word) then
        text = getText(chat_id, "not_filter")
    else
        db:sadd(h, word)
        text = getText(chat_id, "unfilter")
    end
    text = text:format(word)
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function ban(msg, user_id)

    if user_id == bot.id then
        text = getText(msg.chat_id, "cb_my_self")
        tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        return
    end

    if isMod(msg.chat_id, user_id) then
        text = getText(msg.chat_id, "cant_ban")
        tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        return
    end

    kickChatMember(msg.chat_id, user_id)
    h = hash ..":banneds:" .. msg.chat_id
    if db:sismember(h, user_id) then
        text = getText(msg.chat_id, 'is_ban')
    else
        db:sadd(h, user_id)
        text = getText(msg.chat_id, "ban")
    end

    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)


end

function unban(msg, user_id)

    tdbot.changeChatMemberStatus(msg.chat_id, user_id, "Left", {0})
    h = hash ..":banneds:" .. msg.chat_id
    if not db:sismember(h, user_id) then
        text = getText(msg.chat_id, 'not_ban')
    else
        db:srem(h, user_id)
        text = getText(msg.chat_id, "unban")
    end

    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)


end

function saveLink(msg, link)
    db:set(hash .. ":gp_link:" .. msg.chat_id, link)
    text = getText(msg.chat_id, "setlink")
    text = text:format(link)
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function getLink(chat_id)
    link = db:get(hash .. ":gp_link:" .. chat_id)
    if link then
        return link
    end
    return ""
end

function saveRules(msg, rules)
    db:set(hash .. ":gp_rules:" .. msg.chat_id, rules)
    text = getText(msg.chat_id, "setrules")
    text = text:format(rules)
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function getRules(chat_id)
    rules = db:get(hash .. ":gp_rules:" .. chat_id)
    if rules then
        return rules
    end
    return ""
end

function isLock(chat_id, value)
    h = hash .. ":lock-"..value..":" .. msg.chat_id
    if db:get(h) then
        return true
    end
    return false
end

function setLang(msg, lang)
    db:set(hash .. ":lang:" .. msg.chat_id, lang)
    text = getText(msg.chat_id, "setlang")
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function setCmdLang(msg, lang)
    db:set(hash .. ":cmd_lang:" .. msg.chat_id, lang)
    text = getText(msg.chat_id, "setcmdlang")
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function delall(msg, user_id)
    if user_id == bot.id then
        return tdbot.sendText(msg.chat_id, msg.id, getText(msg.chat_id, "cda_my_self"), 0, 1, nil, 1, 'md', 0)
    end
    if isMod(msg.chat_id, user_id) then
        return tdbot.sendText(msg.chat_id, msg.id, getText(msg.chat_id, "cant_delall"), 0, 1, nil, 1, 'md', 0)
    end

    tdbot.deleteMessagesFromUser(msg.chat_id, user_id)
    text = getText(msg.chat_id, "delall")
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function setWelcome(msg, wlctxt)
    db:set(hash .. ":gp_welcome_text:" .. msg.chat_id, wlctxt)
    text = getText(msg.chat_id, "setwelcome")
    text = text:format(checkMarkdown(wlctxt))
    tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
end

function delMessages(msg, num)
    text = getText(msg.chat_id, "del")
    text = text:format(num)
    function cb(arg, data)
        if data.messages then
            for k, v in pairs(data.messages) do
                tdbot.deleteMessages(msg.chat_id, {[0] = v.id}, true)
            end
        end
        if arg.send then
            tdbot.sendText(msg.chat_id, 0, text, 0, 1, nil, 1, 'md', 0)
        end
    end
    h = math.floor(num/100)
    num = num - (h * 100)
    if h >= 1 then
        for i=1, h do
            tdbot.getChatHistory(msg.chat_id, msg.id, 0, 100, false, cb, {send=false})
        end
    end
    tdbot.getChatHistory(msg.chat_id, 0, 0, num, false, cb, {send=true})
end

function leaveChat(chat_id)
    tdbot.changeChatMemberStatus(chat_id, bot.id, "Left", {0})
end

function getMaxWarn(chat_id)
    h = db:get(hash .. ":max_warn:" .. chat_id)
    if h then
        return tonumber(h)
    end
    return 3
end

function warn(msg, user_id)
    if user_id == bot.id then
        text = getText(msg.chat_id, "cw_my_self")
        return tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    if isMod(msg.chat_id, user_id) then
        text = getText(msg.chat_id, "cant_warn")
        return tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    warns = tonumber(db:get(hash .. ":warns:" .. msg.chat_id .. ":" .. user_id) or 0) + 1
    max_warn = getMaxWarn(msg.chat_id)
    if warns >= max_warn then
        kickChatMember(msg.chat_id, user_id)
        db:del(hash .. ":warns:" .. msg.chat_id .. ":" .. user_id)
        text = getText(msg.chat_id, "warn_k")
        text = text:format(user_id)
    else
        db:set(hash .. ":warns:" .. msg.chat_id .. ":" .. user_id, warns)
        text = getText(msg.chat_id, "warn")
        text = text:format(user_id, warns, max_warn)
    end
    sendMention(msg.chat_id, msg.id, text, user_id)
end

function unwarn(msg, user_id)
    warns = tonumber(db:get(hash .. ":warns:" .. msg.chat_id .. ":" .. user_id) or 0) - 1
    max_warn = getMaxWarn(msg.chat_id)
    if warns >= 0 then
        db:set(hash .. ":warns:" .. msg.chat_id .. ":" .. user_id, warns)
        text = getText(msg.chat_id, "unwarn")
        text = text:format(user_id, warns, max_warn)
    else
        text = getText(msg.chat_id, "n_warn")
        text = text:format(user_id)
    end
    sendMention(msg.chat_id, msg.id, text, user_id)
end

function resetWarns(msg, user_id)
    h = hash .. ":warns:" .. msg.chat_id .. ":" .. user_id
    db:del(h)
    text = getText(msg.chat_id, "reswarn")
    text = text:format(user_id)
    sendMention(msg.chat_id, msg.id, text, user_id)
end
function inviteBanneds(msg)
    function ib_cb (arg, data)
        if data.members then
            for k, v in pairs(data.members) do
                tdbot.addChatMember(msg.chat_id, v.user_id, 0)
            end
        end
        if data.total_count < 200 then
            local text = getText(msg.chat_id, "inv_bans")
            tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        else
            tdbot.getChannelMembers(msg.chat_id, 0, 200, "Banned", "", ib_cb)
        end
    end
    tdbot.getChannelMembers(msg.chat_id, 0, 200, "Banned", "", ib_cb)
end

function cleanDeleteds(msg)
    i = 0
    function cda_cb(arg, data)
        if data.members then
            for k, v in pairs(data.members) do
              tdbot.getUser(v.user_id, function (a, d)
                                          if d.status._ == "userStatusEmpty" then
                                              kickChatMember(msg.chat_id, d.id)
                                          end
                                       end)
            end
        end
        if data.total_count < 200 then
            local text = getText(msg.chat_id, "clean_deleted")
            tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        else
            tdbot.getChannelMembers(msg.chat_id, i, 200, "", "", cda_cb)
            i = i + 200
        end
    end
    i = i + 200
    tdbot.getChannelMembers(msg.chat_id, 0, 200, "Recent", "", cda_cb)
end

function cleanBlockList(msg)
    i = 0
    function cbl_cb(arg, data)
        if data.members then
            for k, v in pairs(data.members) do
                tdbot.changeChatMemberStatus(msg.chat_id, v.user_id, "Left", {})
            end
        end
        if data.total_count < 200 then
            local text = getText(msg.chat_id, "clean_blocklist")
            tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        else
            tdbot.getChannelMembers(msg.chat_id, 0, 200, "Banned", "", cbl_cb)
            i = i + 200
        end
    end
    i = i + 200
    tdbot.getChannelMembers(msg.chat_id, 0, 200, "Banned", "", cbl_cb)
end

function cleanBots(msg)
    i = 0
    function cb_cb(arg, data)
        if data.members then
            for k, v in pairs(data.members) do
                kickChatMember(msg.chat_id, v.user_id)
            end
        end
        if data.total_count < 200 then
            local text = getText(msg.chat_id, "clean_bots")
            tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        else
            tdbot.getChannelMembers(msg.chat_id, 0, 200, "Bots", "", cb_cb)
            i = i + 200
        end
    end
    i = i + 200
    tdbot.getChannelMembers(msg.chat_id, 0, 200, "Bots", "", cb_cb)
end

function cleanMembers(msg)
    i = 0
    function cm_cb(arg, data)
        if data.members then
            for k, v in pairs(data.members) do
                if not isMod(msg.chat_id, v.user_id) then
                    kickChatMember(msg.chat_id, v.user_id)
                end
            end
        end
        if data.total_count < 200 then
            local text = getText(msg.chat_id, "clean_mems")
            tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
        else
            tdbot.getChannelMembers(msg.chat_id, 0, 200, "Recent", "", cb_cb)
            i = i + 200
        end
    end
    i = i + 200
    tdbot.getChannelMembers(msg.chat_id, 0, 200, "Recent", "", cm_cb)
end

function cleanMsgs(msg)
    function cm_cb(arg, data)
        if data.messages then
            for k, v in pairs(data.messages) do
                tdbot.deleteMessages(msg.chat_id, {[0] = v.id}, true)
            end
        end
        if data.total_count < 100 then
            local text = getText(msg.chat_id, "clean_msgs")
            return tdbot.sendText(msg.chat_id, 0, text, 0, 1, nil, 1, 'md', 0)
        end
        tdbot.getChatHistory(msg.chat_id, 0, 0, 100, false, cm_cb)
    end
    tdbot.getChatHistory(msg.chat_id, 0, 0, 100, false, cm_cb)
end

function gban(msg, user_id)
    if isAdmin(user_id) then
        local text = getText(msg.chat_id, "cant_gban")
        return tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    if user_id == bot.id then
        local text = getText(msg.chat_id, "cgb_my_self")
        return tdbot.sendText(msg.chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    h = hash .. ":gbans"
    if db:sismember(h, user_id) then
        text = getText(msg.chat_id, "is_gban")
    else
        db:sadd(h, user_id)
        text = getText(msg.chat_id, "gban")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function ungban(msg, user_id)
    h = hash .. ":gbans"
    if not db:sismember(h, user_id) then
        text = getText(msg.chat_id, "not_gban")
    else
        db:srem(h, user_id)
        text = getText(msg.chat_id, "ungban")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function addAdmin(msg, user_id)
    h = hash .. ":admins"
    if db:sismember(h, user_id) then
        text = getText(msg.chat_id, "is_admin")
    else
        db:sadd(h, user_id)
        text = getText(msg.chat_id, "add_admin")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function remAdmin(msg, user_id)
    h = hash .. ":admins"
    if not db:sismember(h, user_id) then
        text = getText(msg.chat_id, "not_admin")
    else
        db:srem(h, user_id)
        text = getText(msg.chat_id, "rem_admin")
    end
    text = text:format(user_id)
    sendMention(chat_id, msg.id, text, user_id)
end

function deleteMsg(chat_id, msg_id)
    tdbot.deleteMessages(chat_id, {[0] = msg_id}, true)
end

function isChargeCmd(msg)
    if msg.content._ ~= "messageText" then return false end
    if not isAdmin(msg.sender_user_id) then return false end
    text = msg.content.text
    cl = getChatCmdLang(msg.chat_id)
    cc = text:lower():match("^[#/!]?charge (%d+)$") or text:match("^شارژ (%d+)$")
    ac = isCmd(text, "add") or text == "افزودن"
    isc = cc or ac
    if isc then return true end
    return false
end

function botAdded(msg)
    if msg.content._ ~= "messageChatAddMembers" then return false end

    for k, v in pairs(msg.content.member_user_ids) do
        if v == bot.id then return true end
    end
    return false
end

function sendWelcomeText(chat_id, user_id, i_text)
    text = checkMarkdown(i_text)
    function pwt_cb (arg, data)
        if data.username == "" then
            data.username = '---'
        end
        if data.last_name == "" then
            data.last_name = '---'
        end
        text = text:gsub('FIRSTNAME', checkMarkdown(data.first_name))
        text = text:gsub('LASTNAME', checkMarkdown(data.last_name))
        text = text:gsub('USERNAME', checkMarkdown(data.username))
        text = text:gsub('USERID', user_id)
        text = text:gsub('CHATID', chat_id)
        tdbot.sendText(chat_id, msg.id, text, 0, 1, nil, 1, 'md', 0)
    end
    tdbot.getUser(user_id, pwt_cb)
    return text
end

function sendWelcMsg(msg)
    text = db:get(hash .. ":gp_welcome_text:" .. msg.chat_id)
    if msg.content._ == "messageChatJoinByLink" then
        sendWelcomeText(msg.chat_id, msg.sender_user_id, text)
    elseif msg.content._ == "messageChatAddMembers" then
        for k, v in pairs(msg.content.member_user_ids) do
                sendWelcomeText(msg.chat_id, v, text)
        end
    end
end

function getAutoLock(chat_id, key)
    local h = hash .. ":auto_lock-"..key..":"..chat_id
    local d = {start_hour=23, start_minute=00, end_hour=7, end_minute=30}
    if db:get(h) then
        r = db:get(h)
    else
        r = d[key]
    end
    if tonumber(r) < 10 then
        r = '0' .. r
    end
    return r
end

function setAutoLock(chat_id, key, value)
    local h = hash .. ":auto_lock-"..key..":"..chat_id
    db:set(h, value)
end
--[[

{
    cmd = {fa = "", en = ""},
    desc = {fa = "", en = ""}
}

]]
help = {
    {
        cmd = {fa = "منو", en = "menu"},
        desc = {fa = "نمایش تنظیمات کلی گروه", en = "Show Group Settings"}
    },
    {
        cmd = {fa = "ربات", en = "ping"},
        desc = {fa = "وضعیت ربات", en = "Bot Status"}
    },
    {
        cmd = {fa = "جوین شو لینک", en = "join link"},
        desc = {fa = "عضویت ربات در گروه با لینک", en = "Join To Group With Link"}
    },
    {
        cmd = {fa = "jointo ایدی", en = "jointo id"},
        desc = {fa = "اضافه کردن صاحب ربات به گروه با ایدی", en = "Add Bot Owner To Group With Group ID"}
    },
    {
        cmd = {fa = "leave ایدی", en = "leave id"},
        desc = {fa = "ترک گروه با ایدی گروه", en = "Leave Group With Group ID"}
    },
    {
        cmd = {fa = "مسدود همگانی [ریپلی|ایدی|یوزرنیم]", en = "gban [reply|id|username]"},
        desc = {fa = "اضافه کردن کاربر به لیست مسدودین همگانی ربات", en = "Add User To Globally Banneds List"}
    },
    {
        cmd = {fa = "حذف مسدود همگانی [ریپلی|ایدی|یوزرنیم]", en = "gban [reply|id|username]"},
        desc = {fa = "حذف کاربر از لیست مسدودین همگانی ربات", en = "Remove User From Globally Banneds List"}
    },
    {
        cmd = {fa = "ادمین [ریپلی|ایدی|یوزرنیم]", en = "addadmin [reply|id|username]"},
        desc = {fa = "اضافه کردن کاربر به لیست ادمین های ربات", en = "Add User To Admins List."}
    },
    {
        cmd = {fa = "حذف ادمین [ریپلی|ایدی|یوزرنیم]", en = "remadmin [reply|id|username]"},
        desc = {fa = "حذف کاربر از لیست ادمین های ربات", en = "Remove User From Admins List."}
    },
    {
        cmd = {fa = "لیست ادمین ها", en = "admins list"},
        desc = {fa = "لیست ادمین های ربات", en = "Bot Admins List"}
    },
    {
        cmd = {fa = "کاربران مسدود همگانی", en = "gbans list"},
        desc = {fa = "لیست کاربران مسدود شده همگانی", en = "Globally Banned Users List."}
    },
    {
        cmd = {fa = "افزودن", en = "add"},
        desc = {fa = "افزودن گروه به لیست گروه های ربات", en = "Add Group To Bot Group's List"}
    },
    {
        cmd = {fa = "حذف گروه", en = "rem"},
        desc = {fa = "حذف گروه از لیست گروه های ربات", en = "Remove Group From Bot Group's List"}
    },
    {
        cmd = {fa = "تنظیم مالک [ریپلی|ایدی|یوزرنیم]", en = "setowner [reply|id|username]"},
        desc = {fa = "ارتقاء کاربر به عنوان مالک گروه", en = "Promote User As Group Owner"}
    },
    {
    cmd = {fa = "مدیر [ریپلی|ایدی|یوزرنیم]", en = "promote [reply|id|username]"},
    desc = {fa = "ارتقاء کاربر به عنوان مدیر گروه", en = "Promote User As Group Admin"}
    },
    {
        cmd = {fa = "حذف مدیر [ریپلی|ایدی|یوزرنیم]", en = "demote [reply|id|username]"},
        desc = {fa = "عزل مقام کاربر", en = "Demote User"}
    },
    {
        cmd = {fa = "سنجاق", en = "pin"},
        desc = {fa = "سنجاق یک پیام در گروه", en = "Pin Message In Group"}
    },
    {
        cmd = {fa = "حذف سنجاق", en = "unpin"},
        desc = {fa = "حذف سنجاق پیام سنجاق شده در گروه", en = "Unpin Pinned Message"}
    },
    {
        cmd = {fa = "سکوت [ریپلی|ایدی|یوزرنیم]", en = "silent [reply|id|username]"},
        desc = {fa = "افزون کاربر به لیست سکوت", en = "Add User To Group Silent List"}
    },
    {
        cmd = {fa = "حذف سکوت [ریپلی|ایدی|یوزرنیم]", en = "unsilent [reply|id|username]"},
        desc = {fa = "حذف کاربر از لیست سکوت گروه", en = "Remove User From Group Silent List"}
    },
    {
        cmd = {fa = "اخراج [ریپلی|ایدی|یوزرنیم]", en = "kick [reply|id|username]"},
        desc = {fa = "اخراج کاربر از گروه", en = "Kick User From Group"}
    },
    {
        cmd = {fa = "مسدود [ریپلی|ایدی|یوزرنیم]", en = "ban [reply|id|username]"},
        desc = {fa = "مسدود کردن کاربر از گروه", en = "Ban User From Group"}
    },
    {
        cmd = {fa = "کاربری [یوزرنیم]", en = "res [username]"},
        desc = {fa = "نمایش اطلاعات کاربر", en = "Show User Info"}
    },
    {
        cmd = {fa = "ایدی", en = "id"},
        desc = {fa = "نمایش اطلاعات شما", en = "Show Your Info"}
    },
    {
        cmd = {fa = "ایدی [ریپلی]", en = "id [reply]"},
        desc = {fa = "نمایش شناسه کاربر", en = "Show User ID"}
    },
    {
        cmd = {fa = "شناسه [ایدی]", en = "whois [id]"},
        desc = {fa = "نمایش اطلاعات کاربر", en = "Show User Info"}
    },
    {
        cmd = {fa = "اطلاعات گروه", en = "gpinfo"},
        desc = {fa = "نمایش اطلاعات گروه", en = "Show Group Info"}
    },
    {
        cmd = {fa = "تنظیم لینک", en = "setlink"},
        desc = {fa = "تنظیم لینک جدید", en = "Set New Link"}
    },
    {
        cmd = {fa = "لینک", en = "link"},
        desc = {fa = "نمایش لینک گروه", en = "Show Group Link"}
    },
    {
        cmd = {fa = "تنظیم قوانین [قوانین]", en = "setrules [rules]"},
        desc = {fa = "تنظیم قوانین جدید", en = "Set New Rules"}
    },
    {
        cmd = {fa = "قوانین", en = "rules"},
        desc = {fa = "نمایش قوانین گروه", en = "Show Group Rules"}
    },
    {
        cmd = {fa = "تنظیم خوش آمد گویی [متن]", en = "setwelcome [text]"},
        desc = {fa = "تنظیم متن خوش آمد گویی گروه\nهمچنین می توانید از FIRSTNAME, LASTNAME, USERNAME, USERID, CHATID استفاده نمایید.",
                en = "Set New Group Welcome Text\nAlso You Can User FIRSTNAME, LASTNAME, USERNAME, USERID, CHATID"}
    },
    {
        cmd = {fa = "فیلتر [کلمه]", en = "filter [word]"},
        desc = {fa = "فیلتر کردن کلمه مورد نظر", en = "Filter Word"}
    },
    {
        cmd = {fa = "حذف فیلتر [کلمه]", en = "unfilter [word]"},
        desc = {fa = "حذف فیلتر کلمه مورد نظر", en = "UnFilter Word"}
    },
    {
        cmd = {fa = "اخطار [ریپلی|ایدی|یوزرنیم]", en = "warn [reply|id|username]"},
        desc = {fa = "اخطار کاربر", en = "Warn User"}
    },
    {
        cmd = {fa = "حذف اخطار [ریپلی|ایدی|یوزرنیم]", en = "unwarn [reply|id|username]"},
        desc = {fa = "حذف اخطار کاربر", en = "UnWarn User"}
    },
    {
        cmd = {fa = "بازنشانی اخطار [ریپلی|ایدی|یوزرنیم]", en = "reset warn [reply|id|username]"},
        desc = {fa = "بازنشانی اخطار های کاربر", en = "Reset User Warn"}
    },
    {
        cmd = {fa = "شارز [روز]", en = "charge [day]"},
        desc = {fa = "تمدید شارژ گروه", en = "Charge Group"}
    },
    {
        cmd = {fa = "حذف پیام ها [ریپلی|ایدی|یوزرنیم]", en = "delall [reply|id|username]"},
        desc = {fa = "حذف تمامی پیام های کاربر", en = "Delete All User's Message"}
    },
    {
        cmd = {fa = "حذف پیام های من", en = "delmypms"},
        desc = {fa = "حذف تمامی پیام های شما", en = "Delete Your All Messages"}
    },
    {
        cmd = {fa = "تنظیم زبان [فارسی|انگلیسی]", en = "setlang [fa|en]"},
        desc = {fa = "تنظیم زبان گروه", en = "Set Group Language"}
    },
    {
        cmd = {fa = "تنظیم زبان دستورات [فارسی|انگلیسی]", en = "setcmdlang [fa|en]"},
        desc = {fa = "تنظیم زبان دستورات گروه", en = "Set Group Commands Language"}
    },
    {
        cmd = {fa = "تنظیم زمان رگباری [ثانیه]", en = "setfloodtime [sec]"},
        desc = {fa = "تنظیم زمان پیام رگباری", en = "Set Flood Message Time"}
    },
    {
        cmd = {fa = "تنظیم مقدار رگباری [تعداد]", en = "setfloodnum [num]"},
        desc = {fa = "تنظیم مقدار پیام رگباری", en = "Set Flood Message Number"}
    },
    {
        cmd = {fa = "پاکسازی [دلیت اکانت|لیست سیاه|ربات ها|اعضا|مسدود ها|مدیران|کلمات فیلتر شده|کاربران ساکت|کاربران مسدود همگانی]",
               en = "clean [deleted|blocklist|bots|members|msgs|banlist|mods|filters|silents|gbans]"},
        desc = {fa = "پاکسازی مورد انتخابی", en = "Clean Choosed Item"}
    },
    {
        cmd = {fa = "ارتقا ادمین ها", en = "config"},
        desc = {fa = "ارتقاء ادمین های گروه در ربات", en = "Promote Group Admins In Bot"}
    },
    {
        cmd = {fa = "دعوت کاربران مسدود", en = "invite banneds"},
        desc = {fa = "دعوت کاربران مسدود شده به گروه", en = "Invite Banneds User To Group"}
    },
    {
        cmd = {fa = "تنظیم نام [نام]", en = "setname [name]"},
        desc = {fa = "تنظیم نام جدید گروه", en = "Set New Group Name"}
    },
    {
        cmd = {fa = "حذف [عدد]", en = "del [num]"},
        desc = {fa = "پاکسازی n پیام مورد نظر", en = "Delete n Messages"}
    },
    {
        cmd = {fa = "ترک گروه", en = "leave"},
        desc = {fa = "خارج شدن ربات از گروه", en = "Leave Current Group"}
    },
    {
        cmd = {fa = "قفل خودکار [شروع|پایان] [ساعت|دقیقه] [مقدار]", en = "autolock [start|end] [hour|minute] [value]"},
        desc = {fa = "تنظیمات مربوط به قفل خودکار گروه", en = "Group AutoLock Settings"}
    },
    {
        cmd = {fa = "قفل خودکار", en = "autolock"},
        desc = {fa = "نمایش وضعیت قفل خودکار", en = "Show AutoLock Status"}
    }
}

function getHelpText(chat_id)
    cl = getChatCmdLang(chat_id)
    l = getChatLang(chat_id)
    text = getText(chat_id, "help") .. "\n"
    for k, v in pairs(help) do
        text = text .. "\n\n<code>" .. v.cmd[cl] .. "</code>\n<b>" .. v.desc[l] .. "</b>"
    end
    return text
end
