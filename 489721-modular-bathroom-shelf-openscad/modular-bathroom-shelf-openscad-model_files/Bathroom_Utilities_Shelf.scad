depth = 50;
anchorHeight = 24;
anchorThickness = 3;
height = 3.6;
cornerRadius = 10;

/**
 * Format for render_modules is:
 [ module_name | [module_name | [module_name, alignment] ]
 e.g.:

 * Render a philips sonicare holder:
 render_modules(["philips_sonicare"]);

 * Render a philips sonicare holder and a tepe holder in the back behind each other 
 render_modules([ ["philips_sonicare", "tepe_interdental_short_back"] ]);

 * Render a soniccare holder and a connector (right aligned) behind each other
 render_modules([ ["philips_soniccare", ["connector_left", "right"] ]);
**/

render_modules(
    [
        [ "tepe_interdental_short", "tepe_interdental_short_back" ],
        "tepe_intertepe_interdental_short_angle_long",
        "philips_sonicare",
//        ["holder", "philips_sonicare"],
//        [["connector_left", "right"]],
//        "empty_long",
//        [["connector_right", "left"]],
//        ["holder", "philips_sonicare"],
        "philips_sonicare",
        "tepe_intertepe_interdental_short_angle_long",
        [ "tepe_interdental_short", "tepe_interdental_short_back" ],
    ],
    height,
    depth,
    anchorHeight,
    anchorThickness);

module_widths = [
    [ "spacer_small", 10 ],
    [ "spacer_regular", 30 ],
    [ "philips_sonicare", 30 ],
    [ "tepe_intertepe_interdental_short_angle_long", 30 ],
    [ "tepe_interdental_short", 30 ],
    [ "tepe_interdental_short_back", 30 ],
    [ "holder", 20 ],
    [ "connector_left", 15 ],
    [ "connector_right", 15 ],
    [ "empty_long", 20 ]
];

function width_for_module(mod) =
    let(index = search([is_list(mod) ? mod[0] : mod],
                       module_widths)[0]) module_widths[index][1];

