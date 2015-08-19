module RequestCount
  def requests_open_count
    requests(open:true).count
  end

  def requests_closed_count
    requests(open:false).count
  end

  private

  def requests(args={})
    Request.where options.merge!(args)
  end

  def options(args={})
    args.merge!({ team:filter })     if filter.is_a?(Team)
    args.merge!({ agent:filter })    if filter.is_a?(Agent)
    args.merge!({ customer:filter }) if filter.is_a?(Customer)
    args
  end
  
  def filter
    self
  end
end