# encoding: utf-8

module NanocSite

  class ReleaseNotesDataSource < Nanoc::DataSource

    identifier :release_notes

    def items
      # content
      path = Bundler.rubygems.find_name('nanoc').first.full_gem_path
      raw_content = File.read(File.join(path, 'NEWS.md'))
      content = raw_content.sub(/^#.*$/, '') # remove h1

      # attributes
      attributes = {
        title: 'Release Notes',
        markdown: 'basic',
        extension: 'md',
      }

      # identifier
      identifier = Nanoc::Identifier.new('/release-notes', style: :full)

      item = new_item(content, attributes, identifier)

      [ item ]
    end

  end

end
