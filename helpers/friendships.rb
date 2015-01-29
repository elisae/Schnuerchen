=begin
	returns 
	0 -> not friends
	1 -> user has sent friend request to friend_id
	2 -> friend_id has sent friend request to user
	3 -> friends
=end
def friends?(user_id, friend_id)

  friend_id = friend_id.to_i

	user = User.find(:id => user_id)
	friends_with_ids = user.friends_with.map { |f|
		f.id
	}
	friend_of_ids = user.friend_of.map { |f|
		f.id
	}
	if (friends_with_ids.empty? && friend_of_ids.empty?)
		return 0
	else
		if (friends_with_ids.include?(friend_id))
			if (friend_of_ids.include?(friend_id))
				return 3
			else
				return 1
			end
		else
			if (friend_of_ids.include?(friend_id))
				return 2
			else
				return 0
			end
		end
	end
end

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

def getFriendsInfo(user_id)
  user = User.find(:id => user_id)
  if user.friends_with.empty?
    nil
  else
    user.friends_with.map{|friend|
      if friends?(user_id,friend[:id]) == 3
        friend.to_hash
      end
    }
  end
end

def getReqsOut(user_id)
  user = User.find(:id => user_id)
  if user.friends_with.empty?
    nil
  else
    user.friends_with.map{ |friend|
      if friends?(user_id,friend[:id]) == 1
        friend.to_hash
      end
    }
  end
end

def getReqsIn(user_id)
  user = User.find(:id => user_id)
  if user.friend_of.empty?
    nil
  else
    user.friend_of.map{ |friend|
      if friends?(user_id,friend[:id]) == 2
        friend.to_hash
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
				puts "added Trophy #{tr.pod} id: #{tr.id} user: #{user_id}"
			end	
		else
			puts "not enough for Trophy #{tr.pod}"
		end
	}
end

# Holt die eigene Score für das jeweilige Spiel aus der Datenbank und speichert sie in einem Array.
def getUserScore(user_id,game_id)
  scoreArr = Array.new
  Score.where{Sequel.&({:user_id => user_id}, {:game_id => game_id})}.select(:score).map{|score|
    scoreArr.push(score.to_hash)
  }
  scoreArr
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

def addFriend(user_id, friend_id)
	Friendship.find_or_create(:friends_with_id => user_id,:friend_of_id=> friend_id)
end


def delFriend(user_id,friend_id)
  if friends?(user_id,friend_id) == 1
    Friendship.where(:friends_with_id => user_id, :friend_of_id => friend_id).delete
  elsif friends?(user_id,friend_id) == 2
    Friendship.where(:friends_with_id => friend_id, :friend_of_id => user_id).delete
  elsif friends?(user_id,friend_id) == 3
    Friendship.where(:friends_with_id => user_id, :friend_of_id => friend_id).delete
    Friendship.where(:friends_with_id => friend_id, :friend_of_id => user_id).delete
  else
    0
    end
end


############## Media Night ################

def everyoneonthemedianightisourfriend(user_id)
  we = User.where(:username => ["kenny","manuel","elisa231","Wambo787"])
  we.map{|friend|
    friend.to_hash
    puts friend.to_hash
    addFriend(user_id,friend[:id])
    addFriend(friend[:id],user_id)
  }
end
