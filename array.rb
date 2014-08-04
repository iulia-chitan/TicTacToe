class Array
  def all_empty?
    self.all? { |element| element.to_s.empty? || element.to_s.nil? }
  end

  def all_same?

    self.all? { |element| element == self[0] && !element.to_s.nil? && !element.to_s.empty? }
  end

  def any_empty?
    self.any? { |element| element.to_s.empty? || element.to_s.nil? }
  end

  def none_empty?
    !any_empty?
  end
end