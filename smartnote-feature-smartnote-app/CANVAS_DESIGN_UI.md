<!-- Design System -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>SmartNote - Note Editor</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&amp;family=Roboto+Flex:wght@400;500&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "on-tertiary-container": "#d8d6dd",
                    "surface": "#fff8f6",
                    "surface-variant": "#e9e1df",
                    "surface-container-low": "#fbf2f0",
                    "background": "#fff8f6",
                    "error": "#ba1a1a",
                    "on-secondary-fixed": "#3b0809",
                    "on-primary-fixed": "#17124b",
                    "surface-container-high": "#efe6e4",
                    "surface-bright": "#fff8f6",
                    "on-secondary-container": "#793734",
                    "on-primary-fixed-variant": "#434078",
                    "primary-fixed": "#e3dfff",
                    "on-surface-variant": "#47464f",
                    "on-error-container": "#93000a",
                    "secondary-fixed": "#ffdad7",
                    "inverse-surface": "#342f2e",
                    "inverse-primary": "#c4c0ff",
                    "surface-container-lowest": "#ffffff",
                    "secondary": "#904a46",
                    "error-container": "#ffdad6",
                    "surface-tint": "#5b5892",
                    "tertiary-fixed-dim": "#c7c6cc",
                    "surface-container-highest": "#e9e1df",
                    "secondary-fixed-dim": "#ffb3ae",
                    "primary": "#423f78",
                    "on-tertiary-fixed": "#1b1b20",
                    "tertiary-container": "#5d5d63",
                    "on-tertiary": "#ffffff",
                    "on-primary-container": "#d6d3ff",
                    "on-surface": "#1e1b1a",
                    "on-secondary": "#ffffff",
                    "outline-variant": "#c8c5d1",
                    "surface-dim": "#e1d8d6",
                    "on-background": "#1e1b1a",
                    "outline": "#787680",
                    "inverse-on-surface": "#f8efed",
                    "on-primary": "#ffffff",
                    "primary-container": "#5a5791",
                    "surface-container": "#f5ecea",
                    "secondary-container": "#fea49d",
                    "on-error": "#ffffff",
                    "primary-fixed-dim": "#c4c0ff",
                    "tertiary-fixed": "#e3e1e8",
                    "on-tertiary-fixed-variant": "#46464c",
                    "tertiary": "#45464b",
                    "on-secondary-fixed-variant": "#733330"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px",
                    "2xl": "1rem",
                    "3xl": "1.5rem"
            },
            "spacing": {
                    "margin-desktop": "32px",
                    "gutter": "24px",
                    "margin-mobile": "16px",
                    "canvas-padding": "40px",
                    "unit": "4px"
            },
            "fontFamily": {
                    "body-lg": ["Roboto Flex"],
                    "headline-sm": ["Outfit"],
                    "body-md": ["Roboto Flex"],
                    "label-sm": ["Outfit"],
                    "display-lg": ["Outfit"],
                    "title-lg": ["Outfit"],
                    "headline-lg-mobile": ["Outfit"],
                    "label-lg": ["Outfit"],
                    "headline-lg": ["Outfit"]
            },
            "fontSize": {
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "headline-sm": ["24px", {"lineHeight": "32px", "fontWeight": "500"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "label-sm": ["11px", {"lineHeight": "16px", "letterSpacing": "0.5px", "fontWeight": "500"}],
                    "display-lg": ["57px", {"lineHeight": "64px", "letterSpacing": "-0.02em", "fontWeight": "600"}],
                    "title-lg": ["22px", {"lineHeight": "28px", "fontWeight": "500"}],
                    "headline-lg-mobile": ["28px", {"lineHeight": "36px", "fontWeight": "500"}],
                    "label-lg": ["14px", {"lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "500"}],
                    "headline-lg": ["32px", {"lineHeight": "40px", "fontWeight": "500"}]
            }
          }
        }
      }
    </script>
<style>
        .glass-panel {
            background: rgba(239, 237, 244, 0.8);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
        }
        
        .textarea-ghost {
            resize: none;
            overflow-y: hidden;
            min-height: 50vh;
        }

        /* Hide scrollbar for clean look */
        ::-webkit-scrollbar {
            width: 0px;
            background: transparent;
        }
    </style>
</head>
<body class="bg-surface text-on-surface font-body-lg min-h-screen flex flex-col antialiased">
<!-- TopAppBar Semantic Shell -->
<header class="flex justify-between items-center px-margin-mobile md:px-margin-desktop h-16 w-full z-40 sticky top-0 backdrop-blur-xl bg-surface/80">
<div class="flex items-center gap-4">
<button aria-label="Go back" class="p-2 rounded-full hover:bg-surface-container-high transition-colors active:scale-95 duration-200 text-on-surface-variant flex items-center justify-center">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 0;">arrow_back</span>
</button>
<h1 class="font-title-lg text-title-lg text-primary">Tạo ghi chú mới</h1>
</div>
<button class="px-4 py-2 bg-primary text-on-primary rounded-full font-label-lg text-label-lg hover:opacity-90 transition-opacity active:scale-95 duration-200 shadow-sm flex items-center gap-2">
<span class="material-symbols-outlined text-[20px]" style="font-variation-settings: 'FILL' 1;">save</span>
            Lưu
        </button>
</header>
<!-- Main Canvas -->
<main class="flex-grow flex flex-col px-margin-mobile md:px-margin-desktop md:max-w-4xl md:mx-auto w-full pt-4 pb-24 relative">
<!-- Segmented Control -->
<div class="glass-panel rounded-full p-1 flex mb-6 mx-auto w-full max-w-sm">
<button class="flex-1 py-2 px-4 rounded-full bg-surface-container-highest text-on-surface font-label-lg text-label-lg shadow-sm transition-all flex items-center justify-center gap-2">
<span>📝</span> Văn bản
            </button>
<button class="flex-1 py-2 px-4 rounded-full text-on-surface-variant font-label-lg text-label-lg hover:bg-surface-container-high transition-all flex items-center justify-center gap-2">
<span>☑️</span> Danh sách công việc
            </button>
</div>
<!-- Note Header -->
<div class="mb-4">
<input class="w-full bg-transparent border-none focus:ring-0 p-0 font-headline-lg-mobile md:font-headline-lg text-headline-lg-mobile md:text-headline-lg text-on-surface placeholder:text-outline-variant focus:outline-none transition-colors border-b-2 border-transparent focus:border-primary pb-2" placeholder="Tiêu đề ghi chú..." type="text"/>
</div>
<!-- Note Metadata/Attachments Indicator -->
<div class="flex items-center gap-2 mb-6">
<div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-secondary-container text-on-secondary-container font-label-sm text-label-sm">
<span>🖼️</span> 2 hình ảnh được đính kèm
            </div>
<div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-container-high text-on-surface-variant font-label-sm text-label-sm cursor-pointer hover:bg-surface-container-highest transition-colors">
<span class="material-symbols-outlined text-[16px]">add</span> Thêm thẻ
            </div>
</div>
<!-- Image Preview Grid (Bento style for attachments) -->
<div class="grid grid-cols-2 gap-4 mb-6">
<div class="relative rounded-2xl overflow-hidden h-40 group shadow-sm">
<div class="w-full h-full bg-cover bg-center transition-transform duration-500 group-hover:scale-105" data-alt="A softly lit, minimalist workspace setup viewed from above. The scene includes a sleek modern laptop, a cup of artisanal coffee in a ceramic mug, and a clean white notepad with a sophisticated black pen resting on it. The light is natural and bright, conveying a calm, focused, and productive atmosphere consistent with a clean aesthetic." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB8iDT8CMuLyXCuBMmyEJjrMPdqu9GapPbee1YcWViTh9t4XqPy-2hfdshQnVqO1xzmEDCem86Cf9hCzh7gUd23IRnUCnMfHO9uZFIl-nKSpa2ZrTQpyUemkeLPySVdmIxRoi5fDGeQUS4FOQTE_qFQVrVuKyjA1G6Rj5EZ0iMb5xiJOQQdQxcisTH98ytD3xA3Am2oZdxGel84E9p6NQCUWm7qYAi70zShCUSkAmceKybpyBujUcvBRA')"></div>
<div class="absolute inset-0 bg-black/10 group-hover:bg-black/20 transition-colors"></div>
<button class="absolute top-2 right-2 p-1.5 bg-surface/80 backdrop-blur-sm rounded-full text-on-surface hover:bg-surface transition-colors opacity-0 group-hover:opacity-100">
<span class="material-symbols-outlined text-[18px]">close</span>
</button>
</div>
<div class="relative rounded-2xl overflow-hidden h-40 group shadow-sm">
<div class="w-full h-full bg-cover bg-center transition-transform duration-500 group-hover:scale-105" data-alt="A close-up macro shot of vibrant green succulent plants in a minimalist geometric concrete pot. The lighting is soft and diffused, highlighting the delicate textures and dew drops on the leaves. The background is a smooth, out-of-focus pastel lavender wall, creating a serene, natural, and calming mood perfect for a soft minimal design space." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAybEXDCsiLUACqjz2RypiHLS0DWgYhFq44ePHEINcGH_mdQk6co12qDI1OSeUTT0EWDkYFiN8sO3yDL3iuSvn-xdBRTS8fajR056yj4g55JPx3wFJf-xfSW1AAa05u-XQpoxSKxyCfiROnrSKdJjimJx2bhDbEbBNr4EJS7YmOX6El3sIbDYSFo1iP3Wildr1PCI9ONZ_BJgaKtnuaVgLZd2uop2ZTvQ1yCSrlsjY2nGDONR5hoAdq7A')"></div>
<div class="absolute inset-0 bg-black/10 group-hover:bg-black/20 transition-colors"></div>
<button class="absolute top-2 right-2 p-1.5 bg-surface/80 backdrop-blur-sm rounded-full text-on-surface hover:bg-surface transition-colors opacity-0 group-hover:opacity-100">
<span class="material-symbols-outlined text-[18px]">close</span>
</button>
</div>
</div>
<!-- Note Body -->
<div class="flex-grow relative">
<textarea class="w-full h-full bg-transparent border-none focus:ring-0 p-0 font-body-lg text-body-lg text-on-surface placeholder:text-outline-variant focus:outline-none textarea-ghost" id="note-body" placeholder="Nội dung ghi chú chi tiết..."></textarea>
</div>
</main>
<!-- Bottom Tool Ribbon (Floating Toolbar) -->
<div class="fixed bottom-margin-mobile md:bottom-margin-desktop left-1/2 transform -translate-x-1/2 w-[calc(100%-32px)] md:w-auto md:min-w-[400px] z-50">
<div class="glass-panel rounded-full px-4 py-3 flex items-center justify-between shadow-lg">
<div class="flex items-center gap-2">
<button aria-label="Camera" class="p-2 rounded-full hover:bg-surface-container text-on-surface-variant hover:text-primary transition-colors flex items-center justify-center">
<span class="material-symbols-outlined">photo_camera</span>
</button>
<button aria-label="Gallery" class="p-2 rounded-full hover:bg-surface-container text-on-surface-variant hover:text-primary transition-colors flex items-center justify-center">
<span class="material-symbols-outlined">image</span>
</button>
<button aria-label="Tag" class="p-2 rounded-full hover:bg-surface-container text-on-surface-variant hover:text-primary transition-colors flex items-center justify-center">
<span class="material-symbols-outlined">label</span>
</button>
<button aria-label="Color Palette" class="p-2 rounded-full hover:bg-surface-container text-on-surface-variant hover:text-primary transition-colors flex items-center justify-center relative">
<span class="material-symbols-outlined">palette</span>
<span class="absolute top-1 right-1 w-2 h-2 rounded-full bg-secondary"></span>
</button>
</div>
<div class="h-6 w-px bg-outline-variant/50 mx-2"></div>
<div class="flex items-center gap-1.5 text-on-surface-variant font-label-sm text-label-sm px-2">
<span class="material-symbols-outlined text-[16px]">cloud_done</span>
<span>💾 Lưu cục bộ</span>
</div>
</div>
</div>
<script>
        // Auto-resize textarea logic
        const tx = document.getElementById('note-body');
        tx.setAttribute('style', 'height:' + (tx.scrollHeight) + 'px;overflow-y:hidden;');
        tx.addEventListener("input", OnInput, false);

        function OnInput() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
        }
    </script>
