function [sub_code] = input_subCode(cfg,subId_str)
%[sub_code] = input_subCode(cfg,subId_str)
%
% Asks the participant's code (e.g., protocol code, 23TL01) 
%
% by <teddy.landron@gmail.com> (2020)

%% Init
confirm = false;

%% Text
if cfg.english
    input_text{1} = ['\nSubject ID code:\n'                             ...
        '    press [ENTER] to leave empty,\n'...
        '    or type ' subId_str '''s ID code (alphanumeric);\n'...
        'Answer: '];
    input_text{2} = ['\nConfirm ' subId_str '''s ID code ''%s'': (numeric, yes: 1/no: 0)'];
else
    input_text{1} = ['\nCode ID sujet:\n'                              ...
        '    Entrer [ENTREE] pour laisser vide,\n'...
        '    ou taper le code ID du ' subId_str ' (alphanumérique)\n'...
        'Réponse: '];
    input_text{2} = ['\nConfirmer le code ID ''%s'' pour le ' subId_str ...
        ' (chiffre, oui : 1/non : 0) : '];
end

%% Main
while ~confirm
    sub_code = input(input_text{1},'s');
    confirm = logical(input_num(cfg,sprintf(input_text{2},sub_code),[0 1]));
end
    
    