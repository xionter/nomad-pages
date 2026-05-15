#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])
core.header(current_session)

if not current_session:
    print('Для работы с командой нужно войти в систему.')
    print('`!`[<Войти>`:' + core.page_path + '/login.mu]`!')
    core.footer()
    raise SystemExit

if core.is_organizer(current_session):
    print('Организатор управляет командами в отдельной панели.')
    print('`!`[<Команды>`:' + core.page_path + '/manage_users.mu`view=teams]`!')
    core.footer()
    raise SystemExit

username = current_session['username']

if 'field_team_name' in os.environ:
    team_id, team = core.create_team(username, os.environ['field_team_name'])
    print('`!Команда создана`!')
    print()
    print('Название: ' + team['name'])
    print('Токен приглашения: ' + team['invite_token'])
    print('Ссылка для участника: `!`[<Вступить>`:' + core.page_path + '/team.mu`invite=' + team['invite_token'] + ']`!')
    print()
    print('Команда появится у организатора в списке заявок.')
    core.footer()
    raise SystemExit

if 'var_invite' in os.environ:
    team_id, team = core.join_team_by_token(username, os.environ['var_invite'])
    if team:
        print('Вы добавлены в команду: `!' + team['name'] + '`!')
    else:
        print('Токен команды не найден.')
    print('`!`[<Команда>`:' + core.page_path + '/team.mu]`!')
    core.footer()
    raise SystemExit

team_id, team = core.find_user_team(username)

if not team:
    print('`!Команда`!')
    print()
    print('Вы пока не состоите в команде.')
    print()
    print('Если вы капитан, создайте команду:')
    print('Название команды: `B444`<team_name`>`b')
    print('`!`[<Создать команду>`:' + core.page_path + '/team.mu`team_name]`!')
    print()
    print('Если вы участник, откройте ссылку приглашения от капитана.')
    core.footer()
    raise SystemExit

status = 'ожидает допуска'
if team.get('approved', False):
    status = 'допущена'

print('`!Команда: ' + team['name'] + '`!')
print()
print('Статус: ' + status)
print('Капитан: ' + team['captain'])
print('Участники: ' + ', '.join(team.get('members', [])))
print()
print('Токен приглашения: ' + team['invite_token'])
print('Ссылка для приглашения: `!`[<Вступить>`:' + core.page_path + '/team.mu`invite=' + team['invite_token'] + ']`!')

if not team.get('approved', False):
    print()
    print('Организатор должен подтвердить заявку команды перед участием в игре.')

core.footer()
