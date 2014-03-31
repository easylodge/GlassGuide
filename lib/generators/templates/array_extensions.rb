class Array
  def to_proc
    Proc.new do |item|
      inject(item) do |mem, obj|
        mem.send(obj)
      end
    end
  end
end

class String
  def dash_blank!
    self.empty? ? "-" : self
  end
end