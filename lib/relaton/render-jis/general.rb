require "relaton-render"
require "metanorma-iso"
require "isodoc"
require_relative "parse"

module Relaton
  module Render
    module JIS
      class General < ::Relaton::Render::Iso::General
        #def config_loc
        #  YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        #end

        def klass_initialize(_options)
          super
          @parseklass = Relaton::Render::JIS::Parse
        end
      end
    end
  end
end
