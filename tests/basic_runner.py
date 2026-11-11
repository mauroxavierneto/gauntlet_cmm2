"""Focused, strict MMBasic routine runner for headless gameplay regressions.

Loads the routines from the game's actual source. This is deliberately a small
language subset, not a CMM2 emulator: graphics/audio calls are recorded, while
unsupported statements fail. Hardware rendering and audio still need CMM2 QA.
"""

from collections import defaultdict
import math
from pathlib import Path
import re


class Array:
    def __init__(self, bounds=None):
        self.values = defaultdict(int)
        self.bounds = bounds

    def key(self, indices):
        key = tuple(round(i) for i in indices)
        if self.bounds is not None:
            assert len(key) == len(self.bounds)
            assert all(0 <= i <= b for i, b in zip(key, self.bounds)), key
        return key

    def __call__(self, *indices):
        return self.values[self.key(indices)]

    def set(self, indices, value):
        self.values[self.key(indices)] = value


def split(text, delimiter=","):
    """Split outside quoted strings and parentheses; strip BASIC comments."""
    result, start, depth, quoted = [], 0, 0, False
    for i, char in enumerate(text):
        if char == '"':
            quoted = not quoted
        elif not quoted:
            if char == "'":
                text = text[:i]
                break
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
            elif char == delimiter and depth == 0:
                result.append(text[start:i].strip())
                start = i + 1
    result.append(text[start:].strip())
    return result


TOKEN = re.compile(r'\s*("[^"]*"|\d+(?:\.\d*)?|[a-z_][\w.$%]*|<>|<=|>=|[()+*/\\^=<>%,\-])', re.I)
PRIORITY = {"or": 1, "and": 2, "=": 3, "<>": 3, "<": 3, ">": 3,
            "<=": 3, ">=": 3, "+": 4, "-": 4, "mod": 5,
            "*": 5, "/": 5, "\\": 5, "^": 6}


class Flow(Exception):
    pass


