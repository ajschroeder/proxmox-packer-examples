# How to contribute

I'm really glad you're reading this, because community driven, open-source projects need volunteer developers.

## Testing

Until actual tests can be developed, I ask that you test any *major* changes to Packer builds. What's a major change? Anything other than changing CPU, RAM, disk size would be considered a major change to a build.

## Submitting changes

Please send a [GitHub Pull Request to proxmox-packer-examples](https://github.com/ajschroeder/proxmox-packer-examples/pull/new/main) with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)). Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

Start reading the code and you'll get the hang of it. We optimize for readability:

  * We indent using two spaces (soft tabs)
  * We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x += 1`, not `x+=1`), and around hash arrows.
  * This is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.

Thanks,
AJ Schroeder
