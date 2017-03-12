class YoutubeHandlersController < ApplicationController

  require 'json'
  include HTTParty

  helper_method :led


  def led

    @youtube_handler = YoutubeHandler.find(params[:id])

    key = ENV["youtube_key"]

    stream_id = 'o8no-xwBmzY'

    #broadcast = HTTParty.get("https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet&id=#{stream_id}&key=#{key}")

    #render json: broadcast.body

    chat_id = 'Cg0KC284bm8teHdCbXpZ'


    response = HTTParty.get("https://www.googleapis.com/youtube/v3/liveChat/messages?liveChatId=#{chat_id}&part=id%2C+snippet%2C+authorDetails&key=#{key}")

    code = response.code


    if code == 200

      pingLed('reset')

      msgArray = []
      lastReadMsgId = ''
      returnValue = 0;

      #Keep pinging here in a loop
      while returnValue != 100

        #ping youtube
        response = HTTParty.get("https://www.googleapis.com/youtube/v3/liveChat/messages?liveChatId=#{chat_id}&part=id%2C+snippet%2C+authorDetails&key=#{key}")

        json = JSON.parse(response.body)

        #check if last message has the same id as previous message

        # for i in 0..(json['items'].length-1)
        #   msgNum = json['items'].length
        #   decrementNum = msgNum - i
          # msg = json['items'][decrementNum-1]

          msg = json['items'].last
          if  msg['id'] == lastReadMsgId || lastReadMsgId == ''
            lastReadMsgId = json['items'].last['id']
            #render json: lastReadMsgId


          else
            #msgArray.push({id:msg['id'],displayName:msg['displayName'],msg:msg['snippet']['textMessageDetails']['messageText']})

            #ping LED
            response = pingLed(msg['snippet']['textMessageDetails']['messageText'])

            lastReadMsgId = json['items'].last['id']


            if response['return_value'] == 100
              pingLed('wincode111') #wincode111 = win funtion on proton
            end

            returnValue = response['return_value']

          #end#for loop

        end #while end

      end


    else

      flash[:alert] = "Error loading broadcast. Make sure you're currently Live."
      redirect_to @youtube_handler

    end


  end

  def pingLed(arg)

     accessToken = ENV["proton_access_token"]

     deviceID = ENV["proton_device_ID"]

     url = "https://api.spark.io/v1/devices/#{deviceID}/action";

    response = HTTParty.post(url,
    :body => { :params => arg,
               #:access_token => accessToken
             }.to_json,
    :headers => { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{accessToken}" } )

    return response.body

  end

  def index
  @youtube_handlers = YoutubeHandler.all
  end


  def show
    @youtube_handler = YoutubeHandler.find(params[:id])
  end

  def benefits
    @youtube_handler = YoutubeHandler.find(params[:youtube_handler_id])
  end

  def new
    @youtube_handler = YoutubeHandler.new
  end

  def create
    @youtube_handler = YoutubeHandler.new(youtube_handler_params)

    if @youtube_handler.save
      redirect_to @youtube_handler, notice: "Your event was created successfully."
    else
      flash.now[:alert] = "Error creating your event. Please try again"
      render :new
    end
  end

  def edit
    @youtube_handler = YoutubeHandler.find(params[:id])
  end

  def update
    @youtube_handler = YoutubeHandler.find(params[:id])

    @youtube_handler.assign_attributes(youtube_handler_params)

    if @youtube_handler.save
      flash[:notice] = "Event was updated."
       redirect_to dashboard
     else
       flash.now[:alert] = "Error saving event. Please try again."
       render :edit
     end
   end

   def destroy
     @youtube_handler = YoutubeHandler.find(params[:id])

     if @youtube_handler.destroy
       flash[:notice] = "\"#{@youtube_handler.name}\" was deleted successfully."
      redirect_to action: :index
    else
      flash.now[:alert] = "There was an error deleting the event."
      render :show
    end
  end

  private

  def youtube_handler_params
    params.require(:youtube_handler).permit(:chat_id, :name, :script)
  end





end
