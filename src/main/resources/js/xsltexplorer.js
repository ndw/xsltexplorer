/* XSLT Explorer JS */

document.querySelectorAll("a").forEach(function(anchor) {
  anchor.onclick = function () {
    checkVisible(anchor);
  };
});

[".toc span", ".lot span", ".lof span"].forEach(function(sel) {
  document.querySelectorAll(sel).forEach(function(span) {
    span.onclick = function () {
      toggleToC(span);
    };
  });
});

document.querySelectorAll(".title.closed").forEach(function(title) {
  title.onclick = function() {
    toggleBody(title);
  };
});

["unused", "shadows", "elsewhere"].forEach(function(note) {
  document.querySelectorAll("span."+note).forEach(function(span) {
    let itype = null;
    span.classList.forEach(function(cname) {
      if (cname !== note) {
        itype = cname;
      }
    });
    span.onclick = function() {
      const div = span.parentNode.parentNode.parentNode;
      if (div && div.classList.contains("stylesheet")) {
        toggleInstructions(div, [itype, note]);
      }
    };
  });
});

["template", "variable", "function", "param"].forEach(function(note) {
  document.querySelectorAll("span.all."+note).forEach(function(span) {
    span.onclick = function() {
      const div = span.parentNode.parentNode.parentNode;
      if (div && div.classList.contains("stylesheet")) {
        toggleInstructions(div, [note]);
      }
    };
  });
});

/* ============================================================ */

function toggleToC(span) {
  const div = span.parentNode;
  let list = div.querySelector("ul");
  if (!list) {
    list = div.querySelector("dl");
  }

  if (span.classList.contains('closed')) {
    span.classList.replace('closed', 'open');
    list.style.display = "block";
  } else {
    span.classList.replace('open', 'closed');
    list.style.display = "none";
  }
};

function toggleBody(title) {
  const div = title.parentNode;
  div.querySelectorAll(".body > div").forEach(function(idiv) {
    if (title.classList.contains('closed')) {
      idiv.style.display = "block";
    } else {
      idiv.style.display = "none";
    }
  });

  if (title.classList.contains('closed')) {
    title.classList.replace('closed', 'open');
  } else {
    title.classList.remove('open');
    title.classList.remove("halfopen");
    title.classList.add("closed");
  }
};

function toggleInstructions(div, classes) {
  const root = div.querySelector(":scope > .instructions");
  let display = null;
  let someOpen = false;
  let someClosed = false;
  root.querySelectorAll(".body > div").forEach(function(div) {
    let match = true;
    classes.forEach(function(name) {
      match = match && div.classList.contains(name);
    });

    const style = window.getComputedStyle(div);

    console.log(match, style.display, div);

    if (match) {
      if (style.display === "none") {
        div.style.display = "block";
        display = "block";
        someOpen = true;
      } else {
        div.style.display = "none";
        display = "none";
        someClosed = true;
      }
    } else {
      someOpen = someOpen || (style.display === "block");
      someClosed = someClosed || (style.display === "none");
    }
  });

  const title = root.querySelector(":scope > .title");
  title.classList.remove("open");
  title.classList.remove("closed");
  title.classList.remove("halfopen");
  if (someOpen) {
    if (someClosed) {
      title.classList.add("halfopen");
    } else {
      title.classList.add("open");
    }
  } else {
    title.classList.add("closed");
  }
};

function checkVisible(anchor) {
  const regex = /^#line-[0-9a-fA-F]+-[0-9]+$/;

  if (anchor.getAttribute("href").startsWith("#")) {
    const id = anchor.getAttribute("href");
    let llink = id.match(regex);
    // For reasons I don't understand, this sometimes returns null.
    // let target = document.querySelector(id);
    let target = document.getElementById(id.substring(1));

    while (target instanceof HTMLElement) {
      // Side-effect: if it's a link to a line in source,
      // display the line number.
      if (llink !== null) {
        const lno = target.querySelectorAll(":scope > .lno").forEach(function(span) {
          span.style.display = "inline";
        });
        llink = null;
      }

      const style = window.getComputedStyle(target);
      if (style.display === "none") {
        console.log("make visible:", target);
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
