package main

import (
	"net/http"
	"encoding/json"
	"strings"
	"io/ioutil"
	"fmt"
	"os"
	"encoding/base64"
	"bytes"
)

type MathpixV3LatexParam struct {
	Src     string   `json:"src"`
	Formats []string `json:"formats"`
	Url     string   `json:"url"`
}

type DetectionMap struct {
	ContainsChart   int     `json:"contains_chart"`
	ContainsDiagram float32 `json:"contains_diagram"`
	ContainsGraph   int     `json:"contains_graph"`
	ContainsTable   int     `json:"contains_table"`
	IsBlank         float32 `json:"is_blank"`
	IsInverted      int     `json:"is_inverted"`
	IsNotMath       float32 `json:"is_not_math"`
	IsPrinted       float32 `json:"is_printed"`
}

type Position struct {
	Height   int `json:"height"`
	TopLeftX int `json:"top_left_x"`
	TopLeftY int `json:"top_left_y"`
	Width    int `json:"width"`
}

type MathpixV3LatexResult struct {
	DetectionList       []string     `json:"detection_list"`
	DetectionMap        DetectionMap `json:"detection_map"`
	Error               string       `json:"error"`
	LatexConfidence     float64      `json:"latex_confidence"`
	LatexConfidenceRate float64      `json:"latex_confidence_rate"`
	LatexList           []string     `json:"latex_list"`
	LatexNormal         string       `json:"latex_normal"`
	LatexStyled         string       `json:"latex_styled"`
	Position            Position     `json:"position"`
}

func (mathpixV3LatexResult *MathpixV3LatexResult) String() string {
	b, err := json.Marshal(*mathpixV3LatexResult)
	if err != nil {
		return fmt.Sprintf("%+v", *mathpixV3LatexResult)
	}
	var out bytes.Buffer
	err = json.Indent(&out, b, "", "    ")
	if err != nil {
		return fmt.Sprintf("%+v", *mathpixV3LatexResult)
	}
	return out.String()
}

func main() {
	filePath := os.Args[1]
	imageByte, err := ioutil.ReadFile(filePath)
	if err != nil{
		fmt.Println(err.Error())
		return
	}

	mathpixV3LatexParam := new(MathpixV3LatexParam)
	mathpixV3LatexParam.Src = "data:image/jpg;base64," + base64.URLEncoding.EncodeToString(imageByte)
	mathpixV3LatexParam.Formats = []string{"latex_normal", "latex_styled"}

	client := &http.Client{}
	data, err := json.Marshal(mathpixV3LatexParam)
	req, err := http.NewRequest("POST", "https://api.mathpix.com/v3/latex", strings.NewReader(string(data)))
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("app_id", "trial")
	req.Header.Set("app_key", "34f1a4cea0eaca8540c95908b4dc84ab")
	resp, err := client.Do(req)
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	//fmt.Println(string(body))

	if err != nil {
		fmt.Println(err.Error())
		return
	}
	mathpixV3LatexResult := new(MathpixV3LatexResult)
	err = json.Unmarshal(body,&mathpixV3LatexResult)
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Println(mathpixV3LatexResult.String())
}
