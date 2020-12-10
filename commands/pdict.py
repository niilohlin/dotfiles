import lldb
import fblldbbase as fb



def lldbcommands():
    return [PrettyPrintDictionary()]


class PrettyPrintDictionary(fb.FBCommand):
    def name(self):
        return "ppdict"

    def description(self):
        return "Pretty print a dictionary"

    def run(self, arguments, options):
        # It's a good habit to explicitly cast the type of all return
        # values and arguments. LLDB can't always find them on its own.

        lldb.debugger.HandleCommand('po print("\({arg} as AnyObject)")'.format(arg=arguments[0]))
