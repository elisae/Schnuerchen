
def getGameCategories
	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				gt.to_hash
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


def addTrophy(user_id, game_id, score)
	user = User.find(:id => user_id)
	trophies = Trophy.filter(:game_id => game_id).order(:pod)

	trophies.map { |tr|
		puts "Testing Trophy #{tr.pod} (id: #{tr.id})"
		puts "score: #{score} Trophy minscore: #{tr.min_score}"
		if (score >= tr.min_score)
			puts "enough"
			ut = user.trophies_dataset.first(:trophy_id => tr.id)
			unless ut 
				user.add_trophy(tr)
				puts "added Trophy id: #{tr.id}"
			end	
		else
			puts "not enough"
		end
	}
end












