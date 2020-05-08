<cfscript>
try{
    application.ledController.setPixelColourHSL(url.i,url.h,url.s/100,url.l/100);  
    application.ledController.render();
	writeOutput('{"success":true}');
} catch (e){
	writeOutput('{"success":false}');
}
</cfscript>