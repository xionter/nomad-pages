#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])
core.header(current_session)

if not current_session or not core.is_organizer(current_session):
    print('Доступ разрешен только организатору.')
    print('`!`[<Войти>`:' + core.page_path + '/login.mu]`!')
    core.footer()
    raise SystemExit

all_users = core.read_users()
teams = core.read_teams()
tasks = core.read_tasks()
state = core.read_game_state()
view = os.environ.get('var_view', 'overview')

def back_link(target_view):
    return core.page_path + '/manage_users.mu`view=' + target_view + ']`!'

def env_value(name, default=''):
    return os.environ.get('field_' + name, os.environ.get('var_' + name, default))

def task_env_value(name, default=''):
    return env_value('task_' + name, env_value(name, default))

def has_task_form_submission():
    task_fields = ['task_title', 'task_description', 'task_answer', 'task_points', 'title', 'description', 'answer', 'points']
    for name in task_fields:
        if 'field_' + name in os.environ or 'var_' + name in os.environ:
            return True
    return False

def render_tasks_list(tasks):
    print('`!Задания`!')
    print()
    print('`!`[<Новое задание>`:' + core.page_path + '/manage_users.mu`new_task=true|view=tasks]`!')
    print()
    if len(tasks) == 0:
        print('Заданий пока нет.')
    for task_id in tasks:
        task = tasks[task_id]
        print('- `!' + task.get('title', task_id) + '`! | ' + str(task.get('points', 0)) + ' очков')
        print('  ' + task.get('description', ''))
        print('  `!`[<Редактировать>`:' + core.page_path + '/manage_users.mu`edit_task=' + task_id + '|view=tasks]`!')

if 'var_game_status' in os.environ:
    core.set_game_status(os.environ['var_game_status'])
    print('Статус игры изменен: ' + os.environ['var_game_status'])
    print('`!`[<Назад>`:' + back_link('overview'))
    core.footer()
    raise SystemExit

if 'var_delete_task' in os.environ:
    if core.delete_task(os.environ['var_delete_task']):
        print('Задание удалено.')
    else:
        print('Задание не найдено.')
    print('`!`[<Назад>`:' + back_link('tasks'))
    core.footer()
    raise SystemExit

if ('var_edit_task' in os.environ or 'var_new_task' in os.environ) and not has_task_form_submission():
    task_id = os.environ.get('var_edit_task', '')
    task = tasks.get(task_id, {"title": "", "description": "", "points": 10})
    if 'var_new_task' in os.environ:
        print('`!Новое задание`!')
    else:
        print('`!Редактирование задания: ' + task.get('title', task_id) + '`!')
    print()
    print('Название: `B444`<task_title`' + task.get('title', '') + '>`b')
    print('Описание: `B444`<task_description`' + task.get('description', '') + '>`b')
    print('Ответ: `B444`<task_answer`' + task.get('answer', '') + '>`b')
    print('Очки: `B444`<task_points`' + str(task.get('points', 10)) + '>`b')
    print()
    if 'var_new_task' in os.environ:
        print('`!`[<Создать>`:' + core.page_path + '/manage_users.mu`task_title|task_description|task_answer|task_points|new_task=true|view=tasks]`!')
    else:
        print('`!`[<Сохранить>`:' + core.page_path + '/manage_users.mu`task_title|task_description|task_answer|task_points|edit_task=' + task_id + '|view=tasks]`!')
        print('`Ff00`!`[<Удалить>`:' + core.page_path + '/manage_users.mu`delete_task=' + task_id + '|view=tasks]`!`f')
    print('`!`[<К списку заданий>`:' + core.page_path + '/manage_users.mu`view=tasks]`!')
    core.footer()
    raise SystemExit

if has_task_form_submission():
    title = task_env_value('title').strip()
    if title == '':
        print('Название задания не может быть пустым.')
        print('Поля формы не были переданы в страницу сохранения. Откройте форму задания заново из вкладки «Задания».')
        print('`!`[<Назад>`:' + back_link('tasks'))
        core.footer()
        raise SystemExit
    original_task_id = os.environ.get('var_edit_task', '')
    task_id_to_save = original_task_id
    task_id = core.upsert_task(
        task_id_to_save,
        title,
        task_env_value('description'),
        task_env_value('answer'),
        task_env_value('points', '0')
    )
    print('Задание сохранено: ' + task_id)
    print()
    render_tasks_list(core.read_tasks())
    core.footer()
    raise SystemExit

if 'var_team' in os.environ and 'var_approved' in os.environ:
    approved = os.environ['var_approved'] == 'true'
    if core.set_team_approved(os.environ['var_team'], approved):
        if approved:
            print('Команда допущена к игре.')
        else:
            print('Допуск команды отозван.')
    else:
        print('Команда не найдена.')
    print('`!`[<Назад>`:' + back_link('teams'))
    core.footer()
    raise SystemExit

