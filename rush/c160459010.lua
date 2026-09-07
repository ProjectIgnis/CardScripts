--マハー・ヴァイロ
--Maha Vailo
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.filter(c,tc)
	return c:IsFaceup() and c:GetEquipTarget()==tc
end
function s.val(e,c)
	local tp=e:GetHandler():GetControler()
	return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_SZONE,0,nil,e:GetHandler())*500
end