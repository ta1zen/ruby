require_relative 'project'
require_relative 'project_manager'

class App
  YAML_FILE = 'projects.yaml'
  JSON_FILE = 'projects.json'

  def initialize
    @manager = ProjectManager.new
    load_initial_data
  end

  def run
    loop do
      print_menu
      print "Ваш вибір: "
      choice = gets.chomp.to_i

      break if choice == 0

      handle_choice(choice)
    end
  ensure
    @manager.save_to_yaml(YAML_FILE)
    puts "\n[Система] Дані автоматично збережено у #{YAML_FILE} перед виходом."
  end

  private

  def load_initial_data
    if @manager.load_from_yaml(YAML_FILE)
      puts "[Система] Дані успішно завантажено з #{YAML_FILE}"
    elsif @manager.load_from_json(JSON_FILE)
      puts "[Система] Дані успішно завантажено з #{JSON_FILE}"
    else
      puts "[Система] Файли не знайдено. Створено нову порожню колекцію."
    end
  end

  def print_menu
    puts "\n" + "="*35
    puts "      МЕНЕДЖЕР ПРОЄКТІВ"
    puts "="*35
    puts "1. Додати проєкт"
    puts "2. Показати всі проєкти"
    puts "3. Знайти за назвою"
    puts "4. Видалити проєкт"
    puts "5. Редагувати проєкт"
    puts "6. Експорт у JSON"
    puts "0. Вихід"
    puts "="*35
  end

  def handle_choice(choice)
    case choice
    when 1
      add_project_dialog
    when 2
      display_projects(@manager.list_projects)
    when 3
      print "Введіть частину назви: "
      query = gets.chomp
      display_projects(@manager.find_by_title(query))
    when 4
      print "Введіть ID для видалення: "
      id = gets.chomp.to_i
      if @manager.delete_project(id)
        puts "Проєкт видалено."
      else
        puts "Проєкт з таким ID не знайдено."
      end
    when 5
      edit_project_dialog
    when 6
      @manager.save_to_json(JSON_FILE)
      puts "Дані успішно експортовано у #{JSON_FILE}."
    else
      puts "Невідома команда, спробуйте ще раз."
    end
  end

  def display_projects(collection)
    if collection.empty?
      puts "Проєктів не знайдено."
    else
      collection.each { |id, project| puts "[#{id}] #{project.to_s}" }
    end
  end

  def add_project_dialog
    puts "\n--- Додавання нового проєкту ---"
    
    print "Назва: "
    title = gets.chomp
    
    print "Команда (введіть через кому, напр. Іван, Марія): "
    team = gets.chomp.split(',').map(&:strip)
    
    print "Теги (введіть через кому, напр. Web, Ruby): "
    tags = gets.chomp.split(',').map(&:strip)
    
    print "Клієнт: "
    client = gets.chomp
    
    print "Дата початку (у форматі YYYY-MM-DD): "
    start_date = gets.chomp
    
    print "Дедлайн (у форматі YYYY-MM-DD): "
    deadline = gets.chomp
    
    print "Бюджет: "
    budget = gets.chomp.to_f
    
    print "Статус (planned, in_progress, completed, cancelled) [залишити порожнім для planned]: "
    status_input = gets.chomp
    status = status_input.empty? ? "planned" : status_input
    
    project = Project.new(title, team, tags, client, start_date, deadline, budget, status)
    
    id = @manager.add_project(project)
    puts "Проєкт '#{title}' успішно додано (ID: #{id})."
  end

  def edit_project_dialog
    print "Введіть ID проєкту для редагування: "
    id = gets.chomp.to_i
    
    projects = @manager.list_projects
    unless projects.key?(id)
      puts "Проєкт з таким ID не знайдено."
      return
    end

    project = projects[id]
    puts "\n--- Редагування: #{project.title} ---"
    puts "(Натисніть Enter, якщо не хочете змінювати поле)"
    
    new_data = {}

    print "Нова назва [зараз: #{project.title}]: "
    val = gets.chomp
    new_data[:title] = val unless val.empty?

    print "Нова команда (через кому) [зараз: #{project.team.join(', ')}]: "
    val = gets.chomp
    new_data[:team] = val.split(',').map(&:strip) unless val.empty?
    
    print "Нові теги (через кому) [зараз: #{project.tags.join(', ')}]: "
    val = gets.chomp
    new_data[:tags] = val.split(',').map(&:strip) unless val.empty?

    print "Новий клієнт [зараз: #{project.client}]: "
    val = gets.chomp
    new_data[:client] = val unless val.empty?
    
    print "Нова дата початку [зараз: #{project.start_date}]: "
    val = gets.chomp
    new_data[:start_date] = val unless val.empty?

    print "Новий дедлайн [зараз: #{project.deadline}]: "
    val = gets.chomp
    new_data[:deadline] = val unless val.empty?

    print "Новий статус (planned, in_progress, completed, cancelled) [зараз: #{project.status}]: "
    val = gets.chomp
    new_data[:status] = val unless val.empty?

    print "Новий бюджет [зараз: #{project.budget}]: "
    val = gets.chomp
    new_data[:budget] = val.to_f unless val.empty?

    if new_data.empty?
      puts "Змін не внесено."
    else
      @manager.edit_project(id, new_data)
      puts "Проєкт успішно оновлено!"
    end
  end
end

App.new.run