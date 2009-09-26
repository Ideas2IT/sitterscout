class Array
  def paginate(page=1, per_page=15)
    pagination_array = WillPaginate::Collection.new(page, per_page, self.size)
    start_index = pagination_array.offset
    end_index = start_index + (per_page - 1)
    array_to_concat = self[start_index..end_index]
    array_to_concat.nil? ? [] : pagination_array.concat(array_to_concat)
  end
end