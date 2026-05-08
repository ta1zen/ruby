require 'yaml'
require 'json'
require_relative 'project'

class ProjectManager
  attr_reader :collection

  def initialize
    @collection = {}
    @next_id = 1
  end

  def add_project(project)
    @collection[@next_id] = project
    @next_id += 1
  end

  def get_project(id)
    @collection[id]
  end

  def delete_project(id)
    @collection.delete(id)
  end

  def find_by_title(query)
    @collection.select { |_, p| p.title.downcase.include?(query.downcase) }
  end

  def filter_by_status(status)
    @collection.select { |_, p| p.status == status }
  end

  def filter_by_tag(tag)
    @collection.select { |_, p| p.tags.any? { |t| t.downcase == tag.downcase } }
  end

  def save_to_yaml(filename = 'projects.yml')
    File.write(filename, YAML.dump(@collection))
  end

  def load_from_yaml(filename = 'projects.yml')
    return false unless File.exist?(filename)

    @collection = YAML.load_file(filename) || {}
    update_next_id
    true
  end

  def save_to_json(filename = 'projects.json')
    File.write(filename, JSON.pretty_generate(@collection.transform_values(&:to_h)))
  end

  def load_from_json(filename = 'projects.json')
    return false unless File.exist?(filename)

    json_data = JSON.parse(File.read(filename))
    @collection = json_data.to_h { |id, h| [id.to_i, Project.from_h(h)] }
    update_next_id
    true
  end

  private

  def update_next_id
    @next_id = (@collection.keys.max || 0) + 1
  end
end
