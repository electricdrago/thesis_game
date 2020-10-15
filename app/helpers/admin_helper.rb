module AdminHelper
  require 'zip'

  def prepareData
    #for each game that is not downloaded yet create a zip with that File
    #mark as saved each item saved
    @steps = 0
    jssps = []
    Zip::File.open("public/game_data.zip", Zip::File::CREATE){ |zip|
      GamesPlayed.where(finished: true, downloaded:[0,1]).each do |game|
        #get jssps that where used so we also send their information
        jssps.push(game.idJSSP)
        #will have each step with number_step, idActivity, number_machine, position
        file_text = ""
        #name of file will have JSSP id, user id, points game id
        if !game.end_points
          game.end_points=0
        end
        name_file = game.idJSSP.to_s+"_"+game.idUser.to_s+"_"+game.id.to_s+"_"+(game.end_points*100).floor.to_s+"_"+game.created_at.to_s+"_"+game.updated_at.to_s+".csv"
        steps = Step.where(idGame: game.id).order(:number_step)
        steps.each do |j|
          file_text += j.number_step.to_s + ", " + j.idActivity.to_s + ", " + j.number_machine.to_s + ", " +  j.position.to_s+", "+j.created_at.to_s
          file_text += "\n"
          @steps+=1
        end
        zip.get_output_stream(name_file){|f| f.puts file_text}
        game.downloaded = 1
        game.save
      end
      jssps.each do |j|
        name_file = "JSSP_"+j.to_s+"_info.txt"
        file_text = ""
        activities = JsspActivity.where(idJSSP: j)
        activities.each do |i|
          file_text+= i.id.to_s+", "+i.number_job.to_s+", "+i.order.to_s+", "+i.time_cost.to_s+", "+i.machine_type.to_s
          file_text += "\n"
        end
        zip.get_output_stream(name_file){|f| f.puts file_text}
      end

    }
    @steps


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
      end
    end

  end

  def deleteFile
    File.delete("public/game_data.zip") if File.exist?("public/game_data.zip")
  end

  def send_email
    require 'net/smtp'

    filename = "public/game_data.zip"
    file_content = open(filename).read
    encoded_content = [file_content].pack("m")   # base64
    files = GamesPlayed.where(downloaded: 1).count.to_s
    marker = "AUNIQUEMARKER"

    part1 = <<-END_OF_MESSAGE
From: JSSP-step-sender <mailsender575@gmail.com>
To: Admin <martinense96@gmail.com>
Subject: Sending #{files} games
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary = #{marker}
--#{marker}
END_OF_MESSAGE


    part2 = <<-END_OF_MESSAGE
Content-Type: text/html
Content-Transfer-Encoding:8bit


<strong>This is an email sent with JSSP information</strong>
<h1>The amounts of games this zip contains is #{files}</h1>
--#{marker}
END_OF_MESSAGE

    part3 = <<-END_OF_MESSAGE
Content-Type: multipart/mixed; name = "#{filename}"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename = "#{filename}"

#{encoded_content}
--#{marker}--
END_OF_MESSAGE

    message = part1 + part2 + part3

    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('smtp.gmail.com', 'mailsender575@gmail.com', 'Mailsender#575', :login) do
      smtp.send_message(message, 'mailsender575@gmail.com', 'martinense96@gmail.com')
    end

  end

end
