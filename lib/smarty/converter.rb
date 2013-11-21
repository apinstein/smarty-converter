require "smarty/converter/version"
require 'nokogiri'

module Smarty
  class Converter
    # Your code goes here...

    def initialize(html, rewrite_path)
      @html = html
      @rewrite_path = rewrite_path
    end

    def doc
      @doc ||= Nokogiri::HTML(@html)
    end

    ABSOLUTE_REGEX = %r{^/}
    HTTP_REGEX = %r{^[http|https]}
    def urls
     (uncommented_links + commented_links + uncommented_scripts + commented_scripts).map { |url| url unless (url =~ ABSOLUTE_REGEX || url =~ HTTP_REGEX)}.compact
    end

    def uncommented_scripts
      doc.css('script').map { |script| script.attributes['src'].value }
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
      head = doc.at_css('head')
      body = doc.at_css('body')
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

    def convert
      @template = smarty_template
    end
  end
end
