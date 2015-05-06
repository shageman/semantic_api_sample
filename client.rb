require 'json'
require 'net/http'
require 'logger'
require 'uri'

class Client
  attr_reader :uri, :api_key, :http, :logger

  def initialize(host_url, api_key, logger = Logger.new(STDOUT))
    @uri          = URI.parse(host_url)
    @http         = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = uri.scheme == 'https'
    @api_key      = api_key
    @logger       = logger
  end

  def analyze_documents(documents, customer_id, enrichments)
    response = post_job(documents, customer_id, enrichments)
    job_id   = response['id']
    status   = response['status']

    while status == 'pending'
      sleep(0.5)
      response = get_job(job_id)
      status   = response['status']
    end

    response
  end

  def post_job(documents, customer_id, enrichments)
    request = post('/analyticsJobs', create_job_body(customer_id, documents, enrichments))
    response = http.request(request)
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      JSON.parse(response.body)
    else
      logger.error "POST request failed: #{response} - body: #{response.body}"
    end
  end

  def get_job(job_id)
    get = get("/analyticsJobs/#{job_id}")

    response = http.request(get)
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      JSON.parse(response.body)
    else
      logger.error "GET request failed: #{response}"
    end
  end

  private

  def v1_address
    uri.to_s + '/semanticApi/v1'
  end

  def create_job_body(customer_id, documents, enrichments)
    {
      customerId:  customer_id.to_s,
      documents:   documents,
      enrichments: enrichments
    }.to_json
  end

  def get(path)
    get = Net::HTTP::Get.new(v1_address + path)
    get.basic_auth("", api_key)
    get['Accept'] = "application/json"
    get
  end

  def post(path, body)
    post = Net::HTTP::Post.new(v1_address + path)
    post.basic_auth("", api_key)
    post.content_type = "application/json"
    post.body = body
    post
  end
end

