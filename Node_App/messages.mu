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
    all_messages = core.read_user_messages(current_session['user_id'])
    
    if 'var_view_message' in os.environ:
        for message in all_messages:
            if os.environ['var_view_message'] == message['id']:
                print('`!`[<Inbox>`:' + core.page_path + '/messages.mu]`! `!`[<Reply>`:' + core.page_path + '/messages.mu`new_message=' +  message['from'] + '|subject=Reply: ' +  message['subject'] + ']`! `Ff00`!`[<Delete>`:' + core.page_path + '/messages.mu`delete_message=' + message['id'] + ']`!`f')
                print()
                print('`!`[<' + message['from'] + '>`:' + core.page_path + '/profile.mu`username=' + message['from'] + ']`! - ' + message['subject'] + ' - ' + core.convert_time(message['time']))
                print()
                print(message['message'])
                print('``')
                print()
                
    if 'var_new_message' in os.environ:
        subject = ''
        if 'var_subject' in os.environ:
            subject = os.environ['var_subject']
        print('`!`[<Inbox>`:' + core.page_path + '/messages.mu]`!')
        print()
        print('To      : `B444`<username`' + os.environ['var_new_message'] + '>`b')
        print()
        print('Subject : `B444`<subject`' + subject + '>`b')
        print()
        print('250 characters maximum.')
        print('Message : `B444`<message`>`b')
        print()
        print('`!`[<Send>`:' + core.page_path + '/messages.mu`username|subject|message]`!')

    if 'var_delete_message' in os.environ:
        core.delete_user_message(current_session['user_id'], os.environ['var_delete_message'])
        print('`!`[<Inbox>`:' + core.page_path + '/messages.mu]`!')


    if 'field_username' in os.environ and 'field_subject' in os.environ and 'field_message' in os.environ:
        if len(os.environ['field_subject']) > 250:
            print('Message too long.')
        elif len(os.environ['field_subject']) < 250:
            os.environ['field_subject'] = os.environ['field_subject'].replace('`', '\\`')
            core.add_user_message(os.environ['field_username'], current_session['username'], os.environ['field_subject'], os.environ['field_message'])
            print('`!`[<Inbox>`:' + core.page_path + '/messages.mu]`!')
    

    elif 'var_view_message' not in os.environ and 'var_subject' not in os.environ and'var_delete_message' not in os.environ and 'var_new_message' not in os.environ and 'field_username' not in os.environ and 'field_subject' not in os.environ and 'field_message' not in os.environ:
        print('`!`[<Compose>`:' + core.page_path + '/messages.mu`new_message=]`!')
        print()
        for message in all_messages:
            print('`!`[<View>`:' + core.page_path + '/messages.mu`view_message=' + message['id'] + ']`! ' + message['from'] + ' | ' + message['subject'])
        print()
# If user is logged out
if not current_session:
    print('Please login.')


# Display footer text
core.footer()
