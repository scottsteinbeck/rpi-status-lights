component {
  
    function run(){
        classLoad( '/home/pi/Desktop/lightStatus/lib/diozero-ws281x-java-0.11/diozero-ws281x-java-0.11.jar' );

        var freq = 800000; //Default 
        var DMA = 5; //Default
        var pin = 18; // GPIO Pin
        var numOfLights = 50;
        var brightness = 100; //0-255
      	
      	// RGB, GBR, BGR
        var stripType = createObject("java","com.diozero.ws281xj.StripType"); 
        var ledController = createObject("java","com.diozero.ws281xj.rpiws281x.WS281x").init(freq,DMA,pin,brightness,numofLights,stripType.WS2811_RGB);
              
        for(var ledID=0; ledID < 50; ledID++ ){
            //( ledID * 5) just uses the (ledID x 5) as the color to make a gradient
            ledController.setPixelColourHSL(ledID,(ledID * 5),.8,.05); 
            ledController.render(); //have to render after set
            sleep(300);
        }
    }
}