</body></html>

<!-- Note Editor -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>SmartNote - Settings</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600&amp;family=Roboto+Flex:wght@400&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "on-tertiary-container": "#d8d6dd",
                      "surface": "#fff8f6",
                      "surface-variant": "#e9e1df",
                      "surface-container-low": "#fbf2f0",
                      "background": "#fff8f6",
                      "error": "#ba1a1a",
                      "on-secondary-fixed": "#3b0809",
                      "on-primary-fixed": "#17124b",
                      "surface-container-high": "#efe6e4",
                      "surface-bright": "#fff8f6",
                      "on-secondary-container": "#793734",
                      "on-primary-fixed-variant": "#434078",
                      "primary-fixed": "#e3dfff",
                      "on-surface-variant": "#47464f",
                      "on-error-container": "#93000a",
                      "secondary-fixed": "#ffdad7",
                      "inverse-surface": "#342f2e",
                      "inverse-primary": "#c4c0ff",
                      "surface-container-lowest": "#ffffff",
                      "secondary": "#904a46",
                      "error-container": "#ffdad6",
                      "surface-tint": "#5b5892",
                      "tertiary-fixed-dim": "#c7c6cc",
                      "surface-container-highest": "#e9e1df",
                      "secondary-fixed-dim": "#ffb3ae",
                      "primary": "#423f78",
                      "on-tertiary-fixed": "#1b1b20",
                      "tertiary-container": "#5d5d63",
                      "on-tertiary": "#ffffff",
                      "on-primary-container": "#d6d3ff",
                      "on-surface": "#1e1b1a",
                      "on-secondary": "#ffffff",
                      "outline-variant": "#c8c5d1",
                      "surface-dim": "#e1d8d6",
                      "on-background": "#1e1b1a",
                      "outline": "#787680",
                      "inverse-on-surface": "#f8efed",
                      "on-primary": "#ffffff",
                      "primary-container": "#5a5791",
                      "surface-container": "#f5ecea",
                      "secondary-container": "#fea49d",
                      "on-error": "#ffffff",
                      "primary-fixed-dim": "#c4c0ff",
                      "tertiary-fixed": "#e3e1e8",
                      "on-tertiary-fixed-variant": "#46464c",
                      "tertiary": "#45464b",
                      "on-secondary-fixed-variant": "#733330"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "margin-desktop": "32px",
                      "gutter": "24px",
                      "margin-mobile": "16px",
                      "canvas-padding": "40px",
                      "unit": "4px"
              },
              "fontFamily": {
                      "body-lg": ["Roboto Flex"],
                      "headline-sm": ["Outfit"],
                      "body-md": ["Roboto Flex"],
                      "label-sm": ["Outfit"],
                      "display-lg": ["Outfit"],
                      "title-lg": ["Outfit"],
                      "headline-lg-mobile": ["Outfit"],
                      "label-lg": ["Outfit"],
                      "headline-lg": ["Outfit"]
              },
              "fontSize": {
                      "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                      "headline-sm": ["24px", {"lineHeight": "32px", "fontWeight": "500"}],
                      "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                      "label-sm": ["11px", {"lineHeight": "16px", "letterSpacing": "0.5px", "fontWeight": "500"}],
                      "display-lg": ["57px", {"lineHeight": "64px", "letterSpacing": "-0.02em", "fontWeight": "600"}],
                      "title-lg": ["22px", {"lineHeight": "28px", "fontWeight": "500"}],
                      "headline-lg-mobile": ["28px", {"lineHeight": "36px", "fontWeight": "500"}],
                      "label-lg": ["14px", {"lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "500"}],
                      "headline-lg": ["32px", {"lineHeight": "40px", "fontWeight": "500"}]
              }
      },
          },
        }
      </script>
