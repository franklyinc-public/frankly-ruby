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
class Generic
  def self.create(address, headers, sessionToken, path, params, payload)
    headers[:params] = params
    headers[:params][:token] = sessionToken
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url(address, path),
      headers: headers,
      payload: payload
    )
  end

  def self.read(address, headers, sessionToken, path, params, payload)
    headers[:params] = params
    headers[:params][:token] = sessionToken
    RestClient::Request.execute(
      method: 'get',
      url: Util.build_url(address, path),
      headers: headers,
      payload: payload
    )
  end

  def self.update(address, headers, sessionToken, path, params, payload)
    headers[:params] = params
    headers[:params][:token] = sessionToken
    RestClient::Request.execute(
      method: 'put',
      url: Util.build_url(address, path),
      headers: headers,
      payload: payload
    )
  end

  def self.delete(address, headers, sessionToken, path, params, payload)
    headers[:params] = params
    headers[:params][:token] = sessionToken
    RestClient::Request.execute(
      method: 'delete',
      url: Util.build_url(address, path),
      headers: headers,
      payload: payload
    )
  end

  def self.upload(address, headers, sessionToken, url, params, payload, content_length, content_type, content_encoding)
    headers[:params] = params
    headers[:params][:token] = sessionToken
    headers['content-length'] = content_length
    headers['content-type'] = content_type
    headers['content-encoding'] = content_encoding
    RestClient::Request.execute(
      method: 'put',
      url: url,
      headers: headers,
      payload: payload
    )
  end
end
