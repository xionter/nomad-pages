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
    if 'remote_identity' in os.environ and 'var_add_identity' not in os.environ and 'var_delete_identity' not in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + os.environ['remote_identity'])
        print()
        print('`!`[<Привязать>`:' + core.page_path + '/identity.mu`add_identity=true]`! `Ff00`!`[<Отвязать>`:' + core.page_path + '/identity.mu`delete_identity=true]`!`f')

        
    if 'remote_identity' in os.environ and 'var_add_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + os.environ['remote_identity'])
        print('Идентичность привязана к аккаунту. При следующем подключении система сможет создать сессию автоматически.')
        print('`!`[<Назад>`:' + core.page_path + '/my_profile.mu]`!')
        core.add_identity(current_session['username'], os.environ['remote_identity'])

    elif 'remote_identity' in os.environ and 'var_delete_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + os.environ['remote_identity'])
        print('Идентичность отвязана от аккаунта.')
        print('`!`[<Назад>`:' + core.page_path + '/my_profile.mu]`!')
        core.delete_identity(current_session['username'], os.environ['remote_identity'])
        
    if 'remote_identity' not in os.environ:
        print('NomadNet не передал remote_identity для текущего подключения.')
        print('`!`[<Назад>`:' + core.page_path + '/my_profile.mu]`!')
    
# If user is logged out
if not current_session:
    if 'remote_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + os.environ['remote_identity'])
    if 'remote_identity' not in os.environ:
        print('NomadNet не передал remote_identity для текущего подключения.')

# Display footer text
core.footer()
