module Jekyll
  module Tags
    class HighlightBlock
      def render_rouge(code)
        require "rouge"
        formatter = Rouge::Formatters::HTML.new
        formatter = line_highlighter_formatter(formatter) if @highlight_options[:mark_lines]
        formatter = table_formatter(formatter) if @highlight_options[:linenos]
        lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
        formatter.format(lexer.lex(code))
      end

      def line_highlighter_formatter(formatter)
        Rouge::Formatters::HTMLLineHighlighter.new(
          formatter,
          :highlight_lines => mark_lines
        )
      end

      def mark_lines
        value = @highlight_options[:mark_lines]
        return value.map(&:to_i) if value.is_a?(Array)
        raise SyntaxError, "Syntax Error for mark_lines declaration. Expected a double-quoted list of integers."
      end

      def table_formatter(formatter)
        Rouge::Formatters::HTMLTable.new(
          formatter,
          :css_class    => "highlight",
          :gutter_class => "gutter",
          :code_class   => "code"
        )
      end
    end
  end
end

Jekyll::Hooks.register :documents, :pre_render do |document, payload|
  docExt = document.extname.tr('.', '')

  document.content.gsub!(/^{([\d\s]+)}\s*^\`\`\`([A-z0-9]+)$(.*?)^\`\`\`$/im, '{% highlight \2 mark_lines="\1" %}\3{% endhighlight %}')
end
