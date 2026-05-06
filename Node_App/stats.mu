#!/usr/bin/env python3

# Import required modules
import core
import os

def active_session_stats():
    active = core.read_active_sessions()
    return active

def user_stats():
    all_users = core.read_users()
    return all_users
    

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

sessions = active_session_stats()
users = user_stats()

# Display same thing, regardless of user logged in or not.
print('Current Stats:')
print()
print('Current users logged in: `!' + str(len(sessions)) + '`!')
print()
print('Registered users: `!' + str(len(users)) + '`!')
print()



# If user is logged in
if current_session:
    print('Users logged in now:')
    for user in sessions.items():
##        print(user[1]['username'])
        print('`!`[<' + user[1]['username'] + '>`:' + core.page_path + '/profile.mu`username=' + user[1]['username'] + ']`! - Logged in at ' + core.convert_time(user[1]['time']))
    print()
    
# Display footer text
core.footer()
