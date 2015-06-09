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
class Files
  def self.create_file(headers, sessionToken, payload)
    headers[:params] = { token: sessionToken }
    RestClient::Request.execute(
      method: 'post',
      url: Util.build_url('files'),
      headers: headers,
      payload: payload
    )
  end

  def self.update_file(headers, sessionToken, destination_url, file_obj, file_size, mime_type, encoding = nil)
    headers[:params] = { token: sessionToken }
    headers['content-length'] = file_size
    headers['content-type'] = mime_type
    headers['content-encoding'] = encoding

    file_bin = file_obj.read
    file_obj.close

    RestClient::Request.execute(
      method: 'put',
      url: destination_url,
      headers: headers,
      payload: file_bin
    )
  end

  def self.update_file_from_path(headers, sessionToken, destination_url, file_path)
    file_obj = File.open(file_path, 'rb')
    file_size = File.size(file_path)
    mime_type = MimeMagic.by_magic(file_obj)
    encoding = CharlockHolmes::EncodingDetector.detect(File.read(file_path))[:type]
    update_file(headers, sessionToken, destination_url, file_obj, file_size, mime_type, encoding)
  end

  def self.upload_file(headers, sessionToken, file_obj, file_size, mime_type, encoding = nil, params)
    cf = create_file(headers, sessionToken, params)
    update_file(headers, sessionToken, cf['url'], file_obj, file_size, mime_type, encoding)
  end

  def self.upload_file_from_path(headers, sessionToken, file_path, params)
    cf = create_file(headers, sessionToken, params)
    update_file_from_path(headers, sessionToken, cf['url'], file_path)
  end
end
