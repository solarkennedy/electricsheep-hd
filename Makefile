default:
	bash go.sh

install_dependencies:
	sudo apt-get install flam3 mencoder mplayer

clean:
	rm -rf animated_genomes/
	rm -rf frames/
	rm -rf movies/

play:
	mplayer -playlist playlist.m3u
