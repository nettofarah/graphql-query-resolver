require "graphql"
require "graphql/query_resolver/version"

module GraphQL
  module QueryResolver

    def self.run(model_class, context, return_type)
      to_load = yield
      dependencies = {}

      reflection_dependencies = map_dependencies(model_class, context.ast_node)
      dependencies = reflection_dependencies.merge(dependencies)

      if dependencies.any? && to_load.present?
        if ActiveRecord::VERSION::MAJOR < 4
          ActiveRecord::Associations::Preloader.new(to_load, dependencies).run
        else
          ActiveRecord::Associations::Preloader.new.preload(to_load, dependencies)
        end
      end

      to_load
    end

    def self.using_relay_pagination?(selection)
      selection.name == 'edges'
    end

    def self.map_relay_pagination_depencies(class_name, selection, dependencies)
      node_selection = selection.selections.find { |sel| sel.name == 'node' }

      if node_selection.present?
        map_dependencies(class_name, node_selection, dependencies)
      else
        dependencies
      end
    end

    def self.has_reflection_with_name?(class_name, selection_name)
      class_name.reflections.with_indifferent_access[selection_name].present?
    end

    def self.map_dependencies(class_name, ast_node, dependencies={})
      ast_node.selections.each do |selection|
        name = selection.name

        if using_relay_pagination?(selection)
          map_relay_pagination_depencies(class_name, selection, dependencies)
          next
        end

        if has_reflection_with_name?(class_name, name)
          begin
            current_class_name = selection.name.singularize.classify.constantize
            dependencies[name] = map_dependencies(current_class_name, selection)
          rescue NameError
            selection_name = class_name.reflections.with_indifferent_access[selection.name].options[:class_name]
            current_class_name = selection_name.singularize.classify.constantize
            dependencies[selection.name.to_sym] = map_dependencies(current_class_name, selection)
            next
          end
        end
      end

      dependencies
    end
  end
end
