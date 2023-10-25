use std::fs::File;
use std::env;
use std::fs;
use std::fs::create_dir_all;
use std::io::Write;
use dirs::home_dir;

fn write_file(file:&str, root_config:&String, tools_config:&[u8]){
    if let Err(_error) = fs::metadata(root_config.clone()) {
        match create_dir_all(root_config.clone()) {
            Ok(_) => println!("{root_config} 目录创建成功"),
            Err(error) => panic!("无法创建目录: {:?}", error),
        }
    }
    let file_path = root_config.to_owned() + file;
    if let Err(_error) = fs::metadata(file_path.clone()) {
        let mut file_fd = match File::create(file_path) {
            Ok(file) => file,
            Err(error) => panic!("无法创建文件: {:?}", error),
        };
        // 写入内容到文件
        match file_fd.write_all(tools_config) {
            Ok(_) => println!("文件创建成功并写入内容"),
            Err(error) => panic!("无法写入文件内容: {:?}", error),
        }
    }
}

pub fn config(file:&str, tools_config:&[u8]) -> String{
    let root_config = env::current_exe().expect("REASON").parent().expect("REASON").to_str().unwrap().to_owned() + "/config/";
    let home_config = home_dir().expect("REASON").to_str().unwrap().to_owned()  + "/.config/";
    let prefix_paths = [
        ".rtt/".to_owned(),
        home_config,
        root_config.clone()
    ];
    write_file(&file,&root_config,tools_config);
    for prefix in prefix_paths.iter(){
        if std::path::Path::new(&(prefix.to_owned() + file)).exists() {
            return prefix.to_owned() + file;
        }
    }
    return root_config.to_owned() + file;
}
