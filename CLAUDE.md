# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`metanorma-jis` is a Ruby gem that lets you author **Japanese Industrial Standards (JIS)** in AsciiDoc and emit XML, HTML, Word (`.doc`), and PDF. It is a thin flavor on top of [`metanorma-iso`](https://github.com/metanorma/metanorma-iso) — the JIS document model is the ISO document model with Japanese-specific rendering tweaks (fonts, layout, boilerplate, doctypes).

- Ruby `>= 3.3.0`; gemspec pins `metanorma-iso ~> 3.4.2`.
- XML root tag: `jis-standard`; XML namespace: `https://www.metanorma.org/ns/jis`.
- Doctypes inherit from ISO plus `japanese-industrial-standard` (default), and JIS-specific document subtypes (TR, TS, 追補/amendment) drive cover-page selection.
- Default language is `ja` (auto-set in `init_i18n` if missing); `jp` is normalized to `ja`.

## Build and Test Commands

```bash
bundle install
bundle exec rspec spec/isodoc/word_spec.rb:42     # one test by line number
bundle exec rspec spec/isodoc/word_spec.rb         # one file
bundle exec rubocop                                # lint
bundle exec rake build                             # build the gem
```

- Follow `metanorma-iso/CLAUDE.md` spec-safety rules: avoid running the full suite (`bundle exec rake`); run **one targeted spec file at a time**. The ISO backend's full suite leaks memory and can kill the shell — JIS inherits that risk via `metanorma-iso ~> 3.4.2`.
- Use `canon diff FILE1 FILE2` for semantic XML diffs; **never** `xmldiff`. Canon is at `/Users/mulgogi/.local/share/mise/installs/ruby/3.4.8/bin/canon` (see `metanorma-iso/CLAUDE.md`).
- **Never use Python.** Ruby only.

## Architecture

### Inheritance from `metanorma-iso`

Every JIS class subclasses its ISO counterpart and overrides only what differs. Read `metanorma-iso/CLAUDE.md` first — most architecture, conventions, and pitfalls are documented there.

```
Metanorma::Standoc::Converter
        └── Metanorma::Iso::Converter           (metanorma-iso)
                └── Metanorma::Jis::Converter    (lib/metanorma/jis/converter.rb)

IsoDoc::XslfoPdfConvert
        └── IsoDoc::Iso::PdfConvert
                └── IsoDoc::Jis::PdfConvert      (lib/isodoc/jis/pdf_convert.rb)

IsoDoc::Iso::WordConvert → IsoDoc::Jis::WordConvert   (lib/isodoc/jis/word_convert.rb)
IsoDoc::Iso::HtmlConvert → IsoDoc::Jis::HtmlConvert
```

### Layer 1 — AsciiDoc → JIS XML (`lib/metanorma/jis/`)

- `converter.rb` — `Metanorma::Jis::Converter < Iso::Converter`, registered as `:jis`. Sets `XML_ROOT_TAG = "jis-standard"`, `XML_NAMESPACE`, default doctype, default language. Routes output via `html_converter`, `doc_converter`, `pdf_converter`, `presentation_xml_converter`.
- `front.rb` — JIS-specific metadata (publisher = "Japanese Industrial Standards", committee contributors, multilingual titles, document identifiers via `pubid`).
- `cleanup.rb` — JIS-specific boilerplate (`boilerplate-ja.adoc`, `boilerplate-en.adoc`) and normative-reference preface wording.
- `validate.rb` — JIS-specific document model validation.
- `*.rng` — RelaxNG schemas (inherited unchanged from ISO unless noted).
- `boilerplate-ja.adoc`, `boilerplate-en.adoc` — Japanese/English boilerplate text injected into documents.

### Layer 2 — JIS XML → rendered output (`lib/isodoc/jis/`)

- `base_convert.rb` — shared rendering mixins used by HTML and Word.
- `html_convert.rb` / `html/*.scss` / `html/*.html` — HTML output and SCSS stylesheets. The HTML templates (`html_jis_titlepage.html`, `html_jis_intro.html`, `word_jis_titlepage.html`, `word_jis_intro.html`) drive both HTML and Word rendering.
- `pdf_convert.rb` + `jis.international-standard.xsl` — PDF via XSL-FO.
- `word_convert.rb` + `word_cleanup.rb` + `word_table.rb` + `word_figure.rb` — **legacy** Word `.doc` (HTML → `Html2Doc::Jis` → MHTML) path. See "DOCX port (in progress)" below.
- `presentation_xml_convert.rb` + `presentation_*.rb` — presentation XML intermediate; `presentation_section.rb`, `presentation_table.rb`, `presentation_list.rb` carry JIS-specific cross-ref / numbering / list rendering.
- `metadata.rb` — JIS document metadata extraction for rendering.
- `i18n.rb` + `i18n-en.yaml` + `i18n-ja.yaml` — labels in English and Japanese.
- `xref.rb` — JIS cross-reference formatting (e.g., "表 X-Y", "図 X-Y", "附属書 X").
- `init.rb` — factories for metadata, xref, i18n, bib renderer.

### Supporting modules

- `lib/html2doc/lists.rb` — `Html2Doc::Jis < ::Html2Doc`; JIS-specific list-to-paragraph flattening (lists are rendered as indented paragraphs with hanging tabs, not as Word list styles).
- `lib/relaton/render-jis/` — JIS bibliographic reference rendering (`config.yml`, `general.rb`, `parse.rb`, `fields.rb`).

### Registration entry points

- `lib/metanorma-jis.rb` — top-level entry: requires the converter, then registers `Metanorma::Jis::Processor` with `Metanorma::Registry` (if a registry is loaded).
- `lib/metanorma/jis/processor.rb` — registers output formats: `html`, `pdf`, `doc`. **No `:docx` format yet** — adding DOCX output is the open task (see below).

