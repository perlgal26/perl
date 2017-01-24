function makeRequest(url, divnames)
{
  var http_request = false;
  if (window.XMLHttpRequest) // Mozilla, Safari,...
    { 
      http_request = new XMLHttpRequest();
    }
  else if (window.ActiveXObject) // IE
    {
      try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
          }
      catch (e)
          {
            try
              {
                http_request = new ActiveXObject("Microsoft.XMLHTTP");
              }
            catch (e) {}
          }
    }

  if (!http_request)
    {
      alert('The request could not be initiated.  Please try again later, or contact Syvum for assistance.');
      return false;
    }

  http_request.onreadystatechange = function() { alertContents(http_request, divnames); };
  http_request.open('GET', url, true);
  http_request.send(null);
}

function alertContents(http_request, divnames)
{
  if (http_request.readyState == 4)
    {
      if (http_request.status == 200)
        {
          if (http_request.responseText.indexOf("<error>") >= 0)
            {
              var alertMsg = http_request.responseText.replace("<error>", "");
              var alertMsg = alertMsg.replace("</error>", "");
              alert(alertMsg);
            }
          else
            {
              var divContent = http_request.responseText.replace("</elem>","").split("<elem>");
              for (i = 0; i < divnames.length; i++)
                {
                  if (document.getElementById(divnames[i]) != null
                      && typeof document.getElementById(divnames[i]) != "undefined")
                    {
                      document.getElementById(divnames[i]).innerHTML = divContent[i+1];
                    }
                  else
                    {
                      alert ('Error updating result. ' + divnames[i] + ' was not found.');
                    }
                }
            }
        }
      else
        {
          alert('The request could not be completed.  Please try again later, or contact Syvum for assistance.');
        }
    }
}

