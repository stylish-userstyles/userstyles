headers["Content-Type"] = "application/atom+xml"
xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   @page_title
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :format => :atom)
  xml.id      "rel" => "self", "href" => url_for(:only_path => false, :format => :atom)
  xml.updated @styles.first.updated.strftime("%Y-%m-%dT%H:%M:%SZ") if @styles.any?
  xml.author  { xml.name "Jason Barnabe" }

  @styles.each do |style|
    xml.entry do
      xml.title   style.short_description
      xml.link    "rel" => "alternate", "href" => style.full_pretty_url
      xml.id      url_for(:only_path => false, :controller => 'styles', :action => 'show', :id => style.id)
      xml.updated style.updated.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.author  { xml.name style.user.name }
      xml.content "type" => "html" do
        xml.text! render(:partial => "/styles/style_feed_entry.html.erb", :locals => {:style => style})
      end
    end
  end

end
