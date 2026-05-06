#!/usr/bin/env python3

# Import required modules
import core
import os

# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

##print(os.environ)
  
# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Remove any expired sessions
core.trim_active_sessions()

# Display the header, i.e. title, menu, etc.
core.header(current_session)

print('''
Add your terms of service here.

`!`[<Register>`:''' + core.page_path + '''/register.mu]`!
''')

# Display footer text
core.footer()
