class Setting < ApplicationRecord
  belongs_to :organization

  def self.get(key, default = nil, organization: nil)
    find_by(key: key, organization: organization)&.value || default
  end

  def self.set(key, value, organization: nil)
    find_or_initialize_by(key: key, organization: organization).tap do |setting|
      setting.value = value
      setting.save
    end
  end
end
