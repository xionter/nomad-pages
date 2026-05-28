#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session, 'register')

if not current_session:
    # We have registration variables, proceed to regisater user
    if 'field_username' in os.environ and 'field_password' in os.environ and 'field_password2' in os.environ and not current_session:
        try:
            core.read_users()[os.environ['field_username']]
            print(core.fg('Имя пользователя уже занято.', core.color_danger))
        except:
            if os.environ['field_password'] != os.environ['field_password2']:
                print(core.fg('Пароль и подтверждение не совпадают.', core.color_danger))
                print(core.action('Повторить', core.page_path + '/register.mu', core.color_warning))
            elif os.environ['field_password'] == '' or os.environ['field_password2'] == '':
                print(core.fg('Пароль не может быть пустым.', core.color_danger))
                print(core.action('Повторить', core.page_path + '/register.mu', core.color_warning))
            elif len(os.environ['field_password']) < 8 or len(os.environ['field_password2']) < 8:
                print(core.fg('Пароль должен быть не короче 8 символов.', core.color_danger))
                print(core.action('Повторить', core.page_path + '/register.mu', core.color_warning))
            elif len(os.environ['field_username']) < 4:
                print(core.fg('Имя пользователя должно быть не короче 4 символов.', core.color_danger))
                print(core.action('Повторить', core.page_path + '/register.mu', core.color_warning))
            elif os.environ['field_password'] == os.environ['field_password2']:
                print(core.fg('Регистрация завершена. Теперь можно войти и создать или принять приглашение в команду.', core.color_success))
                print(core.action('Войти', core.page_path + '/login.mu', core.color_warning))
                try:
                    core.write_new_user(os.environ['field_username'], os.environ['field_password'])
                except Exception as e:
                    print(str(e))
        
    # No registration variables, show sign up page.
    else:
        if core.registration_enabled:
            print(core.heading('Регистрация игрока'))
            print()
            print(core.fg('Имя пользователя должно быть не короче 4 символов, пароль - не короче 8 символов.', core.color_secondary))
            print('После регистрации капитан может создать команду, а рядовой участник - вступить по токен-ссылке.')
            print()
            print('Имя пользователя: ' + core.field('username'))
            print()
            print('Пароль          : ' + core.password_field('password'))
            print()
            print('Повтор пароля   : ' + core.password_field('password2'))
            print()
            print(core.action('Зарегистрироваться', core.page_path + '/register.mu`username|password|password2', core.color_warning))
        if not core.registration_enabled:
            print(core.fg('Регистрация отключена организатором.', core.color_danger))
            print(core.action('Назад', core.page_path + '/index.mu'))

    
if current_session:
        print('Вы уже зарегистрированы и вошли в систему.')
        print(core.action('К заданиям', core.page_path + '/index.mu'))

core.footer()
