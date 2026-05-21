require 'json'
require 'yaml'
require_relative 'project'

class ProjectManager
  def initialize
    @collection = {}
  end

  def add_project(project)
    id = (@collection.keys.max || 0) + 1
    @collection[id] = project
    id
  end

  def edit_project(id, new_data)
    project = @collection[id]
    return false unless project

    new_data.each do |key, value|
      project.send("#{key}=", value) if project.respond_to?("#{key}=")
    end
    true
  end

  def delete_project(id)
    @collection.delete(id)
  end

  def list_projects
    @collection
  end

  def find_by_title(query)
    @collection.select { |_, p| p.title.downcase.include?(query.downcase) }
  end

  def filter_by_status(status)
    @collection.select { |_, p| p.status == status }
  end

  def filter_by_tag(tag)
    @collection.select { |_, p| p.tags.include?(tag) }
  end

  def save_to_yaml(filename)
    File.write(filename, YAML.dump(@collection))
  end

  def load_from_yaml(filename)
    return false unless File.exist?(filename)
    
    @collection = YAML.unsafe_load(File.read(filename)) || {}
    true
  rescue StandardError => e
    puts "Помилка YAML: #{e.message}"
    false
  end

  def save_to_json(filename)
    hash_collection = @collection.transform_values(&:to_h)
    File.write(filename, JSON.pretty_generate(hash_collection))
  end

  def load_from_json(filename)
    return false unless File.exist?(filename)
    
    raw = JSON.parse(File.read(filename), symbolize_names: true)
    
    @collection = raw.transform_keys(&:to_s).transform_keys(&:to_i).transform_values do |project_hash|
      Project.from_h(project_hash)
    end
    true
  end
end