#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])
core.header(current_session)

if not current_session:
    print('Для работы с командой нужно войти в систему.')
    print(core.action('Войти', core.page_path + '/login.mu', core.color_warning))
    core.footer()
    raise SystemExit

if core.is_organizer(current_session):
    print('Организатор управляет командами в отдельной панели.')
    print(core.action('Команды', core.page_path + '/manage_users.mu`view=teams'))
    core.footer()
    raise SystemExit

username = current_session['username']

if 'field_team_name' in os.environ:
    team_id, team = core.create_team(username, os.environ['field_team_name'])
    print(core.heading('Команда создана'))
    print()
    print('Название: ' + core.fg(team['name'], core.color_secondary))
    print('Токен приглашения: ' + core.fg(team['invite_token'], core.color_warning))
    print('Ссылка для участника: ' + core.action('Вступить', core.page_path + '/team.mu`invite=' + team['invite_token']))
    print()
    print('Команда появится у организатора в списке заявок.')
    core.footer()
    raise SystemExit

if 'var_invite' in os.environ:
    team_id, team = core.join_team_by_token(username, os.environ['var_invite'])
    if team:
        print('Вы добавлены в команду: ' + core.fg(core.strong(team['name']), core.color_success))
    else:
        print(core.fg('Токен команды не найден.', core.color_danger))
    print(core.action('Команда', core.page_path + '/team.mu'))
    core.footer()
    raise SystemExit

team_id, team = core.find_user_team(username)

if not team:
    print(core.heading('Команда'))
    print()
    print('Вы пока не состоите в команде.')
    print()
    print('Если вы капитан, создайте команду:')
    print('Название команды: ' + core.field('team_name'))
    print(core.action('Создать команду', core.page_path + '/team.mu`team_name', core.color_warning))
    print()
    print('Если вы участник, откройте ссылку приглашения от капитана.')
    core.footer()
    raise SystemExit

status = 'ожидает допуска'
if team.get('approved', False):
    status = 'допущена'

print(core.heading('Команда: ' + team['name']))
print()
status_color = core.color_success if team.get('approved', False) else core.color_warning
print('Статус: ' + core.status_badge(status, status_color))
print('Капитан: ' + team['captain'])
print('Участники: ' + ', '.join(team.get('members', [])))
print()
print('Токен приглашения: ' + core.fg(team['invite_token'], core.color_warning))
print('Ссылка для приглашения: ' + core.action('Вступить', core.page_path + '/team.mu`invite=' + team['invite_token']))

if not team.get('approved', False):
    print()
    print('Организатор должен подтвердить заявку команды перед участием в игре.')

core.footer()
