package com.modelcloud.modules.business.utils;

import java.util.ArrayList;
import java.util.List;

/**
 * 将 OpenModelica getIconAnnotation 返回值渲染为 SVG。
 * 仅覆盖常见图元（Line/Rectangle/Ellipse/Polygon/Text），满足组件图标展示需求。
 */
public class ModelicaIconSvgRenderer {

    private ModelicaIconSvgRenderer() {}

    public static String render(String annotation) {
        if (annotation == null || annotation.isBlank()) {
            return "";
        }
        String trimmed = annotation.trim();
        if (!(trimmed.startsWith("{") && trimmed.endsWith("}"))) {
            return "";
        }

        List<String> top = splitTopLevel(trimmed.substring(1, trimmed.length() - 1));
        if (top.size() < 9) {
            return "";
        }

        double minX = parseDouble(top.get(0), -100);
        double minY = parseDouble(top.get(1), -100);
        double maxX = parseDouble(top.get(2), 100);
        double maxY = parseDouble(top.get(3), 100);
        String graphics = top.get(top.size() - 1).trim();
        if (!(graphics.startsWith("{") && graphics.endsWith("}"))) {
            return "";
        }

        double width = Math.max(1, maxX - minX);
        double height = Math.max(1, maxY - minY);
        double viewMinY = -maxY;

        StringBuilder body = new StringBuilder();
        List<String> items = splitTopLevel(graphics.substring(1, graphics.length() - 1));
        for (String item : items) {
            String element = renderItem(item.trim());
            if (!element.isBlank()) {
                body.append(element);
            }
        }

        if (body.length() == 0) {
            return "";
        }
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"" + minX + " " + viewMinY + " " + width + " " + height + "\">"
                + body + "</svg>";
    }

    private static String renderItem(String item) {
        if (item.startsWith("Line(")) return renderLine(item);
        if (item.startsWith("Rectangle(")) return renderRectangle(item);
        if (item.startsWith("Ellipse(")) return renderEllipse(item);
        if (item.startsWith("Polygon(")) return renderPolygon(item);
        if (item.startsWith("Text(")) return renderText(item);
        return "";
    }

    private static String renderLine(String text) {
        List<String> args = parseArgs(text, "Line");
        if (args.size() < 6 || !isVisible(args.get(0))) return "";
        List<double[]> points = parsePoints(args.get(3));
        if (points.size() < 2) return "";
        String color = parseColor(args.get(4), "#000000");
        double strokeWidth = parseDouble(args.get(6), 0.25);
        StringBuilder pointsAttr = new StringBuilder();
        for (double[] p : points) {
            if (pointsAttr.length() > 0) pointsAttr.append(" ");
            pointsAttr.append(p[0]).append(",").append(-p[1]);
        }
        return "<polyline fill=\"none\" stroke=\"" + color + "\" stroke-width=\"" + strokeWidth + "\" points=\"" + pointsAttr + "\"/>";
    }

    private static String renderRectangle(String text) {
        List<String> args = parseArgs(text, "Rectangle");
        if (args.size() < 11 || !isVisible(args.get(0))) return "";
        double[][] extent = parseExtent(args.get(9));
        if (extent == null) return "";
        double x1 = extent[0][0], y1 = -extent[0][1];
        double x2 = extent[1][0], y2 = -extent[1][1];
        double x = Math.min(x1, x2), y = Math.min(y1, y2);
        double w = Math.abs(x2 - x1), h = Math.abs(y2 - y1);
        String stroke = parseColor(args.get(3), "#000000");
        String fill = parseColor(args.get(4), "none");
        double strokeWidth = parseDouble(args.get(7), 0.25);
        return "<rect x=\"" + x + "\" y=\"" + y + "\" width=\"" + w + "\" height=\"" + h + "\" stroke=\"" + stroke
                + "\" stroke-width=\"" + strokeWidth + "\" fill=\"" + fill + "\"/>";
    }

    private static String renderEllipse(String text) {
        List<String> args = parseArgs(text, "Ellipse");
        if (args.size() < 10 || !isVisible(args.get(0))) return "";
        double[][] extent = parseExtent(args.get(8));
        if (extent == null) return "";
        double x1 = extent[0][0], y1 = -extent[0][1];
        double x2 = extent[1][0], y2 = -extent[1][1];
        double cx = (x1 + x2) / 2.0, cy = (y1 + y2) / 2.0;
        double rx = Math.abs(x2 - x1) / 2.0, ry = Math.abs(y2 - y1) / 2.0;
        String stroke = parseColor(args.get(3), "#000000");
        String fill = parseColor(args.get(4), "none");
        double strokeWidth = parseDouble(args.get(7), 0.25);
        return "<ellipse cx=\"" + cx + "\" cy=\"" + cy + "\" rx=\"" + rx + "\" ry=\"" + ry
                + "\" stroke=\"" + stroke + "\" stroke-width=\"" + strokeWidth + "\" fill=\"" + fill + "\"/>";
    }

