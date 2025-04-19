--シールド・アタック
--Shield Attack
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Switch the equipped monster's ATK and DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SWAP_AD)
	c:RegisterEffect(e1)
end