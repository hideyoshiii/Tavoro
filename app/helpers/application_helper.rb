module ApplicationHelper

	def default_meta_tags
	    {
	      site: 'TAVORE(タボーレ)',
	      title: 'TAVORE(タボーレ)',
	      reverse: true,
	      charset: 'utf-8',
	      description: 'よりシンプルなコレクションSNS',
	      keywords: 'コレクション, 記録, SNS',
	      canonical: 'https://www.tavore.net',
	      separator: '|',
	      icon: [
	        { href: image_url('favicon.ico') },
	        { href: image_url('apple-touch-icon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' }
	      ],
	      og: {
	        site_name: 'TAVORE(タボーレ)',
	        title: 'TAVORE(タボーレ)',
	        description: 'よりシンプルなコレクションSNS',
	        type: 'website',
	        url: 'https://www.tavore.net',
	        image: image_url('TAVORE.jpg'),
	        locale: 'ja_JP'
	      },
	      twitter: {
	        card: 'summary_large_image',
	        site: '@tavore_info',
	        title: 'TAVORE(タボーレ)',
	        description: 'よりシンプルなコレクションSNS',
	        type: 'website',
	        url: 'https://www.tavore.net',
	        image: image_url('TAVORE.jpg')
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
