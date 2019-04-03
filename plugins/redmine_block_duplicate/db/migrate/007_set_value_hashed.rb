class SetValueHashed < ActiveRecord::Migration

  def self.up
    CustomValue.find_each do |cv|
      if (cv.value)
        cv.value_hashed = Digest::SHA256.hexdigest(cv.value)
        cv.save
      end
    end
  end

  def self.down
  end
end
