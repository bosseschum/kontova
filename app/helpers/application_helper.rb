module ApplicationHelper
  def euro(cents)
    format("%.2f", cents / 100.0).gsub(".", ",") + " €"
  end

  def euro_signed(cents)
    format("%+.2f", cents / 100.0).gsub(".", ",") + " €"
  end
end
