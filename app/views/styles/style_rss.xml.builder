headers["Content-Type"] = "application/rss+xml"
xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       @page_title
    xml.link        url_for(:only_path => false)
    xml.pubDate     CGI.rfc1123_date(@styles.first.updated) if @styles.any?
    xml.description @page_title

    @styles.each do |style|
      xml.item do
        xml.title       style.short_description
        xml.link        url_for(:only_path => false, :controller => 'styles', :action => 'show', :id => style.id)
        xml.description render(:partial => "style_feed_entry.html.erb", :locals => {:style => style})
        xml.pubDate     CGI.rfc1123_date(style.updated)
        xml.guid        url_for(:only_path => false, :controller => 'styles', :action => 'show', :id => style.id)
        xml.author      "jason.barnabe@gmail.com (#{style.user.name})"
      end
    end

  end
end
