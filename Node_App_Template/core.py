import json
import uuid
import os
import datetime
import time
import hashlib

page_path = '/page/Node_App_Template'

data_directory = os.path.join(os.path.dirname(__file__), 'app_data') + '/'

title = '`!Городской квест`! \n Игровая платформа поверх Reticulum и NomadNet'
footer_text = 'Файловая игровая платформа: команды, задания, ответы и итоги.'

color_primary = '0ff'
color_secondary = '5af'
color_success = '5f8'
color_warning = 'fc5'
color_danger = 'f55'
color_dim = '66a'
color_input_bg = '224'
color_nav_active = 'fc5'

use_local_time = False
registration_enabled = True
welcome_message = 'Добро пожаловать на платформу городского квеста.'
default_role = 'player'

def fg(text, color=color_primary):
    return '`F' + color + text + '`f'

def bg(text, color=color_input_bg):
    return '`B' + color + text + '`b'

def strong(text):
    return '`!' + text + '`!'

def heading(text):
    return fg(strong(text), color_primary)

def subheading(text):
    return fg(strong(text), color_secondary)

def muted(text):
    return '`g' + text + '`f'

def status_badge(text, color=color_secondary):
    return '`F000`B' + color + ' ' + text + ' `b`f'

def action(label, target, color=color_primary):
    return '`F' + color + '`!`[<' + label + '>`:' + target + ']`!`f'

def active_action(label, target, color=color_nav_active):
    return '`F000`B' + color + '`!`[< ' + label + ' >`:' + target + ']`!`b`f'

def nav_action(label, target, key, active_key, color=color_secondary):
    if key == active_key:
        return active_action(label, target)
    return action(label, target, color)

def danger_action(label, target):
    return action(label, target, color_danger)

def field(name, value='', width=''):
    if width != '':
        field_markup = '`<' + width + '|' + name + '`' + value + '>'
    else:
        field_markup = '`<' + name + '`' + value + '>'
    return bg(field_markup)

def password_field(name, width=''):
    if width != '':
        field_markup = '`<!' + width + '|' + name + '`>'
    else:
        field_markup = '`<!|' + name + '`>'
    return bg(field_markup)

def read_active_sessions():
    with open(data_directory + 'active_sessions.json', 'r') as session_file:
        active_sessions = json.load(session_file)
        return active_sessions

def read_users():
     with open(data_directory + 'users.json', 'r') as users_file:
        users = json.load(users_file)
        return users

def read_json_file(filename, default_value):
    path = data_directory + filename
    try:
        with open(path, 'r') as json_file:
            return json.load(json_file)
    except:
        return default_value

def write_json_file(filename, data):
    with open(data_directory + filename, "w") as json_file:
        json_file.write(json.dumps(data, indent=4, ensure_ascii=False))

def read_teams():
    return read_json_file('teams.json', {})

def write_teams(teams):
    write_json_file('teams.json', teams)

def read_tasks():
    return read_json_file('tasks.json', default_tasks())

def write_tasks(tasks):
    write_json_file('tasks.json', tasks)

def read_results():
    return read_json_file('results.json', {})

def write_results(results):
    write_json_file('results.json', results)

def read_game_state():
    return read_json_file('game_state.json', {"status": "preparing", "started_at": 0, "ends_at": 0})

def write_game_state(state):
    write_json_file('game_state.json', state)

def default_tasks():
    return {
        "old_tower": {
            "title": "Старая башня",
            "description": "Найдите табличку у башни и введите код, нанесенный рядом с датой постройки.",
            "answer": "TOWER42",
            "answer_hash": hashlib.sha256("TOWER42".encode('utf-8')).hexdigest(),
            "points": 10
        },
        "river_gate": {
            "title": "Речные ворота",
            "description": "Осмотрите знак у спуска к воде. Код состоит из букв и двух цифр.",
            "answer": "RIVER17",
            "answer_hash": hashlib.sha256("RIVER17".encode('utf-8')).hexdigest(),
            "points": 15
        }
    }

def normalize_answer(answer):
    return answer.strip().upper()

def is_organizer(session):
    if not session:
        return False
    user = read_users().get(session['username'])
    if user is None:
        return False
    return user.get('admin') == True or user.get('role') == 'organizer'

