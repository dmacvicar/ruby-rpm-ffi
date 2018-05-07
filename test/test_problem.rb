require File.join(File.dirname(__FILE__), 'helper')

class RPMHeaderTests < Minitest::Test
  def test_create
    problem = RPM::Problem.create(:requires, 'foo-1.0-0', 'foo.rpm', 'bar-1.0-0', 'Hello', 1)
    assert_equal 'foo.rpm', problem.key
    assert_equal :requires, problem.type
    assert_equal 'Hello', problem.str
    assert_equal 'Hello is needed by (installed) bar-1.0-0', problem.to_s

    # Create a RPM::Problem from an existing pointer
    problem2 = RPM::Problem.new(problem.ptr)
    assert_equal problem.key, problem2.key
    assert_equal problem.type, problem2.type
    assert_equal problem.str, problem2.str
    assert_equal problem.to_s, problem2.to_s
  end
end
