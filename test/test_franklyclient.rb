##
# The MIT License (MIT)
#
# Copyright (c) 2015 Frankly Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

require 'frankly-ruby'

require 'minitest/autorun'

class FranklyClientTest < MiniTest::Unit::TestCase
  def setup
    @app_key = ENV['FRANKLY_APP_KEY']
    @app_secret = ENV['FRANKLY_APP_SECRET']
    @test_url = Util.make_base_address ENV['FRANKLY_APP_HOST']
  end

  def test_open
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    client.close
  end

  def test_announcement_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_announcement_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_announcement_functions(client)
    client.close
  end

  def t_announcement_functions(client)
    room_title = 'test create room: ' + rand(36**4).to_s(36)
    room_payload = {
      status: 'active',
      title: room_title
    }
    room = client.create_room(room_payload)

    announcement_payload = {
      sticky: true,
      contents: [
        {
          type:       'text/plain',
          value:      'text'
        }
      ]
    }

    announcement = client.create_announcement(announcement_payload)

    assert_equal([{ 'type' => 'text/plain', 'value' => 'text' }], announcement['contents'])
    assert_equal(true, announcement['sticky'])
    refute_equal(nil, announcement['created_on'])
    refute_equal(nil, announcement['id'])
    refute_equal(nil, announcement['updated_on'])
    assert_equal(1, announcement['version'])

    read_announcement = client.read_announcement(announcement['id'])
    assert_equal(read_announcement, announcement)

    announcement_list = client.read_announcement_list
    assert_equal(true, announcement_list.include?(announcement))

    published_announcement = client.create_room_message(room['id'], announcement: announcement['id'])

    assert_equal([{ 'type' => 'text/plain', 'value' => 'text' }], published_announcement['contents'])
    assert_equal(true, published_announcement['sticky'])
    refute_equal(nil, published_announcement['created_on'])
    refute_equal(nil, published_announcement['id'])
    assert_equal(room['id'], published_announcement['room_id'])
    refute_equal(nil, published_announcement['sent_on'])
    refute_equal(nil, published_announcement['updated_on'])
    assert_equal(1, published_announcement['version'])

    announcement_room_list = client.read_announcement_room_list(announcement['id'])
    assert_equal(true, announcement_room_list.include?(room))

    client.delete_announcement(announcement['id'])

    announcement_list = client.read_announcement_list
    refute_equal(true, announcement_list.include?(announcement))

    announcement_room_list = client.read_announcement_room_list(announcement['id'])
    assert_equal(true, announcement_room_list.include?(room))
  end

  def test_file_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_file_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_file_functions(client)
    client.close
  end

  def t_file_functions(client)
    file_payload = {
      category: 'useravatar',
      type: 'image'
    }
    file = client.create_file(file_payload)

    assert_equal('useravatar', file['category'])
    refute_equal(nil, file['created_on'])
    refute_equal(nil, file['id'])
    assert_equal('image', file['type'])
    refute_equal(nil, file['updated_on'])
    refute_equal(nil, file['url'])
    assert_equal(1, file['version'])

    # To test file upload, replace my_file with a local file path
    # my_file = '/file/path.jpg'
    # response = client.update_file_from_path(file['url'], my_file)
    # assert_equal(200, response.code)
  end

  def test_message_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_message_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_message_functions(client)
    client.close
  end

  def t_message_functions(client)
    room_title = 'test create room: ' + rand(36**4).to_s(36)
    room_payload = {
      status: 'active',
      title: room_title
    }
    room = client.create_room(room_payload)

    message_payload = {
      contents: [
        {
          type: 'text/plain',
          value: 'text'
        }
      ]
    }
    message = client.create_room_message(room['id'], message_payload)

    assert_equal([{ 'type' => 'text/plain', 'value' => 'text' }], message['contents'])
    assert_equal(false, message['sticky'])
    refute_equal(nil, message['created_on'])
    refute_equal(nil, message['id'])
    assert_equal(room['id'], message['room_id'])
    refute_equal(nil, message['sent_on'])
    refute_equal(nil, message['updated_on'])
    assert_equal(1, message['version'])

    read_message = client.read_room_message(room['id'], message['id'])

    assert_equal(message, read_message)
    begin
      client.create_room_message_flag(room['id'], message['id'])
    rescue => e
    end

    assert_equal(e.response.code, 400)

    client.delete_room(room['id'])
  end

  def test_room_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_room_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_room_functions(client)
    client.close
  end

  def t_room_functions(client)
    # Test room creation
    create_room_title = 'test create room: ' + rand(36**4).to_s(36)
    create_payload = {
      status: 'active',
      title: create_room_title
    }

    room = client.create_room(create_payload)
    assert_equal(nil, room['avatar_image_url'])
    refute_equal(nil, room['created_on'])
    assert_equal(nil, room['description'])
    assert_equal(false, room['featured'])
    assert_equal(nil, room['featured_image_url'])
    refute_equal(nil, room['id'])
    assert_equal(0, room['list_position'])
    assert_equal('active', room['status'])
    assert_equal(false, room['subscribed'])
    assert_equal(create_room_title, room['title'])
    refute_equal(nil, room['updated_on'])
    assert_equal(1, room['version'])

    # Test room read
    read_room = client.read_room(room['id'])
    assert_equal(room, read_room)

    # Test room count
    room_count = client.read_room_count(room['id'])
    refute_equal(nil, room_count['active'])
    refute_equal(nil, room_count['online'])
    refute_equal(nil, room_count['subscribed'])

    # Test room update
    update_room_title = 'test update room: ' + rand(36**4).to_s(36)
    update_payload = {
      description: 'updated description',
      title: update_room_title,
      list_position: 1
    }
    updated_room = client.update_room(room['id'], update_payload)
    assert_equal(nil, updated_room['avatar_image_url'])
    refute_equal(nil, updated_room['created_on'])
    assert_equal('updated description', updated_room['description'])
    assert_equal(false, updated_room['featured'])
    assert_equal(nil, updated_room['featured_image_url'])
    refute_equal(nil, updated_room['id'])
    assert_equal(1, updated_room['list_position'])
    assert_equal('active', updated_room['status'])
    assert_equal(false, updated_room['subscribed'])
    assert_equal(update_room_title, updated_room['title'])
    refute_equal(nil, updated_room['updated_on'])
    assert_equal(2, updated_room['version'])

    # Test room list read
    room_list = client.read_room_list
    assert_equal(true, room_list.include?(updated_room))

    # Test room delete
    client.delete_room(room['id'])
    room_list = client.read_room_list
    refute_equal(true, room_list.include?(updated_room))
  end

  def test_user_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_user_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_user_functions(client)
    client.close
  end

  def t_user_functions(client)
    # Test room creation
    create_payload = {
      display_name: 'test_name'
    }
    user = client.create_user(create_payload)

    assert_equal(nil, user['avatar_image_url'])
    refute_equal(nil, user['created_on'])
    assert_equal('test_name', user['display_name'])
    refute_equal(nil, user['id'])
    refute_equal(nil, user['updated_on'])
    assert_equal(1, user['version'])

    # Test user read
    read_user = client.read_user(user['id'])
    assert_equal(user, read_user)

    # Test user update
    update_payload = {
      display_name: 'updated_name'
    }

    update_user = client.update_user(user['id'], update_payload)
    assert_equal(nil, update_user['avatar_image_url'])
    refute_equal(nil, update_user['created_on'])
    assert_equal('updated_name', update_user['display_name'])
    refute_equal(nil, update_user['id'])
    refute_equal(user['updated_on'], update_user['updated_on'])
    assert_equal(2, update_user['version'])

    # Test user ban
    ban = client.read_user_ban(user['id'])
    assert_equal(nil, ban['avatar_image_url'])
    refute_equal(nil, ban['created_on'])
    refute_equal(nil, ban['updated_on'])
    assert_equal(1, ban['version'])

    # Test user delete
    client.delete_user(user['id'])
    begin
      client.read_user(user['id'])
    rescue => e
    end
    assert_equal(e.response.code, 404)
  end

  def test_session_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_session_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_session_functions(client)
    client.close
  end

  def t_session_functions(client)
    client = FranklyClient.new(@test_url)
    client.open(@app_key, @app_secret)

    client_session = client.read_session
    refute_equal(nil, client_session['app'])
    refute_equal(nil, client_session['app_id'])
    refute_equal(nil, client_session['app_user_id'])
    refute_equal(nil, client_session['created_on'])
    refute_equal(nil, client_session['expires_on'])
    refute_equal(nil, client_session['platform'])
    refute_equal(nil, client_session['role'])
    refute_equal(nil, client_session['seed'])
    refute_equal(nil, client_session['user'])
    refute_equal(nil, client_session['version'])

    client.close
  end

  def test_room_roles
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_room_roles(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_room_roles(client)
    client.close
  end

  def t_room_roles(client)
    user_payload = {
      display_name: 'test_name'
    }
    user = client.create_user(user_payload)

    room_title = 'test room: ' + rand(36**4).to_s(36)
    room_payload = {
      status: 'active',
      title: room_title
    }
    room = client.create_room(room_payload)

    # Test Owner Role
    client.create_room_owner(room['id'], user['id'])
    owner_list = client.read_room_owner_list(room['id'])
    assert_equal(true, owner_list.include?(user))

    client.delete_room_owner(room['id'], user['id'])
    owner_list = client.read_room_owner_list(room['id'])
    refute_equal(true, owner_list.include?(user))

    # Test Moderator Role
    client.create_room_moderator(room['id'], user['id'])
    moderator_list = client.read_room_moderator_list(room['id'])
    assert_equal(true, moderator_list.include?(user))

    client.delete_room_moderator(room['id'], user['id'])
    moderator_list = client.read_room_moderator_list(room['id'])
    refute_equal(true, moderator_list.include?(user))

    # Test Member Role
    client.create_room_member(room['id'], user['id'])
    member_list = client.read_room_member_list(room['id'])
    assert_equal(true, member_list.include?(user))

    client.delete_room_member(room['id'], user['id'])
    member_list = client.read_room_member_list(room['id'])
    refute_equal(true, member_list.include?(user))

    # Test Member Role
    client.create_room_announcer(room['id'], user['id'])
    announcer_list = client.read_room_announcer_list(room['id'])
    assert_equal(true, announcer_list.include?(user))

    client.delete_room_announcer(room['id'], user['id'])
    announcer_list = client.read_room_announcer_list(room['id'])
    refute_equal(true, announcer_list.include?(user))
    client.close
  end

  def test_app_functions
    client = FranklyClient.new(@test_url)

    # test with app secret and key
    client.open(@app_key, @app_secret)
    t_app_functions(client)
    client.close

    # test with identity_token
    nonce = Util.parse_json_string Auth.nonce(URI(@test_url))
    identity_token = generate_identity_token(@app_key, @app_secret, nonce, nil, 'admin')
    client.open(identity_token)
    t_app_functions(client)
    client.close
  end

  def t_app_functions(client)
    client_session = client.read_session

    app = client.read_app(client_session['app']['id'])
    assert_equal(app, client_session['app'])
    client.close
  end
end
