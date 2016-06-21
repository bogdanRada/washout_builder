module WashoutBuilder
  class EnvChecker

    attr_reader :whitelist, :blacklist

    def initialize(whitelist, blacklist)
      self.whitelist = get_valid_data(whitelist)
      self.blacklist = get_valid_data(blacklist)
    end

    def enabled_for_env?(env_name)
      if (whitelist.present? || blacklist.present?) && whitelist.find{|a| blacklist.include?(a) }.blank?
        if whitelist.include?('*') || (!valid_for_env?(blacklist, env_name) || valid_for_env?(whitelist, env_name))
          return true
        end
      end
      return false
    end


    private

    def valid_for_env?(env_name)
      try_find_suitable_env(env_name).present?
    end

    def get_valid_data(list)
      list.is_a?(Array) ? list : [list].compact
    end

    def try_find_suitable_env(env_name)
      # The keys of the map can be strings or regular expressions that are
      # matched against the env name and returns the found value
      env_list.find do |host_pattern|
        if host_pattern.is_a? Regexp
          host_pattern.match env_name
        elsif host_pattern.is_a? String
          host_pattern == env_name
        end
      end.try(:last)
    end

  end
end