## DOCX port (in progress)

The current Word output is **legacy HTML→MHTML** via `Html2Doc::Jis` (produces `.doc`). The goal is to add true DOCX output that mirrors the JIS Word template in `reference-docs/JDT2023/`, using the same **Uniword-based DOCX Adapter** architecture that `metanorma-iso` uses (see `metanorma-iso/lib/isodoc/iso/docx/` and `metanorma-iso/data/iso-dis/`).

### Reference template layout (`reference-docs/JDT2023/`)

The official "JDT2023" template distribution from the Japanese Standards Association. Key contents:

- `JIS_Control.dotm` (1.7 MB) and `JIS_NewStyle.dotm` (423 KB) — Word macro-enabled templates that carry the style library and the VBA automation (style checking, generation hooks). Source for style extraction, NOT for redistribution.
- `ﾚｲｱｳﾄ/` (Layout) — per-section `.dotx` templates, each a separate Word section with its own page setup:
  - `JDT_本文.dotx` (main body), `JDT_本文_MOD.dotx` (modified-adoption body)
  - `JDT_表紙_JIS.dotx`, `JDT_表紙_TR.dotx`, `JDT_表紙_TS.dotx`, `JDT_表紙_追補.dotx` (doctype-specific covers)
  - `JDT_索引.dotx` (index), `JDT_解説.dotx` (commentary / 解説附属書)
  - `JDT_追補_国際規格指示無し_本文.dotx` (amendment without international-standard direction)
- `定型文/` (fixed phrases) — boilerplate snippets per doctype (`JIS_NEW_本文.txt`, `TR_NEW_まえがき.txt`, `追補_NEW_本文.txt`, …) and per title-block (`本文_タイトルブロック.txt`, `目次_タイトルブロック.txt`, `索引_タイトルブロック.txt`, `解説_タイトルブロック.txt`, `附属書_タイトルブロック.txt`, `まえがき_タイトルブロック.txt`). Shift_JIS encoded.
- `ひな形/` (templates) — blank `.docx` files for A3 横, A4 横, A4 縦, plus a 用語 (glossary), 用語索引 (index), 参考文献 (references), and JIS-国際規格対比表 (comparison table).
- `manual/manual.pdf` — operator manual (Japanese).
- `StyleCheck.txt`, `Yougolst.txt`, `Nextstyle.txt`, `unconditional.txt`, `利用不可Style.txt` — style metadata and style-usage rules used by the VBA checker. Shift_JIS encoded.
- `JIStemplate.ini`, `Version.ini`, `option.txt`, `Admini.txt`, `CreateShortCut.vbs`, `JDT2023_Start.Bat`, `JDT2023_Start.VBS`, `JDT2023.ico` — installer / launcher configuration (Windows-only, not relevant to DOCX rendering).
- `使用許諾.txt` — license terms for the JDT2023 distribution.

These files are **reference source material** — never delete (see global rule "NEVER DELETE SOURCE FILES"). Encoding is Shift_JIS; decode with `File.read(path, encoding: "Shift_JIS")` when parsing.

### How `metanorma-iso` does DOCX (the pattern to mirror)

1. `lib/metanorma/iso/processor.rb` registers `:doc` and `:docx`; both routes call `IsoDoc::Iso::Docx::Adapter.new(template: ...).convert(xml_input, outname)`.
2. `lib/isodoc/iso/docx.rb` autoloads the Adapter module from the parent namespace.
3. `lib/isodoc/iso/docx/adapter.rb` — `Adapter` orchestrates renderer objects (cover, boilerplate, sections, TOC, inline, formula, etc.). Renderers are registered in a `Renderers::Registry` keyed by model class (MECE, OCP-friendly).
4. `lib/isodoc/iso/docx_style_mapping.rb` — `DocxTemplates` resolves template + style-mapping paths; `DocxStyleMapping` loads `style_mapping.yml`.
5. `data/iso-dis/` and `data/iso-simple/` — one directory per template variant, each with:
   - `template.docx` (or `.dotx`) — the reference DOCX
   - `styles.yml` — extracted style library
   - `numbering.yml` — extracted numbering definitions
   - `style_mapping.yml` — semantic-key → DOCX styleId mapping
   - `doc_defaults.yml` — default run/paragraph properties
   - `document_metadata.yml` — docProps/custom.xml values

The Adapter reads the semantic presentation XML → builds a `Metanorma::IsoDocument::Root` model → walks it via renderers → writes DOCX through Uniword. The template DOCX is loaded once via `Uniword.load(template_path)` and its body is cleared before each render.

## Key Patterns

- The converter hierarchy is `Standoc → Iso → Jis`; validation and cleanup extend their ISO counterparts via separate modules.
- JIS XML namespace is `https://www.metanorma.org/ns/jis`; root tag `jis-standard`. All XPath queries inside IsoDoc use `ns(...)` to resolve the namespace.
- The `Html2Doc::Jis` helper (`lib/html2doc/lists.rb`) flattens ordered/unordered lists into indented paragraphs with hanging tabs — JIS-style lists are NOT Word list styles. This is legacy and only used by the `.doc` path; the new DOCX path should mirror `metanorma-iso/lib/html2doc/lists.rb` (`Html2Doc::IsoDIS`) or the Uniword list renderers.
- The `presentation_section.rb`, `presentation_table.rb`, `presentation_list.rb` modules carry JIS-specific numbering and cross-reference rules that the DOCX renderers will need to consume from the presentation XML.
- PDF is rendered through XSL-FO (`jis.international-standard.xsl`); DOCX is the only format not yet produced natively.
- `Gemfile.devel` (if present) can point to local checkouts of `metanorma-iso`, `isodoc`, etc. for cross-repo development.
