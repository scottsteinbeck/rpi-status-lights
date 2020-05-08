component {

    //LED Lights ID Mapping
    variables.ledIndex = {
        "weekdays": [31, 30, 29, 28, 27, 26, 25],
        "hours": [47, 48, 16, 19, 20, 23, 34, 33, 38, 39, 42, 44],
        "minutes": [46, 49, 17, 18, 21, 22, 35, 36, 37, 40, 41, 45],
        "temp": [15, 14, 13],
        "piStatus": [11, 10, 9, 8],
        "siteMonitor": [7, 6, 5, 4],
        "workMonitor": [3, 2, 1, 0],
        "pomodoro": [24],
        "calStat": [32],
        "genblink": [12],
        "wheatley": [43]
    };

    //Color Name to Hue index
    variables.colorIndex = {
        'red': 1,
        'orange': 40,
        'yellow': 60,
        'green': 100,
        'lightblue': 200,
        'blue': 250,
        'purple': 300
    };

    /* 
        Utility Functions
     */
    
    // Turn off LED by ID
    function turnOffLED(id,forceUpdate = false){
        variables.ledController.setPixelColourHSL(id,0,0,0);
        if(forceUpdate) updateLights();
    }

    // Set LED Hue by ID
    function setLEDHue(id,hue,forceUpdate = false){
        variables.ledController.setPixelColourHSL(id,hue,1,.5);
        if(forceUpdate) updateLights();
    }

    // Push light settings to the LEDs
    function updateLights(){
        variables.ledController.render();
    }

    // Blink light
    function blink(ledID,hue,delay,blinkNum){
        return runAsync(function(){
            for(var i=1; i <=blinkNum; i++){
                setLEDHue(ledID,i,true);
                sleep(delay);
                turnOffLED(ledID,true);
                sleep(delay);
            }
        })
    }

    // Get the corresponding color from a color range based on a percentage
    function colorScale(percent, lowColor, highColor){
        if(percent > 1) percent = 1;
        if(!isNumeric(lowColor)) lowColor = variables.colorIndex[lowColor];
        if(!isNumeric(highColor)) highColor = variables.colorIndex[highColor];
        var val = abs(lowColor -  highColor) * percent;
        if(highColor < lowColor) return lowColor - val;
        return lowColor + val;
    }


    /* 
        Helper functions / Mock functions 
    */

    // turn on lights one at a time for a given set 
    function cycleLights(key){
        var setHue = randRange(1,360);
        for(var i=1; i<=variables.ledIndex[key].len();i++ ){
            setLEDHue(variables.ledIndex[key][i],setHue + (i*5) );
            updateLights();
            sleep(100);
        }
    }

    function testLEDs(){
        for(var ledGroup in variables.ledIndex){
            print.line("#ledGroup#: #serializeJSON(variables.ledIndex[ledGroup])#").toConsole();
            cycleLights(ledGroup);
            sleep(1000);
        }
    }

    //Async health check
    function pingServer(id,siteURL){
        return runAsync(function(){
            cfhttp(method="GET", charset="utf-8", url=siteURL, result="result", timeout=5);
            return result;
        }).then(function(result){
            setLEDHue(variables.ledIndex['siteMonitor'][id],colorScale((result.status_code == 200 ? 1 : 0 ),'red','blue'),true);
        })
    }

    // TODO: make actually check via api/IFTTT
    function checkEmail(){ return randRange(1,100)/100}
    function checkSlack(){ return randRange(1,100)/100}
    function checkLastCommit(){ return randRange(1,100)/100}
    function checkIdleTime(){ return randRange(1,100)/100}
    function checkTweets(){
        var ledID = variables.ledIndex['genblink'][1];
        blink(ledID,randRange(1,360),100,6);        
    }
    function checkAppointements(){
        return runAsync(function(){
            var ledID = variables.ledIndex['calStat'][1];
            turnOffLED(ledID,true);
            if(randRange(0,1) == 0) return;
            for(var i=1; i <=5; i++){
                turnOffLED(ledID,true);
                sleep(300);
                variables.ledController.setPixelColourHSL(ledID,55,1,.8);
                sleep(60);
            }
        })
    }

    /* 
        Dashboard Functions
     */

    // update clock (Day of week, hours, minutes, pomodoro timer)
    function updateClock(){
        //Needs to be set here, or in the admin to ensure the correct time zone
        SetTimeZone(timezone='America/Los_Angeles'); 
        var currTime = now();

        var dow = datepart('w',currTime); //Day of the week 1-7
        var curr_hour = datepart('h',currTime); //Hour 24hr clock
        var curr_min = datepart('n',currTime); //Minutes

        var hourLEDIdx = variables.ledIndex['hours']; //led Index for hours
        var hourColor  = (curr_hour/24*60)+200; //Hour gradient starting at 200 (lightblue)
        
        var minuteLEDIdx = variables.ledIndex['minutes']; //led Index for minutes
        var minuteColor  = (curr_min/60*60)+30; //Minute gradient starting at 30 (purple)

        // Set day of the week
        for(var i = 1; i <= 7; i++){
            if(i == dow) {
                setLEDHue(variables.ledIndex['weekdays'][dow], 240);
            } else {
                // turn off all the rest of the days
                turnOffLED(variables.ledIndex['weekdays'][i]); 
            }
        }

        // update pomodoro clock (0-25 min.) (25-30 min. Red, Get up and move)
        var halftime = curr_min;
        var pomoLED = variables.ledIndex['pomodoro'][1];
        if(halftime > 30) halftime = halftime - 30;
        if(halftime <= 25){
            setLEDHue(pomoLED,colorScale(halftime/25,'green','purple'));            
        } else {
            blink(pomoLED,0,100,6);
        }


        if(curr_hour > 12) curr_hour = curr_hour - 12;//convert to 12hr 
        print.line("#currTime# -- #curr_hour# : #curr_min#").toConsole();
        for(var i=1; i<=hourLEDIdx.len();i++ ){
            if((i-1) <= curr_hour){
                setLEDHue(hourLEDIdx[i],hourColor + (i*5)); //(i*5) incrementing for color gradient/scale
            } else {
                // turn off all the rest of the hours
                turnOffLED(hourLEDIdx[i]);
            }
        }

        for(var i=1; i<=minuteLEDIdx.len();i++ ){
            if((i-1)*5 <= curr_min){
                setLEDHue(minuteLEDIdx[i],minuteColor + (i*5)); //(i*5) incrementing for color gradient/scale
            } else {
                // turn off all the rest of the min
                turnOffLED(minuteLEDIdx[i]);
            }
        }
        updateLights(); //update lights after everything is set
    }

    //Wheatley Robot rainbow colored eye
    function wheatleyBlink(){
        return runAsync(function(){
            var ledID = variables.ledIndex['wheatley'][1];
            for(var i=20; i <=360; i++){
                setLEDHue(ledID,i,true);sleep(60);
            }
        })
    }

    //Temperature Monitor
    //TODO: use api/onboard sensor to give temp scale
    function tempBlink(){
        return runAsync(function(){
            var randHue = randrange(60,220);
            for(var i=1; i <=variables.ledIndex['temp'].len(); i++){
                turnOffLED(variables.ledIndex['temp'][i],true);
            }
            sleep(200);
            for(var i=1; i <=variables.ledIndex['temp'].len(); i++){
                setLEDHue(variables.ledIndex['temp'][i],randHue + (i*5),true);sleep(200);
            }
        })
    }

    //Work Monitor (checkEmail, checkSlack, checkCommit, checkIdleTime, checkAppointement)
    function workMonitor(){
        setLEDHue(variables.ledIndex['workMonitor'][1],colorScale(checkEmail(),'lightblue','orange'));
        setLEDHue(variables.ledIndex['workMonitor'][2],colorScale(checkSlack(),'lightblue','orange'));
        setLEDHue(variables.ledIndex['workMonitor'][3],colorScale(checkLastCommit(),'lightblue','orange'));
        setLEDHue(variables.ledIndex['workMonitor'][4],colorScale(checkIdleTime(),'lightblue','orange'));
        checkAppointements();
        updateLights();
    }

    //Site Monitor (health check)
    function siteMonitor(){
            pingServer(1,"http://my.agritrackingsystems.com");
            pingServer(2,"http://app.cropcast.com");
            pingServer(3,"https://www.ortussolutions.com");
            pingServer(4,"https://www.google.com/");
    }

    //System Stats
    function SystemStats(){
        var  systemInfo=GetSystemMetrics(); //Get lucee System Metrics
	    var heap = getmemoryUsage("heap"); // Java heap usage
	    var nonHeap = getmemoryUsage("non_heap"); //Java Non-heap usage
        
        setLEDHue(variables.ledIndex['piStatus'][1],colorScale(systemInfo.cpuSystem,'green','red'));
        setLEDHue(variables.ledIndex['piStatus'][2],colorScale(heap.used/heap.max, 'green','red'));
        setLEDHue(variables.ledIndex['piStatus'][3],colorScale(systemInfo.queueRequests, 'green','red'));
        setLEDHue(variables.ledIndex['piStatus'][4],colorScale(randRange(0,1), 'green','red'));
        updateLights();
    }
    
    function run(){
        classLoad( '/home/pi/Desktop/lightStatus/lib/diozero-ws281x-java-0.11.jar' );

        var numOfLights = javacast('int',50);
        var freq = javacast('int',800000);
        var DMA = javacast('int',5);
        var pin = javacast('int',18);
        var brightness = javacast('int',200); //0-255
        var stripType = createObject("java","com.diozero.ws281xj.StripType");
        variables.ledController = createObject("java","com.diozero.ws281xj.rpiws281x.WS281x").init(freq,DMA,pin,brightness,numofLights,stripType.WS2811_RGB);
        var hueStart = 1;
        var lastRun = 0;

        variables.ledController.allOff();

        //testLEDs();
        while( true ) {
            var timeElapsedMs = GetTickCount() - lastRun;
            if(timeElapsedMs > 60000) {

                print.line("Running update #now()#").toConsole();
                wheatleyBlink();
                tempBlink();
                updateClock();
                SystemStats();
                workMonitor();
                siteMonitor();
                checkTweets();
                lastRun = GetTickCount();
            }
            sleep( 1000 ); //just a safety 
        }
    }

}