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
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)
    refute_equal('', fc.instance_variable_get(:@sessionToken))
    fc.close
  end

  def test_room_functions
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)

    # Test room creation
    create_room_title = 'test create room: ' + rand(36**10).to_s(36)
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
    update_room_title = 'test update room: ' + rand(36**10).to_s(36)
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

  def test_message_functions
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)

    create_room_title = 'test create room: ' + rand(36**10).to_s(36)
    create_payload = {
      status: 'active',
      title: create_room_title
    }
    cr = fc.create_room(create_payload)

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

  def test_file_functions
    fc = FranklyClient.new
    fc.open(@auth_key, @auth_secret)

    file_payload = {
      category: 'useravatar',
      type: 'image'
    }
    fu = fc.create_file(file_payload)
    puts fu

    assert_equal('useravatar', fu['category'])
    refute_equal(nil, fu['created_on'])
    refute_equal(nil, fu['id'])
    assert_equal('image', fu['type'])
    refute_equal(nil, fu['updated_on'])
    refute_equal(nil, fu['url'])
    assert_equal(1, fu['version'])

    # To test file upload, replace my_file with a local file path
    # myfile = '/file/path.jpg'
    # h = fc.update_file_from_path(fu['url'], my_file)
    # assert_equal(200, h.code)
    fc.close
  end
end
