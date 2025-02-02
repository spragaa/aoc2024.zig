const std = @import("std");
const fs = std.fs;

fn is_increasing_order(report: std.ArrayList(i32)) bool {
    if (report.items.len <= 1) {
        return true;
    }
    
    for (0..report.items.len-1) |index| {
        const diff = report.items[index + 1] - report.items[index];
        if (diff <= 0 or diff < 1 or diff > 3) {
            return false;
        }
    }
    return true;
}

fn is_decreasing_order(report: std.ArrayList(i32)) bool {
    if (report.items.len <= 1) {
        return true;
    }
    
    for (0..report.items.len-1) |index| {
        const diff = report.items[index] - report.items[index + 1];
        if (diff <= 0 or diff < 1 or diff > 3) {
            return false;
        }
    }
    return true;
}

fn is_safe_report(report: std.ArrayList(i32)) bool {
    return is_decreasing_order(report) or is_increasing_order(report);
}

fn is_potentially_safe_report(report: std.ArrayList(i32)) bool {
    if (is_decreasing_order(report) or is_increasing_order(report)) {
        return true;
    }

    var temp_list = std.ArrayList(i32).init(report.allocator);
    defer temp_list.deinit();

    for (0..report.items.len) |skip_index| {
        temp_list.clearRetainingCapacity();
        
        for (0..report.items.len) |i| {
            if (i != skip_index) {
                temp_list.append(report.items[i]) catch continue;
            }
        }

        if (is_decreasing_order(temp_list) or is_increasing_order(temp_list)) {
            return true;
        }
    }

    return false;
}

fn print_report(report: std.ArrayList(i32)) void {
    std.debug.print("Parsed report with {d} items: ", .{report.items.len});
    for (report.items) |num| {
        std.debug.print("{d} ", .{num});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var report = std.ArrayList(i32).init(allocator);
    defer report.deinit();

    var buf_reader = std.io.bufferedReader(file.reader());
    var buf_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var safe_report_count: i32 = 0;
    var potentially_safe_report_count: i32 = 0;

    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = std.mem.tokenizeAny(u8, line, " \t");

        while (iter.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try report.append(num);
        }

        print_report(report);

        if (is_safe_report(report)) {
            safe_report_count += 1;
        }

        if (is_potentially_safe_report(report)) {
            potentially_safe_report_count += 1;
        }

        report.clearRetainingCapacity();
    }

    std.debug.print("Safe report count {d}\n", .{safe_report_count});
    std.debug.print("Potentially safe report count {d}\n", .{potentially_safe_report_count});
}