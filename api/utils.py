import config
import redis
from telebot import types

db = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)

bot_hash = config.bot_hash


def isBotOwner(user_id):
    return user_id == config.owner


def isSudo(user_id):
    if isBotOwner(user_id):
        return True
    if user_id in config.sudoers:
        return True
    return False


def isAdmin(user_id):
    h = f"{bot_hash}:admins"
    if isSudo(user_id):
        return True
    if db.sismember(h, user_id):
        return True
    return False


def isGBanned(user_id):
    h = f"{bot_hash}:gbans"
    if db.sismember(h, user_id):
        return True
    return False


def isBot(user_id):
    return user_id == config.bot_id


def checkMarkdown(text):

    for i in ['_', '`', '*']:
        if i in text:
            text = text.replace(i, f"\\{i}")
    return text


def getText(chat_id, text):
    gp = Group(chat_id)
    return texts[gp.getLang()][text]


def getSettingsPage(data):
    if data in ['all', 'inline', 'sticker', 'game', 'gif', 'contact', 'location', 'photo', 'tag']:
        return 'settings'
    if data in ['audio', 'voice', 'video', 'video_note', 'document', 'text', 'forward', 'bots', 'service']:
        return 'settings_2'
    return 'settings_3'


def getSettingsPageNumber(data):
    if data in ['settings', 'lock_all', 'lock_inline', 'lock_sticker', 'lock_game', 'lock_gif', 'lock_contact',
                'lock_location', 'lock_photo', 'lock_tag']:
        return 1
    if data in ['settings_2', 'lock_audio', 'lock_voice', 'lock_video', 'lock_video_note', 'lock_document',
                'lock_text', 'lock_forward', 'lock_bots', 'lock_service']:
        return 2
    return 3


class Group:
    def __init__(self, chat_id):
        self.chat_id = chat_id
        self.owner = db.get(f"{bot_hash}:owner:{chat_id}")
        self.mods = db.smembers(f"{bot_hash}:mods:{chat_id}")
        self.bans = db.smembers(f"{bot_hash}:banneds:{chat_id}")
        self.silents = db.smembers(f"{bot_hash}:silents:{chat_id}")
        self.filters = db.smembers(f"{bot_hash}:filters:{chat_id}")
        self.lang = db.get(f"{bot_hash}:lang:{chat_id}")
        self.cmd_lang = db.get(f"{bot_hash}:cmd_lang:{chat_id}")
        self.expire = db.ttl(f"{bot_hash}:expire:{chat_id}")

    def isOwner(self, user_id):
        if isAdmin(user_id):
            return True
        if user_id in self.mods:
            return True
        return False

    def isMod(self, user_id):
        if self.isOwner(user_id):
            return True
        if user_id in self.mods:
            return True
        return False

    def isBanned(self, user_id):
        if user_id in self.bans:
            return True
        return False

    def getLang(self):
        return self.lang if self.lang else "en"

    def getCmdLang(self):
        return self.cmd_lang if self.cmd_lang else "en"

    def getText(self, k):
        try:
            return texts[self.getLang()][k]
        except KeyError:
            return k

    def panelFor(self, user_id, inline_id):
        h = f"{bot_hash}:panel_for:{self.chat_id}:{inline_id}"
        if not db.get(h):
            return False
        if int(db.get(h)) == user_id:
            return True
        return False

    def isLock(self, key):
        h = f"{bot_hash}:lock-{key}:{self.chat_id}"
        return True if db.get(h) else False

    def lock(self, key):
        h = f"{bot_hash}:lock-{key}:{self.chat_id}"
        db.set(h, True)

    def unlock(self, key):
        h = f"{bot_hash}:lock-{key}:{self.chat_id}"
        db.delete(h)

    def getExpireStr(self):
        d = {'en': {'sec': 'Seconds', 'min': "Minutes", 'hour': 'Hours', 'day': 'Days', 'and': 'And'},
             'fa': {'sec': 'ثانیه', 'min': "دقیقه", 'hour': 'ساعت', 'day': 'روز', 'and': 'و'}}
        d = d[self.getLang()]
        time = self.expire
        time = int(time)
        if time <= 60:
            text = f"{time} {d['sec']}"
        elif time <= 3600:
            mins = int(time / 60)
            time -= mins * 60
            text = f"{mins} {d['min']}"
            if time > 0:
                text += f" {d['and']} {time} {d['sec']}"
        elif time <= 86400:
            hours = int(time / 3600)
            time -= hours * 3600
            mins = int(time / 60)
            time -= mins * 60
            text = f"{hours} {d['hour']}"
            if mins > 0:
                text += f" {d['and']} {mins} {d['min']}"
            if time > 0:
                text += f" {d['and']} {time} {d['sec']}"
        else:
            days = int(time / 86400)
            time -= days * 86400
            hours = int(time / 3600)
            time -= hours * 3600
            mins = int(time / 60)
            time -= mins * 60
            text = f"{days} {d['day']}"
            if hours > 0:
                text += f" {d['and']} {hours} {d['hour']}"
            if mins > 0:
                text += f" {d['and']} {mins} {d['min']}"
            if time > 0:
                text += f" {d['and']} {time} {d['sec']}"
        return text


