module Hancock::Pages::Connectable
  extend ActiveSupport::Concern

  module ClassMethods
    def hancock_connectable_field (name = :connected_pages, opts = {})
      class_name = opts.delete(:class_name)
      class_name ||= "Hancock::Pages::Page"
      routes_namespace = opts.delete(:routes_namespace)
      routes_namespace ||= :main_app
      autocreate_page = opts.delete(:autocreate_page)
      autocreate_page = false if autocreate_page.nil?

      has_many name, as: :hancock_connectable, class_name: class_name
      class_eval <<-EVAL
        def routes_namespace
          :#{routes_namespace}
        end
      EVAL

      if autocreate_page
        attr_accessor :hancock_connectable_autocreate_page
        _name_attr = Hancock::Pages.config.localize ? "name_translations" : "name"
        class_eval <<-EVAL
          after_create do
            if [true, 1, "1", "true", "t"].include?(self.hancock_connectable_autocreate_page)
              _p = #{class_name}.new
              _p.#{_name_attr} = self.#{_name_attr}
              _p.hancock_connectable = self
              _p.save
            end
          end
        EVAL
      end
    end
  end
end
