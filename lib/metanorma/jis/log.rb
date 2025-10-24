module Metanorma
  module Jis
    class Converter
      JIS_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "JIS_1": { category: "Document Attributes",
                   error: "%s is not a recognised document type",
                   severity: 2 },
        "JIS_2": { category: "Document Attributes",
                   error: "%s is not a recognised script",
                   severity: 2 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(JIS_LOG_MESSAGES)
      end
    end
  end
end
