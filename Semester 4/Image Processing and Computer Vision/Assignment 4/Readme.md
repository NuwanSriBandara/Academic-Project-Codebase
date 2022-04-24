Image classification task on [CIFAR10 dataset](https://www.cs.toronto.edu/~kriz/cifar.html) through:
  1) a linear classifier 
  2) a two-layer fully connected network with H = 200 hidden nodes with sigmoid function as the activation function for the hidden nodes while having no activation function at the output layer
  3) a two-layer fully connected network with H = 200 hidden nodes with stochastic gradient descent with a batch size of 500
  4) a convolutional neural network with the configuration: C32, C64, C64, F64, F10. All three convolutions layers are 3x3. Max pooling (2x2) follows each convolution layer while using SDG (with momentum) with a batch size of 50 and CategoricalCrossentropy as the loss
