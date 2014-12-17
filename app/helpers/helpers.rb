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

end


def getGameCategories
	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				op_name = op.name
				gr_name = gr.name
				gt_name = gt.name
				game_id = Game.first(:operator => op_name, :gamerange => gr_name, :gametype => gt_name).id
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

def getFriendsInfo
  friendinfo = Array.new

  friends = Array.new
  friendsArr = Array.new
  friendsAddedArr = Array.new
  friendRequestsArr = Array.new

  Friend.where(:user_id=>params[:u_id]).or(:friend_id=>params[:u_id]).map{|friend|
    friend.to_hash
    friends.push(friend)
  }
  puts friends

=begin
  friends = Friend.where(:user_id=>params[:u_id]).or(:friend_id=>params[:u_id]).sql.all.map{ |friend|
    friend.to_hash
    puts friend.to_hash
    friendinfo.push(User.where(:id=>friend[:friend_id]).select(:id,:username).map{ |info|
      info.to_hash
    })
  }
=end
  return friendinfo
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











