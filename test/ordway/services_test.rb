require "test_helper"

class Ordway::ServicesTest < Minitest::Test

  UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  def test_that_it_has_a_version_number
    refute_nil ::Ordway::Services::VERSION
  end

  def test_if_processor_instance_methods_defined
    instance_methods = ::Ordway::Services::Processor.instance_methods
    assert [:call, :process, :result].all? { |e| instance_methods.include?(e) }
  end

  def test_should_throw_error_when_process_method_invoked_in_processor_class
    assert_raises NotImplementedError do
      ::Ordway::Services::Processor.call({}, :WEB)
    end
  end

  def test_should_initialize_processor_class_with_provided_content
    processor = ::Ordway::Services::Processor.new({ test_params: "Test Params" }, :WEB, { test_options: "Test Options" })
    assert_equal processor.params, { test_params: "Test Params" }
    assert_equal processor.options, { test_options: "Test Options" }
    assert_equal processor.source, :WEB
  end

  def test_should_initialize_post_processor_class_with_provided_content
    processor = ::Ordway::Services::Processor.new({ test_params: "Test Params" }, :WEB, { test_options: "Test Options" })
    post_processor = Ordway::Services::PostProcessor.new(processor, "payments" , "reverse", Ordway::Services::Result.new(SecureRandom.uuid))
    assert_equal post_processor.caller_object, processor
    assert_equal post_processor.entity, "payments"
    assert_equal post_processor.operation, "reverse"
  end

end
