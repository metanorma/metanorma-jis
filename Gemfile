source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main" # TEMPORARY audit chain (stacked)
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main" # TEMPORARY audit chain
gem "isodoc", github: "metanorma/isodoc", branch: "main" # merged as #825
gem "relaton-render", "~> 3.0.0.pre.alpha" # # slot forms; bare from-only dates; item-language routing, github: "metanorma/relaton-render", branch: "main"
gem "pubid", "~> 2.0.0.pre.alpha"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "main" # TEMPORARY audit chain
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "metanorma-utils", github: "metanorma/metanorma-utils", branch: "main" # GcBudget + table cell buffer, unreleased past 2.0.7 # the audit branch carries the 1.x lib/relaton stack, which cannot boot beside relaton-render 3
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "main" # TEMPORARY audit chain
gem "lutaml-model", "~> 0.8"  # tracking; relaton floors ~> 0.8.113
