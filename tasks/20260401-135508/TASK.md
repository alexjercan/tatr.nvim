# Implement a nvim command that will insert a task as a TODO comment

- STATUS: CLOSED
- PRIORITY: 70
- TAGS: feature

We want to be able to hit a keybinding and have a TODO comment inserted at the
current line. That TODO comment should be in the format of:

```
// TODO(20260330-160000): <task description>
```

Where the timestamp is the current date and time in the format of
YYYYMMDD-HHMMSS. The task should be searched the same way we do the `ls`
command. So it opens it in telescope and when you select it, it inserts it at
the current line.

A nice to have idea that might get explored a bit more is to have a comment and
convert it into a task. For instance, you write a comment like this:

```
// TODO: Implement nvim plugin to create task and link from editor
```

Then you put the cursor on the TODO and press the keybinding to create the task
and link. The plugin creates a `huid` and a `task` and links them together. The
TODO comment is updated to include the timestamp and the task description is
taken from the comment. So it becomes:

```
// TODO(20260330-160000): Implement nvim plugin to create task and link from editor
```

Now, the hard part is to get the `huid` from running the tatr command. Right
now tatr responds to stdout with a text message that includes the `huid`. We
can parse that. Or we can `ls` and look for the most recent task that matches
the description. The first option is simpler and more reasonable. We can just
use a regex to extract the `huid`.
