#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

if 'remote_identity' in os.environ:
    user_identity = core.check_identity(os.environ['remote_identity'])
    if user_identity != None:
        user_data = core.read_user_id(user_identity[1]['user_id'])
        user = core.read_users()[user_data['username']]
        core.add_active_session(os.environ['link_id'], user_identity[1]['user_id'], user_data, user['role'])

current_session = core.get_current_session(os.environ['link_id'])
core.trim_active_sessions()
core.header(current_session)

if not current_session:
    print('`!Платформа городского квеста`!')
    print()
    print('После входа игрок видит полный список заданий, отправляет найденные коды и получает мгновенный вердикт системы.')
    print()
    print('Капитан создает команду на вкладке команды и отправляет участникам токен-ссылку. Организатор подтверждает команду в панели управления.')
    print()
    print('`!`[<Войти>`:' + core.page_path + '/login.mu]`! `!`[<Зарегистрироваться>`:' + core.page_path + '/register.mu]`!')
    core.footer()
    raise SystemExit

username = current_session['username']
user = core.read_users()[username]
team_id, team = core.find_user_team(username)
state = core.read_game_state()
tasks = core.read_tasks()

if core.is_organizer(current_session):
    print('`!Панель организатора`!')
    print()
    print('Статус игры: ' + state.get('status', 'preparing'))
    print('`!`[<Команды и пользователи>`:' + core.page_path + '/manage_users.mu]`!')
    print()
    print('`!Задания игры`!')
    for task_id in tasks:
        task = tasks[task_id]
        status = 'доступно'
        if not task.get('enabled', True):
            status = 'скрыто'
        print('- `!' + task['title'] + '`! [' + status + '] ' + str(task.get('points', 0)) + ' очков')
        print('  ' + task['description'])
    core.footer()
    raise SystemExit

if 'field_team_name' in os.environ:
    print('Создание команды перенесено на отдельную вкладку.')
    print('`!`[<Команда>`:' + core.page_path + '/team.mu`team_name=' + os.environ['field_team_name'] + ']`!')
    core.footer()
    raise SystemExit

if 'var_invite' in os.environ:
    print('Вступление в команду перенесено на отдельную вкладку.')
    print('`!`[<Команда>`:' + core.page_path + '/team.mu`invite=' + os.environ['var_invite'] + ']`!')
    core.footer()
    raise SystemExit

if not team:
    print('`!Формирование команды`!')
    print()
    print('Вы пока не состоите в команде. Сначала создайте команду или вступите по приглашению.')
    print()
    print('`!`[<Перейти к команде>`:' + core.page_path + '/team.mu]`!')
    core.footer()
    raise SystemExit

if not team.get('approved', False):
    print('`!Команда ожидает допуска`!')
    print()
    print('Команда: ' + team['name'])
    print('Капитан: ' + team['captain'])
    print('Участники: ' + ', '.join(team.get('members', [])))
    print()
    print('Токен приглашения: ' + team['invite_token'])
    print('Организатор должен подтвердить заявку команды перед стартом квеста.')
    print()
    print('`!`[<Подробнее о команде>`:' + core.page_path + '/team.mu]`!')
    core.footer()
    raise SystemExit

progress = core.get_team_progress(team_id)

if state.get('status') == 'finished':
    print('`!Игра завершена`!')
    print()
    print('Итоговая таблица результатов:')
    for row in core.get_leaderboard():
        print('- ' + row['team'] + ' | очки: ' + str(row['score']) + ' | заданий: ' + str(row['completed']))
    core.footer()
    raise SystemExit

if state.get('status') != 'running':
    print('`!Команда допущена. Ожидание старта игры`!')
    print()
    print('Команда: ' + team['name'])
    print('Состав: ' + ', '.join(team.get('members', [])))
    print()
    print('Организатор еще не перевел игру в статус running. До старта задания и ввод кодов закрыты.')
    core.footer()
    raise SystemExit

if 'var_task' in os.environ and 'field_answer' in os.environ:
    success, message = core.submit_task_answer(team_id, username, os.environ['var_task'], os.environ['field_answer'])
    print('`!' + message + '`!')
    print('`!`[<Вернуться к заданиям>`:' + core.page_path + '/index.mu]`!')
    core.footer()
    raise SystemExit

if 'var_task' in os.environ:
    task_id = os.environ['var_task']
    task = tasks.get(task_id)
    if task is None:
        print('Задание не найдено.')
    else:
        done = task_id in progress.get('completed', {})
        print('`!' + task['title'] + '`!')
        print()
        print(task['description'])
        print()
        print('Медиа: ' + task.get('media', 'не задано'))
        print('Очки: ' + str(task.get('points', 0)))
        print()
        if done:
            print('Статус: выполнено.')
        else:
            print('Ответ: `B444`<answer`>`b')
            print('`!`[<Отправить>`:' + core.page_path + '/index.mu`answer|task=' + task_id + ']`!')
    print('`!`[<Все задания>`:' + core.page_path + '/index.mu]`!')
    core.footer()
    raise SystemExit

print('`!Игровое пространство`!')
print()
print('Команда: ' + team['name'] + ' | Счет: ' + str(progress.get('score', 0)))
print('Статус игры: ' + state.get('status', 'preparing'))
print()

for task_id in tasks:
    task = tasks[task_id]
    if not task.get('enabled', True):
        continue
    done = task_id in progress.get('completed', {})
    marker = '[ ]'
    if done:
        marker = '[x]'
    print(marker + ' `!`[<' + task['title'] + '>`:' + core.page_path + '/index.mu`task=' + task_id + ']`! - ' + str(task.get('points', 0)) + ' очков')
    print('    ' + task['description'])

if progress.get('finished_at', 0) > 0:
    print()
    print('Все доступные задания выполнены. Результат команды зафиксирован.')

core.footer()
