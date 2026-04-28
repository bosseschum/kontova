module ApplicationHelper
  def format_euro(cents)
    format("%+.2f €", cents / 100.0).gsub(".", ",")
  end
end
