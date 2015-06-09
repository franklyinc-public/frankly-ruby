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

require 'franklyclient'

require 'minitest/autorun'

class FranklyClientTest < MiniTest::Unit::TestCase
  def setup
    @auth_key = ENV['auth_key']
    @auth_secret = ENV['auth_secret']
  end

  def test_open
    client = FranklyClient.new
    client.open(@auth_key, @auth_secret)
    refute_equal('', client.instance_variable_get(:@sessionToken))
    client.close
  end

  def test_announcement_functions
    client = FranklyClient.new
    client.open(@auth_key, @auth_secret)

    room_title = 'test create room: ' + rand(36**4).to_s(36)
    room_payload = {
      status: 'active',
      title: room_title
    }
    room = client.create_room(room_payload)

    announcement_payload = {
      contextual: true,
      contents: [
        {
          type:       'text/plain',
          value:      'text'
        }
      ]
    }

    announcement = client.create_announcement(announcement_payload)

    assert_equal([{ 'type' => 'text/plain', 'value' => 'text' }], announcement['contents'])
    assert_equal(true, announcement['contextual'])
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
    assert_equal(true, published_announcement['contextual'])
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
    client = FranklyClient.new
    client.open(@auth_key, @auth_secret)

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
    # client.close
  end

  def test_message_functions
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)

    room_title = 'test create room: ' + rand(36**4).to_s(36)
    room_payload = {
      status: 'active',
      title: room_title
    }
    cr = fc.create_room(room_payload)

    message_payload = {
      contents: [
        {
          type: 'text/plain',
          value: 'text'
        }
      ]
    }
    m = fc.create_room_message(cr['id'], message_payload)

    assert_equal([{ 'type' => 'text/plain', 'value' => 'text' }], m['contents'])
    assert_equal(false, m['contextual'])
    refute_equal(nil, m['created_on'])
    refute_equal(nil, m['id'])
    assert_equal(cr['id'], m['room_id'])
    refute_equal(nil, m['sent_on'])
    refute_equal(nil, m['updated_on'])
    assert_equal(1, m['version'])

    fc.delete_room(cr['id'])
    fc.close
  end

  def test_room_functions
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)

    # Test room creation
    create_room_title = 'test create room: ' + rand(36**4).to_s(36)
    create_payload = {
      status: 'active',
      title: create_room_title
    }
    cr = fc.create_room(create_payload)
    assert_equal(nil, cr['avatar_image_url'])
    refute_equal(nil, cr['created_on'])
    assert_equal(nil, cr['description'])
    assert_equal(false, cr['featured'])
    assert_equal(nil, cr['featured_image_url'])
    refute_equal(nil, cr['id'])
    assert_equal(0, cr['list_position'])
    assert_equal('active', cr['status'])
    assert_equal(false, cr['subscribed'])
    assert_equal(create_room_title, cr['title'])
    refute_equal(nil, cr['updated_on'])
    assert_equal(1, cr['version'])

    # Test room read
    rr = fc.read_room(cr['id'])
    assert_equal(cr, rr)

    # Test room update
    update_room_title = 'test update room: ' + rand(36**4).to_s(36)
    update_payload = {
      description: 'updated description',
      title: update_room_title,
      list_position: 1
    }
    ur = fc.update_room(cr['id'], update_payload)
    assert_equal(nil, ur['avatar_image_url'])
    refute_equal(nil, ur['created_on'])
    assert_equal('updated description', ur['description'])
    assert_equal(false, ur['featured'])
    assert_equal(nil, ur['featured_image_url'])
    refute_equal(nil, ur['id'])
    assert_equal(1, ur['list_position'])
    assert_equal('active', ur['status'])
    assert_equal(false, ur['subscribed'])
    assert_equal(update_room_title, ur['title'])
    refute_equal(nil, ur['updated_on'])
    assert_equal(2, ur['version'])

    # Test room list read
    rl = fc.read_room_list
    assert_equal(true, rl.include?(ur))

    # Test room delete
    fc.delete_room(cr['id'])
    rl = fc.read_room_list
    refute_equal(true, rl.include?(ur))
    fc.close
  end
end
