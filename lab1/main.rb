require_relative 'project_manager'

projects = {}

puts '=' * 55
puts '  ДОДАВАННЯ ПРОЄКТІВ'
puts '=' * 55

ProjectManager.add_project(projects,
  title:      'Розробка сайту',
  team:       ['Іван Петренко', 'Марія Коваль'],
  tags:       ['Web', 'Ruby', 'Rails'],
  client:     'ТОВ Ромашка',
  start_date: '2024-03-01',
  deadline:   '2024-06-01',
  budget:     50_000.00,
  status:     'in_progress'
)

ProjectManager.add_project(projects,
  title:      'Мобільний додаток',
  team:       ['Олег Сидоренко'],
  tags:       ['Mobile', 'React Native'],
  client:     'ФОП Іваненко',
  start_date: '2024-04-01',
  deadline:   '2024-08-01',
  budget:     30_000.00,
  status:     'planned'
)

ProjectManager.add_project(projects,
  title:      'Корпоративний портал',
  team:       ['Іван Петренко', 'Тетяна Бондар'],
  tags:       ['Web', 'Rails', 'Corporate'],
  client:     'АТ Банк',
  start_date: '2024-05-01',
  deadline:   '2024-12-01',
  budget:     120_000.00,
  status:     'planned'
)

puts "\n#{'=' * 55}"
puts '  УСІ ПРОЄКТИ'
puts '=' * 55
ProjectManager.list_projects(projects)

puts '=' * 55
puts "  ПОШУК за назвою 'сайт'"
puts '=' * 55
ProjectManager.find_by_title(projects, 'сайт')

puts '=' * 55
puts "  ФІЛЬТР за статусом 'planned'"
puts '=' * 55
ProjectManager.filter_by_status(projects, 'planned')

puts '=' * 55
puts "  ФІЛЬТР за тегом 'Rails'"
puts '=' * 55
ProjectManager.filter_by_tag(projects, 'Rails')

puts '=' * 55
puts '  РЕДАГУВАННЯ проєкту ID=1'
puts '=' * 55
ProjectManager.edit_project(projects, 1, status: 'completed', budget: 55_000.00)
ProjectManager.list_projects(projects)

puts '=' * 55
puts '  ВИДАЛЕННЯ проєкту ID=2'
puts '=' * 55
ProjectManager.delete_project(projects, 2)
ProjectManager.list_projects(projects)

puts '=' * 55
puts '  ЗБЕРЕЖЕННЯ ТА ЗАВАНТАЖЕННЯ'
puts '=' * 55
ProjectManager.save_to_json(projects, 'projects.json')
ProjectManager.save_to_yaml(projects, 'projects.yaml')

projects_json = ProjectManager.load_from_json('projects.json')
puts "\n--- Після завантаження з JSON ---"
ProjectManager.list_projects(projects_json)

projects_yaml = ProjectManager.load_from_yaml('projects.yaml')
puts "\n--- Після завантаження з YAML ---"
ProjectManager.list_projects(projects_yaml)

puts '=' * 55
puts '  ОБРОБКА ПОМИЛОК'
puts '=' * 55

ProjectManager.delete_project(projects, 999)
ProjectManager.edit_project(projects, 999, status: 'completed')
ProjectManager.load_from_json('non_existent.json')
ProjectManager.load_from_yaml('non_existent.yaml')

ProjectManager.add_project(projects,
  title: 'Тест', team: [], tags: [], client: 'X',
  start_date: '2024-01-01', deadline: '2024-12-31',
  budget: 0, status: 'wrong_status'
)