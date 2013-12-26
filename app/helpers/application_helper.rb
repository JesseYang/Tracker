module ApplicationHelper
    def paginator_mini(paginator)
    render :partial => "application/paginator_mini",  :locals => {
      :paginator => paginator
    }
  end
end
