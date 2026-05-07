#!/usr/bin/env python3

# Import required modules
import core
import os
import time
import uuid
import json
import re

def read_page(name, process_links = True, sub_new_line = False):
    global current_session
    try:
        with open(core.data_directory + '/wiki/' + name + '.json', 'r') as page_file:
           page = json.load(page_file)
           complete = page['content']
           if process_links == True:
               process_links = re.sub(r'(::[A-Za-z0-9]+)', r'`!`_`[\1`:/page/Node_App_Template/wiki.mu`page_name=\1]`!`_', page['content'])
               complete = re.sub('::', '', process_links)
           if sub_new_line:
               complete = re.sub('\n', '***', complete)
           page['content'] = complete
           return page
        
    except:
        content = 'Try again.'
        if current_session:
            content = '`!`[<Add Page>`:' + core.page_path + '/wiki.mu`add_page=' + name + ']`!'
            
        return {'title': 'Page not found or other error.',
                'content': content,
                'author': '',
                'time': 0.0
                }
    
def delete_page(title):
    os.remove(core.data_directory + '/wiki/' + title + '.json')
    

def add_page(author, title, content):
    page_uuid = str(uuid.uuid4())
    content = re.sub('\*\*\*', '\n', content)
    page = {'author': author, 'title': title, 'content': content, 'id': page_uuid, "time": time.time()}
    page_object = json.dumps(page, indent=4)
     
    with open(core.data_directory + '/wiki/' + title + '.json', "w") as page_file:
        page_file.write(page_object)
                    

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)


# If user is logged in
if current_session:
    if 'var_add_page' in os.environ:
        print()
        print('To link to a page, or create a new page, use a double collon. For example: `=::NewPage`=\nThree asterisks in a row (`=***`=) are equivelent to a newline.')
        print()
        print('Name:       `B444`<name`' + os.environ['var_add_page'] + '>`b')
        print()
        print('Content:    `B444`<content`>`b')
        print()
        print('`!`[<Save>`:' + core.page_path + '/wiki.mu`name|content|save_page=true]`!')

    elif 'var_delete_page' in os.environ:
        print('Page deleted.')
        print('`!`[<Back>`:' + core.page_path + '/wiki.mu]`!')
        delete_page(os.environ['var_delete_page'])

    elif 'var_save_page' in os.environ:
        print('Page saved.')
        print('`!`[<Back>`:' + core.page_path + '/wiki.mu`page_name=' + os.environ['field_name'] + ']`!')
        try:
            add_page(current_session['username'], os.environ['field_name'], os.environ['field_content'])
        except Exception as e:
            print(str(e))
    elif 'var_edit_page' in os.environ:
        page = read_page(os.environ['var_edit_page'], process_links = False, sub_new_line = True)
        print()
        print('To link to a page, or create a new page, use a double collon. For example: `=::NewPage`=\nThree asterisks in a row (`=***`=) are equivelent to a newline.')
        print()
        print('Name:       `B444`<name`' + os.environ['var_edit_page'] + '>`b')
        print()
        print('Content:    `B444`<content`' + page['content'] + '>`b')
        print()
        print('`!`[<Save>`:' + core.page_path + '/wiki.mu`content|name|save_page=true]`!')

##    # OPTIONAL:
##    # Only display if user has a role. A role can be anything.
##    if current_session['role'] == 'admin':
##        print('You have the role admin.')
##
##    if current_session['role'] == 'moderator':
##        print('You have the role moderator.')
##
##    if current_session['role'] == 'user':
##        print('You have the role user.')

    
# If user is logged out
##if not current_session:
if 'var_page_name' not in os.environ:
    os.environ['var_page_name'] = 'Index'

if 'var_page_name' in os.environ and 'var_edit_page' not in os.environ and 'var_save_page' not in os.environ and 'var_add_page' not in os.environ and 'var_delete_page' not in os.environ:
    page = read_page(os.environ['var_page_name'])
    top_buttons = '`!`[<Index>`:' + core.page_path + '/wiki.mu]`! '
    if current_session and page['title'] != 'Page not found or other error.':
        try:
            top_buttons = top_buttons + '`!`[<Edit>`:' + core.page_path + '/wiki.mu`edit_page=' + page['title'] + ']`! `!`[<New Page>`:' + core.page_path + '/wiki.mu`add_page=]`! `Ff00`!`[<Delete>`:' + core.page_path + '/wiki.mu`delete_page=' + page['title'] + ']`!`f'
        except Exception as e:
            print(str(e))
    print(top_buttons)
    print('`c`!' + page['title'] + '`!')
    print('`aAuthor: ' + '`!`[<' + page['author'] + '>`:' + core.page_path + '/profile.mu`username=' + page['author'] + ']`!')
    print('Last updated: ' + core.convert_time(page['time']))
    print('-')
    print(page['content'])
    print('``')
    print()
        



# Display footer text
core.footer()