<style>
        .material-symbols-outlined {
          font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .icon-filled {
            font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
      </style>
</head>
<body class="bg-background text-on-background min-h-screen flex flex-col antialiased selection:bg-primary-container selection:text-on-primary-container">
<!-- TopAppBar -->
<header class="flex justify-between items-center px-margin-mobile md:px-margin-desktop h-16 w-full z-40 sticky top-0 backdrop-blur-xl bg-surface/80 dark:bg-surface-dim/80">
<div class="flex items-center gap-4">
<button class="w-10 h-10 rounded-full bg-surface-container-highest flex items-center justify-center text-primary dark:text-primary-fixed-dim hover:bg-surface-container-high transition-colors active:scale-95 duration-200">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="font-headline-sm text-headline-sm text-primary dark:text-primary-fixed-dim">SmartNote</h1>
</div>
</header>
<!-- Main Content Canvas -->
<main class="flex-grow flex justify-center w-full px-margin-mobile md:px-margin-desktop py-canvas-padding pb-32">
<div class="w-full max-w-3xl">
<div class="mb-12">
<h2 class="font-display-lg text-display-lg text-on-background mb-2">Settings</h2>
<p class="font-body-lg text-body-lg text-on-surface-variant">Manage your workspace preferences, security, and data.</p>
</div>
<!-- Settings Sections - Bento Grid Style -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-gutter">
<!-- Security & Sync Card -->
<div class="md:col-span-2 bg-surface-container-low rounded-[32px] p-8 relative overflow-hidden group">
<div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary to-secondary-container opacity-50"></div>
<h3 class="font-title-lg text-title-lg text-primary mb-6 flex items-center gap-3">
<span class="material-symbols-outlined icon-filled text-primary-container" data-icon="shield">shield</span>
                        Security &amp; Sync
                    </h3>
<div class="flex flex-col gap-2">
<!-- Security & PIN Lock -->
<button class="flex items-center justify-between p-4 rounded-xl hover:bg-surface-container transition-colors group/item w-full text-left">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container-highest flex items-center justify-center text-on-surface-variant group-hover/item:text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="lock">lock</span>
</div>
<div>
<div class="font-label-lg text-label-lg text-on-surface">Security &amp; PIN Lock</div>
<div class="font-body-md text-body-md text-on-surface-variant mt-1">Require PIN to open SmartNote</div>
</div>
</div>
<span class="material-symbols-outlined text-outline-variant group-hover/item:text-primary transition-colors" data-icon="chevron_right">chevron_right</span>
</button>
<div class="h-[1px] w-full bg-outline-variant/20 my-2 ml-16"></div>
<!-- Cloud Sync -->
<button class="flex items-center justify-between p-4 rounded-xl hover:bg-surface-container transition-colors group/item w-full text-left">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container-highest flex items-center justify-center text-on-surface-variant group-hover/item:text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="cloud_sync">cloud_sync</span>
</div>
<div>
<div class="font-label-lg text-label-lg text-on-surface">Cloud Sync &amp; Supabase Auth</div>
<div class="font-body-md text-body-md text-on-surface-variant mt-1">Last synced 2 mins ago</div>
</div>
</div>
<div class="flex items-center gap-2">
<span class="px-3 py-1 rounded-full bg-primary-container/20 text-primary text-xs font-medium">Active</span>
<span class="material-symbols-outlined text-outline-variant group-hover/item:text-primary transition-colors" data-icon="chevron_right">chevron_right</span>
</div>
</button>
</div>
</div>
<!-- Appearance Card -->
<div class="bg-surface-container-low rounded-[32px] p-8">
<h3 class="font-title-lg text-title-lg text-primary mb-6 flex items-center gap-3">
<span class="material-symbols-outlined icon-filled text-primary-container" data-icon="palette">palette</span>
                        Appearance
                    </h3>
<div class="flex items-center justify-between p-4 rounded-xl hover:bg-surface-container transition-colors cursor-pointer" id="theme-toggle">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container-highest flex items-center justify-center text-on-surface-variant">
<span class="material-symbols-outlined" data-icon="dark_mode" id="theme-icon">dark_mode</span>
</div>
<div>
<div class="font-label-lg text-label-lg text-on-surface">Dark Mode</div>
<div class="font-body-md text-body-md text-on-surface-variant mt-1" id="theme-text">Currently off</div>
</div>
</div>
<!-- Custom Toggle Switch -->
<div class="relative w-14 h-8 rounded-full bg-surface-container-highest transition-colors duration-300" id="toggle-track">
<div class="absolute left-1 top-1 w-6 h-6 rounded-full bg-outline transition-transform duration-300 transform translate-x-0 flex items-center justify-center" id="toggle-thumb">
<!-- Inner icon optional, kept clean for minimalism -->
</div>
</div>
</div>
</div>
<!-- Data Management Card -->
<div class="bg-surface-container-low rounded-[32px] p-8">
<h3 class="font-title-lg text-title-lg text-primary mb-6 flex items-center gap-3">
<span class="material-symbols-outlined icon-filled text-primary-container" data-icon="database">database</span>
                        Data Management
                    </h3>
<div class="flex flex-col gap-2">
<!-- Export Data -->
<button class="flex items-center justify-between p-4 rounded-xl hover:bg-surface-container transition-colors group/item w-full text-left">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container-highest flex items-center justify-center text-on-surface-variant group-hover/item:text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="download">download</span>
</div>
<div>
<div class="font-label-lg text-label-lg text-on-surface">Export Data</div>
<div class="font-body-md text-body-md text-on-surface-variant mt-1">PDF / JSON</div>
</div>
</div>
</button>
<!-- Trash Bin -->
<button class="flex items-center justify-between p-4 rounded-xl hover:bg-error-container/50 transition-colors group/item w-full text-left mt-2">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container-highest flex items-center justify-center text-error group-hover/item:bg-error-container transition-colors">
<span class="material-symbols-outlined" data-icon="delete">delete</span>
</div>
<div>
<div class="font-label-lg text-label-lg text-error">Trash Bin</div>
<div class="font-body-md text-body-md text-on-surface-variant mt-1">24 items (42MB)</div>
</div>
</div>
</button>
</div>
</div>
</div>
<!-- Versioning / Branding Anchor -->
<div class="mt-16 text-center opacity-60">
<div class="font-headline-sm text-headline-sm text-primary mb-1">SmartNote</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-widest">Version 1.0.0</div>
</div>
</div>
</main>
<!-- BottomNavBar (Hidden on md, visible on mobile) -->
<!-- Suppressed active navigation logic because Settings is an active tab -->
<nav class="md:hidden fixed bottom-0 left-0 w-full z-50 flex justify-around items-center h-20 px-4 pb-safe bg-surface-container dark:bg-surface-container-high shadow-md rounded-t-xl">
<button class="flex flex-col items-center justify-center w-16 h-16 text-on-surface-variant dark:text-outline p-3 hover:bg-surface-container-highest dark:hover:bg-inverse-surface rounded-full transition-all active:scale-90 duration-150">
<span class="material-symbols-outlined" data-icon="home">home</span>
</button>
<button class="flex flex-col items-center justify-center w-16 h-16 text-on-surface-variant dark:text-outline p-3 hover:bg-surface-container-highest dark:hover:bg-inverse-surface rounded-full transition-all active:scale-90 duration-150">
<span class="material-symbols-outlined" data-icon="search">search</span>
</button>
<button class="flex flex-col items-center justify-center w-16 h-16 text-on-surface-variant dark:text-outline p-3 hover:bg-surface-container-highest dark:hover:bg-inverse-surface rounded-full transition-all active:scale-90 duration-150">
<span class="material-symbols-outlined" data-icon="favorite">favorite</span>
</button>
<!-- ACTIVE TAB -->
<button class="flex flex-col items-center justify-center w-16 h-16 bg-primary-container dark:bg-primary text-on-primary-container dark:text-on-primary rounded-full p-3 hover:bg-surface-container-highest dark:hover:bg-inverse-surface transition-all active:scale-90 duration-150">
<span class="material-symbols-outlined icon-filled" data-icon="settings">settings</span>
</button>
</nav>
<!-- Micro-interaction Script for Theme Toggle Demo -->
<script>
        document.addEventListener('DOMContentLoaded', () => {
            const themeToggle = document.getElementById('theme-toggle');
            const track = document.getElementById('toggle-track');
            const thumb = document.getElementById('toggle-thumb');
            const icon = document.getElementById('theme-icon');
            const text = document.getElementById('theme-text');
            let isDark = false;

            themeToggle.addEventListener('click', () => {
                isDark = !isDark;
                if(isDark) {
                    thumb.classList.remove('translate-x-0', 'bg-outline');
                    thumb.classList.add('translate-x-6', 'bg-on-primary');
                    track.classList.remove('bg-surface-container-highest');
                    track.classList.add('bg-primary');
                    icon.textContent = 'light_mode';
                    text.textContent = 'Currently on';
                    document.documentElement.classList.add('dark');
                    // In a real app, save to localStorage
                } else {
                    thumb.classList.remove('translate-x-6', 'bg-on-primary');
                    thumb.classList.add('translate-x-0', 'bg-outline');
                    track.classList.remove('bg-primary');
                    track.classList.add('bg-surface-container-highest');
                    icon.textContent = 'dark_mode';
                    text.textContent = 'Currently off';
                    document.documentElement.classList.remove('dark');
                }
            });
        });
    </script>
</body></html>

<!-- Settings -->
<!DOCTYPE html><html lang="vi" style=""><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<title>SmartNote - Home Screen</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com" rel="preconnect">
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600&amp;family=Roboto+Flex:wght@400;500;600&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "on-tertiary-container": "#d8d6dd",
                        "surface": "#fff8f6",
                        "surface-variant": "#e9e1df",
                        "surface-container-low": "#fbf2f0",
                        "background": "#fff8f6",
                        "error": "#ba1a1a",
                        "on-secondary-fixed": "#3b0809",
                        "on-primary-fixed": "#17124b",
                        "surface-container-high": "#efe6e4",
                        "surface-bright": "#fff8f6",
                        "on-secondary-container": "#793734",
                        "on-primary-fixed-variant": "#434078",
                        "primary-fixed": "#e3dfff",
                        "on-surface-variant": "#47464f",
                        "on-error-container": "#93000a",
                        "secondary-fixed": "#ffdad7",
                        "inverse-surface": "#342f2e",
                        "inverse-primary": "#c4c0ff",
                        "surface-container-lowest": "#ffffff",
                        "secondary": "#904a46",
                        "error-container": "#ffdad6",
                        "surface-tint": "#5b5892",
                        "tertiary-fixed-dim": "#c7c6cc",
                        "surface-container-highest": "#e9e1df",
                        "secondary-fixed-dim": "#ffb3ae",
                        "primary": "#423f78",
                        "on-tertiary-fixed": "#1b1b20",
                        "tertiary-container": "#5d5d63",
                        "on-tertiary": "#ffffff",
                        "on-primary-container": "#d6d3ff",
                        "on-surface": "#1e1b1a",
                        "on-secondary": "#ffffff",
                        "outline-variant": "#c8c5d1",
                        "surface-dim": "#e1d8d6",
                        "on-background": "#1e1b1a",
                        "outline": "#787680",
                        "inverse-on-surface": "#f8efed",
                        "on-primary": "#ffffff",
                        "primary-container": "#5a5791",
                        "surface-container": "#f5ecea",
                        "secondary-container": "#fea49d",
                        "on-error": "#ffffff",
                        "primary-fixed-dim": "#c4c0ff",
                        "tertiary-fixed": "#e3e1e8",
                        "on-tertiary-fixed-variant": "#46464c",
                        "tertiary": "#45464b",
                        "on-secondary-fixed-variant": "#733330",
                        // Additional contextual colors for the prompt
                        "lavender-container": "#EFEDF4",
                        "soft-coral": "#fea49d", // Maps to secondary-container
                        "sage-green": "#e3e1e8", // Maps to tertiary-fixed
                        "peach-accent": "#ffdad7" // Maps to secondary-fixed
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px",
                        "2xl": "1rem",
                        "3xl": "1.5rem"
                    },
                    "spacing": {
                        "margin-desktop": "32px",
                        "gutter": "24px",
                        "margin-mobile": "16px",
                        "canvas-padding": "40px",
                        "unit": "4px"
                    },
                    "fontFamily": {
                        "body-lg": ["Roboto Flex"],
                        "headline-sm": ["Outfit"],
                        "body-md": ["Roboto Flex"],
                        "label-sm": ["Outfit"],
                        "display-lg": ["Outfit"],
                        "title-lg": ["Outfit"],
                        "headline-lg-mobile": ["Outfit"],
                        "label-lg": ["Outfit"],
                        "headline-lg": ["Outfit"]
                    },
                    "fontSize": {
                        "body-lg": ["16px", { "lineHeight": "24px", "fontWeight": "400" }],
                        "headline-sm": ["24px", { "lineHeight": "32px", "fontWeight": "500" }],
                        "body-md": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "label-sm": ["11px", { "lineHeight": "16px", "letterSpacing": "0.5px", "fontWeight": "500" }],
                        "display-lg": ["57px", { "lineHeight": "64px", "letterSpacing": "-0.02em", "fontWeight": "600" }],
                        "title-lg": ["22px", { "lineHeight": "28px", "fontWeight": "500" }],
                        "headline-lg-mobile": ["28px", { "lineHeight": "36px", "fontWeight": "500" }],
                        "label-lg": ["14px", { "lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "500" }],
                        "headline-lg": ["32px", { "lineHeight": "40px", "fontWeight": "500" }]
                    }
                },
            },
        }
    </script>
