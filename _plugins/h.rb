module Jekyll
    module Tags
      class HighlightBlock
        def render_rouge(code)
          require "rouge"
          formatter = Rouge::Formatters::HTML.new
          formatter = line_highlighter_formatter(formatter, @highlight_options[:mark_lines]) if @highlight_options[:mark_lines]?is_a?(Array)
          formatter = table_formatter(formatter) if @highlight_options[:linenos]
          lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
          formatter.format(lexer.lex(code))
        end
  
        def line_highlighter_formatter(formatter, value)
          Rouge::Formatters::HTMLLineHighlighter.new(
            formatter,
            :highlight_lines => value.map(&:to_i),
            :highlight_line_class => "hll"
          )
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