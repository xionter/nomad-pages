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

# Display same thing, regardless of user logged in or not.
print('''This page demonstrates how to add content, and define who can see it.
''')

# If user is logged in
if current_session:
    print('''User logged in.
Display content to logged in users here.

Examples of other "plugins" for logged in users:
`!`[Micro Blog`:/page/Node_App_Template/user_blog.mu]`!

''')

    # OPTIONAL:
    # Only display if user has a role. A role can be anything. It is a text string.
    if current_session['role'] == 'admin':
        print('You have the role admin.')

    if current_session['role'] == 'moderator':
        print('You have the role moderator.')

    if current_session['role'] == 'user':
        print('You have the role user.')

    
# If user is logged out
if not current_session:
    print('''
User not logged in.
''')

# Display same thing, regardless of user logged in or not.
print('''Everyone can see this.

"Plugins" that anyone can view:

`!`[Bulletin Board`:/page/Node_App_Template/bulletin_board.mu]`!
`!`[Stats`:/page/Node_App_Template/stats.mu]`!
`!`[Wiki`:/page/Node_App_Template/wiki.mu]`!
`!`[Market Listings`:/page/Node_App_Template/market.mu]`!
`!`[File Browser`:/page/Node_App_Template/files.mu]`!




''')

# Display footer text
core.footer()
