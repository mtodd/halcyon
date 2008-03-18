<?php

// Halcyon PHP Client
// Created by Matt Todd <chiology@gmail.com>
// Copyright (c) 2008, Matt Todd <http://purl.org/net/maraby>
// MIT License applies to this library

class Halcyon {
  
  const VERSION = "0.1.0";
  
  private $uri = array('host' => 'localhost', 'port' => 4647, 'scheme' => 'http');
  
  public function __construct($uri = null) {
    if($uri) $this->uri = parse_url($uri);
  }
  
  protected function get($path) {
    return $this->request(array(
      'method' => 'GET',
      'path' => $path
    ));
  }
  
  protected function post($path, $data) {
    return $this->request(array(
      'method' => 'POST',
      'path' => $path,
      'body' => $data
    ));
  }
  
  protected function delete($path) {
    return $this->request(array(
      'method' => 'DELETE',
      'path' => $path
    ));
  }
  
  protected function put($path, $data) {
    return $this->request(array(
      'method' => 'PUT',
      'path' => $path,
      'body' => $data
    ));
  }
  
  private function request($request) {
    $connection = fsockopen($this->uri['host'], $this->uri['port']);
    if($connection) {
      // connected
      $req = "{$request['method']} {$request['path']} HTTP/1.1\r\n";
      $req .= "Content-Type: application/json\r\n";
      $req .= "User-Agent: JSON/1.2.1 Compatible (en-US) Halcyon::Client/0.5.0";
      $req .= "Connection: close\r\n";
      $req .= "\r\n";
      if($request['body']) $req .= http_build_query($request['body']) . "\r\n\r\n";
      
      if(fwrite($connection, $req)) {
        $response = '';
        while(!feof($connection)) {
          $response .= fgets($connection, 256); // throw new HalcyonError("Error receiving response."));
        }
        fclose($connection); // throw new HalcyonError("Error closing connection.");
        
        $response = end(split("\r\n\r\n", $response, 2));
        
        return json_decode($response);
      } else {
        throw new HalcyonError("Request failed to send.");
      }
    } else {
      // connection failed
      throw new HalcyonError("Unable to connect to server {$this->uri['host']}:{$this->uri['port']}.");
    }
  }
  
}

class HalcyonError extends Exception {}

?>
