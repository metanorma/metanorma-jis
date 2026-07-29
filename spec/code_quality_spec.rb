require "spec_helper"

RSpec.describe "code quality", :code_quality do
  LIB_DIR = File.expand_path("../lib", __dir__)

  def lib_ruby_files
    Dir.glob(File.join(LIB_DIR, "**", "*.rb")).sort
  end

  ENTRY_POINT = File.join(LIB_DIR, "metanorma-jis.rb").freeze

  def lib_ruby_files_excluding_entry_point
    lib_ruby_files - [ENTRY_POINT]
  end

  def spec_ruby_files
    Dir.glob(File.expand_path("../spec", __dir__) + "/**/*.rb").sort -
      [File.expand_path(__FILE__)]
  end

  def file_contains?(path, pattern)
    File.read(path, encoding: "UTF-8").match?(pattern)
  end

  def offending_files(files, pattern)
    files.select { |f| file_contains?(f, pattern) }
  end

  describe "no require_relative in lib/" do
    it "uses autoload exclusively for internal loading" do
      offenders = offending_files(lib_ruby_files, /require_relative/)
      expect(offenders).to be_empty,
        "Files using require_relative (use autoload instead): #{offenders.join(', ')}"
    end
  end

  describe "no internal require paths in lib/" do
    it "does not require 'metanorma/jis/...' or 'isodoc/jis/...' from within the gem (except the entry point)" do
      offenders = lib_ruby_files_excluding_entry_point.select do |f|
        content = File.read(f, encoding: "UTF-8")
        content.match?(/^require\s+["'](metanorma\/jis|isodoc\/jis|relaton\/render-jis)/)
      end
      expect(offenders).to be_empty,
        "Files using internal require paths (use autoload instead): #{offenders.join(', ')}"
    end
  end

  describe "no instance_variable_set / instance_variable_get in lib/" do
    it "respects encapsulation" do
      offenders = offending_files(lib_ruby_files, /instance_variable_(set|get)/)
      expect(offenders).to be_empty,
        "Files using instance_variable_set/get: #{offenders.join(', ')}"
    end
  end

  describe "no respond_to? type checks in lib/" do
    it "uses is_a? or relies on the type hierarchy" do
      offenders = offending_files(lib_ruby_files, /respond_to\?/)
      expect(offenders).to be_empty,
        "Files using respond_to? for type checks: #{offenders.join(', ')}"
    end
  end

  describe "no double() in specs" do
    it "uses real instances or Struct" do
      offenders = offending_files(spec_ruby_files, /\bdouble\(/)
      expect(offenders).to be_empty,
        "Spec files using double(): #{offenders.join(', ')}"
    end
  end

  describe "no hand-rolled to_h / from_h / to_json / from_json on model classes" do
    it "uses lutaml-model for serialization" do
      offenders = lib_ruby_files.select do |f|
        content = File.read(f, encoding: "UTF-8")
        content.match?(/^\s*def\s+(to_h|to_hash|from_h|from_hash|to_json|from_json)\b/)
      end
      expect(offenders).to be_empty,
        "Files defining hand-rolled serialization: #{offenders.join(', ')}"
    end
  end
end
