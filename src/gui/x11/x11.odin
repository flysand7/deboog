//+build linux,freebsd,openbsd
package x11

/*
    Bindings for X11.
    
    Anything that starts with `X` or `X_` shouldn't be used, prefer functions
    written in Odin's style and types whose name doesn't start with X.
*/

foreign import x11 "system:X11"
foreign x11 {
    // Errors
    XSynchronize :: proc "c" (display: ^Display, onoff: bool) -> #type proc "c" (display: ^Display) -> b32 ---
    XSetErrorHandler :: proc "c" (handler: #type proc "c" (display: ^Display, event: Error_Event)) -> b32 ---
    XGetErrorText :: proc "c" (display: ^Display, err: Error, str: [^]u8, len: i32) -> i32 ---
    // Display
    XOpenDisplay :: proc "c" (name: cstring) -> ^Display ---
    XDefaultGC :: proc "c" (display: ^Display, screen_number: i32) -> GC ---
    XFlushGC :: proc "c" (display: ^Display, gc: GC) ---
    // Visual
    XDefaultVisual :: proc "c" (display: ^Display, screen_number: i32) -> ^Visual ---
    // Atom
    XInternAtom :: proc "c" (display: ^Display, name: cstring, create: bool) -> Atom ---
    // Image
    XCreateImage :: proc "c" (display: ^Display, visual: ^Visual, depth: u32, format: Image_Format, offset: i32, data: rawptr, w,h: u32, pad: i32, stride: i32) -> ^Image ---
    XPutImage :: proc "c" (display: ^Display, drawable: Drawable, gc: GC, image: ^Image, src_x, src_y, dst_x, dst_y: i32, width, height: u32) ---
    // Window
    XDefaultRootWindow :: proc "c"(display: ^Display) -> Window ---
    XCreateWindow :: proc "c" (
        display: ^Display,
        parent: Window,
        x, y: i32,
        width,height: u32,
        border: u32,
        depth: i32,
        class: Window_Class,
        visual: ^Visual,
        attr_mask: X_Attribute_Mask,
        attr: ^X_Set_Window_Attributes) -> Window ---
    XDestroyWindow :: proc "c" (display: ^Display, window: Window) ---
    XStoreName :: proc "c" (display: ^Display, window: Window, name: cstring) -> b32 ---
    XSelectInput :: proc "c"(display: ^Display, window: Window, events: Event_Mask) -> b32 ---
    XMapWindow :: proc "c" (display: ^Display, window: Window) -> b32 ---
    XMapRaised :: proc "c" (display: ^Display, window: Window) -> b32 ---
    XSetWMProtocols :: proc "c" (display: ^Display, window: Window, protos: [^]Atom, len: i32) -> Error ---
    XNextEvent :: proc "c" (display: ^Display, event: ^Event) -> b32 ---
}

Xid       :: distinct uint
Mask      :: uint
Atom      :: uint
Visual_ID :: uint
Time      :: uint
Window    :: Xid
Drawable  :: Xid
Font      :: Xid
Pixmap    :: Xid
Cursor    :: Xid
Colormap  :: Xid
GContext  :: Xid
KeySym    :: Xid
KeyCode   :: u8

Display :: struct {}

GC :: distinct rawptr

Copy_From_Parent := cast(^Visual) nil
Parent_Relative  :: 1
None             :: 0

/*
    Status codes returned by X11.
*/
Error :: enum {
    Success             = 0,
    BadRequest          = 1,
    BadValue            = 2,
    BadWindow           = 3,
    BadPixmap           = 4,
    BadAtom             = 5,
    BadCursor           = 6,
    BadFont             = 7,
    BadMatch            = 8,
    BadDrawable         = 9,
    BadAccess           = 10,
    BadAlloc            = 11,
    BadColor            = 12,
    BadGC               = 13,
    BadIDChoice         = 14,
    BadName             = 15,
    BadLength           = 16,
    BadImplementation   = 17,
    //FirstExtensionError = 128,
    //LastExtensionError  = 255,
    // Not an X11 error code, this is our custom error code that you will
    // observe if synchronous errors are disabled.
    IDK_Which = 256,
}

Error_Event :: struct {
    type:         i32,
    display:      ^Display,
    serial:       uint,
    error_code:   Error,
    request_code: u8,
    minor_code:   u8,
    resourceid:   Xid,
}

Notify_Mode :: enum i32 {
    Normal       = 0,
    Grab         = 1,
    Ungrab       = 2,
    WhileGrabbed = 3,
}

Notify_Detail :: enum i32 {
    Ancestor         = 0,
    Virtual          = 1,
    Inferior         = 2,
    Nonlinear        = 3,
    NonlinearVirtual = 4,
    Pointer          = 5,
    PointerRoot      = 6,
    DetailNone       = 7,
}

/*
    Events
*/
Event :: struct #raw_union {
    type:              Event_Type, // Part of all "event" structures so it's here
    xany:              Any_Event,
    xkey:              Key_Event,
    xbutton:           Button_Event,
    xmotion:           Motion_Event,
    xcrossing:         Crossing_Event,
    xfocus:            Focus_Change_Event,
    xexpose:           Expose_Event,
    xgraphicsexpose:   Graphics_Expose_Event,
    xnoexpose:         No_Expose_Event,
    xvisibility:       Visibility_Event,
    xcreatewindow:     Create_Window_Event,
    xdestroywindow:    Destroy_Window_Event,
    xunmap:            Unmap_Event,
    xmap:              Map_Event,
    xmaprequest:       Map_Request_Event,
    xreparent:         Reparent_Event,
    xconfigure:        Configure_Event,
    xgravity:          Gravity_Event,
    xresizerequest:    Resize_Request_Event,
    xconfigurerequest: Configure_Request_Event,
    xcirculate:        Circulate_Event,
    xcirculaterequest: Circulate_Request_Event,
    xproperty:         Property_Event,
    xselectionclear:   Selection_Clear_Event,
    xselectionrequest: Selection_Request_Event,
    xselection:        Selection_Event,
    xcolormap:         Colormap_Event,
    xclient:           Client_Message_Event,
    xmapping:          Mapping_Event,
    xerror:            Error_Event,
    xkeymap:           Keymap_Event,
    xgeneric:          Generic_Event,
    xcookie:           Generic_Event_Cookie,
    _:                 [24]int,
}

