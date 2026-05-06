#!/usr/bin/env python3

# Import required modules
import core
import os

# Must be where files are accessible. Typically .nomadnetwork/storage/files
root = '/root/.nomadnetwork/storage/files'

# Sub folder(s) within root directory, leave blank to disable. Example would be: /photos. Do not leave a trailing slash.
root_sub_folder = ''

# Page name, used when generating links.
file_mu = 'Node_App_Template/files.mu'

# Allow only logged in users to browse and download
users_only = False


#####################################################

def up():
    request_split = dir_request.split('/')
    new_path = ''
    for loc in request_split[:-2]:
        new_path = new_path + loc + '/'
    if new_path == '':
        button = ''
        return button
    elif new_path != '':
        button = '`!`[<UP>`:/page/' + file_mu + '`path=' + new_path + ']`! |'
        return button

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

if 'var_path' in os.environ:
##    try:
    if os.environ['var_path'] == '!home!':
        dir_request = '/'
    if os.environ['var_path'] != '!home!':
        dir_request = os.environ['var_path']
elif 'var_path' not in os.environ:
    dir_request = '/'

header = '''`!`[Index`:/page/''' + file_mu + '''`path=!home!]`! | ''' + up() + ''' Current: ''' + dir_request + '''
-
'''

print(header)
    
if not users_only or current_session:
    try:
        for item in os.listdir(root + dir_request):
            if '.' not in item:
                print('`!`[<' + item + '>`:/page/' + file_mu + '`path=' + dir_request + item + '/]`!')
            elif '.' in item:
                file_size = round((os.path.getsize(root + dir_request + item) / 1024) / 1024, 3)
                print('`[' + item + '`:/file' + root_sub_folder + dir_request + item + ']' + ' - ' + str(file_size) + ' MB')

        print()
    except Exception as e:
        print(e)

elif users_only and not current_session:
  print('Login to browse files.')
  print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')

core.footer()
