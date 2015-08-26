class Api::RumbasController < Api::Core
  soap_service namespace: 'urn:WashOut'

  # Simple case
  soap_action "integer_to_string",
              :args   => :integer,
              :return => :string
  def integer_to_string
    render :soap => params[:value].to_s
  end

  soap_action "concat",
              :args   => { :a => :string, :b => :string },
              :return => :string
  def concat
    render :soap => (params[:a] + params[:b])
  end

  # Complex structures
  soap_action "AddCircle",
              :args   => { :circle => { :center => { :x => :integer,
                                                     :y => :integer },
                                        :radius => :double } },
              :return => nil, # [] for wash_out below 0.3.0
              :to     => :add_circle
  def add_circle
    circle = params[:circle]

    raise SOAPError, "radius is too small" if circle[:radius] < 3.0

    Circle.new(circle[:center][:x], circle[:center][:y], circle[:radius])

    render :soap => nil
  end

  # Arrays
  soap_action "integers_to_boolean",
              :args => { :data => [:integer] },
              :return => [:boolean]
  def integers_to_boolean
    render :soap => params[:data].map{|x| x ? 1 : 0}
  end

  # Params from XML attributes;
  # e.g. for a request to the 'AddCircle' action:
  #   <soapenv:Envelope>
  #     <soapenv:Body>
  #       <AddCircle>
  #         <Circle radius="5.0">
  #           <Center x="10" y="12" />
  #         </Circle>
  #       </AddCircle>
  #     </soapenv:Body>
  #   </soapenv:Envelope>
  soap_action "AddCircle",
              :args   => { :circle => { :center => { :@x => :integer,
                                                     :@y => :integer },
                                        :@radius => :double } },
              :return => nil, # [] for wash_out below 0.3.0
              :to     => :add_circle
  def add_circle
    circle = params[:circle]
    Circle.new(circle[:center][:x], circle[:center][:y], circle[:radius])

    render :soap => nil
  end

  # With a customised input tag name, in case params are wrapped;
  # e.g. for a request to the 'IntegersToBoolean' action:
  #   <soapenv:Envelope>
  #     <soapenv:Body>
  #       <MyRequest>  <!-- not <IntegersToBoolean> -->
  #         <Data>...</Data>
  #       </MyRequest>
  #     </soapenv:Body>
  #   </soapenv:Envelope>
  soap_action "integers_to_boolean",
              :args => { :my_request => { :data => [:integer] } },
              :as => 'MyRequest',
              :return => [:boolean]


end
