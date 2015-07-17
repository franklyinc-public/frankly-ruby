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

# @!visibility private
class Rooms
  def self.create_room(address, headers, payload)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms'),
      headers: headers,
      payload: payload
    )
  end

  def self.read_room_list(address, headers)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms'),
      headers: headers
    )
  end

  def self.read_room(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s),
      headers: headers
    )
  end

  def self.update_room(address, headers, room_id, payload)
    RestClient::Request.execute(
      method: 'put',
      url: Util.build_url(address, 'rooms/' + room_id.to_s),
      headers: headers,
      payload: payload
    )
  end

  def self.delete_room(address, headers, room_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s),
      headers: headers
    )
  end

  def self.create_room_owner(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/owners/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_owner_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/owners'),
      headers: headers
    )
  end

  def self.delete_room_owner(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/owners/' + user_id.to_s),
      headers: headers
    )
  end

  def self.create_room_moderator(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/moderators/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_moderator_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/moderators'),
      headers: headers
    )
  end

  def self.delete_room_moderator(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/moderators/' + user_id.to_s),
      headers: headers
    )
  end

  def self.create_room_member(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/members/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_member_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/members'),
      headers: headers
    )
  end

  def self.delete_room_member(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/members/' + user_id.to_s),
      headers: headers
    )
  end

  def self.create_room_announcer(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/announcers/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_announcer_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/announcers'),
      headers: headers
    )
  end

  def self.delete_room_announcer(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/announcers/' + user_id.to_s),
      headers: headers
    )
  end

  def self.create_room_subscriber(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/subscribers/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_subscriber_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/subscribers'),
      headers: headers
    )
  end

  def self.delete_room_subscriber(address, headers, room_id, user_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/subscribers/' + user_id.to_s),
      headers: headers
    )
  end

  def self.read_room_participant_list(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/participants'),
      headers: headers
    )
  end

  def self.read_room_count(address, headers, room_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'rooms/' + room_id.to_s + '/count'),
      headers: headers
    )
  end
end
