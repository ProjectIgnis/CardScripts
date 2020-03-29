--真エクゾディア
--True Exodia
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--lose condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.loseop)
	c:RegisterEffect(e1)
end
s.listed_series={0x40}
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSetCard(0x40)
end
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if g:FilterCount(s.filter,nil)==#g and #g==4 and g:GetClassCount(Card.GetCode)==4 then
		Duel.Win(1-c:GetControler(),WIN_REASON_TRUE_EXODIA)
	end
end
