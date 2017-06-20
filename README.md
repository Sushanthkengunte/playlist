# playlist
# A app to display songs from a JSON file and create playlists.
#--------------------------------------------------------------
# Scenes
# - Homepage: PlaylistTableViewController - Displays all the playtlist created and blank if there is no playlist.
# - A tab from home Screen: songsList.swift - Displays all the songs from music JSON file.
# - PlaylistSongTableViewController: Displays all the songs in a particular playlist.
#--------------------------------------------------------------
# Flow
# The home page is displayed with two tabs which displays the playlists and songs
# User can create a new playlist by clicking the '+' on the right top corner.
#       1) should provide a name of the playlist
# User can add songs to the created playlist in two ways:
#       1) By long pressing on a song in the songs tab and selecting appropriate option
#       2) By pressing the add button present in the scene where songs for a particular playlist is displayed.
# User can delete a song from the playlist by swiping the song name to the left and selecting delete option.
#---------------------------------------------------------------
