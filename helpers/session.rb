def login?
	if (session[:u_id] == nil)
		return false
	else
		return session[:u_id]
	end
end