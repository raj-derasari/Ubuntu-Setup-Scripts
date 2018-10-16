z=`git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -10 | cut -d' ' -f1`

for var in "$z"; do
	git rev-list --objects --all | grep $var
done

# rm -Rf .git/refs/original; rm -Rf .git/logs/; git gc --aggressive --prune=now

