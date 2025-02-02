const std = @import("std");
const fs = std.fs;

pub fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn parseNumber(str: []const u8, start: *usize) !u32 {
    var num: u32 = 0;
    var i = start.*;
    var digits: u8 = 0;

    while (i < str.len and isDigit(str[i])) : (i += 1) {
        num = num * 10 + (str[i] - '0');
        digits += 1;

        if (digits > 3) {
            return error.NumberTooLarge;
        } 
    }

    if (digits == 0) {
        return error.NoNumber;
    } 
    
    start.* = i;
    return num;
}

pub fn findMultiplications(input: []const u8) !u32 {
    var sum: u32 = 0;
    var i: usize = 0;

    while (i + 4 <= input.len) {
        if (input[i] == 'm' and 
            input[i + 1] == 'u' and 
            input[i + 2] == 'l' and 
            input[i + 3] == '(') {
            i += 4;
            
            const num1 = parseNumber(input, &i) catch {
                i += 1;
                continue;
            };

            if (i >= input.len or input[i] != ',') {
                i += 1;
                continue;
            }
            i += 1;

            const num2 = parseNumber(input, &i) catch {
                i += 1;
                continue;
            };

            if (i >= input.len or input[i] != ')') {
                i += 1;
                continue;
            }

            sum += num1 * num2;
        }
        i += 1;
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const file = try fs.cwd().openFile("3.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var buf_stream = buf_reader.reader();
    var buf: [8 * 1024]u8 = undefined;

    var result: u64 = 0;

    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        result += try findMultiplications(line);
    }

    std.debug.print("Result: {}\n", .{result});
}