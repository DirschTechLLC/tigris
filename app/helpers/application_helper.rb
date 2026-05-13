module ApplicationHelper
  def nav_link_to(label, path)
    active = current_page?(path)
    classes = "flex items-center px-3 py-2 rounded-md text-sm font-medium transition-colors"
    classes += active ? " bg-muted text-foreground" : " text-muted-foreground hover:text-foreground hover:bg-muted"
    link_to label, path, class: classes
  end
end
