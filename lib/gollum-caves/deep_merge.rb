# http://stackoverflow.com/questions/9381553/ruby-merge-nested-hash
class ::Hash
    def deeper_merge(second)
        merger = proc { |key, v1, v2|
          Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) :
          Array === v1 && Array === v2 ? v1 | v2 :
          v2
        }
        self.merge(second, &merger)
    end
    def deep_merge(second)
        merger = proc { |key, v1, v2|
          Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
        }
        self.merge(second, &merger)
    end
end
