import json
import uuid
import os
import datetime
import time
import hashlib

page_path = '/page/Node_App_Template'

# Directory to keep data such as user files, messages, etc.
data_directory = '/home/tushonochki/.nomadnetwork/storage/pages/Node_App_Template/app_data/'

# Title of your node page, appears on all pages
title = '`!Node App Template`! \n A template to make really cool NomadNet sites'

# Test that shows up at foot of all pages
footer_text = 'footer text here. other cool links.'

# Links to appear in the header
header_links = [
    '`!`[Example`:' + page_path + '/example.mu]`!',
    ]

# Use local time or UTC
use_local_time = False

# Enable or disable user registration
registration_enabled = True

# Welcome message for new users
welcome_message = 'Welcome to the node.'

# Default role for new users. A role can be usewd for anything.
default_role = 'user'

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
    try:
        os.remove(data_directory + '/user_blogs/' + username + '.json')
    except:
        pass
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

def read_user_messages(user_id):
    user_data = read_user_id(user_id)
    return user_data['messages']

def delete_user_message(user_id, message_id):
    user_data = read_user_id(user_id)
    new_list = []
    for message in user_data['messages']:
        if message_id == message['id']:
            pass
        elif message_id != message['id']:
            new_list.append(message)
    user_data['messages'] = new_list
    user_object = json.dumps(user_data, indent=4)
    with open(data_directory + 'users/' + user_id + '.json', "w") as user_file:
        user_file.write(user_object)
    print('Message deleted.')
    

def add_user_message(username, sending_user, subject, message):
    all_users = read_users()
    try:
        user_id = all_users[username]['user_id']
        user_data = read_user_id(user_id)
        user_data['messages'].insert(0, {'id': str(uuid.uuid4()),
                                         'from': sending_user,
                                         'subject': subject,
                                         'message': message,
                                         'time': time.time()
                                         })
        user_object = json.dumps(user_data, indent=4)
        with open(data_directory + 'users/' + user_id + '.json', "w") as user_file:
            user_file.write(user_object)
        print('Message sent.')
        
    except:
        print('Error sending message.')
    

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
    auth_link = '`!`[Login`:' + page_path + '/login.mu]`!'
    profile_link = ''
    if registration_enabled:
        profile_link = '`!`[Register`:' + page_path + '/register.mu]`! | '
    message_link = ''
    link_string = '| '
    for link in header_links:
        link_string = link_string  + link + ' |'
    if session:
        auth_link = '`!`[Logout`:' + page_path + '/logout.mu]`!'
        profile_link = '| `!`[Profile`:' + page_path + '/my_profile.mu]`! | '
        message_link = ' `!`[Messages`:' + page_path + '/messages.mu]`!'
##    print(os.environ)
    print('#!c=0')
    print('''
-
`c''' + title + '''
-
`!`[Home`:''' + page_path + '''/index.mu]`! ''' + link_string  + message_link + ''' ''' + profile_link + auth_link + ''' | ''' + get_time() + '''
`a
-
''')

def footer():
    print('-\n`c' + footer_text)
