Inputmask.extendDefaults({
  'removeMaskOnSubmit': true
});

Inputmask.extendAliases({
  'cpf_cnpj': {
    mask: ["999.999.999-99", "99.999.999/9999-99"]
  }
});

Inputmask.extendAliases({
  'cep': {
    mask: ["99.999-999"]
  }
});

Inputmask.extendAliases({
  'phone': {
    mask: ["(99) 9999-9999", "(99) 99999-9999"]
  }
});

Inputmask.extendAliases({
  'car': {
    mask: ["aaa-9999"]
  }
});

Inputmask.extendAliases({
  'time': {
    mask: ["99:99"]
  }
});

Inputmask.extendAliases({
  'password': {
    mask: ["9999999999"]
  }
});

Inputmask.extendAliases({
  'br_numeric': {
    alias: "currency",
    prefix: "",
    groupSeparator: ".",
    radixPoint: ",",
    autoGroup: !0,
    digitsOptional: !0,
    decimalProtect: !0
  }
});
