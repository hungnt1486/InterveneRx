//
//  NSDictionary+Survey.m
//  InterV
//
//  Created by HungLe on 12/27/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "NSDictionary+Survey.h"

@implementation NSDictionary (Survey)

//- (NSDictionary *)results{
//    return self[@"results"];
//}
//- (NSNumber *)Id;
//- (NSNumber *)ParentQuestion;
//- (NSString *)QuestionName;
//- (NSNumber *)QuestionType;
//- (NSArray *)Answers;
//- (NSArray *)questions;
//- (NSString *)AnswerName;

//{
//    "success": "1",
//    "token": "ferhhrthhrtioyti2ytiuht3te",
//    "results": [
//                {
//                    "Id": "1",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you have internet (wifi) service?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "1",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "2",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": [
//                                  {
//                                      "Id": "2",
//                                      "ParentQuestion": "1",
//                                      "QuestionName": "Do you have a computer?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "3",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "4",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": [
//                                                    {
//                                                        "Id": "3",
//                                                        "ParentQuestion": "2",
//                                                        "QuestionName": "How often do you use your computer?",
//                                                        "QuestionType": "2",
//                                                        "Answers": [
//                                                                    {
//                                                                        "Id": "5",
//                                                                        "AnswerName": "text"
//                                                                    }
//                                                                    ],
//                                                        "questions": []
//                                                    },
//                                                    {
//                                                        "Id": "4",
//                                                        "ParentQuestion": "2",
//                                                        "QuestionName": "Can you locate a website when given the address?",
//                                                        "QuestionType": "1",
//                                                        "Answers": [
//                                                                    {
//                                                                        "Id": "6",
//                                                                        "AnswerName": "Yes"
//                                                                    },
//                                                                    {
//                                                                        "Id": "7",
//                                                                        "AnswerName": "No"
//                                                                    }
//                                                                    ],
//                                                        "questions": []
//                                                    },
//                                                    {
//                                                        "Id": "5",
//                                                        "ParentQuestion": "2",
//                                                        "QuestionName": "Can you find information on the internet using a search engine such as Google or Yahoo?",
//                                                        "QuestionType": "1",
//                                                        "Answers": [
//                                                                    {
//                                                                        "Id": "8",
//                                                                        "AnswerName": "Yes"
//                                                                    },
//                                                                    {
//                                                                        "Id": "9",
//                                                                        "AnswerName": "No"
//                                                                    }
//                                                                    ],
//                                                        "questions": []
//                                                    },
//                                                    {
//                                                        "Id": "6",
//                                                        "ParentQuestion": "2",
//                                                        "QuestionName": "Can you download and save files, such as documents or PDF’s, from the internet? ",
//                                                        "QuestionType": "1",
//                                                        "Answers": [
//                                                                    {
//                                                                        "Id": "10",
//                                                                        "AnswerName": "Yes"
//                                                                    },
//                                                                    {
//                                                                        "Id": "11",
//                                                                        "AnswerName": "No"
//                                                                    }
//                                                                    ],
//                                                        "questions": []
//                                                    }
//                                                    ]
//                                  },
//                                  {
//                                      "Id": "7",
//                                      "ParentQuestion": "1",
//                                      "QuestionName": "Is the computer shared with others?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "12",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "13",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "8",
//                                      "ParentQuestion": "1",
//                                      "QuestionName": "Do you have an IPad or other tablet computer?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "14",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "15",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "9",
//                                      "ParentQuestion": "1",
//                                      "QuestionName": "Have you ever downloaded an app?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "16",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "17",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  }
//                                  ]
//                },
//                
//                {
//                    "Id": "10",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you have cellular service?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "18",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "19",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": [
//                                  {
//                                      "Id": "11",
//                                      "ParentQuestion": "10",
//                                      "QuestionName": "Do you have a smartphone?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "20",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "21",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "12",
//                                      "ParentQuestion": "10",
//                                      "QuestionName": "Is the phone shared with others?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "22",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "23",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "13",
//                                      "ParentQuestion": "10",
//                                      "QuestionName": "Is the device an IPhone or Android?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "24",
//                                                      "AnswerName": "IPhone"
//                                                  },
//                                                  {
//                                                      "Id": "25",
//                                                      "AnswerName": "Android"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "14",
//                                      "ParentQuestion": "10",
//                                      "QuestionName": "Can you text message?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "26",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "27",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  }
//                                  ]
//                },
//                
//                {
//                    "Id": "15",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you have email?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "28",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "29",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": [
//                                  {
//                                      "Id": "16",
//                                      "ParentQuestion": "15",
//                                      "QuestionName": "Can you read an email?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "30",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "31",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "17",
//                                      "ParentQuestion": "15",
//                                      "QuestionName": "Can you reply to an email?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "32",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "33",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  },
//                                  {
//                                      "Id": "18",
//                                      "ParentQuestion": "15",
//                                      "QuestionName": "Can you open an attachment or send an attachment in an email?",
//                                      "QuestionType": "1",
//                                      "Answers": [
//                                                  {
//                                                      "Id": "34",
//                                                      "AnswerName": "Yes"
//                                                  },
//                                                  {
//                                                      "Id": "35",
//                                                      "AnswerName": "No"
//                                                  }
//                                                  ],
//                                      "questions": []
//                                  }
//                                  ]
//                },
//                
//                {
//                    "Id": "19",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you currently use any health or fitness related apps or devices with your phone or tablet?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "36",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "37",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": []
//                },
//                
//                {
//                    "Id": "20",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you currently use any biometric devices in your home (such as blood pressure monitor, glucometer, etc)?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "38",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "39",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": []
//                },
//                
//                {
//                    "Id": "21",
//                    "ParentQuestion": "0",
//                    "QuestionName": "Do you require any personal/caregiver assistance to use the computer, phone or biometric devices in your home?",
//                    "QuestionType": "1",
//                    "Answers": [
//                                {
//                                    "Id": "40",
//                                    "AnswerName": "Yes"
//                                },
//                                {
//                                    "Id": "41",
//                                    "AnswerName": "No"
//                                }
//                                ],
//                    "questions": []
//                }
//                
//                ]
//}

@end
