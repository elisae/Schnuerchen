def login?
	if (session[:u_id] == nil)
		return false
	else
		return session[:u_id]
	end
end

=begin
	returns 
	0 -> not friends
	1 -> user has sent friend request to friend_id
	2 -> friend_id has sent friend request to user
	3 -> friends
=end
def friends?(user_id, friend_id)
	user = User.find(:id => user_id)
	friends_with_ids = user.friends_with.map { |f|
		f.id
	}
	friend_of_ids = user.friend_of.map { |f|
		f.id
	}

		if (friends_with_ids.empty? && friend_of_ids.empty?)
			puts "User #{user_id} doesn't have any friends"
			return 0
		else
			if (friends_with_ids.include?(friend_id))
				if (friend_of_ids.include?(friend_id))
					puts "User #{user_id} is friends with #{friend_id}"
					return 3
				else
					puts "User #{user_id} has sent request to #{friend_id}"
					return 1
				end
			else
				if (friend_of_ids.include?(friend_id))
					puts "friend (User #{friend_id}) has sent request to User #{user_id}"
					return 2
				else
					puts "User #{user_id} isn't friends with #{friend_id}"
					return 0
				end
			end
		end
end

def getGameCategories
	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				puts "Gamecategories"
				op_name = op.name 
				puts op.name
				gr_name = gr.name
				puts gr.name
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

def getFriendsInfo(userId)
  user = User.find(:id => userId)
  if user.friends_with.empty?
    nil
  else
    user.friends_with.map{|user|
      if friends?(userId,user[:id]) == 3
        user.to_hash
      end
    }
  end
end

def getReqsOut(userId)
  user = User.find(:id => userId)
  if user.friends_with.empty?
    nil
  else
    user.friends_with.map{ |user|
      if friends?(userId,user[:id]) == 1
        user.to_hash
      end
    }
  end
end

def getReqsIn(userId)
  user = User.find(:id => userId)
  if user.friend_of.empty?
    nil
  else
    user.friend_of.map{ |user|
      if friends?(userId,user[:id]) == 2
        user.to_hash
      end
    }
  end
end

def addTrophy(user_id, game_id, score)
	user = User.find(:id => user_id)
	trophies = Trophy.filter(:game_id => game_id).order(:pod)

	trophies.map { |tr|
		if (score >= tr.min_score)
			ut = user.trophies_dataset.first(:trophy_id => tr.id)
			unless ut 
				user.add_trophy(tr)
				puts "added Trophy #{tr.pod} id: #{tr.id}"
			end	
		else
			puts "not enough for Trophy #{tr.pod}"
		end
	}
end

def getUserTrophies(user_id)
	userTrophies = User.find(:id => user_id).trophies_dataset.to_hash_groups(:game_id, :pod)
	puts userTrophies
	return userTrophies
end


def saveScore(user_id, game_id, new_score)
	score = Score.find(:user_id => user_id, :game_id => game_id)
		
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
		puts "Goanix"
	end
end











