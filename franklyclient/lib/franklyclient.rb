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
require 'json'
require 'jwt'
require 'rest-client'
require 'uri'

require 'franklyclient/auth'
require 'franklyclient/files'
require 'franklyclient/message'
require 'franklyclient/rooms'
require 'franklyclient/util'

# This sfunction generates an identity token suitable for a single authentication attempt
# of a client against the Frankly API or SDK
#
# @param app_key [String]
#   The key that specifies which app this client is authenticating for, this value is
#   provided by the Frankly Console.
#
# @param app_secret [String]
#   The secret value associated the the key allowing the client to securely authenticate
#   against the Frankly API.
#
# @param nonce [String]
#   The nonce value got from Frankly SDK or API whether the identity generation comes from
#   an client device or app backend.
#
# @param user_id [String]
#   This argument must be set to make the SDK operate on behalf of a specific user of the app.
#   For backend services willing to interact with the API directly this may be omitted.
#
# @param role [String]
#   For backend services using the Frankly API this can be set to 'admin' to generate a token
#   allowing the client to get admin priviledges and perform operations that regular users are forbidden to.
#
# @return [String]
#   The function returns the generated identity token as a string.
def generate_identity_token(app_key, app_secret, nonce, user_id = nil, role = nil)
  auth_header = {
    typ: 'JWS',
    alg: 'HS256',
    cty: 'frankly-it;v1'
  }

  auth_claims = {
    aak: app_key,
    iat: Time.now.to_i,
    exp: Time.now.to_i + 10 * 24 * 60 * 60,
    nce: nonce
  }

  auth_claims[:uid] = user_id unless user_id.nil?
  auth_claims[:role] = role unless role.nil?

  JWT.encode(auth_claims, app_secret, 'HS256', auth_header)
end

