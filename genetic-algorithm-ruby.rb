# Kyle Rassweiler 2016-01-7

#Get the highest fitness and the gene sequence for it
def GetHighestFitness(population)
    iGeneIndex = 0 #Index of the gene with highest fitness
    fHighestFitness = 0.0 #Fitness value
    for iIndex in 0...population.length #Iterate population
        if population[iIndex].GetFitness > fHighestFitness
            fHighestFitness = population[iIndex].GetFitness
            iGeneIndex = iIndex
        end
    end
    hFitness = {"Gene" => population[iGeneIndex].GetGenesString, "Fitness" => fHighestFitness}
    return hFitness
end

#DNA class
class DNA
    def initialize(args)
        @iLength = 10
        @iLength = args["Length"] unless args["Length"].nil?
        @fFitness = 0.0
        @fMutation = 0.01
        @fMutation = args["Chance"] unless args["Chance"].nil?
        @aGenes = Array.new(@iLength)
    end
    
    #Fill gene array with random characters
    def RandomGenes
        @aGenes.map!{
            |x|
            b = Random.rand(32..127)
            x = b.chr
        }
    end
    
    #Fill gene array based on two parents
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
    
    #Mutate individual characters in the gene array
    def Mutate
        for i in 0...@iLength
            a = Random.rand(0.0..1.0)
            if a < @fMutation
                b = Random.rand(32..127)
                @aGenes[i] = b.chr
            end
        end
    end
    
    #Get the fitness of this instance
    def GetFitness
        return @fFitness
    end
    
    #Set the fitness of this instance based on a target string
    def SetFitness(target)
        score = 0
        for i in 0...@iLength
            if @aGenes[i] == target[i]
                score += 1
            end
        end
        @fFitness = score.to_f/target.length
    end
    
    #Get the gene array
    def GetGenes
        return @aGenes
    end
    
    #Get the gene array in string form
    def GetGenesString
        return @aGenes.join
    end
end

#Main program
#Setup parameters
puts "Mutation Rate? (best is 0.01)"
fMutationChance = gets.chomp.to_f
puts "Population Size? (best is 6000)"
iPopulationSize = gets.chomp.to_i
sTarget = "Welcome to the Shopify team!"
iTargetLength = sTarget.length
iGeneration = 0
aHistory = []

#Setup scenario
aPopulation = Array.new(iPopulationSize)
aGenePool = []
for i in 0...iPopulationSize
    aPopulation[i] = DNA.new({"Length" => iTargetLength, "Chance" => fMutationChance})
    aPopulation[i].RandomGenes
    aPopulation[i].SetFitness(sTarget)
end
fHighest = {}
fHighest['Fitness'] = 0.0

#Begin Circle Of Life
while fHighest['Fitness'] < 1.0
	#Increase generation count
    iGeneration += 1

    #Get highest fitness
    fHighest = GetHighestFitness(aPopulation)
    puts "Generation: #{iGeneration}\nHighest Fitness: #{fHighest['Fitness']*100}\nGene: #{fHighest['Gene']} :"
    
    #Save to history
    if iGeneration % 10 == 0
    	aHistory.push([iGeneration,fHighest['Fitness']*100])
    end

    #Fill mating pool
    for i in 0...iPopulationSize
        n = aPopulation[i].GetFitness*100
        for o in 0...n
            aGenePool.push(aPopulation[i].dup)
        end
    end

    #Clear population -- Alternative: Clear those below mean only
    aPopulation.clear

    #Refill population
    for i in 0...iPopulationSize
    	#Choose random parents
        p1 = Random.rand(iPopulationSize)
        p2 = Random.rand(iPopulationSize)

        #Ensure parents don't match
        while aGenePool[p1].GetGenesString == aGenePool[p2].GetGenesString
        	p2 = Random.rand(iPopulationSize)
        end

        #Create child
        c = DNA.new({"Length" => iTargetLength, "Chance" => fMutationChance})
        c.PopulateGenes({ "P1" => aGenePool[p1].GetGenes, "P2" => aGenePool[p2].GetGenes })
        c.Mutate
        c.SetFitness(sTarget)

        #Add child to population
        aPopulation.push(c.dup)
    end

    #Clear gene pool
    aGenePool.clear
end

#Clear population pool
aPopulation.clear

#Write History to file
File.open("History.txt", "w+") do |f|
  f.puts(aHistory)
end