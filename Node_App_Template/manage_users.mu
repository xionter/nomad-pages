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
    print(core.heading('Задания'))
    print()
    print(core.action('Новое задание', core.page_path + '/manage_users.mu`new_task=true|view=tasks', core.color_warning))
    print()
    if len(tasks) == 0:
        print('Заданий пока нет.')
    for task_id in tasks:
        task = tasks[task_id]
        print('- ' + core.fg(core.strong(task.get('title', task_id)), core.color_secondary) + ' | ' + str(task.get('points', 0)) + ' очков')
        print('  ' + task.get('description', ''))
        print('  ' + core.action('Редактировать', core.page_path + '/manage_users.mu`edit_task=' + task_id + '|view=tasks'))

if 'var_game_status' in os.environ:
    core.set_game_status(os.environ['var_game_status'])
    print('Статус игры изменен: ' + core.status_badge(os.environ['var_game_status'], core.color_warning))
    print(core.action('Назад', core.page_path + '/manage_users.mu`view=overview'))
    core.footer()
    raise SystemExit

if 'var_delete_task' in os.environ:
    if core.delete_task(os.environ['var_delete_task']):
        print(core.fg('Задание удалено.', core.color_warning))
    else:
        print(core.fg('Задание не найдено.', core.color_danger))
    print(core.action('Назад', core.page_path + '/manage_users.mu`view=tasks'))
    core.footer()
    raise SystemExit

if ('var_edit_task' in os.environ or 'var_new_task' in os.environ) and not has_task_form_submission():
    task_id = os.environ.get('var_edit_task', '')
    task = tasks.get(task_id, {"title": "", "description": "", "points": 10})
    if 'var_new_task' in os.environ:
        print(core.heading('Новое задание'))
    else:
        print(core.heading('Редактирование задания: ' + task.get('title', task_id)))
    print()
    print('Название: ' + core.field('task_title', task.get('title', '')))
    print('Описание: ' + core.field('task_description', task.get('description', '')))
    print('Ответ: ' + core.field('task_answer', task.get('answer', '')))
    print('Очки: ' + core.field('task_points', str(task.get('points', 10))))
    print()
    if 'var_new_task' in os.environ:
        print(core.action('Создать', core.page_path + '/manage_users.mu`task_title|task_description|task_answer|task_points|new_task=true|view=tasks', core.color_warning))
    else:
        print(core.action('Сохранить', core.page_path + '/manage_users.mu`task_title|task_description|task_answer|task_points|edit_task=' + task_id + '|view=tasks', core.color_warning))
        print(core.danger_action('Удалить', core.page_path + '/manage_users.mu`delete_task=' + task_id + '|view=tasks'))
    print(core.action('К списку заданий', core.page_path + '/manage_users.mu`view=tasks'))
    core.footer()
    raise SystemExit

if has_task_form_submission():
    title = task_env_value('title').strip()
    if title == '':
        print(core.fg('Название задания не может быть пустым.', core.color_danger))
        print('Поля формы не были переданы в страницу сохранения. Откройте форму задания заново из вкладки «Задания».')
        print(core.action('Назад', core.page_path + '/manage_users.mu`view=tasks'))
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
    print(core.fg('Задание сохранено: ' + task_id, core.color_success))
    print()
    render_tasks_list(core.read_tasks())
    core.footer()
    raise SystemExit

if 'var_team' in os.environ and 'var_approved' in os.environ:
    approved = os.environ['var_approved'] == 'true'
    if core.set_team_approved(os.environ['var_team'], approved):
        if approved:
            print(core.fg('Команда допущена к игре.', core.color_success))
        else:
            print(core.fg('Допуск команды отозван.', core.color_warning))
    else:
        print(core.fg('Команда не найдена.', core.color_danger))
    print(core.action('Назад', core.page_path + '/manage_users.mu`view=teams'))
    core.footer()
    raise SystemExit

if 'var_user' in os.environ and 'var_enabled' not in os.environ and 'var_make_admin' not in os.environ and 'field_role' not in os.environ:
    target = os.environ['var_user']
    print(core.heading('Пользователь: ' + target))
    print(core.danger_action('Удалить', core.page_path + '/manage_users.mu`delete_user=' + target + '|view=users'))
    print()
    print('Статус учетной записи:')
    print(core.action('Включить', core.page_path + '/manage_users.mu`enabled=true|user=' + target + '|view=users', core.color_success) + ' ' + core.danger_action('Отключить', core.page_path + '/manage_users.mu`enabled=false|user=' + target + '|view=users'))
    print()
    print('Роль: ' + core.field('role', all_users[target]['role']))
    print(core.action('Сохранить роль', core.page_path + '/manage_users.mu`role|user=' + target + '|view=users', core.color_warning))
    print()
    print('Рекомендуемые роли: player, organizer.')
    print(core.action('Выдать права администратора', core.page_path + '/manage_users.mu`make_admin=true|user=' + target + '|view=users', core.color_success) + ' ' + core.danger_action('Снять права администратора', core.page_path + '/manage_users.mu`make_admin=false|user=' + target + '|view=users'))
    core.footer()
    raise SystemExit