settings = {
    'settings': [
        {'hash': 'all', 'en': 'Mute All', 'fa': 'قفل همه'},
        {'hash': 'inline', 'en': 'Via Bot [Inline]', 'fa': 'اینلاین'},
        {'hash': 'sticker', 'en': 'Sticker', 'fa': 'استیکر'},
        {'hash': 'game', 'en': 'Game', 'fa': 'بازی'},
        {'hash': 'gif', 'en': 'Gif', 'fa': 'گیف'},
        {'hash': 'contact', 'en': 'Contact', 'fa': 'مخاطب'},
        {'hash': 'location', 'en': 'Location', 'fa': 'ارسال مکان'},
        {'hash': 'photo', 'en': 'Photo', 'fa': 'عکس'},
        {'hash': 'tag', 'en': 'Tag [@]', 'fa': 'تگ (یوزرنیم)'}
    ],
    'settings_2': [
        {'hash': 'audio', 'en': 'Audio', 'fa': 'اهنگ'},
        {'hash': 'voice', 'en': 'Voice', 'fa': 'ویس'},
        {'hash': 'video', 'en': 'Video', 'fa': 'فیلم'},
        {'hash': 'video_note', 'en': 'Video Note', 'fa': 'ویدیو نوت'},
        {'hash': 'document', 'en': 'Document', 'fa': 'فایل'},
        {'hash': 'text', 'en': 'Text', 'fa': 'متن'},
        {'hash': 'forward', 'en': 'Forward', 'fa': 'فوروارد'},
        {'hash': 'bots', 'en': 'Bot', 'fa': 'ربات'},
        {'hash': 'service', 'en': 'Service Message', 'fa': 'سرویس'}
    ],
    'settings_3': [
        {'hash': 'htag', 'en': 'HashTag [#]', 'fa': 'هشتگ (#)'},
        {'hash': 'tg_link', 'en': 'Link', 'fa': 'لینک'},
        {'hash': 'english', 'en': 'English', 'fa': 'انگلیسی'},
        {'hash': 'gp_send_welc', 'en': 'Welcome', 'fa': 'خوش آمد گویی'},
        {'hash': 'auto_lock', 'en': 'AutoLock', 'fa': 'قفل خودکار'}
    ]
}


