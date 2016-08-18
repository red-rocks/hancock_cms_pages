module Hancock::Pages
  class PagesController < ApplicationController
    include Hancock::Pages::Controllers::Pages

    include Hancock::Pages::Decorators::PagesController
  end
end
