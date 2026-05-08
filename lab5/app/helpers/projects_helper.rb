module ProjectsHelper
  def deadline_badge(project)
    return content_tag(:span, 'без дедлайну', class: 'badge bg-secondary') if project.deadline.blank?

    days_left = (project.deadline.to_date - Date.current).to_i

    if days_left.negative?
      content_tag(:span, 'Прострочено', class: 'badge bg-danger')
    elsif days_left <= 7
      content_tag(:span, 'Скоро', class: 'badge bg-warning text-dark')
    else
      content_tag(:span, "через #{days_left} днів", class: 'badge bg-success')
    end
  end

  def status_badge(project)
    css = case project.status
          when 'planned'     then 'badge bg-secondary'
          when 'in_progress' then 'badge bg-primary'
          when 'completed'   then 'badge bg-success'
          when 'cancelled'   then 'badge bg-danger'
          else 'badge bg-light text-dark'
          end
    content_tag(:span, project.status, class: css)
  end
end
