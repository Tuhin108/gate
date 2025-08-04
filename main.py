from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.image import Image
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.spinner import Spinner
from kivy.uix.checkbox import CheckBox
from kivy.uix.popup import Popup
from kivy.uix.scrollview import ScrollView
from kivy.uix.filechooser import FileChooserListView
from kivy.graphics import Color, Line
from kivy.core.camera import Camera as CoreCamera
from kivy.properties import StringProperty, ListProperty, ObjectProperty
from kivy.clock import Clock
import os
import json
from datetime import datetime
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.utils import ImageReader

# Screen management
class GateSurveyApp(App):
    def build(self):
        self.sm = ScreenManager()
        self.sm.add_widget(WelcomeScreen(name='welcome'))
        self.sm.add_widget(GateTypeScreen(name='gate_type'))
        self.sm.add_widget(CameraScreen(name='camera'))
        self.sm.add_widget(SlidingGateSurveyScreen(name='sliding_survey'))
        self.sm.add_widget(SwingGateSurveyScreen(name='swing_survey'))
        self.sm.add_widget(SummaryScreen(name='summary'))
        return self.sm

# Welcome Screen
class WelcomeScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical', padding=50, spacing=30)
        logo = Image(source='assets/logo.png', size_hint=(1, 0.6))
        start_btn = Button(
            text="Start Survey", 
            size_hint=(0.8, 0.1),
            pos_hint={'center_x': 0.5},
            background_color=(0.1, 0.5, 0.8, 1)
        )
        start_btn.bind(on_press=self.start_survey)
        layout.add_widget(logo)
        layout.add_widget(start_btn)
        self.add_widget(layout)
    
    def start_survey(self, instance):
        self.manager.current = 'gate_type'

# Gate Type Selection
class GateTypeScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical', padding=50, spacing=30)
        label = Label(text="Select Gate Type", font_size=24, size_hint=(1, 0.2))
        
        btn_layout = BoxLayout(spacing=20, size_hint=(1, 0.4))
        sliding_btn = Button(text="Sliding Gate", background_color=(0.2, 0.6, 0.2, 1))
        swing_btn = Button(text="Swing Gate", background_color=(0.8, 0.4, 0.1, 1))
        
        sliding_btn.bind(on_press=self.select_sliding)
        swing_btn.bind(on_press=self.select_swing)
        
        btn_layout.add_widget(sliding_btn)
        btn_layout.add_widget(swing_btn)
        
        layout.add_widget(label)
        layout.add_widget(btn_layout)
        self.add_widget(layout)
    
    def select_sliding(self, instance):
        self.manager.get_screen('camera').gate_type = 'sliding'
        self.manager.current = 'camera'
    
    def select_swing(self, instance):
        self.manager.get_screen('camera').gate_type = 'swing'
        self.manager.current = 'camera'