class Keyboards:
    def __init__(self, chat_id):
        self.chat_id = chat_id
        self.lang = Group(chat_id).getLang()
        self.gp = Group(chat_id)

    def getText(self, v):
        try:
            return texts[self.lang][v]
        except KeyError:
            return v

    def main(self):
        mk = types.InlineKeyboardMarkup()
        mk.add(types.InlineKeyboardButton("⚙️" + self.getText('settings'),
                                          callback_data=f"settings:{self.chat_id}")
               )
        mk.add(types.InlineKeyboardButton("🗒" + self.getText('gp_info'),
                                          callback_data=f"gp_info:{self.chat_id}"))
        mk.add(types.InlineKeyboardButton("🔙", callback_data=f"exit:{self.chat_id}"))
        return mk

    def info(self):
        mk = types.InlineKeyboardMarkup()
        mk.add(types.InlineKeyboardButton(self.getText('expire'), callback_data="abc"))
        mk.add(types.InlineKeyboardButton(self.gp.getExpireStr(), callback_data="efg"))
        mk.add(types.InlineKeyboardButton('👮🏻' + self.getText('owner'), callback_data=f"gp_owner:{self.chat_id}"))
        mk.add(types.InlineKeyboardButton('👮🏻‍♀️' + self.getText('mods'), callback_data=f"mods:{self.chat_id}"),
               types.InlineKeyboardButton('🚫' + self.getText('bans'), callback_data=f"bans:{self.chat_id}"))
        mk.add(types.InlineKeyboardButton('🔇' + self.getText('silents'), callback_data=f"silents:{self.chat_id}"),
               types.InlineKeyboardButton('📃' + self.getText('filters'), callback_data=f"filters:{self.chat_id}"))
        mk.add(types.InlineKeyboardButton('🔙', callback_data=f"home:{self.chat_id}"))
        return mk

    def backTo(self, cb):
        mk = types.InlineKeyboardMarkup()
        mk.add(types.InlineKeyboardButton('🔙', callback_data=f"{cb}:{self.chat_id}"))
        return mk

    def settings(self, data):
        mk = types.InlineKeyboardMarkup()
        lang = self.gp.getLang()
        for i in settings[data]:
            e = '✔️' if self.gp.isLock(i['hash']) else '✖️'
            mk.add(types.InlineKeyboardButton(i[lang], callback_data=f"lock_{i['hash']}:{self.chat_id}"),
                   types.InlineKeyboardButton(e, callback_data=f"lock_{i['hash']}:{self.chat_id}"))

        if data == 'settings':
            mk.add(types.InlineKeyboardButton('🔙', callback_data=f'home:{self.chat_id}'),
                   types.InlineKeyboardButton('🔜', callback_data=f'settings_2:{self.chat_id}'))
        elif data == "settings_2":
            mk.add(types.InlineKeyboardButton('🔙', callback_data=f'settings:{self.chat_id}'),
                   types.InlineKeyboardButton('🔜', callback_data=f'settings_3:{self.chat_id}'))
        elif data == "settings_3":
            mk.add(types.InlineKeyboardButton('🔙', callback_data=f'settings_2:{self.chat_id}'))
        return mk


texts = {
    'en': {
        'panel': 'Please Select an Option.',
        'gp_info_t': 'Welcome To Group Info Menu.',
        'settings': 'Group Settings',
        'gp_info': 'Group Info',
        'expire': 'Group Expire',
        'dont_access': 'You Don\'t Access',
        'for_other': 'This Panel is For Other Admins.',
        'close': 'Group Panel Closed.',
        'owner': 'Group Owner',
        'mods': 'Group Admins',
        'bans': 'Group BanList',
        'silents': 'Group SilentList',
        'filters': 'Group Filtered Words',
        'gp_owner': 'Group Owner: {}',
        'list': 'Group {} List:\n',
        'list_empty': 'Group {} List Is Empty.',
        'settings_page': 'Group Settings Page *{}*',
        'hour': 'Hour',
        'minute': 'Minute'
    },
    'fa': {
        'panel': 'لطفا گزینه ای را انتخاب نمایید',
        'gp_info_t': 'به بخش اطلاعات گروه خوش آمدید',
        'settings': 'تنظیمات گروه',
        'gp_info': 'اطلاعات گروه',
        'expire': 'اعتبار گروه',
        'dont_access': 'شما دسترسی ندارید',
        'for_other': 'این پنل برای دیگر ادمین ها می باشد.',
        'close': 'تنظیمات گروه بسته شد.',
        'owner': 'صاحب گروه',
        'mods': 'ادمین های گروه',
        'bans': 'لیست کاربران مسدود شده',
        'silents': 'لیست کاربران بی صدا شده',
        'filters': 'لیست کلمات فیلتر شده',
        'gp_owner': 'مالک گروه: {}',
        'list': '\nلیست {} گروه:',
        'list_empty': 'لیست {} گروه خالی می باشد.',
        'settings_page': 'تنظیمات گروه صفحه *{}*',
        'hour': 'ساعت',
        'minute': 'دقیقه'
    }
}