<style>
        body {
            background-color: theme('colors.background');
            color: theme('colors.on-background');
            -webkit-tap-highlight-color: transparent;
        }
        
        .glass-panel {
            background: rgba(255, 248, 246, 0.7);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.5);
        }

        .glass-card {
            background: rgba(239, 237, 244, 0.8); /* Lavender Container */
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 4px 24px rgba(66, 63, 120, 0.05); /* Soft primary shadow */
            transition: all 0.3s ease;
        }

        .glass-card:active {
            transform: scale(0.98);
            box-shadow: 0 2px 12px rgba(66, 63, 120, 0.08);
        }

        /* Hide scrollbar for chips */
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
</head>
<body class="antialiased min-h-screen flex flex-col relative pb-24">
<!-- TopAppBar -->
<header class="glass-panel flex justify-between items-center px-margin-mobile md:px-margin-desktop h-16 w-full z-40 sticky top-0">
<div class="flex items-center gap-3">
<div class="w-8 h-8 rounded-full overflow-hidden bg-surface-variant flex-shrink-0">
<img alt="User profile photo" class="w-full h-full object-cover" data-alt="A close-up portrait of a young professional in a brightly lit, modern office setting. The lighting is soft and natural, emphasizing a serene and approachable mood. The aesthetic is clean and contemporary, fitting a light-mode UI profile picture." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD1a-bLcRifWLZZJL6AqX3yU1fqHnCNcGVPop0DSioUf3_UG80bt8tmKvp9j3BuFEKaTeP174d9iGzlg4XBoLw0dkUAOh1JvPebjfMajAXgUtSyMcW3lUd87-vf8IBtoN0KX6_gKVYB3585t4maRpZ1f3u6yzUJ-BF83kJJFM0zHJMBNR3-lAYZ9ZIhSIcbGj7C0EjDPRA2BSECvoiIAeQ3Qxn5CH8Qk_qeDTV5Ixo72UFx25j8GwHtZw">
</div>
<h1 class="font-headline-sm text-headline-sm text-primary">SmartNote</h1>
</div>
<div class="flex items-center gap-2 bg-primary-fixed/30 px-3 py-1.5 rounded-full text-primary-fixed-variant">
<span class="material-symbols-outlined text-[18px]">cloud_done</span>
<span class="font-label-sm text-label-sm">Saved</span>
</div>
</header>
<!-- Main Canvas -->
<main class="flex-1 px-margin-mobile md:px-canvas-padding py-6 flex flex-col gap-6 max-w-4xl mx-auto w-full">
<!-- Greeting Section -->
<section class="relative w-full h-[400px] rounded-3xl overflow-hidden mb-6">
<img alt="Mountain Landscape" class="absolute inset-0 w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuA6cMKjmmCulhop6eKIbNSKsP4zROcY7H4AVkOiOMk3a5ohuWAzxE-fWkdJ8lKdlr9YqaMjybrQz59Spxdf8yq-MRJIfWvKHpb7iJKUA6LVkm3jXOQ-OrQTAkKRPmJ3yaK3gYjxeubs3-JvpHGtcN67U0SN3lpyFs5tuL-yMNVbbTom4scjMoMSuyzj4t196ZszXeytdb7-swi8kMyF3YPveVbA1E1AiTWJPYyWYGMVEp-l8qL0y2QBLg">
<div class="absolute inset-0 bg-black/20"></div>
<div class="absolute inset-0 flex items-center justify-center p-6">
<div class="glass-card w-full max-w-md p-6 rounded-2xl flex flex-col gap-4">
<div class="flex items-center gap-2">

