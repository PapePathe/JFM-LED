Chartkick.options = {
  height: "400px",
  colors: ["#b00", "#666"]
}
Chartkick.options[:html] = '<div id="%{id}" style="height: %{height};">Loading...</div>'
Chartkick.options[:content_for] = :charts_js
