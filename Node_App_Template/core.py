import json
import uuid
import os
import datetime
import time
import hashlib

page_path = '/page/Node_App_Template'

# Directory to keep data such as user files, messages, etc.
data_directory = os.path.join(os.path.dirname(__file__), 'app_data') + '/'

# Title of your node page, appears on all pages
title = '`!Городской квест`! \n Игровая платформа поверх Reticulum и NomadNet'

# Test that shows up at foot of all pages
footer_text = 'Файловая игровая платформа: команды, задания, ответы и итоги.'

# Links to appear in the header
header_links = []

# Use local time or UTC
use_local_time = False

# Enable or disable user registration
registration_enabled = True

# Welcome message for new users
welcome_message = 'Добро пожаловать на платформу городского квеста.'

# Default role for new users. A role can be usewd for anything.
default_role = 'player'

# Functionms below.
########### CHANGE ANYTHING BELOW HERE AT YOUR OWN RISK ##############

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
            "media": "Фото локации можно добавить в описание задания.",
            "answer_hash": hashlib.sha256("TOWER42".encode('utf-8')).hexdigest(),
            "points": 10,
            "enabled": True
        },
        "river_gate": {
            "title": "Речные ворота",
            "description": "Осмотрите знак у спуска к воде. Код состоит из букв и двух цифр.",
            "media": "Фотография ориентира: river_gate.jpg",
            "answer_hash": hashlib.sha256("RIVER17".encode('utf-8')).hexdigest(),
            "points": 15,
            "enabled": True
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

def upsert_task(task_id, title, description, media, answer, points, enabled):
    tasks = read_tasks()
    safe_task_id = task_id.strip()
    if safe_task_id == '':
        safe_task_id = str(uuid.uuid4())
    try:
        task_points = int(points)
    except:
        task_points = 0
    tasks[safe_task_id] = {
        "title": title,
        "description": description,
        "media": media,
        "answer_hash": hashlib.sha256(normalize_answer(answer).encode('utf-8')).hexdigest(),
        "points": task_points,
        "enabled": enabled
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
    rows = []
    for team_id in teams:
        progress = results.get(team_id, {"completed": {}, "score": 0, "finished_at": 0})
        rows.append({
            "team": teams[team_id]['name'],
            "score": progress.get('score', 0),
            "completed": len(progress.get('completed', {})),
            "finished_at": progress.get('finished_at', 0)
        })
    return sorted(rows, key=lambda row: (-row['score'], row['finished_at'] if row['finished_at'] > 0 else 9999999999))

def get_team_progress(team_id):
    results = read_results()
    return results.get(team_id, {"completed": {}, "wrong": {}, "score": 0, "finished_at": 0})

def submit_task_answer(team_id, username, task_id, answer):
    tasks = read_tasks()
    if task_id not in tasks or not tasks[task_id].get('enabled', True):
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
        enabled_tasks = [task for task in tasks if tasks[task].get('enabled', True)]
        if len(progress['completed']) >= len(enabled_tasks):
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
 
def read_user(username):
    with open(data_directory + 'users.json', 'r') as users_file:
        users = json.load(users_file)
        user = users[username]
    with open(data_directory + '/users/' + user['user_id'] + '.json', 'r') as user_file:
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
    # Set uyp user for "db"
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

    # Add user to "db"             
    all_users[username] = user_data
    user_object = json.dumps(all_users, indent=4)
    # Set user profile defaults
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
    # Write both to disk 
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
    # Write both to disk 
    with open(data_directory + 'users.json', "w") as user_file:
        user_file.write(user_object)
            
        
def update_profile(active_session, os_environ):
    user_data = read_user_id(active_session['user_id'])
    
    user_data['profile']['lxmf'] = os_environ['field_lxmf']
    user_data['profile']['name'] = os_environ['field_name']
    user_data['profile']['about'] = os_environ['field_about']

    write_user_profile(active_session['user_id'], user_data)

def read_profile_user_id(user_id):
     user_data = read_user_id(user_id)
     return user_data

def read_profile_username(username):
     all_users = read_users()
     user_id = all_users[username]['user_id']
     user_data = read_user_id(user_id)
     return user_data
    

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

##def process_text(text):
##    return re.sub(' @', '', text)
    
    
def get_time():
    if use_local_time == True:
        return datetime.datetime.now().strftime("%H:%M %m/%d/%Y")
    return datetime.datetime.utcnow().strftime("%H:%M %m/%d/%Y")

def convert_time(time):
    if use_local_time == True:
        return datetime.datetime.fromtimestamp(time).strftime("%H:%M %m/%d/%Y")
    return datetime.datetime.utcfromtimestamp(time).strftime("%H:%M %m/%d/%Y")



def header(session):
    links = ['`!`[Главная`:' + page_path + '/index.mu]`!']
    if session:
        if is_organizer(session):
            links.append('`!`[Обзор`:' + page_path + '/manage_users.mu]`!')
            links.append('`!`[Команды`:' + page_path + '/manage_users.mu`view=teams]`!')
            links.append('`!`[Задания`:' + page_path + '/manage_users.mu`view=tasks]`!')
            links.append('`!`[Участники`:' + page_path + '/manage_users.mu`view=users]`!')
        else:
            links.append('`!`[Задания`:' + page_path + '/index.mu]`!')
            links.append('`!`[Команда`:' + page_path + '/team.mu]`!')
        links.append('`!`[Профиль`:' + page_path + '/my_profile.mu]`!')
        links.append('`!`[Выход`:' + page_path + '/logout.mu]`!')
    else:
        if registration_enabled:
            links.append('`!`[Регистрация`:' + page_path + '/register.mu]`!')
        links.append('`!`[Вход`:' + page_path + '/login.mu]`!')
##    print(os.environ)
    print('#!c=0')
    print('''
-
`c''' + title + '''
-
''' + ' | '.join(links) + ''' | ''' + get_time() + '''
`a
-
''')

def footer():
    print('-\n`c' + footer_text)
