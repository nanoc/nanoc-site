---
title: "nanoc 4.0 upgrade guide"
for_nanoc_4: true
---

This document lists all backwards-incompatible changes made to nanoc 4.0, and contains advice on how to migrate from nanoc 3.x to nanoc 4.0.

NOTE: The content of this document is volatile, as nanoc 4.0 is still a work in progress. Nothing described in this document is final. This document is also not guaranteed to be complete yet. If you believe something is missing, please do <a href="https://github.com/nanoc/nanoc.ws/issues/new">open a nanoc.ws issue</a>.

## Identifiers with extensions

In nanoc 4, identifiers include the extension and do not end with a slash. For example, the filename <span class="filename">content/robots.txt</span> maps to the identifier `/robots.txt`, and the filename <span class="filename">content/projects/nanoc.md</span> maps to the identifier `/projects/nanoc.md`.

The <span class="filename">index</span> portion of a filename is no longer stripped in nanoc 4. For example, the filename <span class="filename">content/about/index.html</span> maps to the identifier `/about/index.html`.

Identifiers in nanoc 4 are a first-class concept. Several methods for manipulating an identifier are available. Assuming that `sample` equals an identifier `/projects/nanoc.md`:

`extension`
: Returns the extension. For example, `sample.extension` returns `md`.

`with_ext(s)`
: Returns a new identifier with the extension replaced by `s`. For example, `sample.with_ext('html')` returns `/projects/nanoc.html`.

`without_ext`
: Returns a new identifier with the extension removed. For example, `sample.without_ext` returns `/projects/nanoc`.

`in_dir(dirname)`
: Returns a new identifier with the extension removed, an `index` component added, followed by the original extension. For example, `sample.in_dir` returns `/projects/nanoc/index.md`.

Please consult the [`Nanoc::Identifier` API documentation](/docs/api/core/Nanoc/Identifier.html) for other useful methods.

These methods can be chained together. For example, to recreate nanoc’s default behavior of routing items into their own directory and with the <span class="filename">html</span> extension, you could use `sample.in_dir.with_ext('html')`, which would return `/projects/nanoc/index.html`.

## New string pattern syntax

