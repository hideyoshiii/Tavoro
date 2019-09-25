module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?
 
    html = ""
    messages = resource.errors.full_messages.each do |errmsg|
      html += <<-EOF
      <div class="alert" role="alert" style="background:rgba(5,98,123,1);color:rgba(250,250,250,1);">
       	<div class="inline_block_middle" style="width:80%;">
       		<div style="font-size:14px;">
      			#{errmsg}
      		</div>
      	</div>
      	<div class="inline_block_middle" style="width:20%;text-align:right;">
	        <button type="button" data-dismiss="alert" style="width:auto;height:auto;padding:0;margin:0;">
	          <img src="/assets/cross_FAFAFA.svg" style="width:14px;height:14px;">
	        </button>
        </div>
      </div>
      EOF
    end
    html.html_safe
  end
 
  def devise_error_messages?
    resource.errors.empty? ? false : true
  end
 
end