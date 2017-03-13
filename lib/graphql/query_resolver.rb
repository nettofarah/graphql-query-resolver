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
        # ActiveRecord::Associations::Preloader.new(to_load, dependencies).run
        ActiveRecord::Associations::Preloader.new.preload(to_load, dependencies)
      end

      to_load
    end

    def self.map_dependencies(class_name, ast_node)
      dependencies = {}
      ast_node.selections.each do |selection|
        name = selection.name

        if class_name.reflections.with_indifferent_access[selection.name].present?
          begin
            current_class_name = selection.name.singularize.classify.constantize
            dependencies[name] = map_dependencies(current_class_name, selection)
          rescue NameError
            selection_name = class_name.reflections[selection.name.to_sym].options[:class_name]
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
