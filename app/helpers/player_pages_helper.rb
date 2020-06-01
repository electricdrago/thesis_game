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
    if points < 50
      jssp = Jssp.find_by(level: 1, number: current_user.last_beginner+1)
      current_user.last_beginner+=1
      if !jssp
        current_user.last_beginner=0
        jssp = Jssp.find_by(level: 1, number: 0)
      end
    elsif points < 100
      jssp = Jssp.find_by(level: 1, number: current_user.last_intermidiate+1)
      current_user.last_intermidiate+=1
      if !jssp
        current_user.last_intermidiate=0
        jssp = Jssp.find_by(level: 1, number: 0)
      end
    else
      jssp = Jssp.find_by(level: 2, number: current_user.last_advanced+1)
      current_user.last_advanced+=1
      if !jssp
        current_user.last_advanced=0
        jssp = Jssp.find_by(level: 2, number: 0)
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

end
