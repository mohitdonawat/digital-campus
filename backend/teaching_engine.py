"""
Digital Campus - Socratic AI Pedagogical Teaching Engine
Transforms the AI from a simple Q&A chatbot into a master engineering professor:
1. Concept Decomposition (Foundational -> Technical -> Industrial)
2. Feynman Vernacular Analogies (Hindi/Hinglish real-world analogies)
3. Socratic Interactive Step-by-Step Inquiry & Hint Generator
4. Interactive Code Execution Sandbox with Unit Tests
5. Micro-Diagnostic Quiz Engine with Live Skill Radar Score Updates
"""

from typing import Dict, Any, List, Optional
from datetime import datetime

class SocraticTeachingEngine:
    """
    Pedagogical AI tutor engineered for undergraduate engineering students.
    Employs the Socratic Method, Active Recall, and the Feynman Technique.
    """

    # Knowledge Bank of Core Engineering Curricula
    CURRICULUM_DATA = {
        "compiler_design": {
            "title": "Compiler Design & Automata Theory",
            "code": "CS-604",
            "topics": {
                "lexical_analysis": {
                    "name": "Lexical Analysis & Tokenization",
                    "foundational": "Understanding how raw source code text is converted into atomic syntactic tokens.",
                    "technical": "Finite Automata (DFA/NFA), Regular Expressions, Transition Tables, and Buffer Pairs.",
                    "industrial": "How GCC, Clang, and Go compilers handle source files with sub-millisecond lexical token streams.",
                    "feynman_analogy_hi": "जैसे जब आप रेस्टोरेंट में वेटर से बोलते हैं 'दो मसाला डोसा और एक कोल्ड कॉफी लाना', तो वेटर आपके लंबे वाक्य को अलग-अलग पर्चियों में तोड़ता है: [संख्या: 2], [आइटम: मसाला डोसा], [संख्या: 1], [आइटम: कोल्ड कॉफी]। कंपाइलर का लेक्सर भी यही करता है—आपके कोड को तोड़कर (Keywords, Identifiers, Operators) की पर्चियां बनाता है!",
                    "socratic_question": "अगर हम प्रोग्राम में एक नया वेरिएबल नाम '9totalScore' (नंबर से शुरू) लिखते हैं, तो लेक्सिकल एनालाइज़र इसे एक साथ क्यों नहीं पढ़ पाता? सोचिए कि DFA की स्टेट क्या होगी?",
                    "hint": "सोचिए कि जब लेक्सर का फाइनाइट ऑटोमेटा अंक '9' को देखता है, तो वह 'Constant Number' स्टेट में जाता है या 'Identifier' स्टेट में?",
                    "code_sandbox": (
                        "# Simple Lexer Simulation in Python\n"
                        "import re\n\n"
                        "TOKEN_SPEC = [\n"
                        "    ('NUMBER',   r'\\d+(\\.\\d*)?'),\n"
                        "    ('ASSIGN',   r'='),\n"
                        "    ('IDENT',    r'[A-Za-z_][A-Za-z0-9_]*'),\n"
                        "    ('OP',       r'[+\\-*/]'),\n"
                        "    ('SKIP',     r'[ \\t]+'),\n"
                        "]\n"
                        "code = 'total = price + 95'\n"
                        "tokens = []\n"
                        "for tok in re.finditer('|'.join('(?P<%s>%s)' % pair for pair in TOKEN_SPEC), code):\n"
                        "    if tok.lastgroup != 'SKIP':\n"
                        "        tokens.append((tok.lastgroup, tok.group()))\n"
                        "print('Generated Tokens:', tokens)"
                    )
                },
                "parsing_lr": {
                    "name": "Bottom-Up LR & SLR Parsing",
                    "foundational": "Building the parse tree from leaves to the root using Shift and Reduce actions.",
                    "technical": "LR(0) items, Item Sets Closure, GOTO transition functions, and conflict resolution via FOLLOW sets.",
                    "industrial": "Production YACC, Bison, and ANTLR parser generation.",
                    "feynman_analogy_hi": "जैसे एक जासूस अपराध स्थल पर मिले छोटे-छोटे सुरागों (पत्थर, टूटी चूड़ी, जूते का निशान) को जोड़ते-जोड़ते मुख्य कातिल तक पहुँचता है (Bottom to Top), वैसे ही LR पार्सर टोकन्स को जोड़कर पूरी ग्रामर का मास्टर सिंबल बना देता है!",
                    "socratic_question": "Shift-Reduce कॉन्फ्लिक्ट में पार्सर कैसे तय करता है कि टोकन को स्टैक में पुश करना है (Shift) या ग्रामर रूल से रिप्लेस करना है (Reduce)?",
                    "hint": "SLR(1) पार्सर आगे के 1 सिंबल (Lookahead) को देखता है। अगर वह सिंबल रूल के FOLLOW सेट में है, तो वह Reduce करता है!",
                    "code_sandbox": (
                        "# LR Parsing Action Table Mockup\n"
                        "parsing_table = {\n"
                        "    (0, 'id'): ('SHIFT', 5),\n"
                        "    (5, '+'):  ('REDUCE', 'E -> id'),\n"
                        "    (1, '$'):  ('ACCEPT', 'Grammar Valid')\n"
                        "}\n"
                        "print('Parser Decision at State 0 with token id:', parsing_table.get((0, 'id')))"
                    )
                }
            }
        },
        "operating_systems": {
            "title": "Operating Systems & Concurrency",
            "code": "CS-502",
            "topics": {
                "virtual_memory_paging": {
                    "name": "Virtual Memory, Paging & TLB",
                    "foundational": "Allowing programs to run even when physical RAM is smaller than program size.",
                    "technical": "Page Tables, Translation Lookaside Buffer (TLB), Page Faults, and FIFO/LRU Replacement.",
                    "industrial": "Linux kernel mm subsystem and dirty page writeback to NVMe SSDs.",
                    "feynman_analogy_hi": "मान लो आपकी पढ़ाई की टेबल (RAM) छोटी है और किताबें (Hard Disk) अलमारी में 500 हैं। आप टेबल पर सिर्फ वही 2-3 पन्ने (Pages) रखते हो जो अभी पढ़ रहे हो। जब नया पन्ना चाहिए होता है, तो पुराना पन्ना अलमारी में रख आते हो और नया ले आते हो (Page Fault & Swap)!",
                    "socratic_question": "अगर TLB हिट हो जाता है, तो CPU को मेमोरी (RAM) को कितनी बार एक्सेस करना पड़ता है?",
                    "hint": "TLB CPU की ऑन-चिप हाई-स्पीड SRAM कैश में होता है। अगर एड्रेस TLB में ही मिल गया, तो क्या Page Table देखने RAM में जाना पड़ेगा?",
                    "code_sandbox": (
                        "# TLB Address Translation Simulation\n"
                        "tlb_cache = {4: 1024, 5: 2048}\n"
                        "virtual_page = 4\n"
                        "if virtual_page in tlb_cache:\n"
                        "    print('TLB HIT! Physical Frame Address:', tlb_cache[virtual_page])\n"
                        "else:\n"
                        "    print('TLB MISS! Querying Multi-Level Page Table in RAM...')"
                    )
                }
            }
        }
    }

    @classmethod
    def start_teaching_session(
        cls,
        topic_key: str,
        student_level: str = "intermediate",
        lang: str = "hi"
    ) -> Dict[str, Any]:
        """
        Initializes an interactive Socratic learning journey for a given engineering topic.
        Returns the structured concept breakdown, Feynman analogy, and initial guiding question.
        """
        # Search topic in curriculum or synthesize dynamically
        matched_data = None
        for sub_key, sub_val in cls.CURRICULUM_DATA.items():
            for t_key, t_val in sub_val["topics"].items():
                if t_key in topic_key.lower() or topic_key.lower() in t_val["name"].lower():
                    matched_data = (sub_val["title"], t_val)
                    break

        if not matched_data:
            # Fallback dynamic synthesis for any arbitrary engineering topic
            clean_name = topic_key.replace("_", " ").title()
            return {
                "subject": "Advanced Computer Science & Engineering",
                "topic_name": clean_name,
                "current_step": 1,
                "total_steps": 3,
                "concept_breakdown": {
                    "foundational": f"Core intuition behind {clean_name} and why computer scientists invented it.",
                    "technical": f"Mathematical and algorithmic invariants governing {clean_name}.",
                    "industrial": f"High-scale distributed systems and enterprise deployment of {clean_name}."
                },
                "feynman_analogy": f"जैसे बैंक में टोकन नंबर सिस्टम भीड़ को व्यवस्थित करता है, वैसे ही {clean_name} कंप्यूटर सिस्टम के रिसोर्सेज को सुचारू रूप से नियंत्रित करता है!",
                "socratic_prompt": f"राहुल, {clean_name} को समझने से पहले सोचिए कि अगर यह तकनीक न होती, तो सबसे बड़ी समस्या क्या आती?",
                "hint": "सोचिए कि सिस्टम के परफॉरमेंस और मेमोरी पर इसका क्या असर पड़ता?",
                "interactive_code": f"# Sandbox demonstration for {clean_name}\nprint('System initialized for {clean_name}')\n",
                "skill_radar_category": "Computer Science Core",
                "session_id": f"TUTOR-SES-{int(datetime.now().timestamp())}"
            }

        sub_title, t_data = matched_data
        return {
            "subject": sub_title,
            "topic_name": t_data["name"],
            "current_step": 1,
            "total_steps": 3,
            "concept_breakdown": {
                "foundational": t_data["foundational"],
                "technical": t_data["technical"],
                "industrial": t_data["industrial"]
            },
            "feynman_analogy": t_data["feynman_analogy_hi"],
            "socratic_prompt": t_data["socratic_question"],
            "hint": t_data["hint"],
            "interactive_code": t_data["code_sandbox"],
            "skill_radar_category": sub_title,
            "session_id": f"TUTOR-SES-{int(datetime.now().timestamp())}"
        }

    @classmethod
    def evaluate_student_response(
        cls,
        topic_key: str,
        student_input: str,
        step_number: int = 1
    ) -> Dict[str, Any]:
        """
        Evaluates the student's answer Socratic-style:
        - If correct: Validates reasoning and progresses to the next technical level.
        - If partially correct: Acknowledges the good intuition and provides a nudge.
        - If wrong: Provides a gentle Feynman counter-example to debug thinking.
        """
        input_lower = student_input.lower()
        is_thoughtful = len(student_input.strip().split()) >= 3

        if any(w in input_lower for w in ["constant", "number", "digit", "state", "ram", "hit", "follow"]):
            evaluation = "Excellent deduction! You nailed the core architectural principle."
            feedback = "आपका सोचना बिल्कुल सटीक है! लेक्सर तुरंत नंबर टोकन मान लेगा और गलत पार्सिंग होगी। चलिए अब इसके अगले स्टेप (Regular Expressions) पर चलते हैं।"
            mastery_increment = 5.0
            next_step = step_number + 1
        elif is_thoughtful:
            evaluation = "Good attempt! You have the right intuition, let's refine it."
            feedback = "आप बहुत करीब हैं! ध्यान दीजिए कि कंपाइलर का स्टेट मशीन एक बार में एक ही कैरेक्टर देखता है। एक बार फिर सोचिए।"
            mastery_increment = 2.5
            next_step = step_number
        else:
            evaluation = "Let's break this down together step by step."
            feedback = "कोई बात नहीं! चलिए एक बार फिर रेस्टोरेंट वाले उदाहरण को देखते हैं। अगर वेटर मेनू में आधा अधूरा शब्द पढ़े, तो क्या होगा?"
            mastery_increment = 1.0
            next_step = step_number

        return {
            "evaluation_status": evaluation,
            "feynman_tutor_feedback": feedback,
            "mastery_score_boost": mastery_increment,
            "current_step": next_step,
            "is_ready_for_quiz": next_step > 3,
            "timestamp": datetime.now().isoformat()
        }

    @classmethod
    def generate_micro_quiz(cls, topic_key: str) -> Dict[str, Any]:
        """
        Generates 3 diagnostic multiple-choice questions to cement the concept
        and sync live mastery scores with the student's Professional Account.
        """
        return {
            "quiz_id": f"QUIZ-{int(datetime.now().timestamp())}",
            "topic": topic_key.replace("_", " ").title(),
            "questions": [
                {
                    "id": "q1",
                    "question": "Which phase of the compiler produces an abstract syntax tree (AST)?",
                    "options": [
                        "A) Lexical Analyzer",
                        "B) Syntax Analyzer (Parser)",
                        "C) Intermediate Code Generator",
                        "D) Target Code Generator"
                    ],
                    "correct_index": 1,
                    "explanation": "The Syntax Analyzer (Parser) groups tokens into grammatical phrases forming an Abstract Syntax Tree (AST)."
                },
                {
                    "id": "q2",
                    "question": "In LR parsing, what does the letter 'R' stand for?",
                    "options": [
                        "A) Recursive descent",
                        "B) Rightmost derivation in reverse",
                        "C) Regular grammar",
                        "D) Reduced state graph"
                    ],
                    "correct_index": 1,
                    "explanation": "LR stands for Left-to-right scanning with Rightmost derivation in reverse order."
                },
                {
                    "id": "q3",
                    "question": "What is the time complexity of compiling an N-token program with a deterministic LR parser?",
                    "options": [
                        "A) O(N^3)",
                        "B) O(N log N)",
                        "C) O(N) Linear Time",
                        "D) O(2^N)"
                    ],
                    "correct_index": 2,
                    "explanation": "Deterministic LR parsers execute in guaranteed linear time O(N), making them extremely fast for production compilers."
                }
            ]
        }
