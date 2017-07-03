module ::RecipeHelper
  class << self
    def bootstrap(context)
      @context = context
      init_node
      init_properties
    end

    def top_dir
      @top_dir ||= File.expand_path('../..', __FILE__)
    end

    def node
      @context.node
    end

    private

    def init_node
      node[:environment] = ENV['MITAMAE_ENVIRONMENT'] if ENV['MITAMAE_ENVIRONMENT']
      node[:host] = ENV['MITAMAE_HOST'] if ENV['MITAMAE_HOST']
      node[:roles] = ENV['MITAMAE_ROLES'].split(/\s+/) if ENV['MITAMAE_ROLES']
      node[:team_no] = ENV['MITAMAE_TEAM_NO'].to_i if ENV['MITAMAE_TEAM_NO']
    end

    def init_properties
      properties = Hashie::Mash.new
      property_files.each do |property_file|
        properties.deep_merge!(YAML.load(IO.read(property_file)))
      end
      node.merge!(properties)
    end

    def property_files
      files = [
        File.join(top_dir, 'properties', 'environments', "#{node[:environment]}.yml"),
        *node[:roles].map {|r| File.join(top_dir, 'properties', 'roles', "#{r}.yml") },
        File.join(top_dir, 'properties', 'nodes', "#{node[:host]}.yml")
      ]
      files.select {|fn| File.file?(fn) }
    end
  end
end

class MItamae::RecipeContext
  def attrs
    node[:attributes]
  end

  def global_attrs
    node[:global_attributes]
  end

  def include_middleware(name)
    include_recipe File.join(top_dir, 'recipes', 'middleware', name)
  end

  def top_dir
    ::RecipeHelper.top_dir
  end
end

class MItamae::ResourceContext
  def attrs
    node[:attributes]
  end

  def global_attrs
    node[:global_attributes]
  end
end

class MItamae::Resource::Template < MItamae::Resource::RemoteFile
  def attrs
    node[:attributes]
  end

  def global_attrs
    node[:global_attributes]
  end
end
