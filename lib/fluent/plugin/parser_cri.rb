#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/plugin/parser'

module Fluent
  module Plugin
    class CriParser < Parser
      Plugin.register_parser("cri", self)

      desc 'Merge stream/logtag fields into parsed result'
      config_param :merge_cri_fields, :bool, default: true

      config_set_default :time_key, 'time'.freeze
      config_set_default :time_format, '%Y-%m-%dT%H:%M:%S.%L%z'.freeze
      config_set_default :keep_time_key, true

      def configure(conf)
        super

        @sub_parser = nil
        if parser_config = conf.elements('parse').first
          type = parser_config['@type']
          @sub_parser = Fluent::Plugin.new_parser(type, parent: self.owner)
          @sub_parser.configure(parser_config)
        end
      end

      def parse(text)
        elems = text.split(" ".freeze, 4)
        return yield nil if elems.size != 4

        if @sub_parser
          time = record = nil
          @sub_parser.parse(elems[3]) { |t, r|
            time = t
            record = r
          }
          if @merge_cri_fields
            record['stream'] = elems[1]
            record['logtag'] = elems[2]
          end
        else
          record = {
            "stream" => elems[1],
            "logtag" => elems[2],
            "message" => elems[3]
          }
          t = elems[0]
          time = @time_parser.parse(t)
          if @keep_time_key
            record[@time_key] = t
          end
        end

        yield time, record
      end
    end
  end
end
