module Infusionsoft
  module Connection

    def get(service_call, *args)
      client = XMLRPC::Client.new3(
        host: Infusionsoft.api_url,
        path: "/api/xmlrpc",
        port: 443,
        use_ssl: true
      )

      client.http_header_extra = {'User-Agent' => Infusionsoft.user_agent}

      Retriable.retriable on: Timeout::Error, tries: 3, interval: 1 do
        Infusionsoft.log.info "CALL: #{ service_call } api_key:#{ Infusionsoft.api_key } at:#{ Time.now } args:#{ args.inspect } \n"

        begin
          resp = client.call("#{ service_call }", Infusionsoft.api_key, *args)

          if resp.nil?
            Infusionsoft.log.warn "WARNING: [#{ e }] retrying"
            raise Timeout::Error.new
          end

          Infusionsoft.log.info "RESULT: #{ resp.inspect }"
          resp

        rescue XMLRPC::FaultException => xmlrpc_error
          # Catch all XMLRPC exceptions and rethrow specific exceptions for each type of xmlrpc fault code
          Infusionsoft::ExceptionHandler.new(xmlrpc_error)
        end
      end

    end
  end
end

# Uncomment to view RAW XML
#
# class XMLRPC::Client
#    def call(method, *args)
#      request = create().methodCall(method, *args)
#      puts request
#      data = do_rpc(request, false)
#      parser().parseMethodResponse(data)
#    end
# end