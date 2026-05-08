class Project
  attr_accessor :title, :team, :tags, :client, :start_date, :deadline, :budget, :status

  def initialize(title, team, tags, client, start_date, deadline, budget, status = "planned")
    @title = title
    @team = team
    @tags = tags
    @client = client
    @start_date = start_date
    @deadline = deadline
    @budget = budget
    @status = status
  end

  def to_h
    {
      'title' => @title,
      'team' => @team,
      'tags' => @tags,
      'client' => @client,
      'start_date' => @start_date,
      'deadline' => @deadline,
      'budget' => @budget,
      'status' => @status
    }
  end

  def self.from_h(hash)
    new(
      hash['title'],
      hash['team'],
      hash['tags'],
      hash['client'],
      hash['start_date'],
      hash['deadline'],
      hash['budget'],
      hash['status']
    )
  end

  def to_s
    "Проєкт: '#{@title}' | Клієнт: #{@client} | Дедлайн: #{@deadline} | Статус: #{@status}"
  end
end