from array import array

import numpy as np

cimport mef

def read_metadata(fn, show=False):
    cdef mef.MEF_HEADER_INFO header
    cdef char password[32]
    password[0] = 0
    with open(fn, 'r+b') as fp:
        bk_hdr = fp.read(mef.MEF_HEADER_LENGTH)
        mef.read_mef_header_block(bk_hdr, &header, password)

    if show:
        mef.showHeader(&header)

    return header


def read_index(fn, header):
    index_size = sizeof(mef.INDEX_DATA)
    # print('index_size = {}'.format(index_size))
    with open(fn, 'r+b') as fp:
        fp.seek(header['index_data_offset'])
        indx_bytes = fp.read(index_size*header['number_of_index_entries'])
        indx_array = array('Q', indx_bytes)
        indx_array = np.asarray(indx_array, dtype=np.uint64)
        indx_array.resize((header['number_of_index_entries'], 3))

    return indx_array


def read_data(fn, header, indx_array, start_block, num_blocks):
    cdef mef.RED_BLOCK_HDR_INFO RED_bk_hdr
    cdef mef.si1 password[32]
    cdef mef.ui1 encryptionKey[240]
    cdef mef.ui4 blocks_per_cycle = 5000
    cdef mef.ui4 maxInDataLength = blocks_per_cycle * header['maximum_compressed_block_size']
    cdef mef.ui4 outDataLength = blocks_per_cycle * header['maximum_block_length']
    cdef mef.ui1[::1] in_data = np.zeros(maxInDataLength, dtype=np.uint8)
    cdef mef.si1[::1] diff_buffer = np.zeros(header['maximum_block_length']*4, dtype=np.int8)
    cdef mef.si4[::1] data = np.zeros(outDataLength, dtype=np.int32)

    password[0] = 0
    encryptionKey[0] = 0
    out_data = np.zeros(0, dtype=np.int32)
    with open(fn, 'r+b') as fp:
        last_block = start_block + num_blocks
        while start_block < last_block:
            end_block = start_block + blocks_per_cycle
            if end_block > last_block:
                end_block = last_block
                inDataLength = header['index_data_offset'] - indx_array[start_block, 1]
            else:
                inDataLength = indx_array[end_block, 1] - indx_array[start_block, 1]

            fp.seek(indx_array[start_block, 1])
            temp = fp.read(int(inDataLength))
            temp_array = array('B', temp)
            in_data[:] = 0
            for i in range(temp_array.buffer_info()[1]):
                in_data[i] = temp_array[i]

            dp = 0
            idp = 0
            entryCounter = 0
            for i in range(start_block, end_block):
                bytesDecoded = mef.RED_decompress_block(&in_data[idp], &data[dp], &diff_buffer[0], encryptionKey, 0, header['data_encryption_used'], &RED_bk_hdr)
                idp += bytesDecoded
                dp += RED_bk_hdr.sample_count
                entryCounter += RED_bk_hdr.sample_count

            out_data = np.append(out_data, data[:entryCounter])
            start_block = end_block

    return out_data


def read_mef(fn, start_idx=None, end_idx=None):
    cdef mef.si1 password[16], dbp
    cdef mef.si4 dp
    cdef mef.ui1 *hdr_block, idp, encryptionKey[240]

    header = read_metadata(fn)
    if header['data_encryption_used']:
        raise ValueError("I can't do encryption")

    if start_idx is None:
        start_idx = 0
        
    if start_idx >= header['number_of_samples']:
        raise ValueError('start index exceeds number of samples')

    if end_idx is None:
        end_idx = header['number_of_samples']
    elif end_idx > header['number_of_samples']:
        raise ValueError('end index exceeds number of samples')

    if start_idx >= end_idx:
        raise ValueError('start index >= end index')
        
    indx_array = read_index(fn, header)
    n_index_entries = header['number_of_index_entries']
    for i in range(1, n_index_entries):
        if indx_array[i, 2] > start_idx:
            break

    if indx_array[n_index_entries-1, 2] < start_idx:
        start_block = n_index_entries - 1
        end_block = n_index_entries
    else:
        start_block = i - 1
        for i in range(start_block, n_index_entries):
            if indx_array[i, 2] > end_idx:
                break

        if indx_array[n_index_entries-1, 2] < end_idx:
            end_block = n_index_entries
        else:
            end_block = i

    slice_start = int(start_idx - indx_array[start_block, 2])
    slice_end = int(slice_start + end_idx - start_idx)
    num_blocks = end_block - start_block
    return read_data(fn, header, indx_array, start_block, num_blocks)[slice_start:slice_end]
