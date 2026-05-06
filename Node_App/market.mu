#!/usr/bin/env python3

# Import required modules
import core
import os
import json
import uuid
import time


categories = [
    'Food',
    'Tools',
    'Equipment'
    ]
# 2 weeks
listing_expires = (60 * 60 * 24 * 14)

##############################################3

def read_category(category):
    try:
        with open(core.data_directory + '/market/' + category + '.json', 'r') as market_file:
           markets = json.load(market_file)
        return markets
    except:
        market = []
        market_object = json.dumps(market, indent=4)
        with open(core.data_directory + '/market/' + category + '.json', "w") as market_file:
            market_file.write(market_object)
        return market

def add_listing(category, username, title, description, asking):
    title = title.replace('`', '\\`')
    description = description.replace('`', '\\`')
    asking = asking.replace('`', '\\`')
    markets = read_category(category)
    markets.insert(0, {'username': username, 'id': str(uuid.uuid4()), 'title':title, 'description': description, 'asking': asking, "time": time.time()})
    markets_object = json.dumps(markets, indent=4)
     
    with open(core.data_directory + '/market/' + category + '.json', "w") as markets_file:
        markets_file.write(markets_object)

def delete_listing(category, listing_id):
    markets = read_category(category)
    n_list = 0
    for item in markets:
        if item['id'] == listing_id:
            del_n = n_list
        n_list = n_list + 1
    del markets[del_n]
            
##    markets.insert(0, {'username': username, 'id': str(uuid.uuid4()), 'title':title, 'description': description, 'asking': asking, "time": time.time()})
    markets_object = json.dumps(markets, indent=4)
     
    with open(core.data_directory + '/market/' + category + '.json', "w") as markets_file:
        markets_file.write(markets_object)


# Must be browsing locally, create fake link_id
if 'link_id' not in os.environ:
    os.environ['link_id'] = 'local_test'

# Check if current link_id is loged in as a user.
current_session = core.get_current_session(os.environ['link_id'])

# Display the header, i.e. title, menu, etc.
core.header(current_session)

# Display same thing, regardless of user logged in or not.
if current_session:
    if 'var_new_listing' in os.environ:
            print('Title:       `B444`<title`>`b')
            print()
            print('Asking:      `B444`<asking`>`b')
            print()
            print('Description: `B444`<description`>`b')
            print()
            print('`!`[<Post>`:' + core.page_path + '/market.mu`title|asking|description|category=' + os.environ['var_new_listing'] + ']`!')

    if 'var_del_listing_id' in os.environ:
        delete_listing(os.environ['var_category'], os.environ['var_del_listing_id'])
        print('Deleted listing.')
        print('`!`[<Back to ' + os.environ['var_category'] + '>`:' + core.page_path + '/market.mu`category=' + os.environ['var_category'] + ']`!')

    if 'field_title' in os.environ and 'field_asking' in os.environ and 'field_description' in os.environ:
        print('Listing added.')
        print('`!`[<Back to ' + os.environ['var_category'] + '>`:' + core.page_path + '/market.mu`category=' + os.environ['var_category'] + ']`!')
        add_listing(os.environ['var_category'], current_session['username'], os.environ['field_title'], os.environ['field_description'], os.environ['field_asking'])

if 'var_category' not in os.environ and 'var_listing_id' not in os.environ and 'var_new_listing' not in os.environ and 'var_del_listing_id' not in os.environ:
    print('`c`!Market`!')
    print('`a')
    print()
    for category in categories:
        print('`!`[<' + category + '>`:' + core.page_path + '/market.mu`category=' + category + ']`!')
    print()

if 'var_listing_id' in os.environ:
    items = read_category(os.environ['var_category'])
    for item in items:
        if item['id'] == os.environ['var_listing_id']:
            delete = ''
            try:
                if current_session['username'] == item['username']:
                    delete = '`Ff00`!`[<Delete>`:' + core.page_path + '/market.mu`category=' + os.environ['var_category'] + '|del_listing_id=' + item['id'] + ']`!`f'
            except:
                pass
            print('`!`[<Back to ' + os.environ['var_category'] + '>`:' + core.page_path + '/market.mu`category=' + os.environ['var_category'] + ']`! `!`[<' + item['username'] + ' Profile>`:' + core.page_path + '/profile.mu`username=' +  item['username'] + ']`! `!`[<Message ' + item['username'] + '>`:' + core.page_path + '/messages.mu`new_message=' +  item['username'] + '|subject=Market: ' +  item['title'] + ']`! ' + delete)
            print()
            print('`c`!' + item['title'] + '`!')
            print()
            print(core.convert_time(item['time']))
            print(item['asking'])
            print('`a' + item['description'])
            print()

if 'var_category' in os.environ and 'var_listing_id' not in os.environ and 'var_new_listing' not in os.environ and 'var_del_listing_id' not in os.environ and 'field_title' not in os.environ:
    items = read_category(os.environ['var_category'])
    print('`cMarket: `!' + os.environ['var_category'] + '`!')
    print()
    print('`!`[<All Categories>`:' + core.page_path + '/market.mu]`!')
    print('`a')
    print()
    if current_session:
        print('`!`[<New Listing in ' + os.environ['var_category'] + '>`:' + core.page_path + '/market.mu`new_listing=' + os.environ['var_category'] + ']`!')
        print()
    for item in items:
        if time.time() < item['time'] + listing_expires:
            print('`!`[<View>`:' + core.page_path + '/market.mu`listing_id=' +item['id'] + '|category=' + os.environ['var_category'] + ']`! ' + core.convert_time(item['time']) + ' | `!' + item['title'] + '`! | ' + item['asking'])
        print()
    

# Display footer text
core.footer()
