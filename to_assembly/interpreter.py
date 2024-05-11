lines = open("asm", "r").readlines()
asm = [l.split(" ") for l in lines]
asm = [[l[0]] + [int(x) for x in l[1:]] for l in asm]
mem = [0]*2048
ip = 0
offset = 0


while ip<len(asm):
    print(asm[ip])
    if asm[ip][0][0] == ".":
        ip+=1
    elif asm[ip][0][0] == "error":
        print(asm[ip])
        exit(1)
    elif asm[ip][0] == "AFC":
        mem[asm[ip][1] + offset] = asm[ip][2]
        ip+=1
    elif asm[ip][0] == "COP":
        mem[asm[ip][1] + offset] = mem[asm[ip][2] + offset]
        ip+=1
    elif asm[ip][0] == "ADD":
        mem[asm[ip][1] + offset] = mem[asm[ip][2] + offset] + mem[asm[ip][3] + offset]
        ip+=1
    elif asm[ip][0] == "SUB":
        mem[asm[ip][1] + offset] = mem[asm[ip][2] + offset] - mem[asm[ip][3] + offset]
        ip+=1
    elif asm[ip][0] == "MUL":
        mem[asm[ip][1] + offset] = mem[asm[ip][2] + offset] * mem[asm[ip][3] + offset]
        ip+=1
    elif asm[ip][0] == "DIV":
        mem[asm[ip][1] + offset] = mem[asm[ip][2] + offset] / mem[asm[ip][3] + offset]
        ip+=1
    elif asm[ip][0] == "EQ":
        mem[asm[ip][1] + offset] = (mem[asm[ip][2] + offset] == mem[asm[ip][3] + offset])
        ip+=1
    elif asm[ip][0] == "INF":
        mem[asm[ip][1] + offset] = (mem[asm[ip][2] + offset] < mem[asm[ip][3] + offset])
        ip+=1
    elif asm[ip][0] == "SUP":
        mem[asm[ip][1] + offset] = (mem[asm[ip][2] + offset] > mem[asm[ip][3] + offset])
        ip+=1
    elif asm[ip][0] == "NOT":
        mem[asm[ip][1] + offset] = not(mem[asm[ip][2] + offset])
        ip+=1
    elif asm[ip][0] == "JMP":
        ip = asm[ip][1]
    elif asm[ip][0] == "JMF":
        if (mem[asm[ip][1] + offset] == 0):
            ip = asm[ip][2]
        else:
            ip+=1
    elif asm[ip][0] == "CALL":
        ip = asm[ip][1]
    elif asm[ip][0] == "OFFSETP":
        ip+=1
        offset += asm[ip[1]]
    elif asm[ip][0] == "OFFSETN":
        ip+=1
        offset -= asm[ip[1]]
    elif asm[ip][0] == "RET":
        ip = mem[asm[ip[1]] + offset]
    elif asm[ip][0] == "PRINT":
        print(mem[asm[ip][1] + offset])
        ip+=1
        