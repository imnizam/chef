module DexterRedisCookbook
  module Helpers

    # Takes an Enumerable and normalizes Mashes and Chef things
    # to standard Hashes and Arrays
    #
    # @param config type [Enumerable]
    # @return config with Mashes, etc replaced with ruby primitives
    def self.normalize(config)
      if config.is_a?(Chef::Node::ImmutableMash) or config.is_a?(Mash)
        config = config.to_hash
        config.inject({}) do |h,(k,v)|
          h[k] = normalize(v)
          h
        end
      elsif config.is_a?(Chef::Node::ImmutableArray) or config.is_a?(Array)
        config = config.to_a
        config.map { |x| normalize(x) }
      else
        config
      end
    end

    # Takes an Enumerable and spits out a YAML file.
    #
    # @param config type [Enumerable]
    # @return 'mold' the serialized YAML
    def self.hash_to_yaml(config)
      require 'yaml'
      YAML::dump(normalize(config.dup))
    end
  end
end