# Camera Screen
class CameraScreen(Screen):
    gate_type = StringProperty('')
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.camera = None
        self.camera_display = None
        layout = BoxLayout(orientation='vertical')
        
        # Camera preview placeholder
        self.camera_container = FloatLayout(size_hint=(1, 0.7))
        layout.add_widget(self.camera_container)
        
        # Buttons
        btn_layout = BoxLayout(size_hint=(1, 0.2), spacing=10, padding=10)
        capture_btn = Button(text="Capture Photo", background_color=(0.1, 0.7, 0.3, 1))
        gallery_btn = Button(text="Choose from Gallery", background_color=(0.2, 0.5, 0.8, 1))
        
        capture_btn.bind(on_press=self.capture_photo)
        gallery_btn.bind(on_press=self.open_gallery)
        
        btn_layout.add_widget(capture_btn)
        btn_layout.add_widget(gallery_btn)
        layout.add_widget(btn_layout)
        
        self.add_widget(layout)
    
    def on_pre_enter(self):
        self.initialize_camera()
    
    def initialize_camera(self):
        if self.camera:
            self.camera.stop()
            self.camera = None
        
        try:
            self.camera = CoreCamera(index=0, resolution=(640, 480))
            self.camera.start()
            self.camera_texture = self.camera.texture
            if self.camera_display:
                self.camera_container.remove_widget(self.camera_display)
            self.camera_display = Image(texture=self.camera_texture, size_hint=(1, 1))
            self.camera_container.add_widget(self.camera_display)
            Clock.schedule_interval(self.update_camera, 1.0/30.0)
        except Exception as e:
            print(f"Camera error: {str(e)}")
            self.camera_display = Label(text="Camera not available", size_hint=(1, 1))
            self.camera_container.add_widget(self.camera_display)
    
    def update_camera(self, dt):
        if self.camera and self.camera.texture:
            self.camera_texture = self.camera.texture
            self.camera_display.texture = self.camera_texture
    
    def capture_photo(self, instance):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.filename = f"survey_photo_{timestamp}.png"
        if self.camera and self.camera.texture:
            self.camera.texture.save(self.filename, flipped=False)
            self.proceed_to_survey()
    
    def open_gallery(self, instance):
        content = BoxLayout(orientation='vertical')
        filechooser = FileChooserListView()
        select_btn = Button(text="Select", size_hint_y=0.1)
        
        content.add_widget(filechooser)
        content.add_widget(select_btn)
        
        self.popup = Popup(title="Select Photo", content=content, size_hint=(0.9, 0.9))
        select_btn.bind(on_press=lambda x: self.select_file(filechooser))
        self.popup.open()
    
    def select_file(self, filechooser):
        if filechooser.selection:
            self.filename = filechooser.selection[0]
            self.popup.dismiss()
            self.proceed_to_survey()
    
    def proceed_to_survey(self):
        if self.gate_type == 'sliding':
            survey_screen = self.manager.get_screen('sliding_survey')
            survey_screen.site_photo = self.filename
            self.manager.current = 'sliding_survey'
        else:
            survey_screen = self.manager.get_screen('swing_survey')
            survey_screen.site_photo = self.filename
            self.manager.current = 'swing_survey'
    
    def on_leave(self):
        if self.camera:
            self.camera.stop()
            self.camera = None
        Clock.unschedule(self.update_camera)

# Base Survey Screen
class BaseSurveyScreen(Screen):
    site_photo = StringProperty('')
    gate_image = StringProperty('')
    dimensions = ListProperty([])
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.drawing_mode = False
        self.current_line = None
        self.start_point = None
    
    def on_pre_enter(self):
        self.ids.site_image.source = self.site_photo
    
    def add_gate_image(self, image_path):
        self.gate_image = image_path
        self.ids.gate_overlay.source = image_path
        self.ids.gate_overlay.opacity = 0.7
    
    def start_measurement(self):
        self.drawing_mode = True
        self.dimensions = []
        self.ids.measure_label.text = "Tap and drag to measure"
    
    def on_touch_down(self, touch):
        if self.drawing_mode and self.ids.photo_canvas.collide_point(*touch.pos):
            self.start_point = (touch.x, touch.y)
            with self.ids.photo_canvas.canvas:
                Color(1, 0, 0)
                self.current_line = Line(points=[touch.x, touch.y], width=2)
            return True
        return super().on_touch_down(touch)
    
    def on_touch_move(self, touch):
        if self.drawing_mode and self.current_line and self.start_point:
            self.current_line.points = [self.start_point[0], self.start_point[1], touch.x, touch.y]
    
    def on_touch_up(self, touch):
        if self.drawing_mode and self.current_line and self.start_point:
            dx = touch.x - self.start_point[0]
            dy = touch.y - self.start_point[1]
            distance = (dx**2 + dy**2)**0.5
            self.dimensions.append(round(distance, 2))
            self.ids.measure_label.text = f"Measurement: {self.dimensions[-1]} px"
            self.drawing_mode = False
            self.start_point = None

