const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  PageBreak, Header, Footer, PageNumber, NumberFormat,
  AlignmentType, HeadingLevel, WidthType, BorderStyle, ShadingType,
  PageOrientation, LevelFormat,
} = require("docx");
const fs = require("fs");

// ─── Palette (Cool + Heavy + Calm → Deep Sea Academic) ───
const P = {
  primary: "#162032",
  body: "#1C2A3D",
  secondary: "#5B6B7D",
  accent: "#8B7E5A",
  surface: "#F5F7FA",
};
const c = (hex) => hex.replace("#", "");

// ─── Helpers ───
function heading1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 160, line: 312 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 32,
        font: { ascii: "Times New Roman", eastAsia: "SimHei" },
        color: c(P.primary),
      }),
    ],
  });
}

function heading2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 280, after: 120, line: 312 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 28,
        font: { ascii: "Times New Roman", eastAsia: "SimHei" },
        color: c(P.primary),
      }),
    ],
  });
}

function heading3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 100, line: 312 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimHei" },
        color: c(P.primary),
      }),
    ],
  });
}

function body(text) {
  return new Paragraph({
    alignment: AlignmentType.JUSTIFIED,
    indent: { firstLine: 480 },
    spacing: { line: 312 },
    children: [
      new TextRun({
        text,
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: "000000",
      }),
    ],
  });
}

function bodyNoIndent(text) {
  return new Paragraph({
    spacing: { line: 312 },
    children: [
      new TextRun({
        text,
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: "000000",
      }),
    ],
  });
}

function boldBody(text) {
  return new Paragraph({
    spacing: { line: 312 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: "000000",
      }),
    ],
  });
}

function codeBlock(text) {
  return new Paragraph({
    spacing: { line: 312, before: 60, after: 60 },
    indent: { left: 480 },
    children: [
      new TextRun({
        text,
        size: 20,
        font: { ascii: "Consolas", eastAsia: "SimSun" },
        color: c(P.primary),
      }),
    ],
  });
}

function note(text) {
  return new Paragraph({
    spacing: { line: 312 },
    indent: { left: 480 },
    children: [
      new TextRun({
        text: "\u6ce8\uFF1A",
        bold: true,
        size: 22,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: c(P.secondary),
      }),
      new TextRun({
        text,
        size: 22,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: c(P.secondary),
      }),
    ],
  });
}

function emptyLine() {
  return new Paragraph({ spacing: { line: 312 }, children: [] });
}

// ─── Table Helper ───
function makeTable(headers, rows, colWidths) {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: {
      top: { style: BorderStyle.SINGLE, size: 2, color: "9AA6B2" },
      bottom: { style: BorderStyle.SINGLE, size: 2, color: "9AA6B2" },
      left: { style: BorderStyle.SINGLE, size: 1, color: "D0D0D0" },
      right: { style: BorderStyle.SINGLE, size: 1, color: "D0D0D0" },
      insideHorizontal: { style: BorderStyle.SINGLE, size: 1, color: "D0D0D0" },
      insideVertical: { style: BorderStyle.SINGLE, size: 1, color: "D0D0D0" },
    },
    rows: [
      new TableRow({
        tableHeader: true,
        cantSplit: true,
        children: headers.map((h, i) =>
          new TableCell({
            children: [
              new Paragraph({
                alignment: AlignmentType.CENTER,
                children: [
                  new TextRun({
                    text: h,
                    bold: true,
                    size: 21,
                    font: { ascii: "Times New Roman", eastAsia: "SimHei" },
                    color: "FFFFFF",
                  }),
                ],
              }),
            ],
            shading: { type: ShadingType.CLEAR, fill: c(P.primary) },
            margins: { top: 60, bottom: 60, left: 100, right: 100 },
            width: colWidths ? { size: colWidths[i], type: WidthType.PERCENTAGE } : undefined,
          })
        ),
      }),
      ...rows.map(
        (row) =>
          new TableRow({
            cantSplit: true,
            children: row.map((cell, i) =>
              new TableCell({
                children: [
                  new Paragraph({
                    spacing: { line: 300 },
                    children: [
                      new TextRun({
                        text: cell,
                        size: 20,
                        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
                        color: "000000",
                      }),
                    ],
                  }),
                ],
                margins: { top: 50, bottom: 50, left: 100, right: 100 },
                shading: rows.indexOf(row) % 2 === 1
                  ? { type: ShadingType.CLEAR, fill: c(P.surface) }
                  : undefined,
                width: colWidths ? { size: colWidths[i], type: WidthType.PERCENTAGE } : undefined,
              })
            ),
          })
      ),
    ],
  });
}

// ─── Checkbox Item ───
function checkItem(text) {
  return new Paragraph({
    spacing: { line: 312, before: 40, after: 40 },
    indent: { left: 360, hanging: 360 },
    children: [
      new TextRun({
        text: "\u25A1  ",
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: "000000",
      }),
      new TextRun({
        text,
        size: 24,
        font: { ascii: "Times New Roman", eastAsia: "SimSun" },
        color: "000000",
      }),
    ],
  });
}

