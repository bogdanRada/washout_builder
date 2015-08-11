
module FIxMinitest
  def self.disable_autorun
    disable_auto_runner
    override_minitest_run
    override_minitest_unit_run
  end

  # rubocop:disable NestedMethodDefinition
  def self.override_minitest_run
    Minitest.instance_eval do
      def run(*)
        FIxMinitest.run_mininitest
      end
    end if defined?(Minitest)
  end
  
# rubocop:disable NestedMethodDefinition
  def self.run_mininitest
    case $ERROR_INFO
      when SystemExit
        $ERROR_INFO.status
      else
        true
    end
  end
  # rubocop:disable NestedMethodDefinition
  def self.override_minitest_unit_run
    Minitest::Unit.class_eval do
      def run(*)
      end
    end if defined?(Minitest) && defined?(Minitest::Unit)
  end

  def self.disable_auto_runner
    Test::Unit::Runner.module_eval('@@stop_auto_run = true') if defined?(Test::Unit::Runner)
  end
end
