#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])
core.header(current_session)

if not current_session:
    print('Для просмотра таблицы результатов нужно войти в систему.')
    print(core.action('Войти', core.page_path + '/login.mu', core.color_warning))
    core.footer()
    raise SystemExit

state = core.read_game_state()
rows = core.get_leaderboard()

print(core.heading('Лидерборд'))
print()
print('Статус игры: ' + core.status_badge(state.get('status', 'preparing'), core.color_warning))
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
    status_color = core.color_success if row.get('approved', False) else core.color_warning
    print(str(rank) + '. ' + core.fg(core.strong(row.get('team', '')), core.color_secondary) + ' | ' + core.status_badge(status, status_color))
    print('   Очки: ' + core.fg(str(row.get('score', 0)), core.color_success) + ' | задания: ' + completed + ' | ошибки: ' + core.fg(str(row.get('wrong', 0)), core.color_danger) + ' | время: ' + core.format_duration(row.get('elapsed', 0)))
    print('   Капитан: ' + row.get('captain', ''))
    rank = rank + 1

core.footer()
