/*!
\title{Java Semantics}
\author{Denis Bogd\u{a}na\c{s}
        (\texttt{denis.bogdanas@info.uaic.ro})}
\organization{Alexandru Ioan Cuza University of Ia\c{s}i}

% Reduces page borders, now we can put more characters in one line
\usepackage{fullpage}

% Supports big angular brackets. Default amsmath brackets are limited to 3 lines.
\usepackage{yhmath}

% Required for integration with markdown
\usepackage{fancyvrb}

\newenvironment{markdown}%
    {\VerbatimEnvironment\begin{VerbatimOut}{tmp.markdown}}%
    {\end{VerbatimOut}%
        \immediate\write18{pandoc .latex\string\\tmp.markdown -t latex -o .latex\string\\tmp.tex}%
        \input{.latex\string\\tmp.tex}}

*/