    private static String renderPolygon(String text) {
        List<String> args = parseArgs(text, "Polygon");
        if (args.size() < 6 || !isVisible(args.get(0))) return "";
        List<double[]> points = parsePoints(args.get(3));
        if (points.size() < 3) return "";
        String stroke = parseColor(args.get(4), "#000000");
        String fill = parseColor(args.get(5), "none");
        double strokeWidth = parseDouble(args.get(8), 0.25);
        StringBuilder pointsAttr = new StringBuilder();
        for (double[] p : points) {
            if (pointsAttr.length() > 0) pointsAttr.append(" ");
            pointsAttr.append(p[0]).append(",").append(-p[1]);
        }
        return "<polygon points=\"" + pointsAttr + "\" stroke=\"" + stroke + "\" stroke-width=\"" + strokeWidth
                + "\" fill=\"" + fill + "\"/>";
    }

    private static String renderText(String text) {
        List<String> args = parseArgs(text, "Text");
        if (args.size() < 11 || !isVisible(args.get(0))) return "";
        double[][] extent = parseExtent(args.get(9));
        if (extent == null) return "";
        String str = unquote(args.get(10));
        if (str.isBlank()) return "";
        double x1 = extent[0][0], y1 = -extent[0][1];
        double x2 = extent[1][0], y2 = -extent[1][1];
        double x = (x1 + x2) / 2.0, y = (y1 + y2) / 2.0;
        String fill = parseColor(args.get(3), "#000000");
        return "<text x=\"" + x + "\" y=\"" + y + "\" fill=\"" + fill
                + "\" font-size=\"12\" text-anchor=\"middle\" dominant-baseline=\"middle\" transform=\"scale(1,-1) translate(0," + (-2 * y) + ")\">"
                + escapeXml(str) + "</text>";
    }

    private static List<String> parseArgs(String text, String fn) {
        String prefix = fn + "(";
        if (!text.startsWith(prefix) || !text.endsWith(")")) return new ArrayList<>();
        String content = text.substring(prefix.length(), text.length() - 1);
        return splitTopLevel(content);
    }

    private static boolean isVisible(String raw) {
        return "true".equalsIgnoreCase(String.valueOf(raw).trim());
    }

    private static double[][] parseExtent(String raw) {
        List<double[]> points = parsePoints(raw);
        if (points.size() < 2) return null;
        return new double[][]{points.get(0), points.get(1)};
    }

    private static List<double[]> parsePoints(String raw) {
        String t = String.valueOf(raw).trim();
        List<double[]> out = new ArrayList<>();
        if (!(t.startsWith("{") && t.endsWith("}"))) return out;
        String inner = t.substring(1, t.length() - 1).trim();
        if (inner.isEmpty()) return out;
        List<String> tuples = splitTopLevel(inner);
        for (String tuple : tuples) {
            String p = tuple.trim();
            if (!(p.startsWith("{") && p.endsWith("}"))) continue;
            List<String> xy = splitTopLevel(p.substring(1, p.length() - 1));
            if (xy.size() < 2) continue;
            out.add(new double[]{parseDouble(xy.get(0), 0), parseDouble(xy.get(1), 0)});
        }
        return out;
    }

    private static String parseColor(String raw, String fallback) {
        String t = String.valueOf(raw).trim();
        if (!(t.startsWith("{") && t.endsWith("}"))) return fallback;
        List<String> rgb = splitTopLevel(t.substring(1, t.length() - 1));
        if (rgb.size() < 3) return fallback;
        int r = clamp((int) Math.round(parseDouble(rgb.get(0), 0)));
        int g = clamp((int) Math.round(parseDouble(rgb.get(1), 0)));
        int b = clamp((int) Math.round(parseDouble(rgb.get(2), 0)));
        return String.format("#%02x%02x%02x", r, g, b);
    }

    private static int clamp(int v) {
        return Math.max(0, Math.min(255, v));
    }

    private static String unquote(String s) {
        String t = String.valueOf(s).trim();
        if (t.length() >= 2 && t.startsWith("\"") && t.endsWith("\"")) {
            t = t.substring(1, t.length() - 1);
        }
        return t.replace("\\\"", "\"");
    }

    private static String escapeXml(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static double parseDouble(String raw, double fallback) {
        try {
            return Double.parseDouble(String.valueOf(raw).trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private static List<String> splitTopLevel(String s) {
        List<String> result = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int paren = 0, brace = 0, bracket = 0;
        boolean inString = false;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '"' && (i == 0 || s.charAt(i - 1) != '\\')) {
                inString = !inString;
            }
            if (!inString) {
                if (c == '(') paren++;
                else if (c == ')') paren--;
                else if (c == '{') brace++;
                else if (c == '}') brace--;
                else if (c == '[') bracket++;
                else if (c == ']') bracket--;
            }
            if (c == ',' && !inString && paren == 0 && brace == 0 && bracket == 0) {
                result.add(current.toString().trim());
                current.setLength(0);
            } else {
                current.append(c);
            }
        }
        if (current.length() > 0) {
            result.add(current.toString().trim());
        }
        return result;
    }
}
