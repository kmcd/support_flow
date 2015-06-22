module Labelable
  extend ActiveSupport::Concern
  
  included do
  end
  
  def label_list
    return '' unless labels.present?
    labels.join ' '
  end
  
  def label_list=(label_list)
    self.labels = parse label_list
  end
  
  def parse(label_list)
    label_list.
      split(/(\s+|,)/).
      reject(&:blank?).
      flatten
  end
end
