#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if current_session:
    if 'var_save' not in os.environ and 'var_new_password' not in os.environ:
        user_data = core.read_user_id(current_session['user_id'])
        user = core.read_users()[current_session['username']]
        admin_links = ''
        if user['admin']:
            admin_links = '\n`!`[<Manage Users>`:' + core.page_path + '/manage_users.mu]`!\n'
        print('`!Edit Profile`!')
        print(admin_links)
        print('Update Password: `B444`<!|password`>`b')
        print('`!`[<Update Password>`:' + core.page_path + '/my_profile.mu`password|new_password=true]`!')
        print()
        print('Name:            `B444`<name`' + user_data['profile']['name'] + '>`b')
        print()
        print('About:           `B444`<about`' + user_data['profile']['about'] + '>`b')
        print()
        print('LXMF Address:    `B444`<lxmf`' + user_data['profile']['lxmf'] + '>`b')

        print()
        print('`!`[<Save>`:' + core.page_path + '/my_profile.mu`name|lxmf|about|save=true]`!')
        print('`Ff00`!`[<Delete Account>`:' + core.page_path + '/delete_account.mu]`!`f')
        print('`!`[<Manage Identity>`:' + core.page_path + '/identity.mu]`!')
    elif 'var_save' in os.environ:
        core.update_profile(core.get_current_session(os.environ['link_id']), os.environ)
        print('Saved.')
        print('`!`[<Back>`:' + core.page_path + '/my_profile.mu]`!')
    elif 'var_new_password' in os.environ:
        core.update_password(current_session['username'], os.environ['field_password'])
        print('Password updated.')
        print('`!`[<Back>`:' + core.page_path + '/my_profile.mu]`!')
    
if not current_session:
    print('Not Authorized!')
    print('`!`[<Go to Home>`:' + core.page_path + '/index.mu]`!')

core.footer()
