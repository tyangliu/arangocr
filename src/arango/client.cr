class Arango::Client
  setter :async

  def initialize(@endpoint : String, @user : String, @password : String)
    @jwt = ""
    uri = URI.parse("#{@endpoint}")
    @http = HTTP::Client.new uri
    @async = false
    response = @http.post(
      "/_open/auth",
      body: {"username" => @user, "password" => @password}.to_json
    )
    if response.status_code == 200
      @jwt = JSON.parse(response.body)["jwt"].to_s
    elsif response.status_code == 404
      puts "Warning! It looks like you are using a passwordless configuration!"
    else
      puts "Error #{response.status_code} #{response.status_message}"
    end
  end

  def database(name : String)
    Database.new(self, name)
  end

  def get(url : String)
    @http.get(url, headers)
  end

  def post(url : String, body)
    @http.post(url, headers: headers, body: body.to_json)
  end

  def post(url : String, body : String)
    @http.post(url, headers: headers, body: body)
  end

  def post(url : String)
    @http.post(url, headers: headers)
  end

  def patch(url : String, body)
    @http.patch(url, headers: headers, body: body.to_json)
  end

  def patch(url : String, body : String)
    @http.patch(url, headers: headers, body: body)
  end

  def delete(url : String)
    @http.delete(url, headers: headers)
  end

  def delete(url : String, body)
    @http.delete(url, headers: headers, body: body.to_json)
  end

  def put(url : String, body)
    @http.put(url, headers: headers, body: body.to_json)
  end

  def put(url : String, body : String)
    @http.put(url, headers: headers, body: body)
  end

  def head(url : String)
    @http.head(url, headers: headers)
  end

  private def headers
    if @async
      HTTP::Headers{"Authorization" => "bearer #{@jwt}", "x-arango-async" => "true"}
    else
      HTTP::Headers{"Authorization" => "bearer #{@jwt}"}
    end
  end
end
