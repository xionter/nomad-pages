#!/usr/bin/env python3

import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

current_session = core.get_current_session(os.environ['link_id'])

core.header(current_session)

if not current_session:
    # We have registration variables, proceed to regisater user
    if 'field_username' in os.environ and 'field_password' in os.environ and 'field_password2' in os.environ and not current_session:
        try:
            core.read_users()[os.environ['field_username']]
            print('Username already used.')
        except:
            if os.environ['field_password'] != os.environ['field_password2']:
                print('Password mismatch, try again.')
                print('`!`[<Try Again>`:' + core.page_path + '/register.mu]`!')
            elif os.environ['field_password'] == '' or os.environ['field_password2'] == '':
                print('Password blank, try again.')
                print('`!`[<Try Again>`:' + core.page_path + '/register.mu]`!')
            elif len(os.environ['field_password']) < 8 or len(os.environ['field_password2']) < 8:
                print('Password too short, must be at least 8 characters. Try again.')
                print('`!`[<Try Again>`:' + core.page_path + '/register.mu]`!')
            elif len(os.environ['field_username']) < 4:
                print('Username too short, must be at least 4 characters. Try again.')
                print('`!`[<Try Again>`:' + core.page_path + '/register.mu]`!')
            elif os.environ['field_password'] == os.environ['field_password2']:
                print('You are now registered!')
                print('`!`[<Go to Login>`:' + core.page_path + '/login.mu]`!')
                try:
                    core.write_new_user(os.environ['field_username'], os.environ['field_password'])
                except Exception as e:
                    print(str(e))
        
    # No registration variables, show sign up page.
    else:
        if core.registration_enabled:
            print('`!Register a new account`!')
            print()
            print('Username must be at least 4 characters, password must be at least 8 characters.')
            print('By registering, you agree to the `!`[<Terms of Service>`:' + core.page_path + '/terms_of_service.mu]`!.')
            print()
            print('Username        : `B444`<username`>`b')
            print()
            print('Password        : `B444`<!|password`>`b')
            print()
            print('Confirm Password: `B444`<!|password2`>`b')
            print()
            print('`!`[<Register>`:' + core.page_path + '/register.mu`username|password|password2]`!')
        if not core.registration_enabled:
            print('Registration disabled.')
            print('`!`[<Back>`:' + core.page_path + '/index.mu]`!')

    
if current_session:
        print('Already registered and logged in!')
        print('`!`[<Go to Home>`:' + core.page_path + '/index.mu]`!')

core.footer()