# Sliding Gate Survey
class SlidingGateSurveyScreen(BaseSurveyScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical')
        
        # Photo and overlay canvas
        photo_layout = FloatLayout(size_hint=(1, 0.5))
        self.ids.photo_canvas = photo_layout
        self.site_image = Image(source="", allow_stretch=True, keep_ratio=True)
        self.gate_overlay = Image(source="", opacity=0)
        photo_layout.add_widget(self.site_image)
        photo_layout.add_widget(self.gate_overlay)
        
        # Measurement label
        self.measure_label = Label(text="", size_hint_y=None, height=30)
        layout.add_widget(self.measure_label)
        
        # Controls
        ctrl_layout = BoxLayout(size_hint=(1, 0.1), spacing=5)
        measure_btn = Button(text="Measure", background_color=(0.8, 0.6, 0.1, 1))
        gate_btn = Button(text="Add Gate", background_color=(0.3, 0.5, 0.8, 1))
        
        measure_btn.bind(on_press=lambda x: self.start_measurement())
        gate_btn.bind(on_press=self.show_gate_selection)
        
        ctrl_layout.add_widget(measure_btn)
        ctrl_layout.add_widget(gate_btn)
        layout.add_widget(ctrl_layout)
        
        # Form
        form_scroll = ScrollView(size_hint=(1, 0.3))
        form_layout = BoxLayout(orientation='vertical', size_hint_y=None, height=500, padding=10, spacing=10)
        form_layout.bind(minimum_height=form_layout.setter('height'))
        
        # Create form fields
        self.clear_opening = TextInput(hint_text="Clear Opening (m)", multiline=False)
        self.height = TextInput(hint_text="Height Required (m)", multiline=False)
        self.parking = TextInput(hint_text="Parking Space (m)", multiline=False)
        self.opening_direction = Spinner(
            text="Select Direction", 
            values=["Left", "Right", "Up", "Down"],
            size_hint_y=None, height=44
        )
        
        # Provisions
        provision_layout = BoxLayout(size_hint_y=None, height=44)
        provision_layout.add_widget(Label(text="Cabling Provision:"))
        self.cabling = CheckBox(size_hint_x=None, width=50)
        provision_layout.add_widget(self.cabling)
        
        storage_layout = BoxLayout(size_hint_y=None, height=44)
        storage_layout.add_widget(Label(text="Storage Provision:"))
        self.storage = CheckBox(size_hint_x=None, width=50)
        storage_layout.add_widget(self.storage)
        
        # Recommendation
        self.recommendation = TextInput(hint_text="Gate Recommendation", multiline=True, size_hint_y=None, height=100)
        
        # Add to form
        fields = [
            ("Clear Opening (m)", self.clear_opening),
            ("Height Required (m)", self.height),
            ("Parking Space (m)", self.parking),
            ("Opening Direction", self.opening_direction),
            provision_layout,
            storage_layout,
            ("Recommendation", self.recommendation)
        ]
        
        for label, widget in fields:
            if isinstance(label, str):
                form_layout.add_widget(Label(text=label, size_hint_y=None, height=30))
            form_layout.add_widget(widget)
        
        form_scroll.add_widget(form_layout)
        layout.add_widget(form_scroll)
        
        # Navigation
        nav_btn = Button(
            text="Generate Report", 
            size_hint=(1, 0.1),
            background_color=(0.1, 0.7, 0.3, 1)
        )
        nav_btn.bind(on_press=self.generate_report)
        layout.add_widget(nav_btn)
        
        self.add_widget(layout)
        self.ids = {'photo_canvas': photo_layout, 'site_image': self.site_image, 
                   'gate_overlay': self.gate_overlay, 'measure_label': self.measure_label}
    
    def show_gate_selection(self, instance):
        content = BoxLayout(orientation='vertical')
        grid = BoxLayout(cols=3, spacing=10, size_hint_y=0.9)
        
        for i in range(1, 7):
            img = Image(source=f'assets/{chr(96+i)}.png', size_hint=(None, None), size=(100, 100))
            btn = Button(size_hint=(None, None), size=(110, 110))
            btn.add_widget(img)
            btn.bind(on_press=lambda x, img=f'assets/{chr(96+i)}.png': self.add_gate_image(img))
            grid.add_widget(btn)
        
        content.add_widget(grid)
        close_btn = Button(text="Close", size_hint_y=0.1)
        content.add_widget(close_btn)
        
        popup = Popup(title="Select Gate Image", content=content, size_hint=(0.9, 0.7))
        close_btn.bind(on_press=popup.dismiss)
        popup.open()
    
    def generate_report(self, instance):
        survey_data = {
            "gate_type": "sliding",
            "clear_opening": self.clear_opening.text,
            "height": self.height.text,
            "parking": self.parking.text,
            "direction": self.opening_direction.text,
            "cabling": self.cabling.active,
            "storage": self.storage.active,
            "recommendation": self.recommendation.text,
            "dimensions": self.dimensions,
            "photo": self.site_photo,
            "gate_image": self.gate_image
        }
        summary = self.manager.get_screen('summary')
        summary.survey_data = survey_data
        self.manager.current = 'summary'

# Swing Gate Survey
class SwingGateSurveyScreen(BaseSurveyScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical')
        
        # Photo and overlay canvas
        photo_layout = FloatLayout(size_hint=(1, 0.5))
        self.ids.photo_canvas = photo_layout
        self.site_image = Image(source="", allow_stretch=True, keep_ratio=True)
        self.gate_overlay = Image(source="", opacity=0)
        photo_layout.add_widget(self.site_image)
        photo_layout.add_widget(self.gate_overlay)
        
        # Measurement label
        self.measure_label = Label(text="", size_hint_y=None, height=30)
        layout.add_widget(self.measure_label)
        
        # Controls
        ctrl_layout = BoxLayout(size_hint=(1, 0.1), spacing=5)
        measure_btn = Button(text="Measure", background_color=(0.8, 0.6, 0.1, 1))
        gate_btn = Button(text="Add Gate", background_color=(0.3, 0.5, 0.8, 1))
        
        measure_btn.bind(on_press=lambda x: self.start_measurement())
        gate_btn.bind(on_press=self.show_gate_selection)
        
        ctrl_layout.add_widget(measure_btn)
        ctrl_layout.add_widget(gate_btn)
        layout.add_widget(ctrl_layout)
        
        # Form
        form_scroll = ScrollView(size_hint=(1, 0.3))
        form_layout = BoxLayout(orientation='vertical', size_hint_y=None, height=500, padding=10, spacing=10)
        form_layout.bind(minimum_height=form_layout.setter('height'))
        
        # Create form fields
        self.clear_opening = TextInput(hint_text="Clear Opening (m)", multiline=False)
        self.height = TextInput(hint_text="Height Required (m)", multiline=False)
        self.opening_direction = Spinner(
            text="Select Direction", 
            values=["Inward", "Outward", "Left", "Right"],
            size_hint_y=None, height=44
        )
        self.opening_angle = TextInput(hint_text="Opening Angle (degrees)", multiline=False)
        
        # Provisions
        provision_layout = BoxLayout(size_hint_y=None, height=44)
        provision_layout.add_widget(Label(text="Cabling Provision:"))
        self.cabling = CheckBox(size_hint_x=None, width=50)
        provision_layout.add_widget(self.cabling)
        
        storage_layout = BoxLayout(size_hint_y=None, height=44)
        storage_layout.add_widget(Label(text="Storage Provision:"))
        self.storage = CheckBox(size_hint_x=None, width=50)
        storage_layout.add_widget(self.storage)
        
        # Recommendation
        self.recommendation = TextInput(hint_text="Gate Recommendation", multiline=True, size_hint_y=None, height=100)
        
        # Add to form
        fields = [
            ("Clear Opening (m)", self.clear_opening),
            ("Height Required (m)", self.height),
            ("Opening Direction", self.opening_direction),
            ("Opening Angle (degrees)", self.opening_angle),
            provision_layout,
            storage_layout,
            ("Recommendation", self.recommendation)
        ]
        
        for label, widget in fields:
            if isinstance(label, str):
                form_layout.add_widget(Label(text=label, size_hint_y=None, height=30))
            form_layout.add_widget(widget)
        
        form_scroll.add_widget(form_layout)
        layout.add_widget(form_scroll)
        
        # Navigation
        nav_btn = Button(
            text="Generate Report", 
            size_hint=(1, 0.1),
            background_color=(0.1, 0.7, 0.3, 1)
        )
        nav_btn.bind(on_press=self.generate_report)
        layout.add_widget(nav_btn)
        
        self.add_widget(layout)
        self.ids = {'photo_canvas': photo_layout, 'site_image': self.site_image, 
                   'gate_overlay': self.gate_overlay, 'measure_label': self.measure_label}
    
    def show_gate_selection(self, instance):
        content = BoxLayout(orientation='vertical')
        grid = BoxLayout(cols=3, spacing=10, size_hint_y=0.9)
        
        for i in range(1, 7):
            img = Image(source=f'assets/{chr(96+i)}.png', size_hint=(None, None), size=(100, 100))
            btn = Button(size_hint=(None, None), size=(110, 110))
            btn.add_widget(img)
            btn.bind(on_press=lambda x, img=f'assets/{chr(96+i)}.png': self.add_gate_image(img))
            grid.add_widget(btn)
        
        content.add_widget(grid)
        close_btn = Button(text="Close", size_hint_y=0.1)
        content.add_widget(close_btn)
        
        popup = Popup(title="Select Gate Image", content=content, size_hint=(0.9, 0.7))
        close_btn.bind(on_press=popup.dismiss)
        popup.open()
    
    def generate_report(self, instance):
        survey_data = {
            "gate_type": "swing",
            "clear_opening": self.clear_opening.text,
            "height": self.height.text,
            "direction": self.opening_direction.text,
            "angle": self.opening_angle.text,
            "cabling": self.cabling.active,
            "storage": self.storage.active,
            "recommendation": self.recommendation.text,
            "dimensions": self.dimensions,
            "photo": self.site_photo,
            "gate_image": self.gate_image
        }
        summary = self.manager.get_screen('summary')
        summary.survey_data = survey_data
        self.manager.current = 'summary'

# Summary Screen
class SummaryScreen(Screen):
    survey_data = ObjectProperty({})
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical', padding=20, spacing=10)
        
        self.summary_label = Label(
            text="Survey Summary", 
            font_size=24,
            size_hint=(1, 0.1)
        )
        layout.add_widget(self.summary_label)
        
        self.details = Label(
            text="", 
            size_hint=(1, 0.6),
            halign='left',
            valign='top',
            markup=True
        )
        scroll = ScrollView(size_hint=(1, 0.6))
        scroll.add_widget(self.details)
        layout.add_widget(scroll)
        
        btn_layout = BoxLayout(size_hint=(1, 0.2), spacing=10)
        pdf_btn = Button(text="Generate PDF", background_color=(0.2, 0.6, 0.2, 1))
        new_btn = Button(text="New Survey", background_color=(0.1, 0.5, 0.8, 1))
        
        pdf_btn.bind(on_press=self.generate_pdf)
        new_btn.bind(on_press=self.new_survey)
        
        btn_layout.add_widget(pdf_btn)
        btn_layout.add_widget(new_btn)
        layout.add_widget(btn_layout)
        
        self.add_widget(layout)
    
    def on_pre_enter(self):
        if self.survey_data:
            text = "[b]Survey Details:[/b]\n\n"
            text += f"Gate Type: {self.survey_data['gate_type'].capitalize()}\n"
            text += f"Clear Opening: {self.survey_data['clear_opening']} m\n"
            text += f"Height: {self.survey_data['height']} m\n"
            
            if self.survey_data['gate_type'] == 'sliding':
                text += f"Parking Space: {self.survey_data['parking']} m\n"
            else:
                text += f"Opening Angle: {self.survey_data['angle']}°\n"
                
            text += f"Direction: {self.survey_data['direction']}\n"
            text += f"Cabling Provision: {'Yes' if self.survey_data['cabling'] else 'No'}\n"
            text += f"Storage Provision: {'Yes' if self.survey_data['storage'] else 'No'}\n"
            text += f"\n[b]Recommendation:[/b]\n{self.survey_data['recommendation']}"
            
            self.details.text = text
    
    def generate_pdf(self, instance):
        filename = f"GateSurvey_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
        c = canvas.Canvas(filename, pagesize=letter)
        width, height = letter
        
        # Title
        c.setFont("Helvetica-Bold", 18)
        c.drawString(100, height-50, "Gate Installation Survey Report")
        
        # Details
        c.setFont("Helvetica", 12)
        y = height - 100
        for key, value in self.survey_data.items():
            if key not in ['photo', 'gate_image', 'dimensions']:
                display_key = key.replace('_', ' ').capitalize()
                if key == 'cabling' or key == 'storage':
                    display_value = 'Yes' if value else 'No'
                else:
                    display_value = str(value)
                c.drawString(100, y, f"{display_key}: {display_value}")
                y -= 20
        
        # Images
        img_y = y - 200
        if os.path.exists(self.survey_data['photo']):
            c.drawImage(ImageReader(self.survey_data['photo']), 50, img_y, width=200, height=150)
        
        if 'gate_image' in self.survey_data and self.survey_data['gate_image'] and os.path.exists(self.survey_data['gate_image']):
            c.drawImage(ImageReader(self.survey_data['gate_image']), 300, img_y, width=200, height=150)
        
        c.save()
        
        # Show confirmation
        popup = Popup(
            title="PDF Generated",
            content=Label(text=f"Report saved as:\n{filename}"),
            size_hint=(0.8, 0.4)
        )
        popup.open()
    
    def new_survey(self, instance):
        self.manager.current = 'gate_type'

if __name__ == '__main__':
    GateSurveyApp().run()