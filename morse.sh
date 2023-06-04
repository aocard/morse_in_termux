#!/bin/bash

# Copyright 2021 Aria O. Cardoso
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Information and Usage
#
# This is a program made to convert strings, passed as arguments,
# to morse code, and to use a flashlight (in this case, through
# Termux's API interface, to transmit the coded message.
# The program includes an S.O.S. mode, which can be activated with
# the argument "-sos". I recommend NOT DOING SO IN PUBLIC UNLESS UNDER
# A REAL EMERGENCY.
# The program also includes a repeat mode, activated by passing "-r" as the first argument and followed by the string to transmit, which repeats the message indefinitely. use with care.

# Declaration of morse-coded letters and numbers
declare -A code
code[0]='-----'
code[1]='.----'
code[2]='..---'
code[3]='...--'
code[4]='....-'
code[5]='.....'
code[6]='-....'
code[7]='--...'
code[8]='---..'
code[9]='----.'
code[A]='.-'
code[B]='-...'
code[C]='-.-.'
code[D]='-..'
code[E]='.'
code[F]='..-.'
code[G]='--.'
code[H]='....'
code[I]='..'
code[J]='.---'
code[K]='-.-'
code[L]='.-..'
code[M]='--'
code[N]='-.'
code[O]='---'
code[P]='.--.'
code[Q]='--.-'
code[R]='.-.'
code[S]='...'
code[T]='-'
code[U]='..-'
code[V]='...-'
code[W]='.--'
code[X]='-..-'
code[Y]='-.--'
code[Z]='--..'

# Function for flashlight "dot". corresponds to minimum time the
# Termux utility can turn it on and off, which is acceptable for
# my device (Redmi Note 8).
dot(){
	termux-torch on
	termux-torch off
}

# Function for flashlight "dash". Set to last 0.5 seconds plus
# delays, seems to correspond to roughly three times the duration
# of a "dot"
dash(){
	termux-torch on
	sleep 0.5
	termux-torch off
}

# Function to convert a char to Morse code and flash it on the
# flashlight using "dot" and "dash" above.
morse(){
	ch=$1
	cl=${code[$ch]} # cl is ASCII string of Morse-codded char
	echo $ch $cl # For debugging, prints letter and its Morse equivalent in ASCII
	for (( j=0; j<${#cl}; j++ )); do # Iterates between characters of string containing the letter's code
		if [[ ${cl:$j:1} == '.' ]]; then dot; fi
		if [[ ${cl:$j:1} == '-' ]]; then dash; fi
	done
}

# S.O.S. mode, activated when argument "-sos" is supplied.
# Set to continuously flash an S.O.S signal on the flashlight, with
# no letter spacing, as per international standard.
# Be advised to not use this in public in non-emergency scenarios.
if [[ $@ == "-sos" ]]; then
	echo WARNING: S.O.S. MODE ACTIVATED
	while true; do
		morse S
		morse O
		morse S
		sleep .5
	done
	exit
fi

# Repeat mode. if enabled with -r, cuts the first argument (as it is the -r itself).
if [[ $1 != "-r" ]]; then	
	input=${@^^} # Converts arguments to uppercase and crams them into variable
else
	input=${@:2}
	input=${input^^}
fi

a=1
while [[ $a -eq 1 ]]; do
	for (( i=0; i<${#input}; i++ )); do # Iterates between chars in "input"
		ch=${input:$i:1} # Gets current char
		if [[ $ch > '@' && $ch < '[' ]] || [[ $ch > '/' && $ch < ':' ]]; then # If char is a letter or number
			morse $ch # Flashes char on flashlight
			sleep .5 # Waits for the duration of a "dash", as per international standard
		fi
		if [[ $ch == ' ' ]]; then echo; sleep 1.17; fi # For spaces, echoes a blank line (for debugging) and sleeps for 2.33 times the duration of a dash (or 7x the duration of a dot, as per international standard), rounding up.
	done
	if [[ $1 != "-r" ]]; then # Ends loop if not in repeat mode
		a=0
	else # If on repeat mode,
		echo # Prints a newline for debugging and sleeeps for twice the amount it does in between words.
		sleep 2.34
	fi
done
