"""
Example rules for building generated headers for 'hello_world'
"""

def genheader(name, **kwargs):
    """
    Generate header file

    Args:
        name: name of header file to generate (example: hello.h)
        **kwargs: Additional arguments to pass to rule
    """

    # Simple rule for building a 'platform independent' generated header
    # Note that we prefix the output file name with _ as this is just an intermidiate file.
    native.genrule(
        name = name + "_rule",
        outs = [name],
        cmd = """
        # Simulate that generating header takes time
        sleep 10
        echo '/* test */' > $@
        """,
        **kwargs,
    )

