--エッジインプ・ＤＴモドキ (Anime)
--Edge Imp Frightfuloid (Anime)
--Scripted By Sever666
local s,id=GetID()
function s.initial_effect(c)
	--code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(0xad)
	c:RegisterEffect(e1)
end
s.listed_series={0xad}
