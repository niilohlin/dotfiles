import lldb
import fblldbbase as fb
import sys

def lldbcommands():
    return [EvaluateCurrentLine()]


class EvaluateCurrentLine(fb.FBCommand):
    def name(self):
        return "ev"

    def description(self):
        return "Evaluate Current Line"

    def get_output(self, debugger, command):
        handle = debugger.GetOutputFileHandle()
        debugger.HandleCommand('po "here 1"')
        f=open("/tmp/lldb_output.temp","w+")
        debugger.HandleCommand('po "here 2"')
        debugger.SetOutputFileHandle(f,True);
        debugger.HandleCommand('po "here 3"')
        debugger.HandleCommand(command)
        debugger.HandleCommand('po "here 4"')
        debugger.HandleCommand('po "here 5"')
        debugger.SetOutputFileHandle(handle, True)
        f.close()
        debugger.HandleCommand('po "here 6"')
        f=open("/tmp/lldb_output.temp","r")
        debugger.HandleCommand('po "here 7"')
        s = f.readlines()
        debugger.HandleCommand('po "here 8"')
        f.close()
        debugger.HandleCommand('po "here 9"')
        return s

    def run(self, arguments, options):
        debugger = lldb.debugger
        status = self.get_output(debugger, 'process status')
        current_line = None
        debugger.HandleCommand('po "here 10"')
        for line in status:
            if line.startswith("->"):
                current_line = line
                break

        debugger.HandleCommand('po "found line: {arg}"'.format(arg=current_line))
        tab_index = current_line.find("\t")
        current_statement = current_line[tab_index + 1:]

        lldb.debugger.HandleCommand('po {arg}'.format(arg=current_statement))

