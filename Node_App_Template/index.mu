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
    print(core.heading('Платформа городского квеста'))
    print()
    print(core.fg('После входа игрок видит полный список заданий, отправляет найденные коды и получает мгновенный вердикт системы.', core.color_secondary))
    print()
    print('Капитан создает команду на вкладке команды и отправляет участникам токен-ссылку. Организатор подтверждает команду в панели управления.')
    print()
    print(core.action('Войти', core.page_path + '/login.mu', core.color_warning) + ' ' + core.action('Зарегистрироваться', core.page_path + '/register.mu'))
    core.footer()
    raise SystemExit

username = current_session['username']
user = core.read_users()[username]
team_id, team = core.find_user_team(username)
state = core.read_game_state()
tasks = core.read_tasks()

if core.is_organizer(current_session):
    print(core.heading('Обзор организатора'))
    print()
    print('Статус игры: ' + core.status_badge(state.get('status', 'preparing'), core.color_warning))
    print(core.action('Управление', core.page_path + '/manage_users.mu'))
    print()
    print(core.subheading('Задания игры'))
    for task_id in tasks:
        task = tasks[task_id]
        print('- ' + core.fg(core.strong(task['title']), core.color_secondary) + ' ' + str(task.get('points', 0)) + ' очков')
        print('  ' + task['description'])
    core.footer()
    raise SystemExit

if 'field_team_name' in os.environ:
    print('Создание команды перенесено на отдельную вкладку.')
    print(core.action('Команда', core.page_path + '/team.mu`team_name=' + os.environ['field_team_name']))
    core.footer()
    raise SystemExit

if 'var_invite' in os.environ:
    print('Вступление в команду перенесено на отдельную вкладку.')
    print(core.action('Команда', core.page_path + '/team.mu`invite=' + os.environ['var_invite']))
    core.footer()
    raise SystemExit

if not team:
    print(core.heading('Формирование команды'))
    print()
    print('Вы пока не состоите в команде. Сначала создайте команду или вступите по приглашению.')
    print()
    print(core.action('Перейти к команде', core.page_path + '/team.mu'))
    core.footer()
    raise SystemExit

if not team.get('approved', False):
    print(core.heading('Команда ожидает допуска'))
    print()
    print('Команда: ' + team['name'])
    print('Капитан: ' + team['captain'])
    print('Участники: ' + ', '.join(team.get('members', [])))
    print()
    print('Токен приглашения: ' + team['invite_token'])
    print('Организатор должен подтвердить заявку команды перед стартом квеста.')
    print()
    print(core.action('Подробнее о команде', core.page_path + '/team.mu'))
    core.footer()
    raise SystemExit

progress = core.get_team_progress(team_id)

if state.get('status') == 'finished':
    print(core.heading('Игра завершена'))
    print()
    print('Итоговая таблица результатов:')
    for row in core.get_leaderboard():
        print('- ' + core.fg(row['team'], core.color_secondary) + ' | очки: ' + str(row['score']) + ' | заданий: ' + str(row['completed']) + '/' + str(row['total']) + ' | время: ' + core.format_duration(row.get('elapsed', 0)))
    print()
    print(core.action('Полный лидерборд', core.page_path + '/leaderboard.mu'))
    core.footer()
    raise SystemExit

if state.get('status') != 'running':
    print(core.heading('Команда допущена. Ожидание старта игры'))
    print()
    print('Команда: ' + team['name'])
    print('Состав: ' + ', '.join(team.get('members', [])))
    print()
    print('Организатор еще не перевел игру в статус running. До старта задания и ввод кодов закрыты.')
    core.footer()
    raise SystemExit

if 'var_task' in os.environ and 'field_answer' in os.environ:
    success, message = core.submit_task_answer(team_id, username, os.environ['var_task'], os.environ['field_answer'])
    message_color = core.color_success if success else core.color_danger
    print(core.fg(core.strong(message), message_color))
    print(core.action('Вернуться к заданиям', core.page_path + '/index.mu'))
    core.footer()
    raise SystemExit

if 'var_task' in os.environ:
    task_id = os.environ['var_task']
    task = tasks.get(task_id)
    if task is None:
        print('Задание не найдено.')
    else:
        done = task_id in progress.get('completed', {})
        print(core.heading(task['title']))
        print()
        print(task['description'])
        print()
        print('Очки: ' + str(task.get('points', 0)))
        print()
        if done:
            print('Статус: ' + core.status_badge('выполнено', core.color_success))
        else:
            print('Ответ: ' + core.field('answer'))
            print(core.action('Отправить', core.page_path + '/index.mu`answer|task=' + task_id, core.color_warning))
    print(core.action('Все задания', core.page_path + '/index.mu'))
    core.footer()
    raise SystemExit

print(core.heading('Игровое пространство'))
print()
print('Команда: ' + core.fg(team['name'], core.color_secondary) + ' | Счет: ' + core.fg(str(progress.get('score', 0)), core.color_success))
print('Статус игры: ' + core.status_badge(state.get('status', 'preparing'), core.color_warning))
print()

for task_id in tasks:
    task = tasks[task_id]
    done = task_id in progress.get('completed', {})
    marker = '[ ]'
    if done:
        marker = '[x]'
    task_color = core.color_success if done else core.color_primary
    print(marker + ' ' + core.action(task['title'], core.page_path + '/index.mu`task=' + task_id, task_color) + ' - ' + str(task.get('points', 0)) + ' очков')
    print('    ' + task['description'])

if progress.get('finished_at', 0) > 0:
    print()
    print('Все доступные задания выполнены. Результат команды зафиксирован.')

core.footer()
