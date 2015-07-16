##
# The MIT License (MIT)
#
# Copyright (c) 2015 Frankly Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

# = Usage
# The sections below explain how to use the module to authenticate and query the <b>
# Frankly API</b>.
#
# All operations to the API are made from instances of the <b>FranklyClient</b> class. Those
# objects expose methods to the application which map to remote procedure calls (RPC)
# on the <b>Frankly</b> servers, they also negotiate and maintain the state required by the
# API's security policies.
#
# Here's how <b>FranklyClient</b> instances are created:
#     require 'frankly-ruby'
#     client = FranklyClient.new
#
# == Authentication
# Before performing any operation (calling any method) the client instance needs to authenticate
# against Frankly API. The API supports different permission levels but this module is designed
# to only allow <em>admin</em> authentication.
#
# In order to authenticate as an <em>admin</em> user, the client needs to be given the <b>app_key</b>
# and <b>app_secret</b> values obtained from the {Frankly Console}[https://console.franklychat.com/].
#
# Here's how to perform authentication:
#     require 'frankly-ruby'
#
#     app_key    = 'app_key from Frankly Console'
#     app_secret = 'app_secret from Frankly Console'
#
#     client = FranklyClient.new
#     client.open(app_key, app_secret)
#
# The call to <b>open</b> returns a session object if the authentication was successful. The application can now
# use this instance of <b>FranklyClient</b> to perform other operations.
#
# <em>Please do not publish your</em> <b>app_secret</b> <em>value to the public. This can have security implications
# and could be used by an attacker to alter the content of your application.</em>
#
# == Rooms
# One of the central concepts in the <b>Frankly API</b> is the chat room. A chat room is a collection of
# messageswith some associated meta-data, like the title, description, or avatar image, that can be
# displayed when the endusers access a mobile or web app that uses the <b>Frankly SDK</b>. With the <b>Frankly
# API</b>, you can create, update, and delete chat rooms.
#
# This code snippet shows how to create chat rooms:
#     require 'frankly-ruby'
#
#     room_payload = {
#       title:       'Hi',
#       description: 'My First Chat Room',
#       status:      'active'
#     }
#     room = client.create_room(room_payload)
#
# As we can see here, when creating the room the application must specify a <em>status</em> property
# which can be one of the following:
# * <b>unpublished</b> In this state, the room will not be shown to clients fetching the list of
#   available rooms in the app. This is useful if the application needs to create rooms that shouldn't
#   be available yet because they still need to be modified.
#
# * <b>active</b> In this state, the room will be fetched by clients and will be displayed in the list of available
#   rooms that endusers can join to start chatting with each other.
#
# * <b>inactive</b> This last state is an intermediary state between the first two. The room will be
#   part of fetching operations but it will not be displayed in the mobile or web app UI. This state is useful
#   for testing purposes.
#
# In addition to the data available in the room object, you can also fetch data about the number of users that are
# in that room. The room count function returns a hash that lists the <b>active</b>, <b>online</b>, and <b>subscribed</b>
# user counts. <b>Online</b> represents the users that are currently in the room, <b>subscribed</b> represents the users
# that have subscribed to the room, and <b>active</b> is the union of the online and subscribed users.
#
# This code snippet shows how to fetch the room count:
#      room = client.create_room(room_payload)
#      count = client.read_room_count(room['id'])
#
# == Message
# Frankly, being a chat platform, allows applications to sendand receive messages. Naturally,
# <b>FranklyClient</b> instances can fetch messages and publish them to chat rooms.
#
# This code snippet shows how to create messages:
#     require 'frankly-ruby'
#
#     message1_payload = {
#       contents: [{
#         type:  'text/plain',
#         value: 'Hello World!'
#       }]
#     }
#     message1 = client.create_room_message(room['id'],create_payload)
#
#     message2_payload = {
#       contents: [{
#         type: 'image/*',
#         url:  'https://app.franklychat.com/files/...'
#       }]
#     }
#     message2 = client.create_room_message(room['id'],create_payload)
#
# Let's explain what's happening here: messages published to chat rooms can contain multiple
# parts; they could contain a few text enries, text an an image, several images, etc. The contents
# property of the message is actually a list of objects, the fields of the <em>contents</em. objects are:
# * <b>type</b> This is the mime type of the actual content it represents, it gives the application
#   information about how to render the content. This field is mandatory.
#
# * <b>value</b> This is used for inline resources directly embedded into the message. One of <em>value</em>
#   or <em>url</em> must be specified.
#
# * <b>url</b> This is the inline resource that is directly imbedded into the message.
#   One of <em>value</em> or <em>url</em> must be specified.
#
# Typically, text messages are inlined because they are small enough resources that they can be embedded into
# the message without having an impact on the user experience. Images, on the other hand, may take a while to download
# and caching mechanisms can be used to optimize rendering by preventing large resources from downloading too often.
# This is why we provide the <em>value</em> as a remote resouce (we'll see later in the  <em>Files</em> section how to
# generate remote resource URLs).
#
# <em>Keep in mind that when a message is created, it will be broadcasted to every client application that is currently
# listening for messages in that chat room.</em>
#
# === Announcements
# Announcements are a type of message that is only available to admin users.
# A client authenticated with admin priviledges can create announcements in the app which can be published
# to one or more rooms at a later time.
#
# Currently, the only type of Announcement is the Sticky Message. Once the most recent Sticky
# Message sent reaches the top of the Chat Room UI, it will anchor to the top until a new
# Sticky Message replaces it. This provides context to the endusers about what has recently
# happened or what is currently happening to make it easier for them to jump in and chat.
#
# Here's how an app using the frankly module would create and then publish announcements:
#     require 'frankly-ruby'
#
#     anno_payload = {
#       sticky: true,
#       contents: [{
#         type:  'text/plain',
#         value: 'Hello World!'
#       }]
#     }
#
#     anno = client.create_announcement(anno_payload)
#     client.create_room_message(room.id, {announcement: anno['id']})
# As we can see here, the announcement is created with the same structure than a regular message. The content of the
# announcement well be set as the message content when it is published to the room and the contents field obeys the rules
# about inline and remote content that were described in the <em>Messages</em> section.
#
#
# == Users
#
# === Roles
#
#
# == Files
# Objects of the <b>Frankly API</b> can have URL properties set to reference remote resources like images. All these
# URLs must be within the <b>+https://app.franklychat.com+</b> domain, which means an application must upload these
# resources to Frankly servers.
#
# Uploading a file happens in two steps, first the application needs to request a new file URL to the <b>Frankly API</b>,
# then it can use that URL to upload a resource to Frankly servers. Lukily the frankly module abstracts this nicely in a
# single operation, here's an example of how to set an image for a chat room:
#     require 'frankly-ruby'
#
#     file_payload = {
#       category:  'useravatar',
#       type: 'image'
#     }
#
#     file = client.upload_file_from_path('./path/to/image.pnp',file_payload)
#     room = client.update_room(room.id, {avatar_image_url = file['url']})
#
# The object returned by a call to <b>+upload_file_from_path+</b> and other upload methods is created in the first step
# described above. The <b>+category+</b> parameter shown here is used by the <b>Frankly API</b> to determine which
# formatting rules should be applied to the resource. Since the files will be optimized for different situations based
# on their category, it will be easier to integrate with Frankly and this will create a better user experience.
#
# Here are the file categories currently available:
# * <b>chat</b>
#   This is the default category and is usually applied to images sent by endusers.
#
# * <b>useravatar</b>
#   This category is for files that will be displayed in room lists.
#
# * <b>roomavatar</b>
#   This category is for files that will be displayed in room lists.
#
# * <b>featuredavatar</b>
#   This category is for files that will represent featured rooms.
#
# * <b>sticker</b>
#   This category is for files that are used in sticker messages.
#
# * <b>stickerpack</b>
#   This category is for files that will be the avatar of a sticker pack.
#
# == Moderation
# === Bans
# With the <b>Frankly API</b>, you can read the ban status of a given user. A banned user will not be able to send
# messages so it will be useful to determine programmatically if a user has been banned.
# Here's an example of how you can read the ban status of a user
#
#     require 'frankly-client'
#
#     user_id = #some number
#     ban = client.read_user_ban(user_id)
#

