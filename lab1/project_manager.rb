require 'json'
require 'yaml'

class ProjectManager
  VALID_STATUSES = %w[planned in_progress completed cancelled].freeze

  def self.add_project(collection, title:, team:, tags:, client:, start_date:, deadline:, budget:, status: 'planned')
    unless VALID_STATUSES.include?(status)
      puts "Помилка: Некоректний статус '#{status}'. Допустимі: #{VALID_STATUSES.join(', ')}."
      return
    end

    id = generate_id(collection)
    collection[id] = {
      title:      title,
      team:       Array(team),
      tags:       Array(tags),
      client:     client,
      start_date: start_date,
      deadline:   deadline,
      budget:     budget.to_f,
      status:     status
    }
    
    puts "Проєкт '#{title}' додано (ID=#{id})."
    id
  end

  def self.edit_project(collection, id, new_data)
    unless collection.key?(id)
      puts "Помилка: Проєкт з ID=#{id} не знайдено."
      return
    end

    if new_data.key?(:status) && !VALID_STATUSES.include?(new_data[:status])
      puts "Помилка: Некоректний статус '#{new_data[:status]}'."
      return
    end

    collection[id].merge!(new_data)
    puts "Проєкт ID=#{id} успішно оновлено."
  end

  def self.delete_project(collection, id)
    if collection.delete(id)
      puts "Проєкт ID=#{id} видалено."
    else
      puts "Помилка: Проєкт з ID=#{id} не знайдено."
    end
  end

  def self.list_projects(collection)
    if collection.empty?
      puts 'Колекція порожня.'
      return
    end
    collection.each { |id, p| puts format_project(id, p) }
  end

  def self.find_by_title(collection, query)
    results = collection.select { |_, p| p[:title].downcase.include?(query.downcase) }
    print_results(results, "назвою '#{query}'")
  end

  def self.filter_by_status(collection, status)
    results = collection.select { |_, p| p[:status] == status }
    print_results(results, "статусом '#{status}'")
  end

  def self.filter_by_tag(collection, tag)
    results = collection.select { |_, p| p[:tags].any? { |t| t.downcase == tag.downcase } }
    print_results(results, "тегом '#{tag}'")
  end

  def self.save_to_json(collection, filename)
    File.write(filename, JSON.pretty_generate(collection))
    puts "Збережено у '#{filename}'."
  rescue => e
    puts "Помилка збереження JSON: #{e.message}"
  end

  def self.load_from_json(filename)
    raw = JSON.parse(File.read(filename), symbolize_names: true)
    
    loaded = raw.transform_keys(&:to_s).transform_keys(&:to_i)
    
    puts "Завантажено #{loaded.size} проєкт(ів) з '#{filename}'."
    loaded
  rescue Errno::ENOENT
    puts "Помилка: Файл '#{filename}' не знайдено."
    {}
  rescue JSON::ParserError => e
    puts "Помилка парсингу JSON: #{e.message}"
    {}
  end

  def self.save_to_yaml(collection, filename)
    File.write(filename, collection.to_yaml)
    puts "Збережено у '#{filename}'."
  rescue => e
    puts "Помилка збереження YAML: #{e.message}"
  end

  def self.load_from_yaml(filename)
    loaded = YAML.load_file(filename) || {}
    puts "Завантажено #{loaded.size} проєкт(ів) з '#{filename}'."
    loaded
  rescue Errno::ENOENT
    puts "Помилка: Файл '#{filename}' не знайдено."
    {}
  end

  class << self
    private

    def generate_id(collection)
      (collection.keys.max || 0) + 1
    end

    def format_project(id, p)
      <<~TEXT
        [#{id}] #{p[:title]}  |  #{p[:status]}
             Клієнт:   #{p[:client]}
             Команда:  #{p[:team].join(', ')}
             Теги:     #{p[:tags].join(', ')}
             Початок:  #{p[:start_date]}   Дедлайн: #{p[:deadline]}
             Бюджет:   #{Kernel.format('%.2f', p[:budget])} грн
      TEXT
    end

    def print_results(results, label)
      if results.empty?
        puts "Проєктів з #{label} не знайдено."
      else
        puts "Знайдено #{results.size} проєкт(ів) з #{label}:"
        results.each { |id, p| puts format_project(id, p) }
      end
      results
    end
  end
end