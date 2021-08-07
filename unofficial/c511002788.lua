--Quiz Panel - Ra 30
os = require('os')
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51102781,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,g)
	return g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local endtime=0
	local check=true
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,3,nil)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,nil,g)
	local start=os.time()
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4006,8))
	local tc=Duel.AnnounceNumberRange(1-tp,1,Duel.GetFieldGroupCount(tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0))
	endtime=os.time()-start
	check=endtime<=10 and tc==ct
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
	if check then
		Duel.Damage(tp,1200,REASON_EFFECT)
	else
		local a=Duel.GetAttacker()
		if a and a:IsRelateToBattle() then
			Duel.Destroy(a,REASON_EFFECT)
		end
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
