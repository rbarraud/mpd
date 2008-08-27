;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

;;;; MPD Commands

;;; This software is in the public domain and is
;;; provided with absolutely no warranty.

(in-package :mpd)

(defcommand password (password)
  "Authentication."
  (send "password" password))

(defcommand disconnect ()
  "Close connection."
  (socket-close connection))

(defcommand now-playing ()
  "Return instance of playlist with current song."
  (make-track (send "currentsong") 'playlist))

(defcommand disable-output (id)
  (send "disableoutput" id))

(defcommand enable-output (id)
  (send "enableoutput" id))

(defcommand ping ()
  "Send ping to MPD."
  (send "ping"))

(defcommand kill ()
  "Stop MPD in a safe way."
  (send "kill"))

(defcommand status ()
  "Return status of MPD."
  (split-values (send "status")))

(defcommand stats ()
  "Return statisics."
  (split-values (send "stats")))

(defcommand outputs ()
  "Return information about all outputs."
  (split-values (send "outputs")))

(defcommand commands ()
  "Return list of available commands."
  (filter-keys (send "commands")))

(defcommand not-commands ()
  "Return list of commands to which the current user does not have access."
  (filter-keys
   (send "notcommands")))

;;; Control

(defcommand pause ()
  "Toggle pause / resume playing."
  (send "pause"))

(defcommand play (&optional song-number)
  "Begin playing the playlist starting from song-number, default is 0."
  (send "play" song-number))

(defcommand stop ()
  "Stop playing."
  (send "stop"))

(defcommand next ()
  "Play next track in the playlist."
  (send "next"))

(defcommand previous ()
  "Play previous track in the playlist."
  (send "previous"))

;; Playlist

(defcommand playlist ()
  "Return list of files in the current playlist."
  (filter-keys (send "playlist")))

(defcommand clear-playlist ()
  "Clear the current playlist."
  (send "clear"))

(defcommand save-playlist (filename)
  "Save the current playlist to the file in the playlist directory."
  (send "save" filename))

(defcommand load-playlist (filename)
  "Load playlist from file."
  (send "load" filename))

(defcommand rename-playlist (name new-name)
  "Rename playlist."
  (send "rename" name new-name))

(defcommand playlist-info (&optional id)
  "Return content of the current playlist."
  (if id
      (make-track (send "playlistinfo" id) 'playlist)
      (parse-list (send "playlistinfo") 'playlist)))

(defgeneric add (connection what)
  (:documentation "Add file or directory to the current playlist."))

(defmethod-command add ((what track))
  (add connection (file what)))

(defmethod-command add ((what string))
  (send "add" what))

(defgeneric add-id (connection what)
  (:documentation "Like add, but returns a id."))

(defmethod-command add-id ((what track))
  (add connection (file what)))

(defmethod-command add-id ((what string))
  (car (filter-keys (send "addid" what))))

(defcommand move (from to)
  "Move track from `from' to `to' in the playlist."
  (send "move" from to))

(defgeneric move-id (connection id to)
  (:documentation "Move track with `id' to `to' in the playlist."))

(defmethod-command move-id ((track playlist) to)
  (move-id connection (id track) to))

(defmethod-command move-id ((id number) to)
  (send "moveid" id to))

(defcommand delete-track (number)
  "Delete track from playlist."
  (send "delete" number))

(defgeneric delete-id (connection id)
  (:documentation "Delete track with `id' from playlist."))

(defmethod-command delete-id ((id playlist))
  (delete-id connection (id id)))

(defmethod-command delete-id ((id number))
  (send "deleteid" id))

;;; Database

(defcommand update (&optional path)
  "Scan directory for music files and add them to the database."
  (send "update" path))

(defcommand mpd-find (type what)
  "Find tracks in the database with a case sensitive, exact match."
  (parse-list (send "find" type what) 'track))

(defcommand mpd-list (metadata-1 &optional metadata-2 search-term)
  "List all metadata of `metadata-1'.
If `metadata-2' & `search-term' are supplied,
then list all `metadata-1' in which `metadata-2' has value `search-term'."
  (send "list" metadata-1 metadata-2 search-term))

(defcommand mpd-search (type what)
  "Find tracks in the database with a case sensitive, inexact match."
  (parse-list (send "search" type what) 'track))

(defcommand list-all-info (&optional path)
  "Lists all information about files in `path' recursively. Default path is /."
  (parse-list (send "listallinfo" path) 'track))

(defcommand list-all (&optional path)
  "Lists all files in `path' recursively. Default path is /."
  (parse-list (send "listall" path)))

(defcommand list-info (&optional path)
  "Show contents of directory."
  (parse-list (send "lsinfo" path) 'track))

(defcommand mpd-count (scope query)
  "Number of songs and their total playtime matchin `query'.
Return: (number playtime)."
  (filter-keys (send "count" scope query)))

(defcommand set-volume (value)
  "Set the volume to the value between 0-100."
  (declare (type (integer 0 100) value))
  (send "setvol" value))

(defcommand tag-types ()
  "Get a list of available metadata types."
  (filter-keys (send "tagtypes")))

(defcommand url-handlers ()
  "Get a list of available URL handlers."
  (filter-keys (send "urlhandlers")))