<span class="font-headline-sm text-primary tracking-tight">SmartNote</span>
</div>
<div class="flex flex-col gap-1">
<p class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">Team Members</p>
<h2 class="font-title-lg text-title-lg text-on-surface">Diep Yen Khoa, Nguyen Truong Diem Quynh, Tran Thai Hoa</h2>
</div>
<p class="font-body-md text-body-md text-on-surface-variant">
        Bai Giua KI</p>
<button class="bg-primary-container text-on-primary-container font-label-lg px-6 py-3 rounded-full flex items-center justify-center gap-2 hover:shadow-lg transition-all active:scale-95">
        Start Noting
        <span class="material-symbols-outlined">arrow_forward</span>
</button>
</div>
</div>
</section>
<!-- Inspiration Card (Lavender) -->
<!-- Filter Chips -->
<section class="flex gap-2 overflow-x-auto no-scrollbar py-2 -mx-margin-mobile px-margin-mobile md:mx-0 md:px-0">
<button class="bg-primary text-on-primary font-label-lg text-label-lg px-4 py-2 rounded-full whitespace-nowrap flex-shrink-0 transition-colors">All</button>
<button class="bg-surface-variant text-on-surface-variant hover:bg-surface-container-highest font-label-lg text-label-lg px-4 py-2 rounded-full whitespace-nowrap flex-shrink-0 transition-colors">Study</button>
<button class="bg-surface-variant text-on-surface-variant hover:bg-surface-container-highest font-label-lg text-label-lg px-4 py-2 rounded-full whitespace-nowrap flex-shrink-0 transition-colors">Projects</button>
<button class="bg-surface-variant text-on-surface-variant hover:bg-surface-container-highest font-label-lg text-label-lg px-4 py-2 rounded-full whitespace-nowrap flex-shrink-0 transition-colors">Ideas</button>
<button class="bg-surface-variant text-on-surface-variant hover:bg-surface-container-highest font-label-lg text-label-lg px-4 py-2 rounded-full whitespace-nowrap flex-shrink-0 transition-colors">Personal</button>
</section>
<!-- Note Grid (Staggered/Bento style) -->
<section class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-2">
<!-- Note 1 -->
<article class="glass-card rounded-2xl p-5 flex flex-col gap-4 border-t-4 border-t-secondary-fixed">
<div class="flex justify-between items-start">
<div class="bg-tertiary-fixed text-on-tertiary-fixed-variant px-2.5 py-1 rounded-md font-label-sm text-label-sm inline-flex">
                        Projects
                    </div>
