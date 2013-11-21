require "smarty/converter/version"
require 'nokogiri'
#require 'nokogiri-pretty'

module Smarty
  class Converter

    def initialize(html, rewrite_path)
      @html = html
      @rewrite_path = rewrite_path
    end

    def doc
      @doc ||= Nokogiri::HTML(@html, &:noblanks)
    end

    ABSOLUTE_REGEX = %r{^/}
    HTTP = 'http'

    def urls
     (uncommented_links + commented_links + commented_scripts +  scripts).map { |url| url unless (url =~ ABSOLUTE_REGEX || url.include?(HTTP))}.compact
    end

    def scripts
      scripts = doc.xpath('//node()').map { |n| n if n.name == 'script' }.compact
      scripts.map { |script| script.attributes['src'].value if script.attributes['src'] }.compact
    end

    def uncommented_links
      doc.css('link').map do |link|
        if link.attributes['rel'] && link.attributes['rel'].value == 'stylesheet'
          link.attributes['href'].value
        end
      end.compact
    end

    def commented_scripts
      scripts = []
      doc.xpath('//comment()').each do |comment|
        _doc = Nokogiri::HTML(comment.content)
        _doc.css('script').each { |script| scripts << script.attributes['src'].value }
      end
      scripts
    end

    def commented_links
      links = []
      doc.xpath('//comment()').each do |comment|
        _doc = Nokogiri::HTML(comment.content)
        _doc.css('link').each do|link| 
          if link.attributes['rel'] && link.attributes['rel'].value == 'stylesheet'
            links << link.attributes['href'].value
          end
        end
      end

     links 
    end

    def smarty_template
      #head = doc.at_css('head').children.to_html
      #body = doc.at_css('body').children.to_html
      head = /<head>(.+)<\/head>/m.match(@html)[1]
      body = /<body[.+]?>(.+)<\/body>/m.match(@html)[1]
      template = <<-SMARTY
{WFHead}
#{head}
{/WFHead}
{literal}
 #{body}
 {/literal}
      SMARTY
      urls.each do |url|
        new_url = @rewrite_path + url
        template.sub!(url, new_url)
      end

      template
    end

  end
end
