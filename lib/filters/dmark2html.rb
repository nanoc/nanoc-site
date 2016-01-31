require 'dmark'

Class.new(Nanoc::Filter) do
  identifier :dmark2html

  class NanocWsHTMLTranslator < DMark::Translator
    def initialize(tree, items)
      super(tree)
      @items = items
    end

    def handle(node)
      case node
      when DMark::Nodes::RootNode
        handle_children(node)
      when DMark::Nodes::TextNode
        out << node.text
      when DMark::Nodes::ElementNode
        tags = tags_for(node)

        output_start_tags(tags)
        handle_children(node)
        output_end_tags(tags)
      end
    end

    def output_start_tags(tags)
      tags.each do |tag|
        out << '<'
        out << tag[:name]
        if tag[:attributes]
          tag[:attributes].each_pair do |key, value|
            # TODO: escape
            # TODO: translate

            out << ' '
            out << key.to_s
            out << '="'
            out << value
            out << '"'
          end
        end
        out << '>'
      end
    end

    def output_end_tags(tags)
      tags.reverse_each do |tag|
        out << "</#{tag[:name]}>"
      end
    end

    def tags_for(node)
      # returns e.g. [{name: 'pre', attributes: {}}]

      attributes = {}
      node_attributes = node.attributes.split(',').map { |piece| piece.split('=') }
      if node_attributes.any? { |a| a[0] == 'id' }
        attributes.merge!(id: node_attributes.find { |a| a[0] == 'id' }.last)
      end

      case node.name
      when 'listing'
        [
          { name: 'pre', attributes: attributes },
          { name: 'code', attributes: attributes },
        ]
      when 'emph'
        [{ name: 'em', attributes: attributes }]
      when 'firstterm', 'identifier', 'glob', 'filename', 'class', 'command', 'prompt', 'productname', 'see'
        [{ name: 'span', attributes: attributes.merge(class: node.name) }]
      when 'p', 'dl', 'dt', 'dd', 'code', 'kbd', 'h1', 'h2', 'h3', 'ul', 'li'
        is_legacy = node_attributes.any? { |a| a[0] == 'legacy' }
        [{ name: node.name, attributes: attributes.merge(is_legacy ? { class: 'legacy' } : {}) }]
      when 'note', 'tip', 'caution'
        [
          { name: 'div', attributes: attributes.merge(class: "admonition-wrapper #{node.name}") },
          { name: 'div', attributes: attributes.merge(class: 'admonition') },
        ]
      when 'ref'
        if node_attributes.any? { |a| a[0] == 'item' }
          pattern = node_attributes.find { |a| a[0] == 'item' }.last
          path = @items[pattern].path
          [{ name: 'a', attributes: attributes.merge(href: path) }]
        elsif node_attributes.any? { |a| a[0] == 'url' }
          url = node_attributes.find { |a| a[0] == 'url' }.last
          [{ name: 'a', attributes: attributes.merge(href: url) }]
        elsif node_attributes.any? { |a| a[0] == 'frag' }
          frag = node_attributes.find { |a| a[0] == 'frag' }.last
          [{ name: 'a', attributes: attributes.merge(href: "##{frag}") }]
        else
          raise "Cannot translate ref #{node.inspect}"
        end
      else
        raise "Cannot translate #{node.name}"
      end
    end
  end

  def run(content, params = {})
    tokens = DMark::Lexer.new(content).run
    tree = DMark::Parser.new(tokens).run
    NanocWsHTMLTranslator.new(tree, @items).run
  end
end
