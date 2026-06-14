#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if current_session:
    core.deauthenticate_user(os.environ['link_id'])
    print(core.heading('Выход'))
    print()
    print(core.fg('Сессия завершена.', core.color_success))

if not current_session:
    print('Вы уже вышли из системы.')

print(core.action('Продолжить', core.page_path + '/index.mu'))

core.footer()