<button aria-label="Like note" class="text-secondary hover:scale-110 transition-transform active:scale-95">
<span class="material-symbols-outlined" style="font-variation-settings: &quot;FILL&quot; 1;">favorite</span>
</button>
</div>
<div>
<h3 class="font-title-lg text-title-lg text-on-surface mb-2 flex items-center gap-2">
<span class="text-xl">💡</span> Ý tưởng App Mới
                    </h3>
<p class="font-body-md text-body-md text-on-surface-variant line-clamp-3">
                        Tạo ứng dụng ghi chú thông minh sử dụng AI để tự động phân loại và gợi ý nội dung liên quan. Cần tích hợp cloud sync và dark mode...
                    </p>
</div>
<div class="mt-auto pt-4 flex items-center justify-between text-outline text-xs">
<span class="font-label-sm text-label-sm">Hôm nay, 09:41</span>
<span class="material-symbols-outlined text-[18px]">more_horiz</span>
</div>
</article>
<!-- Note 2 -->
<article class="glass-card rounded-2xl p-5 flex flex-col gap-4 border-t-4 border-t-tertiary-fixed">
<div class="flex justify-between items-start">
<div class="bg-tertiary-fixed text-on-tertiary-fixed-variant px-2.5 py-1 rounded-md font-label-sm text-label-sm inline-flex">
                        Study
                    </div>