Event_Type :: enum i32 {
    Key_Press         = 2,
    Key_Release       = 3,
    Button_Press      = 4,
    Button_Release    = 5,
    Motion_Notify     = 6,
    Enter_Notify      = 7,
    Leave_Notify      = 8,
    Focus_In          = 9,
    Focus_Out         = 10,
    Keymap_Notify     = 11,
    Expose            = 12,
    Graphics_Expose   = 13,
    NoExpose          = 14,
    Visibility_Notify = 15,
    Create_Notify     = 16,
    Destroy_Notify    = 17,
    Unmap_Notify      = 18,
    Map_Notify        = 19,
    Map_Request       = 20,
    Reparent_Notify   = 21,
    Configure_Notify  = 22,
    Configure_Request = 23,
    Gravity_Notify    = 24,
    Resize_Request    = 25,
    Circulate_Notify  = 26,
    Circulate_Request = 27,
    Property_Notify   = 28,
    Selection_Clear   = 29,
    Selection_Request = 30,
    Selection_Notify  = 31,
    Colormap_Notify   = 32,
    Client_Message    = 33,
    Mapping_Notify    = 34,
    Generic_Event     = 35,
}

Key_Mask :: bit_set[Key_Mask_Bits; u32]
Key_Mask_Bits :: enum {
    Shift   = 0,
    Lock    = 1,
    Control = 2,
    Mod1    = 3,
    Mod2    = 4,
    Mod3    = 5,
    Mod4    = 6,
    Mod5    = 7,
}

