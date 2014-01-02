#encoding: utf-8
module ApplicationHelper
  def paginator_mini(paginator)
    render :partial => "application/paginator_mini",  :locals => {
      :paginator => paginator
    }
  end

  def operator(mnc)
    case mnc.to_i
    when 0, 2, 7
      "中国移动"
    when 1, 6
      "中国联通"
    when 3, 5
      "中国电信"
    end
  end
end
