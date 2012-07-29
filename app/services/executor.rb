class Executor

  class InvalidResponseCode < Exception; end
  class ElementNotFound < Exception; end

  def self.process_batch
    executor = self.new
    petitions = Petition.next_batch

    petitions.each do |petition|
      petition.last_check = Time.now
      petition.save
      executor.queue(petition)
    end
    executor.run
  end

  def initialize
    @hydra = Typhoeus::Hydra.new
  end
  
  def queue(petition)
    request = Typhoeus::Request.new(petition.request_url)
    request.on_complete do |response|
      process_response(response, petition)
    end
    @hydra.queue request
  rescue Exception => e
    set_error(petition, e)
  end
  
  def run
    @hydra.run
  end
  

  private
  

  def process_response(response, petition)
    raise InvalidResponseCode.new(response.code) if response.code >= 300 || response.code < 200

    new_content = get_new_content(response.body, petition)
    return unless new_content
    return if new_content == petition.last_value

    petition.last_value = new_content
    petition.last_error = nil
    petition.save

    request_callback(petition, new_content)
  rescue Exception => e
    set_error(petition, e)
  end

  def request_callback(petition, value)
    @hydra.queue Typhoeus::Request.new(petition.callback_url, method: :post, body: value)
  end

  def get_new_content(body, petition)
    doc = Nokogiri::HTML(body)
    element = doc.css(petition.css_selector).first
    raise ElementNotFound.new([body, petition.css_selector]) unless element

    element.content
  end

  def set_error(petition, e)
    petition.last_error = e.inspect
    petition.save
    Rails.logger.error("Found an error executing petition #{petition.id}: #{e.inspect}")
  end

end