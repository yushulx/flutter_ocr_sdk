const String template = """
{
    "CaptureVisionTemplates": [
        {
            "Name": "ReadVINText",
            "ImageROIProcessingNameArray": [
                "roi-read-vin-text"
            ],
            "ImageSource": "",
            "MaxParallelTasks": 4,
            "MinImageCaptureInterval": 0,
            "OutputOriginalImage": 0,
            "Timeout": 10000
        },
        {
            "Name": "ReadMRZ",
            "OutputOriginalImage": 0,
            "ImageROIProcessingNameArray": [
                "roi-mrz"
            ],
            "SemanticProcessingNameArray": [
                "sp-mrz"
            ],
            "Timeout": 1000000
        }
    ],
    "TargetROIDefOptions": [
        {
            "Name": "roi-read-vin-text",
            "TaskSettingNameArray": [
                "task-read-vin-text"
            ]
        },
        {
            "Name": "roi-mrz",
            "TaskSettingNameArray": [
                "task-mrz"
            ]
        }
    ],
    "CharacterModelOptions": [
        {
            "CharSet": {
                "ExcludeChars": [
                    "O",
                    "Q",
                    "I"
                ]
            },
            "DirectoryPath": "",
            "Name": "VIN"
        },
        {
            "DirectoryPath": "",
            "Name": "MRZ"
        }
    ],
    "ImageParameterOptions": [
        {
            "BaseImageParameterName": "",
            "BinarizationModes": [
                {
                    "BinarizationThreshold": -1,
                    "BlockSizeX": 0,
                    "BlockSizeY": 0,
                    "EnableFillBinaryVacancy": 1,
                    "GrayscaleEnhancementModesIndex": -1,
                    "Mode": "BM_LOCAL_BLOCK",
                    "MorphOperation": "Close",
                    "MorphOperationKernelSizeX": -1,
                    "MorphOperationKernelSizeY": -1,
                    "MorphShape": "Rectangle",
                    "ThresholdCompensation": 10
                }
            ],
            "ColourConversionModes": [
                {
                    "BlueChannelWeight": -1,
                    "GreenChannelWeight": -1,
                    "Mode": "CICM_GENERAL",
                    "RedChannelWeight": -1,
                    "ReferChannel": "H_CHANNEL"
                }
            ],
            "GrayscaleEnhancementModes": [
                {
                    "Mode": "GEM_GENERAL",
                    "Sensitivity": -1,
                    "SharpenBlockSizeX": -1,
                    "SharpenBlockSizeY": -1,
                    "SmoothBlockSizeX": -1,
                    "SmoothBlockSizeY": -1
                }
            ],
            "GrayscaleTransformationModes": [
                {
                    "Mode": "GTM_ORIGINAL"
                },
                {
                    "Mode": "GTM_INVERTED"
                }
            ],
            "IfEraseTextZone": 0,
            "Name": "ip_recognize_text",
            "RegionPredetectionModes": [
                {
                    "AspectRatioRange": "[]",
                    "FindAccurateBoundary": 0,
                    "ForeAndBackgroundColours": "[]",
                    "HeightRange": "[]",
                    "ImageParameterName": "",
                    "MeasuredByPercentage": 1,
                    "MinImageDimension": 262144,
                    "Mode": "RPM_GENERAL",
                    "RelativeRegions": "[]",
                    "Sensitivity": 1,
                    "SpatialIndexBlockSize": 5,
                    "WidthRange": "[]"
                }
            ],
            "ScaleDownThreshold": 2300,
            "ScaleUpModes": [
                {
                    "AcuteAngleWithXThreshold": -1,
                    "LetterHeightThreshold": 0,
                    "Mode": "SUM_AUTO",
                    "ModuleSizeThreshold": 0,
                    "TargetLetterHeight": 0,
                    "TargetModuleSize": 0
                }
            ],
            "TextDetectionMode": {
                "CharHeightRange": [
                    5,
                    1000,
                    1
                ],
                "Direction": "HORIZONTAL",
                "MaxSpacingInALine": -1,
                "Mode": "TTDM_LINE",
                "Sensitivity": 7,
                "StringLengthRange": null
            },
            "TextureDetectionModes": [
                {
                    "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                    "Sensitivity": 5
                }
            ]
        },
        {
            "Name": "ip-mrz",
            "TextureDetectionModes": [
                {
                    "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                    "Sensitivity": 8
                }
            ],
            "BinarizationModes": [
                {
                    "EnableFillBinaryVacancy": 0,
                    "ThresholdCompensation": 21,
                    "Mode": "BM_LOCAL_BLOCK"
                }
            ],
            "TextDetectionMode": {
                "Mode": "TTDM_LINE",
                "CharHeightRange": [
                    5,
                    1000,
                    1
                ],
                "Direction": "HORIZONTAL",
                "Sensitivity": 7
            }
        }
    ],
    "LabelRecognizerTaskSettingOptions": [
        {
            "Name": "task-read-vin-text",
            "TextLineSpecificationNameArray": [
                "tls_vin_text"
            ],
            "SectionImageParameterArray": [
                {
                    "ContinueWhenPartialResultsGenerated": 1,
                    "ImageParameterName": "ip_recognize_text",
                    "Section": "ST_REGION_PREDETECTION"
                },
                {
                    "ContinueWhenPartialResultsGenerated": 1,
                    "ImageParameterName": "ip_recognize_text",
                    "Section": "ST_TEXT_LINE_LOCALIZATION"
                },
                {
                    "ContinueWhenPartialResultsGenerated": 1,
                    "ImageParameterName": "ip_recognize_text",
                    "Section": "ST_TEXT_LINE_RECOGNITION"
                }
            ]
        },
        {
            "Name": "task-mrz",
            "ConfusableCharactersPath": "ConfusableChars.data",
            "TextLineSpecificationNameArray": [
                "tls-mrz-passport",
                "tls-mrz-visa-td3",
                "tls-mrz-id-td1",
                "tls-mrz-id-td2",
                "tls-mrz-visa-td2"
            ],
            "SectionImageParameterArray": [
                {
                    "Section": "ST_REGION_PREDETECTION",
                    "ImageParameterName": "ip-mrz"
                },
                {
                    "Section": "ST_TEXT_LINE_LOCALIZATION",
                    "ImageParameterName": "ip-mrz"
                },
                {
                    "Section": "ST_TEXT_LINE_RECOGNITION",
                    "ImageParameterName": "ip-mrz"
                }
            ]
        }
    ],
    "TextLineSpecificationOptions": [
        {
            "BinarizationModes": [
                {
                    "BinarizationThreshold": -1,
                    "BlockSizeX": 11,
                    "BlockSizeY": 11,
                    "EnableFillBinaryVacancy": 1,
                    "GrayscaleEnhancementModesIndex": -1,
                    "Mode": "BM_LOCAL_BLOCK",
                    "MorphOperation": "Erode",
                    "MorphOperationKernelSizeX": -1,
                    "MorphOperationKernelSizeY": -1,
                    "MorphShape": "Rectangle",
                    "ThresholdCompensation": 10
                }
            ],
            "CharHeightRange": [
                5,
                1000,
                1
            ],
            "CharacterModelName": "VIN",
            "CharacterNormalizationModes": [
                {
                    "Mode": "CNM_AUTO",
                    "MorphArgument": "3",
                    "MorphOperation": "Close"
                }
            ],
            "ConcatResults": 0,
            "ConcatSeparator": "\\n",
            "ConcatStringLengthRange": [
                3,
                200
            ],
            "ExpectedGroupsCount": 1,
            "GrayscaleEnhancementModes": [
                {
                    "Mode": "GEM_GENERAL",
                    "Sensitivity": -1,
                    "SharpenBlockSizeX": -1,
                    "SharpenBlockSizeY": -1,
                    "SmoothBlockSizeX": -1,
                    "SmoothBlockSizeY": -1
                }
            ],
            "Name": "tls_vin_text",
            "OutputResults": 1,
            "StringLengthRange": [
                17,
                17
            ],
            "StringRegExPattern": "[0-9A-HJ-NPR-Z]{9}[1-9A-HJ-NPR-TV-Y][0-9A-HJ-NPR-Z]{2}[0-9]{5}",
            "SubGroups": null,
            "TextLinesCount": 1
        },
        {
            "Name": "tls-mrz-passport",
            "BaseTextLineSpecificationName": "tls-base",
            "StringLengthRange": [
                44,
                44
            ],
            "OutputResults": 1,
            "ExpectedGroupsCount": 1,
            "ConcatResults": 1,
            "ConcatSeparator": "\\n",
            "SubGroups": [
                {
                    "StringRegExPattern": "(P[A-Z<][A-Z<]{3}[A-Z<]{39}){(44)}",
                    "StringLengthRange": [
                        44,
                        44
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[0-9<][0-9]){(44)}",
                    "StringLengthRange": [
                        44,
                        44
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                }
            ]
        },
        {
            "Name": "tls-mrz-visa-td3",
            "BaseTextLineSpecificationName": "tls-base",
            "StringLengthRange": [
                44,
                44
            ],
            "OutputResults": 1,
            "ExpectedGroupsCount": 1,
            "ConcatResults": 1,
            "ConcatSeparator": "\\n",
            "SubGroups": [
                {
                    "StringRegExPattern": "(V[A-Z<][A-Z<]{3}[A-Z<]{39}){(44)}",
                    "StringLengthRange": [
                        44,
                        44
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[A-Z0-9<]{2}){(44)}",
                    "StringLengthRange": [
                        44,
                        44
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                }
            ]
        },
        {
            "Name": "tls-mrz-visa-td2",
            "BaseTextLineSpecificationName": "tls-base",
            "StringLengthRange": [
                36,
                36
            ],
            "OutputResults": 1,
            "ExpectedGroupsCount": 1,
            "ConcatResults": 1,
            "ConcatSeparator": "\\n",
            "SubGroups": [
                {
                    "StringRegExPattern": "(V[A-Z<][A-Z<]{3}[A-Z<]{31}){(36)}",
                    "StringLengthRange": [
                        36,
                        36
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{8}){(36)}",
                    "StringLengthRange": [
                        36,
                        36
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                }
            ]
        },
        {
            "Name": "tls-mrz-id-td2",
            "BaseTextLineSpecificationName": "tls-base",
            "StringLengthRange": [
                36,
                36
            ],
            "OutputResults": 1,
            "ExpectedGroupsCount": 1,
            "ConcatResults": 1,
            "ConcatSeparator": "\\n",
            "SubGroups": [
                {
                    "StringRegExPattern": "([ACI][A-Z<][A-Z<]{3}[A-Z<]{31}){(36)}",
                    "StringLengthRange": [
                        36,
                        36
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{8}){(36)}",
                    "StringLengthRange": [
                        36,
                        36
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                }
            ]
        },
        {
            "Name": "tls-mrz-id-td1",
            "BaseTextLineSpecificationName": "tls-base",
            "StringLengthRange": [
                30,
                30
            ],
            "OutputResults": 1,
            "ExpectedGroupsCount": 1,
            "ConcatResults": 1,
            "ConcatSeparator": "\\n",
            "SubGroups": [
                {
                    "StringRegExPattern": "([ACI][A-Z<][A-Z<]{3}[A-Z0-9<]{9}[0-9][A-Z0-9<]{15}){(30)}",
                    "StringLengthRange": [
                        30,
                        30
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z<]{3}[A-Z0-9<]{11}[0-9]){(30)}",
                    "StringLengthRange": [
                        30,
                        30
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                },
                {
                    "StringRegExPattern": "([A-Z<]{30}){(30)}",
                    "StringLengthRange": [
                        30,
                        30
                    ],
                    "BaseTextLineSpecificationName": "tls-base"
                }
            ]
        },
        {
            "Name": "tls-base",
            "CharacterModelName": "MRZ",
            "CharHeightRange": [
                5,
                1000,
                1
            ],
            "BinarizationModes": [
                {
                    "BlockSizeX": 30,
                    "BlockSizeY": 30,
                    "Mode": "BM_LOCAL_BLOCK",
                    "EnableFillBinaryVacancy": 0,
                    "ThresholdCompensation": 15
                }
            ],
            "ConfusableCharactersCorrection": {
                "ConfusableCharacters": [
                    [
                        "0",
                        "O"
                    ],
                    [
                        "1",
                        "I"
                    ],
                    [
                        "5",
                        "S"
                    ]
                ],
                "FontNameArray": [
                    "OCR_B"
                ]
            }
        }
    ],
    "SemanticProcessingOptions": [
        {
            "Name": "sp-mrz",
            "ReferenceObjectFilter": {
                "ReferenceTargetROIDefNameArray": [
                    "roi-mrz"
                ]
            },
            "TaskSettingNameArray": [
                "dcp-mrz"
            ]
        }
    ],
    "CodeParserTaskSettingOptions": [
        {
            "Name": "dcp-mrz",
            "CodeSpecifications": [
                "MRTD_TD3_PASSPORT",
                "MRTD_TD2_VISA",
                "MRTD_TD3_VISA",
                "MRTD_TD1_ID",
                "MRTD_TD2_ID"
            ]
        }
    ]
}
""";
