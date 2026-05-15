#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if not current_session:
    # We have registration variables, proceed to regisater user
    if 'field_username' in os.environ and 'field_password' in os.environ and 'field_password2' in os.environ and not current_session:
        try:
            core.read_users()[os.environ['field_username']]
            print('Имя пользователя уже занято.')
        except:
            if os.environ['field_password'] != os.environ['field_password2']:
                print('Пароль и подтверждение не совпадают.')
                print('`!`[<Повторить>`:' + core.page_path + '/register.mu]`!')
            elif os.environ['field_password'] == '' or os.environ['field_password2'] == '':
                print('Пароль не может быть пустым.')
                print('`!`[<Повторить>`:' + core.page_path + '/register.mu]`!')
            elif len(os.environ['field_password']) < 8 or len(os.environ['field_password2']) < 8:
                print('Пароль должен быть не короче 8 символов.')
                print('`!`[<Повторить>`:' + core.page_path + '/register.mu]`!')
            elif len(os.environ['field_username']) < 4:
                print('Имя пользователя должно быть не короче 4 символов.')
                print('`!`[<Повторить>`:' + core.page_path + '/register.mu]`!')
            elif os.environ['field_password'] == os.environ['field_password2']:
                print('Регистрация завершена. Теперь можно войти и создать или принять приглашение в команду.')
                print('`!`[<Войти>`:' + core.page_path + '/login.mu]`!')
                try:
                    core.write_new_user(os.environ['field_username'], os.environ['field_password'])
                except Exception as e:
                    print(str(e))
        
    # No registration variables, show sign up page.
    else:
        if core.registration_enabled:
            print('`!Регистрация игрока`!')
            print()
            print('Имя пользователя должно быть не короче 4 символов, пароль - не короче 8 символов.')
            print('После регистрации капитан может создать команду, а рядовой участник - вступить по токен-ссылке.')
            print()
            print('Имя пользователя: `B444`<username`>`b')
            print()
            print('Пароль          : `B444`<!|password`>`b')
            print()
            print('Повтор пароля   : `B444`<!|password2`>`b')
            print()
            print('`!`[<Зарегистрироваться>`:' + core.page_path + '/register.mu`username|password|password2]`!')
        if not core.registration_enabled:
            print('Регистрация отключена организатором.')
            print('`!`[<Назад>`:' + core.page_path + '/index.mu]`!')

    
if current_session:
        print('Вы уже зарегистрированы и вошли в систему.')
        print('`!`[<К заданиям>`:' + core.page_path + '/index.mu]`!')

core.footer()


