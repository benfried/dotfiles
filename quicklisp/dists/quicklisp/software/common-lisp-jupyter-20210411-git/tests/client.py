import unittest
import jupyter_kernel_test
import jupyter_client

TIMEOUT = 240


class MyKernelTests(jupyter_kernel_test.KernelTests):

    @classmethod
    def tearDownClass(cls):
        cls.kc.shutdown()

    language_name = "common-lisp"

    file_extension = ".lisp"

    code_hello_world = '(format t "hello, world")'

    code_stderr = '(format *error-output* "test")'

    complete_code_samples = [
        '\'x',
        '(+ 1 2)'
    ]
    incomplete_code_samples = [
        '(+ 1'
    ]
    invalid_code_samples = [
        '(+ 1 2))'
    ]

    completion_samples = [
        {
            'text': '(z',
            'matches': {'zerop'},
        },
        {
            'text': '(cl:cd',
            'matches': {
                'cdaadr',
                'cddaar',
                'cdadar',
                'cdar',
                'cddadr',
                'cdadr',
                'cdddr',
                'cdaaar',
                'cddddr',
                'cddr',
                'cdaar',
                'cdddar',
                'cddar',
                'cdaddr',
                'cdr'
            },
        },
    ]

    code_page_something = "(format jupyter:*page-output* \"foo\")"

    # code_generate_error = '(/ 1 0)'

    code_execute_result = [
        {'code': '(+ 1 2)', 'result': '3'}
    ]

    code_display_data = [{
        'code': '(jupyter:text "wibble" t)',
        'mime': 'text/plain'
    }, {
        'code': '(jupyter:html "<html/>" t)',
        'mime': 'text/html'
    }, {
        'code': '(jupyter:latex "$r^2$" t)',
        'mime': 'text/latex'
    }, {
        'code': '(jupyter:markdown "wibble" t)',
        'mime': 'text/markdown'
    }, {
        'code': '(jupyter:svg "<svg/>" t)',
        'mime': 'image/svg+xml'
    }]

    code_inspect_sample = "format"

    code_clear_output = "(jupyter:clear)"

    code_history_pattern = "?+ 1*"
    supported_history_operations = ("tail", "range", "search")

    def test_repl_previous_results(self):
        reply, output_msgs = self.execute_helper(
            code="(values 'a1 'a2) 'b (values 'c1 'c2 'c3) (list / // ///)")
        self.assertEqual(len(output_msgs), 7, "Did not receive 7 execution results.")
        self.assertEqual(output_msgs[-1]['msg_type'], 'execute_result')
        self.assertIn('data', output_msgs[-1]['content'])
        self.assertIn('text/plain', output_msgs[-1]['content']['data'])
        self.assertEqual(output_msgs[-1]['content']['data']['text/plain'], '((C1 C2 C3) (B) (A1 A2))')

    def test_repl_previous_primary_result(self):
        reply, output_msgs = self.execute_helper(
            code="(values 'a1 'a2) 'b (values 'c1 'c2 'c3) (list * ** ***)")
        self.assertEqual(len(output_msgs), 7, "Did not receive 7 execution results.")
        self.assertEqual(output_msgs[-1]['msg_type'], 'execute_result')
        self.assertIn('data', output_msgs[-1]['content'])
        self.assertIn('text/plain', output_msgs[-1]['content']['data'])
        self.assertEqual(output_msgs[-1]['content']['data']['text/plain'], '(C1 B A1)')

    def test_repl_previous_eval_form(self):
        reply, output_msgs = self.execute_helper(
            code="(+ 0 1) (- 4 2) (/ 9 3) (list + ++ +++)")
        self.assertEqual(len(output_msgs), 4, "Did not receive 4 execution results.")
        self.assertEqual(output_msgs[-1]['msg_type'], 'execute_result')
        self.assertIn('data', output_msgs[-1]['content'])
        self.assertIn('text/plain', output_msgs[-1]['content']['data'])
        self.assertEqual(output_msgs[-1]['content']['data']['text/plain'], '((/ 9 3) (- 4 2) (+ 0 1))')

    def test_quickload(self):
        reply, output_msgs = self.execute_helper(
            code="(ql:quickload :jsown)")
        for msg in output_msgs:
            if msg['msg_type'] == 'execute_result':
                self.assertIn('data', msg['content'])
                self.assertIn('text/plain', msg['content']['data'])
                self.assertEqual(msg['content']['data']['text/plain'], '(:JSOWN)')
            else:
                self.assertEqual(msg['msg_type'], "stream", "Output message must be stream or result")
                self.assertEqual(msg['content']['name'], 'stdout', "Stream must be stdout")


def load_tests(loader, tests, pattern):
    suite = unittest.TestSuite()
    mgr = jupyter_client.kernelspec.KernelSpecManager()
    for name, spec in mgr.get_all_specs().items():
        if spec['spec']['language'] == "common-lisp":
            suite.addTests(loader.loadTestsFromTestCase(type(name, (MyKernelTests,), dict(kernel_name = name))))
    return suite


if __name__ == '__main__':
    unittest.main()
