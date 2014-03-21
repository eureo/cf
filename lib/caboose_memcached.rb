module CabooseMemcached

  def memcache_me(key, timeout=600, &blk)
    unless defined?CACHE # no memcache
      return block_given? ? yield : nil
    end

    # no block given, just delete the cache
    unless block_given?
      CACHE.delete(key) 
      return
    end

    # cache hit, block was not evaluated
    results = 0
    return results if results = CACHE.get(key)

    # otherwise, set the cached item
    if block_given?
      CACHE.set(key, results=yield, timeout)
      results
    end
  end
end

