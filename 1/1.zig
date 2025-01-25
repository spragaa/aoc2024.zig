const std = @import("std");
const fs = std.fs;

fn lessThan(context: void, a: i32, b: i32) bool {
    _ = context;
    return a < b;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var left_column = std.ArrayList(i32).init(allocator);
    defer left_column.deinit();
    var right_column = std.ArrayList(i32).init(allocator);
    defer right_column.deinit();

    var buf_reader = std.io.bufferedReader(file.reader());
    var read_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    while (try read_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = std.mem.tokenizeAny(u8, line, " \t");
        
        if (iter.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try left_column.append(num);
        }

        if (iter.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try right_column.append(num);
        }
    }

    std.debug.print("Left column ({d} items): ", .{left_column.items.len});
    for (left_column.items) |num| {
        std.debug.print("{d} ", .{num});
    }
    std.debug.print("\n\n", .{});

    std.debug.print("Right column ({d} items): ", .{right_column.items.len});
    for (right_column.items) |num| {
        std.debug.print("{d} ", .{num});
    }
    std.debug.print("\n\n", .{});

    if (right_column.items.len != left_column.items.len) {
        std.debug.print("Length of left and right columns is not equal!", .{});
        return;        
    }
    
    std.mem.sort(i32, left_column.items, {}, lessThan);
    std.mem.sort(i32, right_column.items, {}, lessThan);

    std.debug.print("Sorted left column ({d} items): ", .{left_column.items.len});
    for (left_column.items) |num| {
        std.debug.print("{d} ", .{num});
    }
    std.debug.print("\n\n", .{});

    std.debug.print("Sorted right column ({d} items): ", .{right_column.items.len});
    for (right_column.items) |num| {
        std.debug.print("{d} ", .{num});
    }
    std.debug.print("\n\n", .{});

    var result: u32 = 0;
    for (left_column.items, right_column.items) |item1, item2| {
        result += @intCast(@abs(item1 - item2));
    }
    std.debug.print("Result: {d}\n\n", .{result});
}