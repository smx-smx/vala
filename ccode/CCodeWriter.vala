/* valaccodewriter.vala
 *
 * Copyright (C) 2006-2009  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 */

using GLib;

/**
 * Represents a writer to write C source files.
 */
public class Vala.CCodeWriter {
	/**
	 * Specifies the file to be written.
	 */
	public string filename { get; set; }

	/**
	 * Specifies the source file used to generate this one.
	 */
	private string source_filename;

	/**
	 * Specifies whether to emit line directives.
	 */
	public bool line_directives { get; set; }

	/**
	 * Specifies whether the output stream is at the beginning of a line.
	 */
	public bool bol {
		get { return _bol; }
	}

	static GLib.Regex fix_indent_regex;

	private string temp_filename;
	private bool file_exists;

	private FileStream? stream;
	
	private int indent;
	private int current_line_number = 1;
	private bool using_line_directive;

	/* at begin of line */
	private bool _bol = true;
	
	public CCodeWriter (string filename, string? source_filename = null) {
		this.filename = filename;
		this.source_filename = source_filename;
	}

	/**
	 * Opens the file.
	 *
	 * @return true if the file has been opened successfully,
	 *         false otherwise
	 */
	public bool open (bool write_version) {
		file_exists = FileUtils.test (filename, FileTest.EXISTS);
		if (file_exists) {
			temp_filename = "%s.valatmp".printf (filename);
			stream = FileStream.open (temp_filename, "w");
		} else {
			/*
			 * File doesn't exist. In case of a particular destination (-d flag),
			 * check and create the directory structure.
			 */
			var dirname = Path.get_dirname (filename);
			DirUtils.create_with_parents (dirname, 0755);
			stream = FileStream.open (filename, "w");
		}

		if (stream == null) {
			return false;
		}

		var opening = write_version ?
			"/* %s generated by valac %s, the Vala compiler".printf (Path.get_basename (filename), Config.BUILD_VERSION) :
			"/* %s generated by valac, the Vala compiler".printf (Path.get_basename (filename));
		write_string (opening);

		// Write the file name if known
		if (source_filename != null) {
			write_newline ();
			write_string (" * generated from %s".printf (Path.get_basename (source_filename)));
		}

		write_string (", do not modify */");
		write_newline ();
		write_newline ();

		return true;
	}

	/**
	 * Closes the file.
	 */
	public void close () {
		stream = null;
		
		if (file_exists) {
			var changed = true;

			try {
				var old_file = new MappedFile (filename, false);
				var new_file = new MappedFile (temp_filename, false);
				var len = old_file.get_length ();
				if (len == new_file.get_length ()) {
					if (Memory.cmp (old_file.get_contents (), new_file.get_contents (), len) == 0) {
						changed = false;
					}
				}
				old_file = null;
				new_file = null;
			} catch (FileError e) {
				// assume changed if mmap comparison doesn't work
			}
			
			if (changed) {
				FileUtils.rename (temp_filename, filename);
			} else {
				FileUtils.unlink (temp_filename);
				if (source_filename != null) {
					var stats = Stat (source_filename);
					var target_stats = Stat (filename);
					if (stats.st_mtime >= target_stats.st_mtime) {
						UTimBuf timebuf = { stats.st_atime + 1, stats.st_mtime + 1 };
						FileUtils.utime (filename, timebuf);
					}
				}
			}
		}
	}
	
	/**
	 * Writes tabs according to the current indent level.
	 */
	public void write_indent (CCodeLineDirective? line = null) {
		if (line_directives) {
			if (line != null) {
				line.write (this);
				using_line_directive = true;
			} else if (using_line_directive) {
				// no corresponding Vala line, emit line directive for C line
				string path = Path.get_basename (filename);
				path = path.replace("\\", "/");

				write_string ("#line %d \"%s\"".printf (current_line_number + 1, path));
				write_newline ();
				using_line_directive = false;
			}
		}

		if (!_bol) {
			write_newline ();
		}
		
		stream.puts (string.nfill (indent, '\t'));
		_bol = false;
	}
	
	/**
	 * Writes n spaces.
	 */
	public void write_nspaces (uint n) {
		stream.puts (string.nfill (n, ' '));
	}

	/**
	 * Writes the specified string.
	 *
	 * @param s a string
	 */
	public void write_string (string s) {
		stream.puts (s);
		_bol = false;
	}
	
	/**
	 * Writes a newline.
	 */
	public void write_newline () {
		stream.putc ('\n');
		current_line_number++;
		_bol = true;
	}
	
	/**
	 * Opens a new block, increasing the indent level.
	 */
	public void write_begin_block () {
		if (!_bol) {
			stream.putc (' ');
		} else {
			write_indent ();
		}
		stream.putc ('{');
		write_newline ();
		indent++;
	}
	
	/**
	 * Closes the current block, decreasing the indent level.
	 */
	public void write_end_block () {
		assert (indent > 0);
		
		indent--;
		write_indent ();
		stream.putc ('}');
	}
	
	/**
	 * Writes the specified text as comment.
	 *
	 * @param text the comment text
	 */
	public void write_comment (string text) {
		try {
			write_indent ();
			stream.puts ("/*");
			bool first = true;

			// discard tabs at beginning of line
			if (fix_indent_regex == null)
				fix_indent_regex = new GLib.Regex ("^\t+");;

			foreach (unowned string line in text.split ("\n")) {
				if (!first) {
					write_indent ();
				} else {
					first = false;
				}

				var lineparts = fix_indent_regex.replace_literal (line, -1, 0, "").split ("*/");

				for (int i = 0; lineparts[i] != null; i++) {
					stream.puts (lineparts[i]);
					if (lineparts[i+1] != null) {
						stream.puts ("* /");
					}
				}
			}
			stream.puts ("*/");
			write_newline ();
		} catch (RegexError e) {
			// ignore
		}
	}
}
