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
class Announcement
  def self.create_announcement(address, headers, payload)
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, 'announcements'),
      headers: headers,
      payload: payload
    )
  end

  def self.read_announcement(address, headers, announcement_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'announcements/' + announcement_id.to_s),
      headers: headers
    )
  end

  def self.delete_announcement(address, headers, announcement_id)
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, 'announcements/' + announcement_id.to_s),
      headers: headers
    )
  end

  def self.read_announcement_list(address, headers)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'announcements'),
      headers: headers
    )
  end

  def self.read_announcement_room_list(address, headers, announcement_id)
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, 'announcements/' + announcement_id.to_s + '/rooms'),
      headers: headers
    )
  end
end
