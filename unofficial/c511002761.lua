--ＢＫ スイッチヒッター
--Battlin' Boxer Switchitter (Anime)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(511001225)
	e1:SetOperation(s.tgval)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.listed_series={0x84}
function s.tgval(e,c)
	return c:IsSetCard(0x84)
end