Key_Event :: struct {
    using _:     Any_Event,
    root:        Window,
    subwindow:   Window,
    time:        Time,
    x:           i32,
    y:           i32,
    x_root:      i32,
    y_root:      i32,
    state:       Key_Mask,
    keycode:     u32,
    same_screen: b32,
}

Key_Pressed_Event  :: Key_Event
Key_Released_Event :: Key_Event

Button_Event :: struct {
    using _:     Any_Event,
    root:        Window,
    subwindow:   Window,
    time:        Time,
    x:           i32,
    y:           i32,
    x_root:      i32,
    y_root:      i32,
    state:       Key_Mask,
    button:      Button,
    same_screen: b32,
}

Button :: enum u32 {
    Button1 = 1,
    Button2 = 2,
    Button3 = 3,
    Button4 = 4,
    Button5 = 5,
}

Button_Pressed_Event  :: Button_Event
Button_Released_Event :: Button_Event

Motion_Event :: struct {
    using _:     Any_Event,
    root:        Window,
    subwindow:   Window,
    time:        Time,
    x:           i32,
    y:           i32,
    x_root:      i32,
    y_root:      i32,
    state:       Key_Mask,
    is_hint:     b8,
    same_screen: b32,
}

NotifyHint :: b8(true)

Pointer_Moved_Event :: Motion_Event

Crossing_Event :: struct {
    using _:     Any_Event,
    root:        Window,
    subwindow:   Window,
    time:        Time,
    x:           i32,
    y:           i32,
    x_root:      i32,
    y_root:      i32,
    mode:        Notify_Mode,
    detail:      Notify_Detail,
    same_screen: b32,
    focus:       b32,
    state:       Key_Mask,
}

Enter_Window_Event :: Crossing_Event
Leave_Window_Event :: Crossing_Event

Focus_Change_Event :: struct {
    using _:     Any_Event,
    mode:        Notify_Mode,
    detail:      Notify_Detail,
}
Focus_In_Event  :: Focus_Change_Event
Focus_Out_Event :: Focus_Change_Event

Keymap_Event :: struct {
    using _:     Any_Event,
    key_vector:  [32]u8,
}

Expose_Event :: struct {
    using _:     Any_Event,
    x:           i32,
    y:           i32,
    width:       i32,
    height:      i32,
    count:       i32,
}

Graphics_Expose_Event :: struct {
    type:        Event_Type,
    serial:      uint,
    send_event:  b32,
    display:     ^Display,
    drawable:    Drawable,
    x:           i32,
    y:           i32,
    width:       i32,
    height:      i32,
    count:       i32,
    major_code:  i32,
    minor_code:  i32,
}

No_Expose_Event :: struct {
    type:        Event_Type,
    serial:      uint,
    send_event:  b32,
    display:     ^Display,
    drawable:    Drawable, // TODO
    major_code:  i32,
    minor_code:  i32,
}

Visibility_Event :: struct {
    using _:     Any_Event,
    state:       Visibility_State,
}

Visibility_State :: enum i32 {
    Unobscured        = 0,
    PartiallyObscured = 1,
    FullyObscured     = 2,
}

Create_Window_Event :: struct {
    type:              Event_Type,
    serial:            uint,
    send_event:        b32,
    display:           ^Display,
    parent:            Window,
    window:            Window,
    x:                 i32,
    y:                 i32,
    width:             i32,
    height:            i32,
    border_width:      i32,
    override_redirect: b32,
}

Destroy_Window_Event :: struct {
    type:       Event_Type,
    serial:     uint,
    send_event: b32,
    display:    ^Display,
    event:      Window,
    window:     Window,
}

Unmap_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    from_configure: b32,
}

Map_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    override_redirect: b32,
}

Map_Request_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    parent:         Window,
    window:         Window,
}

Reparent_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    parent:         Window,
    x:              i32,
    y:              i32,
    override_redirect: b32,
}

Configure_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    x:              i32,
    y:              i32,
    width:          i32,
    height:         i32,
    border_width:   i32,
    above:          Window,
    override_redirect: b32,
}

