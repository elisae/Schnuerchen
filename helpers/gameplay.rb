def getGameCategories
	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				op_name = op.name
				gr_name = gr.name
				gt_name = gt.name
				game = Game.first(:operator => op_name, :gamerange => gr_name, :gametype => gt_name)
				unless (game == nil) 
					game_id = game.id
				end
				gt.to_hash.merge(:game_id => game_id)
			}
			unless types.any?
				types = nil
			end
			gr.to_hash.merge(:types=>types)
		}
		unless ranges.any?
			ranges = nil
		end
		op.to_hash.merge(:ranges=>ranges)
	}
	return operators
end

=begin
checks if score high enough for trophies, returns:
0: no trophy
1: gold
2: silber
3: bronze
=end
def addTrophy(user_id, game_id, score)
	highest = 0
	user = User.find(:id => user_id)
	trophies = Trophy.filter(:game_id => game_id).order(:pod)

	trophies.map { |tr|
		if (score >= tr.min_score)
			ut = user.trophies_dataset.first(:trophy_id => tr.id)
			unless ut 
				user.add_trophy(tr)
			end	
		else
			highest = tr.pod + 1
		end
	}
	puts "Highest Trophy = #{highest}"
	return highest
end


def getUserTrophies(user_id)
	userTrophies = User.find(:id => user_id).trophies_dataset.to_hash_groups(:game_id, :pod)
	puts "usertrophies: #{userTrophies}"

	return userTrophies
end


def getUserScore(user_id,game_id)
  scores = Score.where{Sequel.&({:user_id => user_id}, {:game_id => game_id})}.select(:score).map{|score|
    score.to_hash
  }
  return scores
end

# returns highest trophy reached (see addTrophy)
def saveScore(user_id, game_id, new_score)
	score = Score.find(:user_id => user_id, :game_id => game_id)
	highscore = new_score
	new_high = true
		
	if (score == nil)
		puts "Neuer score angelegt (first time played)"
		Score.create(:user_id => user_id, 
					:game_id => game_id,
					:timestamp => DateTime.now,
					:score => new_score)
	elsif (score.score <= new_score)
		puts "Score (id: #{score.id} updated)"
		score.set(:timestamp => DateTime.now)
		score.set(:score => new_score)
		score.save
	else
		puts "Kein neuer Highscore"
		highscore = score.score
		new_nigh = false
	end

	result = {
		:pod => addTrophy(user_id, game_id, new_score),
		:new_high => new_high,
		:highscore => highscore
	}
	return result
end










