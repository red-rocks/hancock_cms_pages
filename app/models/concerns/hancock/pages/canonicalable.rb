module Hancock::Pages::Canonicalable
  extend ActiveSupport::Concern

  module ClassMethods
    def hancock_canonical_fields(default = true)
      if Hancock::Pages.mongoid?
        field :use_hancock_canonicalable, type: Mongoid::Boolean, default: default
        belongs_to :hancock_canonicalable, polymorphic: true
        field :hancock_canonicalable_url, type: String, default: ""
      end
    end
  end

  included do
    hancock_canonical_fields
    def hancock_canonical_url(view_object)
      return hancock_canonicalable_url unless hancock_canonicalable_url.blank?
      return view_object.url_for hancock_canonicalable unless hancock_canonicalable.nil?
    end
  end

end