String patterns in nanoc 4 are globs, and behave like Unix-like shell globs. The behavior of the `*` character has changed, and the `+` character no longer has a special meaning. nanoc 4 uses Ruby’s [`File.fnmatch` method](http://ruby-doc.org/core/File.html#method-c-fnmatch) with the `File::FNM_PATHNAME` option enabled. The three most useful wildcards are the following:

`*`
: Matches any file or directory name. Does not cross directory boundaries. For example, `/projects/*.md` matches `/projects/nanoc.md`, but not `/projects/cri.adoc` nor `/projects/nanoc/about.md`.

`**`
: Matches any file or directory name, and crosses directory boundaries. For example, `/projects/**/*.md` matches both `/projects/nanoc.md` and `/projects/nanoc/history.md`.

`[abc]`
: Matches any single character in the set. For example, `/people/[kt]im.md` matches only `/people/kim.md` and `/people/tim.md`.

Please consult the [`File.fnmatch`](http://ruby-doc.org/core/File.html#method-c-fnmatch) documentation for other supported patterns, and more comprehensive documentation.

NOTE: Extended globs are only available in Ruby 2.0 and up, and are not enabled in nanoc 4. Extended globs allow patterns like <code>/c{at,ub}s.txt</code>, which match either <code>/cats.txt</code> or <code>/cubs.txt</code>.

Patterns based on regular expressions are still supported in nanoc 4, so you can still use e.g. `%r{\A/projects/(cri|nanoc)\.md\Z}` to match both `/projects/nanoc.md` and `/projects/cri.md`.

## Compact rules

In nanoc 3.x, defining how an item is processed happens using both <span class="firstterm">compilation rule</span> and a <span class="firstterm">routing rule</span>.

In nanoc 4.0, routing rules have been merged into compilation rules. Additionally, convenience methods such as `#passthrough` and `#ignore` have been removed.

In nanoc 3.x, a <span class="filename">Rules</span> file could looks like this:

	#!ruby

	layout '/default/'

	compile '/' do
	  filter :erb
	end

	route '/' do
	  '/index.html'
	end

	compile '*' do
	  filter :kramdown
	  layout 'default'
	end

	route '*' do
	  item.identifier + 'index.html'
	end

In nanoc 4.0, that same <span class="filename">Rules</span> file looks like this:

	#!ruby

	layout '/default.*'

	compile '/index.*' do
	  filter :erb
	  write '/index.html'
	end

	compile '/**/*' do
	  filter :kramdown
	  layout '/default.*'
	  write item.identifier.in_dir.with_ext('html')
	end

The compilation rule now includes a `#write` call, with an argument containing the path to the file to write to.

Also note that the pattern has changed: instead of using `'*'` as a pattern, the `'/**/*'` pattern is used, which indicates that files are being matched recursively.

## Extracted plugins

nanoc 4 is split up in several distinct repositories, each with their matching Ruby gem. The split was performed so that release cycles of individual parts are decoupled; for instance, a new version of the Sass plugin can be released without affecting the release schedule of the core.

The main repositories are

`nanoc-core`
: Contains the core code, without any filters, helpers or data sources

`nanoc-cli`
: Contains the command-line interface

NOTE: At the time of writing, `nanoc-core` still contains the `erb` filter and the `filesystem` data source. These might be extracted at a later date.

Each non-core feature has been extracted into its own plugin. The name of the plugin is the name of the repository and is the name of the gem. Three kinds of plugins exist:

* Filters, such as [<span class="productname">nanoc-kramdown</span>](https://github.com/nanoc/nanoc-kramdown), [<span class="productname">nanoc-xslt</span>](https://github.com/nanoc/nanoc-xslt), and [<span class="productname">nanoc-sass</span>](https://github.com/nanoc/nanoc-sass)

* Helpers, such as [<span class="productname">nanoc-tagging</span>](https://github.com/nanoc/nanoc-tagging), [<span class="productname">nanoc-linking</span>](https://github.com/nanoc/nanoc-linking), and [<span class="productname">nanoc-filtering</span>](https://github.com/nanoc/nanoc-filtering)

* Other tools, such as [<span class="productname">nanoc-checking</span>](https://github.com/nanoc/nanoc-checking) and [<span class="productname">nanoc-deploying</span>](https://github.com/nanoc/nanoc-deploying)

All plugins can be found in the [nanoc organisation on GitHub](https://github.com/nanoc).

NOTE: A list of plugins along with the kind of feature they provide (filter, helper, …) will be available on the site at some point in the future.

To manage a nanoc site’s dependent gems, we recommend using [Bundler](http://bundler.io/). A site’s <span class="filename">Gemfile</span> should include <span class="productname">nanoc-core</span> and <span class="productname">nanoc-cli</span>, as well as any other dependencies. For example, the nanoc 4 version of this site looks like this:

	#!ruby
	source 'https://rubygems.org'

	gem 'nanoc-core'
	gem 'nanoc-cli'

	gem 'nanoc-breadcrumbs'
	gem 'nanoc-capturing'
	gem 'nanoc-checking'
	gem 'nanoc-colorize_syntax'
	gem 'nanoc-deploying'
	gem 'nanoc-escaping'
	gem 'nanoc-filtering'
	gem 'nanoc-kramdown'
	gem 'nanoc-linking'
	gem 'nanoc-rainpress'
	gem 'nanoc-relativize_paths'
	gem 'nanoc-rendering'
	gem 'nanoc-sass'
	gem 'nanoc-xml_sitemap'

There is no need to list additional dependencies, such as `sass`, `builder` or `rainpress`, because these would be dependencies of the nanoc plugins.

Helpers still need to be included somewhere in <span class="filename">lib/</span>. For example, the nanoc 4 version of this site has the following in <span class="filename">lib/helpers_.rb</span>:

	#!ruby
	# encoding: utf-8

	include Nanoc::Breadcrumbs::Helper
	include Nanoc::Filtering::Helper
	include Nanoc::Linking::Helper
	include Nanoc::Rendering::Helper
	include Nanoc::XMLSitemap::Helper

NOTE: Helpers will likely be auto-required before the final nanoc 4.0 release.

## Removed features

* The `create-item` and `create-layout` commands have been removed. These commands were deemed to be not useful. Instead of using these commands, create items manually on the file system.

* nanoc will no longer attempt to load the Gemfile. Execute nanoc using `bundle exec` instead.

* Support for Ruby 1.8.x has been dropped, because Ruby 1.8.x was retired mid 2013.

* The `watch` and `autocompile` commands have been removed. These commands were already deprecated in nanoc 3.6.4. Use [guard-nanoc](https://github.com/guard/guard-nanoc) instead.

* The `filesystem_verbose` data source has been removed. Use the `filesystem` data source instead, as it provides the same functionality.

* The `filesystem` data source no longer accepts a `allow_periods_in_identifiers` option. With the changes to identifiers made in nanoc 4, this no longer serves a purpose.

* The `static` data source has been removed. Its purpose was to work around the nanoc 3.x limitation that identifiers did not include an extension, and that two different items or layouts could therefore not have the same base name. This limitation is no longer present in nanoc 4.

* The Markaby filter has been removed, as it was not compatible with Ruby 1.9.

* The `update` command has been removed. This command was used to manage source data, which should not have been the responsibility of nanoc.

## Minor changed features

* The `filesystem_unified` data source has been renamed to `filesystem`.

* The `output_dir` configuration option has been renamed to `build_dir`, and the default build directory has been changed from `output/` to `build/`. This more clearly communicates the intent of the directory. The `#output_filenames` method in the `Checks` file has been renamed to `#build_filenames`.

* Auto-pruning is now turned on by default. This means that all files in the build directory that do not correspond with a source item will be removed after compilation. If you do not want this behavior, you can opt-out by explicitly setting the `auto_prune` option in the `prune` section of the configration file to `false`.

* nanoc no longer infers the encoding from the environment, but assumes it to be UTF-8 unless explicitly stated otherwise in the data source section fo the configuration file.

## Developer changes

* All API parts that were previously deprecated have been removed.

* VCS integration has been removed. Its original purpose was to aid in managing source content, but this was deemed to be out of scope for nanoc 4.

* The `Nanoc3` namespace has been removed, and no `Nanoc4` namespace exists. Use `Nanoc` instead.

This site also includes the [API for nanoc-core](/docs/api/core/).
