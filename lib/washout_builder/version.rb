# Returns the version of the currently loaded gem as a <tt>Gem::Version</tt>
module WashoutBuilder
  #  Returns the version of the currently loaded gem as a <tt>Gem::Version</tt>
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  # the module that is used to generate the gem version
  module VERSION
    # the major version of the gem
    MAJOR = 1
    # the minor version of the gem
    MINOR = 1
    # the tiny version of the gem
    TINY = 2
    # if the version should be a e
    PRE = nil

    # the full version of the gem composed from major minor tiny and prerelease versions
    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')
  end
end
