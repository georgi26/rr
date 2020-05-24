RACC=racc
#RACCFLAGS=
RACCFLAGS=-g

objects= parse_c_if.rb calc.rb calc1.rb calc2.rb calc3.rb

all: $(objects)

clean:
	$(RM) $(objects)

.SUFFIXES: .y .rb

.y.rb:
	$(RACC) $(RACCFLAGS) $< -o $*.rb

