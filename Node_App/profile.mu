#!/usr/bin/env python3

# Import required modules
import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

##print(os.environ)

# If user is logged in
if current_session:
    if 'var_username' in os.environ:
        try:
            user_data = core.read_profile_username(os.environ['var_username'])
            print('''
Username: `!''' + user_data['username'] + '''`!
Name: `!''' + user_data['profile']['name'] + '''`!
LXMF: `!<`[lxmf@''' + user_data['profile']['lxmf'] + ''']>`!

About: `!''' + user_data['profile']['about'] + '''`!

`c`!`[<Message ''' + user_data['username'] + '''>`:''' + core.page_path + '''/messages.mu`new_message=''' + user_data['username'] + ''']`!
`a
    ''')
        except:
            print('Error viewing profile.')
            print('`!`[<Continue to Messages>`:' + core.page_path + '/messages.mu]`!')

##    elif 'var_username_id' not in os.environ:
##        print('Not implemented yet.')
    
# If user is logged out
if not current_session:
    print('You must be logged in.')
    print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')

# Display footer text
core.footer()
