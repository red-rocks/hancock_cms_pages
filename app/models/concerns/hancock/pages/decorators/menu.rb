module Hancock::Pages::Decorators
  module Menu
    extend ActiveSupport::Concern

    included do

      # def self.default_cache_keys
      #   ['menus']
      # end

      ############# rails_admin ##############
      # def self.rails_admin_add_fields
      #   [] #super
      # end
      #
      # def self.rails_admin_add_config(config)
      #   #super(config)
      # end

      # def admin_can_user_defined_actions
      #   [].freeze
      # end
      # def admin_cannot_user_defined_actions
      #   [].freeze
      # end
      # def manager_can_user_defined_actions
      #   [].freeze
      # end
      # def manager_cannot_user_defined_actions
      #   [].freeze
      # end
      # def rails_admin_user_defined_visible_actions
      #   [].freeze
      # end

    end

  end
end
