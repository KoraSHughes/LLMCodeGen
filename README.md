# CodeGen
An exploration in code & assertion generation with large language models. An explanation for the prompting schema, data acquisition, and methodology can be found [here, in my Master's thesis](https://www.proquest.com/docview/3059107595?sourcetype=Dissertations%20&%20Theses).

## Project Abstract:
Software assertions play a critical role in the creation of test benches and the overall verification of systems. In the case of formal property verification, complex design specifications are interpreted by industry experts and translated into System Verilog Assertions (SVA). Recent research has pointed toward large language models as a potential tool for SVA generation, however, lack of data and standardization of software assertions has resulted in mixed results amongst methods of evaluations. Thus, this paper proposes a dataset of code and natural language data containing assertions in SystemVerilog and Python that can be used to train and test future collaborative coding models. Additionally, this paper provides a preliminary analysis
vii and novel schema for the consistent generation of quality software assertions with
OpenAI’s GPT-4.

## A Brief Tour:
- Main Components:
  - <em>AllInOne.ipynb</em> is an aggregate of many of the processing files that includes code cleaning, prompt generation, and analysis. For more information on textbook analysis see <em>GPT-ImageScrapper.ipynb</em>.
  - <em>Data/exploration.ipynb</em> gathers statistics and other visual analytics from the asserted supervised, asserted unsupervised, and textbook datasets.
  - <em>Organized Dataset/*</em> contains cleaned results, prompts, image directories, & LLM responses.
    - The majority of this is focused on asserted code with the notable exception of <em>Organized Dataset/Verilog Textbook Code/*</em> which is all interpreted Verilog code.
  - <em>Data/*</em> Contains most of the intermediary states of data as it is processed.
    - <em>Data/BigQuery/*</em> contains the raw code data from Google Cloud.
    - <em>Data/Data/example-code/supervised-textbook/*</em> contains the raw & partially-processed textbook data.
    - <em>Data/example-code/verilog examples/open-titan/*</em> contains the raw & partially-processed testbench data.
- generally helpful documents:
  - <em>Gpt-Tutorial.ipynb</em> has a brief overview of how to query openai's api & automate the process of extracting LLM-generated code
  - <em>GPTest.ipynb</em> shows the train of thought and some preliminary analysis done with LLM responses.

#### Key:
- any file with "supervised" in the title is related to the connection between a piece of code's behavioral description (as given by an LLM) and the code-text itself.
  - likewise anything "unsupervised" relates exclusively to the code its assertions.
- any file with "response" entails an LLM output.

> For further questions feel free to reach me at [korashughes+github@gmail.com](malito:korashughes+github@gmail.com)
