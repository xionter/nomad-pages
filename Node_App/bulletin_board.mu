#!/usr/bin/env python3

# Import required modules
import core
import os
import json
import time

# Functions used by page
def read_posts():
    try:
        with open(core.data_directory + 'bulletin_board.json', 'r') as board_file:
           posts = json.load(board_file)
        return posts
    except:
        post = []
        post_object = json.dumps(post, indent=4)
        with open(core.data_directory + 'bulletin_board.json', "w") as board_file:
            board_file.write(post_object)
        return post
        

def add_post(username, subject, post):
    posts = read_posts()
    subject = subject.replace('`', '\\`')
    post = post.replace('\\', '\\\\')
    posts.insert(0, {'username': username, 'subject': subject, 'post': post, "time": time.time()})
    post_object = json.dumps(posts, indent=4)
     
    with open(core.data_directory + 'bulletin_board.json', "w") as board_file:
        board_file.write(post_object)


# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

# If user is logged in
if current_session:
    if 'field_post' in os.environ and 'field_subject' in os.environ:
        print('Posted.')
        print('`!`[<Back>`:' + core.page_path + '/bulletin_board.mu]`!')
        add_post(current_session['username'], os.environ['field_subject'], os.environ['field_post'])

    elif 'var_new' in os.environ:
        print('Subject: `B444`<subject`>`b')
        print()
        print('Post:    `B444`<post`>`b')
        print()
        print('`!`[<Post>`:' + core.page_path + '/bulletin_board.mu`subject|post]`!')
        
if 'field_post' not in os.environ and 'field_subject' not in os.environ and 'var_new' not in os.environ:
    all_posts = read_posts()[:15]
    print('`c`!Bulletin Board`!')
    if current_session:
        print('`!`[<New Post>`:' + core.page_path + '/bulletin_board.mu`new=true]`!')
        print('`a')
        print()
    for post in all_posts:
        print('>' + post['subject'] +  ' - ' + core.convert_time(post['time']))
        print('`!`[<' + post['username'] + '>`:' + core.page_path + '/profile.mu`username=' + post['username'] + ']`!: ' + post['post'] + '``')
        print()
    
    
### If user is logged out
##if not current_session:
##    print('User not logged in.')
##    print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')

# Display footer text
core.footer()
