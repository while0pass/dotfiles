#!/bin/sh

show_df()
{
	df -h | sed -n '1p;/dpowdere\|nurono/p'
}

echo "Use '$0 free' to remove folders that are safe to remove"
case "$1" in

	free)
		echo
		echo "Before cleanup:"
		echo
		show_df
		echo
		rm -fr ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage
		rm -fr ~/Library/Application\ Support/Slack/Cache
		rm -fr ~/Library/Application\ Support/Code
		#rm -fr ~/.vscode/extensions
		echo "After cleanup:"
		echo
		show_df
		echo
		;;

	*)
		echo
		show_df >.largest_folders
		echo >> .largest_folders
		cat .largest_folders
		echo "Please, wait. We are searching for the largest folders to show you..."
		find ~ -type d -exec du -hs {} + 2>/dev/null \
			| sort -hr | head -100 >> .largest_folders
		less .largest_folders

esac
