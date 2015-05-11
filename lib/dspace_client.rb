require 'rest-client'

class DspaceClient
  attr_reader :rest_client

  def initialize(url)
    @url = url
    @rest_client = build_rest_client url
  end

  def repository
    @dspace_repository ||= build_repository @rest_client
  end

  def login(username, password)
    user = JSON.generate({
                             email: username,
                             password: password
                         })

    # send login request to server and receive the token
    authenticated_token = @rest_client['/login'].post user

    # overwrite the rest_client and dspace_repository
    @rest_client = build_rest_client @url, rest_dspace_token: authenticated_token
    @dspace_repository = build_repository @rest_client

    return (!authenticated_token.nil?)
  end

  def logout
    response = JSON.parse @rest_client['/logout'].post []
  end

  def status
    response = JSON.parse @rest_client['/status'].get
  end

  def test
    response = JSON.parse(@rest_client['/test'].get)
  end

  private

  def build_repository(rest_client)
    DSpaceRest::Repositories::DspaceRepository.new rest_client
  end

  def build_rest_client(url, headers={})
    RestClient::Resource.new(url,
                             verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                             headers: headers.merge(
                                 content_type: :json,
                                 accept: :json
                             )
    )
  end

end