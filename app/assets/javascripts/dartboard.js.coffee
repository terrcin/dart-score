angular.module("dartboard", [])
  .controller "DartboardController",

    class DartboardController
      name: ""
      missId: "dartboard"
      missValue: 0
      highestDouble: 40
      numTurns:  3
      lastScore: 0
      players: []
      currentPlayer: {}

      addPlayer: (name) ->
        player = { name: name, score: 501, turn: [], shots: [], isActive: "" }
        @players.push(player)
        @setCurrentPlayer(player)
        @name = ""

      setCurrentPlayer: (player) ->
        @currentPlayer.isActive = ""
        @currentPlayer = player
        @currentPlayer.isActive = "active"

      dartThrow: (e) =>
        @dartHit(e.target.id) unless !e.target.id

      dartHit: (target=@missId) ->
        @addShotToPlayerTurn(@calculateDartHit(target)) unless _.isEmpty(@currentPlayer)

      calculateDartHit: (target) ->
        if target == @missId
          @updateScore(0)
          @missValue
        else
          # Expects the format s1 or d15
          score = target.slice(1,3) * @scoreMultiplier(target[0])
          @updateScore(score)
          score

      addShotToPlayerTurn: (shot) ->
        @currentPlayer.turn = [] if @currentPlayer.turn.length >= 3
        @currentPlayer.turn.push(shot)

      scoreMultiplier: (type) ->
        switch type
          when "t" then 3 # Triple
          when "d" then 2 # Double
          else 1          # Single

      updateScore: (score) ->
        @currentPlayer.score -= score
        @currentPlayer.shots.push(score)
        @lastScore = score

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

      winItMessage: ->
        if @isBust()
          @bustScore()
          "Bust!"
        else if @hasWon()
          "YEWWWW!"
        else if @isScoreInDoubleRange(@currentPlayer.score)
          if @evenScoreRemaining()
            "Double #{@doubleToWin()} to win" 
          else
            "In winning range"

      bustScore: ->
        @undoLastThrow(false) for n in @currentPlayer.turn
        @currentPlayer.turn = []

      removePlayer: (player) ->
        console.log "Removing #{player}"

      getCurrentPlayerName: ->
        if _.isEmpty(@currentPlayer)
          "Dart Score"
        else
          "#{@currentPlayer.name}'s turn"

      undoLastThrow: (undoTurn=true) ->
        if !_.isEmpty(@currentPlayer) && @currentPlayer.shots.length > 0
          @currentPlayer.score += @currentPlayer.shots.pop()
          @undoLastTurn() if undoTurn
          @lastScore = (@currentPlayer.shots[@currentPlayer.shots.length-1] || 0)

      undoLastTurn: ->
        @currentPlayer.turn.pop()
        if @currentPlayer.turn.length == 0
          @currentPlayer.turn = @lastThreeShots()

      lastThreeShots: ->
        @currentPlayer.shots.slice(@currentPlayer.shots.length-3, @currentPlayer.shots.length)
