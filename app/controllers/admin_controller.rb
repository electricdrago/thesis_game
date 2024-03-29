class AdminController < ApplicationController
  before_action :user_is_admin

  include AdminHelper

  def user_is_admin
    unless is_admin?
      redirect_to root_url
    end
  end

  def jssp_info
  end


  def makeData
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @steps = prepareData
    @message ="data was prepared, "+@steps.to_s+" steps where prepared"
    render 'data'
  end
  def getData
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    downloadData
    @message ="data was downloaded"
    render 'data'
  end
  def cleanMemory

    cleanData
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @message= "data was deleted"
    render 'data'
  end

  def deleteAll
    cleanData
    deleteFile
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @message= "data was deleted"
    render 'data'
  end


  def email
    send_email
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @message= "email sent"
    render 'data'
  end

  def fullPack
    @steps = prepareData
    p "data was prepared"
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp
    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @message ="data was prepared, "+@steps.to_s+" steps where prepared, sent and deleted, rows where: "+@rows.to_s+" before delete"
    p "data is going to downloas"
    downloadData
    p "data was sent to download"
    deleteFile
    p "data was deleted"
    send_email
    p "mail was sent"
    cleanData
    p "data was cleaned"

    @rows=0
    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    p "about to render"
    render 'data'
  end


  def data
    @rows = 0
    Step
    GamesPlayed
    JsspActivity
    Jssp

    ApplicationRecord.descendants.collect { |type| @rows+=type.count }
    @message = "No message to show"
  end

  def add_problems
  end

  def save_story
    @message = ""
    levels=params[:levels]
    #strength, intelligence, curiosity, organization, construction
    @story = Story.new(strength: levels[0].to_i, intelligence: levels[1].to_i, curiosity: levels[2].to_i, organization: levels[3].to_i, construction: levels[4].to_i)
    if @story.save
      @message+='success'
    else
      @message+='failed'
    end
    params[:dialogs].each{ |k,i|
      @dialog = Dialog.new(storyId: @story.id, order: k.to_i, dialog: i[1], character: i[2], side: i[3])
      if @dialog.save
        @message+='success'
      else
        @message+='failed'
      end
    }
    params[:scenes].each{ |k,i|
      @scene = Scene.new(storyId: @story.id, background: i[0], frame: i[1].to_i, tutorial:i[2])
      if @scene.save
        @message+='success'
      else
        @message+='failed'
      end
    }

    render json: {message: @message, num: 3}
  end

  def save_JSSP

    #Jssp.destroy_all
    #JsspActivity.delete_all
    @message = ""
    @num=0
    #p params
    #p "kjhkjhkjhkjh\n khkjhkjkjkjhkj"
    @answer = GamesPlayed.new(downloaded: 3)
    @answer.save
    maxLevel=Jssp.where(level: params[:level].to_i).count
    mapA = []

    @JSSP = Jssp.new(number_machines: params[:number_machines], time_limit: params[:time_limit], diff_machines:true, machines: params[:machines], level: params[:level], number: maxLevel, answer:@answer.id)
    if @JSSP.save
      @message += "JSSP created "
      job_id = 0


      params[:JSSP].each{ |k,i|
        activity_position = 0
        mapA[job_id]=[]
        i.each{|ky,j|
          @activity = JsspActivity.new(number_job: job_id, idJSSP: @JSSP.id, order: activity_position, time_cost:j[0], machine_type: j[1])
          p mapA, job_id, activity_position

          #@message +="number_job"+ job_id.to_s + "idJSSP"+ @JSSP.id.to_s + "order"+ activity_position.to_s + "time_cost"+j[0].to_s + "machine_type"+ j[1].to_s
          if @activity.save
            @message+="success\n"
            mapA[job_id][activity_position] = @activity.id
          else
            @message+="failed\n"
          end
          activity_position+=1
        }
        job_id+=1
      }
      params[:answer].each{ |k, i|
        @step = Step.new(idGame: @answer.id, number_step: i[0], idActivity: mapA[i[1].to_i][i[2].to_i], number_machine: i[3], position: i[4])
        @step.save
      }

    else
      @message += "problem creating JSSP"
    end

    render json: {message: @message, num: @num}

  end

  def raw_data
    
  end

end
