---
title:      "Configuration"
is_dynamic: true
---

## `text_extensions`

<!-- TODO move this piece of documentation into the data source config -->

A list of file extensions that nanoc will consider to be textual rather than
binary. If an item with an extension not in this list is found,  the file
will be considered as binary.

	#!yaml
	text_extensions: <%= array_to_yaml(Nanoc::SiteLoader::DEFAULT_DATA_SOURCE_CONFIG[:text_extensions]) %>

## `output_dir`

The path to the directory where all generated files will be written to. This
can be an absolute path starting with a slash, but it can also be path
relative to the site directory.

	#!yaml
	output_dir: <%= Nanoc::SiteLoader::DEFAULT_CONFIG[:output_dir] %>

## `index_filenames`

A list of index filenames, i.e. names of files that will be served by a web
server when a directory is requested. Usually, index files are named
“index.html”, but depending on the web server, this may be something else,
such as “default.htm”. This list is used by nanoc to generate pretty URLs.

	#!yaml
	index_filenames: <%= array_to_yaml(Nanoc::SiteLoader::DEFAULT_CONFIG[:index_filenames]) %>

## `enable_output_diff`

Whether or not to generate a diff of the compiled content when compiling a
site. The diff will contain the differences between the compiled content
before and after the last site compilation.

	#!yaml
	enable_output_diff: false

## `prune`

The `prune` section contains options for the [prune](/docs/reference/commands/#prune) command, which deletes stray files from the output directory.

### `auto_prune`

Whether to automatically remove files not managed by nanoc from the output
directory. For safety reasons, this is turned off by default.

	#!yaml
	prune:
	  auto_prune: false

CAUTION: Enabling <code>auto_prune</code> will cause nanoc to remove all files and directories from the output directory that do not correspond to nanoc items. Make sure that the output directory does not contain anything that you still need.

### `exclude`

Which files and directories you want to exclude from pruning. If you version
your output directory, you should probably exclude VCS directories such as
.git, .svn etc.

	#!yaml
	prune:
	  exclude: [ '.git', '.hg', '.svn', 'CVS' ]

## `data_sources`

The data sources contains the definition of the data sources of this site. It is a list of hashes with keys described in the sections below; each array element represents a single data source. For example:

	#!yaml
	data_sources:
	  -
	    type: pentabarf # a custom data source
	    items_root: /conference/

By default, there is only a single data source that reads data from the “content/” and “layout/” directories in the site directory.

### `type`

The type is the identifier of the data source. By default, this will be
`filesystem_unified`.

	#!yaml
	type: <%= Nanoc::SiteLoader::DEFAULT_DATA_SOURCE_CONFIG[:type].inspect %>

### `items_root`

The path where items should be mounted (comparable to mount points in
Unix-like systems). This is “/” by default, meaning that items will have
“/” prefixed to their identifiers. If the items root were “/en/”
instead, an item at content/about.html would have an identifier of
“/en/about/” instead of just “/about/”.

	#!yaml
	items_root: <%= Nanoc::SiteLoader::DEFAULT_DATA_SOURCE_CONFIG[:items_root].inspect %>

### `layouts_root`

The path where layouts should be mounted. The layouts root behaves the
same as the items root, but applies to layouts rather than items.

	#!yaml
	layouts_root: <%= Nanoc::SiteLoader::DEFAULT_DATA_SOURCE_CONFIG[:layouts_root].inspect %>

### `allow_periods_in_identifiers`

Whether to allow periods in identifiers. When turned off, everything
past the first period is considered to be the extension, and when
turned on, only the characters past the last period are considered to
be the extension. For example,  a file named “content/about.html.erb”
will have the identifier “/about/” when turned off, but when turned on
it will become “/about.html/” instead.

	#!yaml
	allow_periods_in_identifiers: false
