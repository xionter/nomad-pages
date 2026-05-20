#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])
core.header(current_session)

if not current_session:
    print('Для просмотра таблицы результатов нужно войти в систему.')
    print('`!`[<Войти>`:' + core.page_path + '/login.mu]`!')
    core.footer()
    raise SystemExit

state = core.read_game_state()
rows = core.get_leaderboard()

print('`!Лидерборд`!')
print()
print('Статус игры: ' + state.get('status', 'preparing'))
print()

if len(rows) == 0:
    print('Команд пока нет.')
    core.footer()
    raise SystemExit

rank = 1
for row in rows:
    status = 'ожидает допуска'
    if row.get('approved', False):
        status = 'допущена'
    completed = str(row.get('completed', 0)) + '/' + str(row.get('total', 0))
    print(str(rank) + '. `!' + row.get('team', '') + '`! | ' + status)
    print('   Очки: ' + str(row.get('score', 0)) + ' | задания: ' + completed + ' | ошибки: ' + str(row.get('wrong', 0)) + ' | время: ' + core.format_duration(row.get('elapsed', 0)))
    print('   Капитан: ' + row.get('captain', ''))
    rank = rank + 1

core.footer()
