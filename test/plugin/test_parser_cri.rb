require "test-unit"
require "fluent/test"
require "fluent/test/helpers"
require "fluent/test/driver/parser"
require "fluent/plugin/parser_cri.rb"

class CriParserTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf)
    c = Fluent::Config.parse(conf, "(test)", "(test_dir)", true)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::CriParser).configure(c)
  end

  def test_parse
    d = create_driver('')
    log = '2020-10-10T00:10:00.333333333Z stdout F Hello Fluentd'
    d.instance.parse(log) do |time, record|
      t = event_time('2020-10-10T00:10:00.333333333Z', format: '%Y-%m-%dT%H:%M:%S.%L%z')
      r = {'stream' => 'stdout', 'logtag' => 'F', 'message' => 'Hello Fluentd', 'time' => '2020-10-10T00:10:00.333333333Z'}
      assert_equal t, time
      assert_equal r, record
    end
  end

  def test_parse_without_keep_time_key
    conf = %[keep_time_key false]
    d = create_driver(conf)
    log = '2020-10-10T00:10:00.333333333Z stdout F Hello Fluentd'
    d.instance.parse(log) do |time, record|
      t = event_time('2020-10-10T00:10:00.333333333Z', format: '%Y-%m-%dT%H:%M:%S.%L%z')
      r = {'stream' => 'stdout', 'logtag' => 'F', 'message' => 'Hello Fluentd'}
      assert_equal t, time
      assert_equal r, record
    end
  end

  def test_parse_with_json
    conf = %[
      <parse>
        @type json
        time_key time
        time_format %Y-%m-%dT%H:%M:%S.%L%z
      </parse>
    ]
    d = create_driver(conf)
    log = '2020-10-10T00:10:00.333333333Z stdout F {"foo":"bar","num":100,"time":"2020-11-11T00:11:00.111111111Z"}'
    d.instance.parse(log) do |time, record|
      t = event_time('2020-11-11T00:11:00.111111111Z', format: '%Y-%m-%dT%H:%M:%S.%L%z')
      r = {"foo" => "bar", "num" => 100, 'stream' => 'stdout', 'logtag' => 'F'}
      assert_equal t, time
      assert_equal r, record
    end
  end

  def test_parse_with_json_without_merge_cri_fields
    conf = %[
      merge_cri_fields false
      <parse>
        @type json
        time_key time
        time_format %Y-%m-%dT%H:%M:%S.%L%z
      </parse>
    ]
    d = create_driver(conf)
    log = '2020-10-10T00:10:00.333333333Z stdout F {"foo":"bar","num":100,"time":"2020-11-11T00:11:00.111111111Z"}'
    d.instance.parse(log) do |time, record|
      t = event_time('2020-11-11T00:11:00.111111111Z', format: '%Y-%m-%dT%H:%M:%S.%L%z')
      r = {"foo" => "bar", "num" => 100}
      assert_equal t, time
      assert_equal r, record
    end
  end
end