module
switch_render_module(mod, height, depth, anchorHeight, anchorThickness)
{
    if (mod == "philips_sonicare") {
        philips_sonicare_module(height, depth, anchorHeight, anchorThickness);
    } else if (mod == "tepe_intertepe_interdental_short_angle_long") {
        tepe_intertepe_interdental_short_angle_long_module(
            height, depth, anchorHeight, anchorThickness);
    } else if (mod == "tepe_interdental_short") {
        tepe_interdental_short_module(
            height, depth, anchorHeight, anchorThickness);
    } else if (mod == "tepe_interdental_short_back") {
        tepe_interdental_short_back_module(
            height, depth, anchorHeight, anchorThickness);
    } else if (mod == "holder") {
        holder_module(height, depth, anchorHeight, anchorThickness);
    } else if (mod == "spacer_small") {
        base(width_for_module("spacer_small"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
    } else if (mod == "spacer_regular") {
        base(width_for_module("spacer_regular"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
    } else if (mod == "connector_left") {
        connector_left_module(height, depth, anchorHeight, anchorThickness);
    } else if (mod == "connector_right") {
        connector_right_module(height, depth, anchorHeight, anchorThickness);
    }
}

module
multi_switch_render_module(mods, height, depth, anchorHeight, anchorThickness)
{
    max_width = max([for (mod = mods) width_for_module(mod)]);

    difference()
    {
        for (p_mod = mods) {
            alignment = is_list(p_mod) ? p_mod[1] : "center";
            mod = is_list(p_mod) ? p_mod[0] : p_mod;
            width = width_for_module(mod);
            xOffset = alignment == "center"
                          ? (max_width - width) / 2
                          : (alignment == "left" ? 0 : (max_width - width));
            if (width < max_width) {
                base(xOffset, height, depth, anchorHeight, anchorThickness);
                translate([ xOffset + width, 0, 0 ])
                    base((max_width - width - xOffset),
                         height,
                         depth,
                         anchorHeight,
                         anchorThickness);
            }
            translate([ xOffset, 0, 0 ]) switch_render_module(
                mod, height, depth, anchorHeight, anchorThickness);
        }

        for (p_mod = mods) {
            alignment = is_list(p_mod) ? p_mod[1] : "center";
            mod = is_list(p_mod) ? p_mod[0] : p_mod;
            width = width_for_module(mod);
            difference()
            {
                xOffset = alignment == "center"
                              ? (max_width - width) / 2
                              : (alignment == "left" ? 0 : (max_width - width));
                base(max_width, height, depth, anchorHeight, anchorThickness);
                if (width < max_width) {
                    base(xOffset, height, depth, anchorHeight, anchorThickness);
                    translate([ xOffset + width, 0, 0 ])
                        base((max_width - width - xOffset),
                             height,
                             depth,
                             anchorHeight,
                             anchorThickness);
                }
                translate([ xOffset, 0, 0 ]) switch_render_module(
                    mod, height, depth, anchorHeight, anchorThickness);
            }
        }
    }
}

module
render_module(mod, remaining, height, depth, anchorHeight, anchorThickness)
{
    width = is_list(mod) ? max([for (m = mod) width_for_module(m)])
                         : width_for_module(mod);
    render(convexity = 4)
    {
        difference()
        {
            if (is_list(mod)) {
                multi_switch_render_module(
                    mod, height, depth, anchorHeight, anchorThickness);
            } else {
                switch_render_module(
                    mod, height, depth, anchorHeight, anchorThickness);
            }

            if (len(remaining) == 0) {
                translate([ width, 0, 0 ]) mirror([ 1, 0, 0 ]) cornerLeft(
                    cornerRadius, height, depth, anchorHeight, anchorThickness);
            }
        }
        if (len(remaining) > 0) {
            rest = len(remaining) > 1
                       ? [for (i = [1:len(remaining) - 1]) remaining[i]]
                       : [];
            translate([ width, 0, 0 ]) render_module(remaining[0],
                                                     rest,
                                                     height,
                                                     depth,
                                                     anchorHeight,
                                                     anchorThickness);
        }
    }
}

module
render_modules(modules, height, depth, anchorHeight, anchorThickness)
{
    rest = len(modules) > 1 ? [for (i = [1:len(modules) - 1]) modules[i]] : [];
    color("#EFEFEE") render() difference()
    {
        render_module(
            modules[0], rest, height, depth, anchorHeight, anchorThickness);
        cornerLeft(cornerRadius, height, depth, anchorHeight, anchorThickness);
    }
}

module
connector_left_module(height, depth, anchorHeight, anchorThickness)
{
    width = width_for_module("connector_left");
    base(width, height, depth, anchorHeight, anchorThickness);

    linear_extrude(height / 2) translate([ width, depth - 20, 0 ])
        polygon(points = [ [ 0, 0 ], [ 0, 10 ], [ 10, 14 ], [ 10, -4 ] ]);
}

module
connector_right_module(height, depth, anchorHeight, anchorThickness)
{
    width = width_for_module("connector_right");
    difference()
    {
        base(width, height, depth, anchorHeight, anchorThickness);

        linear_extrude(height / 2 + 0.5) translate([ 0, depth - 20, 0 ])
            offset(delta = 0.04) polygon(
                points = [ [ 0, 0 ], [ 0, 10 ], [ 10, 14 ], [ 10, -4 ] ]);
    }
}

module
holder_module(height, depth, anchorHeight, anchorThickness)
{
    width = width_for_module("holder");
    yLoc = depth - 10 - 12;
    union()
    {
        base(width, height, depth, anchorHeight, anchorThickness);
        difference()
        {
            translate([ (width - 15) / 2, yLoc, height ]) cube([ 15, 12, 7 ]);
            translate([ (width - 15) / 2, yLoc + 6, height + 7 + 4 ])
                rotate([ 0, 90, 0 ]) cylinder(h = 15, r = 6, $fn = 100);
        }
    }
}

module
tepe_interdental_short_module(height, depth, anchorHeight, anchorThickness)
{
    difference()
    {
        base(width_for_module("tepe_interdental_short"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
        tepe_interdental_short_cutout(height, depth);
    }
}

module
tepe_interdental_short_back_module(height, depth, anchorHeight, anchorThickness)
{
    difference()
    {
        base(width_for_module("tepe_interdental_short_back"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
        translate([ 0, (depth - 11) / 2, 0 ])
            tepe_interdental_short_cutout(height, depth);
    }
}

module
tepe_interdental_short_cutout(height, depth)
{
    width = width_for_module("tepe_intertepe_interdental_short_angle_long");
    translate([ width / 2, 11, 1 ])
        linear_extrude(height - 1, scale = [ 14.4 / 10, 1 ])
            square(size = [ 10, 5.6 ], center = true);
    translate([ width / 2, 11, 0 ]) linear_extrude(1)
        square(size = [ 9, 5.6 ], center = true);
    translate([ width / 2, 11, 0 ]) linear_extrude(height)
        circle(d = 9.6, $fn = 100);

    translate([ width / 2 - (14.4 / 2) + 5.6 / 2, 11 - 5.6 / 2, height ])
        rotate([ -90, 0, 0 ]) cylinder(h = 5.6, r = 5.6 / 2, $fn = 100);
    translate([ width / 2 + (14.4 / 2) - 5.6 / 2, 11 - 5.6 / 2, height ])
        rotate([ -90, 0, 0 ]) cylinder(h = 5.6, r = 5.6 / 2, $fn = 100);
}

module
tepe_intertepe_interdental_short_angle_long_module(height,
                                                   depth,
                                                   anchorHeight,
                                                   anchorThickness)
{
    difference()
    {
        base(width_for_module("tepe_intertepe_interdental_short_angle_long"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
        tepe_intertepe_interdental_short_angle_long_cutout(height, depth);
    }
}

module
tepe_intertepe_interdental_short_angle_long_cutout(height, depth)
{
    width = width_for_module("tepe_intertepe_interdental_short_angle_long");
    translate([ width / 2, 11, 0 ])
        linear_extrude(height, scale = [ 13.1 / 10, 1 ])
            square(size = [ 10, 5.4 ], center = true);
    translate([ width / 2 - 4, 0, 0 ]) cube([ 8, 11, height ]);
}

module
philips_sonicare_module(height, depth, anchorHeight, anchorThickness)
{
    difference()
    {
        base(width_for_module("philips_sonicare"),
             height,
             depth,
             anchorHeight,
             anchorThickness);
        philips_sonicare_cutout(height, depth);
    }
}

module
philips_sonicare_cutout(height, depth)
{
    // Width
    let(width = width_for_module("philips_sonicare"))
    {
        translate([ width / 2, 10, 0 ])
        {
            translate([ 0, 0, (1 - 2.6 / 3.6) * height ])
                cylinder(h = height * 2.6 / 3.6, r1 = 6, r2 = 8, $fn = 100);
            cylinder(h = height * (1 - 2.6 / 3.6), r = 6, $fn = 100);
        }
        translate([ width / 2 - (9.5 / 2), 0, 0 ]) cube([ 9.5, 11, height ]);
    }
}

module
base(width, height, depth, anchorHeight, anchorThickness)
{
    scale([ width, 1, 1 ])
        baseNormal(height, depth, anchorHeight, anchorThickness);
}

module
baseNormal(height, depth, anchorHeight, anchorThickness)
{
    difference()
    {
        cube([ 1, depth, height ]);
        difference()
        {
            translate([ 0, 0, height / 2 ]) cube([ 1, height / 2, height / 2 ]);
            translate([ 0, height / 2, height / 2 ]) rotate([ 0, 90, 0 ])
                cylinder(h = 1, r = height / 2, $fn = 100);
        }
    }
    translate([ 0, depth, 0 ]) cube([ 1, anchorThickness, anchorHeight ]);
}

module
cornerLeft(radius, height, depth, anchorHeight, anchorThickness)
{
    difference()
    {
        translate([ 0, depth, anchorHeight - radius ])
            cube([ radius, anchorThickness, radius ]);
        translate([ radius, depth + anchorThickness, anchorHeight - radius ])
            rotate([ 90, 0, 0 ])
                cylinder(h = anchorThickness, r = radius, $fn = 100);
    }
    difference()
    {
        cube([ radius, radius, height ]);
        translate([ radius, radius, 0 ])
            cylinder(h = height, r = radius, $fn = 100);
    }
}
module
cornerRight(radius, height, depth, anchorHeight, anchorThickness)
{
    mirror([ 1, 0, 0 ])
        cornerLeft(radius, height, depth, anchorHeight, anchorThickness);
}