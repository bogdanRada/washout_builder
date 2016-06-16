helper_files = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'app','helpers', '**', '*.rb')
Dir.glob(helper_files).each {|file| require file }
module WashoutBuilder
  # the module that is used for soap actions to parse their definition and hold the infoirmation about
  # their arguments and return types
  module SOAP

    module DocHandler

      def setup_controller(base)
        base.send :helper,  WashoutBuilderComplexTypeHelper
        base.send :helper,  WashoutBuilderFaultTypeHelper
        base.send :helper,WashoutBuilderMethodArgumentsHelper
        base.send :helper, WashoutBuilderMethodListHelper
        base.send :helper, WashoutBuilderMethodReturnTypeHelper
      end

      def _generate_doc
        setup_controller("#{params[:controller]}_controller".camelize.constantize)
        @document = WashoutBuilder::Document::Generator.new(controller_path)
        render template: 'wash_with_html/doc', layout: false,
        content_type: 'text/html'
      end

    end
  end
end