def find_user_team(username):
    teams = read_teams()
    for team_id in teams:
        team = teams[team_id]
        if username == team.get('captain') or username in team.get('members', []):
            return team_id, team
    return None, None

def create_team(captain_username, team_name):
    teams = read_teams()
    current_team_id, current_team = find_user_team(captain_username)
    if current_team:
        return current_team_id, current_team
    team_id = str(uuid.uuid4())
    invite_token = str(uuid.uuid4())
    teams[team_id] = {
        "id": team_id,
        "name": team_name,
        "captain": captain_username,
        "members": [captain_username],
        "invite_token": invite_token,
        "approved": False,
        "created_at": time.time()
    }
    write_teams(teams)
    return team_id, teams[team_id]

def join_team_by_token(username, token):
    teams = read_teams()
    for team_id in teams:
        team = teams[team_id]
        if team.get('invite_token') == token:
            if username not in team.get('members', []):
                team['members'].append(username)
                write_teams(teams)
            return team_id, team
    return None, None

def set_team_approved(team_id, approved):
    teams = read_teams()
    if team_id in teams:
        teams[team_id]['approved'] = approved
        write_teams(teams)
        return True
    return False

def upsert_task(task_id, title, description, answer, points):
    tasks = read_tasks()
    safe_task_id = task_id.strip()
    if safe_task_id == '':
        safe_task_id = str(uuid.uuid4())
    try:
        task_points = int(points)
    except:
        task_points = 0
    answer_value = answer.strip()
    answer_hash = ''
    if answer.strip() != '':
        answer_hash = hashlib.sha256(normalize_answer(answer).encode('utf-8')).hexdigest()
    elif safe_task_id in tasks:
        answer_value = tasks[safe_task_id].get('answer', '')
        answer_hash = tasks[safe_task_id].get('answer_hash', '')
    else:
        answer_hash = hashlib.sha256(normalize_answer(answer).encode('utf-8')).hexdigest()
    tasks[safe_task_id] = {
        "title": title,
        "description": description,
        "answer": answer_value,
        "answer_hash": answer_hash,
        "points": task_points
    }
    write_tasks(tasks)
    return safe_task_id

def delete_task(task_id):
    tasks = read_tasks()
    if task_id in tasks:
        del tasks[task_id]
        write_tasks(tasks)
        return True
    return False

def set_game_status(status):
    state = read_game_state()
    state['status'] = status
    if status == 'running':
        state['started_at'] = time.time()
    if status == 'finished':
        state['ends_at'] = time.time()
    write_game_state(state)

def get_leaderboard():
    teams = read_teams()
    results = read_results()
    tasks = read_tasks()
    state = read_game_state()
    rows = []
    for team_id in teams:
        progress = results.get(team_id, {"completed": {}, "wrong": {}, "score": 0, "finished_at": 0})
        finished_at = progress.get('finished_at', 0)
        elapsed = 0
        if finished_at > 0 and state.get('started_at', 0) > 0 and finished_at >= state.get('started_at', 0):
            elapsed = finished_at - state.get('started_at', 0)
        rows.append({
            "team_id": team_id,
            "team": teams[team_id]['name'],
            "captain": teams[team_id].get('captain', ''),
            "approved": teams[team_id].get('approved', False),
            "score": progress.get('score', 0),
            "completed": len(progress.get('completed', {})),
            "total": len(tasks),
            "wrong": sum(progress.get('wrong', {}).values()),
            "finished_at": finished_at,
            "elapsed": elapsed
        })
    return sorted(rows, key=lambda row: (-row['score'], row['finished_at'] if row['finished_at'] > 0 else 9999999999))

def format_duration(seconds):
    if seconds <= 0:
        return '-'
    seconds = int(seconds)
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60
    if hours > 0:
        return str(hours) + 'ч ' + str(minutes) + 'м ' + str(secs) + 'с'
    if minutes > 0:
        return str(minutes) + 'м ' + str(secs) + 'с'
    return str(secs) + 'с'

def get_team_progress(team_id):
    results = read_results()
    return results.get(team_id, {"completed": {}, "wrong": {}, "score": 0, "finished_at": 0})

