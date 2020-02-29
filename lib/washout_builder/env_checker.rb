module WashoutBuilder
  class EnvChecker

    attr_reader :app
    attr_writer :app

    def initialize(app)
      self.app = app
    end

    def available_for_env?(env_name)
      if whitelist.present? || blacklist.present?
        if whitelist.find{|a| blacklist.include?(a) }.blank?
          if whitelist.include?('*') || (!valid_for_env?(blacklist, env_name) && valid_for_env?(whitelist, env_name))
            return true
          end
        end
      else
        return true
      end
      false
    end


    private

    def whitelist
      get_valid_data(app_config[:whitelisted_envs])
    end

    def blacklist
      get_valid_data(app_config[:blacklisted_envs])
    end

    def app_config
      app.config.washout_builder
    end

    def valid_for_env?(list, env_name)
      try_find_suitable_env(list, env_name).present?
    end

    def get_valid_data(list)
      (list.is_a?(Array) ? list : [list]).compact
    end

    def try_find_suitable_env(list, env_name)
      return if list.blank?
      # The keys of the map can be strings or regular expressions that are
      # matched against the env name and returns the found value
      list.find do |env_pattern|
        if env_pattern.is_a? Regexp
          env_pattern.match env_name
        elsif env_pattern.is_a? String
          env_pattern == env_name
        end
      end
    end

  end
end
