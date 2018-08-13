require "metanorma/processor"

module Metanorma
  module Acme
    class Processor < Metanorma::Processor

      def initialize
        @short = :acme
        @input_format = :asciidoc
        @asciidoctor_backend = :acme
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::Acme #{Metanorma::Acme::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def extract_options(file)
        head = file.sub(/\n\n.*$/m, "\n")
        /\n:htmlstylesheet: (?<htmlstylesheet>[^\n]+)\n/ =~ head
        /\n:htmlcoverpage: (?<htmlcoverpage>[^\n]+)\n/ =~ head
        /\n:htmlintropage: (?<htmlintropage>[^\n]+)\n/ =~ head
        /\n:scripts: (?<scripts>[^\n]+)\n/ =~ head
        /\n:wordstylesheet: (?<wordstylesheet>[^\n]+)\n/ =~ head
        /\n:standardstylesheet: (?<standardstylesheet>[^\n]+)\n/ =~ head
        /\n:header: (?<header>[^\n]+)\n/ =~ head
        /\n:wordcoverpage: (?<wordcoverpage>[^\n]+)\n/ =~ head
        /\n:wordintropage: (?<wordintropage>[^\n]+)\n/ =~ head
        /\n:ulstyle: (?<ulstyle>[^\n]+)\n/ =~ head
        /\n:olstyle: (?<olstyle>[^\n]+)\n/ =~ head
        new_options = {
          htmlstylesheet: defined?(htmlstylesheet) ? htmlstylesheet : nil,
          htmlcoverpage: defined?(htmlcoverpage) ? htmlcoverpage : nil,
          htmlintropage: defined?(htmlintropage) ? htmlintropage : nil,
          scripts: defined?(scripts) ? scripts : nil,
          wordstylesheet: defined?(wordstylesheet) ? wordstylesheet : nil,
          standardstylesheet: defined?(standardstylesheet) ? standardstylesheet : nil,
          header: defined?(header) ? header : nil,
          wordcoverpage: defined?(wordcoverpage) ? wordcoverpage : nil,
          wordintropage: defined?(wordintropage) ? wordintropage : nil,
          ulstyle: defined?(ulstyle) ? ulstyle : nil,
          olstyle: defined?(olstyle) ? olstyle : nil,
        }.reject { |_, val| val.nil? }
        super.merge(new_options)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Acme::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Acme::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Acme::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
