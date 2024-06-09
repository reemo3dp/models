$fn=180;
gauge(4, 1, 2.8);

module gauge(baseHeight, letterExtrusionHeight, keyDiameter) {
	difference() {
		union() {
			hull() {
				difference() {
					union() {
						cylinder(h=4,d=145);
					}
					union() {
						rotate(-4) translate([0,-80,-1]) cube([80,80,10]);
						rotate(4) translate([-80,-80,-1]) cube([80,160,10]);
					}
				}
				cylinder(h=4,d=10);
			}
			color("red") for (index =[0:15]) {
				angle = index * 360/-60;
                texts = str(index);
                
				rotate(45+ angle,[0,0,1]) translate([47,47,4]) {
					linear_extrude(letterExtrusionHeight) 
                        polygon([[3,3],[0,-2.5],[-2.5,0]]);
				}
				rotate(angle,[0,0,1]) translate([0,59,4]) {
					linear_extrude(letterExtrusionHeight) 
                        text(texts,size=3,font="Nimbus Mono:style=bold",halign = "center");
				}
			}
			cylinder(h=6,d=10);
		}
		union() {
			translate([0,0,-1]) cylinder(h=10,d=keyDiameter);
		}
	}
}