class Basic:
    def __init__(self, root, names):
        self.globals = defaultdict(int)
        self.arrays = defaultdict(Array)
        self.arrays["st"] = Array((37, 37))
        self.routines = {}
        self.calls = []
        self.builtins = {"int": math.floor, "fix": math.trunc, "cint": round,
                         "abs": abs, "min": min, "max": max, "sqr": math.sqrt,
                         "sgn": lambda value: (value > 0) - (value < 0),
                         "rnd": lambda *_: 0.9, "mm.info$": lambda *_: "MODFILE"}
        self.noops = {"playwav", "playsample", "putspritechar", "putsprite",
                      "hurtsound", "putexplosion"}
        for path in [*Path(root).glob("*.BAS"), *Path(root).glob("*.INC")]:
            source = path.read_text(encoding="utf-8-sig")
            for match in re.finditer(r"(?im)^\s*(sub|function)\s+(\w+)(?:\(([^\n]*)\))?[^\n]*\n(.*?)^\s*end\s+\1\s*$", source, re.S | re.M):
                kind, name, params, body = match.groups()
                if name.lower() not in names:
                    continue
                lines = self.lines(body)
                nodes, end = self.parse(lines, 0)
                assert end == len(lines), (path, name, lines[end:])
                self.routines[name.lower()] = (kind.lower(), split(params or ""), nodes)

    @staticmethod
    def statements(line):
        parts = split(line, ":")
        for index, part in enumerate(parts):
            if part.lower().startswith("if "):
                yield ":".join(parts[index:])
                break
            yield part

    @staticmethod
    def lines(source):
        lines = []
        for line in source.splitlines():
            line = split(line, "\0")[0].strip()
            if not line:
                continue
            # A single-line IF owns the remaining colon statements.
            statements = Basic.statements(line)
            for statement in statements:
                if statement.lower().startswith("next "):
                    lines.extend("Next " + name for name in split(statement[5:]))
                else:
                    lines.append(statement)
        return lines

    def snippet(self, source):
        lines = self.lines(source)
        nodes, end = self.parse(lines, 0)
        assert end == len(lines), lines[end:]
        self.execute(nodes, {})

    def parse(self, lines, i, stops=()):
        nodes = []
        while i < len(lines):
            line, low = lines[i], lines[i].lower()
            if any(low.startswith(stop) for stop in stops):
                return nodes, i
            i += 1
            if low.startswith("if ") and re.search(r"\bthen\s*$", low):
                branches = []
                condition = re.split(r"\bthen\b", line[3:], flags=re.I)[0]
                while True:
                    body, i = self.parse(lines, i, ("elseif ", "else", "endif", "end if"))
                    branches.append((condition, body))
                    marker = lines[i]
                    i += 1
                    if marker.lower().startswith("elseif "):
                        condition = re.split(r"\bthen\b", marker[7:], flags=re.I)[0]
                    elif marker.lower() == "else":
                        body, i = self.parse(lines, i, ("endif", "end if"))
                        branches.append((None, body))
                        i += 1
                        break
                    else:
                        break
                nodes.append(("if", branches))
            elif low.startswith("for "):
                match = re.fullmatch(r"for\s+(\w+)\s*=\s*(.*?)\s+to\s+(.*?)(?:\s+step\s+(.*))?", line, re.I)
                assert match, line
                body, i = self.parse(lines, i, ("next",))
                i += 1
                nodes.append(("for", match.groups(), body))
            elif low.startswith("do while "):
                body, i = self.parse(lines, i, ("loop",))
                i += 1
                nodes.append(("while", line[9:], body))
            elif low.startswith("select case "):
                cases = []
                while i < len(lines) and lines[i].lower() != "end select":
                    assert lines[i].lower().startswith("case "), lines[i]
                    selector = lines[i][5:]
                    body, i = self.parse(lines, i + 1, ("case ", "end select"))
                    cases.append((selector, body))
                i += 1
                nodes.append(("select", line[12:], cases))
            else:
                nodes.append(("statement", line))
        return nodes, i

    def get(self, name, local):
        name = name.lower()
        return local[name] if name in local else self.globals[name]

    def set(self, name, value, local):
        name = name.lower()
        (local if name in local else self.globals)[name] = value

    def expression(self, expression, local):
        tokens, cursor = [], 0
        while cursor < len(expression):
            if not expression[cursor:].strip():
                break
            match = TOKEN.match(expression, cursor)
            assert match, expression[cursor:]
            tokens.append(match[1].lower() if not match[1].startswith('"') else match[1])
            cursor = match.end()
        pos = 0

        def expr(min_priority=0):
            nonlocal pos
            token = tokens[pos]
            pos += 1
            if token in ("-", "+", "not"):
                value = expr(6)
                value = -value if token == "-" else (int(not value) if token == "not" else value)
            elif token == "(":
                value = expr()
                assert tokens[pos] == ")"
                pos += 1
            elif token.startswith('"'):
                value = token[1:-1]
            elif token[0].isdigit():
                value = float(token) if "." in token else int(token)
            elif pos < len(tokens) and tokens[pos] == "(":
                pos += 1
                args = []
                while tokens[pos] != ")":
                    args.append(expr())
                    if tokens[pos] != ",":
                        break
                    pos += 1
                assert tokens[pos] == ")"
                pos += 1
                if token in self.builtins:
                    value = self.builtins[token](*args)
                elif token in self.routines:
                    value = self.call(token, *args)
                else:
                    value = self.arrays[token](*args)
            else:
                value = self.get(token, local)
            while pos < len(tokens) and PRIORITY.get(tokens[pos], -1) >= min_priority:
                operator = tokens[pos]
                priority = PRIORITY[operator]
                pos += 1
                rhs = expr(priority + (operator != "^"))
                if operator == "+": value += rhs
                elif operator == "-": value -= rhs
                elif operator == "*": value *= rhs
                elif operator == "/": value /= rhs
                elif operator == "\\": value = math.trunc(value / rhs)
                elif operator == "^": value **= rhs
                elif operator == "mod": value -= math.trunc(value / rhs) * rhs
                elif operator == "and": value = int(bool(value) and bool(rhs))
                elif operator == "or": value = int(bool(value) or bool(rhs))
                elif operator == "=": value = int(value == rhs)
                elif operator == "<>": value = int(value != rhs)
                elif operator == "<": value = int(value < rhs)
                elif operator == ">": value = int(value > rhs)
                elif operator == "<=": value = int(value <= rhs)
                elif operator == ">=": value = int(value >= rhs)
            return value

        result = expr()
        assert pos == len(tokens), (expression, tokens[pos:])
        return result

    def case(self, value, selector, local):
        if selector.lower() == "else":
            return True
        for part in split(selector):
            bounds = re.split(r"\s+to\s+", part, flags=re.I)
            if len(bounds) == 2:
                if self.expression(bounds[0], local) <= value <= self.expression(bounds[1], local):
                    return True
            elif re.match(r"[<>=]", part):
                local["casevalue"] = value
                if self.expression("casevalue" + part, local):
                    return True
            elif self.expression(part, local) == value:
                return True
        return False

    def execute(self, nodes, local):
        for node in nodes:
            kind = node[0]
            if kind == "statement":
                self.statement(node[1], local)
            elif kind == "if":
                for condition, body in node[1]:
                    if condition is None or self.expression(condition, local):
                        self.execute(body, local)
                        break
            elif kind == "select":
                value = self.expression(node[1], local)
                for selector, body in node[2]:
                    if self.case(value, selector, local):
                        self.execute(body, local)
                        break
            elif kind in ("for", "while"):
                if kind == "for":
                    name, first, last, step = node[1]
                    first, last, step = (self.expression(v, local) for v in (first, last, step or "1"))
                    self.set(name, first, local)
                for iteration in range(10001):
                    if kind == "for":
                        value = self.get(name, local)
                        if (value > last if step > 0 else value < last):
                            break
                    elif not self.expression(node[1], local):
                        break
                    assert iteration < 10000, "BASIC loop did not terminate"
                    try:
                        self.execute(node[2], local)
                    except Flow as flow:
                        if str(flow) in ("exit for", "exit do"):
                            break
                        if str(flow) != "continue for":
                            raise
                    if kind == "for":
                        self.set(name, self.get(name, local) + step, local)

    def statement(self, statement, local):
        low = statement.lower().strip()
        if not low:
            return
        if low.startswith("if "):
            condition, body = re.split(r"\bthen\b", statement[3:], maxsplit=1, flags=re.I)
            branches = re.split(r"\belse\b", body, maxsplit=1, flags=re.I)
            index = 0 if self.expression(condition, local) else 1
            if index < len(branches):
                for item in self.statements(branches[index]):
                    self.statement(item, local)
            return
        if low.startswith("local "):
            for name in split(statement[6:]):
                local[name.lower()] = 0
            return
        if low in ("exit sub", "exit function", "exit for", "exit do", "continue for"):
            raise Flow(low)
        assignment = re.fullmatch(r"([\w$%.]+)(?:\((.*?)\))?\s*=\s*(.*)", statement)
        if assignment:
            name, indices, expression = assignment.groups()
            value = self.expression(expression, local)
            if indices is None:
                self.set(name, value, local)
            else:
                self.arrays[name.lower()].set([self.expression(i, local) for i in split(indices)], value)
            return
        if low.startswith(("page ", "pause(", "blit ", "play stop")):
            self.calls.append(statement)
            return
        call = re.fullmatch(r"(\w+)(?:\((.*)\))?", statement)
        assert call, f"Unsupported BASIC statement: {statement}"
        name, args = call.groups()
        values = [self.expression(a, local) for a in split(args or "") if a]
        if name.lower() in self.noops:
            self.calls.append((name.lower(), values))
        else:
            self.call(name, *values)

    def call(self, name, *args):
        name = name.lower()
        kind, params, body = self.routines[name]
        params = [p.lower() for p in params if p]
        assert len(args) <= len(params), (name, params, args)
        local = dict(zip(params, (*args, *(0 for _ in range(len(params) - len(args))))))
        if kind == "function":
            local[name] = 0
        try:
            self.execute(body, local)
        except Flow as flow:
            assert str(flow) in ("exit sub", "exit function"), (name, flow)
        return local.get(name)
