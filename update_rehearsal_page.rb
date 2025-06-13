#!/usr/bin/env ruby
# update_rehearsal_page.rb
# This script scans the music/ directory and updates rehearsal.md with all current music files, sorted alphabetically by part and title.

# IMPORTANT: If you make manual changes to rehearsal.md formatting or structure,
# you must also update this script to match. This script will overwrite rehearsal.md.

require 'erb'
require 'fileutils'

# Configuration
MUSIC_DIR = 'music'
REHEARSAL_MD = 'rehearsal.md'
PARTS = %w[Soprano Alto Tenor Bass AllParts]

# Helper to prettify file names
 def prettify(filename)
  name = File.basename(filename, '.mp3')
  name.gsub('%20', ' ').gsub('_', ' ')
end

# Collect all tracks by part
tracks_by_part = {}
PARTS.each do |part|
  dir = File.join(MUSIC_DIR, part)
  next unless Dir.exist?(dir)
  tracks = Dir.glob(File.join(dir, '*.mp3')).map do |path|
    {
      title: prettify(path),
      url: "{{ site.baseurl }}/#{dir}/#{ERB::Util.url_encode(File.basename(path))}"
    }
  end
  tracks_by_part[part] = tracks.sort_by { |t| t[:title].downcase }
end

# ERB template for the page
page_template = <<-MARKDOWN
---
layout: page
title: "Rehearsal Tracks"
permalink: /rehearsal/
---

<style>
.rehearsal-section {
  background: #f7f7f7;
  border: 1px solid #222;
  border-radius: 6px;
  margin-bottom: 2em;
  padding: 1em 1.5em;
}
.rehearsal-section summary {
  font-size: 1.5em;
  font-weight: bold;
  margin-bottom: 0.5em;
  cursor: pointer;
}
.rehearsal-list {
  display: flex;
  flex-direction: column;
  gap: 1.2em;
  margin: 0;
  padding: 0;
}
.rehearsal-track {
  background: #fff;
  border: 1px solid #bbb;
  border-radius: 5px;
  padding: 1em;
  display: flex;
  flex-direction: column;
  gap: 0.5em;
  box-shadow: 0 1px 4px rgba(0,0,0,0.03);
}
.track-title {
  font-weight: bold;
  font-size: 1.1em;
}
.rehearsal-track a {
  color: #0077cc;
  text-decoration: underline;
  font-size: 1em;
}
@media (max-width: 600px) {
  .rehearsal-track {
    padding: 0.7em;
  }
  .track-title {
    font-size: 1em;
  }
}
</style>

<% PARTS.each do |part| %>
<details class="rehearsal-section">
  <summary><%= part == 'AllParts' ? 'All Parts' : part %></summary>
  <div class="rehearsal-list">
    <% tracks_by_part[part].each do |track| %>
    <div class="rehearsal-track">
      <div class="track-title"><%= track[:title] %></div>
      <div><a href="<%= track[:url] %>" download>Download</a></div>
      <div><audio controls src="<%= track[:url] %>"></audio></div>
    </div>
    <% end %>
  </div>
</details>
<% end %>

<!-- Add your rehearsal track links or content below -->
MARKDOWN

# Render and write the new rehearsal.md
File.write(REHEARSAL_MD, ERB.new(page_template, trim_mode: '-').result)
puts "Updated #{REHEARSAL_MD} with all current music files."
