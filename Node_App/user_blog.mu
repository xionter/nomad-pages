#!/usr/bin/env python3

# Import required modules
import core
import os
import json
import time
import uuid

# Functions used by page
def read_posts(username):
    try:
        with open(core.data_directory + '/user_blogs/' + username + '.json', 'r') as blog_file:
           posts = json.load(blog_file)
        return posts
    except:
        post = []
        post_object = json.dumps(post, indent=4)
        with open(core.data_directory + '/user_blogs/' + username + '.json', "w") as blog_file:
            blog_file.write(post_object)
        return post

def read_feed():
    try:
        with open(core.data_directory + '/blog_feed.json', 'r') as feed_file:
           feed = json.load(feed_file)
        return feed
    except:
        feed = []
        feed_object = json.dumps(feed, indent=4)
        with open(core.data_directory + '/blog_feed.json', "w") as feed_file:
            feed_file.write(feed_object)
        return feed
 

def add_post(username, subject, post):
    posts = read_posts(username)
    post_uuid = str(uuid.uuid4())
    subject = subject.replace('`', '\\`')
    post = post.replace('\\', '\\\\')
    posts.insert(0, {'username': username, 'subject': subject, 'post': post, 'comments': [], 'id': post_uuid, "time": time.time()})
    post_object = json.dumps(posts, indent=4)
     
    with open(core.data_directory + '/user_blogs/' + username + '.json', "w") as blog_file:
        blog_file.write(post_object)
                    
    add_to_feed(username, subject, post, post_uuid)

def add_to_feed(username, subject, post, post_uuid):
    feed = read_feed()
    feed.insert(0, {'username': username, 'subject': subject, 'post': post, 'id': post_uuid, "time": time.time()})
    feed_object = json.dumps(feed, indent=4)
     
    with open(core.data_directory + '/blog_feed.json', "w") as feed_file:
        feed_file.write(feed_object)

def remove_from_feed(post_id):
    feed = read_feed()
    post_n = 0
    del_index = None
    for post in feed:
        if post['id'] == post_id:
            del_index = post_n
            break
            
        post_n = post_n + 1
    if del_index != None:
        del feed[del_index]
        feed_object = json.dumps(feed, indent=4)
     
        with open(core.data_directory + '/blog_feed.json', "w") as feed_file:
            feed_file.write(feed_object)
        
            

def delete_post(username, post_index):
    posts = read_posts(username)
    del posts[int(post_index)]
    post_object = json.dumps(posts, indent=4)
     
    with open(core.data_directory + '/user_blogs/' + username + '.json', "w") as blog_file:
        blog_file.write(post_object)

    

def add_comment(commenter, username, post_index, post):
    posts = read_posts(username)
    post = post.replace('\\', '\\\\')
    posts[int(post_index)]['comments'].append({'username': commenter, 'post': post, "time": time.time()})
    post_object = json.dumps(posts, indent=4)
     
    with open(core.data_directory + '/user_blogs/' + username + '.json', "w") as blog_file:
        blog_file.write(post_object)



# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

# Display same thing, regardless of user logged in or not.
##print('This page demonstrates how to add content, and define who can see it.')

