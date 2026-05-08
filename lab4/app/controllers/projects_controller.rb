class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.order(created_at: :desc)
  end

  def show; end

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

  # Кастомна дія — активні проєкти, відсортовані за дедлайном
  def in_progress
    @projects = Project.in_progress.order(deadline: :asc)
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  # Strong parameters
  def project_params
    params.require(:project).permit(:title, :category, :main_tag, :client,
                                    :start_date, :deadline, :budget, :status)
  end
end
