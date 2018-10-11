module Test
  module DatabaseHelpers
    module_function

    def rom
      Sepass::Container["persistence.rom"]
    end

    def db
      Sepass::Container["persistence.db"]
    end
  end
end
