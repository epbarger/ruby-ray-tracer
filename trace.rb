require 'pry'
require 'chunky_png'

class Vector
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def subtract(another_vector)
    return Vector.new(x - another_vector.x, y - another_vector.y, z - another_vector.z)
  end

  def dot_product(another_vector)
    return x * another_vector.x + y * another_vector.y + z * another_vector.z
  end

  def scale(scalar)
    return Vector.new(x * scalar, y * scalar, z * scalar)
  end

  def add(another_vector)
    return Vector.new(x + another_vector.x, y + another_vector.y, z + another_vector.z)
  end
end

class Sphere
  attr_accessor :position, :radius, :material

  def initialize(position, radius, material)
    @position = position
    @radius = radius
    @material = material
  end

  # /* A = d.d, the vector dot product of the direction */
  # float A = vectorDot(&r->dir, &r->dir); 
  
  # /* We need a vector representing the distance between the start of 
  #  * the ray and the position of the circle.
  #  * This is the term (p0 - c) 
  #  */
  # vector dist = vectorSub(&r->start, &s->pos);
  
  # /* 2d.(p0 - c) */  
  # float B = 2 * vectorDot(&r->dir, &dist);
  
  # /* (p0 - c).(p0 - c) - r^2 */
  # float C = vectorDot(&dist, &dist) - (s->radius * s->radius);
  
  # /* Solving the discriminant */
  # float discr = B * B - 4 * A * C;
  
  # /* If the discriminant is negative, there are no real roots.
  #  * Return false in that case as the ray misses the sphere.
  #  * Return true in all other cases (can be one or two intersections)
  #  * t represents the distance between the start of the ray and
  #  * the point on the sphere where it intersects.
  #  */
  # if(discr < 0)
  #   retval = false;
  # else{
  #   float sqrtdiscr = sqrtf(discr);
  #   float t0 = (-B + sqrtdiscr)/(2);
  #   float t1 = (-B - sqrtdiscr)/(2);
    
  #   /* We want the closest one */
  #   if(t0 > t1)
  #     t0 = t1;

  #   /* Verify t1 larger than 0 and less than the original t */
  #   if((t0 > 0.001f) && (t0 < *t)){
  #     *t = t0;
  #     retval = true;
  #   }else
  #     retval = false;
  # }

  def ray_intersect(ray)
    intersection_point = nil
    term_a = ray.direction.dot_product(ray.direction)
    distance = ray.start.subtract(position)
    term_b = 2 * ray.direction.dot_product(distance)
    term_c = distance.dot_product(distance) - radius * radius
    discriminant = term_b * term_b - 4 * term_a * term_c

    if discriminant >= 0
      sqrt_discriminant = Math.sqrt(discriminant)
      t0 = (-term_b + sqrt_discriminant)/2
      t1 = (-term_b - sqrt_discriminant)/2

      if (t0 > t1) 
        t0 = t1
      end

      if (t0 > 0.001)
        intersection_point = t0
      end
    end

    intersection_point
  end
end

class Ray
  attr_accessor :start, :direction

  def initialize(start, direction)
    @start = start
    @direction = direction
  end
end

class Image
  attr_accessor :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @pixels = Array.new(width) { Array.new(height) }
  end

  def set_pixel(x, y, value)
    @pixels[x][y] = value
  end

  def print_ascii
    @pixels.each do |row|
      row.each do |pixel|
        print(!!pixel ? '++' : '  ')
      end
      print("\n")
    end
  end

  def export_png
    background_color = ChunkyPNG::Color.rgba(0,0,0,255)
    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
    height.times do |y|
      width.times do |x|
        color = @pixels[x][y]
        if color 
          rgba = color.to_rgba
          png[x,y] = ChunkyPNG::Color.rgba(rgba[0], rgba[1], rgba[2], rgba[3])
        end
      end
    end
    png.save('output.png', interlace: true)
  end
end

class Color
  attr_accessor :red, :blue, :green

  def initialize(red, blue, green)
    @red = red
    @blue = blue
    @green = green
  end

  def to_rgba
    [([red, 1].min * 255).to_i, ([blue, 1].min * 255).to_i, ([green,1].min * 255).to_i, 255]
  end
end

class Light
  attr_accessor :position, :intensity

  def initialize(position, intensity)
    @position = position
    @intensity = intensity
  end  
end

class Material
  attr_accessor :diffuse, :reflection

  def initialize(diffuse, reflection)
    @diffuse = diffuse
    @reflection = reflection
  end
end

red_material = Material.new(Color.new(1,0,0), 0.2)
green_material = Material.new(Color.new(0,1,0), 0.5)
blue_material = Material.new(Color.new(0,0,1), 0.9)
mirror_material = Material.new(Color.new(1,1,1), 1.0)
  
spheres = []
# spheres[0] = Sphere.new(Vector.new(200, 300, 0), 100, red_material)
# spheres[1] = Sphere.new(Vector.new(400, 400, 0), 100, green_material)
# spheres[2] = Sphere.new(Vector.new(500, 140, 0), 100, blue_material)
spheres[0] = Sphere.new(Vector.new(200, 300, 0), 100, mirror_material)
spheres[1] = Sphere.new(Vector.new(400, 400, 0), 100, mirror_material)
spheres[2] = Sphere.new(Vector.new(500, 140, 0), 100, mirror_material)
  
lights = []
# lights[0] = Light.new(Vector.new(0, 240, -100), Color.new(1,1,1))
# lights[1] = Light.new(Vector.new(3200, 3000, -1000), Color.new(0.6, 0.7, 1))
# lights[2] = Light.new(Vector.new(600, 0, -100), Color.new(0.3, 0.5, 1))
lights[0] = Light.new(Vector.new(0, 240, -100), Color.new(1,0,0))
lights[1] = Light.new(Vector.new(3200, 3000, -1000), Color.new(0, 1, 0))
lights[2] = Light.new(Vector.new(600, 0, -100), Color.new(0, 0, 1))
# lights[0] = Light.new(Vector.new(0,0, -500), Color.new(1,1,1))

