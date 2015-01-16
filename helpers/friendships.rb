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