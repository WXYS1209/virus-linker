##### Visualization #####
plot_linker = function(df, threshold_min, threshold_max, proteins){
  if (is.null(df)) {
    return(NULL)
  }
  
  ## Filter the data set
  df = df  %>% 
    filter(atom1 %in% proteins,
           atom2 %in% proteins) %>% 
    mutate(self_link = atom1 == atom2,
           in_threshold = (distance >= threshold_min & 
                             distance <= threshold_max),
           dist_plot = ifelse(in_threshold, distance, NA),
           color = if_else(self_link, atom1, paste0(atom1, atom2)))
  
  
  if (dim(df)[1] == 0 | threshold_min == threshold_max) {
    return(NULL)
  }
  
  ## Create graph
  edge_list = df %>%
    select(atom1_name, atom2_name, dist_plot)
  
  graph = graph_from_data_frame(edge_list, directed = FALSE)
  
  E(graph)$width = 1/edge_list$dist_plot
  
  atoms = unique(c(df$atom1, df$atom2))
  E(graph)$color = df$color
  
  atom_names = list()
  for (i in 1:length(atoms)){
    atom_names[[i]] = unique(c(edge_list$atom1_name[df$atom1==atoms[i]], 
                                 edge_list$atom2_name[df$atom2==atoms[i]]))
  }
  
  ## Layout
  xx = rep(1, length(atoms))
  yy = (1:length(atoms))*10
  XX = c()
  YY = c()
  
  for (i in 1:length(V(graph)$name)){
    for (j in 1:length(atom_names)){
      if (V(graph)$name[i] %in% atom_names[[j]]){
        XX = c(XX, xx[j])
        YY = c(YY, yy[j])
        xx[j] = xx[j] + 5 
      }
    }
  }
  
  for (k in 1:length(atom_names)){
    pro = which(YY == yy[k])
    XX[pro] = XX[pro][rank(V(graph)$name[pro])]
  }
  
  V(graph)$x = XX

  V(graph)$y = YY
  
  ## Plot
  p = ggraph(graph, layout = 'manual', x = V(graph)$x, y = V(graph)$y) +
    geom_edge_arc(aes(width = width,
                      alpha = width, 
                      color = factor(color)), 
                  strength = 0.2) +
    geom_node_point(shape = 19, size = 1) +
    geom_node_text(aes(label = name),
                   # vjust = 1.5,
                   hjust = -0.3,
                   size = 2.5,
                   angle = -90,
                   repel = T) +
    labs(edge_color = "Interaction type",
         edge_alpha = "1/distance",
         edge_width = "1/distance") +
    ggtitle("Virus Linker")
  
  p
}



