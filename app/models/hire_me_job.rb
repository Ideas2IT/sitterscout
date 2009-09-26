class HireMeJob < Choice
  [:parent, :sitter].each do |r|
    belongs_to r
  end
end