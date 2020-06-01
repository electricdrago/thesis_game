class ExtraPagesController < ApplicationController
  def temp_game
    
    @JSSP = Jssp.find_by(id: 16)

    #n_machines (Number of machines that this problem has)
    #machine_type (string with the type of each string, assume that maximum type id = 9)
    #JSSA (each activity, includes [#job, position, time_cost,id activity, machine_type])
    @JSSA = [[0,0,32,0,0],[0,1,12,1,1],[1,0,10,2,0],[0,2,20,3,2],[1,1,15,4,1],[1,2,25,5,2],[2,0,25,6,0]]
    @idGame = 0
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
end