# Instances of this class can be used to authenticate and query the Frankly REST
# APIs.
class FranklyClient
  def initialize
    @headers = {}
    @session_token = ''
  end

  # This should be the first method called on an instance of FranklyClient,
  # after succesfully returning the client can be used to interact with the Frankly
  # API.
  #
  # @param app_key [String]
  #   The key that specifies which app this client is authenticating for, this value is
  #   provided by the Frankly Console.
  #
  # @param app_secret [String]
  #   The secret value associated the the key allowing the client to securely authenticate
  #   against the Frankly API.
  #
  # @return [nil]
  #  The method doesn't return anything, it modified the internal
  #  state of the object it is called on.
  def open(app_key, app_secret)
    nonce = Auth.nonce[1..-2]

    auth_header = {
      typ: 'JWS',
      alg: 'HS256',
      cty: 'frankly-it;v1'
    }

    auth_claims = {
      aak: app_key,
      iat: Time.now.to_i,
      exp: Time.now.to_i + 10 * 24 * 60 * 60,
      nce: nonce,
      role: 'admin'
    }

    identity_token = generate_identity_token(app_key, app_secret, nonce, nil, 'admin')
    session = JSON.parse Auth.open(identity_token)
    @session_token = session['token']
    @headers = Util.build_headers
  end

  # Discards all internal state maintained by this client.
  def close
    @session_token = nil
    @headers = nil
  end

  # Creates a new room object in the app.
  # The properties of that new room are given as hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new room. See the Rooms
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created room.
  def create_room(payload)
    JSON.parse Rooms.create_room(@headers, @session_token, payload.to_json)
  end

  # Retrieves the list of all available rooms from the app.
  #
  # @return [Array]
  #   The method returns a list of hashes ordered by id, which may be empty if there are no
  #   rooms in the app.
  def read_room_list
    JSON.parse Rooms.read_room_list(@headers, @session_token)
  end

  # Retrieves a room object with id specified as first argument from the app.
  #
  # @param room_id [Int]
  #   The identifier of the room to fetch.
  #
  # @return [Hash]
  #   The method returns a hash that represents the fetched room.
  def read_room(room_id)
    JSON.parse Rooms.read_room(@headers, @session_token, room_id)
  end

  # Updates an existing room object in the app and return that object.
  # The properties of that new room are given as a hash to the method.
  #
  # @param room_id [Integer]
  #   The identifier of the room to update.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new room. See the Rooms
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly updated room.
  def update_room(room_id, payload)
    JSON.parse Rooms.update_room(@headers, @session_token,
                                 room_id, payload.to_json)
  end

  # Deletes an room object with id sepecified as first argument from the app.
  # Note that this will cause all messages sent to this room to be deleted as well,
  # a safer approach could be to change the room status to 'unpublished' to hide it without erasing data.
  # This operation cannot be undone!
  #
  # @param room_id [Int]
  #   The identifier of the room to delete.
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def delete_room(room_id)
    Rooms.delete_room(@headers, @session_token, room_id)
  end

  # This method exposes a generic interface for creating objects through the Frankly API.
  # Every create_* method is implemented on top of this one.
  #
  # @param path [Array]
  #   An Array of strings representing the collection to create an object in.
  #
  # @param params [Hash]
  #   Parameters passed as part of the request.
  #
  # @param payload [Hash]
  #   Dict-like object representing the object to create.
  #
  # @return [Hash/Array]
  #   The method returns either a hash, or an array of hashes representing the
  #   object or objects that were created.
  def create(path, params = {}, payload = {})
    JSON.parse Generic.create(@headers, @session_token, path, params, payload)
  end

  # This method exposes a generic interface for reading objects through the Frankly API.
  # Every read_* method is implemented on top of this one.
  #
  # @param path [Array]
  #   An Array of strings representing the collection to read an object in.
  #
  # @param params [Hash]
  #   Parameters passed as part of the request.
  #
  # @param payload [Hash]
  #   Dict-like object representing the object to create.
  #
  # @return [Hash/Array]
  #   The method returns the object read from the API at the specified path.
  def read(path, params = {}, payload = {})
    JSON.parse Generic.read(@headers, @session_token, path, params, payload)
  end

  # This method exposes a generic interface for updating objects through the Frankly API.
  # Every read_* method is implemented on top of this one.
  #
  # @param path [Array]
  #   An Array of strings representing the collection to read an object in.
  #
  # @param params [Hash]
  #   Parameters passed as part of the request.
  #
  # @param payload [Hash]
  #   Dict-like object representing the object to create.
  #
  # @return [Hash/Array]
  #   The method returns the object updated on the API at the specified path.
  def update(path, params = {}, payload = {})
    JSON.parse Generic.update(@headers, @session_token, path, params, payload)
  end

  # This method exposes a generic interface for deleting objects through the Frankly API.
  # Every delete_* method is implemented on top of this one.
  #
  # @param path [Array]
  #   An Array of strings representing the collection to delete an object in.
  #
  # @param params [Hash]
  #   Parameters passed as part of the request.
  #
  # @param payload [Hash]
  #   A hash representing the body of the request.
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws
  #   an exception on failure.
  def delete(path, params = {}, payload = {})
    JSON.parse Generic.delete(@headers, @session_token, path, params, payload)
  end

  # This method exposes a generic interface for uploading file contents through the Frankly API.
  # Every upload_* method is implemented on top of this one.
  #
  # @param url [String]
  #   The URL at which the file is hosted on Frankly servers. This can be obtained
  #   from the url field of an object returned by create_file for example.
  #
  # @param params [Hash]
  #   Parameters passed as part of the request.
  #
  # @param payload [Hash]
  #   A hash representing the body of the request.
  #
  # @param content_length [Int]
  #   The size of the new file content (in bytes).
  #
  # @param content_type [String]
  #   The mime type of the new file content.
  #
  # @param content_encoding [String]
  #   The encoding of the new file content ('gzip' for example).
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def upload(url, params, payload, content_length, content_type, content_encoding)
    JSON.parse Generic.upload(@headers, @session_token, url, params, payload, content_length, content_type, content_encoding)
  end

  # Creates a new announcement object in the app.
  # The properties of that new announcement are given as hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new announcement. See the Announcement
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created announcement.
  def create_announcement(payload)
    Json.parse Announcement.create_announcement(@headers, @session_token, payload)
  end

  # Retrieves an announcement object with id sepecified as first argument from the app.
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement to fetch.
  #
  # @return [Hash]
  #  The method returns a hash representing the announcement wit the specified id in the app.
  def read_announcement(announcement_id)
    Json.parse Announcement.read_announcement(@headers, @session_token, announcement_id)
  end

  # Deletes an announcement object with id sepecified as first argument from the app.
  # Note that deleting an announcement doesn't remove messages from rooms it has already been published to.
  # This operation cannot be undone!
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement to delete.
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def delete_announcement(announcement_id)
    Json.parse Announcement.delete_announcement(@headers, @session_token, announcement_id)
  end

  # Retrieves a list of announcements available in the app.
  #
  # @return [Array]
  #   The method returns an array of annoucement hashes ordered by id, which may be empty if
  #   there are no announcements in the app.
  def read_announcement_list
    Json.parse Announcement.read_announcement_list(@headers, @session_token)
  end

  # Retrieves a list of announcements available in the app.
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement to fetch.
  #
  # @return [Array]
  #   The method returns an array of annoucement hashes ordered by id, which may be empty if
  #   there are no announcements in the app.
  def read_announcement_room_list(announcement_id)
    Json.parse Announcement.read_announcement_room_list(@headers, @session_token, announcement_id)
  end

  # Creates a new message object in the room with id specified as first argument.
  # The properties of that new message are given as hash to the method.
  #
  # @param room_id [Int]
  #   The identifier of the room to create the message in.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new message. See the Messages
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created message.
  def create_room_message(room_id, payload)
    JSON.parse Message.create_room_message(@headers, @session_token, room_id, payload.to_json)
  end

  # Creates a new message object in the room with id specified as first argument.
  # The properties of that new message are given as hash to the method.
  #
  # @param room_id [Int]
  #   The identifier of the room to create the message in.
  #
  # @param params [Hash]
  #   A hash that defines the range of the messages that are fetched. See the Messages
  #   section above to see how properly format this argument.
  #
  # @return [Array]
  #   The method returns an array of room hashes which may be empty if no messages satisfy the query.
  def read_room_message_list(room_id, params)
    Json.parse Message.read_room_message_list(@headers, @session_token, room_id, params)
  end

  # Creates a new file object on Frankly servers and returns that object.
  # The properties of that new file are given as a hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new file. See the Files
  #   section above to see how properly format this argument.
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created file.
  def create_file(payload)
    JSON.parse Files.create_file(@headers, @session_token, payload.to_json)
  end

  # Creates a new file object on Frankly servers and returns that object.
  # The properties of that new file are given as a hash to the method.
  #
  # @param destination_url [String]
  #   The URL at which the file is hosted on Frankly servers. This can be obtained
  #   from the url field of an object returned by create_file for example.
  #
  # @param file_obj [File]
  #   A file-like object (as returned by File.open(..., "rb") for example) providing
  #   the new content of the file.
  #
  # @param file_size [Int]
  #   The size of the new file content (in bytes).
  #
  # @param mime_type [String]
  #   The mime type of the new file content.
  #
  # @param encoding [String]
  #   The encoding of the new file content ('gzip' for example).
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def update_file(destination_url, file_obj, file_size, mime_type, encoding = nil)
    Files.upload_file(@headers, @session_token, destination_url, file_obj, file_size, mime_type, encoding)
  end

  # Creates a new file object on Frankly servers and returns that object.
  # The properties of that new file are given as a hash to the method.
  #
  # @param destination_url [String]
  #   The URL at which the file is hosted on Frankly servers. This can be obtained
  #   from the url field of an object returned by create_file for example.
  #
  # @param file_path [String]
  #   A path to a local providing the new file content
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def update_file_from_path(destination_url, file_path)
    Files.update_file_from_path(@headers, @session_token, destination_url, file_path)
  end

  # This method is convenience wrapper for creating a new file object on the Frankly API and setting its content.
  #
  # @param file_obj [File]
  #   A file-like object (as returned by File.open(..., "rb") for example) providing
  #   the new content of the file.
  #
  # @param file_size [Int]
  #   The size of the new file content (in bytes).
  #
  # @param mime_type [String]
  #   The mime type of the new file content.
  #
  # @param encoding [String]
  #   The encoding of the new file content ('gzip' for example).
  #
  # @param params [Hash]
  #   A hash containing the properties of the new file. See the Files
  #   section above to see how properly format this argument.
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created file.
  def upload_file(file_obj, file_size, mime_type, encoding = nil, params)
    Files.upload_file(@headers, @session_token, destination_url, file_obj, file_size, mime_type, encoding, params)
  end

  # This method is convenience wrapper for creating a new file object on the Frankly API and setting its content.
  #
  # @param file_path [String]
  #   A path to a local providing the new file content
  #
  # @param params [Hash]
  #   A hash containing the properties of the new file. See the Files
  #   section above to see how properly format this argument.
  #
  # @return [Hash]
  #   The method returns a hash that represents the newly created file.
  def upload_file_from_path(file_path, params)
    Files.upload_file_from_path(@headers, @session_token, file_path, params)
  end
end
