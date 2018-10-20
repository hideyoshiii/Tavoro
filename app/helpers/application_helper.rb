module ApplicationHelper

	def default_meta_tags
	    {
	      site: 'TAVORE(タボーレ)',
	      title: 'list the works you read, watched, listened, others',
	      reverse: true,
	      charset: 'utf-8',
	      description: '',
	      keywords: '記録, 映画, 本',
	      canonical: 'https://tavore.herokuapp.com',
	      separator: '|',
	      icon: [
	        { href: image_url('favicon.ico') },
	        { href: image_url('apple-touch-icon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' }
	      ],
	    }
	  end

	def resource_name
    	:user
	end

	def resource
	    @resource ||= User.new
	end

	def devise_mapping
	   	@devise_mapping ||= Devise.mappings[:user]
	end

	def current_user?(user)
    	user == current_user
  	end
  	
end