width = 800
height = 600
ray_direction = Vector.new(0,0,1)
image = Image.new(width, height)

height.times do |y|
  width.times do |x|
    ray = Ray.new(Vector.new(x, y, -2000), ray_direction)

    red = 0
    green = 0
    blue = 0
    level = 0
    coef = 1.0

    while((coef > 0) && (level < 15)) do

      #   do{
      #     /* Find closest intersection */
      #     float t = 20000.0f;
      #     int currentSphere = -1;
          
      #     unsigned int i;
      #     for(i = 0; i < 3; i++){
      #       if(intersectRaySphere(&r, &spheres[i], &t))
      #         currentSphere = i;
      #     }
      #     if(currentSphere == -1) break;
          
      #     vector scaled = vectorScale(t, &r.dir);
      #     vector newStart = vectorAdd(&r.start, &scaled);
          
      #     /* Find the normal for this new vector at the point of intersection */
      #     vector n = vectorSub(&newStart, &spheres[currentSphere].pos);
      #     float temp = vectorDot(&n, &n);
      #     if(temp == 0) break;
          
      #     temp = 1.0f / sqrtf(temp);
      #     n = vectorScale(temp, &n);

      closest_intersection = Float::INFINITY
      closest_sphere = nil
      spheres.each do |sphere|
        intersection = sphere.ray_intersect(ray)
        if intersection && (intersection < closest_intersection)
          closest_intersection = intersection
          closest_sphere = sphere
        end
      end



      break unless closest_intersection < Float::INFINITY

      scaled = ray.direction.scale(closest_intersection)
      new_start = ray.start.add(scaled)

      normal = new_start.subtract(closest_sphere.position)
      temp = normal.dot_product(normal)
      break if temp == 0

      temp = 1.0 / Math.sqrt(temp)
      normal = normal.scale(temp)


      # if closest_sphere
      #   red = closest_sphere.material.diffuse.red
      #   blue = closest_sphere.material.diffuse.blue
      #   green = closest_sphere.material.diffuse.green
      # end


      #     /* Find the material to determine the colour */
      #     material currentMat = materials[spheres[currentSphere].material];
          
      #     /* Find the value of the light at this point */
      #     unsigned int j;
      #     for(j=0; j < 3; j++){
      #       light currentLight = lights[j];
      #       vector dist = vectorSub(&currentLight.pos, &newStart);
      #       if(vectorDot(&n, &dist) <= 0.0f) continue;
      #       float t = sqrtf(vectorDot(&dist,&dist));
      #       if(t <= 0.0f) continue;
            
      #       ray lightRay;
      #       lightRay.start = newStart;
      #       lightRay.dir = vectorScale((1/t), &dist);

          #       /* Calculate shadows */
          # bool inShadow = false;
          # unsigned int k;
          # for (k = 0; k < 3; ++k) {
          #   if (intersectRaySphere(&lightRay, &spheres[k], &t)){
          #     inShadow = true;
          #     break;
          #   }
          # }
          # if (!inShadow){
          #   /* Lambert diffusion */
          #   float lambert = vectorDot(&lightRay.dir, &n) * coef; 
          #   red += lambert * currentLight.intensity.red * currentMat.diffuse.red;
          #   green += lambert * currentLight.intensity.green * currentMat.diffuse.green;
          #   blue += lambert * currentLight.intensity.blue * currentMat.diffuse.blue;
          # }
            
        
      lights.each do |light|
        distance = light.position.subtract(new_start) 
        next if distance.dot_product(normal) <= 0.0
        t = Math.sqrt(distance.dot_product(distance))
        next if t <= 0.0

        light_ray = Ray.new(new_start, distance.scale(1/t))

        # Shadows
        in_shadow = false
        # spheres.each do |sphere|
        #   if sphere.ray_intersect(light_ray)
        #     in_shadow = true
        #     break 
        #   end
        # end

        # Lambert diffusion
        unless in_shadow
          lambert = light_ray.direction.dot_product(normal) * coef
          red += lambert * light.intensity.red * closest_sphere.material.diffuse.red
          green += lambert * light.intensity.green * closest_sphere.material.diffuse.green
          blue += lambert * light.intensity.blue * closest_sphere.material.diffuse.blue
        end
      end

      #     /* Iterate over the reflection */
      #     coef *= currentMat.reflection;
          
      #     /* The reflected ray start and direction */
      #     r.start = newStart;
      #     float reflect = 2.0f * vectorDot(&r.dir, &n);
      #     vector tmp = vectorScale(reflect, &n);
      #     r.dir = vectorSub(&r.dir, &tmp);

      #     level++;

      coef *= closest_sphere.material.reflection
      ray.start = new_start
      reflect = 2.0 * ray.direction.dot_product(normal)
      tmp = normal.scale(reflect)
      ray.direction = ray.direction.subtract(tmp)

      level += 1
    end

    #   }while((coef > 0.0f) && (level < 15));
    
    #   img[(x + y*WIDTH)*3 + 0] = (unsigned char)min(red*255.0f, 255.0f);
    #   img[(x + y*WIDTH)*3 + 1] = (unsigned char)min(green*255.0f, 255.0f);
    #   img[(x + y*WIDTH)*3 + 2] = (unsigned char)min(blue*255.0f, 255.0f); 
    #binding.pry if closest_sphere
    image.set_pixel(x,y,Color.new(red, green, blue))
  end
end

image.export_png
