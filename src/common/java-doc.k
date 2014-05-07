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

% For listing example programs
\usepackage{listings}

\newenvironment{markdown}%
    {\VerbatimEnvironment\begin{VerbatimOut}{tmp.markdown}}%
    {\end{VerbatimOut}%
        \immediate\write18{pandoc .latex\string\\tmp.markdown -t latex -o .latex\string\\tmp.tex}%
        \input{.latex\string\\tmp.tex}}

% Renders a reduction term on three lines. The first line is above the ruler
% Lines 2 and 3 are below the ruler. Useful to break long terms into multiple lines.
\newcommand{\reduceTopBottomBottom}[3]{\hbox{%
  \begin{tikzpicture}[baseline=(top.base),
                      inner xsep=0pt,
                      inner ysep=.3333ex,
                      minimum width=2em]
    \path node (top) {$#1$\strut}
          (top.south)
          node (bottom) [anchor=north, inner ysep=.5ex] {$#2$\strut}
					node (bottom) [anchor=north, inner ysep= 3ex] {$#3$\strut}; %this node is my contribution

    % Draw the horizontal line:
    \path[draw,thin,solid] let \p1 = (current bounding box.west),
                               \p2 = (current bounding box.east),
                               \p3 = (top.south)
                           in (\x1,\y3) -- (\x2,\y3);

    % Solid arrow (augmenting the solid line).
    \path[fill] (top.south) ++(2pt,0) -- ++(-4pt,0) -- ++(2pt,-1.5pt) -- cycle;
  \end{tikzpicture}%
}}

\lstset{language=Java,captionpos=t,tabsize=3,frame=no,keywordstyle=\color{blue},
        commentstyle=\color{gray},stringstyle=\color{red},
        breaklines=true,showstringspaces=false,emph={label},
        basicstyle=\ttfamily}

*/