def submit_task_answer(team_id, username, task_id, answer):
    tasks = read_tasks()
    if task_id not in tasks:
        return False, "Задание недоступно."
    state = read_game_state()
    if state.get('status') != 'running':
        return False, "Игра не запущена. Ввод кодов закрыт."
    results = read_results()
    progress = results.get(team_id, {"completed": {}, "wrong": {}, "score": 0, "finished_at": 0})
    if task_id in progress.get('completed', {}):
        return True, "Задание уже выполнено."
    answer_hash = hashlib.sha256(normalize_answer(answer).encode('utf-8')).hexdigest()
    if answer_hash == tasks[task_id]['answer_hash']:
        progress['completed'][task_id] = {"user": username, "time": time.time()}
        progress['score'] = progress.get('score', 0) + int(tasks[task_id].get('points', 0))
        if len(progress['completed']) >= len(tasks):
            progress['finished_at'] = time.time()
        results[team_id] = progress
        write_results(results)
        return True, "Верно. Задание засчитано команде."
    wrong = progress.get('wrong', {})
    wrong[task_id] = wrong.get(task_id, 0) + 1
    progress['wrong'] = wrong
    results[team_id] = progress
    write_results(results)
    return False, "Неверно. Проверьте код и повторите попытку позже."

def read_user_id(user_id):
    with open(data_directory + 'users/' + user_id + '.json', 'r') as user_file:
         user_data = json.load(user_file)
         return user_data
 
def trim_active_sessions():
    current_sessions = read_active_sessions()
    del_list = []
    for session in current_sessions.items():
        if time.time() > session[1]['time'] + (60 * 30):
            del_list.append(session[0])
    for session in del_list:
        del current_sessions[session]
    session_object = json.dumps(current_sessions, indent=4)
    with open(data_directory + 'active_sessions.json', "w") as session_file:
        session_file.write(session_object)

def add_active_session(link_id, user_id, user_data, role):
    current_sessions = read_active_sessions()         
    current_sessions[link_id] = {'user_id': user_id, 'username': user_data['username'], "role": role, "time": time.time()}
    session_object = json.dumps(current_sessions, indent=4)
     
    with open(data_directory + 'active_sessions.json', "w") as session_file:
        session_file.write(session_object)

def get_current_session(link_id):
    active_sessions = read_active_sessions()
    if link_id not in active_sessions:
        return False
    return active_sessions[link_id]

def authenticate_user(username, password):
    user_data = read_users().get(username)
    if user_data is None:
        return False
    hash_password = hashlib.sha256(password.encode('utf-8')).hexdigest()
    if user_data['password'] == hash_password and user_data['enabled'] == True:
        return True
    else:
        return False

def deauthenticate_user(link_id):
    current_sessions = read_active_sessions()
    del current_sessions[link_id]
    
    active_sessions = json.dumps(current_sessions, indent=4)
     
    with open(data_directory + 'active_sessions.json', "w") as session_file:
        session_file.write(active_sessions)

def write_user_profile(user_id, user_data):
    user_object = json.dumps(user_data, indent=4)
     
    with open(data_directory + 'users/' + user_id + '.json', "w") as user_file:
        user_file.write(user_object)

def write_new_user(username, password):
    all_users = read_users()
    user_uuid = str(uuid.uuid4())
    hash_password = hashlib.sha256(password.encode('utf-8')).hexdigest()
    user_data = {
        "user_id": user_uuid,
        "password": hash_password,
        "role": default_role,
        "enabled": True,
        "admin": False,
        "identity": ""
        }

    all_users[username] = user_data
    user_object = json.dumps(all_users, indent=4)
    user_profile_data = {
        "username": username,
        "remote_identity": "",
        "profile": {
            "name": "",
            "lxmf": "",
            "about": ""
        },
        "messages": [
                    {
                    "id": str(uuid.uuid4()),
                    "from": "admin",
                    "subject": "Welcome",
                    "message": welcome_message,
                    "time": 0.0
                    }
            ]
        }
    user_profile_object = json.dumps(user_profile_data, indent=4)
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)
        
    with open(data_directory + 'users/' + user_uuid + '.json', "w") as user_profile_file:
        user_profile_file.write(user_profile_object)

