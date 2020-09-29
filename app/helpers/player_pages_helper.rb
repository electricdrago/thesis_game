module PlayerPagesHelper
  def player_getNextGame
    last_played = current_user.last_Game
    if !last_played || last_played == -1
      player_getNewGame
    else
      game = GamesPlayed.find_by(id: last_played)
      if game && !game.finished
        game
      else
        player_getNewGame
      end
    end
  end

  def player_getNewGame
    points = current_user.points
    if points < 80
      #p "level2"
      jssp = Jssp.find_by(level: 1, number: current_user.last_beginner+1)
      current_user.last_beginner+=(current_user.id%5)
      if !jssp
        current_user.last_beginner=0
        jssp = Jssp.find_by(level: 1, number: 0)
      end
    elsif points < 250
      #p "level2"
      if current_user.last_intermidiate<0
        current_user.last_intermidiate = current_user.id%4
      end
      jssp = Jssp.find_by(level: 2, number: current_user.last_intermidiate)
      current_user.last_intermidiate+=4
      if !jssp

        count = Jssp.where(level:2).count
        if current_user.last_intermidiate>=count
          current_user.last_intermidiate-=count
        end
        if count%2==0
          current_user.last_intermidiate+=1
        end
        if count>0 && current_user.last_intermidiate>count
          current_user.last_intermidiate= current_user.last_intermidiate%count
        end

        jssp = Jssp.find_by(level: 2, number: current_user.last_intermidiate)
      end
      if !jssp
        jssp = Jssp.find_by(level: 2, number: 0)
      end
    else
      #p "level3"
      #p points
      if current_user.last_advanced<0
        current_user.last_advanced = current_user.id%4
      end
      jssp = Jssp.find_by(level: 3, number: current_user.last_advanced)
      current_user.last_advanced+=4
      if !jssp

        count = Jssp.where(level:3).count
        if current_user.last_advanced>=count
          current_user.last_advanced-=count
        end
        if count%2==0
          current_user.last_advanced+=1
        end
        if count>0 && current_user.last_advanced>count
          current_user.last_advanced= current_user.last_advanced%count
        end

        jssp = Jssp.find_by(level: 3, number: current_user.last_advanced)
      end
      if !jssp
        jssp = Jssp.find_by(level: 3, number: 0)
      end
    end
    if !jssp
      jssp = Jssp.first
    end
    game = GamesPlayed.new(idUser: current_user.id, idJSSP: jssp.id, finished: false)
    if game.save
      current_user.last_Game = game.id
      if current_user.save
      end
      game
    end
    game
  end

  def getPlayers(seed=0)

    basic = ["nicubunu_Game_baddie_Basic_guy.png", "nicubunu_Game_baddie_Basic_guy2.png", "nicubunu_Game_baddie_Basic_guy3.png", "nicubunu_Game_baddie_Basic_guy4.png", "nicubunu_Game_baddie_Basic_guy5.png", "nicubunu_Game_baddie_Basic_guy6.png"]
    strength = ["nicubunu_Game_baddie_Warrior.png", "nicubunu_Game_baddie_Ninja.png", "nicubunu_Game_baddie_Camouflage.png"]
    curiosity = ["nicubunu_Game_baddie_Devil.png", "nicubunu_Game_baddie_Billy.png", "nicubunu_Game_baddie_Stripey.png"]
    intelligence = ["nicubunu_Game_baddie_Squared.png", "nicubunu_Game_baddie_.png", "nicubunu_Game_baddie_.png"]
    organization = ["nicubunu_Game_baddie_Sunglasser.png", "nicubunu_Game_baddie_Princess.png", "nicubunu_Game_baddie_Dandy.png"]
    construction = ["nicubunu_Game_baddie_Candy.png", "nicubunu_Game_baddie_Bricky.png", "nicubunu_Game_baddie_Geek.png"]
    final_chars = []
    i = 1
    while i*30 <= current_user.StrengthPoints && i<4
      final_chars.push("/assets/"+strength[i-1])
      i+=1
    end
    i = 1
    while i*30 <= current_user.CuriosityPoints && i<4
      final_chars.push("/assets/"+curiosity[i-1])
      i+=1
    end
    i = 1
    while i*30 <= current_user.IntelligencePoints && i<4
      final_chars.push("/assets/"+intelligence[i-1])
      i+=1
    end
    i = 1
    while i*30 <= current_user.OrganizationPoints && i<4
      final_chars.push("/assets/"+organization[i-1])
      i+=1
    end
    i = 1
    while i*30 <= current_user.ConstructionPoints && i<4
      final_chars.push("/assets/"+construction[i-1])
      i+=1
    end
    i = 0
    while final_chars.length < 5
      final_chars.push("/assets/"+basic[i])
      i+=1
    end
    rng = Random.new(seed)
    final_chars.sample(5, random:rng)

  end

end
