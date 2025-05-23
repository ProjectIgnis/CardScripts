--封印されしエクゾディア
--Exodia the Forbidden One
local s,id=GetID()
function s.initial_effect(c)
	--win
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={8124921,44519536,70903634,7902349}
function s.check(g)
	local a1=false
	local a2=false
	local a3=false
	local a4=false
	local a5=false
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if code==8124921 then a1=true
			elseif code==44519536 then a2=true
			elseif code==70903634 then a3=true
			elseif code==7902349 then a4=true
			elseif code==id then a5=true
		end
	end
	return a1 and a2 and a3 and a4 and a5
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local wtp=s.check(g1)
	local wntp=s.check(g2)
	if wtp and not wntp then
		Duel.ConfirmCards(1-tp,g1)
		Duel.Win(tp,WIN_REASON_EXODIA)
	elseif not wtp and wntp then
		Duel.ConfirmCards(tp,g2)
		Duel.Win(1-tp,WIN_REASON_EXODIA)
	elseif wtp and wntp then
		Duel.ConfirmCards(1-tp,g1)
		Duel.ConfirmCards(tp,g2)
		Duel.Win(PLAYER_NONE,WIN_REASON_EXODIA)
	end
end