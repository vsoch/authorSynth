# This script will plot authorBrain maps on the SOM grid of neuroSynth images.  This
# is done by matching the authorBrains to each of the best matching units,
# and rendering the scores as the color on the plot.

# Load the SOM,labels
load('/scratch/users/vsochat/DATA/BRAINMAP/dimensionality_reduction/som/brainMap.Rda')
load('/scratch/users/vsochat/DATA/BRAINMAP/dimensionality_reduction/icaMatch/SZOvsHCMatrix.Rda')

# We need to define a color scale that indicates the strength of the match score
colorscale = brewer.pal(9,"YlOrRd")
colorscale = colorRampPalette(brewer.pal(8,"YlOrRd"))(100)

# The coordinates in so$grid$pts that we plot match the image names, so we need to order the matrix
# by the filename.  First extract the numbers
#imageNames = colnames(data)
#imageNames = as.numeric(gsub("_beststats.txt","",gsub("2mmbrainGrid","",imageNames)))
#idx = sort(imageNames,index.return=TRUE)
#data = data[,colnames(data)[idx$ix]]

# This is our color palette
rbPal <- colorRampPalette(brewer.pal(8,"YlOrRd"))

# This is match scores for one compobent to all images - the range is the max match score for all images
test = data[1,]
test = c(0,as.numeric(test),max(data))

#This adds a column of color values
# based on the y values
color = rbPal(10)[as.numeric(cut(test,breaks = 10))]
color = color[-c(1,508)]

plot(brainMap$som$grid$pts,main="Which BrainTerms Maps are Similar?",col=color,xlab="Nodes",ylab="Nodes",pch=15,cex=6)
text(brainMap$som$grid$pts,brainMap$labels,cex=.6)



### Draw plot of counts coloured by the 'Set3' pallatte
br.range <- seq(min(rand.data),max(rand.data),length.out=10)
results <- sapply(1:ncol(rand.data),function(x) hist(rand.data[,x],plot=F,br=br.range)$counts)
plot(x=br.range,ylim=range(results),type="n",ylab="Counts")
cols <- brewer.pal(8,"Set3")
lapply(1:ncol(results),function(x) lines(results[,x],col=cols[x],lwd=3))

### Draw a pie chart
table.data <- table(round(rand.data))
cols <- colorRampPalette(brewer.pal(8,"YlOrRd"))(100)
pie(table.data,col=cols)


plot(so)
