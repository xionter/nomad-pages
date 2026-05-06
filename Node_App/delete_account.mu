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

# If user is logged in
if current_session:
    if 'var_confirm_delete' in os.environ:
        print('Account deleted.')
        print()
        print('`!`[<Go to Home>`:' + core.page_path + '/index.mu]`!')
        core.delete_user(current_session['username'])
        
    if 'var_confirm_delete' not in os.environ:
        print('''
Delete account?

`Ff00`!`[<Yes, delete it!>`:''' + core.page_path + '''/delete_account.mu`confirm_delete=true]`!`f `!`[<No, go back!>`:''' + core.page_path + '''/my_profile.mu]`!
''')
##    if 'confirm_delete' in os.environ:
##        print('delete it')
    
# If user is logged out
if not current_session:
    print('No account to delete.')
    print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')
    
# Display footer text
core.footer()
