# © 2026 aiaiaiai · aiaiaiai.org

module PrismaTelegram
  class FileInteractionStateStore
    include PrismBot::Ports::InteractionStateStore

    FORMAT_VERSION = 1
    MAX_STATE_BYTES = 65_536

    def initialize(directory:, ttl_seconds:, clock: -> { Time.now.to_i })
      @directory = File.expand_path(String(directory)).freeze
      @ttl_seconds = Integer(ttl_seconds)
      @clock = clock
      if @directory.empty? || @ttl_seconds <= 0 || !@clock.respond_to?(:call)
        raise ArgumentError, "invalid interaction state store configuration"
      end

      FileUtils.mkdir_p(@directory, mode: 0o700)
    end

    def load(key:)
      path = path_for(key)
      source = File.binread(path, MAX_STATE_BYTES + 1)
      if source.bytesize > MAX_STATE_BYTES
        raise StateStoreError.new(
          "prisma_telegram.state.too_large",
          "interaction state exceeds the maximum size"
        )
      end

      payload = JSON.parse(source)
      validate_payload!(payload)
      if payload.fetch("expires_at") <= now
        delete(key: key)
        return nil
      end

      state = payload.fetch("state")
      PrismBot::Domain::InteractionState.new(
        name: state.fetch("name"),
        data: state.fetch("data", {})
      )
    rescue Errno::ENOENT
      nil
    rescue JSON::ParserError, KeyError, TypeError => error
      raise StateStoreError.new(
        "prisma_telegram.state.invalid",
        "interaction state cannot be decoded: #{error.class}"
      )
    end

    def store(key:, state:)
      unless state.is_a?(PrismBot::Domain::InteractionState)
        raise ArgumentError, "state must be an InteractionState"
      end

      payload = {
        "version" => FORMAT_VERSION,
        "expires_at" => now + @ttl_seconds,
        "state" => {
          "name" => state.name,
          "data" => state.data
        }
      }
      atomic_write(path_for(key), JSON.generate(payload))
      state
    end

    def delete(key:)
      File.delete(path_for(key))
      nil
    rescue Errno::ENOENT
      nil
    end

    private

    def now
      Integer(@clock.call)
    end

    def validate_payload!(payload)
      unless payload.is_a?(Hash) &&
          payload["version"] == FORMAT_VERSION &&
          payload["expires_at"].is_a?(Integer) &&
          payload["state"].is_a?(Hash)
        raise StateStoreError.new(
          "prisma_telegram.state.invalid",
          "interaction state has an unsupported shape"
        )
      end
    end

    def path_for(key)
      unless key.is_a?(PrismBot::Domain::InteractionKey)
        raise ArgumentError, "key must be an InteractionKey"
      end

      fingerprint = Digest::SHA256.hexdigest(
        [key.instance_id, key.surface, key.actor_ref].join("\0")
      )
      File.join(@directory, "#{fingerprint}.json")
    end

    def atomic_write(path, source)
      temporary = "#{path}.tmp-#{Process.pid}-#{SecureRandom.hex(8)}"
      File.open(
        temporary,
        File::WRONLY | File::CREAT | File::EXCL,
        0o600
      ) do |file|
        file.write(source)
        file.flush
        file.fsync
      end
      File.rename(temporary, path)
    ensure
      File.delete(temporary) if temporary && File.exist?(temporary)
    end
  end
end
