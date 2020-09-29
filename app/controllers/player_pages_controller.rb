class PlayerPagesController < ApplicationController
  before_action :user_is_login
  def user_is_login
    unless logged_in?
      redirect_to root_url
    end
  end

  def Jssp_game
    @lala = true
    @Game = player_getNextGame
    @idGame = @Game.id
    @JSSP = Jssp.find_by(id: @Game.idJSSP)
    @aliens = getPlayers(@idGame)
    #@JSSP = Jssp.find_by(id: 16)

    #n_machines (Number of machines that this problem has)
    #machine_type (string with the type of each string, assume that maximum type id = 9)
    #JSSA (each activity, includes [#job, position, time_cost,id activity, machine_type])
    #@idGame = 0
    @n_machines = @JSSP.number_machines
    @machine_type = @JSSP.machines
    @maxTime = @JSSP.time_limit
    @JSSA = []
    activities = JsspActivity.where(idJSSP: @JSSP.id)

    activities.each do |i|
      @JSSA.push([i.number_job, i.order, i.time_cost, i.id, i.machine_type])
    end
    steps = Step.where(idGame: @idGame).order(:number_step)
    @steps = []
    steps.each do |j|
      @steps.push([j.idActivity, j.number_machine, j.position])
    end
  end

  def save_step
    @message = ""
    params = account_params
    step = Step.new(params)
    if step.save
      @message +="step saved"
    else
      @message += "step saving failed"
    end
    render json: {message: @message, num: @num}
  end

  def end_game
    params = end_params
    game = GamesPlayed.find_by(id: params[:idGame])
    points = [1, params[:points].to_f].min

    if game.finished
      a=2
    else
      #sum_g(sum_i(n^j))  max points on g games
      game.end_points = points

      if points>=0.85
        n = 10
        points = points*(n + (current_user.points*0.1))
        current_user.points+=points
      end

      game.finished = true

      if current_user.save

      end
      if game.save
      end
    end
    #redirect_to 'shop'

    redirect_to '/answer/'+params[:idGame]
  end

  def restart_game
    params = restart_params
    new_game = GamesPlayed.new(params)
    if new_game.save
      current_user.last_Game = new_game.id
      if current_user.save
      end
    end
    redirect_to '/activity_assignment'
  end

  def readStory
    if !current_user.stories
      current_user.stories = "0"
    end
    if current_user.stories.length<=params[:storyId].to_i
      current_user.stories+="0"*(params[:storyId].to_i+1-current_user.stories.length)
    end

    current_user.stories[params[:storyId].to_i] = "1"

    if current_user.save
    end

    redirect_to '/activity_assignment'
  end

  def shop
    #get specifiv points with <%= current_user.specificPoints%>
    spentPoints = current_user.StrengthPoints+current_user.IntelligencePoints+
      current_user.CuriosityPoints+ current_user.OrganizationPoints+ current_user.ConstructionPoints

    @items = [["Strength",current_user.StrengthPoints,current_user.StrengthPoints],["Intelligence",current_user.IntelligencePoints,current_user.IntelligencePoints],
      ["Curiosity",current_user.CuriosityPoints,current_user.CuriosityPoints],["Organization",current_user.OrganizationPoints,current_user.OrganizationPoints],
      ["Construction",current_user.ConstructionPoints,current_user.ConstructionPoints]]
    @extra_points = current_user.points-spentPoints
    if @extra_points<10
      redirect_to '/story'
    end
  end

  def addPoints
    #count that added points equal to total points
    params = points_params

    extra_points = params[:StrengthPoints].to_i
    previous_points = current_user.StrengthPoints
    current_user.StrengthPoints+= params[:StrengthPoints].to_i

    extra_points += params[:IntelligencePoints].to_i
    previous_points+= current_user.IntelligencePoints
    current_user.IntelligencePoints+=params[:IntelligencePoints].to_i

    extra_points += params[:CuriosityPoints].to_i
    previous_points+= current_user.CuriosityPoints
    current_user.CuriosityPoints+=params[:CuriosityPoints].to_i

    extra_points += params[:OrganizationPoints].to_i
    previous_points+= current_user.OrganizationPoints
    current_user.OrganizationPoints+=params[:OrganizationPoints].to_i

    extra_points += params[:ConstructionPoints].to_i
    previous_points+= current_user.ConstructionPoints
    current_user.ConstructionPoints+=params[:ConstructionPoints].to_i


    if previous_points+extra_points>current_user.points

    else
      if current_user.save
      end
    end

    redirect_to '/story'
  end

  def history
    #Get unlocked stories from points
    #Check which stories had not been seen
    #Mark story as read when starting game

    story_map=[[0,0,0,0,0, "intro.js"], [30,0,0,0,0,"strength1.js"], [60,0,0,0,0,"strength2.js"], [90,0,0,0,0,"strength3.js"],
    [0,30,0,0,0,"intelligence1.js"], [200,60,0,0,0,"intelligence2.js"], [200,90,0,0,0,"intelligence3.js"],
    [0,0,30,0,0,"curiosity1.js"], [0,0,60,0,0,"curiosity2.js"], [0,0,90,0,0,"curiosity3.js"],
    [0,0,0,30,0,"organization1.js"],[0,0,0,60,0,"organization2.js"],[0,0,0,90,0,"organization3.js"],
    [0,0,0,0,30,"construcction1.js"], [0,0,0,60,0,"construcction2.js"], [0,0,0,0,90,"construcction3.js"]]
    l = story_map.length
    if !current_user.stories
      current_user.stories = "0"
    end
    if current_user.stories.length < l
      current_user.stories += "0"*(l-current_user.stories.length)
      current_user.save
    end
    st = 0
    @st = 0
    while st<l do
      if current_user.stories[st] != "1" && story_map[st][0]<=current_user.StrengthPoints &&
        story_map[st][1]<=current_user.IntelligencePoints && story_map[st][2]<= current_user.CuriosityPoints &&
        story_map[st][3]<= current_user.OrganizationPoints && story_map[st][4]<= current_user.ConstructionPoints

        @story = story_map[st][5]
        @st = st
        break
      end
      st+=1
    end
    @story = @story || "neutral.js"


  end

  def answer
    @idGame = params[:id].to_i
    @aliens = getPlayers(@idGame)
    @Game = GamesPlayed.find_by(id: @idGame)
    @points = (@Game.end_points*100).to_i
    if @Game && @Game.finished && @Game.idUser == current_user.id
      @JSSP = Jssp.find_by(id: @Game.idJSSP)
      #@JSSP = Jssp.find_by(id: 16)

      #n_machines (Number of machines that this problem has)
      #machine_type (string with the type of each string, assume that maximum type id = 9)
      #JSSA (each activity, includes [#job, position, time_cost,id activity, machine_type])
      #@idGame = 0
      @n_machines = @JSSP.number_machines
      @machine_type = @JSSP.machines
      @maxTime = @JSSP.time_limit
      @JSSA = []
      activities = JsspActivity.where(idJSSP: @JSSP.id)

      activities.each do |i|
        @JSSA.push([i.number_job, i.order, i.time_cost, i.id, i.machine_type])
      end
      steps = Step.where(idGame: @idGame).order(:number_step)
      @steps = []
      steps.each do |j|
        @steps.push([j.idActivity, j.number_machine, j.position])
      end
      @answer = @JSSP.answer
      steps = Step.where(idGame: @answer).order(:number_step)
      @stepsA = []
      steps.each do |j|
        @stepsA.push([j.idActivity, j.number_machine, j.position])
      end
    else
      redirect_to '\shop'
    end
  end



  private
    def account_params
      params.permit(:idGame, :number_step, :idActivity, :number_machine, :position)
    end
    def end_params
      params.permit(:idGame, :points)
    end
    def restart_params
      params.permit(:idUser, :idJSSP)
    end
    def points_params
      params.permit(:StrengthPoints, :IntelligencePoints, :CuriosityPoints, :OrganizationPoints, :ConstructionPoints)
    end
end
