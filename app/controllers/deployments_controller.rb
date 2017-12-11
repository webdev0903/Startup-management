class DeploymentsController < ApplicationController

  protect_from_forgery with: :null_session

  before_filter :check_branch
  

  def deploy    
    payload = params
    output = ''
    if payload['ref'] == 'refs/heads/master'
      output = `mina deploy to=production &`
    elsif payload['ref'] == 'refs/heads/dev'
      output = `mina deploy &`
    end
    
    logger.info { output }
    DeploymentMailer.status(output).deliver
    render :json => {:flag => :success, :status => :deployed}.to_json, :status => 200
  end

  private

    def check_branch
      # if params[:payload].blank?
      # logger.info params

      if params.blank?
        render :json => {:flag => :no_payload, :status => :ignored}.to_json, :status => 200
        return
      end
      # payload = JSON.parse(params[:payload])
      payload = params
      if payload['ref'] != 'refs/heads/master' && payload['ref'] != 'refs/heads/dev'
        render :json => {:flag => :not_master, :status => :ignored}.to_json, :status => 200
        return
      end
    end
  
end