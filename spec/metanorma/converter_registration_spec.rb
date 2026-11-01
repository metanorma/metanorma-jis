# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Asciidoctor converter registration" do
  LIB_DIR = File.expand_path("../lib", __dir__)

  # Asciidoctor resolves the converter for the `backend: :jis` document
  # attribute through the global registry built by `register_for` at
  # class-body load. This process cannot probe that load-time behavior:
  # spec_helper itself instantiates Metanorma::Jis::Converter, which
  # fires the autoload and registers the converter regardless. A fresh
  # process loading the gem entry alone is the honest probe — bare
  # FlavorLoader paths (`metanorma site generate`) compile JIS documents
  # through exactly such a load, and crashed with "missing converter for
  # backend 'jis'" when registration did not happen at load time.
  it "registers the jis backend when the gem entry loads alone" do
    code = <<~RUBY
      $LOAD_PATH.unshift(#{LIB_DIR.inspect})
      require "metanorma-jis"
      exit(Asciidoctor::Converter.for("jis") ? 0 : 1)
    RUBY
    expect(system(RbConfig.ruby, "-e", code)).to be(true)
  end
end