<button aria-label="Like note" class="text-outline hover:scale-110 transition-transform active:scale-95 hover:text-secondary">
<span class="material-symbols-outlined">favorite</span>
</button>
</div>
<div>
<h3 class="font-title-lg text-title-lg text-on-surface mb-2 flex items-center gap-2">
<span class="text-xl">📚</span> Ôn Thi Flutter
                    </h3>
<p class="font-body-md text-body-md text-on-surface-variant line-clamp-3">
                        1. Riverpod state management cơ bản và nâng cao<br>
                        2. SQLite local database integration<br>
                        3. Animation custom paint...
                    </p>
</div>
<div class="mt-auto pt-4 flex items-center justify-between text-outline text-xs">
<span class="font-label-sm text-label-sm">Hôm qua, 14:20</span>
<span class="material-symbols-outlined text-[18px]">more_horiz</span>
</div>
</article>
</section>
</main>
<!-- FAB -->
<button aria-label="Add new note" class="fixed bottom-24 right-6 w-14 h-14 bg-primary text-on-primary rounded-[24px] shadow-lg hover:shadow-xl hover:-translate-y-1 transition-all duration-200 flex items-center justify-center z-40 active:scale-95">
<span class="material-symbols-outlined text-3xl">add</span>
</button>
<!-- BottomNavBar (Mobile only context, but rendered as per JSON structure requested) -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center h-20 px-4 pb-safe bg-surface-container shadow-[0_-4px_24px_rgba(0,0,0,0.05)] rounded-t-2xl md:hidden">
<button aria-label="Home" class="flex flex-col items-center justify-center w-16 h-full text-primary group">
<div class="bg-primary-container text-on-primary-container rounded-full p-1.5 px-4 transition-colors group-active:scale-90 duration-150">
<span class="material-symbols-outlined text-[24px]" style="font-variation-settings: &quot;FILL&quot; 1;">home</span>
</div>
<span class="font-label-sm text-label-sm mt-1">Home</span>
</button>
<button aria-label="Search" class="flex flex-col items-center justify-center w-16 h-full text-on-surface-variant hover:text-primary group transition-colors">
<div class="rounded-full p-1.5 px-4 transition-colors group-hover:bg-surface-container-highest group-active:scale-90 duration-150">
<span class="material-symbols-outlined text-[24px]">search</span>
</div>
<span class="font-label-sm text-label-sm mt-1 opacity-0 group-hover:opacity-100 transition-opacity">Search</span>
</button>
<button aria-label="Favorite" class="flex flex-col items-center justify-center w-16 h-full text-on-surface-variant hover:text-primary group transition-colors">
<div class="rounded-full p-1.5 px-4 transition-colors group-hover:bg-surface-container-highest group-active:scale-90 duration-150">
<span class="material-symbols-outlined text-[24px]">favorite</span>
</div>
<span class="font-label-sm text-label-sm mt-1 opacity-0 group-hover:opacity-100 transition-opacity">Saved</span>
</button>
<button aria-label="Settings" class="flex flex-col items-center justify-center w-16 h-full text-on-surface-variant hover:text-primary group transition-colors">
<div class="rounded-full p-1.5 px-4 transition-colors group-hover:bg-surface-container-highest group-active:scale-90 duration-150">
<span class="material-symbols-outlined text-[24px]">settings</span>
</div>
<span class="font-label-sm text-label-sm mt-1 opacity-0 group-hover:opacity-100 transition-opacity">Settings</span>
</button>
</nav>


</body></html>