angular.module("dartboard", [])
  .service "gameService",

    class GameService

      missIds: ["dartboard", "score_1_", "miss"]
      missValue: 0
      highestDouble: 40
      numTurns:  3
      winMessages: ["YEWWWW!", "You've won!", ":)"]

      name: ""
      lastScore: 0
      players: []
      currentPlayer: {}

      addPlayer: (name) ->
        player = { name: name, score: 501, turn: [], turns: [], isActive: "" }
        @players.push(player)
        @setCurrentPlayer(player)

      setCurrentPlayer: (player) ->
        @completeTurn()
        @currentPlayer.isActive = ""
        @currentPlayer = player
        @currentPlayer.isActive = "active"

      getNextPlayer: () ->
        if @players.indexOf(@currentPlayer) < (@players.length-1)
          @players[@players.indexOf(@currentPlayer)+1]
        else
          @players[0]

      hasCurrentPlayer: ->
        !_.isEmpty(@currentPlayer)

      currentPlayerName: ->
        @currentPlayer.name || []

      currentPlayerTurn: ->
        @currentPlayer.turn || []

      dartHit: (target) ->
        if @currentPlayer.turn.length < @numTurns
          @addShotToPlayerTurn(@calculateDartHit(target)) if @hasCurrentPlayer()

      calculateDartHit: (target="miss") ->
        if target in @missIds
          @updateScore(0)
          @missValue
        else
          # Expects the format s1 or d15
          score = target.slice(1,3) * @scoreMultiplier(target[0])
          @updateScore(score)
          score

      scoreMultiplier: (type) ->
        switch type
          when "t" then 3 # Triple
          when "d" then 2 # Double
          else 1          # Single

      updateScore: (score) ->
        @currentPlayer.score -= score
        @lastScore = score

      addShotToPlayerTurn: (shot) ->
        @currentPlayer.turn.push(shot)

      completeTurn: () ->
        if @hasCurrentPlayer() && @currentPlayer.turn.length > 0
          @currentPlayer.turns.push(@currentPlayer.turn.concat([@missValue, @missValue, @missValue]).slice(0,3))
          @currentPlayer.turn = []

      winItMessage: ->
        if @isBust()
          @bustScore()
          "Bust!"
        else if @hasWon()
          @winMessage()
        else if @isScoreInDoubleRange(@currentPlayer.score)
          if @evenScoreRemaining()
            "Double #{@doubleToWin()} to win"
          else
            "In winning range"

      winMessage: ->
        randomIndex = Math.floor(Math.random() * (@winMessages.length))
        @winMessages[randomIndex]

      bustScore: ->
        @undoLastThrow(false) for n in @currentPlayer.turn
        @currentPlayer.turn = []

      isBust: ->
        @currentPlayer.score < 0 || @currentPlayer.score == 1

      hasWon: ->
        @currentPlayer.score == 0

      isScoreInDoubleRange: (score) ->
        score <= @highestDouble

      evenScoreRemaining: ->
        @currentPlayer.score % 2 == 0

      doubleToWin: ->
        @currentPlayer.score / 2

      undoLastThrow: (undoTurn=true) ->
        if @hasCurrentPlayer()

          if @currentPlayer.turn.length > 0
            @currentPlayer.score += @currentPlayer.turn.pop()
          else if undoTurn
            @currentPlayer.turn = @currentPlayer.turns.pop()

          @lastScore = _(@currentPlayer.turns.concat(@currentPlayer.turn)).chain().flatten().last().value() || 0