// ─── Document Content ───
const doc = new Document({
  styles: {
    default: {
      document: {
        run: {
          font: { ascii: "Times New Roman", eastAsia: "SimSun" },
          size: 24,
          color: "000000",
        },
        paragraph: {
          spacing: { line: 312 },
        },
      },
      heading1: {
        run: { font: { ascii: "Times New Roman", eastAsia: "SimHei" }, size: 32, bold: true, color: c(P.primary) },
        paragraph: { spacing: { before: 360, after: 160, line: 312 } },
      },
      heading2: {
        run: { font: { ascii: "Times New Roman", eastAsia: "SimHei" }, size: 28, bold: true, color: c(P.primary) },
        paragraph: { spacing: { before: 280, after: 120, line: 312 } },
      },
      heading3: {
        run: { font: { ascii: "Times New Roman", eastAsia: "SimHei" }, size: 24, bold: true, color: c(P.primary) },
        paragraph: { spacing: { before: 200, after: 100, line: 312 } },
      },
    },
  },
  sections: [
    {
      properties: {
        page: {
          size: { width: 11906, height: 16838 },
          margin: { top: 1440, bottom: 1440, left: 1701, right: 1417 },
        },
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [new TextRun({ children: [PageNumber.CURRENT], size: 18, color: "888888" })],
            }),
          ],
        }),
      },
      children: [
        // ════════════════════════════════════════════════════════════
        // Title Page
        // ════════════════════════════════════════════════════════════
        new Paragraph({ spacing: { before: 3000 }, children: [] }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 200 },
          children: [
            new TextRun({
              text: "\u724C\u673A\u7C7B\u578B\u6E38\u620F\u70ED\u66F4\u65B0",
              size: 52,
              bold: true,
              font: { ascii: "Times New Roman", eastAsia: "SimHei" },
              color: c(P.primary),
            }),
          ],
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 600 },
          children: [
            new TextRun({
              text: "\u670D\u52A1\u7AEF\u9A8C\u8BC1\u6E05\u5355",
              size: 44,
              bold: true,
              font: { ascii: "Times New Roman", eastAsia: "SimHei" },
              color: c(P.primary),
            }),
          ],
        }),
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [
          new TextRun({ text: "\u6587\u6863\u7248\u672C\uFF1Av1.0", size: 22, color: c(P.secondary), font: { ascii: "Times New Roman", eastAsia: "SimSun" } }),
        ] }),
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [
          new TextRun({ text: "\u53D1\u5E03\u65E5\u671F\uFF1A2026\u5E748\u6708", size: 22, color: c(P.secondary), font: { ascii: "Times New Roman", eastAsia: "SimSun" } }),
        ] }),
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [
          new TextRun({ text: "\u9002\u7528\u8303\u56F4\uFF1A\u670D\u52A1\u7AEF\u5F00\u53D1\u56E2\u961F / \u6D4B\u8BD5\u56E2\u961F", size: 22, color: c(P.secondary), font: { ascii: "Times New Roman", eastAsia: "SimSun" } }),
        ] }),

        new Paragraph({ children: [new PageBreak()] }),

        // ════════════════════════════════════════════════════════════
        // 1. Background
        // ════════════════════════════════════════════════════════════
        heading1("1. \u80CC\u666F\u8BF4\u660E"),
        body("\u724C\u673A\u7C7B\u578B\u6E38\u620F\uFF08EGameType.Card = 1\uFF09\u7684\u53C2\u6570\u914D\u7F6E\u5B58\u50A8\u5728\u591A\u5F20\u8868\u4E2D\uFF1Aroomtableconfig\u3001roomtableconfig_card\u3001paracard\u3001cardpayoutprofile\u3001pararoom\u3002\u540E\u53F0\u4FDD\u5B58\u540E\uFF0C\u901A\u8FC7 Windows Named Pipes \u5411\u4E2D\u5FC3\u670D\u53D1\u9001\u70ED\u66F4\u65B0\u6307\u4EE4\uFF0C\u89E6\u53D1\u670D\u52A1\u7AEF\u91CD\u65B0\u52A0\u8F7D\u53C2\u6570\u3002"),
        body("\u672C\u6587\u6863\u5217\u51FA\u540E\u53F0\u53D1\u9001\u7684\u6240\u6709\u70ED\u66F4\u65B0\u6307\u4EE4\u53CA\u5176\u534F\u8BAE\u683C\u5F0F\uFF0C\u4F9B\u670D\u52A1\u7AEF\u56E2\u961F\u9010\u6761\u9A8C\u8BC1\u662F\u5426\u5DF2\u5B8C\u6574\u5B9E\u73B0\u70ED\u66F4\u65B0\u3002"),

        // ════════════════════════════════════════════════════════════
        // 2. Protocol Overview
        // ════════════════════════════════════════════════════════════
        heading1("2. \u724C\u673A\u70ED\u66F4\u65B0\u534F\u8BAE\u603B\u89C8"),
        body("\u724C\u673A\u6E38\u620F\u5171\u4F7F\u7528 3 \u79CD\u70ED\u66F4\u65B0\u6307\u4EE4\uFF0C\u5747\u901A\u8FC7\u540E\u53F0\u4E0E\u4E2D\u5FC3\u670D\u7684 Named Pipe \u8FDE\u63A5\u53D1\u9001\uFF1A"),
        emptyLine(),

        makeTable(
          ["\u6307\u4EE4", "\u540D\u79F0", "\u534F\u8BAE\u7C7B\u578B", "\u4F5C\u7528", "\u53D1\u9001\u65F6\u673A"],
          [
            ["RP", "Room Reload", "\u6587\u672C\uFF08\u7BA1\u9053\u5B57\u7B26\u4E32\uFF09", "\u5168\u91CF\u91CD\u65B0\u52A0\u8F7D\u8BE5\u6E38\u620F\u7684\u6240\u6709\u53C2\u6570\uFF08\u4ECE\u6570\u636E\u5E93\u8BFB\u53D6\uFF09", "\u6BCF\u6B21\u4FDD\u5B58\u684C\u53F0\u914D\u7F6E\u540E\u5FC5\u53D1"],
            ["PA", "Desk Parameters", "\u6587\u672C\uFF08\u7BA1\u9053\u5B57\u7B26\u4E32\uFF09", "\u5B9E\u65F6\u66F4\u65B0\u5355\u684C\u96BE\u5EA6\u53C2\u6570\uFF08DIF + HYPE_TYPE\uFF09", "RP \u6210\u529F\u540E\u53D1\u9001\uFF1B\u6216\u5355\u72EC\u4FDD\u5B58\u96BE\u5EA6\u65F6\u53D1\u9001"],
            ["TC", "Table Config", "\u4E8C\u8FDB\u5236\uFF08\u7BA1\u9053\u5B57\u8282\u6D41\uFF09", "\u70ED\u66F4\u65B0\u684C\u53F0\u57FA\u7840\u914D\u7F6E\uFF08\u684C\u540D\u3001\u542F\u7528\u3001\u8D85\u65F6\u3001\u5EA7\u4F4D\u7B49\uFF09", "RP \u6210\u529F\u540E\u53D1\u9001"],
          ],
          [10, 18, 18, 36, 18]
        ),

        // ════════════════════════════════════════════════════════════
        // 3. RP Command
        // ════════════════════════════════════════════════════════════
        heading1("3. RP \u6307\u4EE4\u9A8C\u8BC1\uFF08\u623F\u95F4\u91CD\u8F7D\uFF09"),
        heading2("3.1 \u534F\u8BAE\u683C\u5F0F"),
        bodyNoIndent("\u53D1\u9001\uFF1A"),
        codeBlock("RP{gameId}"),
        bodyNoIndent("\u793A\u4F8B\uFF1A"),
        codeBlock("RP1    // \u91CD\u8F7D gameId=1 \u7684\u724C\u673A\u6E38\u620F"),
        bodyNoIndent("\u5B57\u7B26\u4E32\u4EE5 '\\0' \u7ED3\u5C3E\u3002\u670D\u52A1\u7AEF\u5E94\u56DE\u590D MsgDefine.config \u4E2D\u5B9A\u4E49\u7684\u72B6\u6001\u7801\uFF1A"),
        codeBlock("RPOK   // \u6210\u529F\uFF0C\u5BF9\u5E94\u503C=\u201C\u623F\u95F4\u8BBE\u5B9A\u6210\u529F\u3002\u201D"),
        codeBlock("RP\u5176\u4ED6  // \u5931\u8D25\uFF0C\u8FD4\u56DE\u5BF9\u5E94\u9519\u8BEF\u7801"),

        heading2("3.2 \u670D\u52A1\u7AEF\u5904\u7406\u8981\u6C42"),
        boldBody("RP \u6307\u4EE4\u662F\u724C\u673A\u70ED\u66F4\u65B0\u7684\u6838\u5FC3\u3002\u670D\u52A1\u7AEF\u6536\u5230 RP \u540E\u5FC5\u987B\uFF1A"),
        checkItem("\u4ECE\u6570\u636E\u5E93\u91CD\u65B0\u8BFB\u53D6 paragame.ROOM_MAX\uFF08\u724C\u673A\u6052\u4E3A 1\uFF09"),
        checkItem("\u6309 ROOM_MAX \u5FAA\u73AF\u8BFB\u53D6 pararoom base \u884C\uFF08ID = gameId * 1000\uFF09\uFF0C\u83B7\u53D6 NUM = \u684C\u53F0\u6570"),
        checkItem("\u6309 NUM \u5FAA\u73AF\u8BFB\u53D6 paracard[0..N-1]\uFF08ID = gameId * 1000 + i\uFF09"),
        checkItem("\u8BFB\u53D6 roomtableconfig \u4E2D\u8BE5\u6E38\u620F\u7684\u6240\u6709\u684C\u53F0\u914D\u7F6E\uFF08\u684C\u540D\u3001\u542F\u7528\u3001\u9650\u7EA2\u3001\u5EA7\u4F4D\u7B49\uFF09"),
        checkItem("\u8BFB\u53D6 roomtableconfig_card \u4E2D\u8BE5\u6E38\u620F\u7684\u724C\u673A\u4E13\u5C5E\u53C2\u6570\uFF08ExCoin\u3001ScoreSwitch\u3001GameMo\u3001MaxBetUnits\uFF09"),
        checkItem("\u8BFB\u53D6 cardpayoutprofile \u4E2D\u8BE5\u6E38\u620F\u6BCF\u5F20\u684C\u7684\u724C\u578B\u6982\u7387\u548C\u542F\u7528\u72B6\u6001\uFF08HandType 0~12 + \u9B3C\u724C 201/202/203\uFF09"),
        checkItem("\u5C06\u6240\u6709\u53C2\u6570\u91CD\u65B0\u4E0B\u53D1\u7ED9\u5B50\u6E38\u620F\u670D"),
        checkItem("\u56DE\u590D RPOK\uFF08\u6210\u529F\uFF09\u6216\u9519\u8BEF\u7801\uFF08\u5931\u8D25\uFF09"),

        note("\u5173\u952E\uFF1A\u540E\u53F0\u5728\u53D1 RP \u4E4B\u524D\u5DF2\u6267\u884C SyncRoomMaxToRoomCount\uFF0C\u786E\u4FDD ROOM_MAX \u4E3A\u5F53\u524D\u684C\u53F0\u6570\u3002\u670D\u52A1\u7AEF\u4E0D\u5E94\u4F9D\u8D56\u7F13\u5B58\u4E2D\u7684 ROOM_MAX\u3002"),

        // ════════════════════════════════════════════════════════════
        // 4. PA Command
        // ════════════════════════════════════════════════════════════
        heading1("4. PA \u6307\u4EE4\u9A8C\u8BC1\uFF08\u673A\u53F0\u96BE\u5EA6\uFF09"),
        heading2("4.1 \u534F\u8BAE\u683C\u5F0F"),
        bodyNoIndent("\u53D1\u9001\uFF1A"),
        codeBlock("PA{gameId:2\u4F4D}{tableIndex:3\u4F4D}{DIF:16\u4F4D}{HYPE_TYPE}"),
        bodyNoIndent("\u793A\u4F8B\uFF1A"),
        codeBlock("PA0100012345566778800   // gameId=1, tableIndex=0, DIF=123455667788, HYPE_TYPE=0"),
        bodyNoIndent("\u5404\u5B57\u6BB5\u8BF4\u660E\uFF1A"),
        makeTable(
          ["\u5B57\u6BB5", "\u957F\u5EA6", "\u8BF4\u660E"],
          [
            ["gameId", "2 \u4F4D\uFF0C\u4E0D\u8DB3\u524D\u7F00\u8865\u96F6", "\u6E38\u620F ID\uFF0C\u5982 01\u300112"],
            ["tableIndex", "3 \u4F4D\uFF0C\u4E0D\u8DB3\u524D\u7F00\u8865\u96F6", "\u684C\u53F0\u7D22\u5F15\uFF0C\u4ECE 0 \u5F00\u59CB\uFF0C\u5982 000\u3001001"],
            ["DIF", "\u56FA\u5B9A 16 \u4F4D\u6570\u5B57", "\u724C\u673A\u96BE\u5EA6\u5B57\u7B26\u4E32\uFF0C\u5982 1234556677880000"],
            ["HYPE_TYPE", "\u53D8\u957F\uFF0C\u6574\u6570", "\u7092\u573A\u7C7B\u578B\uFF0C\u5982 0\u30011\u30012"],
          ],
          [20, 25, 55]
        ),

        heading2("4.2 \u670D\u52A1\u7AEF\u5904\u7406\u8981\u6C42"),
        boldBody("PA \u662F\u5B9E\u65F6\u70ED\u66F4\u65B0\u6307\u4EE4\uFF0C\u4E0D\u7B49\u5F85 RP \u5168\u91CF\u91CD\u8F7D\u3002\u670D\u52A1\u7AEF\u5FC5\u987B\uFF1A"),
        checkItem("\u89E3\u6790\u5B57\u7B26\u4E32\uFF0C\u62BD\u53D6 gameId\u3001tableIndex\u3001DIF\u3001HYPE_TYPE"),
        checkItem("\u901A\u8FC7 SetTablePara \u5C06\u96BE\u5EA6\u53C2\u6570\u4E0B\u53D1\u7ED9\u5BF9\u5E94\u5B50\u6E38\u620F\u670D"),
        checkItem("\u5B50\u6E38\u620F\u670D\u8C03\u7528 AlgDifSet \u5373\u65F6\u751F\u6548\uFF08\u4E0D\u7B49\u5F85\u91CD\u542F\uFF09"),
        checkItem("\u56DE\u590D PAOK\uFF08\u6210\u529F\uFF09\u6216 PAER\uFF08\u5931\u8D25\uFF09"),
        checkItem("\u5BF9\u4E8E\u724C\u673A\uFF0CSetTablePara \u5E94\u540C\u6B65\u5199\u56DE paracard \u8868\uFF08\u786E\u4FDD RP \u91CD\u8F7D\u65F6\u4E00\u81F4\uFF09"),

        note("DIF \u5B57\u6BB5\u5FC5\u987B\u6070\u597D 16 \u4F4D\u6570\u5B57\uFF0C\u540E\u53F0\u5DF2\u6821\u9A8C\uFF0C\u670D\u52A1\u7AEF\u4E0D\u5FC5\u518D\u6821\u9A8C\u4F46\u5E94\u80FD\u5BB9\u9519\u5904\u7406\u3002"),

        // ════════════════════════════════════════════════════════════
        // 5. TC Command
        // ════════════════════════════════════════════════════════════
        heading1("5. TC \u6307\u4EE4\u9A8C\u8BC1\uFF08\u684C\u53F0\u914D\u7F6E\uFF09"),
        heading2("5.1 \u534F\u8BAE\u683C\u5F0F"),
        body("\u4E8C\u8FDB\u5236\u534F\u8BAE\uFF0C\u4E0D\u7ECF\u8FC7 MsgDefine.config \u6A21\u677F\uFF0C\u7531 SConnect.SendTcCommand \u76F4\u63A5\u7EC4\u5305\u53D1\u9001\u3002\u62A5\u6587\u5E03\u5C40\uFF1A"),
        emptyLine(),

        makeTable(
          ["\u504F\u79FB", "\u5B57\u6BB5", "\u7C7B\u578B", "\u8BF4\u660E"],
          [
            ["0", "\u547D\u4EE4\u5934", "char[2]", "\u56FA\u5B9A\u4E3A \"TC\""],
            ["2", "gameID", "U16 BE", "\u6E38\u620F ID\uFF0C\u5927\u7AEF\u5E8F"],
            ["4", "roomIndex", "U16 BE", "\u6052\u4E3A 0\uFF08\u5E9F\u5F03\u591A\u623F\u95F4\u6A21\u578B\uFF09"],
            ["6", "tableIndex", "U16 BE", "\u684C\u53F0\u7D22\u5F15\uFF08ID % 1000\uFF09"],
            ["8", "\u684C\u540D\u957F\u5EA6", "7-bit varint", "UTF-8 \u5B57\u8282\u6570\uFF0C\u221651"],
            ["8+", "\u684C\u540D", "UTF-8", "\u684C\u53F0\u540D\u79F0\u5B57\u7B26\u4E32"],
            ["8+len", "enabled", "U8", "0=\u7981\u7528\uFF0C1=\u542F\u7528"],
            ["9+len", "idleFireTimeoutSec", "U32 BE", "\u7A7A\u95F2\u8D85\u65F6\u79D2\u6570"],
            ["13+len", "idleFireKickEnabled", "U8", "0=\u7981\u7528\uFF0C1=\u542F\u7528"],
            ["14+len", "maxSeats", "U16 BE", "\u6700\u5927\u5EA7\u4F4D\u6570\uFF08\u22648\uFF09"],
          ],
          [10, 22, 18, 50]
        ),

        body("\u724C\u673A\u4E0D\u53D1\u9001 TcTableExt \u548C TcBetExt \u6269\u5C55\u5B57\u6BB5\u3002"),

        heading2("5.2 \u670D\u52A1\u7AEF\u5904\u7406\u8981\u6C42"),
        boldBody("TC \u662F\u4E8C\u8FDB\u5236\u6307\u4EE4\uFF0C\u4E0E RP/PA \u7684\u6587\u672C\u534F\u8BAE\u4E0D\u540C\u3002\u670D\u52A1\u7AEF\u5FC5\u987B\uFF1A"),
        checkItem("\u8BC6\u522B\u547D\u4EE4\u5934 \"TC\"\uFF0C\u786E\u8BA4\u4E0D\u662F RP/PA \u6587\u672C\u6307\u4EE4"),
        checkItem("\u6309\u5927\u7AEF\u5E8F\uFF08Big-Endian\uFF09\u89E3\u6790 U16/U32 \u5B57\u6BB5"),
        checkItem("\u7528 7-bit varint \u89E3\u6790\u684C\u540D\u957F\u5EA6\u524D\u7F00\uFF0C\u8BFB\u53D6 UTF-8 \u684C\u540D"),
        checkItem("\u5C06\u684C\u540D\u3001\u542F\u7528\u72B6\u6001\u3001\u8D85\u65F6\u3001\u5EA7\u4F4D\u7B49\u5199\u5165 roomtableconfig \u8868"),
        checkItem("\u5C06\u66F4\u65B0\u540E\u7684\u684C\u53F0\u914D\u7F6E\u5168\u91CF\u91CD\u63A8\u7ED9\u5B50\u6E38\u620F\u670D\uFF08\u901A\u8FC7 ApplyCardTableSnap \u7B49\uFF09"),
        checkItem("\u56DE\u590D TCOK\uFF08\u6210\u529F\uFF09\u6216 TCER\uFF08\u5931\u8D25\uFF09"),

        note("TC \u63A5\u6536\u65F6\u4E0D\u80FD\u7528\u5B57\u7B26\u4E32\u89E3\u6790\uFF0C\u5FC5\u987B\u7528\u4E8C\u8FDB\u5236\u6D41\u8BFB\u53D6\u3002\u540E\u53F0\u5DF2\u5904\u7406\u5927\u7AEF\u5E8F\u548C varint\uFF0C\u670D\u52A1\u7AEF\u9700\u4E00\u81F4\u3002"),

        // ════════════════════════════════════════════════════════════
        // 6. Verification Checklist
        // ════════════════════════════════════════════════════════════
        heading1("6. \u670D\u52A1\u7AEF\u5904\u7406\u6D41\u7A0B\u9A8C\u8BC1\u6E05\u5355"),
        body("\u4EE5\u4E0B\u662F\u670D\u52A1\u7AEF\u5FC5\u987B\u5B9E\u73B0\u7684\u5168\u90E8\u5904\u7406\u903B\u8F91\uFF0C\u8BF7\u9010\u6761\u6253\u52FE\u786E\u8BA4\uFF1A"),
        emptyLine(),

        boldBody("A. RP \u6307\u4EE4\u5904\u7406"),
        checkItem("A1. \u63A5\u6536 \"RP{gameId}\" \u6587\u672C\u6307\u4EE4"),
        checkItem("A2. \u4ECE\u6570\u636E\u5E93\u8BFB\u53D6 paragame.ROOM_MAX\uFF08\u724C\u673A\u6052\u4E3A 1\uFF09"),
        checkItem("A3. \u6309 ROOM_MAX \u5FAA\u73AF\u8BFB\u53D6 pararoom base \u884C\uFF08ID = gameId * 1000\uFF09"),
        checkItem("A4. \u83B7\u53D6 base \u884C\u7684 NUM = \u5F53\u524D\u684C\u53F0\u603B\u6570"),
        checkItem("A5. \u6309 NUM \u5FAA\u73AF\u8BFB\u53D6 paracard\uFF08ID = gameId * 1000 + i\uFF09\uFF0C\u83B7\u53D6 DIF \u548C HYPE_TYPE"),
        checkItem("A6. \u8BFB\u53D6 roomtableconfig \u4E2D\u8BE5\u6E38\u620F\u7684\u6240\u6709\u884C\uFF0C\u83B7\u53D6\u684C\u53F0\u57FA\u7840\u914D\u7F6E"),
        checkItem("A7. \u8BFB\u53D6 roomtableconfig_card \u4E2D\u8BE5\u6E38\u620F\u7684\u6240\u6709\u884C\uFF0C\u83B7\u53D6\u724C\u673A\u4E13\u5C5E\u53C2\u6570"),
        checkItem("A8. \u8BFB\u53D6 cardpayoutprofile \u4E2D\u8BE5\u6E38\u620F\u6BCF\u5F20\u684C\u7684\u724C\u578B\u6982\u7387\uFF08HandType 0~12 + 201/202/203\uFF09"),
        checkItem("A9. \u5C06\u4EE5\u4E0A\u6240\u6709\u53C2\u6570\u6574\u5408\u540E\u4E0B\u53D1\u7ED9\u5BF9\u5E94\u5B50\u6E38\u620F\u670D"),
        checkItem("A10. \u8FD4\u56DE RPOK\uFF08\u6210\u529F\uFF09\u6216\u9519\u8BEF\u7801\uFF08\u5931\u8D25\uFF09"),

        emptyLine(),
        boldBody("B. PA \u6307\u4EE4\u5904\u7406"),
        checkItem("B1. \u63A5\u6536 \"PA{2\u4F4DgameId}{3\u4F4DtableIndex}{16\u4F4DDIF}{HYPE_TYPE}\" \u6587\u672C\u6307\u4EE4"),
        checkItem("B2. \u62BD\u53D6 gameId\u3001tableIndex\u3001DIF\u3001HYPE_TYPE"),
        checkItem("B3. \u901A\u8FC7 SetTablePara \u4E0B\u53D1 COM_TABLE_SET \u7ED9\u5B50\u6E38\u620F\u670D"),
        checkItem("B4. \u5B50\u6E38\u620F\u670D\u8C03\u7528 AlgDifSet \u5373\u65F6\u751F\u6548"),
        checkItem("B5. \u5C06\u66F4\u65B0\u540E\u7684 DIF/HYPE_TYPE \u5199\u56DE paracard \u8868\uFF08\u4FDD\u6301\u4E0E\u6570\u636E\u5E93\u4E00\u81F4\uFF09"),
        checkItem("B6. \u8FD4\u56DE PAOK\uFF08\u6210\u529F\uFF09\u6216 PAER\uFF08\u5931\u8D25\uFF09"),

        emptyLine(),
        boldBody("C. TC \u6307\u4EE4\u5904\u7406"),
        checkItem("C1. \u63A5\u6536\u4E8C\u8FDB\u5236\u62A5\u6587\uFF0C\u8BC6\u522B\u547D\u4EE4\u5934 \"TC\""),
        checkItem("C2. \u6309\u5927\u7AEF\u5E8F\u89E3\u6790 U16: gameID\u3001roomIndex\u3001tableIndex"),
        checkItem("C3. \u7528 7-bit varint \u89E3\u6790\u684C\u540D\u957F\u5EA6\u524D\u7F00\uFF0C\u8BFB\u53D6 UTF-8 \u684C\u540D\uFF08\u221651\u5B57\u8282\uFF09"),
        checkItem("C4. \u89E3\u6790 U8 enabled\u3001U32 BE idleFireTimeoutSec\u3001U8 idleFireKickEnabled\u3001U16 BE maxSeats"),
        checkItem("C5. \u5C06\u4EE5\u4E0A\u5B57\u6BB5\u5199\u5165 roomtableconfig \u8868"),
        checkItem("C6. \u5C06\u66F4\u65B0\u540E\u7684\u684C\u53F0\u914D\u7F6E\u5168\u91CF\u91CD\u63A8\u7ED9\u5B50\u6E38\u620F\u670D"),
        checkItem("C7. \u8FD4\u56DE TCOK\uFF08\u6210\u529F\uFF09\u6216 TCER\uFF08\u5931\u8D25\uFF09"),

        emptyLine(),
        boldBody("D. \u6570\u636E\u5E93\u5B8C\u6574\u6027"),

        // ─── Database table reference ───
        emptyLine(),
        makeTable(
          ["\u8868\u540D", "\u724C\u673A\u5B57\u6BB5", "\u70ED\u66F4\u65B9\u5F0F"],
          [
            ["paragame", "ROOM_MAX = 1", "RP \u524D\u540E\u53F0\u5199\u5165\uFF0C\u670D\u52A1\u7AEF\u4EC5\u8BFB"],
            ["pararoom (base)", "ID=gameId*1000, NUM=++\u684C\u6570, BET_MIN/MAX, EX_COIN, COIN_SC, COIN_NEED, scoreSwitch, Game_Mo, MinBetUnits, MaxBetUnits, TableName, MaxSeats, IdleFireTimeoutSec, IdleFireKickEnabled, Enabled", "RP \u91CD\u8F7D"],
            ["paracard", "ID=gameId*1000+i, DIF(16\u4F4D), HYPE_TYPE", "PA \u5B9E\u65F6 + RP \u91CD\u8F7D"],
            ["roomtableconfig", "TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats, MinBetUnits", "TC \u70ED\u66F4 + RP \u91CD\u8F7D"],
            ["roomtableconfig_card", "TableIndex, ExCoin, ScoreSwitch, GameMo, MaxBetUnits", "RP \u91CD\u8F7D"],
            ["cardpayoutprofile", "TableId, HandType(0~12, 201/202/203), ProbabilityBasis, Enabled", "RP \u91CD\u8F7D"],
          ],
          [18, 55, 27]
        ),

        emptyLine(),
        checkItem("D1. \u724C\u673A pararoom base \u884C ID = gameId * 1000\uFF08\u4E0D\u662F gameId * 1000 + i\uFF09"),
        checkItem("D2. paracard ID = gameId * 1000 + i\uFF08\u4ECE 0 \u5F00\u59CB\u8FDE\u7EED\u7F16\u53F7\uFF09"),
        checkItem("D3. roomtableconfig.TableIndex \u4E0E paracard \u7D22\u5F15\u4FDD\u6301\u4E00\u81F4\uFF08\u5220\u9664\u540E\u538B\u7F29\u540E\u90FD\u4ECE 0 \u5F00\u59CB\u8FDE\u7EED\uFF09"),
        checkItem("D4. cardpayoutprofile \u4E2D HandType 0~12 \u5BF9\u5E94 te_CardsType \u679A\u4E3E\uFF0C201/202/203 \u4E3A\u9B3C\u724C\u54E8\u5175\u884C"),
        checkItem("D5. \u724C\u578B\u8D54\u7387\u4E3A\u4E07\u5206\u6BD4\uFF080~10000\uFF09\uFF0C\u5408\u8BA1\u4E0D\u8D85\u8FC7 10000"),
        checkItem("D6. \u9B3C\u724C\u4E09\u6BB5\u6982\u7387\u5408\u8BA1\u4E0D\u8D85\u8FC7 10000"),

        // ════════════════════════════════════════════════════════════
        // 7. Common Pitfalls
        // ════════════════════════════════════════════════════════════
        heading1("7. \u5E38\u89C1\u95EE\u9898\u4E0E\u6CE8\u610F\u4E8B\u9879"),
        emptyLine(),

        boldBody("7.1 ROOM_MAX \u672A\u540C\u6B65"),
        body("\u5982\u679C paragame.ROOM_MAX \u4E0D\u7B49\u4E8E\u5F53\u524D\u623F\u95F4\u6570\uFF08\u724C\u673A\u6052\u4E3A 1\uFF09\uFF0C\u670D\u52A1\u7AEF\u53EA\u4F1A\u52A0\u8F7D ROOM_MAX \u4E2A\u623F\u95F4\u3002\u65B0\u589E\u7684\u684C\u53F0\u5982\u679C TableIndex \u8D85\u51FA\u8303\u56F4\uFF0C\u4F1A\u88AB\u5FFD\u7565\u3002\u540E\u53F0\u5728\u53D1 RP \u524D\u5DF2\u8C03\u7528 SyncRoomMaxToRoomCount\uFF0C\u4F46\u670D\u52A1\u7AEF\u5E94\u4E0D\u4F9D\u8D56\u7F13\u5B58\u7684 ROOM_MAX\u3002"),

        boldBody("7.2 \u5220\u9664\u684C\u53F0\u540E\u7D22\u5F15\u538B\u7F29"),
        body("\u5220\u9664\u684C\u53F0\u540E\uFF0Croomtableconfig.TableIndex \u548C paracard.ID \u5FC5\u987B\u91CD\u65B0\u7F16\u53F7\u4E3A 0..k-1\u3002\u5982\u679C\u4E0D\u538B\u7F29\uFF0C\u670D\u52A1\u7AEF\u7684 GetCardPara \u6309 ID=gameId*1000+i \u5FAA\u73AF\u8BFB\u53D6\u65F6\u4F1A\u8BFB\u5230\u9519\u4F4D\u6570\u636E\u3002\u540E\u53F0\u5DF2\u5B9E\u73B0 CompactCardParaIds\uFF0C\u670D\u52A1\u7AEF\u4E0D\u9700\u8981\u5904\u7406\u6B64\u903B\u8F91\uFF0C\u4F46\u9700\u786E\u4FDD\u8BFB\u53D6\u65F6\u4E0D\u4F9D\u8D56 ID \u8FDE\u7EED\u6027\u3002"),

        boldBody("7.3 \u724C\u578B\u8D54\u7387\u500D\u6570\u4E0D\u5728\u540E\u53F0\u7BA1\u7406"),
        body("\u724C\u578B\u8D54\u7387\u500D\u6570\u4EE5\u5BA2\u6237\u7AEF Blueeboard.cs \u4E3A\u552F\u4E00\u6743\u5A01\uFF0C\u540E\u53F0\u65E2\u4E0D\u63A5\u6536\u4E5F\u4E0D\u4FDD\u5B58\u3002\u670D\u52A1\u7AEF\u4E0D\u5E94\u4ECE cardpayoutprofile.PayoutMultiplier \u8BFB\u53D6\u500D\u7387\uFF0C\u8BE5\u5B57\u6BB5\u5728\u6570\u636E\u5E93\u4E2D\u4F7F\u7528\u9ED8\u8BA4\u503C 0\u3002\u724C\u578B\u8D54\u7387\u500D\u6570\u65E0\u6CD5\u901A\u8FC7\u540E\u53F0\u70ED\u66F4\u65B0\u3002"),

        boldBody("7.4 PA \u5931\u8D25\u4E0D\u56DE\u6EDA"),
        body("\u5F53\u524D\u4EE3\u7801\u7B56\u7565\uFF1ARP \u6210\u529F\u540E\u6570\u636E\u5E93\u5DF2\u63D0\u4EA4\uFF0CPA \u5931\u8D25\u4EC5\u8BB0\u65E5\u5FD7\u4E0D\u56DE\u6EDA\u3002\u8FD9\u610F\u5473\u7740\u670D\u52A1\u7AEF\u5185\u5B58\u4E2D\u7684\u96BE\u5EA6\u53C2\u6570\u53EF\u80FD\u6682\u65F6\u4E0E\u6570\u636E\u5E93\u4E0D\u4E00\u81F4\uFF0C\u7B49\u5F85\u4E0B\u6B21 RP \u6216\u91CD\u542F\u540E\u81EA\u52A8\u6062\u590D\u3002"),

        boldBody("7.5 \u724C\u578B\u6982\u7387\u5408\u8BA1\u6821\u9A8C"),
        body("\u540E\u53F0\u4FDD\u5B58\u65F6\u4F1A\u6821\u9A8C\uFF1A\u4E2D\u5956\u724C\u578B\u6982\u7387\u5408\u8BA1 \u2264 10000\uFF0C\u9B3C\u724C\u4E09\u6BB5\u6982\u7387\u5408\u8BA1 \u2264 10000\u3002\u670D\u52A1\u7AEF\u4E0D\u9700\u8981\u91CD\u590D\u6821\u9A8C\uFF0C\u4F46\u5728 cardpayoutprofile \u4E2D\u8BFB\u53D6\u65F6\u5E94\u6CE8\u610F Enabled \u4E3A 0 \u7684\u884C\u5E94\u88AB\u5FFD\u7565\u3002"),

        boldBody("7.6 \u6240\u6709\u53C2\u6570\u5747\u53EF\u70ED\u66F4\u65B0\uFF08\u9664\u500D\u7387\u5916\uFF09"),
        body("\u9664\u4E86\u724C\u578B\u8D54\u7387\u500D\u6570\uFF08\u5BA2\u6237\u7AEF\u786C\u7F16\u7801\uFF09\u4E4B\u5916\uFF0C\u724C\u673A\u7684\u6240\u6709\u53C2\u6570\u90FD\u652F\u6301\u70ED\u66F4\u65B0\uFF1A"),
        checkItem("ROOM_MAX / NUM / BET_MIN / BET_MAX / EX_COIN / COIN_SC / COIN_NEED / scoreSwitch / Game_Mo / MinBetUnits / MaxBetUnits"),
        checkItem("\u684C\u540D / \u542F\u7528 / \u8D85\u65F6 / \u5EA7\u4F4D"),
        checkItem("DIF (16\u4F4D\u96BE\u5EA6\u4E32) / HYPE_TYPE (\u7092\u573A\u7C7B\u578B)"),
        checkItem("\u724C\u578B\u6982\u7387 (HandType 0~12 \u4E07\u5206\u6BD4) / \u724C\u578B\u542F\u7528 (Enabled)"),
        checkItem("\u9B3C\u724C\u6982\u7387 (HandType 201/202/203 \u4E07\u5206\u6BD4) / \u9B3C\u724C\u542F\u7528"),

        // ════════════════════════════════════════════════════════════
        // 8. Testing Scenarios
        // ════════════════════════════════════════════════════════════
        heading1("8. \u6D4B\u8BD5\u573A\u666F\u63D0\u793A"),
        body("\u4EE5\u4E0B\u573A\u666F\u53EF\u7528\u4E8E\u9A8C\u8BC1\u724C\u673A\u70ED\u66F4\u65B0\u662F\u5426\u5B8C\u6574\u5B9E\u73B0\uFF1A"),
        emptyLine(),

        makeTable(
          ["\u573A\u666F", "\u64CD\u4F5C", "\u9884\u671F\u7ED3\u679C", "\u9A8C\u8BC1\u65B9\u6CD5"],
          [
            ["\u4FEE\u6539\u724C\u578B\u6982\u7387", "\u540E\u53F0\u4FEE\u6539\u67D0\u724C\u578B\u6982\u7387\u5E76\u4FDD\u5B58", "\u5B50\u6E38\u620F\u670D\u5373\u65F6\u751F\u6548", "\u67E5\u770B\u5B50\u6E38\u620F\u670D\u724C\u578B\u6982\u7387\u662F\u5426\u66F4\u65B0"],
            ["\u4FEE\u6539\u96BE\u5EA6\u53C2\u6570", "\u540E\u53F0\u4FEE\u6539 DIF \u5E76\u4FDD\u5B58", "\u5B50\u6E38\u620F\u670D\u5373\u65F6\u751F\u6548", "\u67E5\u770B AlgDifSet \u662F\u5426\u88AB\u89E6\u53D1"],
            ["\u4FEE\u6539\u684C\u540D", "\u540E\u53F0\u4FEE\u6539\u684C\u53F0\u540D\u79F0\u5E76\u4FDD\u5B58", "\u684C\u540D\u5373\u65F6\u66F4\u65B0", "\u67E5\u770B\u5B50\u6E38\u620F\u670D\u684C\u540D\u662F\u5426\u53D8\u5316"],
            ["\u65B0\u589E\u684C\u53F0", "\u540E\u53F0\u65B0\u589E\u4E00\u5F20\u724C\u673A\u684C\u5E76\u4FDD\u5B58", "\u65B0\u684C\u5373\u65F6\u53EF\u89C1", "\u5B50\u6E38\u620F\u670D\u80FD\u8FDE\u63A5\u65B0\u684C"],
            ["\u5220\u9664\u684C\u53F0", "\u540E\u53F0\u5220\u9664\u4E00\u5F20\u684C\u5E76\u4FDD\u5B58", "\u884C\u4E2D\u684C\u53F0\u5373\u65F6\u4E0D\u53EF\u89C1", "\u5B50\u6E38\u620F\u670D\u4E0D\u518D\u663E\u793A\u8BE5\u684C"],
            ["\u4FEE\u6539\u52A0\u82AC\u5E45\u5EA6", "\u540E\u53F0\u4FEE\u6539 scoreSwitch \u5E76\u4FDD\u5B58", "\u5B50\u6E38\u620F\u670D\u5373\u65F6\u751F\u6548", "\u67E5\u770B\u5B50\u6E38\u620F\u670D scoreSwitch \u662F\u5426\u66F4\u65B0"],
            ["\u70ED\u66F4\u5931\u8D25\u6062\u590D", "\u624B\u52A8\u91CD\u542F\u5B50\u6E38\u620F\u670D", "\u670D\u52A1\u7AEF\u4ECE\u6570\u636E\u5E93\u52A0\u8F7D\u6700\u65B0\u53C2\u6570", "\u786E\u8BA4\u91CD\u542F\u540E\u53C2\u6570\u4E0E\u540E\u53F0\u4E00\u81F4"],
          ],
          [16, 28, 28, 28]
        ),
      ],
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync("C:\\Users\\cdys\\Downloads\\MTH-Backend\\\u724C\u673A\u70ED\u66F4\u65B0\u670D\u52A1\u7AEF\u9A8C\u8BC1\u6E05\u5355.docx", buf);
  console.log("OK: \u724C\u673A\u70ED\u66F4\u65B0\u670D\u52A1\u7AEF\u9A8C\u8BC1\u6E05\u5355.docx created");
});