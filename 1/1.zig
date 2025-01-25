const std = @import("std");
const fs = std.fs;

fn lessThan(context: void, a: i32, b: i32) bool {
    _ = context;
    return a < b;
}

fn partOne(left_column: std.ArrayList(i32), right_column: std.ArrayList(i32)) !i32 {
    std.mem.sort(i32, left_column.items, {}, lessThan);
    std.mem.sort(i32, right_column.items, {}, lessThan);

    var result: i32 = 0;
    for (left_column.items, right_column.items) |item1, item2| {
        result += @intCast(@abs(item1 - item2));
    }
    
    return result;
}

fn partTwo(left_column: std.ArrayList(i32), right_column: std.ArrayList(i32)) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var result: i32 = 0;
    var freq = std.AutoHashMap(i32, i32).init(allocator);
    defer freq.deinit();

    for (right_column.items) |item| {
        const entry = try freq.getOrPut(item);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    for (left_column.items) |item| {
        if (freq.contains(item)) {
            const count = freq.get(item).?;
            result += item * count;
        }
    }

    return result;
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

    const first_result = try partOne(left_column, right_column);
    std.debug.print("Part 1: difference between columns is {}\n", .{first_result});

    const second_result = try partTwo(left_column,right_column);
    std.debug.print("Part 2: similarity score {}\n", .{second_result});
}
