module StripAttributes
  # Strips whitespace from model fields and converts blank values to nil.
  def strip_attributes!
    before_validation do |record|
      attributes = record.attributes
      attributes.each do |attr, value|
        if value.respond_to?(:strip)
          record[attr] = (value.blank?) ? nil : value.strip
        end
      end
    end
  end
end
