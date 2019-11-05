# frozen_string_literal: true

class HellosController < ApplicationController
  before_action :set_hello, only: %i[show update destroy]

  # GET /hellos
  def index
    # @hellos = Hello.all
    # HardWorker.new.perform("redis",10)
    HardWorker.perform_async('redis', 10)
    # HardWorker.perform_in(1.minute, 'redis', 10)
    render json: { status: 200 }
  end

  # GET /hellos/1
  def show
    jobs = Sidekiq::Cron::Job.all
    render json: { status: 200, jobs: jobs }
  end

  # POST /hellos
  def create
    @hello = Hello.new(hello_params)

    if @hello.save
      render json: @hello, status: :created, location: @hello
    else
      render json: @hello.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /hellos/1
  def update
    if @hello.update(hello_params)
      render json: @hello
    else
      render json: @hello.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hellos/1
  def destroy
    @hello.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_hello
    # @hello = Hello.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def hello_params
    params.require(:hello).permit(:index)
  end
end
