require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = parse_www_encoded_form(req.query_string) if req.query_string
      if req.body
        if @params
          @params.merge(parse_www_encoded_form(req.body))
        else
          @params = parse_www_encoded_form(req.body)
        end
      end
      if route_params
        route_params = Hash[route_params.map { |key,value|  [key.to_s,value] }]
        if @params
          @params.merge(route_params)
        else
          @params = route_params
        end
      end
    end

    def [](key)
      @params[key.to_s]
    end

    attr_reader :params

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    # private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      hash ||= {}
      query_array = URI::decode_www_form(www_encoded_form)

      query_array.each do |single_query|
        key_list = parse_key(single_query[0])
        length = key_list.length

        next_hash = ""
        0.upto(length - 1) do |index|
          key = key_list[index].to_s
          if index == 0
            unless hash.has_key?(key)
              if length == 1
                hash[key] = single_query[1]
              else
                hash[key] = {}
              end
            end
            next_hash = hash[key]
          elsif index == length - 1
            current_hash = next_hash
            current_hash[key] = single_query[1]
          else
            current_hash = next_hash
            current_hash[key] = {} unless current_hash.has_key?(key)
            next_hash = current_hash[key]
          end
        end
      end

      hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end

  end
end
