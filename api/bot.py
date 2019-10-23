from multiprocessing import Process, freeze_support

import re
from telebot import TeleBot

from utils import *

bot = TeleBot(config.token)
bot_info = bot.get_me()
print(f"[@{bot_info.username}] ({bot_info.id})")


def onInline(q: types.InlineQuery):
    if not isBot(q.from_user.id):
        return False
    if re.match("menu (-\d+) (\d+)", q.query):
        match = re.match("menu (-\d+) (\d+)", q.query)
        chat_id, user_id = match.groups()

        text = getText(chat_id, 'panel')
        mk = Keyboards(chat_id).main()

        res = [
            types.InlineQueryResultArticle('1', str(chat_id), types.InputTextMessageContent(text), reply_markup=mk)
        ]

        bot.answer_inline_query(q.id, res, cache_time='1')


def onCallback(call: types.CallbackQuery):
    if re.match('(\S+):(-\d+)', call.data):
        data, chat_id = re.match('(\S+):(-\d+)', call.data).groups()
        gp = Group(chat_id)
        kb = Keyboards(chat_id)

        if not gp.isMod(call.from_user.id):
            return bot.answer_callback_query(call.id, gp.getText('dont_access'), show_alert=True)
        if not gp.panelFor(call.from_user.id, call.inline_message_id):
            return bot.answer_callback_query(call.id, gp.getText('s'), show_alert=True)

        d_for = {
            'mods': {'list': gp.mods, 'en': 'Admins', 'fa': 'ادمین های'},
            'bans': {'list': gp.bans, 'en': 'Banned Users', 'fa': 'کاربران مسدود شده'},
            'silents': {'list': gp.silents, 'en': 'Silent Users', 'fa': 'کاربران ساکت شده'},
            'filters': {'list': gp.filters, 'en': 'Filter Words', 'fa': 'کلمات فیلتر شده'}
        }

        if data == "home":
            bot.edit_message_text(gp.getText('panel'), inline_message_id=call.inline_message_id, reply_markup=kb.main())

        elif data == "exit":
            bot.edit_message_text(gp.getText('close'), inline_message_id=call.inline_message_id)

        elif data == "gp_info":
            bot.edit_message_text(gp.getText('gp_info_t'), inline_message_id=call.inline_message_id,
                                  reply_markup=kb.info())

        elif data == "gp_owner":
            text = gp.getText('gp_owner').format(gp.owner)
            bot.edit_message_text(text, inline_message_id=call.inline_message_id, reply_markup=kb.backTo('gp_info'))

        elif data in d_for.keys():
            u = list(d_for[data]['list'])
            if len(u) >= 1:
                text = gp.getText(f'list').format(d_for[data][gp.getLang()])
                for i in range(len(u)):
                    text += f'\n{i+1}. {u[i]}'
            else:
                text = gp.getText(f'list_empty').format(d_for[data][gp.getLang()])

            bot.edit_message_text(text, inline_message_id=call.inline_message_id, reply_markup=kb.backTo('gp_info'))

        elif data in settings.keys():
            mk = kb.settings(data)
            text = gp.getText('settings_page').format(getSettingsPageNumber(data))
            bot.edit_message_text(text, inline_message_id=call.inline_message_id, reply_markup=mk,
                                  parse_mode="markdown")

        elif data.startswith('lock_'):
            h = data.replace('lock_', '')
            if gp.isLock(h):
                gp.unlock(h)
            else:
                gp.lock(h)

            mk = kb.settings(getSettingsPage(h))
            text = gp.getText('settings_page').format(getSettingsPageNumber(data))
            bot.edit_message_text(text, inline_message_id=call.inline_message_id, reply_markup=mk,
                                  parse_mode="markdown")


@bot.inline_handler(func=lambda q: True)
def inline_query(q):
    freeze_support()
    Process(target=onInline, args=(q,)).start()


@bot.callback_query_handler(func=lambda call: True)
def callback_query(call):
    Process(target=onCallback, args=(call,)).start()


@bot.chosen_inline_handler(func=lambda q: True)
def inline_chosen(q: types.ChosenInlineResult):
    if re.match("menu (-\d+) (\d+)", q.query):
        match = re.match("menu (-\d+) (\d+)", q.query)
        chat_id, user_id = match.groups()
        db.set(f"{bot_hash}:panel_for:{chat_id}:{q.inline_message_id}", user_id)


bot.polling()
