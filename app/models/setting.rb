class Setting < ApplicationRecord
  def self.get(key, default = nil)
    find_by(key: key)&.value || default
  end

  def self.set(key, value)
    find_or_initialize_by(key: key).tap do |setting|
      setting.value = value
      setting.save
    end
  end
end
