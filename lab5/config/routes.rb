Rails.application.routes.draw do
  resources :categories

  get 'projects/in_progress',    to: 'projects#in_progress',    as: :in_progress_projects
  get 'projects/deadline_soon',  to: 'projects#deadline_soon',  as: :deadline_soon_projects

  resources :projects do
    resources :team_members, except: %i[index show]
  end

  root 'projects#index'


  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

end
