/* */

document.querySelectorAll("a").forEach(function(anchor) {
  anchor.onclick = function () {
    checkVisible(anchor);
  };
});

document.querySelectorAll(".toc span").forEach(function(span) {
  span.onclick = function () {
    toggleToC(span);
  };
});

document.querySelectorAll(".module-title").forEach(function(title) {
  title.onclick = function () {
    toggleInstructions(title);
  };
});

["variable", "param", "function", "template"].forEach(function(cname) {
  let sel = ".unused-" + cname + "s";
  document.querySelectorAll(sel).forEach(function(span) {
    span.onclick = function () {
      toggleUnused(span, cname, 'not-used');
    };
  });

  sel = ".onlyused-" + cname + "s";
  document.querySelectorAll(sel).forEach(function(span) {
    span.onclick = function () {
      toggleUnused(span, cname, 'only-used');
    };
  });

  if (cname === "variable") {
    sel = ".shadow";
    document.querySelectorAll(sel).forEach(function(span) {
      span.onclick = function () {
        toggleUnused(span, cname, 'shadow');
      };
    });
  }
});

/* ============================================================ */

function toggleToC(span) {
  const div = span.parentNode;
  const ul = div.querySelector("ul");

  if (span.classList.contains('closed')) {
    span.classList.replace('closed', 'open');
    ul.style.display = "block";
  } else {
    span.classList.replace('open', 'closed');
    ul.style.display = "none";
  }
};

function toggleInstructions(title) {
  const div = title.parentNode;
  const body = div.querySelectorAll(":scope > .instructions").forEach(function(idiv) {
    idiv.querySelectorAll(":scope > div").forEach(function(vdiv) {
      if (title.classList.contains('closed')) {
        vdiv.style.display = "block";
      } else {
        vdiv.style.display = "none";
      }
    });
  });

  if (title.classList.contains('closed')) {
    title.classList.replace('closed', 'open');
  } else {
    title.classList.replace('open', 'closed');
  }
};

function toggleUnused(span, cname, sel) {
  console.log("Toggle unused:", cname, sel);
  let div = span.parentNode.parentNode.parentNode;
  div.querySelectorAll(":scope > .instructions").forEach(function(idiv) {
    idiv.querySelectorAll(`${'div.' + cname}`).forEach(function(vdiv) {
      if (vdiv.classList.contains(sel)) {
        if (vdiv.style.display === "block") {
          vdiv.style.display = "none";
        } else {
          vdiv.style.display = "block";
        }
      }
    });
  });
};

function checkVisible(anchor) {
  if (anchor.getAttribute("href").startsWith("#")) {
    const id = anchor.getAttribute("href").substring(1);
    let target = document.querySelector("#"+id);

    while (target instanceof HTMLElement) {
      const style = window.getComputedStyle(target);
      if (style.display === "none") {
        if (target.tagName === "SPAN") {
          target.style.display = "inline";
        } else { 
          target.style.display = "block";
        }
      }
      target = target.parentNode;
    }
  }
}
