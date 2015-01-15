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

  friend_id = friend_id.to_i

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
				puts "added Trophy #{tr.pod} id: #{tr.id} user: #{user_id}"
			end	
		else
			puts "not enough for Trophy #{tr.pod}"
		end
	}
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

def getFriendScore(user_id,friend_id,game_id)

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









