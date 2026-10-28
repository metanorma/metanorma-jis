source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec


gem "metanorma-standoc", "~> 3.5.1.pre.alpha" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.2.pre.alpha"
gem "isodoc", "~> 3.7.4.pre.alpha"
gem "relaton-render", "~> 3.0" # slot forms; bare from-only dates; item-language routing
gem "pubid", "~> 2.0"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "main" # TEMPORARY audit chain
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "metanorma-utils", "~> 2.0" # GcBudget + table cell buffer
gem "metanorma-core", "~> 0.2.5.pre.alpha" # published flavor/taste table (metanorma-core#18)
gem "lutaml-model", "~> 0.8"  # tracking; relaton floors ~> 0.8.113
