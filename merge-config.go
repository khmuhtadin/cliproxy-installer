package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Model struct {
	ModelDisplayName string `json:"model_display_name"`
	Model            string `json:"model"`
	BaseURL          string `json:"base_url"`
	APIKey           string `json:"api_key"`
	Provider         string `json:"provider"`
}

type Config struct {
	CustomModels []Model `json:"custom_models"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: merge-config <existing-config> <new-models-config>")
		os.Exit(1)
	}
	existingPath := os.Args[1]
	newPath := os.Args[2]

	existingBytes, err := os.ReadFile(existingPath)
	if err != nil {
		fmt.Printf("Error reading existing config: %v\n", err)
		os.Exit(1)
	}
	var existingConfig Config
	if err := json.Unmarshal(existingBytes, &existingConfig); err != nil {
		fmt.Printf("Error parsing existing config: %v\n", err)
		os.Exit(1)
	}

	newBytes, err := os.ReadFile(newPath)
	if err != nil {
		fmt.Printf("Error reading new models config: %v\n", err)
		os.Exit(1)
	}
	var newConfig Config
	if err := json.Unmarshal(newBytes, &newConfig); err != nil {
		fmt.Printf("Error parsing new models config: %v\n", err)
		os.Exit(1)
	}

	existingMap := make(map[string]bool)
	for _, m := range existingConfig.CustomModels {
		existingMap[m.Model] = true
	}

	addedCount := 0
	for _, m := range newConfig.CustomModels {
		if !existingMap[m.Model] {
			existingConfig.CustomModels = append(existingConfig.CustomModels, m)
			existingMap[m.Model] = true
			addedCount++
		}
	}

	if addedCount > 0 {
		outBytes, err := json.MarshalIndent(existingConfig, "", "    ")
		if err != nil {
			fmt.Printf("Error marshaling config: %v\n", err)
			os.Exit(1)
		}
		if err := os.WriteFile(existingPath, outBytes, 0644); err != nil {
			fmt.Printf("Error writing config: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("✓ Merged %d new models into config\n", addedCount)
	} else {
		fmt.Println("✓ No new models to add - all models already exist")
	}
}
