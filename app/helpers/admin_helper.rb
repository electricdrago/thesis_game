module AdminHelper
  require 'zip'

  def prepareData
    #for each game that is not downloaded yet create a zip with that File
    #mark as saved each item saved
    Zip::File.open("public/game_data.zip", Zip::File::CREATE){ |zip|
      GamesPlayed.where(finished: true, downloaded:[0,1]).each do |game|
        #will have each step with number_step, idActivity, number_machine, position
        file_text = ""
        #name of file will have JSSP id, user id, points game id
        if !game.end_points
          game.end_points=0
        end
        name_file = game.idJSSP.to_s+"_"+game.idUser.to_s+"_"+game.id.to_s+"_"+(game.end_points*100).floor.to_s+".csv"
        steps = Step.where(idGame: game.id).order(:number_step)
        steps.each do |j|
          file_text += j.number_step.to_s + ", " + j.idActivity.to_s + ", " + j.number_machine.to_s + ", " +  j.position.to_s
          file_text += "\n"
        end
        zip.get_output_stream(name_file){|f| f.puts file_text}
        game.downloaded = 1
        game.save
      end
    }

  end

  def downloadData
    #Get the zip and send it
    #Mark saved data as downloaded
    GamesPlayed.where(downloaded: 1).update_all(downloaded: 2)
    send_file "public/game_data.zip", :type=>"application/zip"
  end

  def cleanData
    #Delete all games and their steps if these are not the last game from player and are already downloaded
    #Delete the zip file
    games = GamesPlayed.where(downloaded: 2)
    games.each do |game|
      if !(User.find(game.idUser).last_Game == game.id)
        Step.where(idGame: game.id).destroy_all
        game.destroy
      else
        p User.find(game.idUser).last_Game
        p game.id
      end
    end
    File.delete("public/game_data.zip")
  end

end
