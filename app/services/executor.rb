class Executor

  class InvalidResponseCode < Exception; end
  class ElementNotFound < Exception; end

  def self.process_batch
    executor = self.new
    petitions = Petition.next_batch

    petitions.each do |petition|
      petition.last_check = Time.now
      petition.save
      executor.queue(petition) do |v, err|
        if err.nil?
          petition.last_value = v
          petition.last_error = nil
        else
          petition.last_error = err.inspect
          Rails.logger.error("Found an error executing petition #{petition.id}: #{err.inspect}")
        end
        petition.save
      end
    end
    executor.run
  end

  def initialize
    @hydra = Typhoeus::Hydra.new
  end
  
  def queue(petition, &cb)
    request = Typhoeus::Request.new(petition.request_url)
    request.on_complete do |response|
      process_response(response, petition, &cb)
    end
    @hydra.queue request
  rescue Exception => e
    cb.call(nil, e)
  end
  
  def run
    @hydra.run
  end
  

  private
  

  def process_response(response, petition, &cb)
    raise InvalidResponseCode.new(response.code) if response.code >= 300 || response.code < 200

    new_content = get_new_content(response.body, petition)
    return unless new_content
    return if new_content == petition.last_value

    request_callback(petition, new_content, &cb)
  rescue Exception => e
    cb.call(nil, e)
  end

  def request_callback(petition, value, &cb)
    @hydra.queue Typhoeus::Request.new(petition.callback_url, method: :post, body: value)
    cb.call(value, nil) if block_given?
  end

  def get_new_content(body, petition)
    doc = Nokogiri::HTML(body)
    element = doc.css(petition.css_selector).first
    raise ElementNotFound.new([body, petition.css_selector]) unless element

    element.content
  end

end