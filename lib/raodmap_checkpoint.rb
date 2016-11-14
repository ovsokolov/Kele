module RoadMapAndCheckPoint
  def get_roadmap(roadmap_id)
    url = "/roadmaps/#{roadmap_id}"
    result = self.class.get(url, headers: { "authorization" => @auth_token }, :body => {"id" => roadmap_id})
    @roadmap = JSON.parse(result.body)
  end

  def get_checkpoint(checkpoint_id)
    raise BlocIoError, "Load RoadMap first" if @roadmap.nil?
    @checkpoints = Hash.new
    sections = @roadmap["sections"]
    sections.each do |section|
      checkpoints = section["checkpoints"]
      checkpoints.each do |checkpoint|
        @checkpoints[checkpoint["id"]] = checkpoint if checkpoint["id"] == checkpoint_id
      end
    end
    raise BlocIoError, "CheckPoint not found" unless @checkpoints.length > 0
    @checkpoints
  end
end
