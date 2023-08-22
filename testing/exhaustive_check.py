from quicksort import quicksort
import copy

'''''''''''''''
!!!!

Program that cross references exhaustive checks between python quicksort and legv8 quicksort output.

1. Duplicate data array in text file. See 'data1.txt' for example
2. Load 'exhaustive.s' and text file data. Make sure to modify the array length for printing
3. Run entire program and the save output as a text file
4. Remove all contents except the sorted output arrays. See 'output1.txt' for example
5. Run 'exhaustive_check.py'. Make sure to configure your file paths

!!!!
'''''''''''''''

def get_data(path):
    '''
    Get data array from text file.

    :path: file path to text file
    :return: data array
    '''

    # Read text file
    file = open(path, 'r')
    lines = file.readlines()

    for line in lines:

        # Find start of array
        if 'a:' in line:

            # Parse data
            data = line.replace('a:', '').strip()
            data = data.split(' ')
            data = [int(i) for i in data]

            return data

def quicksort_python(data):
    '''
    Implement exhaustive quicksort on python

    :data: data array
    :return: dictionary of all possible quicksorts, access with key: (low, high)
    '''

    temp = copy.copy(data)
    truths = {}

    for i, _ in enumerate(data):
        for j, _ in enumerate(data):
            # Edge case: skip when j < i
            if j < i:
                continue

            quicksort(temp, i, j)
            truths.update({(i, j): temp})
            temp = copy.copy(data)

    return truths

def parse_simulator_output(path, keys):
    '''
    Parse output file from LEGV8 simulator and format as dictionary, access with key: (low, high)

    :path: file path to output file
    :keys: keys of exhaustive sorted arrays
    :return: dictionary of LEGV8 simulator results, access with key: (low, high)
    '''

    # Read text file
    file = open(path, 'r')
    lines = file.readlines()

    output = {}
    for key in keys:
        limit = lines.index('\n')
        sorted_array = lines[:limit]
        sorted_array = [int(i) for i in sorted_array[1:]]
        output.update({key: sorted_array})

        lines = lines[limit+1:]
    
    return output

if __name__ == '__main__':
    # Data text file
    data = get_data('data/data4.txt')

    # Get ground truths from python quicksort
    truths = quicksort_python(data)

    # Output file from LEGV8
    simulator_output = parse_simulator_output('data/output4.txt', truths.keys())

    # Exhaustive check
    accuracy = 0
    for i in truths:
        match = truths[i] == simulator_output[i]
        emoji = '\u2705' if match else '\u274c'
        accuracy += int(match)

        print(f'(Low, High): {i}')
        print(f'Truth: {truths[i]}')
        print(f'Simulator: {simulator_output[i]}')
        print(emoji)
        print('')

    print(f'Accuracy: {accuracy}/{len(truths)}')

        
