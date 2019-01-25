module ApplicationHelper

	def default_meta_tags
	    {
	      title: 'TAVORE(タボーレ)',
	      reverse: true,
	      charset: 'utf-8',
	      description: '映画､本､音楽､すべてこの場所に',
	      keywords: 'コレクション, 記録, SNS',
	      canonical: request.original_url,
	      icon: [
	        { href: image_url('favicon.ico') },
	        { href: image_url('apple-touch-icon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' }
	      ],
	      og: {
	        site_name: 'TAVORE(タボーレ)',
	        title: 'TAVORE(タボーレ)',
	        description: '映画､本､音楽､すべてこの場所に',
	        type: 'website',
	        url: request.original_url,
	        image: image_url('TAVORE.jpg'),
	        locale: 'ja_JP'
	      },
	      twitter: {
	        card: 'summary',
	        site: '@tavore_info',
	      }
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
