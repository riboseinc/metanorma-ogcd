module Asciidoctor
  module Ogc
    class Converter < Standoc::Converter
      def title_validate(root)
        nil
      end

      def content_validate(doc)
        super
        bibdata_validate(doc.root)
      end

      def bibdata_validate(doc)
        stage_validate(doc)
        version_validate(doc)
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(swg-draft oab-review public-rfc tc-vote
        approved deprecated retired).include? stage or
        @log.add("Document Attributes", nil, "#{stage} is not a recognised status")
      end

      def version_validate(xmldoc)
        version = xmldoc&.at("//bibdata/edition")&.text
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        if %w(engineering-report discussion-paper).include? doctype
          version.nil? or
          @log.add("Document Attributes", nil, "Version not permitted for #{doctype}") 
        else
          version.nil? and
          @log.add("Document Attributes", nil,  "Version required for #{doctype}") 
        end
      end

      def section_validate(doc)
        preface_sequence_validate(doc.root)
        sections_sequence_validate(doc.root)
        super
      end

      STANDARDTYPE = %w{standard standard-with-suite abstract-specification
      community-standard profile}.freeze

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ =
        [
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::clause[@type = 'scope']" ]
          },
          {
            msg: "Scope must be followed by Conformance",
            val: ["./self::clause[@type = 'conformance']" ]
          },
          {
            msg: "Normative References must be followed by "\
            "Terms and Definitions",
            val: ["./self::terms | .//terms"]
          },
      ].freeze

      def seqcheck(names, msg, accepted)
        n = names.shift
        return [] if n.nil?
        test = accepted.map { |a| n.at(a) }
        if test.all? { |a| a.nil? }
          @log.add("Style", nil, msg)
        end
        names
      end

      def sections_sequence_validate(root)
        return unless STANDARDTYPE.include?(
          root&.at("//bibdata/ext/doctype")&.text)
        names = root.xpath("//sections/* | //bibliography/*")
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val])
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val])
        names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val])
        n = names.shift
        if n&.at("./self::definitions")
          n = names.shift
        end
        if n.nil? || n.name != "clause"
          @log.add("Style", nil, "Document must contain at least one clause")
          return
        end
        root.at("//references | //clause[descendant::references]"\
                "[not(parent::clause)]") or
        @log.add("Style", nil, "Normative References are mandatory")
      end

      def preface_sequence_validate(root)
        root.at("//preface/abstract") or @log.add("Style", nil, "Abstract is missing!")
        root.at("//bibdata/keyword | //bibdata/ext/keyword") or
          @log.add("Style", nil, "Keywords are missing!")
        root.at("//foreword") or @log.add("Style", nil,  "Preface is missing!")
        root.at("//bibdata/contributor[role/@type = 'author']/organization/"\
                "name") or
               @log.add("Style", nil, "Submitting Organizations is missing!")
        root.at("//submitters") or @log.add("Style", nil, "Submitters is missing!")
      end
    end
  end
end

