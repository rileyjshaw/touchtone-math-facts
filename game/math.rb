# entry point
def main
  say "Let's do math."
  redirect :start
end


# reset streak variable and start a game
def start
  player.streak = 0
  player.timeout_counter = 0

  redirect :intro_loop
end


# ask caller for the challenge type (addition or multiplication)
def intro_loop
  retries = player.timeout_counter.to_i + 1

  prompt do
    say "Press 1 for addition. Press 2 for multiplication."

    route 1 => :set_addition
    route 2 => :set_multiplication
  end

  # ask three times before hanging up
  if retries < 3
    player.timeout_counter = retries
    redirect :intro_loop
  else
    redirect :timeout
  end
end


# start the addition challenge
def set_addition
  player.mode = "plus"
  player.timeout_counter = 0

  redirect :ask_math_question
end


# start the multiplication challenge
def set_multiplication
  player.mode = "times"
  player.timeout_counter = 0

  redirect :ask_math_question
end


# ask a question and save the answer
def ask_math_question
  a = rand(10)
  b = rand(10)

  player.input = ""
  player.answer = (player.mode == "plus" ? a + b : a * b).to_s

  say "What is #{a} #{player.mode} #{b}?"
  redirect :wait_for_keypress
end


# wait for caller's input
def wait_for_keypress
  prompt do
    route :any => :check_answer
  end

  redirect :too_slow
end


# check if caller got the right answer —
# feeds back into wait_for_keypress, allowing for multi-digit answers
def check_answer
  player.timeout_counter = 0
  player.input += player.choice

  # correct
  if player.answer == player.input
    redirect :success
  # on the right track
  elsif player.answer.start_with? player.input
    redirect :wait_for_keypress
  # incorrect
  else
    redirect :wrong_answer
  end
end


# explain caller's failure
def wrong_answer
  say "No."
  redirect :failure
end


# explain caller's failure
def too_slow
  retries = player.timeout_counter.to_i + 1

  # ask three times before hanging up
  if retries < 3
    say "That was a bit slow."

    player.timeout_counter = retries
    redirect :failure
  else
    redirect :timeout
  end
end


# loop back to generate a new question
def failure
  player.streak = 0
  redirect :ask_math_question
end


# generate a new question until caller hits a streak of 5
def success
  streak = player.streak.to_i + 1

  if streak < 5
    play "https://www.khanacademy.org/sounds/question-correct.ogg"
    say "#{streak} in a row!" unless streak == 1

    player.streak = streak
    redirect :ask_math_question
  else
    redirect :you_are_a_master
  end
end


# caller wins! congratulate 'em.
def you_are_a_master
  play "https://www.khanacademy.org/sounds/end-of-task.ogg"
  say "You got five in a row! Way to go."

  redirect :replay_loop
end


# ask caller if they want to play again
def replay_loop
  retries = player.timeout_counter.to_i + 1

  prompt do
    say "Press 1 to play again. Press any other key to exit."

    route 1 => :start
    route :any => :exit
  end

  # ask two times before hanging up
  if retries < 2
    player.timeout_counter = retries
    redirect :replay_loop
  else
    redirect :timeout
  end
end


# cancel the call if caller remains inactive for too long
def timeout
  say "Are you still there? Call back to play again."
  redirect :exit
end


# click...
def exit
  say "Thanks for playing!"
end
