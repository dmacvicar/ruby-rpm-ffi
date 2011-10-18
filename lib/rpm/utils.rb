module RPM

	module Utils

		def self.check_type(var, type)
			raise(TypeError, "wrong argument type #{vas.class} (expected #{type.class})") unless var.is_a?(type)
		end

	end
end