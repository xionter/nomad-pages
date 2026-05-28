#!/usr/bin/env python3

import core
import os

if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session, 'profile')

if current_session:
    if 'remote_identity' in os.environ and 'var_add_identity' not in os.environ and 'var_delete_identity' not in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + core.fg(os.environ['remote_identity'], core.color_secondary))
        print()
        print(core.action('Привязать', core.page_path + '/identity.mu`add_identity=true', core.color_success) + ' ' + core.danger_action('Отвязать', core.page_path + '/identity.mu`delete_identity=true'))

        
    if 'remote_identity' in os.environ and 'var_add_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + core.fg(os.environ['remote_identity'], core.color_secondary))
        print(core.fg('Идентичность привязана к аккаунту. При следующем подключении система сможет создать сессию автоматически.', core.color_success))
        print(core.action('Назад', core.page_path + '/my_profile.mu'))
        core.add_identity(current_session['username'], os.environ['remote_identity'])

    elif 'remote_identity' in os.environ and 'var_delete_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + core.fg(os.environ['remote_identity'], core.color_secondary))
        print(core.fg('Идентичность отвязана от аккаунта.', core.color_warning))
        print(core.action('Назад', core.page_path + '/my_profile.mu'))
        core.delete_identity(current_session['username'], os.environ['remote_identity'])
        
    if 'remote_identity' not in os.environ:
        print(core.fg('NomadNet не передал remote_identity для текущего подключения.', core.color_danger))
        print(core.action('Назад', core.page_path + '/my_profile.mu'))
    
if not current_session:
    if 'remote_identity' in os.environ:
        print('Ваша текущая Reticulum/NomadNet-идентичность: ' + core.fg(os.environ['remote_identity'], core.color_secondary))
    if 'remote_identity' not in os.environ:
        print(core.fg('NomadNet не передал remote_identity для текущего подключения.', core.color_danger))

core.footer()
