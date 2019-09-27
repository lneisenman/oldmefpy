cdef extern from "mef_lib_2_1/mef.h":
    ctypedef char si1
    ctypedef unsigned char ui1
    ctypedef short si2
    ctypedef unsigned short ui2
    ctypedef int si4
    ctypedef unsigned int ui4
    ctypedef long long si8
    ctypedef unsigned long long ui8
    ctypedef float sf4
    ctypedef double sf8
    ctypedef long double sf16

    cdef int MEF_HEADER_LENGTH

    ctypedef struct MEF_HEADER_INFO:
        si1 *institution
        si1 *unencrypted_text_field
        si1 *encryption_algorithm
        ui1 subject_encryption_used
        ui1 session_encryption_used
        ui1 data_encryption_used
        ui1 byte_order_code
        ui1 header_version_major
        ui1 header_version_minor
        si1	*subject_first_name
        si1 *subject_second_name
        si1 *subject_third_name
        si1 *subject_id
        ui8 number_of_samples
        si1 *channel_name
        ui8 recording_start_time
        ui8 recording_end_time
        sf8 sampling_frequency
        sf8 low_frequency_filter_setting
        sf8 high_frequency_filter_setting
        sf8 notch_filter_frequency
        sf8 voltage_conversion_factor
        si1 *channel_comments
        si4 physical_channel_number
        ui8 index_data_offset
        ui8 number_of_index_entries
        ui4 maximum_compressed_block_size
        ui8 maximum_block_length
        ui2 block_header_length
        sf4 GMT_offset
        
    ctypedef struct RED_BLOCK_HDR_INFO:
        si4 sample_count

    ctypedef struct INDEX_DATA:
        ui8 time
        ui8 file_offset
        ui8 sample_number


    si4	read_mef_header_block(ui1 *bk_hdr, MEF_HEADER_INFO *header, si1 *password)
    void showHeader(MEF_HEADER_INFO *header)
    ui8 RED_decompress_block(ui1 *in_buffer, si4 *out_buffer, si1 *diff_buffer, ui1 *key, ui1 validate_CRC, ui1 data_encryption, RED_BLOCK_HDR_INFO *block_hdr_struct)