if 'var_user' in os.environ and 'var_enabled' not in os.environ and 'var_make_admin' not in os.environ and 'field_role' not in os.environ:
    target = os.environ['var_user']
    print('`!Пользователь: ' + target + '`!')
    print('`Ff00`!`[<Удалить>`:' + core.page_path + '/manage_users.mu`delete_user=' + target + '|view=users]`!`f')
    print()
    print('Статус учетной записи:')
    print('`!`[<Включить>`:' + core.page_path + '/manage_users.mu`enabled=true|user=' + target + '|view=users]`! `!`[<Отключить>`:' + core.page_path + '/manage_users.mu`enabled=false|user=' + target + '|view=users]`!')
    print()
    print('Роль: `B444`<role`' + all_users[target]['role'] + '>`b')
    print('`!`[<Сохранить роль>`:' + core.page_path + '/manage_users.mu`role|user=' + target + '|view=users]`!')
    print()
    print('Рекомендуемые роли: player, organizer.')
    print('`!`[<Выдать права администратора>`:' + core.page_path + '/manage_users.mu`make_admin=true|user=' + target + '|view=users]`! `!`[<Снять права администратора>`:' + core.page_path + '/manage_users.mu`make_admin=false|user=' + target + '|view=users]`!')
    core.footer()
    raise SystemExit

if 'var_delete_user' in os.environ:
    core.delete_user(os.environ['var_delete_user'])
    print('Пользователь удален.')
    print('`!`[<Назад>`:' + back_link('users'))
    core.footer()
    raise SystemExit

if 'var_enabled' in os.environ:
    core.user_enabled(os.environ['var_user'], os.environ['var_enabled'])
    print('Статус учетной записи изменен.')
    print('`!`[<Назад>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users]`!')
    core.footer()
    raise SystemExit

if 'var_make_admin' in os.environ:
    core.user_admin(os.environ['var_user'], os.environ['var_make_admin'])
    print('Права администратора изменены.')
    print('`!`[<Назад>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users]`!')
    core.footer()
    raise SystemExit

if 'field_role' in os.environ:
    core.user_role(os.environ['var_user'], os.environ['field_role'])
    print('Роль пользователя изменена.')
    print('`!`[<Назад>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users]`!')
    core.footer()
    raise SystemExit

if 'var_new_user' in os.environ:
    print('`!Добавить учетную запись`!')
    print()
    print('Имя пользователя: `B444`<username`>`b')
    print('Пароль          : `B444`<!|password`>`b')
    print('Повтор пароля   : `B444`<!|password2`>`b')
    print()
    print('`!`[<Добавить>`:' + core.page_path + '/manage_users.mu`username|password|password2|create_new_user=true|view=users]`!')
    core.footer()
    raise SystemExit

if 'var_create_new_user' in os.environ:
    if os.environ['field_username'] in all_users:
        print('Имя пользователя уже занято.')
    else:
        core.write_new_user(os.environ['field_username'], os.environ['field_password'])
        print('Пользователь добавлен.')
    print('`!`[<Назад>`:' + back_link('users'))
    core.footer()
    raise SystemExit

if view == 'overview':
    print('`!Обзор`!')
    print()
    print('Статус игры: ' + state.get('status', 'preparing'))
    print('`!`[<Подготовка>`:' + core.page_path + '/manage_users.mu`game_status=preparing]`! `!`[<Старт>`:' + core.page_path + '/manage_users.mu`game_status=running]`! `Ff00`!`[<Завершить>`:' + core.page_path + '/manage_users.mu`game_status=finished]`!`f')
    print()
    print('Команд: ' + str(len(teams)))
    print('Заданий: ' + str(len(tasks)))
    print('Участников: ' + str(len(all_users)))
    print()
    print('`!Результаты`!')
    leaderboard = core.get_leaderboard()
    if len(leaderboard) == 0:
        print('Результатов пока нет.')
    for row in leaderboard:
        print('- ' + row['team'] + ' | очки: ' + str(row['score']) + ' | заданий: ' + str(row['completed']) + '/' + str(row['total']) + ' | время: ' + core.format_duration(row.get('elapsed', 0)))
    core.footer()
    raise SystemExit

if view == 'teams':
    print('`!Команды`!')
    print()
    if len(teams) == 0:
        print('Заявок команд пока нет.')
    for team_id in teams:
        team = teams[team_id]
        status = 'ожидает допуска'
        if team.get('approved', False):
            status = 'допущена'
        print('- ' + team['name'] + ' | ' + status)
        print('  Капитан: ' + team['captain'] + ' | участники: ' + ', '.join(team.get('members', [])))
        print('  Токен: ' + team.get('invite_token', ''))
        print('  `!`[<Допустить>`:' + core.page_path + '/manage_users.mu`approved=true|team=' + team_id + '|view=teams]`! `!`[<Отозвать>`:' + core.page_path + '/manage_users.mu`approved=false|team=' + team_id + '|view=teams]`!')
    core.footer()
    raise SystemExit

if view == 'tasks':
    render_tasks_list(tasks)
    core.footer()
    raise SystemExit

if view == 'users':
    print('`!Участники и роли`!')
    print()
    print('`!`[<Новая учетная запись>`:' + core.page_path + '/manage_users.mu`new_user=true|view=users]`!')
    for user in all_users.items():
        admin_enabled = ''
        user_enabled = '(включен)'
        if user[1]['admin']:
            admin_enabled = '`!администратор`!'
        if not user[1]['enabled']:
            user_enabled = '(отключен)'
        print('`!`[<Редактировать>`:' + core.page_path + '/manage_users.mu`user=' + user[0] + '|view=users]`! | ' + user[0] + ' ' + user_enabled + ' | роль: ' + user[1]['role'] + ' | ' + admin_enabled)
    core.footer()
    raise SystemExit

print('Неизвестная вкладка панели организатора.')
core.footer()
