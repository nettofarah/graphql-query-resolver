require "graphql"
require "graphql/query_resolver/version"

module GraphQL
  module QueryResolver
    def self.run(model_class, context, _return_type, &block)
      Resolver.new(model_class, context).call(&block)
    end

    class Resolver
      attr_reader :context, :fragment_definitions

      def initialize(model_class, context)
        @model_class = model_class
        @context = context
        @fragment_definitions = context.query.fragments
      end

      def call
        to_load = yield
        dependencies = map_dependencies(@model_class, context.ast_node)

        if dependencies.any? && to_load.present?
          preload_dependencies(to_load, dependencies)
        end

        to_load
      end

      private

      def preload_dependencies(to_load, dependencies)
        if ActiveRecord::VERSION::MAJOR < 4
          return ActiveRecord::Associations::Preloader.new(
            to_load, dependencies
          ).run
        end

        ActiveRecord::Associations::Preloader.new.preload(to_load, dependencies)
      end

      def relay_connection_using_edges?(selection)
        selection.name == 'edges'
      end

      def relay_connection_using_nodes?(selection)
        selection.name == 'nodes'
      end

      def map_relay_pagination_depencies(class_name, selection, dependencies)
        node_selection = selection.selections.find { |sel| sel.name == 'node' }

        return unless node_selection.present?

        map_dependencies(class_name, node_selection, dependencies)
      end

      def preloadable_reflection?(class_name, selection_name)
        class_name.reflections.with_indifferent_access[selection_name].present?
      end

      def map_dependencies(class_name, ast_node, dependencies = {})
        ast_node.selections.each do |selection|
          if inline_fragment?(selection) || relay_connection_using_nodes?(selection)
            map_dependencies(class_name, selection, dependencies)

            next
          end

          if fragment_spread?(selection)
            fragment_definition = fragment_definitions[selection.name]
            map_dependencies(class_name, fragment_definition, dependencies)

            next
          end

          if relay_connection_using_edges?(selection)
            map_relay_pagination_depencies(class_name, selection, dependencies)

            next
          end

          name = selection.name
          next unless preloadable_reflection?(class_name, name)

          begin
            current_class_name = name.singularize.classify.constantize
          rescue NameError
            selection_name = class_name.reflections[name].options[:class_name]
            current_class_name = selection_name.singularize.classify.constantize
          end

          dependencies[name.to_sym] = map_dependencies(current_class_name, selection)
        end

        dependencies
      end

      def inline_fragment?(selection)
        selection.is_a?(GraphQL::Language::Nodes::InlineFragment)
      end

      def fragment_spread?(selection)
        selection.is_a?(GraphQL::Language::Nodes::FragmentSpread)
      end
    end
  end
end
