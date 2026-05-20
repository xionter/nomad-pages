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
        print(core.heading('Профиль участника'))
        print('Новый пароль: ' + core.password_field('password'))
        print(core.action('Обновить пароль', core.page_path + '/my_profile.mu`password|new_password=true', core.color_warning))
        print()
        print('Имя:             ' + core.field('name', user_data['profile']['name']))
        print()
        print('О себе:          ' + core.field('about', user_data['profile']['about']))
        print()
        print('LXMF адрес:      ' + core.field('lxmf', user_data['profile']['lxmf']))

        print()
        team_id, team = core.find_user_team(current_session['username'])
        if team:
            print('Команда: ' + core.fg(team['name'], core.color_secondary) + ' | капитан: ' + team['captain'])
            print('Токен приглашения: ' + core.fg(team['invite_token'], core.color_warning))
        else:
            print('Команда не выбрана. Создать команду или вступить по токену можно на главной странице.')
        print()
        print(core.action('Сохранить', core.page_path + '/my_profile.mu`name|lxmf|about|save=true', core.color_warning))
        print(core.action('Идентичность Reticulum', core.page_path + '/identity.mu'))
    elif 'var_save' in os.environ:
        core.update_profile(core.get_current_session(os.environ['link_id']), os.environ)
        print(core.fg('Профиль сохранен.', core.color_success))
        print(core.action('Назад', core.page_path + '/my_profile.mu'))
    elif 'var_new_password' in os.environ:
        core.update_password(current_session['username'], os.environ['field_password'])
        print(core.fg('Пароль обновлен.', core.color_success))
        print(core.action('Назад', core.page_path + '/my_profile.mu'))
    
if not current_session:
    print('Требуется вход в систему.')
    print(core.action('На главную', core.page_path + '/index.mu'))

core.footer()
