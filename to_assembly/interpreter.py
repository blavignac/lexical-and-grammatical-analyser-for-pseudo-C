lines = open("asm", "r").readlines()
asm = [l.split(" ") for l in lines]
asm = [[l[0]] + [int(x) for x in l[1:]] for l in asm]
mem = [0]*100
ip = 0
offset = 0
while ip<len(asm):
    if asm[ip][0] == "AFC":
        mem[asm[ip][1]] = asm[ip][2]
        ip+=1
    elif asm[ip][0] == "COP":
        mem[asm[ip][1]] = mem[asm[ip][2]]
        ip+=1
    elif asm[ip][0] == "ADD":
        mem[asm[ip][1]] = mem[asm[ip][2]] + mem[asm[ip][3]]
        ip+=1
    elif asm[ip][0] == "SUB":
        mem[asm[ip][1]] = mem[asm[ip][2]] - mem[asm[ip][3]]
        ip+=1
    elif asm[ip][0] == "MUL":
        mem[asm[ip][1]] = mem[asm[ip][2]] * mem[asm[ip][3]]
        ip+=1
    elif asm[ip][0] == "DIV":
        mem[asm[ip][1]] = mem[asm[ip][2]] / mem[asm[ip][3]]
        ip+=1
    elif asm[ip][0] == "JMP":
        ip = asm[ip][1]
    elif asm[ip][0] == "JMF":
        if (asm[ip][1] == 0):
            ip = asm[ip][2]
        ip+=1
        