# === Message Flagging

# @!visibility private
require 'charlock_holmes'
require 'io/console'
require 'json'
require 'jwt'
require 'mimemagic'
require 'rest-client'
require 'uri'

require 'frankly-ruby/apps'
require 'frankly-ruby/auth'
require 'frankly-ruby/announcement'
require 'frankly-ruby/files'
require 'frankly-ruby/generic'
require 'frankly-ruby/message'
require 'frankly-ruby/rooms'
require 'frankly-ruby/sessions'
require 'frankly-ruby/users'
require 'frankly-ruby/util'
require 'frankly-ruby/version'

# This function generates an identity token suitable for a single authentication attempt
# of a client against the Frankly API or SDK
#
# @param app_key [String]
#   The key that specifies which app this client is authenticating for, this value is
#   provided by the Frankly Console.
#
# @param app_secret [String]
#   The secret value associated with the key that allows the client to securely authenticate
#   against the Frankly API.
#
# @param nonce [String]
#   The nonce value got from Frankly SDK or API whether the identity generation comes from
#   an client device or app backend.
#
# @param user_id [String]
#   This argument must be set to make the SDK operate on behalf of a specific user of the app.
#   For backendservices willing to interact with the API directly this may be omitted.
#
# @param role [String]
#   For backendservices using the Frankly API this can be set to 'admin' to generate a token
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
  def initialize(address = 'https:')
    @base_url = URI(Util.make_base_address(address))
    @headers = {}
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
  def open(*args)
    if args.length == 2
      app_key = args[0]
      app_secret = args[1]
      @headers = Util.build_headers(@base_url, app_key, app_secret)
    else
      if args.length == 1
        identity_token = args[0]
        response = Auth.open(@base_url, identity_token)
        @headers = Util.build_headers(@base_url, response.cookies)
      else
        fail 'Incorrect number of arguments'
      end
    end
  end

  # Discards all internal state maintained by this client.
  def close
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
  #   A hash that represents the newly created room.
  def create_room(payload)
    JSON.parse Rooms.create_room(@base_url, @headers, payload.to_json)
  end

  # Retrieves the list of all available rooms in the app.
  #
  # @return [Array]
  #   A list of hashes ordered by id, which may be empty if there are no
  #   rooms in the app.
  def read_room_list
    JSON.parse Rooms.read_room_list(@base_url, @headers)
  end

  # Retrieves the room object with the id specified in the first argument.
  #
  # @param room_id [Int]
  #   The identifier of the room to fetch.
  #
  # @return [Hash]
  #   A hash that represents the fetched room.
  def read_room(room_id)
    JSON.parse Rooms.read_room(@base_url, @headers, room_id)
  end

  # Updates the existing room object with the id specified in the first argument and returns that
  # object. The properties to update are given to the method as a hash.
  #
  # @param room_id [Integer]
  #   The identifier of the room to update.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new room. See the Rooms
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   A hash that represents the newly updated room.
  def update_room(room_id, payload)
    JSON.parse Rooms.update_room(@base_url, @headers, room_id, payload.to_json)
  end

  # Deletes the room object with the id sepecified in the first argument.
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
    Rooms.delete_room(@base_url, @headers, room_id)
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
  #   Either a hash, or an array of hashes representing the
  #   object or objects that were created.
  def create(path, params = {}, payload = {})
    JSON.parse Generic.create(@base_url, @headers, path, params, payload)
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
  #   The object read from the API at the specified path.
  def read(path, params = {}, payload = {})
    JSON.parse Generic.read(@base_url, @headers, path, params, payload)
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
  #   The object updated on the API at the specified path.
  def update(path, params = {}, payload = {})
    JSON.parse Generic.update(@base_url, @headers, path, params, payload)
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
    JSON.parse Generic.delete(@base_url, @headers, path, params, payload)
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
    JSON.parse Generic.upload(@headers, url, params, payload, content_length, content_type, content_encoding)
  end

  # Creates a new user in the app.
  # The properties of that new user are given as hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new user. See the Users
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   A hash that represents the newly created user.
  def create_user(payload)
    JSON.parse Users.create_user(@base_url, @headers, payload.to_json)
  end

  # Retrieves the user object with the id specified in the first argument.
  #
  # @param user_id [Int]
  #   The identifier of the room to fetch.
  #
  # @return [Hash]
  #   A hash that represents the fetched user.
  def read_user(user_id)
    JSON.parse Users.read_user(@base_url, @headers, user_id)
  end

  # Updates an existing user object in the app and returns that object.
  # The properties of that new user are given as a hash to the method.
  #
  # @param user_id [Integer]
  #   The identifier of the room to update.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new room. See the Users
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   A hash that represents the newly updated user.
  def update_user(user_id, payload)
    JSON.parse Users.update_user(@base_url, @headers, user_id, payload.to_json)
  end

  # Deletes the user object with the id sepecified in the first argument.
  #
  # @param room_id [Int]
  #   The identifier of the user to delete.
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def delete_user(user_id)
    Users.delete_user(@base_url, @headers, user_id)
  end

  # Retrieves the ban status of the user with the id specified in the first argument.
  #
  # @param user_id [Int]
  #   The identifier of the user whose ban status is fetched.
  #
  # @return [Hash]
  #   A hash that represents the ban status of the user.
  def read_user_ban(user_id)
    JSON.parse Users.read_user_ban(@base_url, @headers, user_id)
  end

  # Creates a new announcement object in the app.
  # The properties of that new announcement are given as hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new announcement. See the Announcement
  #   section above to see how properly format this argument
  #
  # @return [Hash]
  #   A hash that represents the newly created announcement.
  def create_announcement(payload)
    JSON.parse Announcement.create_announcement(@base_url, @headers, payload.to_json)
  end

  # Retrieves the announcement object with the id sepecified in the first argument.
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement to fetch.
  #
  # @return [Hash]
  #  A hash representing the announcement with the specified id.
  def read_announcement(announcement_id)
    JSON.parse Announcement.read_announcement(@base_url, @headers, announcement_id)
  end

  # Deletes the announcement object with the id sepecified in the first argument.
  # Note that deleting an announcement doesn't remove messages from rooms it has already been published to.
  # This operation cannot be undone!
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement to delete.
  #
  # @return [nil]
  #   The method doesn't return anything on success and throws an exception on failure.
  def delete_announcement(announcement_id)
    Announcement.delete_announcement(@base_url, @headers, announcement_id)
  end

  # Retrieves the list of announcements that are available in the app.
  #
  # @return [Array]
  #   An array of annoucement hashes ordered by id, which may be empty if
  #   there are no announcements in the app.
  def read_announcement_list
    JSON.parse Announcement.read_announcement_list(@base_url, @headers)
  end

  # Retrieves the list of rooms that an annoucement has been published to.
  #
  # @param announcement_id [Int]
  #   The identifier of the announcement used to generate the room list.
  #
  # @return [Array]
  #   A list of room objects ordered by id, which may be empty
  #   if the announcement haven't been published yet.
  def read_announcement_room_list(announcement_id)
    JSON.parse Announcement.read_announcement_room_list(@base_url, @headers, announcement_id)
  end

  # Creates a new message object in the room with the id specified in the first argument.
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
  #   A hash that represents the newly created message.
  def create_room_message(room_id, payload)
    JSON.parse Message.create_room_message(@base_url, @headers, room_id, payload)
  end

  # Fetches a list of messages from the room with the id specified in the first argument.
  #
  # @param room_id [Int]
  #   The identifier of the room whose messages are being fetched.
  #
  # @param params [Hash]
  #   A hash that defines the range of the messages that are fetched. See the Messages
  #   section above to see how properly format this argument.
  #
  # @return [Array]
  #   An array of room hashes which may be empty if no messages satisfy the query.
  def read_room_message_list(room_id, params)
    JSON.parse Message.read_room_message_list(@base_url, @headers, room_id, params)
  end

  # Retrieves the message object with the id sepecified in first argument from the room
  # with the id specified in the second argument.
  #
  # @param room_id [Int]
  #   The identifier of the room to create the message in.
  #
  # @param message_id [Int]
  #   The identifier of the message to fetch.
  #
  # @return [Hash]
  #  A hash representing the message with the specified id.
  def read_room_message(room_id, message_id)
    JSON.parse Message.read_room_message(@base_url, @headers, room_id, message_id)
  end

  # Creates a new file object on Frankly servers and returns that object.
  # The properties of that new file are given as a hash to the method.
  #
  # @param payload [Hash]
  #   A hash containing the properties of the new file. See the Files
  #   section above to see how properly format this argument.
  #
  # @return [Hash]
  #   A hash that represents the newly created file.
  def create_file(payload)
    JSON.parse Files.create_file(@base_url, @headers, payload.to_json)
  end

  # Creates a new file object on Frankly servers and returns that object.
  # The properties of that new file are given as a hash to the method.
  #
  # @param destination_url [String]
  #   The URL at which the file is hosted on Frankly servers. This can be obtained
  #   from the url field of an object returned by create_file for example.
  #
  # @param file_obj [File]
  #   A file-like object (as returned by File.open(..., 'rb') for example) providing
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
    Files.upload_file(@base_url, @headers, destination_url, file_obj, file_size, mime_type, encoding)
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
    Files.update_file_from_path(@base_url, @headers, destination_url, file_path)
  end

  # This method is convenience wrapper for creating a new file object on the Frankly API and setting its content.
  #
  # @param file_obj [File]
  #   A file-like object (as returned by File.open(..., 'rb') for example) providing
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
  #   A hash that represents the newly created file.
  def upload_file(file_obj, file_size, mime_type, encoding = nil, params)
    Files.upload_file(@base_url, @headers, destination_url, file_obj, file_size, mime_type, encoding, params)
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
  #   A hash that represents the newly created file.
  def upload_file_from_path(file_path, params)
    Files.upload_file_from_path(@base_url, @headers, file_path, params)
  end

  # This method returns an object representing the current user's session
  # See the Sessions section above for a description of the contents of the user session.
  #
  # @return [Hash]
  #   A hash that represents the current session.
  def read_session
    JSON.parse Sessions.read_session(@base_url, @headers)
  end

  # This method deletes the current session. After this function is called, the other
  # functions will return exceptions until open is called again.
  #
  # @return [nil]
  #   The method does not return anything and throws an exception on failure
  def delete_session
    Sessions.delete_session(@base_url, @headers)
  end

  # This method gives the user with id user_id the role of owner in the room with
  # id room_id.
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of owner.
  #
  # @param user_id [Int]
  #   The identifier of the user that will have the role of owner.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure.
  def create_room_owner(room_id, user_id)
    Rooms.create_room_owner(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room with the
  # role of owner.
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users with the owner role.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   owner role.
  def read_room_owner_list(room_id)
    JSON.parse Rooms.read_room_owner_list(@base_url, @headers, room_id)
  end

  # This method removes the role of owner from the user with id user_id in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of owner removed.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure.
  def delete_room_owner(room_id, user_id)
    Rooms.delete_room_owner(@base_url, @headers, room_id, user_id)
  end

  # This method gives the user with id user_id the role of moderator in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of moderator.
  #
  # @param user_id [Int]
  #   The identifier of the user that will have the role of moderator.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def create_room_moderator(room_id, user_id)
    Rooms.create_room_moderator(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room with the
  # role of moderator
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users with the moderator role.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   moderator role
  def read_room_moderator_list(room_id)
    JSON.parse Rooms.read_room_moderator_list(@base_url, @headers, room_id)
  end

  # This method removes the role of moderator from the user with id user_id in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of moderator removed.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def delete_room_moderator(room_id, user_id)
    Rooms.delete_room_moderator(@base_url, @headers, room_id, user_id)
  end

  # This method gives the user with id user_id the role of member in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of member.
  #
  # @param user_id [Int]
  #   The identifier of the user that will have the role of member.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def create_room_member(room_id, user_id)
    Rooms.create_room_member(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room with the
  # role of member
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users with the member role.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   member role
  def read_room_member_list(room_id)
    JSON.parse Rooms.read_room_member_list(@base_url, @headers, room_id)
  end

  # This method removes the role of member from the user with id user_id in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of member removed.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def delete_room_member(room_id, user_id)
    Rooms.delete_room_member(@base_url, @headers, room_id, user_id)
  end

  # This method gives the user with id user_id the role of announcer in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of announcer.
  #
  # @param user_id [Int]
  #   The identifier of the user that will have the role of announcer.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def create_room_announcer(room_id, user_id)
    Rooms.create_room_announcer(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room with the
  # role of announcer
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users with the announcer role.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   announcer role
  def read_room_announcer_list(room_id)
    JSON.parse Rooms.read_room_announcer_list(@base_url, @headers, room_id)
  end

  # This method removes the role of announcer from the user with id user_id in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of announcer removed.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def delete_room_announcer(room_id, user_id)
    Rooms.delete_room_announcer(@base_url, @headers, room_id, user_id)
  end

  # This method gives the user with id user_id the role of subscriber in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of subscriber.
  #
  # @param user_id [Int]
  #   The identifier of the user that will have the role of subscriber.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def create_room_subscriber(room_id, user_id)
    Rooms.create_room_subscriber(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room with the
  # role of subscriber
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users with the subscriber role.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   subscriber role
  def read_room_subscriber_list(room_id)
    JSON.parse Rooms.read_room_subscriber_list(@base_url, @headers, room_id)
  end

  # This method removes the subscriber role from the user with id user_id in the room with
  # id room_id
  #
  # @param room_id [Int]
  #   The identifier of the room in which the user will have the role of subscriber removed.
  #
  # @return [nil]
  #   This method does not return anything and throws an exception on failure
  def delete_room_subscriber(room_id, user_id)
    Rooms.delete_room_subscriber(@base_url, @headers, room_id, user_id)
  end

  # The method returns a hash that contains a list of all of the users in the room.
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users.
  #
  # @return [Array]
  #   An array of hashes that represent the users in the room with the
  #   participant role
  def read_room_participant_list(room_id)
    JSON.parse Rooms.read_room_participant_list(@base_url, @headers, room_id)
  end

  # The method returns a hash that contains the number of active, subscribed, and online users in the
  # room with id room_id.
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the users.
  #
  # @return [Hash]
  #   A hash that contains the active, subscribed, and online user counts.
  def read_room_count(room_id)
    Rooms.read_room_count(@base_url, @headers, room_id)
  end

  # This method returns a hash that contains all of the properties of the application with it
  # app_id. See the Application section above for more information.
  #
  # @param app_id [Int]
  #   The identifier of the application.
  #
  # @return [Hash]
  #   A hash that contains the properties of the app.
  def read_app(app_id)
    JSON.parse Apps.read_app(@base_url, @headers, app_id)
  end

  # This method flags the message with id message_id in the room with id room_id.
  #
  # @param room_id [Int]
  #   The identifier of the room that contains the messsage to be flagged.
  #
  # @param message_id [Int]
  #   The identifier of the messsage being flagged.
  #
  # @return [nil]
  #   The method doesn't return anything and throws an exception on failure.
  def create_room_message_flag(room_id, message_id)
    JSON.parse Message.create_room_message_flag(@base_url, @headers, room_id, message_id)
  end
end