def user_enabled(username, enabled):
    if enabled == 'true':
        bool_enabled = True
    if enabled == 'false':
        bool_enabled = False
    all_users = read_users()
    user = all_users[username]
    user['enabled'] = bool_enabled

    user_object = json.dumps(all_users, indent=4)

    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

def user_admin(username, enabled):
    if enabled == 'true':
        bool_enabled = True
    if enabled == 'false':
        bool_enabled = False
    all_users = read_users()
    user = all_users[username]
    user['admin'] = bool_enabled

    user_object = json.dumps(all_users, indent=4)

    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

def user_role(username, role):
    all_users = read_users()
    user = all_users[username]
    user['role'] = role

    user_object = json.dumps(all_users, indent=4)

    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

        

def delete_user(username):
    for session in read_active_sessions().items():
        if session[1]['username'] == username:
            deauthenticate_user(os.environ['link_id'])
    all_users = read_users()
    user_id = all_users[username]['user_id']
    os.remove(data_directory + 'users/' + user_id + '.json')
    del all_users[username]
    user_object = json.dumps(all_users, indent=4)
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)
            
        
def update_profile(active_session, os_environ):
    user_data = read_user_id(active_session['user_id'])
    
    user_data['profile']['lxmf'] = os_environ['field_lxmf']
    user_data['profile']['name'] = os_environ['field_name']
    user_data['profile']['about'] = os_environ['field_about']

    write_user_profile(active_session['user_id'], user_data)

def update_password(username, password):
    all_users = read_users()
    hash_password = hashlib.sha256(password.encode('utf-8')).hexdigest()
    all_users[username]['password'] = hash_password
    user_object = json.dumps(all_users, indent=4)
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

def check_identity(identity):
    all_users = read_users()
    for user in all_users.items():
        if user[1]['identity'] == identity:
            return  user

def add_identity(username, identity):
    all_users = read_users()
    all_users[username]['identity'] = identity
    
    user_object = json.dumps(all_users, indent=4)
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

def delete_identity(username, identity):
    all_users = read_users()
    all_users[username]['identity'] = ''
    
    user_object = json.dumps(all_users, indent=4)
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)

def get_time():
    if use_local_time == True:
        return datetime.datetime.now().strftime("%H:%M %m/%d/%Y")
    return datetime.datetime.utcnow().strftime("%H:%M %m/%d/%Y")

def header(session, active_key='home'):
    links = []
    if session:
        if is_organizer(session):
            links.append(nav_action('Главная', page_path + '/index.mu', 'home', active_key))
            links.append(nav_action('Обзор', page_path + '/manage_users.mu', 'overview', active_key))
            links.append(nav_action('Команды', page_path + '/manage_users.mu`view=teams', 'teams', active_key))
            links.append(nav_action('Задания', page_path + '/manage_users.mu`view=tasks', 'tasks', active_key))
            links.append(nav_action('Лидерборд', page_path + '/leaderboard.mu', 'leaderboard', active_key))
            links.append(nav_action('Участники', page_path + '/manage_users.mu`view=users', 'users', active_key))
        else:
            links.append(nav_action('Задания', page_path + '/index.mu', 'home', active_key))
            links.append(nav_action('Команда', page_path + '/team.mu', 'team', active_key))
            links.append(nav_action('Лидерборд', page_path + '/leaderboard.mu', 'leaderboard', active_key))
        links.append(nav_action('Профиль', page_path + '/my_profile.mu', 'profile', active_key, color_warning))
        links.append(action('Выход', page_path + '/logout.mu', color_danger))
    else:
        links.append(nav_action('Главная', page_path + '/index.mu', 'home', active_key))
        if registration_enabled:
            links.append(nav_action('Регистрация', page_path + '/register.mu', 'register', active_key))
        links.append(nav_action('Вход', page_path + '/login.mu', 'login', active_key, color_warning))
    print('#!c=0')
    print('#!fg=ddd')
    print('#!bg=000')
    print('''
`c`F0ff
-=
''' + title + '''
=-
`f
''' + ' | '.join(links) + ''' | ''' + get_time() + '''
`a
-
''')

def footer():
    print('-\n`c' + muted(footer_text) + '  ' + status_badge('NomadNet', color_dim))
