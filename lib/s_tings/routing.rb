module STingsRoutes #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions
      def s_tings
        send :resources, :settings, :except => [:edit, :create, :new], :collection => {:update_all => :put}
      end
    end
  end
end

ActionController::Routing::RouteSet::Mapper.send :include, STingsRoutes::Routing::MapperExtensions