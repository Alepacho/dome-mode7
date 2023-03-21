// Copyright (c) 2023 Alepacho

import "dome" for Window
import "graphics" for Canvas, Color, ImageData, Font
import "math" for Math, Vector
import "input" for Keyboard, Mouse

var PI      = 3.14
var WIDTH   = 256
var HEIGHT  = 224 / 2
var SCALE   = 3

class Main {
    construct new() {
        Window.resize(WIDTH * SCALE, HEIGHT * SCALE)
        Canvas.resize(WIDTH, HEIGHT)
        _w          = Canvas.width
        _h          = Canvas.height
        _image      = ImageData.load("assets/curcuit_01.png")
        _grass      = ImageData.load("assets/grass.png")
        _redraw     = true

        _bkgImage   = List.new()
        _bkg        = Color.rgb(248, 232, 144)
        _horizon    = 200
        _scale      = 10
        _tscale     = 0.5
        _position   = Vector.new(512, 512)
        _direction  = 0.0
        _speed      = 3
    }

    w { _w }
    h { _h }
    image { _image }
    position { _position }

    init() {
        Window.title = "DOME : MODE 7"
        _bkgImage.add(ImageData.load("assets/background_02.png"))
        _bkgImage.add(ImageData.load("assets/background_01.png"))
        System.print("size: %(_w), %(_h)")
    }

    update() {
        // Movement
        var right = (Keyboard.isKeyDown("right") || Keyboard.isKeyDown("d") ? 1 : 0)
        var left  = (Keyboard.isKeyDown("left")  || Keyboard.isKeyDown("a") ? 1 : 0)
        var up    = (Keyboard.isKeyDown("up")    || Keyboard.isKeyDown("w") ? 1 : 0)
        var down  = (Keyboard.isKeyDown("down")  || Keyboard.isKeyDown("s") ? 1 : 0)

        var h = left - right
        var v = up   - down 

        if (v != 0) {
            var dx = (v * _speed) * Math.cos(_direction + 90 * (PI / 180))
            var dy = (v * _speed) * Math.sin(_direction + 90 * (PI / 180))
            _position.x = _position.x + dx
            _position.y = _position.y + dy
            _redraw = true
        }

        if (h != 0) {
            var dx = (h * _speed) * Math.cos(_direction)
            var dy = (h * _speed) * Math.sin(_direction)
            _position.x = _position.x + dx
            _position.y = _position.y + dy
            _redraw = true
        }

        // Turn around
        if (Keyboard.isKeyDown("q")) {
            _direction = _direction - 1.25 * (PI / 180)
            if (_direction < 0) _direction = _direction + 360 * (PI / 180)
            _redraw = true
        }
        if (Keyboard.isKeyDown("e")) {
            _direction = _direction + 1.25 * (PI / 180)
            if (_direction > 359 * (PI / 180)) _direction = _direction - 360 * (PI / 180)
            _redraw = true
        }

        // Change FOV
        if (Keyboard.isKeyDown("z")) {
            _horizon = _horizon + 5 
            _redraw = true
        }
        if (Keyboard.isKeyDown("x")) {
            _horizon = _horizon - 5
            _redraw = true
        }

        // Change player height
        if (Keyboard.isKeyDown("space")) {
            _scale = _scale + 1
            _redraw = true
        }
        if (Keyboard.isKeyDown("c")) {
            _scale = _scale - 1
            _redraw = true
        }
    }

    draw(alpha) {
        if (_redraw == true) {
            _redraw = false

            var sin = Math.sin(_direction)
            var cos = Math.cos(_direction)

            Canvas.cls(_bkg)

            var HALF_WIDTH  = this.w / 2
            var HALF_HEIGHT = this.h / 2
            for (y in 0..HALF_HEIGHT) {
                var j  = (y + HALF_HEIGHT)
                var yy = j + _horizon
                var zz = j - HALF_HEIGHT + 0.01

                for (x in 0...this.w) {
                    var xx = HALF_WIDTH - x
                    
                    // Rotation
                    var rx = (xx * cos - yy * sin)
                    var ry = (xx * sin + yy * cos)

                    // Projection
                    var px = rx / zz * _scale 
                    var py = ry / zz * _scale

                    var p = Vector.new(
                        Math.floor(px + _position.x),
                        Math.floor(py + _position.y)
                    )

                    if (p.x >= 0 && p.y >= 0 && p.x < this.image.width && p.y < this.image.height) {
                        var pc = this.image.pget(p.x % this.image.width, p.y % this.image.height)
                        Canvas.pset(x, y + HALF_HEIGHT, pc)
                    } else {
                        var pc = _grass.pget(Math.abs(p.x) % _grass.width, Math.abs(p.y) % _grass.height)
                        Canvas.pset(x, y + HALF_HEIGHT, pc)
                    }
                }
            }

            var d1 = (_direction * (180 / PI)) / 360 * (_bkgImage[0].width - 512)
            _bkgImage[0].draw(-(d1), HALF_HEIGHT - _bkgImage[0].height)

            var d2 = (_direction * (180 / PI)) / 360 * (_bkgImage[1].width - 1024)
            _bkgImage[1].draw(-(d1 * 2), HALF_HEIGHT - _bkgImage[1].height)
        }

        // Debug Info
        var fps = Math.floor(Window.fps)
        Canvas.rectfill(0, 0, this.w, 8, Color.rgb(0, 0, 0))
        Canvas.print("FPS:%(fps)", 0, 0, Font.default)
        var dir = Math.floor(_direction * (180 / PI))
        Canvas.print("DIR:%(dir)", 64, 0, Font.default)
        var fov = Math.floor(_horizon)
        Canvas.print("FOV:%(fov)", 128, 0, Font.default)
        var yyy = Math.floor(_scale)
        Canvas.print("Y:%(yyy)", 192, 0, Font.default)
    }
}

var Game = Main.new()