module Hancock::Pages::SeoPages
  extend ActiveSupport::Concern
  included do
    before_action :find_page

    helper_method :current_seo_page
  end

  def current_seo_page
    @current_seo_page ||= (@seo_page || @seo_parent_page)
  end
  
  def seo_object
    @seo_page
  end


  private
  def path_subdomains_transformer(path, subdomains = [])
    return path, subdomains
  end

  def find_page
    return if rails_admin?
    @seo_page = find_seo_page request.path, request.subdomains
    if !@seo_page.nil? && !@seo_page.redirect.blank?
      redirect_to @seo_page.redirect, status: :moved_permanently
    end
  end

  def find_seo_page(path, subdomains = [])
    path, subdomains = path_subdomains_transformer(path, subdomains)
    subdomain = subdomains.join(".")
    do_redirect = false
    if path[0] != '/'
      path = '/' + path
    end
    if path.length > 1 && path[-1] == '/'
      path = path[0..-2]
      do_redirect = true
    end
    page = page_class.enabled.all_of({fullpath: path}, {subdomain: subdomain}).first

    if page.nil? && !params[:slug].blank?
      page = page_class.enabled.all_of({fullpath: "/" + params[:slug]}, {subdomain: subdomain}).first
    end

    if page.nil?
      page = find_seo_extra(path)
    end

    if page.nil?
      do_redirect = true
      spath = path.chomp(File.extname(path))
      if spath and spath != path and (!params[:slug].blank? and spath != "/" + params[:slug])
        page = page_class.enabled.all_of({fullpath: spath}, {subdomain: subdomain}).first
      end
    end

    if !page.nil? && do_redirect
      redirect_to path, status: :moved_permanently
    end

    page
  end

  def find_seo_page_with_redirect(path, subdomains = [])
    path, subdomains = path_subdomains_transformer(path, subdomains)
    subdomain = subdomains.join(".")
    do_redirect = false
    if path[0] != '/'
      path = '/' + path
    end
    if path.length > 1 && path[-1] == '/'
      path = path[0..-2]
      do_redirect = true
    end

    page = page_class.enabled.all_of({"$or": [{fullpath: path}, {redirect: path}]}, {subdomain: subdomain}).first
    if page.nil?
      do_redirect = true
      spath = path.chomp(File.extname(path))
      if spath != path
        page = page_class.enabled.all_of({"$or": [{fullpath: spath}, {redirect: spath}]}, {subdomain: subdomain}).first
      end
    end
    if !page.nil? && do_redirect
      redirect_to path, status: :moved_permanently
    end

    page
  end


  def page_title
    if @seo_page.nil?
      if Hancock::Pages.config.seo_support
        Hancock::Seo::Seo.settings.default_title
      else
        Settings ? Settings.default_title : "" #temp
      end
    else
      @seo_page.page_title
    end
  end


  def find_seo_extra(path)
    nil
  end

  def page_class_name
    "Hancock::Pages::Page"
  end
  def page_class
    @page_class ||= page_class_name.constantize
  end

  def rails_admin?
    self.is_a?(RailsAdmin::ApplicationController) || self.is_a?(RailsAdmin::MainController) || (respond_to?(:rails_admin_controller?) and rails_admin_controller?)
  end
end
