Rails.application.routes.draw do
  resources :categories

  # Кастомні маршрути ДО resources — інакше Rails матчить їх як :id
  get 'projects/in_progress',    to: 'projects#in_progress',    as: :in_progress_projects
  get 'projects/deadline_soon',  to: 'projects#deadline_soon',  as: :deadline_soon_projects

  resources :projects do
    # Вкладений ресурс: /projects/:project_id/team_members/...
    resources :team_members, except: %i[index show]
  end

  root 'projects#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
