use serde_json::Value;
use std::fs::File;
use std::io::BufRead;
use std::io::BufReader;
use std::env;
use std::process::{Command, Stdio};
use std::io;
use std::fs;
use std::io::Write;
mod config;
mod path;

struct ToolChain {
    name: String,
    prefix: String,
    path: String,
}

fn get_tool(config:&Value) -> String {
    for (key, values) in config["tools"].as_object().unwrap() {
        for value in values.as_array().unwrap() {
            if std::path::Path::new(value.as_str().unwrap()).exists() {
                return key.to_string();
            }
        }
    }
    return "".to_string();
}

fn remove_long_path_prefix(path: &str) -> String {
    if path.starts_with("\\\\?\\") {
        path[4..].replace("\\", "\\\\")
    } else {
        path.replace("\\", "\\\\")
    }
}

fn is_smart(rtconfig:&str) -> usize{
    if let Ok(metadata) = fs::metadata(rtconfig) {
        if metadata.is_file() {
            let file = File::open(rtconfig).expect("rtconfig Failed to open file");
            let reader = io::BufReader::new(file);
            let mut contains_string = false;
            for line in reader.lines() {
                if let Ok(line) = line {
                    if line.contains("RT_USING_SMART") {
                        contains_string = true;
                        break;
                    }
                }
            }
            if contains_string {
                return 1;
            }
        }
    }
    0
}

fn norm_tool_path(path:&String,config_path:&str, name:&str) -> String{
    let root_config = env::current_exe().expect("REASON").parent().expect("REASON").to_str().unwrap().to_owned();
    if config_path.contains(&root_config) && path.starts_with("."){
        let path = std::path::Path::new(config_path).join("../").join(path.clone());
        if !std::path::Path::new(&path).exists() {
            cmd(&("scoop install ".to_owned() + name));
        }
        let absolute_path = path.canonicalize().expect("工具链路径有问题，尽量不要用相对路径！！");
        return remove_long_path_prefix(absolute_path.to_str().unwrap_or("")).to_string();
    }
    path.to_string()
}

fn get_tool_chain(config:&Value,config_path:&str) -> ToolChain {
    let current_path = env::current_dir().expect("REASON");
    let current_path = current_path.to_str().unwrap();
    let rtconfig = current_path.to_owned() + "/rtconfig.h";
    let smart_flags = ["toolchains", "smarttoolchains"];

    let mut current_tool = ToolChain {
        name: String::from("arm"),
        prefix: String::from("arm-none-eabi-"),
        path: String::from("/bin"),
    };

    for flag in &smart_flags[is_smart(&rtconfig)..] {
        for (name, toolchain) in config[flag].as_object().unwrap() {
            for bsp in toolchain["bsps"].as_array().unwrap() {
                if current_path.contains(bsp.as_str().unwrap()) {
                    current_tool.name = name.to_string();
                    current_tool.path = toolchain["path"].to_string().trim_matches('"').to_string();
                    current_tool.prefix = toolchain["prefix"].to_string().trim_matches('"').to_string();
                    #[cfg(target_os = "windows")]
                    {
                        current_tool.path = norm_tool_path(&current_tool.path,&config_path,name);
                    }
                    return current_tool;
                }
            }
        }
    }
    let default_tool_name = "rt-gcc-arm-none-eabi";
    let default_tool_path = config["toolchains"][default_tool_name]["path"].as_str().unwrap().to_string();
    current_tool.name = default_tool_name.to_string();
    current_tool.path = norm_tool_path(&default_tool_path,&config_path,default_tool_name);
    current_tool.prefix = config["toolchains"][default_tool_name]["prefix"].as_str().unwrap().to_string();
    return current_tool;
}

fn cmd(command:&str) {
    let (cmd, cmd_c);
    #[cfg(target_os = "linux")]
    {
    cmd = "sh";
    cmd_c = "-c";
    }
    #[cfg(target_os = "windows")]
    {
    cmd = "powershell";
    cmd_c = "-command";
    }
    println!("{cmd}:{cmd_c}:{command}");
    let mut child = Command::new(cmd)
        .arg(cmd_c)
        .arg(command)
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
        .expect("Failed to execute command");

    let status = child.wait()
        .expect("Failed to wait for {command}");

    if status.success() {
        println!("{command} executed successfully");
    } else {
        println!("{command} failed");
    }
}

fn get_build_tool() -> Vec<String>{
    let args: Vec<String> = env::args().collect();
    let mut only_args: Vec<String> = Vec::new();
    let mut command = "".to_string();
    let mut command_prefix:String = "".to_string();
    if args.len() > 1{
        let menuconfigs = [
            "--menu",
            "--menuconfig",
            "menu",
            "menuconfig"
        ];
        for menuconfig in menuconfigs.iter(){
            if &args[1] == menuconfig{
                #[cfg(target_os = "linux")]
                {
                    command = "scons --menuconfig".to_string();
                }
                #[cfg(target_os = "windows")]
                {
                    command = "menuconfig".to_string();
                }
                only_args = (&args[2..]).to_vec();
                break;
            }
        }
        if command != "".to_string(){}
        else if args[1].starts_with("-") {
            only_args = (&args[1..]).to_vec()
        }
        else {
            command = args[1].clone();
            only_args = (&args[2..]).to_vec()
        }
    }

    let mut rets = Vec::new();

    let config_path = "tools.json";
    let config_path = path::config(config_path,config::initial().as_bytes());
    let file = File::open(config_path.clone()).unwrap();
    let reader = BufReader::new(file);

    let parsed:Value= serde_json::from_reader(reader).unwrap();
    if command == "" {
        command = get_tool(&parsed);
    }
    if command == "scons"{
        let current_tool_chain =  get_tool_chain(&parsed,&config_path);
        #[cfg(target_os = "linux")]
        {
        command_prefix = format!("export RTT_CC_PREFIX={} && export RTT_EXEC_PATH={} && ", current_tool_chain.prefix,current_tool_chain.path);
        }
        #[cfg(target_os = "windows")]
        {
        command_prefix = format!("$env:RTT_CC_PREFIX=\"{}\";$env:RTT_EXEC_PATH=\"{}\";", current_tool_chain.prefix,current_tool_chain.path);
        }
    }
    
    rets.push(command_prefix);
    rets.push(command);
    rets.push(only_args.join(" "));

    rets
}

fn main() {
    cmd(&(get_build_tool().join(" ")));
}
