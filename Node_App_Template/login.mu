#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if not current_session:
    if 'field_username' in os.environ and 'field_password' in os.environ and not current_session:
        user_authed = core.authenticate_user(os.environ['field_username'], os.environ['field_password'])
        if user_authed:
            user = core.read_users()[os.environ['field_username']]
            print('Вход выполнен. `!Сессия действует 30 минут.`!')
            print('`!`[<Перейти к заданиям>`:' + core.page_path + '/index.mu]`!')
            user_id = user['user_id']
            user_data = core.read_user_id(user_id)
            core.add_active_session(os.environ['link_id'], user_id, user_data, user['role'])
        elif not user_authed:
            print('Ошибка входа: имя, пароль или статус учетной записи не прошли проверку.')
            print('`!`[<На главную>`:' + core.page_path + '/index.mu]`!')


    else:
        print('`!Вход в систему`!')
        print()
        print('Имя пользователя: `B444`<username`>`b')
        print()
        print('Пароль: `B444`<!|password`>`b')
        print()
        print('`!`[<Войти>`:' + core.page_path + '/login.mu`username|password]`!')
    
if current_session:
        print('Вы уже вошли в систему.')
        print('`!`[<К заданиям>`:' + core.page_path + '/index.mu]`!')

core.footer()
