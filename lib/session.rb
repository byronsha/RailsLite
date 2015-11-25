require 'json'

class Session
  attr_accessor :session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    if req.cookies["_rails_lite_app"]
      @session_cookie = JSON.parse(req.cookies["_rails_lite_app"])
    else
      @session_cookie = {}
    end
  end

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_rails_lite_app", path: "/", value: @session_cookie.to_json)
  end
end
#
# RESPONSE CONTAINS:
#
#   browser cookie (for rails_lite_app) = {
#     'path' => path where cookie was set, ('/')
#     'session' => {gvhgjghj => asldksad}.to_json
#   }
#
# END
#
# #set_cookie ( name of cookie, options)
# options include 'path', 'session'
