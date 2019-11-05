class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    # sleep(count)
    pp '########################'
    pp "hello #{name},#{count}"
  end
end
