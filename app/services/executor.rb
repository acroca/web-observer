class Executor

  class InvalidResponseCode < Exception; end
  class ElementNotFound < Exception; end

  def self.process_batch
    executor = self.new
    petitions = Petition.next_batch

    petitions.each do |petition|
      petition.last_check = Time.now
      petition.save
      executor.queue(petition.request_url, petition.css_selector, petition.last_value, petition.callback_url) do |v, err|
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
  
  def queue(request_url, css_selector, old_value, callback_url, &cb)
    request = Typhoeus::Request.new(request_url)
    request.on_complete do |response|
      process_response(response, callback_url, old_value, css_selector, &cb)
    end
    @hydra.queue request
  rescue Exception => e
    cb.call(nil, e)
  end
  
  def run
    @hydra.run
  end
  

  private
  

  def process_response(response, callback_url, old_value, css_selector, &cb)
    raise InvalidResponseCode.new(response.code) if response.code >= 300 || response.code < 200

    new_content = get_new_content(response.body, css_selector)
    return unless new_content
    return if new_content == old_value

    request_callback(callback_url, new_content, &cb)
  rescue Exception => e
    cb.call(nil, e)
  end

  def request_callback(callback_url, value, &cb)
    @hydra.queue Typhoeus::Request.new(callback_url, method: :post, body: value)
    cb.call(value, nil) if block_given?
  end

  def get_new_content(body, css_selector)
    doc = Nokogiri::HTML(body)
    element = doc.css(css_selector).first
    raise ElementNotFound.new([body, css_selector]) unless element

    element.content
  end

end