require 'uri'

  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params.merge!(route_params)
    end

    def [](key)
      @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      parse =  URI::decode_www_form(www_encoded_form)
      results = {}


      parse.each do |key, value|
        parsed_keys = parse_key(key)
        current_hash = nil


        parsed_keys.each_with_index do |parsed_key, idx|
          if parsed_keys.length == 1
            results[parsed_key] = value
            break;
          end

          if idx == 0
            results[parsed_key] ||= {}
            current_hash = results[parsed_key]
          elsif idx == parsed_keys.length - 1
            current_hash[parsed_key] = value
          else
             current_hash[parsed_key] ||= {}
             current_hash = current_hash[parsed_key]
          end
        end
      end

      results
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end


  end
