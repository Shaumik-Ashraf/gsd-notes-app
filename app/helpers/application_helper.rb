module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: false, hard_wrap: false)
    Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      tables: true
    ).render(text.to_s).html_safe
  end
end
