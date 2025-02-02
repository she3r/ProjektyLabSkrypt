var Drone = require('drone');  
var blocks = require('blocks');  
  
Drone.extend('zamekPK2', function() {  
    this.chkpt('zamekPK2')  
        .castleBase()  
        .castleWalls()  
        .castleTowers()
        .castleGate()  
        .castleRoof()
        .createLight()  
        .move('zamekPK2');  
});  

Drone.extend('createLight', function() {  
    this.move('zamekPK2').up(10).fwd(8).right(8).box('89', 4, 1, 4)
        .up();  
    return this;  
});  
  
Drone.extend('castleBase', function() {  
    this.box(blocks.stone, 20, 1, 10)
    .fwd(10)
    .box('35', 20, 1, 10)
    .move('zamekPK2') 
        .up();  
    return this;  
});  
  
Drone.extend('castleWalls', function() {  
    this.box0(blocks.gold, 20, 10, 20)
        .up(10);  
    return this;  
});  
  
Drone.extend('castleTowers', function() {  
    this  
        .move('zamekPK2')  
        .tower()  
        .move('zamekPK2')  
        .fwd(17)  
        .tower()  
        .move('zamekPK2')  
        .right(17)  
        .tower()  
        .move('zamekPK2')  
        .right(17)  
        .fwd(17)  
        .tower();  
    return this;  
});  
  
Drone.extend('tower', function() {  
    this.box('98', 3, 12, 3)  
        .up(12)  
        .box('98', 3, 1, 3)  
        .up();  
    return this;  
});  
  
Drone.extend('castleGate', function() {  
    this.move('zamekPK2')  
        .right(9)  
        .box(blocks.air, 2, 5, 1) 
    return this;  
});  


Drone.extend('castleRoof', function() {  
    this.move('zamekPK2')  
        .up(10)  
        .box('45', 20, 1, 20);
    return this;  
});  