#!/usr/bin/env python3
"""Independent reference for breakout_game: prints the playfield after N ticks as 120 lines of 160 chars (no input)."""
import sys
def run(n):
    bx,by,vx,vy,padx,lives,bricks,idle=80,90,1,2,68,3,(1<<50)-1,0
    for _ in range(n):
        nx,ny,nvx,nvy,np=bx+vx,by+vy,vx,vy,padx
        if idle!=180: idle+=1
        else:
            if bx+1<padx+10 and padx>4: np=padx-2
            elif bx+1>padx+14 and padx<132: np=padx+2
        padx=np
        if nx<2: nx=2; nvx=abs(vx)
        if nx>154: nx=154; nvx=-abs(vx)
        if ny<2: ny=2; nvy=abs(vy)
        if vy>0 and ny+3>=108 and ny<=110 and nx+3>np and nx<np+24:
            ny=105; nvy=-2; off=nx+1-(np+12)
            nvx=-2 if off<-8 else -1 if off<0 else 1 if off<8 else 2
        cx,cy=nx+1,ny+1; clear=None
        if 14<=cy<54 and (cy-14)%8<6 and 10<=cx<150:
            idx=((cy-14)//8)*10+(cx-10)//14
            if bricks>>idx&1: clear=idx; nvy=-nvy
        nb=bricks
        if clear is not None: nb&=~(1<<clear)
        dead=ny>=118
        if dead:
            if lives==1: lives=3; nb=(1<<50)-1
            else: lives-=1
            nx,ny,nvx,nvy=80,90,1,2
        elif bricks==0:          # RTL tests the brick set from before this tick
            nb=(1<<50)-1; nx,ny,nvx,nvy=80,90,1,2
        bricks=nb
        bx,by,vx,vy=nx,ny,nvx,nvy
    return bx,by,padx,lives,bricks
def frame(st):
    bx,by,padx,lives,bricks=st; out=[]
    for y in range(120):
        row=''
        for x in range(160):
            on = y<2 or x<2 or x>=158 or (padx<=x<padx+24 and 108<=y<111) or (bx<=x<bx+3 and by<=y<by+3)
            if 14<=y<54 and 10<=x<150:
                bxr,byr=x-10,y-14
                if bxr%14<13 and byr%8<6 and bricks>>((byr//8)*10+bxr//14)&1: on=True
            if 114<=y<118 and 6<=x<24 and (x-6)%6<4 and (x-6)//6<lives: on=True
            row+='#' if on else '.'
        out.append(row)
    return out
if __name__=='__main__':
    print('\n'.join(frame(run(int(sys.argv[1])))))
