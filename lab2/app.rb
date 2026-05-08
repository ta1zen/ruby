require_relative 'project_manager'

class App
  VALID_STATUSES = %w[planned in_progress completed cancelled].freeze

  def initialize
    @manager = ProjectManager.new
    load_data
  end

  def run
    loop do
      print_menu
      choice = gets.chomp

      case choice
      when '1' then list_projects
      when '2' then create_project
      when '3' then edit_project
      when '4' then delete_project
      when '5' then find_by_title
      when '6' then filter_by_status
      when '7' then filter_by_tag
      when '8' then save_to_json_explicit
      when '9' then load_from_json_explicit
      when '0'
        puts "Завершення роботи..."
        break
      else
        puts "Невірний вибір. Будь ласка, спробуйте ще раз."
      end
    end
  rescue Interrupt
    puts "\nЕкстрене завершення..."
  ensure
    @manager.save_to_yaml
    puts "Дані автозбережено у projects.yml."
  end

  private

  def load_data
    if @manager.load_from_yaml
      puts "Дані завантажено з projects.yml."
    elsif @manager.load_from_json
      puts "Дані завантажено з projects.json."
    else
      puts "Файли даних не знайдені. Створено нову порожню базу."
    end
  end

  def print_menu
    puts "\n--- МЕНЕДЖЕР ПРОЄКТІВ ---"
    puts "1. Список усіх проєктів"
    puts "2. Додати новий проєкт"
    puts "3. Редагувати проєкт"
    puts "4. Видалити проєкт"
    puts "5. Пошук за назвою"
    puts "6. Фільтр за статусом"
    puts "7. Фільтр за тегом"
    puts "8. Зберегти вручну в JSON"
    puts "9. Завантажити з JSON"
    puts "0. Вийти"
    print "Оберіть дію: "
  end


  def ask(prompt)
    print prompt
    gets.chomp.strip
  end

  def split_list(str)
    str.split(',').map(&:strip).reject(&:empty?)
  end

  def print_results(results, label)
    if results.empty?
      puts "Проєктів #{label} не знайдено."
    else
      puts "Знайдено #{results.size} проєкт(ів) #{label}:"
      results.each { |id, project| puts "[#{id}] #{project}" }
    end
  end


  def list_projects
    if @manager.collection.empty?
      puts "Список проєктів порожній."
    else
      @manager.collection.each { |id, project| puts "[#{id}] #{project}" }
    end
  end

  def create_project
    title      = ask("Назва: ")
    team       = split_list(ask("Команда (через кому): "))
    tags       = split_list(ask("Теги (через кому): "))
    client     = ask("Клієнт: ")
    start_date = ask("Дата початку (YYYY-MM-DD): ")
    deadline   = ask("Дедлайн (YYYY-MM-DD): ")
    budget     = ask("Бюджет: ").to_f
    status     = ask("Статус (#{VALID_STATUSES.join('/')}): ")
    status     = 'planned' unless VALID_STATUSES.include?(status)

    @manager.add_project(Project.new(title, team, tags, client, start_date, deadline, budget, status))
    puts "Проєкт успішно додано!"
  rescue StandardError => e
    puts "Помилка при створенні: #{e.message}"
  end

  def edit_project
    id      = ask("ID проєкту для редагування: ").to_i
    project = @manager.get_project(id)

    if project.nil?
      puts "Проєкт з ID #{id} не знайдено."
      return
    end

    puts "Редагуємо: #{project}"
    puts "(Залиште поле порожнім — не змінювати)"

    val = ask("Нова назва: ")
    project.title = val unless val.empty?

    val = ask("Новий клієнт: ")
    project.client = val unless val.empty?

    val = ask("Новий статус (#{VALID_STATUSES.join('/')}): ")
    project.status = val if VALID_STATUSES.include?(val)

    val = ask("Новий бюджет: ")
    project.budget = val.to_f unless val.empty?

    val = ask("Нова команда (через кому): ")
    project.team = split_list(val) unless val.empty?

    val = ask("Нові теги (через кому): ")
    project.tags = split_list(val) unless val.empty?

    val = ask("Новий дедлайн (YYYY-MM-DD): ")
    project.deadline = val unless val.empty?

    puts "Проєкт ID=#{id} оновлено."
  end

  def delete_project
    id = ask("ID проєкту для видалення: ").to_i
    if @manager.delete_project(id)
      puts "Проєкт з ID #{id} видалено."
    else
      puts "Проєкт з ID #{id} не знайдено."
    end
  end

  def find_by_title
    query   = ask("Рядок для пошуку за назвою: ")
    results = @manager.find_by_title(query)
    print_results(results, "з назвою '#{query}'")
  end

  def filter_by_status
    status  = ask("Статус (#{VALID_STATUSES.join('/')}): ")
    results = @manager.filter_by_status(status)
    print_results(results, "зі статусом '#{status}'")
  end

  def filter_by_tag
    tag     = ask("Тег: ")
    results = @manager.filter_by_tag(tag)
    print_results(results, "з тегом '#{tag}'")
  end

  def save_to_json_explicit
    @manager.save_to_json
    puts "Дані збережено у projects.json."
  end

  def load_from_json_explicit
    print "Поточні дані будуть замінені. Продовжити? (y/n): "
    return unless gets.chomp.downcase == 'y'

    if @manager.load_from_json
      puts "Дані завантажено з projects.json."
    else
      puts "Файл projects.json не знайдено."
    end
  end
end

App.new.run
