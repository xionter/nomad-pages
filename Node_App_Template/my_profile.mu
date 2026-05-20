#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if current_session:
    if 'var_save' not in os.environ and 'var_new_password' not in os.environ:
        user_data = core.read_user_id(current_session['user_id'])
        print('`!Профиль участника`!')
        print('Новый пароль: `B444`<!|password`>`b')
        print('`!`[<Обновить пароль>`:' + core.page_path + '/my_profile.mu`password|new_password=true]`!')
        print()
        print('Имя:             `B444`<name`' + user_data['profile']['name'] + '>`b')
        print()
        print('О себе:          `B444`<about`' + user_data['profile']['about'] + '>`b')
        print()
        print('LXMF адрес:      `B444`<lxmf`' + user_data['profile']['lxmf'] + '>`b')

        print()
        team_id, team = core.find_user_team(current_session['username'])
        if team:
            print('Команда: ' + team['name'] + ' | капитан: ' + team['captain'])
            print('Токен приглашения: ' + team['invite_token'])
        else:
            print('Команда не выбрана. Создать команду или вступить по токену можно на главной странице.')
        print()
        print('`!`[<Сохранить>`:' + core.page_path + '/my_profile.mu`name|lxmf|about|save=true]`!')
        print('`!`[<Идентичность Reticulum>`:' + core.page_path + '/identity.mu]`!')
    elif 'var_save' in os.environ:
        core.update_profile(core.get_current_session(os.environ['link_id']), os.environ)
        print('Профиль сохранен.')
        print('`!`[<Назад>`:' + core.page_path + '/my_profile.mu]`!')
    elif 'var_new_password' in os.environ:
        core.update_password(current_session['username'], os.environ['field_password'])
        print('Пароль обновлен.')
        print('`!`[<Назад>`:' + core.page_path + '/my_profile.mu]`!')
    
if not current_session:
    print('Требуется вход в систему.')
    print('`!`[<На главную>`:' + core.page_path + '/index.mu]`!')

core.footer()
