# This file is a component in the Rosencrantz Entertainment Conglomerate
# Copyright (C) 2021 Hampus Andreas Niklas Rosencrantz

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

module DB::Serializable
  macro included
    {% verbatim do %}
      macro finished
        def self.type_array
          \{{ @type.instance_vars
            .reject { |var| var.annotation(::DB::Field) && var.annotation(::DB::Field)[:ignore] }
            .map { |name| name.stringify }
          }}
        end

        def initialize(tuple)
          \{% for var in @type.instance_vars %}
            \{% ann = var.annotation(::DB::Field) %}
            \{% if ann && ann[:ignore] %}
            \{% else %}
              @\{{var.name}} = tuple[:\{{var.name.id}}]
            \{% end %}
          \{% end %}
        end

        def to_a
          \{{ @type.instance_vars
            .reject { |var| var.annotation(::DB::Field) && var.annotation(::DB::Field)[:ignore] }
            .map { |name| name }
          }}
        end
      end
    {% end %}
  end
end

module JSON::Serializable
  macro included
    {% verbatim do %}
      macro finished
        def initialize(tuple)
          \{% for var in @type.instance_vars %}
            \{% ann = var.annotation(::JSON::Field) %}
            \{% if ann && ann[:ignore] %}
            \{% else %}
              @\{{var.name}} = tuple[:\{{var.name.id}}]
            \{% end %}
          \{% end %}
        end
      end
    {% end %}
  end
end

macro templated(filename, template = "template", x = true)
  x = {{x}}
  render "src/getamovie/views/#{{{filename}}}.ecr", "src/getamovie/views/#{{{template}}}.ecr"
end

macro rendered(filename)
  render "src/getamovie/views/#{{{filename}}}.ecr"
end
