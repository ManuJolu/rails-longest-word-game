class PlayController < ApplicationController
  def game
    @new_grid = generate_grid(9).join(" ")
    @start_time = Time.now
  end

  def generate_grid(grid_size)
    Array.new(grid_size) do
      rand < 0.2 ? ['A','E','I','O','U','Y'][rand(6)] : ('A'..'Z').to_a[rand(26)]
    end
  end

  def score
    @end_time = Time.now
    @start_time = Time.parse(params[:start])
    @new_grid = params[:grid].split(" ")
    @result = run_game(params[:attempt], @new_grid, @start_time, @end_time)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "15fc374c-4e27-4f96-a36b-9521e1baeda5"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end
end
