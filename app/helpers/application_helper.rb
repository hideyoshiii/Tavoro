module ApplicationHelper

	def default_meta_tags
	    {
	      title: 'TAVORE(タボーレ) | 作品コレクションSNS',
	      reverse: true,
	      charset: 'utf-8',
	      description: 'TAVORE(タボーレ)は映画や本,音楽などの作品を気軽に記録,共有できる場所です',
	      keywords: 'タボーレ,記録,作品',
	      canonical: request.original_url,
	      icon: [
	        { href: image_url('favicon.ico') },
	        { href: image_url('apple-touch-icon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' }
	      ],
	      og: {
	        site_name: 'TAVORE(タボーレ)',
	        title: 'TAVORE(タボーレ) | 作品コレクションSNS',
	      	description: '',
	        type: 'website',
	        url: request.original_url,
	        image: image_url('TAVORE01.jpg'),
	        locale: 'ja_JP'
	      },
	      twitter: {
	      	title: 'TAVORE(タボーレ) | 作品コレクションSNS',
	      	description: '',
	      	image: image_url('TAVORE02.jpg'),
	        card: 'summary_large_image',
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
