# Chinese Restaurant Process mixtures in Gen

This is a draft for a Gen tutorial.
[Gen](https://www.gen.dev/)  is a general-purpose probabilistic programming system, embedded in Julia.

**Overview:**

In **Part 1** I start by recalling the definition of the [Chinese Restaurant Process](https://en.wikipedia.org/wiki/Chinese_restaurant_process) (CRP) and a mixture model based on it. 

Then, in **Part 2**, I proceed with an approximate inference model - mostly to get comfortable with Gen. I present more sophisticated models as described in (Neal, 2000) for instance and aim more for performance in Part 3.

(Finally, in Part 3, I will use a MH approach from (Neal, 2000) to solve the inference problem. This is in its earliest stage. This is under heavy construction and in its earliest stage...)

The notebooks don't always render right on Github, so here are links to the notebooks in Jupyter's "nbviewer":

- [Part 1 - CRP Model only.ipynb](https://nbviewer.jupyter.org/github/mirkoklukas/CRP-mixtures-in-Gen/blob/draft/Part%201%20-%20CRP%20Model%20only.ipynb) 
- [Part 2 - Inference only.ipynb](https://nbviewer.jupyter.org/github/mirkoklukas/CRP-mixtures-in-Gen/blob/draft/Part%202%20-%20Inference%20only.ipynb)
- [Part 3 - MH Inference.ipynb](https://nbviewer.jupyter.org/github/mirkoklukas/CRP-mixtures-in-Gen/blob/draft/Part%203%20-%20MH%20Inference.ipynb)
