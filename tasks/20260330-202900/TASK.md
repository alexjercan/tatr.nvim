# Implement nvim plugin to create task and link from editor

- STATUS: CLOSED
- PRIORITY: 90
- TAGS: feature

This is a follow up to the Task Tracker project. We want to be able to create
tasks from the editor and link them to the file and line number where they were
created. This will allow us to easily jump to the task from the editor and see
the details of the task.

In code the tasks will look like this:

```
TODO(20260330-202900): Implement nvim plugin to create task and link from editor
```

I would like to be able to have a keybinding that creates a `huid` and a `task`
and links them together. Then whatever I type in the TODO comment will be the
title of the task.

Or I guess the workflow can be like this:
- I write
```
TODO: Implement nvim plugin to create task and link from editor
```
- I put the cursor on the TODO and press the keybinding to create the task and link
- The plugin creates a `huid` and a `task` and links them together.

Ok so basically the new idea is to have a keybind that let's you define a task
the same way I do with macro query.

For instance. I will press something like `<leader>tn`, which would run
something like `:TatrNew` command, which just executes `tatr new` in shell. I
will just have to make sure the `tatr` tool is installed in the vim plugin. Or
maybe I just add the vim `lua` code into the `tatr` repository. I will have to
check which one makes more sense. New repo or monorepo. Then it's pretty
straight forward. What would also be cool is to have `ls` integrated into vim.
Basically `:TatrList` and it could also have some extra parameters which runs
`tatr ls` and that just gets put either into a quickfix list or in telescope. I
might do telescope just because it is easier. Then you just use trouble to put
it into list.
