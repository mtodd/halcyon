<?php

require(dirname(__FILE__).'/../lib/halcyon.php');

class Sparrow extends Halcyon {
  public function greet($name) {
    return $this->get("/greet/{$name}");
  }
}

try {
  $client = new Sparrow('http://localhost:4647/');
  print($client->greet($argv[1] ? $argv[1] : 'Matt')->body . "\n");
} catch(HalcyonError $e) {
  print("ERROR: " . $e->getMessage() . "\n");
}

?>
