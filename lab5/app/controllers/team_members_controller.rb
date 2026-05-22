class TeamMembersController < ApplicationController
  before_action :set_project
  before_action :set_team_member, only: %i[edit update destroy]

  def new
    @team_member = TeamMember.new(project_id: @project.id)
  end

  def edit; end

  def create
    @team_member = TeamMember.new(team_member_params.merge(project_id: @project.id))
    if @team_member.save
      redirect_to @project, notice: t('team_members.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @team_member.update(team_member_params)
      redirect_to @project, notice: t('team_members.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @team_member.destroy
    redirect_to @project, notice: t('team_members.destroyed')
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :role)
  end
end
