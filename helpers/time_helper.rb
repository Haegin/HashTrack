module TimeHelper
  def relative_time(time)
    %(
      <time class="timeago" datetime="#{time.getutc.iso8601}">
        #{time.strftime("%H:%M on %-d %b %y")}
      </time>
    )
  end
end
