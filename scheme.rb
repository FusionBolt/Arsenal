# frozen_string_literal: true

module Scheme
  def tokenize(s)
    s.gsub('(', ' ( ').gsub(')', ' ) ').split
  end

  def atom(token)
    case token
    when /\d/
      token.to_f % 1 > 0 ? token.to_f : token.to_i
    else
      token.to_sym
    end
  end

  def read_from_tokens(tokens)
    raise 'tokens empty' if tokens.empty?

    token = tokens.shift
    if token == '('
      l = []
      l.push read_from_tokens tokens while tokens[0] != ')'
      tokens.shift
      l
    elsif token == ')'
      raise 'unexpect )'
    else
      atom(token)
    end
  end

  def parse(s)
    read_from_tokens tokenize s
  end

  def standard_env
    env ||=
      begin
        operators = %i[== != < <= > >= + - * /]
        operators.inject({}) do |env, operator|
          env.merge operator => ->(*args) { args.inject &operator }
            #env.merge operator => ->(*args) { operator.to_proc.call(*args) }
        end
      end
    fun = { list: ->(*args) { return *args },
            list?: -> x { x.is_a? Array },
            len: -> x { args.flatten.length },
            sum: ->(*args) { args.flatten.sum },
            cons: ->(x, y) { [x] + y },
            car: -> x { x[0] },
            cdr: -> x { x[1..-1] },
            map: -> (list, operator) { list.map{ |x|  operator.call x } },
            range: -> (x, y) { (x..y).to_a }
            }
    env.merge fun
      # env.merge pi: 3.14
  end

  class Env < Hash
    def initialize(param = [], args = [], parent = nil)
      update Hash[param.zip args]
      @parent = parent
    end

    def find(var)
      (key? var) ? self : @parent.find(var)
    end
  end

  $global_env = Env.new

  class Procedure
    def initialize(param, body, env)
      @param = param
      @body = body
      @env = env
    end

    def call(*args)
      eval(@body, Env.new(@param, args, @env))
    end
  end

  def eval(expr, env = $global_env)
    return env.find(expr)[expr] if expr.is_a? Symbol
    return expr unless expr.is_a? Array

    case expr[0]
    when :define
      _, var, exp = expr
      env[var] = eval exp, env
    when :if
      _, test, conseq, alt = expr
      exp = eval(test) ? conseq : alt
      eval exp, env
    when :quote
      _, exp = expr
      exp.join(' ')
    when :set!
      _, var, exp = expr
      env.find(var)[var] = eval(exp)
    when :lambda
      (_, params, body) = expr
      Procedure.new(params, body, env)
    else
      proc, *args = expr.map { |exp| eval exp, env }
      proc.call *args
    end
  end

  def repl(prompt = 'scheme> ')
    while true
      print prompt
      input = gets.chomp
      return if input == 'q'
      begin
      val = eval(parse(input))
      rescue
        p $@, $!
      end
      p val
    end
  end
end
