module ActionDispatch::Routing
  class Mapper

    def hancock_cms_pages_routes(config = {})
      routes_config = {
        use_slug_path: true,
        use_pages_path: true,
        classes: {
          pages: :pages
        },
        paths: {
          pages: :pages
        }
      }
      routes_config.deep_merge!(config)

      generate_hancock_pages_user_routes(routes_config)
      generate_hancock_pages_cms_routes(routes_config)

    end


    private
    def generate_hancock_pages_user_routes(routes_config)
      if !routes_config[:use_pages_path] and !routes_config[:classes][:pages].nil?
        resources routes_config[:classes][:pages].to_sym, only: [:show], path: routes_config[:paths][:pages]
      end
      if !routes_config[:use_slug_path] and !routes_config[:classes][:pages].nil?
        get '*slug' => "#{routes_config[:classes][:pages]}#show"
      end
    end
    def generate_hancock_pages_cms_routes(routes_config)
      scope module: 'hancock' do
        scope module: 'pages' do
          if routes_config[:use_pages_path] and !routes_config[:classes][:pages].nil?
            resources routes_config[:classes][:pages].to_sym, only: [:show], path: routes_config[:paths][:pages], as: :hancock_pages
          end
          if routes_config[:use_slug_path] and !routes_config[:classes][:pages].nil?
            get '*slug' => "#{routes_config[:classes][:pages]}#show"
          end
        end
      end
    end

  end
end
