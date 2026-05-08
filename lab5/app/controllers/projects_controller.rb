class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.order(created_at: :desc)
  end

  def show
    # Учасники команди цього проєкту для відображення на сторінці show
    @team_members = TeamMember.where(project_id: @project.id).order(:name)
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: t('projects.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t('projects.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: t('projects.destroyed')
  end

  # Активні проєкти — використовує scope :active з моделі
  def in_progress
    @projects = Project.active.order(deadline: :asc)
  end

  # Кастомна сторінка — проєкти з дедлайном у наступні 7 днів (scope :deadline_soon)
  def deadline_soon
    @projects = Project.deadline_soon.order(deadline: :asc)
  end

  # ─── Демонстраційні запити (Active Record queries) ───────────────────────────

  # Активні проєкти відсортовані за дедлайном (where + order)
  def active_sorted
    @projects = Project.where(status: :in_progress).order(deadline: :asc)
    render :index
  end

  # Три найближчі до дедлайну проєкти (limit)
  def nearest_deadlines
    @projects = Project.where.not(deadline: nil).order(deadline: :asc).limit(3)
    render :index
  end

  # Завершені проєкти (where по enum)
  def completed_projects
    @projects = Project.done.order(deadline: :desc)
    render :index
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  # Strong parameters — додано :description
  def project_params
    params.require(:project).permit(:title, :description, :category, :main_tag,
                                    :client, :start_date, :deadline, :budget, :status)
  end
end
