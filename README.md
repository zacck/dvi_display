## DVI IP

Initially this was simple and thats perhaps my day job is in video and I have rehearsed this over and over.
Also perhaps the fact that I have worked on a VGA IP before albeit this one seems more concrete and understandable to me.


The day did not end as simply at it began, the tm_choice module is the shortest module I have written yet it took me quite a few 
hours. 

1. System verilog is not programming, you do not have time as a line to use for computations, these are hardware signals not 
programming variables.
2. When using combinational concepts please stick to combinational items, this includes not using logic or reg and using wires only 
3. Loops especially in combinational code will not work how you expect.
4. Don't be clever, do it the way they do it not how you do it.

## TMDS
The differential signaling on TMDS is not that hard, well its already figured out and all we have to do is follow 
a standard. Do it on paper, confirm some conditions from GTKWAVE on paper. It helps in internalization.

## Initial Learnings before Testing 
- Differential pins are routed differently and you will need to find them in the board schematic DUH!
- TMDS is both a protocol and has its own IO standard, opens the door to LVDS 
- We are using SERDES wow! all of a sudden! so basically a really fast pwm style Deserialiser?
- I should likely move the SERDES and Clocking modules to System Verilog so I have the advantage of logic type 


There is still quite a bit from this stage to look into, SERDES, IOBUFS and maybe a MMCME revisit