# If user is logged in
if current_session:
    if 'field_post' in os.environ and 'field_subject' in os.environ:
        print('Posted.')
        print('`!`[<Back>`:' + core.page_path + '/user_blog.mu`view_user=' + os.environ['var_view_user'] + ']`!')
        add_post(current_session['username'], os.environ['field_subject'], os.environ['field_post'])


    elif 'field_post' in os.environ and 'var_new_comment' in os.environ:
        print('Posted comment.')
        print('`!`[<Back>`:' + core.page_path + '/user_blog.mu`view_user=' + os.environ['var_view_user'] + ']`!')
        try:
            add_comment(current_session['username'], os.environ['var_view_user'], os.environ['var_post_index'], os.environ['field_post'])
        except Exception as e:
            print(str(e))

    elif 'var_new' in os.environ:
        print('Subject: `B444`<subject`>`b')
        print()
        print('Post:    `B444`<post`>`b')
        print()
        print('`!`[<Post>`:' + core.page_path + '/user_blog.mu`subject|post|view_user=' + os.environ['var_view_user'] + ']`!')

    elif 'var_delete_post' in os.environ:
        print('Post deleted.')
        print('`!`[<Back>`:' + core.page_path + '/user_blog.mu`view_user=' + os.environ['var_view_user'] + ']`!')
        delete_post(current_session['username'], os.environ['var_delete_post'])
        remove_from_feed(os.environ['var_del_post_id'])

    elif 'var_new_comment' in os.environ and 'field_post' not in os.environ:
        print('Post:    `B444`<post`>`b')
        print()
        print('`!`[<Post>`:' + core.page_path + '/user_blog.mu`post|new_comment=true|post_index=' + os.environ['var_post_index'] + '|view_user=' + os.environ['var_view_user'] + ']`!')
        
    elif 'field_post' not in os.environ and 'field_subject' not in os.environ:
        if 'var_view_user' not in os.environ:
            print('`c`!Latest Posts`!')
            
            print('`!`[<My Blog>`:' + core.page_path + '/user_blog.mu`view_user=' + current_session['username'] + ']`!')
            print('`a')
            print()
            post_feed = read_feed()[:15]
            for post in post_feed:
                subject = ''
                if post['subject'] != '':
                    subject = post['subject'] +  ' - '
                print('>' + subject + core.convert_time(post['time']))
                print('`!`[<' + post['username'] + '>`:' + core.page_path + '/user_blog.mu`view_user=' + post['username'] + ']`!: ' + post['post'])
                print()
            
        elif 'var_view_user' in os.environ:
            posts = read_posts(os.environ['var_view_user'])[:15]
            
            user_data = core.read_profile_username(os.environ['var_view_user'])
            if current_session['username'] != os.environ['var_view_user']:
                print('''
Username: `!''' + user_data['username'] + '''`!
Name: `!''' + user_data['profile']['name'] + '''`!

About: `!''' + user_data['profile']['about'] + '''`!

`c`!`[<Message ''' + user_data['username'] + '''>`:''' + core.page_path + '''/messages.mu`new_message=''' + user_data['username'] + ''']`! `!`[<Profile>`:''' + core.page_path + '''/profile.mu`username=''' + user_data['username'] + ''']`!
`a

    ''')
        
            if current_session['username'] == os.environ['var_view_user']:
                print('`c`!`[<New Post>`:' + core.page_path + '/user_blog.mu`new=true|view_user=' + os.environ['var_view_user'] + ']`!' + ' `!`[<Main Feed>`:' + core.page_path + '/user_blog.mu]`!')
                print('`a')
                print()
##            print()
            post_n = 0
            for post in posts:
                subject = ''
                delete_button = ''
                if current_session['username'] == os.environ['var_view_user']:
                    delete_button = ' `Ff00`!`[<Delete>`:' + core.page_path + '/user_blog.mu`delete_post=' + str(post_n) + '|del_post_id=' + post['id'] + '|view_user=' + os.environ['var_view_user'] + ']`!`f'

                if post['subject'] != '':
                    subject = post['subject'] +  ' - '
                print('>' + subject + core.convert_time(post['time']))
                print(post['post'] + '``')

                print('`!`[<Comment>`:' + core.page_path + '/user_blog.mu`new_comment=true|post_index=' + str(post_n) + '|view_user=' + os.environ['var_view_user'] + ']`!' + delete_button)
                print()

                for comment in post['comments']:
                    print('>>')
                    print('`!`[<' + comment['username'] + '>`:' + core.page_path + '/user_blog.mu`view_user=' + comment['username'] + ']`!: ' + comment['post'] + '``')
                post_n = post_n + 1
                print()

    
    
# If user is logged out
if not current_session:
    print('User not logged in.')
    print('`!`[<Login>`:' + core.page_path + '/login.mu]`!')

# Display footer text
core.footer()