Gravity_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    x:              i32,
    y:              i32,
}

Resize_Request_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
    width:          i32,
    height:         i32,
}

Configure_Request_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    parent:         Window,
    window:         Window,
    x:              i32,
    y:              i32,
    width:          i32,
    height:         i32,
    border_width:   i32,
    above:          Window,
    detail:         Window_Stacking,
    value_mask:     uint, // TODO
}

Window_Stacking :: enum i32 {
    Above    = 0,
    Below    = 1,
    TopIf    = 2,
    BottomIf = 3,
    Opposite = 4,
}

Circulate_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    event:          Window,
    window:         Window,
    place:          Circulate_Place,
}

Circulate_Request_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    parent:         Window,
    window:         Window,
    place:          Circulate_Place,
}

Circulate_Place :: enum i32 {
    On_Top    = 0,
    On_Bottom = 1,
}

Property_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
    atom:           Atom,
    time:           Time,
    state:          Property_State,
}

Property_State :: enum i32 {
    New_Value = 0,
    Delete    = 1,
}

Selection_Clear_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
    selection:      Atom,
    time:           Time,
}

Selection_Request_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    owner:          Window,
    requestor:      Window,
    selection:      Atom,
    target:         Atom,
    property:       Atom,
    time:           Time,
}

Selection_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    requestor:      Window,
    selection:      Atom,
    target:         Atom,
    property:       Atom,
    time:           Time,
}

Colormap_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
    colormap:       Colormap,
    new:            b32,
    state:          Colormap_State,
}

Colormap_State :: enum i32 {
    Uninstalled = 0,
    Installed   = 1,
}

Client_Message_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
    message_type:   Atom,
    format:         i32,
    data: struct #raw_union {
        b: [20]i8,
        s: [10]i16,
        l: [5]int, // long live, X11 bugs
    },
}

Mapping_Event :: struct {
    using _:        Any_Event,
    request:        Mapping_Request,
    first_keycode:  i32,
    count:          i32,
}

Mapping_Request :: enum i32 {
    Modifier = 0,
    Keyboard = 1,
    Pointer  = 2,
}

Any_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    window:         Window,
}

Generic_Event :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    extension:      i32,
    evtype:         i32,
}

Generic_Event_Cookie :: struct {
    type:           Event_Type,
    serial:         uint,
    send_event:     b32,
    display:        ^Display,
    extension:      i32,
    evtype:         i32,
    cookie:         u32,
    data:           rawptr,
}

/*
    Information about display's color mapping.
*/
Visual :: struct {
    ext_data:     ^Ext_Data,
    visualid:     Visual_ID,
    class:        Visual_Class,
    red_mask:     uint,
    green_mask:   uint,
    blue_mask:    uint,
    bits_per_rgb: i32,
    map_entries:  i32,
}

/*
    Class of the visual.
*/
Visual_Class :: enum i32 {
    Static_Gray  = 0,
    Gray_Scale   = 1,
    Static_Color = 2,
    Pseudo_Color = 3,
    True_Color   = 4,
    Direct_Color = 5,
}

/*
    Extension data.
*/
Ext_Data :: struct {
    number:       i32,
    next:         ^Ext_Data,
    free_private: #type proc "c" (ext: ^Ext_Data) -> i32,
    private_data: rawptr,
}

/*
    Window class.
*/
Window_Class :: enum {
    Copy_From_Parent = 0,
    Input_Output     = 1,
    Input_Only       = 2,
}

X_Set_Window_Attributes :: struct {
    back_pixmap:       Pixmap,
    back_pixel:        uint,
    border_pixmap:     Pixmap,
    border_pixel:      uint,
    bit_gravity:       Gravity,
    win_gravity:       Gravity,
    backing_store:     Backing_Store,
    backing_planes:    uint,
    backing_pixel:     uint,
    save_under:        b32,
    event_mask:        Event_Mask,
    dont_propagate:    Event_Mask,
    override_redirect: b32,
    colormap:          Colormap,
    cursor:            Cursor,
}

