#!/usr/bin/env python3

import core
import os


if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

if 'remote_identity' in os.environ:
    user_identity = core.check_identity(os.environ['remote_identity'])
    if user_identity != None:
        user_data = core.read_user_id(user_identity[1]['user_id'])
        user = core.read_users()[user_data['username']]
        core.add_active_session(os.environ['link_id'], user_identity[1]['user_id'], user_data, user['role'])
        
    
current_session = core.get_current_session(os.environ['link_id'])

core.trim_active_sessions()

core.header(current_session)
print("""
`c
`B222   `b         `B222   `b         `B222   `b
`B222 `Bddc `Bddc `B333 `B222`b       `B222 `Bddc `Bddc `B333 `B222`b       `B222 `Bddc `Bddc `B333 `B222`b
`B222 `Bddc  `Bddc  `B333 `B222`b     `B222 `Bddc  `Bddc  `B333 `B222`b     `B222 `Bddc  `Bddc  `B333 `B222`b
`B333 `Bddc  `Bddc  `Bddc `B333 `b    `B333 `Bddc  `Bddc  `Bddc `B333 `b    `B333 `Bddc  `Bddc  `Bddc `B333 `b
`B222 `Bddc  `Beed  `Bddc `B222 `b   `B222 `Bddc  `Beed  `Bddc `B222 `b   `B222 `Bddc  `Beed  `Bddc `B222 `b
`B333 `Bddc  `Bddc  `Bccb `B333 `b    `B333 `Bddc  `Bddc  `Bccb `B333 `b   `B333 `Bddc   `Bddc  `Bccb `B333 `b
`B222 `Bccb  `Bccb  `Bccb `B222 `b    `B222 `Bccb  `Bccb  `Bccb `B222 `b    `B222 `Bccb  `Bccb  `Bccb `B222 `b
`B333 `Bddc  `Bddc `B222 `b      `B333 `Bddc  `Bddc `B222 `b      `B333 `Bddc  `Bddc `B222 `b
`B222 `b           `B222 `b           `B222 `b
`a
""")
if current_session:
    username = current_session["username"]
    print(f'''
>`F0f0`!Welcome, `f`Fff0{username}`f`!`a
Welcome to the homepage!

You are logged in. Congratulations!
Кстати, вот все твои данные: {current_session}

''')
else:
    print('''
>Welcome Guest
Welcome to the homepage! Please log in.

''')
print("""
>Welcome to the homepage!

(топовый контик >>> https://t.me/stranno_jungle)

""")
print("""
`c
`B222   `b         `B222   `b         `B222   `b
`B222 `Bddc `Bddc `B333 `B222`b       `B222 `Bddc `Bddc `B333 `B222`b       `B222 `Bddc `Bddc `B333 `B222`b
`B222 `Bddc  `Bddc  `B333 `B222`b     `B222 `Bddc  `Bddc  `B333 `B222`b     `B222 `Bddc  `Bddc  `B333 `B222`b
`B333 `Bddc  `Bddc  `Bddc `B333 `b    `B333 `Bddc  `Bddc  `Bddc `B333 `b    `B333 `Bddc  `Bddc  `Bddc `B333 `b
`B222 `Bddc  `Beed  `Bddc `B222 `b   `B222 `Bddc  `Beed  `Bddc `B222 `b   `B222 `Bddc  `Beed  `Bddc `B222 `b
`B333 `Bddc  `Bddc  `Bccb `B333 `b    `B333 `Bddc  `Bddc  `Bccb `B333 `b   `B333 `Bddc   `Bddc  `Bccb `B333 `b
`B222 `Bccb  `Bccb  `Bccb `B222 `b    `B222 `Bccb  `Bccb  `Bccb `B222 `b    `B222 `Bccb  `Bccb  `Bccb `B222 `b
`B333 `Bddc  `Bddc `B222 `b      `B333 `Bddc  `Bddc `B222 `b      `B333 `Bddc  `Bddc `B222 `b
`B222 `b           `B222 `b           `B222 `b
`a
""")

print(" ")
print(" ")
#core.footer()
