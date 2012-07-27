class @NumberHelpers
  @number_to_currency = (float, opts={}) ->
    _precision  = opts.precision ? 2
    _unit       = opts.unit ? '$'
    _separator  = opts.separator ? '.'
    _delimiter  = opts.delimiter ? ','  
    
    number  = float.toString().split('.')
    integer = number[0] 
    decimal = number[1]
    
    # Pad to _precision
    decimal = parseFloat("0.#{decimal}").toFixed(_precision)
    decimal = decimal.toString().split('.')
    decimal = decimal[1] ? ''
        
    # Remove separator if no decimal
    _separator = '' unless decimal
    
    # Non-number values return zero precision
    _separator = decimal = '' if isNaN(integer)    
    
    integer = NumberHelpers.number_with_delimiter(integer, {delimiter: _delimiter})
          
    return "#{_unit}#{integer}#{_separator}#{decimal}"
  
  @number_with_delimiter = (float, opts={}) ->
    # _separator - Sets the separator between the units (defaults to ".").
    # _delimiter - Sets the thousands delimiter (defaults to ",").
    _separator  = opts.separator ? '.'
    _delimiter  = opts.delimiter ? ','
    
    number  = float.toString().split(".")
    integer = number[0]
    decimal = number[1] ? ''
    
    # Remove separator if no decimal
    _separator = '' unless decimal
    
    rgx = /(\d+)(\d{3})/
    integer = integer .replace(rgx, "$1" + _delimiter + "$2") while rgx.test(integer ) if _delimiter
    
    return "#{integer}#{_separator}#{decimal}"
  
  @number_with_precision = (float, opts={}) ->
    _precision    = opts.precision ? 3
    _delimiter    = opts.delimiter ? ','
    _separator    = opts.separator ? '.'
    _significant  = opts.significant ? false
    _strip_insignificant_zeros = opts.strip_insignificant_zeros ? false
    
    multiple  = Math.pow(10, _precision)
    rounded   = Math.round(float * multiple) / multiple
        
    number    = rounded.toString().split('.')
    integer   = number[0] 
    decimal   = number[1] ? ''
    
    # Pad to _precision
    decimal = parseFloat("0.#{decimal}").toFixed(_precision) 
    decimal = decimal.toString().split('.')
    decimal = decimal[1] ? ''
    
    # Reconstitute the number with correct decimal
    number    = "#{integer}.#{decimal}" * 1
    num_array = number.toString().split('')
    num_lngth = num_array.length
    
    # Count Non-zero Digits
    i = 0; sigs = 0
    while i < num_lngth
      sigs++ unless num_array[i] is '.' or num_array[i] is '0'
      i++
    
    if _significant and sigs > _precision
      
      # toPrecision() rounds therefor need to chomp
      if decimal.toString().length >= _precision
        chomp   = _precision - integer.toString().length
        decimal = decimal.toString().substr(0, chomp)
        number  = "#{integer}.#{decimal}" * 1 
        console.log number
      significant = number.toPrecision(_precision) * 1
      significant = significant.toString().split('.')
      integer     = significant[0] 
      decimal     = significant[1] ? ''
      
    # Delimiter Integer
    integer = NumberHelpers.number_with_delimiter(integer, {delimiter: _delimiter})
    
    # Strip Insignificant Digits
    decimal = '' if _strip_insignificant_zeros
      
    # Remove separator if no decimal
    _separator = '' unless decimal
            
    return "#{integer}#{_separator}#{decimal}"
  
  @number_to_human = (float, opts={}) ->
    _precision    = opts.precision    ? 3
    _separator    = opts.separator    ? '.'
    _significant  = opts.significant  ? true
    _delimiter    = opts.delimiter    ? ','
    _strip_insignificant_zeros = opts.strip_insignificant_zeros ? false
    
    # Remove the sign of the number for easier comparision
    abs_float = Math.abs(float)
    
    # Less than Thousand does not need text or a insignifiant digits
    if abs_float < Math.pow(10, 3)
      denom = 1
      label = false
    else if abs_float >= Math.pow(10, 3) and abs_float < Math.pow(10, 6)
      denom = Math.pow(10, 3)
      label = 'Thousand'
    else if abs_float >= Math.pow(10, 6) and abs_float < Math.pow(10, 9)
      denom = Math.pow(10, 6)
      label = 'Million'
    else if abs_float >= Math.pow(10, 9) and abs_float < Math.pow(10, 12)
      denom = Math.pow(10, 9)
      label = 'Billion'
    else if abs_float >= Math.pow(10, 12) and abs_float < Math.pow(10, 15)
      denom = Math.pow(10, 12)
      label = 'Trillion'
    else if abs_float >= Math.pow(10, 15)
      denom = Math.pow(10, 15)
      label = 'Quadrillion'
    
    # Process the number into a presentable format
    number  = float / denom
    precise = NumberHelpers.number_with_precision(number,
      precision:                  _precision
      significant:                _significant
      delimiter:                  if label is 'Quadrillion' then '' else _delimiter
      separator:                  _separator
      strip_insignificant_zeros:  unless label then true else _strip_insignificant_zeros
    )
    
    #No label needed for less than thousand
    if label
      return "#{precise} #{label}"
    else 
      return precise
  
  @number_to_human_size = (float, opts={}) ->
    _precision    = opts.precision    ? 3
    _separator    = opts.separator    ? '.'
    _significant  = opts.significant  ? true
    _delimiter    = opts.delimiter    ? ','
    _strip_insignificant_zeros = opts.strip_insignificant_zeros ? false
    
    # Remove the sign of the number for easier comparision
    abs_float = Math.abs(float)
    
    # Less than Thousand does not need text or a insignifiant digits
    if abs_float < Math.pow(10, 3)
      denom = 1
      label = 'Bytes'
    else if abs_float >= Math.pow(10, 3) and abs_float < Math.pow(10, 6)
      denom = Math.pow(10, 3)
      label = 'KB'
    else if abs_float >= Math.pow(10, 6) and abs_float < Math.pow(10, 9)
      denom = Math.pow(10, 6)
      label = 'MB'
    else if abs_float >= Math.pow(10, 9) and abs_float < Math.pow(10, 12)
      denom = Math.pow(10, 9)
      label = 'GB'
    else if abs_float >= Math.pow(10, 12) and abs_float < Math.pow(10, 15)
      denom = Math.pow(10, 12)
      label = 'TB'
    
    # Process the number into a presentable format
    number  = float / denom
    
    precise = NumberHelpers.number_with_precision(number,
      precision:                  _precision
      significant:                _significant
      delimiter:                  _delimiter
      separator:                  _separator
      strip_insignificant_zeros:  if label is 'Bytes' then true else _strip_insignificant_zeros
    )
    
    return "#{precise} #{label}"