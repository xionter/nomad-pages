#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if current_session:
    core.deauthenticate_user(os.environ['link_id'])
    print('`!Выход`!')
    print()
    print('Сессия завершена.')

if not current_session:
    print('Вы уже вышли из системы.')

print('`!`[<Продолжить>`:' + core.page_path + '/index.mu]`!')
    
core.footer()
