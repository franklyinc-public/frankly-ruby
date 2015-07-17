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

class Util
  def self.build_url(base_url, path)
    base_url.to_s + path
  end

  # one argument is a cookie
  # two arguments is key and secret
  def self.build_headers(address, *args)
    headers = {}
    headers['host'] = address.host
    headers['accept'] = 'application/json'
    headers['content-type'] = 'application/json'
    headers['user-agent'] = 'Frankly-SDK/' + Frankly::VERSION + ' (Ruby)'
    headers[:cookies] = args[0] if args.length == 1
    if args.length == 2
      headers['Frankly-App-Key'] = args[0]
      headers['Frankly-App-Secret'] = args[1]
    end
    headers
  end

  def self.parse_json_string(string)
    string[1..-2]
  end

  def self.make_base_address(address)
    case address
    when 'https'
      return 'https://app.franklychat.com/'
    end

    if address.start_with? 'https:'
      return address
    end

    if address.start_with? 'http:'
      return address
    end

    errorMessage = "She given address doesn't tell what protocol to use: " + address
    raise ArgumentError, errorMessage
  end
end