if 'var_delete_user' in os.environ:
    core.delete_user(os.environ['var_delete_user'])
    print(core.fg('Пользователь удален.', core.color_warning))
    print(core.action('Назад', core.page_path + '/manage_users.mu`view=users'))
    core.footer()
    raise SystemExit

if 'var_enabled' in os.environ:
    core.user_enabled(os.environ['var_user'], os.environ['var_enabled'])
    print(core.fg('Статус учетной записи изменен.', core.color_success))
    print(core.action('Назад', core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users'))
    core.footer()
    raise SystemExit

if 'var_make_admin' in os.environ:
    core.user_admin(os.environ['var_user'], os.environ['var_make_admin'])
    print(core.fg('Права администратора изменены.', core.color_success))
    print(core.action('Назад', core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users'))
    core.footer()
    raise SystemExit

if 'field_role' in os.environ:
    core.user_role(os.environ['var_user'], os.environ['field_role'])
    print(core.fg('Роль пользователя изменена.', core.color_success))
    print(core.action('Назад', core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + '|view=users'))
    core.footer()
    raise SystemExit

if 'var_new_user' in os.environ:
    print(core.heading('Добавить учетную запись'))
    print()
    print('Имя пользователя: ' + core.field('username'))
    print('Пароль          : ' + core.password_field('password'))
    print('Повтор пароля   : ' + core.password_field('password2'))
    print()
    print(core.action('Добавить', core.page_path + '/manage_users.mu`username|password|password2|create_new_user=true|view=users', core.color_warning))
    core.footer()
    raise SystemExit

if 'var_create_new_user' in os.environ:
    if os.environ['field_username'] in all_users:
        print(core.fg('Имя пользователя уже занято.', core.color_danger))
    else:
        core.write_new_user(os.environ['field_username'], os.environ['field_password'])
        print(core.fg('Пользователь добавлен.', core.color_success))
    print(core.action('Назад', core.page_path + '/manage_users.mu`view=users'))
    core.footer()
    raise SystemExit

if view == 'overview':
    print(core.heading('Обзор'))
    print()
    print('Статус игры: ' + core.status_badge(state.get('status', 'preparing'), core.color_warning))
    print(core.action('Подготовка', core.page_path + '/manage_users.mu`game_status=preparing') + ' ' + core.action('Старт', core.page_path + '/manage_users.mu`game_status=running', core.color_success) + ' ' + core.danger_action('Завершить', core.page_path + '/manage_users.mu`game_status=finished'))
    print()
    print('Команд: ' + core.fg(str(len(teams)), core.color_secondary))
    print('Заданий: ' + core.fg(str(len(tasks)), core.color_secondary))
    print('Участников: ' + core.fg(str(len(all_users)), core.color_secondary))
    print()
    print(core.subheading('Результаты'))
    leaderboard = core.get_leaderboard()
    if len(leaderboard) == 0:
        print('Результатов пока нет.')
    for row in leaderboard:
        print('- ' + core.fg(row['team'], core.color_secondary) + ' | очки: ' + core.fg(str(row['score']), core.color_success) + ' | заданий: ' + str(row['completed']) + '/' + str(row['total']) + ' | время: ' + core.format_duration(row.get('elapsed', 0)))
    core.footer()
    raise SystemExit

if view == 'teams':
    print(core.heading('Команды'))
    print()
    if len(teams) == 0:
        print('Заявок команд пока нет.')
    for team_id in teams:
        team = teams[team_id]
        status = 'ожидает допуска'
        if team.get('approved', False):
            status = 'допущена'
        status_color = core.color_success if team.get('approved', False) else core.color_warning
        print('- ' + core.fg(team['name'], core.color_secondary) + ' | ' + core.status_badge(status, status_color))
        print('  Капитан: ' + team['captain'] + ' | участники: ' + ', '.join(team.get('members', [])))
        print('  Токен: ' + core.fg(team.get('invite_token', ''), core.color_warning))
        print('  ' + core.action('Допустить', core.page_path + '/manage_users.mu`approved=true|team=' + team_id + '|view=teams', core.color_success) + ' ' + core.danger_action('Отозвать', core.page_path + '/manage_users.mu`approved=false|team=' + team_id + '|view=teams'))
    core.footer()
    raise SystemExit

if view == 'tasks':
    render_tasks_list(tasks)
    core.footer()
    raise SystemExit

if view == 'users':
    print(core.heading('Участники и роли'))
    print()
    print(core.action('Новая учетная запись', core.page_path + '/manage_users.mu`new_user=true|view=users', core.color_warning))
    for user in all_users.items():
        admin_enabled = ''
        user_enabled = '(включен)'
        if user[1]['admin']:
            admin_enabled = core.fg(core.strong('администратор'), core.color_warning)
        if not user[1]['enabled']:
            user_enabled = '(отключен)'
        print(core.action('Редактировать', core.page_path + '/manage_users.mu`user=' + user[0] + '|view=users') + ' | ' + user[0] + ' ' + user_enabled + ' | роль: ' + core.fg(user[1]['role'], core.color_secondary) + ' | ' + admin_enabled)
    core.footer()
    raise SystemExit

print('Неизвестная вкладка панели организатора.')
core.footer()
