#Get the highest fitness and the gene sequence for it
def GetHighestFitness(pop)
    g = 0
    highest = 0.0
    for i in 0...pop.length
        if pop[i].GetFitness > highest
            highest = pop[i].GetFitness
            g = i
        end
    end
    fH = {"Gene" => pop[g].GetGenesString, "Fitness" => highest}
    return fH
end

#DNA class
class DNA
    def initialize(args)
        @iLength = 10
        @iLength = args["Length"] unless args["Length"].nil?
        @fFitness = 0.0
        @fMutation = 0.01
        @aGenes = Array.new(@iLength)
    end
    
    def RandomGenes
        @aGenes.map!{
            |x|
            b = Random.rand(32..127)
            x = b.chr
        }
    end
    
    def PopulateGenes(args)
        aP1 = args["P1"] unless args["P1"].nil?
        aP2 = args["P2"] unless args["P2"].nil?
        for i in 0...@iLength
        	iMid = Random.rand(0..1)
            if iMid == 1
                @aGenes[i] = aP1[i]
            else
                @aGenes[i] = aP2[i]
            end
        end
    end
    
    def Mutate
        for i in 0...@iLength
            a = Random.rand(0.0..1.0)
            if a < @fMutation
                b = Random.rand(32..127)
                @aGenes[i] = b.chr
            end
        end
    end
    
    def GetFitness
        return @fFitness
    end
    
    def SetFitness(target)
        score = 0
        for i in 0...@iLength
            if @aGenes[i] == target[i]
                score += 1
            end
        end
        @fFitness = score.to_f/target.length
    end
    
    def GetGenes
        return @aGenes
    end
    
    def GetGenesString
        return @aGenes.join
    end
end

#Main program===========================================================================
puts "Mutation Rate? (best is 0.01)"
fRate = gets.chomp.to_f
puts "Population Size? (best is 5000)"
iPop = gets.chomp.to_i
sTarget = "Welcome to the Shopify team!"
#sTarget = "Super Test Test Test"
iL = sTarget.length
gen = 0
aHistory = []

#Setup scenario
aPopulation = Array.new(iPop)
aPool = []
for i in 0...iPop
    aPopulation[i] = DNA.new({"Length" => iL})
    aPopulation[i].RandomGenes
    aPopulation[i].SetFitness(sTarget)
end
fHighest = {}
fHighest['Fitness'] = 0.0
#Begin Circle Of Life
while fHighest['Fitness'] < 1.0
	#Increase generation count
    gen += 1

    #Get highest fitness
    fHighest = GetHighestFitness(aPopulation)
    puts "Generation: #{gen}\nHighest Fitness: #{fHighest['Fitness']*100}\nGene: #{fHighest['Gene']} :"
    
    #Save to history
    if gen % 10 == 0
    	aHistory.push([gen,fHighest['Fitness']*100])
    end

    #Fill mating pool
    for i in 0...iPop
        n = aPopulation[i].GetFitness*100
        for o in 0...n
            aPool.push(aPopulation[i].dup)
        end
    end

    #Clear population -- Alternative: Clear those below mean only
    aPopulation.clear

    #Refill population
    for i in 0...iPop
    	#Choose random parents
        p1 = Random.rand(iPop)
        p2 = Random.rand(iPop)

        #Ensure parents don't match
        while aPool[p1].GetGenesString == aPool[p2].GetGenesString
        	p2 = Random.rand(iPop)
        end

        #Create child
        c = DNA.new({"Length" => iL})
        c.PopulateGenes({ "P1" => aPool[p1].GetGenes, "P2" => aPool[p2].GetGenes })
        c.Mutate
        c.SetFitness(sTarget)

        #Add child to population
        aPopulation.push(c.dup)
    end

    #Clear gene pool
    aPool.clear
end

#Write History to file
File.open("History.txt", "w+") do |f|
  f.puts(aHistory)
end