X_Attribute_Mask :: bit_set[X_Attribute_Mask_Bits; i32]
X_Attribute_Mask_Bits :: enum {
    Back_Pixmap        = 0,
    Back_Pixel         = 1,
    Border_Pixmap      = 2,
    Border_Pixel       = 3,
    Bit_Gravity        = 4,
    Win_Gravity        = 5,
    Backing_Store      = 6,
    Backing_Planes     = 7,
    Backing_Pixel      = 8,
    Override_Redirect  = 9,
    Save_Under         = 10,
    Event_Mask         = 11,
    Dont_Propagate     = 12,
    Colormap           = 13,
    Cursor             = 14,
}

/*
    Event mask for the window events that should be saved.
*/
Event_Mask :: bit_set[Event_Mask_Bits; int]
Event_Mask_Bits :: enum {
    Key_Press             = 0,
    Key_Release           = 1,
    Button_Press          = 2,
    Button_Release        = 3,
    Enter_Window          = 4,
    Leave_Window          = 5,
    Pointer_Motion        = 6,
    Pointer_Motion_Hint   = 7,
    Button1_Motion        = 8,
    Button2_Motion        = 9,
    Button3_Motion        = 10,
    Button4_Motion        = 11,
    Button5_Motion        = 12,
    Button_Motion         = 13,
    Keymap_State          = 14,
    Exposure              = 15,
    Visibility_Change     = 16,
    Structure_Notify      = 17,
    Resize_Redirect       = 18,
    Substructure_Notify   = 19,
    Substructure_Redirect = 20,
    Focus_Change          = 21,
    Property_Change       = 22,
    Colormap_Change       = 23,
    Owner_Grab_Button     = 24,
}

/*
    Gravity for bits when the window is resized, or the gravity for
    the window when the parent window is resized.
*/
Gravity :: enum i32 {
    Forget      =  0,
    Unmap       =  0,
    North_West  =  1,
    North       =  2,
    North_East  =  3,
    West        =  4,
    Center      =  5,
    East        =  6,
    South_West  =  7,
    South       =  8,
    South_East  =  9,
    Static      = 10,
}

/*
    Specifies when the backing store should mantain the data.
*/
Backing_Store :: enum i32 {
    Not_Useful  = 0,
    When_Mapped = 1,
    Always      = 2,
}

/*
    X image
*/
Image :: struct {
    width:            i32,
    height:           i32,
    xoffset:          i32,
    format:           Image_Format,
    data:             [^]u8,
    byte_order:       Byte_Order,
    bitmap_unit:      i32,
    bitmap_bit_order: i32,
    bitmap_pad:       i32,
    depth:            i32,
    stride:           i32,
    bits_per_pixel:   i32,
    red_mask:         uint,
    green_mask:       uint,
    blue_mask:        uint,
    obdata:           rawptr,
    f: struct {
        create_image: #type proc "c" (d: ^Display, v: ^Visual, depth: u32, f: Image_Format, off: i32, data: [^]u8, w, h: u32, pad, stride: i32) -> Image,
        destroy_image: #type proc "c" (img: ^Image) -> b32,
        get_pixel: #type proc "c" (img: ^Image, x,y: i32) -> uint,
        put_pixel: #type proc "c" (img: ^Image, x,y: i32, pix: uint) -> b32,
        sub_image: #type proc "c" (img: ^Image, x,y: i32, w,h: u32) -> Image,
        add_pixel: #type proc "c" (img: ^Image, p: int) -> b32,
    },
}

/*
    Image format
*/
Image_Format :: enum i32 {
    XYBitmap = 0,
    XYPixmap = 1,
    ZPixmap  = 2,
}

/*
    Byte order
*/
Byte_Order :: enum i32 {
    LSBFirst = 0,
    MSBFirst = 1,
}

synchronize :: proc(display: ^Display, )

