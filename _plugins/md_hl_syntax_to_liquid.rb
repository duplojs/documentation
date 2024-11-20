# frozen_string_literal: true

# Convert markdown highlight lines feature syntax to liquid syntax

Jekyll::Hooks.register :documents, :pre_render do |document, payload|
    docExt = document.extname.tr('.', '')
  
    # only process if we deal with a markdown file
    if payload['site']['markdown_ext'].include? docExt
      document.content.gsub!(/^{([\d\s]+)}\`\`\`([A-Za-z]+)$(.*?)^\`\`\`$/im, '{% highlight \2 highlight_lines="\1" %}\3{% endhighlight %}')
    end
  end