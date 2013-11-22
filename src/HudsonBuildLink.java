import java.io.IOException;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * 
 */

/**
 * @author EneK
 *
 */
public class HudsonBuildLink {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//System.out.println("Running ... " + args[0]);
		// TODO Auto-generated method stub
		byte[] text = new byte[1024*100];
		try {
			int bytes = System.in.read(text);
			String file = new String(text).substring(0, bytes);
			Pattern p = Pattern.compile(
"<a href=\"lastSuccessfulBuild/artifact/\">Last Successful Artifacts</a><ul>(?:<li>.*?</li>)*?<li><a href=\"([^\"]*?\\.zip)\">",
 Pattern.MULTILINE);

			// Так возьмет лишнее на проектах с несколькими выходными файлами - ([^\"]*?\\.zip)
			//p = Pattern.compile("<a href=\"([^\"]*?\\.zip)\">", Pattern.MULTILINE);
			Matcher m = p.matcher(file);
			if (m.find()){
				System.out.println(m.group(1));
			} else {
				System.err.println("No link matched in file.");
				// Код завершения почему-то всегда УСПЕШНЫЙ
				// Предполагавшийся вариан использования кода завершения:
				// java.exe HudsonBuildLink <file.htm 2>nul && echo OK || echo ERROR
				System.exit(1);
			}
		} catch (IOException e) {
			
		}

	}

}
