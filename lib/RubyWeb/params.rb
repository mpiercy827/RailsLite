require 'uri'

class Params
  #Gather route params, params from query string, and params from response body
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  #Creates deeply nested hash of params
  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?
    URI::decode_www_form(www_encoded_form).each do |key, value|
      nested_keys = parse_key(key)
      construct_params_with(nested_keys, value)
    end
  end

  def construct_params_with(nested_keys, value)
    curr = @params

    nested_keys[0...-1].each do |key|
      curr[key] ||= {}
      curr = curr[key]
    end

    curr[nested_keys.last] = value
  end

  #Splits nested key into an array of keys, useful for construct_params_with
  def parse_key(key)
    regex = /\]\[|\[|\]/
    key.split(regex)
  end
end
