#!/usr/bin/env ruby
# frozen_string_literal: true

# Merges disposable email domains from ivolo/disposable-email-domains into emails.txt.
#
# This script:
# 1. Copies the current emails.txt into a working directory
# 2. Downloads index.json from the remote source
# 3. Merges both lists (unique, sorted, no blanks)
# 4. Verifies the merge
# 5. Copies the result back to emails.txt

require "json"
require "net/http"
require "uri"
require "tmpdir"
require "set"
require "fileutils"

REMOTE_URL = "https://raw.githubusercontent.com/ivolo/disposable-email-domains/master/index.json"

repo_root = File.expand_path("..", __dir__)
emails_path = File.join(repo_root, "emails.txt")

abort "emails.txt not found at #{emails_path}" unless File.exist?(emails_path)

Dir.mktmpdir("merge-spam-domains") do |tmpdir|
  puts "Working in #{tmpdir}"

  # Step 1: Copy current emails.txt
  old_path = File.join(tmpdir, "emails.txt.old")
  FileUtils.cp(emails_path, old_path)
  old_domains = File.readlines(old_path, chomp: true)
  puts "Loaded #{old_domains.size} domains from emails.txt"

  # Step 2: Download index.json
  puts "Downloading #{REMOTE_URL}..."
  uri = URI(REMOTE_URL)
  response = Net::HTTP.get_response(uri)
  abort "Failed to download index.json: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  json_path = File.join(tmpdir, "index.json")
  File.write(json_path, response.body)
  new_domains = JSON.parse(response.body)
  puts "Downloaded #{new_domains.size} domains from index.json"

  # Step 3: Merge
  merged = (old_domains + new_domains)
    .map(&:strip)
    .reject(&:empty?)
    .uniq
    .sort

  merged_path = File.join(tmpdir, "emails.txt.merged")
  File.write(merged_path, merged.join("\n") + "\n")
  puts "Merged to #{merged.size} unique domains"

  # Step 4: Verify
  puts "\nVerifying merge..."
  failures = 0
  merged_set = merged.to_set

  missing_old = old_domains.reject { |d| merged_set.include?(d) }
  if missing_old.empty?
    puts "  PASS: All #{old_domains.size} original domains present"
  else
    puts "  FAIL: #{missing_old.size} original domains missing"
    missing_old.first(10).each { |d| puts "    missing: #{d}" }
    failures += 1
  end

  missing_new = new_domains.reject { |d| merged_set.include?(d) }
  if missing_new.empty?
    puts "  PASS: All #{new_domains.size} remote domains present"
  else
    puts "  FAIL: #{missing_new.size} remote domains missing"
    missing_new.first(10).each { |d| puts "    missing: #{d}" }
    failures += 1
  end

  dupes = merged.tally.select { |_, count| count > 1 }
  if dupes.empty?
    puts "  PASS: No duplicates"
  else
    puts "  FAIL: #{dupes.size} duplicates found"
    failures += 1
  end

  if merged == merged.sort
    puts "  PASS: Sorted alphabetically"
  else
    puts "  FAIL: Not sorted"
    failures += 1
  end

  blanks = merged.select { |line| line.strip.empty? }
  if blanks.empty?
    puts "  PASS: No blank lines"
  else
    puts "  FAIL: #{blanks.size} blank lines"
    failures += 1
  end

  if failures > 0
    abort "\n#{failures} check(s) FAILED — emails.txt was NOT updated"
  end

  # Step 5: Copy back
  FileUtils.cp(merged_path, emails_path)
  puts "\nAll checks passed. Updated #{emails_path}"
  puts "Old: #{old_domains.size} → New: #{merged.size} (+#{merged.size - old_domains.size})"
end
