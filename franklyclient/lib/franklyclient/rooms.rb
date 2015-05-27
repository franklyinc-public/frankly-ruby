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
  def self.create_room(headers, sessionToken, payload)
    headers[:params] = { token: sessionToken}
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url('rooms'),
      headers: headers,
      payload: payload
    )
  end

  def self.read_room_list(headers, sessionToken)
    headers[:params] = { token: sessionToken}
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url('rooms'),
      headers: headers
    )
  end

  def self.read_room(headers, sessionToken, room_id)
    headers[:params] = { token: sessionToken}
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url('rooms/' + room_id.to_s),
      headers: headers
    )
  end

  def self.update_room(headers, sessionToken, room_id, payload)
   headers[:params] = { token: sessionToken}
    RestClient::Request.execute(
      method: 'put',
      url: Util.build_url('rooms/' + room_id.to_s),
      headers: headers,
      payload: payload
    )
  end

  def self.delete_room(headers, sessionToken, room_id)
   headers[:params] = { token: sessionToken}
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url('rooms/' + room_id.to_s),
      headers: headers
    )
  end
end
