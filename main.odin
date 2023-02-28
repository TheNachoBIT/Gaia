package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"
import "core:c/libc"
import "core:encoding/json"

Join :: proc(target: string, add: string) -> string
{
	a := [?]string { target, add };
	b := strings.concatenate(a[:]);
	return b;
}

to_u8array :: proc(target: string) -> []u8
{
	chars := transmute([]u8) target;

	return chars;
}

CreateJSON :: proc(project: string)
{
	content := "{\n";

	content = Join(content, "\t\"project\": \"");
	content = Join(content, project);
	content = Join(content, "\",\n");

	content = Join(content, "\t\"version\": \"1.0.0\",\n\n");

	content = Join(content, "\t\"dependencies\": \n\t{\n");
	content = Join(content, "\t}\n");

	content = Join(content, "}\n");

	path := project;
	path = Join(path, "/Gaia.json");

	os.write_entire_file(path, to_u8array(content));
}

CreateHellope :: proc(project: string)
{
	content := "package main\n\n";

	content = Join(content, "import \"core:fmt\"\n\n");

	content = Join(content, "main :: proc() {\n");
	content = Join(content, "\tfmt.println(\"Hellope!\");\n");
	content = Join(content, "}\n");

	path := project;
	path = Join(path, "/main.odin");

	os.write_entire_file(path, to_u8array(content));
}

CreateProject :: proc(name: string)
{
	fmt.print("Creating Gaia Project \"");
	fmt.print(name);
	fmt.print("\"...");

	os.make_directory(name);

	CreateJSON(name);

	CreateHellope(name);
}

GetPath :: proc(source: string, name: string, repo: string) -> string
{
	link: string = "";
	if(source == "github")
	{
		link = Join(link, "https://github.com/");
	}
	else { fmt.panicf("Error: This current source is not available."); }

	link = Join(link, name);
	link = Join(link, "/");
	link = Join(link, repo);

	return link;
}

GetPackages :: proc() -> bool
{
	data, ok := os.read_entire_file_from_filename("Gaia.json");

	if !ok
	{
		fmt.println("Error: Gaia.json is not found.");
		return false;
	}

	defer delete(data);

	json_data, err := json.parse(data);

	if err != .None
	{
		fmt.println("Error: A JSON Parsing error in Gaia.json has been found.");
		fmt.println("Reason: ", err);
		return false;
	}

	defer json.destroy_value(json_data);

	root := json_data.(json.Object);

	//fmt.println("Routes:");
	deps := root["dependencies"];
	for name, path in deps.(json.Object)
	{
    	link := strings.split(path.(json.String), ":");
    	
    	fullPath := GetPath(link[0], link[1], name);

    	fmt.println(fullPath);

    	cmd := Join("git clone ", fullPath);
    	cmd = Join(cmd, " _packages/");
    	cmd = Join(cmd, name);

    	libc.system(strings.clone_to_cstring(cmd));
	}

	return true;
}

Welcome :: proc()
{
	fmt.println("Welcome to Gaia!\n");

	fmt.println("Gaia is a Package Manager/Toolbox for the");
	fmt.println("ODIN Programming Language that helps you providing:\n");

	fmt.println("- Easy use of external libraries.");
	fmt.println("- Simple project setups.");
	fmt.println("- Helpful automation.\n");

	fmt.println("and more...\n");

	fmt.println("To get started, type 'gaia help'.");
}

Hello :: proc()
{
	fmt.println("Hi! :D");
}

main :: proc()
{
	if(len(os.args) > 1)
	{
		if(os.args[1] == "create")
		{
			if(len(os.args) > 2) { CreateProject(os.args[2]); }
			else 				 { fmt.println("Error: Name not set!"); }
		}
		else if(os.args[1] == "hello") { Hello(); }
		else if(os.args[1] == "get") 
		{ 
			if !GetPackages() { return; }
		}
	}
	else { Welcome(); }
}