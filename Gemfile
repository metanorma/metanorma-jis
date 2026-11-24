source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec


gem "metanorma-standoc", "~> 3.5.7" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.3"
gem "isodoc", "~> 3.7.9"
# The render engine ships inside the consolidated relaton gem (the
# standalone relaton-render repo is archived; its released 3.0 gem is
# frozen on the pre-reconciliation JIS forms), whose bundled styles
# carry the JIS-approved instances (metanorma-jis#551).
gem "relaton", github: "relaton/relaton", branch: "main"
gem "pubid", "~> 2.0"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "main" # TEMPORARY audit chain
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "metanorma-utils", "~> 2.0" # GcBudget + table cell buffer
gem "metanorma-core", "~> 0.2.7" # published flavor/taste table (metanorma-core#18)
gem "mn-requirements", github: "metanorma/mn-requirements", branch: "main" # TEMPORARY until its next release drops relaton-render: the frozen 3.0 gem carries the pre-reconciliation JIS styles and would shadow the relaton gem's engine (metanorma-jis#551)
gem "lutaml-model", "~> 0.8"  # tracking; relaton floors ~> 0.8.113
