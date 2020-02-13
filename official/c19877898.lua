--アルティメット・インセクト LV7
--Ultimate Insect LV7
local s,id=GetID()
function s.initial_effect(c)
	--atk,def down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(-700)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
s.listed_names={34830502}
s.LVnum=7
s.LVset=0x5d
function s.con(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
