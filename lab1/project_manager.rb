require 'json'
require 'yaml'

VALID_STATUSES = %w[planned in_progress completed cancelled].freeze


def add_project(collection, title:, team:, tags:, client:, start_date:, deadline:, budget:, status: 'planned')
  validate_status!(status)
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
rescue ArgumentError => e
  puts "Помилка: #{e.message}"
end

def edit_project(collection, id, new_data)
  project = find_project!(collection, id)
  validate_status!(new_data[:status]) if new_data.key?(:status)
  project.merge!(new_data)
  puts "Проєкт ID=#{id} оновлено."
rescue ArgumentError => e
  puts "Помилка: #{e.message}"
end

def delete_project(collection, id)
  find_project!(collection, id)
  collection.delete(id)
  puts "Проєкт ID=#{id} видалено."
rescue ArgumentError => e
  puts "Помилка: #{e.message}"
end

def list_projects(collection)
  if collection.empty?
    puts 'Колекція порожня.'
    return
  end
  collection.each { |id, p| puts format_project(id, p) }
end


def find_by_title(collection, query)
  results = collection.select { |_, p| p[:title].downcase.include?(query.downcase) }
  print_results(results, "назвою '#{query}'")
end

def filter_by_status(collection, status)
  results = collection.select { |_, p| p[:status] == status }
  print_results(results, "статусом '#{status}'")
end

def filter_by_tag(collection, tag)
  results = collection.select { |_, p| p[:tags].any? { |t| t.downcase == tag.downcase } }
  print_results(results, "тегом '#{tag}'")
end


def save_to_json(collection, filename)
  data = collection.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) }
  File.write(filename, JSON.pretty_generate(data))
  puts "Збережено у '#{filename}'."
rescue => e
  puts "Помилка збереження JSON: #{e.message}"
end

def load_from_json(filename)
  raw = JSON.parse(File.read(filename))
  loaded = raw.transform_keys(&:to_i).transform_values { |v| symbolize_keys(v) }
  puts "Завантажено #{loaded.size} проєкт(ів) з '#{filename}'."
  loaded
rescue Errno::ENOENT
  puts "Файл '#{filename}' не знайдено."
  {}
rescue JSON::ParserError => e
  puts "Помилка парсингу JSON: #{e.message}"
  {}
end

def save_to_yaml(collection, filename)
  File.write(filename, collection.to_yaml)
  puts "Збережено у '#{filename}'."
rescue => e
  puts "Помилка збереження YAML: #{e.message}"
end

def load_from_yaml(filename)
  data = YAML.safe_load(File.read(filename), permitted_classes: [Symbol])
  loaded = data.transform_keys(&:to_i).transform_values { |v| symbolize_keys(v) }
  puts "Завантажено #{loaded.size} проєкт(ів) з '#{filename}'."
  loaded
rescue Errno::ENOENT
  puts "Файл '#{filename}' не знайдено."
  {}
rescue Psych::Exception => e
  puts "Помилка парсингу YAML: #{e.message}"
  {}
end


def generate_id(collection)
  (collection.keys.max || 0) + 1
end

def find_project!(collection, id)
  collection.fetch(id) { raise ArgumentError, "Проєкт з ID=#{id} не знайдено." }
end

def validate_status!(status)
  return if VALID_STATUSES.include?(status)

  raise ArgumentError, "Некоректний статус '#{status}'. Допустимі: #{VALID_STATUSES.join(', ')}."
end

def format_project(id, p)
  <<~TEXT
    [#{id}] #{p[:title]}  |  #{p[:status]}
         Клієнт:   #{p[:client]}
         Команда:  #{p[:team].join(', ')}
         Теги:     #{p[:tags].join(', ')}
         Початок:  #{p[:start_date]}   Дедлайн: #{p[:deadline]}
         Бюджет:   #{format('%.2f', p[:budget])} грн
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

def stringify_keys(value)
  return value.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) } if value.is_a?(Hash)

  value
end

def symbolize_keys(value)
  return value.transform_keys(&:to_sym).transform_values { |v| symbolize_keys(v) } if value.is_a?(Hash)

  value
end
