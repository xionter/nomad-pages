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
    all_users = core.read_users()
    admin_user = all_users[current_session['username']]['admin']
    
    if admin_user:
        if 'var_user' in os.environ and 'var_enabled' not in os.environ and 'var_make_admin' not in os.environ and 'field_role' not in os.environ:
            print('`!`[<Back>`:' + core.page_path + '/manage_users.mu]`! `Ff00`!`[<Delete>`:' + core.page_path + '/manage_users.mu`delete_user=' + os.environ['var_user'] + ']`!`f `!`[<Profile>`:' + core.page_path + '/profile.mu`username=' + os.environ['var_user'] + ']`! `!`[<Send Message>`:' + core.page_path + '/messages.mu`new_message=' + os.environ['var_user'] + ']`!')
            print()
            print('User: `!' + os.environ['var_user'] + '`!')
            print('`!`[<Enable User>`:' + core.page_path + '/manage_users.mu`enabled=true|user=' + os.environ['var_user'] + ']`! `!`[<Disable user>`:' + core.page_path + '/manage_users.mu`enabled=false|user=' + os.environ['var_user'] + ']`!')
            print()
            print('Role:    `B444`<role`' + all_users[os.environ['var_user']]['role'] + '>`b')
            print('`!`[<Save>`:' + core.page_path + '/manage_users.mu`role|user=' + os.environ['var_user'] + ']`!')
            print()
            print('`!`[<Enable Admin>`:' + core.page_path + '/manage_users.mu`make_admin=true|user=' + os.environ['var_user'] + ']`! `!`[<Disable Admin>`:' + core.page_path + '/manage_users.mu`make_admin=false|user=' + os.environ['var_user'] + ']`!')

        elif 'var_delete_user' in os.environ:
            core.delete_user(os.environ['var_delete_user'])
            print('User deleted.')
            print('`!`[<Back>`:' + core.page_path + '/manage_users.mu]`!')

        elif 'var_enabled' in os.environ:
            if os.environ['var_enabled'] == 'true':
                core.user_enabled(os.environ['var_user'], os.environ['var_enabled'])
                print('User enabled.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + ']`!')
            if os.environ['var_enabled'] == 'false':
                core.user_enabled(os.environ['var_user'], os.environ['var_enabled'])
                print('User disabled.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + ']`!')
                
        elif 'var_make_admin' in os.environ:
            if os.environ['var_make_admin'] == 'true':
                core.user_admin(os.environ['var_user'], os.environ['var_make_admin'])
                print('User is now an administrator.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + ']`!')
            if os.environ['var_make_admin'] == 'false':
                core.user_admin(os.environ['var_user'], os.environ['var_make_admin'])
                print('User is NOT an administrator.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + ']`!')

        elif 'field_role' in os.environ:
            core.user_role(os.environ['var_user'], os.environ['field_role'])
            print('Changed user role.')
            print('`!`[<Back>`:' + core.page_path + '/manage_users.mu`user=' + os.environ['var_user'] + ']`!')



        elif 'var_new_user' in os.environ:
            print('`!Add a new account`!')
            print()
            print('Username        : `B444`<username`>`b')
            print()
            print('Password        : `B444`<!|password`>`b')
            print()
            print('Confirm Password: `B444`<!|password2`>`b')
            print()
            print('`!`[<Add>`:' + core.page_path + '/manage_users.mu`username|password|password2|create_new_user=true]`!')

        elif 'var_create_new_user' in os.environ:
            try:
                core.read_users()[os.environ['field_username']]
                print('Username already used.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu]`!')
            except:
                print('User added.')
                print('`!`[<Back>`:' + core.page_path + '/manage_users.mu]`!')

                core.write_new_user(os.environ['field_username'], os.environ['field_password'])
        
        elif 'var_user' not in os.environ and 'var_create_new_user' not in os.environ and 'var_new_user' not in os.environ and 'var_delete_user' not in os.environ:
            print('`!`[<New User>`:' + core.page_path + '/manage_users.mu`new_user=true]`!')
            print()
            for user in all_users.items():
                admin_enabled = ''
                user_enabled = '(ENABLED)'
                if user[1]['admin']:
                    admin_enabled = '`!ADMIN ENABLED`!'
                if not user[1]['enabled']:
                    user_enabled = '(DISABLED)'
                print('`!`[<Edit>`:' + core.page_path + '/manage_users.mu`user=' + user[0] + ']`! | ' + user[0] + ' ' + user_enabled + ' | ' + user[1]['role'] + ' | ' + admin_enabled)
            print()
        
    elif not admin_user:
        print('Not authorized.')
        print('`!`[<Go to Home>`:' + core.page_path + '/index.mu]`!')

    
# If user is logged out
if not current_session:
    print('Not authorized')
    print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')

# Display footer text
core.footer()
