# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      # Walks the typed model tree and dispatches each node to the
      # appropriate renderer via Renderers::Registry. Pure tree
      # traversal — no rendering logic here.
      class Walker
        attr_reader :registry

        def initialize(doc:, resolver:)
          @registry = Renderers::Registry.new(doc: doc, resolver: resolver)
        end

        def walk(node)
          return unless node
          if section?(node)
            walk_section(node)
          elsif block?(node)
            walk_block(node)
          end
        end

        def walk_section(section)
          registry.render(section)
        end

        def walk_block(block)
          registry.render(block)
        end

        private

        def section?(node)
          node.class.name =~ /Section|Sections/
        end

        def block?(node)
          node.class.name =~ /Block|List|Table|Paragraph|Figure/
        end
      end
    end
  end
end
