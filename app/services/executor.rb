class Executor

  def initialize
    @hydra = Typhoeus::Hydra.new
  end
  
  def queue(request_url, css_selector, old_value, callback_url, &cb)
    request = Typhoeus::Request.new(request_url)
    request.on_complete do |response|
      process_response(response, callback_url, old_value, css_selector, &cb)
    end
    @hydra.queue request
  end
  
  def run
    @hydra.run
  end
  

  private
  

  def process_response(response, callback_url, old_value, css_selector, &cb)
    return if response.code >= 300 || response.code < 200

    new_content = get_new_content(response.body, css_selector)
    return unless new_content
    return if new_content == old_value

    request_callback(callback_url, new_content, &cb)
  end

  def request_callback(callback_url, value, &cb)
    @hydra.queue Typhoeus::Request.new(callback_url, method: :post, body: value)
    cb.call(value) if block_given?
  end

  def get_new_content(body, css_selector)
    doc = Nokogiri::HTML(body)
    element = doc.css(css_selector).first
    return nil unless element

    element.content
  end

  
end