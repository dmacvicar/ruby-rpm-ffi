module RPM

  module FFI

  	Tag = enum(:tag, [
      :not_found, -1,
      :headerimage, 61,
      :headersignatures, 62,
      :headerimmutable, 63,
      :headerregions, 64,
      :headeri18ntable, 100,
      :sig_base, 256,
      :sigsize, 256+1,
      :siglemd5_1, 256+2,
      :sigpgp, 256+3,
      :siglemd5_2, 256+4,
      :sigmd5, 256+5,
      :siggpg, 256+6,
      :sigpgp5, 256+7,
      :badsha1_1, 256+8,
      :badsha1_2, 256+9,
      :pubkeys, 256+10,
      :dsaheader, 256+11,
      :rsaheader, 256+12,
      :sha1header, 256+13,
      :longsigsize, 256+14,
      :longarchivesize, 256+15,
      :name, 1000,
      :version, 1001,
      :release, 1002,
      :epoch, 1003,
      :summary, 1004,
      :description, 1005,
      :buildtime, 1006,
      :buildhost, 1007,
      :installtime, 1008,
      :size, 1009,
      :distribution, 1010,
      :vendor, 1011,
      :gif, 1012,
      :xpm, 1013,
      :license, 1014,
      :packager, 1015,
      :group, 1016,
      :changelog, 1017,
      :source, 1018,
      :patch, 1019,
      :url, 1020,
      :os, 1021,
      :arch, 1022,
      :prein, 1023,
      :postin, 1024,
      :preun, 1025,
      :postun, 1026,
      :oldfilenames, 1027,
      :filesizes, 1028,
      :filestates, 1029,
      :filemodes, 1030,
      :fileuids, 1031,
      :filegids, 1032,
      :filerdevs, 1033,
      :filemtimes, 1034,
      :filedigests, 1035,
      :filelinktos, 1036,
      :fileflags, 1037,
      :root, 1038,
      :fileusername, 1039,
      :filegroupname, 1040,
      :exclude, 1041,
      :exclusive, 1042,
      :icon, 1043,
      :source, 1044,
      :fileverifyflags, 1045,
      :archivesize, 1046,
      :providename, 1047,
      :requireflags, 1048,
      :requirename, 1049,
      :requireversion, 1050,
      :nosource, 1051,
      :nopatch, 1052,
      :conflictflags, 1053,
      :conflictname, 1054,
      :conflictversion, 1055,
      :defaultprefix, 1056,
      :buildroot, 1057,
      :installprefix, 1058,
      :excludearch, 1059,
      :excludeos, 1060,
      :exclusivearch, 1061,
      :exclusiveos, 1062,
      :autoreqprov, 1063,
      :version, 1064,
      :triggerscripts, 1065,
      :triggername, 1066,
      :triggerversion, 1067,
      :triggerflags, 1068,
      :triggerindex, 1069,
      :verifyscript, 1079,
      :changelogtime, 1080,
      :changelogname, 1081,
      :changelogtext, 1082,
      :brokenmd5, 1083,
      :prereq, 1084,
      :preinprog, 1085,
      :postinprog, 1086,
      :preunprog, 1087,
      :postunprog, 1088,
      :buildarchs, 1089,
      :obsoletename, 1090,
      :verifyscriptprog, 1091,
      :triggerscriptprog, 1092,
      :docdir, 1093,
      :cookie, 1094,
      :filedevices, 1095,
      :fileinodes, 1096,
      :filelangs, 1097,
      :prefixes, 1098,
      :instprefixes, 1099,
      :triggerin, 1100,
      :triggerun, 1101,
      :triggerpostun, 1102,
      :autoreq, 1103,
      :autoprov, 1104,
      :capability, 1105,
      :sourcepackage, 1106,
      :oldorigfilenames, 1107,
      :buildprereq, 1108,
      :buildrequires, 1109,
      :buildconflicts, 1110,
      :buildmacros, 1111,
      :provideflags, 1112,
      :provideversion, 1113,
      :obsoleteflags, 1114,
      :obsoleteversion, 1115,
      :dirindexes, 1116,
      :basenames, 1117,
      :dirnames, 1118,
      :origdirindexes, 1119,
      :origbasenames, 1120,
      :origdirnames, 1121,
      :optflags, 1122,
      :disturl, 1123,
      :payloadformat, 1124,
      :payloadcompressor, 1125,
      :payloadflags, 1126,
      :installcolor, 1127,
      :installtid, 1128,
      :removetid, 1129,
      :sha1rhn, 1130,
      :rhnplatform, 1131,
      :platform, 1132,
      :patchesname, 1133,
      :patchesflags, 1134,
      :patchesversion, 1135,
      :cachectime, 1136,
      :cachepkgpath, 1137,
      :cachepkgsize, 1138,
      :cachepkgmtime, 1139,
      :filecolors, 1140,
      :fileclass, 1141,
      :classdict, 1142,
      :filedependsx, 1143,
      :filedependsn, 1144,
      :dependsdict, 1145,
      :sourcepkgid, 1146,
      :filecontexts, 1147,
      :fscontexts, 1148,
      :recontexts, 1149,
      :policies, 1150,
      :pretrans, 1151,
      :posttrans, 1152,
      :pretransprog, 1153,
      :posttransprog, 1154,
      :disttag, 1155,
      :suggestsname, 1156,
      :suggestsversion, 1157,
      :suggestsflags, 1158,
      :enhancesname, 1159,
      :enhancesversion, 1160,
      :enhancesflags, 1161,
      :priority, 1162,
      :cvsid, 1163,
      :blinkpkgid, 1164,
      :blinkhdrid, 1165,
      :blinknevra, 1166,
      :flinkpkgid, 1167,
      :flinkhdrid, 1168,
      :flinknevra, 1169,
      :packageorigin, 1170,
      :triggerprein, 1171,
      :buildsuggests, 1172,
      :buildenhances, 1173,
      :scriptstates, 1174,
      :scriptmetrics, 1175,
      :buildcpuclock, 1176,
      :filedigestalgos, 1177,
      :variants, 1178,
      :xmajor, 1179,
      :xminor, 1180,
      :repotag, 1181,
      :keywords, 1182,
      :buildplatforms, 1183,
      :packagecolor, 1184,
      :packageprefcolor, 1185,
      :xattrsdict, 1186,
      :filexattrsx, 1187,
      :depattrsdict, 1188,
      :conflictattrsx, 1189,
      :obsoleteattrsx, 1190,
      :provideattrsx, 1191,
      :requireattrsx, 1192,
      :buildprovides, 1193,
      :buildobsoletes, 1194,
      :dbinstance, 1195,
      :nvra, 1196,
      :filenames, 5000,
      :fileprovide, 5001,
      :filerequire, 5002,
      :fsnames, 5003,
      :fssizes, 5004,
      :triggerconds, 5005,
      :triggertype, 5006,
      :origfilenames, 5007,
      :longfilesizes, 5008,
      :longsize, 5009,
      :filecaps, 5010,
      :filedigestalgo, 5011,
      :bugurl, 5012,
      :evr, 5013,
      :nvr, 5014,
      :nevr, 5015,
      :nevra, 5016,
      :headercolor, 5017,
      :verbose, 5018,
      :epochnum, 5019,
      :preinflags, 5020,
      :postinflags, 5021,
      :preunflags, 5022,
      :postunflags, 5023,
      :pretransflags, 5024,
      :posttransflags, 5025,
      :verifyscriptflags, 5026,
      :triggerscriptflags, 5027,
      :collections, 5029,
      :policynames, 5030,
      :policytypes, 5031,
      :policytypesindexes, 5032,
      :policyflags, 5033,
      :vcs, 5034,
      :ordername, 5035,
      :orderversion, 5036,
      :orderflags, 5037,
      :firstfree_tag ]
    )

    Dbi = enum(
      :packages, 0,
      :label, 2,
      :name, Tag[:name],
      :basenames, Tag[:basenames],
      :group, Tag[:group],
      :requirename, Tag[:requirename],
      :providename, Tag[:providename],
      :conflictname, Tag[:conflictname],
      :obsoletename, Tag[:obsoletename],
      :triggername, Tag[:triggername],
      :dirnames, Tag[:dirnames],
      :installtid, Tag[:installtid],
      :sigmd5, Tag[:sigmd5],
      :sha1header, Tag[:sha1header]
    )

    TagType = enum( :tag_type, [
      :null_type, 0,
      :char_type, 1,
      :int8_type, 2,
      :int16_type, 3,
      :int32_type, 4,
      :int64_type, 5,
      :string_type, 6,
      :bin_type, 7,
      :string_array_type, 8,
      :i18nstring_type, 9 ])

  end
end
