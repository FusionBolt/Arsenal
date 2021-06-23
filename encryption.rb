module Encryption
  private

  def assert(expr)
    raise 'wrong' unless expr
  end

  # TODO:注入到Random和Array中
  def generate_random_list(range)
    range.to_a.shuffle
  end

  def swap_arr_i_v(arr)
    new_arr = Array.new(arr.size, 0)
    arr.each_index do |index|
      new_arr[arr[index]] = index
    end
    new_arr
  end

  public

  def generate_pair_key
    random_key1 = self.generate_random_list(0..256)
    random_key2 = self.swap_arr_i_v(random_key1)
    [random_key1, random_key2]
  end

  # def generate_pair_key
  #   random_key1 = (0..256).to_a.shuffle!
  #   random_key2 = Array.new(256, 0)
  #   random_key1.each_index do |index|
  #     random_key2[random_key1[index]] = index
  #   end
  #   [random_key1, random_key2]
  # end

  def encoding(str, key)
    s = str.bytes.map do |byte|
      key[byte]
    end
    s.pack('c*')
  end

  def demo
    key1, key2 = generate_pair_key
    str = 'test encryption'
    old_str = str.dup
    str = encoding(str, key1)
    str = encoding(str, key2)
    assert(str == old_str)
  end

  def load_key(file_name)
    key = []
    open(file_name, 'r+') do |f|
      key = Marshal.load(f.read)
    end
    key
  end

  def write_key(key, file_name)
    open(file_name, 'w+') do |f|
      f.write(Marshal.dump(key))
    end
  end
end