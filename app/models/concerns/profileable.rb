module Profileable
  extend ActiveSupport::Concern
  
  included do
    def self.profile_entry(profile_entries=[])
      [ profile_entries ].flatten.each do |profile_entry|
        entry = profile_entry.to_s
        define_method(entry.to_sym) { profile[entry] }
        define_method("#{entry}=".to_sym) {|_| profile[entry] = _ }
      end
    end
  end
end
