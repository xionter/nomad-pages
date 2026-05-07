#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if current_session:
    core.deauthenticate_user(os.environ['link_id'])
    print('`!Logout`!')
    print()
    print('Sucessfully logged out.')

if not current_session:
    print('Already logged out.')

print('`!`[<Continue>`:' + core.page_path + '/index.mu]`!')
    
core.footer()
