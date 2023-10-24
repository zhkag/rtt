use serde_json::Value;
use std::fs::File;
use std::io::BufRead;
use std::io::BufReader;
use std::path::Path;
use std::env;
use std::process::{Command, Stdio};
use std::io;
use std::fs;
use std::fs::create_dir_all;
use std::io::Write;
use dirs::home_dir;
mod config;

struct ToolChain {
    name: String,
    prefix: String,
    path: String,
}

fn get_config_path(_path:&str) -> String{
    let root_config = env::current_exe().expect("REASON").parent().expect("REASON").to_str().unwrap().to_owned() + "/config/";
    let home_config = home_dir().expect("REASON").to_str().unwrap().to_owned()  + "/.config/";
    let prefix_paths = [
        ".rtt/".to_owned(),
        home_config,
        root_config.clone()
    ];
    for prefix in prefix_paths.iter(){
        if Path::new(&(prefix.to_owned() + _path)).exists() {
            return prefix.to_owned() + _path;
        }
    }

    println!("root_config:{:?}", root_config);
    if let Ok(metadata) = fs::metadata(root_config.clone()) {
        if metadata.is_file() {
        }
    }else {
        match create_dir_all(root_config.clone()) {
            Ok(_) => println!("{root_config} 目录创建成功"),
            Err(error) => panic!("无法创建目录: {:?}", error),
        }
    }
    let mut file = match File::create(root_config.to_owned() + _path) {
        Ok(file) => file,
        Err(error) => panic!("无法创建文件: {:?}", error),
    };

    // 写入内容到文件
    match file.write_all(config::initial().as_bytes()) {
        Ok(_) => println!("文件创建成功并写入内容"),
        Err(error) => panic!("无法写入文件内容: {:?}", error),
    }

    return root_config.to_owned() + _path;
}

fn get_tool(config:&Value) -> String {
    for (key, values) in config["tools"].as_object().unwrap() {
        for value in values.as_array().unwrap() {
            if Path::new(value.as_str().unwrap()).exists() {
                return key.to_string();
            }
        }
    }
    return "".to_string();
}

fn get_tool_chain(config:&Value) -> ToolChain {
    let current_path = env::current_dir().expect("REASON");
    let current_path = current_path.to_str().unwrap();
    let rtconfig = current_path.to_owned() + "/rtconfig.h";
    let mut smart_flag = "toolchains";

    if let Ok(metadata) = fs::metadata(rtconfig) {
        if metadata.is_file() {
            let file = File::open(current_path.to_owned()+"/rtconfig.h").expect("Failed to open file");
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
                smart_flag = "smarttoolchains";
            }
        }
    }

    let mut current_tool = ToolChain {
        name: String::from("arm"),
        prefix: String::from("arm-none-eabi-"),
        path: String::from("/bin"),
    };

    for (name, toolchain) in config[smart_flag].as_object().unwrap() {
        for bsp in toolchain["bsps"].as_array().unwrap() {
            if current_path.contains(bsp.as_str().unwrap()) {
                current_tool.name = name.to_string();
                current_tool.path = toolchain["path"].to_string().trim_matches('"').to_string();
                current_tool.prefix = toolchain["prefix"].to_string().trim_matches('"').to_string();
                return current_tool;
            }
        }
    }
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

    let path = "tools.json";
    let path = get_config_path(path);
    let file = File::open(path).unwrap();
    let reader = BufReader::new(file);

    let parsed:Value= serde_json::from_reader(reader).unwrap();
    if command == "" {
        command = get_tool(&parsed);
    }
    if command == "scons"{
        let current_tool_chain =  get_tool_chain(&parsed);
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
