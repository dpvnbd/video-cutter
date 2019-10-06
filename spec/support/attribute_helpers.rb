# Recursively digs attributes, methods and keys in objects and hashes
# Filter example: [:id, :name, user: [:id, :email], posts: [:id, :body, comments: [:id, :body]]]
def extract_attributes(object, filter)
  return {} if filter.blank?

  top_level_attrs = filter.reject { |a| a.is_a? Hash }.map(&:to_s)
  nested_attrs = filter.select { |a| a.is_a? Hash }

  result = {}

  if object.is_a? ActiveRecord::Base
    top_level_attrs.each do |attribute|
      result[attribute] = convert_attributes(object.public_send(attribute))
    end
  elsif object.is_a? Hash
    indifferent = object.with_indifferent_access
    values = top_level_attrs.reduce({}) { |h, k| h[k] = indifferent[k]; h }
    result = result.merge(convert_attributes(values))
  else
    result = object
  end

  nested_attrs.each do |nested|
    nested.each do |field, field_attrs|

      field_value = if object.is_a? Hash
                      object.with_indifferent_access[field.to_s]
                    else
                      object.public_send(field.to_s)
                    end
      result[field.to_s] = if field_value.is_a? Hash
                             extract_attributes(field_value, field_attrs)
                           elsif field_value.is_a? Enumerable
                             field_value.map { |value_item| extract_attributes(value_item, field_attrs) }
                           else
                             extract_attributes(field_value, field_attrs)
                           end
    end
  end

  result
end

# Round and convert date and time so they are equal to response strings
def convert_attributes(attrs)
  if attrs.is_a? Time
    attrs.iso8601(3)
  elsif attrs.is_a? Date
    attrs.iso8601
  elsif attrs.is_a? Hash
    attrs.map { |k, v| { k => convert_attributes(v) } }.reduce(:merge)
  else
    attrs
  end
end

# Matches nested hashes and arrays of hashes ignoring the order
def nested_hash_matcher(hash)
  nested_hashes = hash.select { |_, v| v.is_a? Hash }
  nested_arrays = hash.select { |_, v| v.is_a? Array }
  top_level = hash.reject { |_, v| v.is_a?(Hash) || v.is_a?(Array) }

  nested_hashes.each do |k, nested_hash|
    top_level[k] = nested_hash_matcher(nested_hash)
  end

  nested_arrays.each do |k, nested_array|
    if nested_array.all? { |item| item.is_a? Hash }
      matchers = nested_array.map(&method(:nested_hash_matcher))
      top_level[k] = contain_exactly(*matchers)
    else
      top_level[k] = match_array(nested_array)
    end
  end

  include(top_level)
end

#
# def print_diff(actual, expected)
#   puts SuperDiff::EqualityMatcher.new(expected: expected, actual: actual).call
# end