get_error_text :: proc(display: ^Display, error: Error, buf: []u8) -> string {
    str_len := XGetErrorText(display, error, cast([^]u8) raw_data(buf), cast(i32) len(buf))
    return cast(string) (cast([^]u8) raw_data(buf))[:str_len]
}

open_display :: proc(name: cstring) -> (^Display, Error) {
    display := XOpenDisplay(name)
    if display == nil {
        return nil, x11_last_error
    }
    return display, nil
}

default_gc :: proc(display: ^Display, #any_int screen_number: i32) -> GC {
    return XDefaultGC(display, screen_number)
}

flush_gc :: proc(display: ^Display, gc: GC) {
    XFlushGC(display, gc)
}

default_visual :: proc(display: ^Display, #any_int screen_number: i32) -> (^Visual, Error) {
    visual := XDefaultVisual(display, screen_number)
    if visual == nil {
        return nil, x11_last_error
    }
    return visual, nil
}

intern_atom :: proc(display: ^Display, name: cstring, create: bool) -> (Atom, Error) {
    atom := XInternAtom(display, name, create)
    if atom == 0 {
        return 0, x11_last_error
    }
    return atom, nil
}

default_root_window :: proc(display: ^Display) -> (Window, Error) {
    window := XDefaultRootWindow(display)
    if window == 0 {
        return 0, x11_last_error
    }
    return window, nil
}

create_window :: proc (display: ^Display, parent: Window,
    #any_int x, y, width, height, border, depth: int,
    class: Window_Class, visual: ^Visual,
    attr: ^Window_Attributes_Set) -> (Window, Error)
{
    window := XCreateWindow(display, parent, cast(i32) x, cast(i32) y,
        cast(u32) width, cast(u32) height, cast(u32) border, cast(i32) depth,
        class, visual, attr.mask, &attr.set)
    if window == 0 {
        return 0, x11_last_error
    }
    return window, nil
}

destroy_window :: proc(display: ^Display, window: Window) {
    XDestroyWindow(display, window)
}

store_name :: proc(display: ^Display, window: Window, name: cstring) -> Error {
    ok := XStoreName(display, window, name)
    if !ok {
        return x11_last_error
    }
    return nil
}

select_input :: proc(display: ^Display, window: Window, event_mask: Event_Mask) -> Error {
    ok := XSelectInput(display, window, event_mask)
    if !ok {
        return x11_last_error
    }
    return nil
}

map_window :: proc(display: ^Display, window: Window) -> Error {
    ok := XMapWindow(display, window)
    if !ok {
        return x11_last_error
    }
    return nil
}

map_raised :: proc(display: ^Display, window: Window) -> Error {
    ok := XMapRaised(display, window)
    if !ok {
        return x11_last_error
    }
    return nil
}

set_wm_protocols :: proc(display: ^Display, window: Window, protos: []Atom) -> Error {
    return XSetWMProtocols(display, window, cast([^]Atom) raw_data(protos), cast(i32) len(protos))
}

create_image :: proc(display: ^Display, visual: ^Visual,
    #any_int depth: uint,
    format: Image_Format,
    #any_int offset: int,
    data: rawptr,
    #any_int width: int,
    #any_int height: int,
    #any_int pad: int,
    #any_int stride: int) -> (^Image, Error)
{
    image := XCreateImage(display, visual, cast(u32) depth, format, cast(i32) offset,
        cast(rawptr) data, cast(u32) width, cast(u32) height, cast(i32) pad, cast(i32) stride)
    if image == nil {
        return nil, x11_last_error
    }
    return image, nil
}

put_image :: proc(display: ^Display, drawable: Drawable, gc: GC, image: ^Image,
    #any_int src_x, src_y, dst_x, dst_y: i32,
    #any_int width, height: u32)
{
    XPutImage(display, drawable, gc, image, src_x, src_y, dst_x, dst_y, width, height)
}

next_event :: proc(display: ^Display, event: ^Event) -> Error {
    ok := XNextEvent(display, event)
    if !ok {
        return x11_last_error
    }
    return nil
}
